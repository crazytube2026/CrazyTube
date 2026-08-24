# CrazyTube – Watch, Create & Earn

Flutter MVP starter for the CrazyTube concept.

## Included in this prototype
- Google sign-in wiring (requires Firebase configuration)
- One channel profile per signed-in Google account (backend enforcement still needed)
- Home feed with mock videos
- Reels vertical feed
- Video player
- Like, comment, follow UI
- Upload flow for Reel or Long Video
- Long video validation: maximum 10 minutes
- Creator Studio dashboard UI
- Wallet/earnings UI mock
- Settings UI

## Important
This is a source-code MVP, not a production-ready social video platform. Real uploads, transcoding, CDN delivery, moderation, monetization, payment/withdrawal, copyright detection, and server-side one-account enforcement require a backend and production services.

## Run
1. Install Flutter.
2. Run `flutter pub get`.
3. Create a Firebase project and enable Google Sign-In.
4. Add Android/iOS Firebase configuration files.
5. Run `flutter run`.

The app currently uses mock feed data so the UI can be explored before the backend is connected.
