# Himalaya

A high-performance **zero-latency** brickwall limiter for broadcast, streaming, and music mastering with multiband processing and modern dark neon aesthetics. Built with JUCE 8 + WebView (Vite / React 19 / MUI). Ships as **VST3 / AU / AAX / Standalone** on Windows & macOS and **VST3 / LV2 / CLAP / Standalone** on Linux.

> **Note**: This project is a fork of [ZeroLimit](https://github.com/Jun-Murakami/ZeroLimit) by [Jun Murakami](https://github.com/Jun-Murakami).

Maintained by **scobru** — [https://github.com/scobru/himalaya](https://github.com/scobru/himalaya)

## Highlights

- **0-sample latency** — no lookahead. Instant attack, time-constant release. Suitable for live/broadcast where monitoring delay is unacceptable.
- **Single or Multi-band** — toggle between a single wideband limiter and a 3 / 4 / 5-band multiband limiter.
- **Modern Dark Neon Aesthetic** — high-contrast electric cyan meters, amber reduction indicators, and deep dark panel styling matching Spectra Denoiser and Pressor2000.
- **Zero-config by design** — crossover frequencies and per-band release times are preset to musically sensible values. Users only touch Threshold, Output, Mode, and Band count.
- **Preserves vocal intelligibility** — the 3-band mode keeps the entire vocal spectrum (~120 Hz – 5 kHz) within a single phase-coherent band.
- **Auto Release** — program-dependent dual-envelope release (fast + slow, min). Per-band time constants are adapted to each band's center frequency in multiband mode.
- **Auto Makeup Gain** — lowering the threshold automatically compensates the post-limiter level.
- **Five-mode metering** — Input L/R, Gain Reduction, Output L/R, with Peak / RMS / Momentary LKFS (ITU-R BS.1770-4) switchable.
- **Waveform display mode** — Pro-L style oscilloscope (~7 sec scrollback): input envelope, threshold line, and per-sample gain-reduction reflection. Switch on the fly between meter view and waveform view.
- **Link** — Threshold ⇔ Output Gain move together while preserving their relative offset.
- **Formats**: VST3, AU (macOS), AAX (when SDK present), LV2 / CLAP (Linux), Standalone.

## Requirements

- CMake 3.22+
- C++17 toolchain
  - Windows: Visual Studio 2022 with C++ workload
  - macOS: Xcode 14+
  - Linux: gcc 13+ / clang + required development packages
- Node.js 18+ and npm (for the WebUI)
- JUCE 8 (included as a submodule)
- `clap-juce-extensions` (included as a submodule)
- Optional: AAX SDK for Pro Tools builds (drop at `aax-sdk/`)
- Optional: Inno Setup 6 for the Windows installer

## Getting started

```bash
# 1. Clone with submodules
git clone https://github.com/scobru/himalaya.git
cd himalaya
git submodule update --init --recursive

# 2. WebUI dependencies
cd webui && npm install && cd ..

# 3. Build (Windows)
powershell -ExecutionPolicy Bypass -File build_windows.ps1 -Configuration Release
# → produces releases/<VERSION>/Himalaya_<VERSION>_Windows_VST3_CLAP_Standalone.zip
#   and (if Inno Setup 6 is installed) Himalaya_<VERSION>_Windows_Setup.exe

# 4. Build (macOS)
./build_macos.zsh

# 5. Build (Linux)
bash build_linux.sh
```

### Pro Tools (AAX) Support

Himalaya includes native support for Avid Pro Tools via the **AAX** format:
1. **Compiling AAX**:
   - Place the Avid AAX SDK in `aax-sdk/` or set the `JUCE_AAX_SDK_PATH` environment variable.
   - CMake automatically enables the `Himalaya_AAX` target with `AAX_ePlugInCategory_Dynamics`.
   - On macOS, builds `Himalaya.aaxplugin` (dest: `/Library/Application Support/Avid/Audio/Plug-Ins/`).
   - On Windows, builds `Himalaya.aaxplugin` (dest: `C:\Program Files\Common Files\Avid\Audio\Plug-Ins\`).
   - *Commercial Pro Tools*: Retail Pro Tools requires AAX binaries to be digitally signed using PACE Eden (`wraptool` with Avid developer certificate). For Pro Tools Developer Edition, unsigned binaries work out of the box.
2. **Instant Pro Tools use via VST3 Wrapper**:
   - To use Himalaya immediately in any retail Pro Tools version without needing PACE signing, load `Himalaya.vst3` through an AAX wrapper such as **Blue Cat's PatchWork** or **DDMF Metaplugin**.

### Building on Linux

Tested on modern glibc-based distributions with `webkit2gtk-4.1` available.

```bash
sudo apt update
sudo apt install -y \
  build-essential pkg-config cmake ninja-build git \
  libasound2-dev libjack-jackd2-dev libcurl4-openssl-dev \
  libfreetype-dev libfontconfig1-dev \
  libx11-dev libxcomposite-dev libxcursor-dev libxext-dev \
  libxinerama-dev libxrandr-dev libxrender-dev \
  libwebkit2gtk-4.1-dev libglu1-mesa-dev mesa-common-dev libgtk-3-dev

git submodule update --init --recursive   # JUCE + clap-juce-extensions
bash build_linux.sh                        # Release VST3 / LV2 / CLAP / Standalone + zip
```

Output:

- Build artefacts: `build-linux/plugin/Himalaya_artefacts/Release/{VST3,LV2,CLAP,Standalone}/`
- Auto-installed: `~/.vst3/Himalaya.vst3`, `~/.lv2/Himalaya.lv2`, `~/.clap/Himalaya.clap`
- Distribution zip: `releases/<VERSION>/Himalaya_<VERSION>_Linux_VST3_LV2_CLAP_Standalone.zip`

### Manual CMake build (for development)

```bash
# Windows (Debug)
cmake -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Debug --target Himalaya_VST3

# macOS (Debug)
cmake -B build -G Xcode
cmake --build build --config Debug --target Himalaya_VST3
```

### Development mode (hot-reload WebUI)

```bash
# Terminal A: Vite dev server
cd webui && npm run dev

# Terminal B: Debug build of the plugin
cmake --build build --config Debug --target Himalaya_Standalone
```

Debug builds load the WebUI from `http://127.0.0.1:5173`. Release builds embed the bundled assets via `juce_add_binary_data`.

## Parameters

| ID             | Type                 | Range / Values                     | Default  | Notes                                                                 |
| -------------- | -------------------- | ---------------------------------- | -------- | --------------------------------------------------------------------- |
| `THRESHOLD`    | float (dB)           | -30 .. 0                           | 0 dB     | Brickwall ceiling. 0 dB = bypass-equivalent.                          |
| `OUTPUT_GAIN`  | float (dB)           | -30 .. 0                           | 0 dB     | Post-limiter trim (downward only).                                    |
| `RELEASE_MS`   | float (ms, log skew) | 0.01 .. 1000                       | 1.0 ms   | Manual release (Single-band only; ignored in Multi).                  |
| `AUTO_RELEASE` | bool                 | false / true                       | true     | Program-dependent dual-envelope. Forced true in Multi.                |
| `LINK`         | bool                 | false / true                       | false    | Locks Threshold and Output Gain to a constant offset.                 |
| `METERING_MODE`| choice               | Peak / RMS / Momentary             | Peak     | Display mode for IN / OUT meters. Forced to Peak in Waveform view.    |
| `MODE`         | choice               | Single / Multi                     | **Multi**| Zero-latency wideband vs. multiband limiter.                          |
| `BAND_COUNT`   | choice               | 3 Band / 4 Band / 5 Band           | **3**    | Active only when MODE = Multi.                                        |
| `DISPLAY_MODE` | choice               | Metering / Waveform                | Metering | Center-panel visual: 5-bar meter array vs. oscilloscope waveform.     |

## Multiband details

All multiband modes use **Linkwitz-Riley 4th-order IIR** crossovers (cascaded 2nd-order Butterworths, Q = 1/√2). The tree-cascade topology plus allpass phase alignment guarantees that, when band gains are equal, the sum is magnitude-flat (the signal passes through as an all-pass response, i.e. phase-rotated but un-colored).

| Mode    | Crossovers                   | Rationale                                                  |
| ------- | ---------------------------- | ---------------------------------------------------------- |
| 3-band  | 120 Hz / 5 kHz               | Broadcast-first. Keeps the full vocal spectrum (F0 through presence) inside a single phase-coherent Mid band. |
| 4-band  | 150 Hz / 5 kHz / 15 kHz      | Matches the default of Steinberg's MultibandCompressor. Adds an Air band on top of the 3-band layout. |
| 5-band  | 80 / 250 / 1k / 5k Hz        | Finer spectral control for music mastering; crossovers inevitably traverse vocal formants. |

Release time constants are per-band and adapted to each band's center frequency (low bands slower, high bands faster). In Multi mode the release controls in the UI are disabled since each band runs its own auto-release.

After the bands are summed, a final safety limiter catches any residual peak from phase reconstruction so the output is guaranteed brickwall at the threshold.

## Waveform display mode

The center panel can be toggled between the conventional 5-bar meter array and oscilloscope view. Toggle live via the `Metering / Waveform` switch at the bottom-right of the Release section.

- **Waveform envelope (cyan)** — pre-limiter input peaks, merged L/R absolute value, downsampled to 200 Hz slices (~5 ms/slice) and scrolled right-to-left over a 7-second window.
- **Threshold line (white, dashed)** — horizontal indicator that tracks the current Threshold parameter.
- **Above-threshold region (light gray)** — the portion of the virtual input envelope that would exceed threshold. Rendered as a muted overlay.
- **Gain-reduction reflection (amber/red)** — mirrored below the threshold line in real-time. The depth at each slice represents the *actual* per-sample gain applied by the limiter, not a simple input-above-threshold calculation, so the envelope reflects release-envelope behavior faithfully.
- **Right-side strip** — a thin GR bar + OUT meter remain visible even in waveform view so level and reduction can still be read at a glance. Metering mode is pinned to Peak here.
- **Performance** — canvas drawing is paused during window resize to keep drag interactions smooth; it resumes automatically once the ResizeObserver settles.

Internally the DSP tracks per-sample gain into a scratch buffer, so the visualization resolution is decoupled from the DAW's block size.

## Latency verification

Himalaya reports **0 samples** to the host. To confirm empirically in your DAW:

1. Open the plugin info / delay compensation display — e.g. in Cubase: *Studio → Plug-in Manager* or the MixConsole insert header shows `Latency: 0 samples`.
2. Null test — duplicate a clip on two tracks; insert Himalaya on one (Threshold 0 dB, Output 0 dB so nothing gets limited); invert the polarity of the other; sum. In Single mode this nulls to silence. In Multi mode a phase-rotated residual remains (that is LR4 IIR's phase rotation, not latency) — inspect the transient peak positions, they align sample-accurately.

## Directory layout

```
Himalaya/
├─ plugin/              # JUCE plugin (C++)
│  ├─ src/
│  │  ├─ PluginProcessor.*        # APVTS, DSP chain entry
│  │  ├─ PluginEditor.*           # WebView init, Web↔APVTS relays
│  │  ├─ ParameterIDs.h
│  │  ├─ KeyEventForwarder.*      # WebView → host DAW key forwarding
│  │  └─ dsp/
│  │     ├─ Limiter.*             # Zero-latency brickwall core
│  │     ├─ CrossoverLR4.*        # 3/4/5-band LR4 IIR crossover
│  │     ├─ MultibandLimiter.*    # Multiband wrapper
│  │     └─ MomentaryProcessor.*  # ITU-R BS.1770-4 Momentary LKFS
│  └─ CMakeLists.txt
├─ webui/               # Vite + React 19 + MUI frontend
│  ├─ src/
│  │  ├─ App.tsx
│  │  ├─ components/{ParameterFader,VUMeter,ReleaseSection,LicenseDialog,...}.tsx
│  │  ├─ hooks/{useJuceParam,useHostShortcutForwarding,...}.ts
│  │  └─ bridge/juce.ts
│  └─ package.json
├─ wasm/                # Pure-C++ port of the DSP, compiled to WebAssembly via Emscripten
├─ cmake/               # Version.cmake, icon
├─ installer.iss        # Inno Setup script for Windows installer
├─ build_windows.ps1    # Windows release build pipeline
├─ build_macos.zsh      # macOS release build pipeline
├─ VERSION              # Single source of truth for the version string
└─ LICENSE
```

## License

This project is licensed under the **GNU Affero General Public License v3.0 or later** (AGPL-3.0-or-later) — see the [LICENSE](LICENSE) file for the full text.

It uses [JUCE](https://juce.com/) under the AGPLv3 option of its dual-licensing scheme.

## Credits

Originally developed by [Jun Murakami](https://github.com/Jun-Murakami) as [ZeroLimit](https://github.com/Jun-Murakami/ZeroLimit). Rebranded, customized, and maintained by **scobru**. Built on **JUCE** with an embedded **WebView2 / WKWebView** frontend.
