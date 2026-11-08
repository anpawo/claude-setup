---
name: ui-tweak
description: Make a visual change to an existing website or app interface and verify substantial changes with an offscreen or headless capture. Use for layout, styling, animation, and visual bugs, not backend-only work.
---

# UI tweaks

1. Identify the exact project, screen, and element from the request and its context. Read the relevant source and local instructions before editing.
2. Make the smallest change that meets the visual request. Keep the product's established language and components.
3. Never open a window, app, simulator, or emulator to verify the result. Use headless browser rendering for web, offscreen Qt rendering, Paparazzi or Robolectric for Android, and a windowless render path for macOS apps.
4. For a substantial visual change, capture and inspect an image, then share the capture and state what it shows. Text, color, or padding-only changes do not need a capture.
5. If no windowless verification path exists, say so before asking the user to inspect the live app. Do not publish or deploy unless asked.

Use the `playwright-cli` skill for headless web captures.
