# Updating MindPulse Later

You asked for this to be set up so future updates are easy. Here's how it
works, and how to keep the project structure so it stays that way.

## The split that makes this repeatable

- **`www/`** holds only your actual web app: `index.html`, `app.js`,
  `styles.css`, `manifest.webmanifest`, `service-worker.js`, logo images.
  This is what changes every time you update MindPulse.
- **`www/config.js`** is the one exception — it holds your production
  backend URL and is *not* part of your original source, so it should
  survive future updates untouched.
- **`android/`, `ios/`, `resources/`, `.github/`** are the native wrapper —
  generated once, then only touched again if you add native plugins,
  change permissions, or change the app icon.

## Option A: send me the updated app again

Next time you upload a new MindPulse zip in a conversation with me, tell me
you want it re-synced into this mobile wrapper (mention this project). I'll:
1. Replace the changed files inside `www/` (keeping `www/config.js` as-is
   unless you say otherwise).
2. Run `npx cap sync` to push the changes into both `android/` and `ios/`.
3. Re-zip and hand back the updated project.

If you've made native-side changes too (new permission, new icon, etc.)
just mention that as well.

## Option B: do it yourself with the included script

```
./sync-web-update.sh /path/to/your/updated/mindpulse-main
npx cap sync
```
This copies over the web files (skipping `config.js`) and leaves everything
else alone. Then rebuild via Android Studio/Xcode or push to GitHub to let
the Actions workflows build fresh APKs.

## A note on the service worker cache

`service-worker.js` uses a cache name (`mindpulse-v2`). If you're also
still serving the app on the web (Netlify) as a PWA, remember to bump that
version string when you ship changes there, or returning visitors' browsers
may keep serving old cached files. This doesn't affect the native app builds
here, since the native builds now skip service worker registration
entirely (see README).
