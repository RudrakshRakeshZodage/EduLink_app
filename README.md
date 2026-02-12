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

Prerequisites: Flutter SDK and a supported platform toolchain (Android/iOS).

1. Clone the repo and install deps:

	git clone https://github.com/RudrakshRakeshZodage/EduLink_app.git
	cd EduLink_app
	flutter pub get

2. Run the app (example for desktop/web):

	flutter run

3. To use the OpenAI integration locally, provide your key at runtime:

```powershell
# Windows PowerShell
flutter run --dart-define=OPENAI_API_KEY=sk-REPLACE_WITH_YOUR_KEY
```

## Notes on secrets

- Never commit API keys or secrets. Use `--dart-define` for local runs and
  store secrets in your CI provider's secret store (e.g., GitHub Secrets).
- If a key was committed accidentally, rotate it immediately.

## Minimal project layout

- `lib/` — app source (screens, services, models, widgets)
- `assets/` — images and static assets
- platform folders — `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`

---

This README focuses on the essentials: features, quickstart, and secrets
best-practices. Tell me if you want a longer developer guide or a
`CONTRIBUTING.md` next.

---

If you'd like, I can also:

- Add a short developer `CONTRIBUTING.md` with run instructions
- Create a small `README` section describing CI / GitHub Actions secrets setup
- Commit and push this README update for you

Tell me which of those you'd like next.
