# MindPulse — Mobile App Wrapper

This turns your MindPulse web app into a real native app project using
**Capacitor** (the standard, industry-used tool for taking an existing
HTML/CSS/JS app and packaging it as an installable Android app and iOS app,
while reusing 100% of your existing frontend code — nothing was rewritten).

```
mindpulse-mobile/
├── www/                  ← your web app (index.html, app.js, styles.css...)
├── config.js              ← NEW: one file to set your live backend URL
├── android/               ← native Android project (open in Android Studio)
├── ios/                   ← native iOS project (open in Xcode, Mac only)
├── resources/              ← source icon/splash used to generate all sizes
└── .github/workflows/      ← optional: build APKs automatically in the cloud
```

**Important — I could not compile the actual APK/IPA file for you in this
session.** Building Android apps needs the Android SDK + Gradle, and building
iOS apps needs Xcode, which only runs on a Mac — neither is available in
this sandboxed environment, and it can't download them either (network
access here is restricted to a small allowlist of package registries). What
I *did* do is generate the complete, correct native project for both
platforms, wire up permissions/icons/splash screens, and set up two paths to
get a real, installable build with almost no manual setup on your end
(below). This is the real, standard project structure — the same thing
`npx cap add android/ios` produces on any developer's machine.

---

## Fastest path: let GitHub build it for you (no Mac, no Android Studio)

I included `.github/workflows/android-build.yml` and `ios-build.yml`. These
run on GitHub's own servers, which come with the Android SDK and Xcode
already installed — so you don't need to install anything locally.

1. Push this folder to a new GitHub repo (create one at github.com/new, then
   `git init && git add . && git commit -m "MindPulse mobile" && git remote add origin <your-repo-url> && git push -u origin main`).
2. Go to the repo's **Actions** tab. The Android workflow will run
   automatically and produce a debug `.apk` you can download from the run's
   "Artifacts" section and install directly on an Android phone (Settings →
   allow installs from unknown sources, or just AirDrop/email it to yourself).
3. The iOS workflow builds and verifies the app compiles for the iOS
   Simulator (proves the project is healthy) but can't produce an
   App-Store-ready `.ipa` without your own Apple Developer account for
   signing — see below.

## Building locally instead

