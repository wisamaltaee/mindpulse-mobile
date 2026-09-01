// MindPulse mobile build config.
// This file is NOT overwritten when the web app source (index.html/app.js/styles.css)
// is refreshed from a new upload - it's the one place to point the native app at your
// live backend.
//
// IMPORTANT: before you submit to the App Store / Play Store, replace the URL below
// with your deployed backend's HTTPS URL (e.g. a Render or Railway URL). The app will
// NOT be able to sign in, save baby profiles, or sync history until this is set,
// because "http://localhost:8000" refers to the phone itself, not your server.
window.MINDPULSE_CONFIG = {
  API_URL: "https://REPLACE-WITH-YOUR-DEPLOYED-BACKEND.example.com"
};
