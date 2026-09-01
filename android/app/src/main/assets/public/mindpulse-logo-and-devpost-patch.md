# MindPulse — logo + Devpost copy patch

## 1. Add the logo to the repo
Drop both files into a new folder:
```
assets/
  mindpulse-logo-white.png        (white bg — use in README, social)
  mindpulse-logo-transparent.png  (transparent — use in header, favicon source)
```

## 2. index.html — paste inside <head>, don't touch anything else
```html
<link rel="icon" type="image/png" href="/assets/mindpulse-logo-transparent.png">
```

If there's a header/nav element with the "MindPulse" title text, add the logo right before it, e.g.:
```html
<img src="/assets/mindpulse-logo-transparent.png" alt="MindPulse logo" width="32" height="32" style="vertical-align:middle;margin-right:8px;">
```
Adjust the width/height to match whatever your header's font-size looks like — 28–36px usually sits well next to a wordmark.

## 3. manifest.webmanifest — add to the "icons" array (create the array if it doesn't exist)
```json
{
  "src": "/assets/mindpulse-logo-transparent.png",
  "sizes": "415x386",
  "type": "image/png"
}
```

## 4. README.md — add near the top, right under the title
```markdown
<img src="assets/mindpulse-logo-white.png" alt="MindPulse logo" width="120">
```

---

## 5. Devpost Story — replace the existing sections with this (copy-paste ready)

Two real bugs in the current live version, independent of tone: the bullet lists under "What it does" are missing a space after each `-`, so Devpost won't render them as a list — and the RMS formula under "How we built it" uses raw LaTeX (`$$...$$`), which Devpost doesn't render, so it currently shows as broken text with literal dollar signs. Both are fixed below, along with tightening the language.

### Inspiration
A few of us have family in maternal-fetal medicine and see firsthand how hard the first months are for new parents trying to read what their baby needs at 2am. At the same time, we kept seeing stories about baby monitors and smart-home mics getting breached or quietly shipping audio to the cloud. Handing a stranger's server a live feed of your sleeping baby's room felt like a bad trade for convenience. We wanted something that was actually useful — learns what settles *your* baby — without ever needing to trust anyone else with the audio.

### What it does
- **Local audio analysis** — listens to room sound patterns entirely in browser memory, nothing leaves the device by default.
- **Smart, safe responses** — on sustained noise like crying or stirring, it can fade in a synthesized white, pink, or brown noise response, tuned over time to what actually settles that specific baby.
- **Absolute privacy** — raw audio is never recorded, saved, or uploaded. If a parent wants long-term sleep trends, only derived, batched events (timestamps, not sound) are optionally synced.
- **Safety first** — output is capped under 50 dB per AAP sound-machine guidance.

### How we built it
The frontend is HTML, CSS, and vanilla JS on the Web Audio API — no server-side audio processing at all. We calculate rolling RMS energy on the live audio buffer, and a sustained rise above a calibrated threshold triggers a gentle DSP-synthesized noise response. The optional backend is FastAPI and Postgres behind Docker Compose, and it only ever accepts derived feature vectors and timestamps — there's no audio endpoint in the API at all.

### Challenges we ran into
Browser autoplay policy blocks any audio context from starting without a user gesture, so we had to design an explicit opt-in flow instead of just starting to listen on page load. The harder problem was calibration — babies make a lot of incidental noise, and tuning the rolling-average threshold so the app responds to real distress instead of every rustle took real trial and error.

### Accomplishments we're proud of
Getting a genuinely zero-audio-leakage architecture working while still feeling "smart" — and building the white/pink/brown noise synthesizer algorithmically on the Web Audio API instead of looping MP3 files, so it stays lightweight with no audio assets to ship.

### What we learned
Real-time signal processing in the browser, what it actually takes to design a local-first PWA, and the gap between "runs on my machine" and "deployed somewhere a stranger can open a link and use it."

### What's next for MindPulse
- A tiny quantized TensorFlow.js model running fully on-device to tell cry types apart, still with zero audio leaving the browser.
- Full offline PWA support so a dropped wifi connection at 3am doesn't break monitoring.
- An open, strictly opt-in feature-vector dataset so the detection model keeps improving without ever asking anyone to hand over raw audio.
