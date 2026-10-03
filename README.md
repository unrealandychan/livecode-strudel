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

## ⚡ Offline Mode & Eliminating Audio Lag

### Why does complex music lag or stutter?
When you write patterns with drums and acoustic instruments:
```javascript
s("bd [~ sd] bd [sd hh]") // Uses samples: bd, sd, hh
```
Strudel streams raw audio sample files **on-demand over HTTP** from GitHub/CDN (`tidalcycles/dirt-samples`).
- If your internet connection has high latency, packet loss, or poor bandwidth, audio buffers cannot download in time for the audio scheduler's lookahead window (100–200ms).
- This causes **missed beats, audible jitter, delayed triggers, and stuttering**.
- Once a sample is downloaded, Chromium's persistent cache (`~/.cache/strudel-nvim`) keeps it on disk, so subsequent loops play smoother — but any new sample or pattern variation triggers more network downloads.

---

### Solutions for Zero Lag & Full Offline Playback

#### Solution 1: Pure Synth Live-Coding (100% Offline by Default)
WebAudio software oscillators require **zero network downloads** and have **0ms latency**:
- **Instruments**: `s("sawtooth")`, `s("sine")`, `s("triangle")`, `s("square")`
- **Modifiers**: `.cutoff()`, `.decay()`, `.resonance()`, `.delay()`, `.room()`
- Example (see `03_melodic_synths_and_bass.str`):
  ```javascript
  note("c2 [eb2 g2] bb2 c3")
    .s("sawtooth")
    .lpf(sine.range(400, 3000).slow(4))
    .resonance(14)
    .decay(0.2)
  ```
*This works flawlessly even with airplane mode turned on!*

#### Solution 2: Local Sample Server with `@strudel/sampler`
If you need drum kits, acoustic instruments, or custom sound packs without relying on the internet:
1. Clone or download sample packs onto your machine:
   ```bash
   git clone --depth 1 https://github.com/tidalcycles/dirt-samples.git ~/dirt-samples
   ```
2. Run the official Strudel sample server:
   ```bash
   npx @strudel/sampler ~/dirt-samples
   ```
   *(This serves your samples locally on `http://localhost:5432`)*
3. In your Strudel code (or buffer header):
   ```javascript
   samples('http://localhost:5432')
   s("bd [~ sd] bd [sd hh]")
   ```
   All audio is now loaded directly from your SSD with **zero network lag**!

#### Solution 3: Pre-Warming the Sample Cache
Because `strudel.nvim` stores browser cache persistently in `~/.cache/strudel-nvim`:
- Run through your performance track once while connected to Wi-Fi before going on stage.
- All downloaded samples are cached locally for the rest of your session.

---

1. `01_starter_beats.str` — Basic Tidal mini-notation (kicks, snares, hats, subdivisions).
2. `02_euclidean_and_polyrhythms.str` — Euclidean rhythms `(3,8)`, polymeter `<>`, and speed multipliers.
3. `03_melodic_synths_and_bass.str` — Synth waveforms, note sequences, chords, low-pass filter (`lpf`), reverb, and delay.
4. `04_full_performance.str` — Multi-track layered jam session (`stack(...)`).
5. `05_visuals_with_hydra.str` — Algorithmic reactive visual patterns using Hydra + Strudel.
6. `06_dj_set.str` (or `06_dj.str`) — Live dinner lounge DJ performance (Mellow Jazz, Neo-Soul & Chillhop) with zero-drum ambient intros and seamless Neovim hot-swapping (`<leader>mu`).

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