**Android** (needs [Android Studio](https://developer.android.com/studio), free):
```
npm install
npx cap sync
npx cap open android
```
Then in Android Studio: Build → Build Bundle(s)/APK(s) → Build APK(s), or
just press the ▶ Run button with an emulator/device connected.

**iOS** (needs a Mac with [Xcode](https://apps.apple.com/app/xcode/id497799835)):
```
npm install
npx cap sync
npx cap open ios
```
This opens `App.xcodeproj` (this Capacitor version uses Swift Package
Manager, not CocoaPods, so there's no separate `.xcworkspace` or `pod
install` step). Press ▶ Run to launch it in the simulator, or Product →
Archive to prepare it for TestFlight/App Store upload once you have a
Developer account and signing set up.

---

## Before you submit anywhere: fix the backend URL

Your app currently talks to your account/sync backend at whatever's in
**`www/config.js`**. Right now it's a placeholder. The core room-listening
feature works fully offline/on-device either way, but sign-in, baby
profiles, and history sync will silently fail until you:

1. Deploy `backend/` somewhere reachable over HTTPS (Render, Railway, Fly.io
   are common free/cheap options for a small FastAPI app).
2. Put that URL in `www/config.js`.
3. Run `npx cap sync` again so both platforms pick it up.

iOS blocks plain `http://` network requests by default (App Transport
Security), so this needs to be an `https://` URL — using Render/Railway's
default domain gives you HTTPS automatically.

## What I already set up for you

- **Permissions**: `RECORD_AUDIO`/`MODIFY_AUDIO_SETTINGS`/`WAKE_LOCK` on
  Android, `NSMicrophoneUsageDescription` on iOS — required for the room
  listener and lullaby recording to be allowed to use the microphone at all.
  Capacitor's built-in WebView bridge already handles asking the user for
  the runtime permission when the app calls `getUserMedia`, so no extra code
  was needed there.
- **App icon & splash screen**: generated in every required Android/iOS
  size from your existing logo (`resources/icon.png`, `resources/splash.png`
  — dark background matching your `#141817` theme color). Swap those two
  source files and re-run `npx capacitor-assets generate` any time you want
  a different icon.
- **Service worker**: now skipped when running inside the native app (it's
  meant for the browser PWA install path; inside Capacitor everything is
  already bundled locally, so the service worker was only a source of
  potential stale-cache confusion after updates).
- **Android release signing**: wired up to read from environment
  variables/CI secrets rather than needing a key hardcoded anywhere — see
  "Signing your Android app" below.

## Signing your Android app (needed to publish, not needed to test)

Play Store requires every release to be cryptographically signed with a key
only you hold — **if you lose this key, you can never update your app
again**, so back it up somewhere durable (password manager, encrypted
drive) the moment you create it. Generate it locally (not in a shared
environment) with the JDK's built-in tool:

```
keytool -genkeypair -v -keystore mindpulse-release.keystore \
  -alias mindpulse -keyalg RSA -keysize 2048 -validity 10000
```

It'll prompt you for a password and some identity fields (can be anything).
To build a signed release locally:
```
export MINDPULSE_KEYSTORE_PATH=/full/path/to/mindpulse-release.keystore
export MINDPULSE_KEYSTORE_PASSWORD=<the password you chose>
export MINDPULSE_KEY_ALIAS=mindpulse
export MINDPULSE_KEY_PASSWORD=<the password you chose>
cd android && ./gradlew bundleRelease
```
This produces `android/app/build/outputs/bundle/release/app-release.aab` —
the `.aab` format Play Store wants (not a raw `.apk`) for new app listings.

To let the GitHub Actions workflow build this for you instead, add these as
repo secrets (Settings → Secrets and variables → Actions):
- `MINDPULSE_KEYSTORE_BASE64` — run `base64 -i mindpulse-release.keystore`
  and paste the output
- `MINDPULSE_KEYSTORE_PASSWORD`, `MINDPULSE_KEY_ALIAS`, `MINDPULSE_KEY_PASSWORD`

## Building for iOS / App Store

Apple requires a paid Apple Developer Program membership ($99/year) and a
Mac to sign and submit an app — there's no way around either, and no cloud
workaround avoids the $99/year (GitHub's macOS runners still need *your*
signing certificate). Once enrolled:
1. In Xcode, sign in with your Apple ID (Settings → Accounts) and select
   your team under App target → Signing & Capabilities.
2. Set a unique Bundle Identifier (currently `com.mindpulse.app` — see
   below).
3. Product → Archive, then use the Organizer window's "Distribute App" flow
   to upload to App Store Connect (or use **TestFlight** first to test on
   real devices before a public release — strongly recommended).

## About the app ID

Both platforms currently use `com.mindpulse.app` as the unique identifier
(set in `capacitor.config.ts`, `android/app/build.gradle`, and the iOS
target settings). You don't need to own the `mindpulse.app` domain — it just
needs to be unique per store. **This can't be changed after you publish**,
so double check it's what you want first. If you'd rather use something
else, change it in those three places, then `npx cap sync`.

## Known limitations worth knowing about

- `navigator.wakeLock` (used to keep the screen on while monitoring) isn't
  supported in iOS's WKWebView, so on iPhone the screen may still sleep
  during monitoring — your code already fails silently on this (wrapped in
  try/catch), so nothing breaks, but the feature just won't do anything on
  iOS. A Capacitor plugin like `@capacitor-community/keep-awake` would fix
  this if it matters to you; I didn't add it since it's a new dependency
  you'd want to review first.
- This wraps your existing browser-based audio analysis as-is. It's the
  fastest path to app stores, but if background monitoring (screen off/app
  backgrounded) ever becomes a requirement, that needs native code, not
  just a wrapped web view.

## Store submission requirements (accounts, listing content, legal)

See **`STORE_SUBMISSION.md`** for the Play Store / App Store checklist —
developer accounts, required listing assets, and the privacy policy /
data-safety disclosures both stores require before they'll accept this kind
of app (it asks for a mic and collects account data, so this part isn't
optional).

## Next time you update the MindPulse web app

See **`UPDATING.md`** — short version: send me the updated project (or run
`sync-web-update.sh` yourself), and only `www/index.html`, `www/app.js`,
`www/styles.css` and similar get replaced. `www/config.js`, the native
`android/`/`ios/` folders, icons, and this whole setup stay intact.
