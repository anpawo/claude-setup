# The figures of a RAM check on Windows: memory use, memory by app, each Claude session with
# what it started, and leftovers (MCP servers or their browsers whose session is gone).
$ErrorActionPreference = 'SilentlyContinue'
$now = Get-Date
$os = Get-CimInstance Win32_OperatingSystem
$procs = @(Get-CimInstance Win32_Process)
$byPid = @{}; foreach ($p in $procs) { $byPid[[int]$p.ProcessId] = $p }

function GB($bytes) { '{0,5:N1}' -f ($bytes / 1GB) }
function Age($p) { $t = $now - $p.CreationDate; '{0}h{1:00}m' -f [int][math]::Floor($t.TotalHours), $t.Minutes }
function IsClaude($p) { $p.Name -eq 'claude.exe' -or $p.CommandLine -match '@anthropic-ai[\\/]claude-code' }
# Windows keeps a dead parent's pid on its children, and may hand that pid to a newer process.
function ParentOf($p) {
    $q = $byPid[[int]$p.ParentProcessId]
    if ($q -and $q.CreationDate -le $p.CreationDate -and $q.ProcessId -ne $p.ProcessId) { $q }
}

$reg = @{}
Get-ChildItem "$HOME\.claude\sessions\*.json" | ForEach-Object {
    $s = Get-Content $_.FullName -Raw | ConvertFrom-Json
    if ($s.pid) { $reg[[int]$s.pid] = $s }
}

'== Memory'
$total = $os.TotalVisibleMemorySize * 1KB; $free = $os.FreePhysicalMemory * 1KB
'used: {0} GB of {1} GB ({2:N0}%)' -f (GB ($total - $free)).Trim(), (GB $total).Trim(), (($total - $free) / $total * 100)
'committed: {0} GB of {1} GB limit' -f (GB (($os.TotalVirtualMemorySize - $os.FreeVirtualMemory) * 1KB)).Trim(), (GB ($os.TotalVirtualMemorySize * 1KB)).Trim()
Get-CimInstance Win32_PageFileUsage | ForEach-Object {
    'page file: {0} GB used of {1} GB' -f (GB ($_.CurrentUsage * 1MB)).Trim(), (GB ($_.AllocatedBaseSize * 1MB)).Trim()
}

''
'== Memory by app (GB, processes)'
$procs | Group-Object {
    if (IsClaude $_) { 'Claude Code' }
    elseif ($_.CommandLine -match 'playwright|mcp') { 'MCP servers and their browsers' }
    else { $_.Name -replace '\.exe$', '' }
} | ForEach-Object {
    [pscustomobject]@{ Bytes = ($_.Group | Measure-Object WorkingSetSize -Sum).Sum; Count = $_.Count; Name = $_.Name }
} | Sort-Object Bytes -Descending | Select-Object -First 15 | ForEach-Object {
    '{0} GB  {1,3}  {2}' -f (GB $_.Bytes), $_.Count, $_.Name
}

# What a session started (MCP servers, browsers, shells) counts for its nearest claude.
$claudes = @($procs | Where-Object { IsClaude $_ })
$kids = @{}
foreach ($p in $procs) {
    if (IsClaude $p) { continue }
    for ($q = ParentOf $p; $q; $q = ParentOf $q) {
        if (IsClaude $q) { $kids[[int]$q.ProcessId] += $p.WorkingSetSize; break }
    }
}
''
'== Claude sessions (GB claude, GB what it started, age, name, -p, folder)'
$claudes | Sort-Object WorkingSetSize -Descending | ForEach-Object {
    $s = $reg[[int]$_.ProcessId]
    $name = if ($s.name) { $s.name } else { '-' }
    $kind = if ($s.entrypoint -eq 'sdk-cli') { '-p' } else { '' }
    $where = if ($s.cwd) { $s.cwd } else { "$($_.CommandLine)".Substring(0, [math]::Min(40, "$($_.CommandLine)".Length)) }
    '{0} {1} {2,9}  {3,-30} {4,-2} {5}' -f (GB $_.WorkingSetSize), (GB $kids[[int]$_.ProcessId]), (Age $_), $name, $kind, $where
}

''
'== Leftovers (parent gone: pid, age, GB, command)'
$procs | Where-Object {
    $_.CommandLine -match 'playwright|mcp|headless' -and $_.CommandLine -notmatch 'cliDaemon' -and -not (ParentOf $_)
} | ForEach-Object {
    $cmd = "$($_.CommandLine)"
    '{0,6} {1,9} {2} GB  {3}' -f $_.ProcessId, (Age $_), (GB $_.WorkingSetSize), $cmd.Substring(0, [math]::Min(90, $cmd.Length))
}
