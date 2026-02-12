# EduLink

EduLink is a cross-platform Flutter application for student–tutor collaboration,
course discovery, and in-app AI assistance. This repository contains the
mobile and desktop Flutter project used to build EduLink.

## Features

- User authentication (Firebase)
- AI tutor/chat powered by OpenAI (client reads API key from runtime)
- Student and tutor profiles, search, and service listings
- Group study, chat, and notifications
- Payment integration and student import/reporting utilities

## Quickstart

Prerequisites: Flutter SDK, Android Studio / Xcode (for mobile builds), and
an editor such as VS Code.

1. Clone the repo:

	git clone https://github.com/RudrakshRakeshZodage/EduLink_app.git
	cd EduLink_app

2. Install dependencies and run the app:

	flutter pub get
	flutter run

3. Open with device selector (Android/iOS/web/desktop) or run:

	flutter run -d chrome

## Secrets & API keys

Do NOT hard-code API keys in source. The project reads the OpenAI key from a
dart-define at runtime. Examples:

```powershell
# Windows PowerShell
flutter run --dart-define=OPENAI_API_KEY=sk-REPLACE_WITH_YOUR_KEY
```

Or set an environment variable in CI or your shell and pass it via your build
system or GitHub Actions secrets.

If an API key was accidentally committed, rotate it immediately — this
repository had a key committed and it was removed from history; rotate any
compromised keys.

## Project layout

- `lib/` — Dart source code (screens, services, models, widgets)
- `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/` — platform folders
- `assets/` — images and other static assets
- `test/` — unit/widget tests

## Contributing

Please open issues or pull requests. For sensitive data, use GitHub Secrets or
environment variables rather than committing keys.

## License

This project doesn't include a license file. Add one if you plan to publish
this repository publicly.

---

If you'd like, I can also:

- Add a short developer `CONTRIBUTING.md` with run instructions
- Create a small `README` section describing CI / GitHub Actions secrets setup
- Commit and push this README update for you

Tell me which of those you'd like next.
