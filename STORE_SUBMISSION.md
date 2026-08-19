# Store Submission Checklist

This isn't legal advice (I'm not a lawyer) — it's a practical checklist of
what both stores will actually ask you for. Given MindPulse touches
microphone audio and baby-related data, expect both stores' review teams to
look closely; the disclaimers already in your UI ("not a medical device or
certified baby monitor") are exactly the right instinct to keep front and
center in your store listing too, not just inside the app.

## 1. Accounts you need

| | Cost | Notes |
|---|---|---|
| Google Play Console | $25 one-time | Can take a few hours to a day to verify identity |
| Apple Developer Program | $99/year | Can take 24-48h for approval; individual or org enrollment |

## 2. A real, hosted privacy policy (required by both stores — not optional)

Both stores require a **publicly accessible URL** to a privacy policy before
they'll let you submit, because the app requests microphone access and
creates user accounts. I put a starting draft in `PRIVACY_POLICY.md` based
on what your backend actually stores (email, hashed password, baby name/
birth month, derived sleep session data — never raw audio). You'll need to:
1. Review/edit it (I'd suggest an actual read-through with a lawyer or at
   least Google's/Apple's own guidelines, given the health-adjacent
   subject matter).
2. Host it somewhere public — a page on your Netlify site, a GitHub Pages
   site, or even a Google Doc set to "anyone with the link."
3. Put that URL in both store listings.

## 3. Listing assets you'll need to prepare

**Google Play:**
- App icon: 512×512 PNG (I generated `resources/icon.png` at 1024×1024,
  which downsizes fine)
- Feature graphic: 1024×500 PNG/JPG (not auto-generated — this is marketing
  banner art, you'll want to design this)
- At least 2 phone screenshots (min 320px, max 3840px on the long edge)
- Short description (80 chars), full description (4000 chars)
- Content rating questionnaire (answer honestly about mic use, account
  creation, no ads/no user-generated content sharing)
- **Data safety form** — declares what data the app collects/shares. Based
  on your backend: collects **email, and app activity/derived sleep
  metrics**; does NOT collect audio recordings, precise location, or
  financial info. Mark data as encrypted in transit (true once you're on
  HTTPS) and note users can request deletion.

**Apple App Store:**
- App icon: 1024×1024 PNG, no transparency (I generated
  `resources/icon.png` — already opaque)
- Screenshots for at least one 6.7" iPhone size (others can reuse via
  App Store Connect's auto-scaling, though Apple's checks are getting
  stricter about this — check current requirements in App Store Connect)
- Privacy Nutrition Label (App Store Connect's own form, similar intent to
  Play's Data Safety form above) — same honest answers apply
- App Privacy: since you collect an email + account data, you'll declare
  "Data Linked to You" for account info; derived sleep metrics likely count
  too since they're tied to an account

## 4. Category & age rating

- Don't select "Made for Kids" / Apple's Kids Category — MindPulse is a
  tool *for parents*, not an app used directly by children. Selecting the
  kids category triggers a much stricter, different review process (COPPA-
  related) that doesn't fit this app.
- A reasonable category: Health & Fitness, Parenting, or Lifestyle,
  depending on how you want to position it.

## 5. Language to be careful with

Both stores (Apple especially) scrutinize health/medical claims. Your
in-app copy already does the right thing by saying MindPulse "can help spot
a possible disturbance" and explicitly is "not a medical device or
certified baby monitor" — keep that same careful, non-diagnostic language
in your store description too. Avoid words like "monitor your baby's
breathing," "detect apnea," "medical-grade," or anything implying a safety
guarantee — that's the kind of claim that gets health apps rejected or
pulled.

## 6. Before you hit submit

- [ ] Backend deployed over HTTPS, `www/config.js` updated and re-synced
- [ ] Tested sign-up/sign-in/baby profile/monitoring on a real device build
- [ ] Privacy policy live at a public URL
- [ ] Data safety / privacy nutrition label filled out accurately
- [ ] Screenshots + icon + description ready
- [ ] Release signed (Android) / archived with a valid provisioning profile
      (iOS)
