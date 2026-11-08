#!/bin/bash
# The figures of a RAM check on macOS or Linux: memory use, memory by app, each Claude session
# with what it started, and leftovers (MCP servers or their browsers whose session is gone).
set -u
reg=$(find ~/.claude/sessions -maxdepth 1 -name '*.json' -exec cat {} + 2>/dev/null |
    jq -r '[.pid, .name, .entrypoint, .cwd] | @tsv' 2>/dev/null)

echo "== Memory"
if [ "$(uname)" = Darwin ]; then
    # 1 normal, 2 warn, 4 critical: the level Activity Monitor colours its graph with.
    echo "level: $(sysctl -n kern.memorystatus_vm_pressure_level) (1 normal, 2 warn, 4 critical)"
    memory_pressure | sed -n 's/^System-wide memory free percentage: /free: /p'
    sysctl -n vm.swapusage | awk '{u=$6; t=$3; sub(/M/,"",u); sub(/M/,"",t); printf "swap: %.1f GB used of %.1f GB\n", u/1024, t/1024}'
    vm_stat | awk -v ps="$(pagesize)" '/wired down|occupied by compressor/ {
        n = $NF; sub(/\.$/, "", n); k = $0; sub(/:.*/, "", k); printf "%s: %.1f GB\n", k, n * ps / 2^30 }'
    # Footprint as Activity Monitor's "Memory Used": (anonymous - purgeable + wired + compressed) over all the RAM.
    echo "used: $(vm_stat | awk -v total="$(sysctl -n hw.memsize)" '/page size of/ {p=$8} /Anonymous pages/ {a=$3} /Pages purgeable/ {u=$3} /Pages wired down/ {w=$4} /occupied by compressor/ {c=$5} END {printf "%d%%", (a+0-u+w+c)*p/total*100}')"
    echo "total: $(( $(sysctl -n hw.memsize) / 1073741824 )) GB;$(uptime | sed 's/^[^u]*//')"
else
    free -b | awk '/^Mem:/ {printf "used: %.1f GB of %.1f GB, available: %.1f GB\n", $3/2^30, $2/2^30, $7/2^30}
        /^Swap:/ {printf "swap: %.1f GB used of %.1f GB\n", $3/2^30, $2/2^30}'
    [ -r /proc/pressure/memory ] &&
        sed -n 's/^some avg10=\([^ ]*\).*/pressure: \1% of the last 10 s some task waited on memory/p' /proc/pressure/memory
    echo "load$(uptime | sed 's/.*load average//')"
fi

ps axww -o pid=,ppid=,rss=,etime=,command= | REG="$reg" awk '
BEGIN {
    n = split(ENVIRON["REG"], lines, "\n")
    for (i = 1; i <= n; i++) { split(lines[i], f, "\t"); name[f[1]] = f[2]; ep[f[1]] = f[3]; dir[f[1]] = f[4] }
}
{
    if ($5 == "awk") next  # the filter of this very script names the patterns it looks for
    p = $1; pp[p] = $2; mb[p] = $3 / 1024; et[p] = $4; order[++N] = p
    cmd = $0; sub(/^ *[0-9]+ +[0-9]+ +[0-9]+ +[^ ]+ +/, "", cmd); c[p] = cmd
    if ($5 ~ /(^|\/)claude$|\/claude\/versions\//) { g = "Claude Code"; cl[p] = 1 }
    else if (cmd ~ /playwright|mcp/) g = "MCP servers and their browsers"
    else if (match(cmd, /\/[^\/]+\.app\//)) g = substr(cmd, RSTART + 1, RLENGTH - 6)
    else if ($5 ~ /mds|mdworker|Spotlight/) g = "Spotlight"
    else { g = $5; sub(/.*\//, "", g) }
    grp[g] += mb[p]; cnt[g]++
}
END {
    print "\n== Memory by app (GB, processes)"
    s = "sort -rn | head -15"
    for (g in grp) printf "%5.1f GB  %3d  %s\n", grp[g] / 1024, cnt[g], g | s
    close(s)

    # What a session started (MCP servers, browsers, shells) counts for its nearest claude.
    for (i = 1; i <= N; i++) {
        p = order[i]
        if (p in cl) continue
        for (q = pp[p]; q > 1 && (q in pp); q = pp[q]) if (q in cl) { kids[q] += mb[p]; break }
    }
    print "\n== Claude sessions (GB claude, GB what it started, age, name, rc or -p, folder)"
    s = "sort -k1,1rn"
    for (p in cl) {
        kind = c[pp[p]] ~ /remote-control/ ? "rc" : ep[p] == "sdk-cli" ? "-p" : ""
        where = (p in dir) ? dir[p] : substr(c[p], 1, 40)
        printf "%4.1f  %4.1f  %11s  %-30s %-3s %s\n", mb[p] / 1024, kids[p] / 1024, et[p], (p in name && name[p] != "") ? name[p] : "-", kind, where | s
    }
    close(s)

    # A WebKit .xpc service always has launchd for parent: it is left over only once no
    # browser of its Playwright build is alive.
    for (i = 1; i <= N; i++)
        if (c[order[i]] !~ /\.xpc\// && match(c[order[i]], /ms-playwright\/[^\/]+/)) host[substr(c[order[i]], RSTART, RLENGTH)] = 1
    print "\n== Leftovers (parent gone: pid, age, GB, command)"
    for (i = 1; i <= N; i++) {
        p = order[i]
        if (c[p] ~ /\.xpc\// && match(c[p], /ms-playwright\/[^\/]+/) && (substr(c[p], RSTART, RLENGTH) in host)) continue
        # The playwright-cli daemon is detached by design and stops itself after 10 idle minutes.
        # Linux hands orphans to a `systemd --user` subreaper rather than pid 1.
        if ((pp[p] == 1 || c[pp[p]] ~ /systemd --user/) && c[p] ~ /playwright|mcp|headless/ && c[p] !~ /cliDaemon/)
            printf "%6s  %11s  %4.1f  %s\n", p, et[p], mb[p] / 1024, substr(c[p], 1, 90)
    }
}'
