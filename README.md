# Live Coding Algorave with Neovim & Strudel / TidalCycles

A self-contained learning environment for algorithmic live-coding music and visuals directly from Neovim, inspired by the YouTube video **"My NeoVim TidalCycles setup explained: installation and showcase"** and **Strudel (`strudel.nvim`)**.

---

## ⚡ Will this crash my Neovim ENV?

### Short Answer
**No, it will not crash or corrupt your Neovim environment.**

### Detailed Technical Explanation

1. **Process Isolation via Non-blocking Jobs**:
   Both `strudel.nvim` and `tidal.nvim` operate via Neovim's asynchronous job API (`vim.fn.jobstart`).
   - `strudel.nvim` launches Node.js and Chromium in an external subprocess communicating through standard I/O (stdin/stdout).
   - If Node.js, Puppeteer, or Chromium encounters an error, only that child process exits. Neovim's main Lua event loop remains completely unharmed and responsive.

2. **No Memory Leaks or Binary Segfaults**:
   Neither plugin uses C FFI or native compiled Neovim C modules. They are pure Lua wrapper plugins orchestrating external tools.

3. **Comparison: YouTube Setup (TidalCycles) vs. Strudel (`strudel.nvim`)**:

| Aspect | YouTube Video Setup (`tidal.nvim`) | Strudel Setup (`strudel.nvim`) |
| :--- | :--- | :--- |
| **Engine** | Haskell (`ghci` + `tidal` library) | JavaScript / WebAudio (Strudel engine) |
| **Sound Engine** | SuperCollider (`sclang` + `scsynth` + `SuperDirt`) | Browser Web Audio (Chromium / WebSynth) |
| **System Prerequisites** | GHC, Cabal, SuperCollider, SuperDirt, Jack/Pipewire audio routing | Node.js, Chromium *(Already installed on this machine!)* |
| **Crash / Failure Mode** | Fails with `ghci: command not found` if SuperCollider / GHC aren't configured. | Fails with a friendly Lua notification if the browser cannot start. |
| **Setup Complexity** | High (~1-2 hours configuring Haskell quarks & audio engines) | Instant (Works out of the box in 30 seconds) |

---

## 🚀 Quickstart: 2 Ways to Run This

### Option A: 100% Isolated Sandbox (Zero changes to your main Neovim)
You can launch an isolated Neovim instance dedicated specifically to Strudel live-coding:

```bash
cd /home/arch/Projects/livecode-strudel
./launch-sandbox.sh 01_starter_beats.str
```
- Uses its own sandbox config (`sandbox/init.lua`) and plugin cache.
- Leaves your `~/.config/nvim` completely untouched.

---

### Option B: Add to your main LazyVim (`~/.config/nvim`)
If you want live-coding integrated seamlessly into your normal Neovim setup:

1. Copy the prepared plugin spec:
   ```bash
   cp /home/arch/Projects/livecode-strudel/plugin-spec/strudel.lua ~/.config/nvim/lua/plugins/strudel.lua
   ```
2. Open any `.str` or `.std` music file in Neovim:
   ```bash
   nvim /home/arch/Projects/livecode-strudel/01_starter_beats.str
   ```
3. Run `:StrudelLaunch` (or press `<leader>ml`).
4. Chromium will open side-by-side syncing your edits and playing live sound!

---

## 🎭 Presentation Mode: Eliminating the Browser Popup

If you are performing or presenting on stage, having a browser window pop up over your editor looks unprofessional. You have **3 presentation choices**:

### 1. Pure Headless Mode (Zero Popup - Audio Only) — *Now Default!*
Chromium runs as a silent headless background process via Puppeteer.
- **What the audience sees**: Only your full-screen Neovim terminal.
- **Audio**: Plays normally through your system sound engine (PipeWire/ALSA).
- **Configuration** in `opts`:
  ```lua
  headless = true,
  ```

### 2. Hydra Visuals on Projector (No UI Clutter)
If you want to project live algorithmic visuals (e.g., `05_visuals_with_hydra.str`) onto a second monitor or projector without showing the Strudel editor UI or menu controls:
- **Configuration** in `opts`:
  ```lua
  headless = false,
  ui = {
    hide_menu_panel = true,
    hide_top_bar = true,
    hide_error_display = true,
    hide_code_editor = true, -- Leaves only the full-screen visual canvas
  },
  ```

### 3. Hyprland / Omarchy Silent Workspace
If you ever run non-headless mode but don't want it to steal focus or appear on your main screen, route Chromium silently to a hidden or second workspace in `hyprland.conf`:
```ini
windowrulev2 = workspace 9 silent, class:^(chromium)$
```

---

## 🎹 Default Keymaps (Configured in `plugin-spec/strudel.lua`)

| Keymap | Command | Description |
| :--- | :--- | :--- |
| `<leader>ml` | `:StrudelLaunch` | **L**aunch Strudel browser window & sync buffer |
| `<leader>mp` | `:StrudelToggle` | **P**lay / Pause playback |
| `<leader>mu` | `:StrudelUpdate` | **U**pdate live pattern (evaluate changes) |
| `<leader>ms` | `:StrudelStop` | **S**top audio |
| `<leader>mq` | `:StrudelQuit` | **Q**uit Strudel browser process |

---

## 🎼 Learning Files Included in this Subproject

1. `01_starter_beats.str` — Basic Tidal mini-notation (kicks, snares, hats, subdivisions).
2. `02_euclidean_and_polyrhythms.str` — Euclidean rhythms `(3,8)`, polymeter `<>`, and speed multipliers.
3. `03_melodic_synths_and_bass.str` — Synth waveforms, note sequences, chords, low-pass filter (`lpf`), reverb, and delay.
4. `04_full_performance.str` — Multi-track layered jam session (`stack(...)`).
5. `05_visuals_with_hydra.str` — Algorithmic reactive visual patterns using Hydra + Strudel.

---

## 📚 TidalCycles Mini-Notation Cheat Sheet

Strudel uses the exact same rhythmic mini-notation created for TidalCycles:

- `"bd sd"` : Two sounds per cycle (half a bar each).
- `"bd [sd hh]"` : Brackets subdivide a step (snare + hat share step 2).
- `"hh*4"` : Repeats `hh` four times within its step.
- `"bd ~ sd ~"` : Tilde `~` represents a rest/silence.
- `"<c3 e3 g3>"` : Angle brackets cycle through one item per loop cycle.
- `"cp(3,8)"` : Euclidean rhythm: 3 hits evenly distributed over 8 pulses (Tresillo rhythm).
- `stack(s1, s2, s3)` : Plays multiple patterns simultaneously.
