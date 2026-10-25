# ChatBot — Flutter AI Chatbot with Groq API

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-App-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter app" />
  <img src="https://img.shields.io/badge/Dart-Language-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/AI-Groq%20API-F55036?style=for-the-badge" alt="Groq API" />
  <img src="https://img.shields.io/badge/Model-gpt--oss--20b-6D28D9?style=for-the-badge" alt="GPT OSS 20B model" />
</p>

<p align="center">
  A Flutter chatbot application built with Dart and the Groq API, created by
  <a href="https://github.com/abhayguptadev">Abhay Gupta (@abhayguptadev)</a>.
</p>

<p align="center">
  <a href="https://github.com/abhayguptadev/ChatBot">Repository</a> •
  <a href="https://abhayguptadev.com/">Portfolio</a> •
  <a href="https://www.linkedin.com/in/abhayguptadev/">LinkedIn</a>
</p>

---

## Overview

**ChatBot** is a Flutter-based AI chat application that sends conversation messages to Groq's chat completions API and displays the assistant's response in a dark-themed chat interface.

The repository's current implementation uses the `openai/gpt-oss-20b` model identifier, the `http` Dart package, and a custom message model. You need your own Groq API key to run API requests.

## Features in the current code

- Dark chat interface with purple gradient user message bubbles.
- Separate user and assistant message styling.
- Suggested prompt chips on the empty chat screen.
- Typing indicator while a request is in progress.
- Conversation messages sent to Groq using the chat completions endpoint.
- Basic handling for HTTP/API errors and network exceptions.
- Scroll-to-latest-message behavior.

**Current limitations:** The inspected code does not implement persistent chat history, authentication, a backend proxy, or working settings/menu actions. The “Online” label is a UI label, not a verified live connection status.

## Technology Stack

- **Flutter** — app UI and cross-platform framework
- **Dart** — programming language
- **Groq API** — model inference through the chat completions endpoint
- **`http`** — HTTP requests
- **Model configured in source:** `openai/gpt-oss-20b`

## Project Structure

```text
ChatBot/
├── android/                  # Android project configuration
├── ios/                      # iOS project configuration
├── lib/
│   ├── main.dart             # Flutter app entry point
│   ├── ChatScreen.dart       # Chat UI and message flow
│   ├── ChatMsg.dart          # Chat message model
│   ├── Service.dart          # Groq API request service
│   └── api_key.dart          # Local API key file; create it yourself
├── assets/
│   └── icon/                 # App icon assets
├── pubspec.yaml              # Dependencies and Flutter configuration
└── README.md
```

`lib/api_key.dart` is intentionally not included in this repository. Create it locally as described below. Do not commit a real API key.

## Requirements

Install these tools first:

1. [Flutter SDK](https://docs.flutter.dev/get-started/install)
2. [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/)
3. Android SDK and an Android emulator, or a USB-connected Android phone with USB debugging enabled
4. A [Groq Console](https://console.groq.com/) account and API key

Verify the Flutter installation:

```bash
flutter doctor
flutter --version
```

Resolve any required Android toolchain issues reported by `flutter doctor` before running the app.

## Installation and Setup

### 1. Clone the repository

```bash
git clone https://github.com/abhayguptadev/ChatBot.git
cd ChatBot
```

Alternatively, download the repository ZIP from GitHub and extract it.

### 2. Install Flutter dependencies

Run this from the project root, where `pubspec.yaml` is located:

```bash
flutter pub get
```

### 3. Create a Groq API key

1. Open [Groq Console](https://console.groq.com/).
2. Sign in and create an API key.
3. Copy the key and keep it private.
4. Never paste the actual key into this README, a public issue, a screenshot, or a committed source file.

### 4. Create the local API key file

Create a new file at `lib/api_key.dart`:

```dart
class ApiKey {
  static const String api = 'PASTE_YOUR_GROQ_API_KEY_HERE';
}
```

Replace `PASTE_YOUR_GROQ_API_KEY_HERE` with your own key for local testing only. The class and field names must match the import in `lib/Service.dart`.

The repository's `.gitignore` already contains `lib/api_key.dart`; keep that ignore rule. Before committing, check that the file is not tracked:

```bash
git status --short
git check-ignore -v lib/api_key.dart
```

If a real key has ever been committed or shared publicly, revoke it in Groq Console and create a replacement. Removing it from the latest commit alone does not invalidate an exposed key.

> **Security warning:** A secret embedded in a Flutter app can be extracted from a built APK. This local file is a convenience for development, not secure production key storage. For a public release, route requests through a backend you control and store the Groq key in a server-side environment variable or secret manager.

### 5. Check the model and API access

The current code requests the model ID `openai/gpt-oss-20b`. Confirm in the [Groq model documentation](https://console.groq.com/docs/models) that this model is available to your account and remains supported. If it is unavailable, update `_model` in `lib/Service.dart` to a model ID supported by your Groq account.

### 6. Run the app

Start an Android emulator or connect an Android device, then run:

```bash
flutter devices
flutter run
```

If more than one device is connected, select the device ID:

```bash
flutter run -d DEVICE_ID
```

## How to Use the App

1. Launch the ChatBot app.
2. On the initial screen, choose one of the suggested prompts or tap the message input field.
3. Type a question, request, coding question, or writing prompt.
4. Tap the send button or use the send action in the keyboard, depending on the current UI.
5. Wait for the typing indicator to finish while the app sends the conversation to Groq.
6. Read the assistant's response in the chat.
7. Continue sending messages to maintain the in-memory conversation context during the current app session.

### Example prompts

- `Explain Flutter state management in simple terms.`
- `Help me debug this Dart function.`
- `Write a short professional introduction.`
- `Explain REST APIs with an example.`

The initial system instruction asks the model to act as a helpful, concise AI companion. Responses depend on the model, API availability, and the prompts you send.

## Build an Android APK

For a local test build:

```bash
flutter build apk --debug
```

For a release APK:

```bash
flutter build apk --release
```

The generated APK is typically located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Before distributing an APK, move the Groq API call to a secure backend. Do not distribute a production Flutter build that contains a private API key.

## Troubleshooting

### `Target of URI doesn't exist: 'api_key.dart'`

Create `lib/api_key.dart` using the instructions above, with the `ApiKey` class and `api` constant.

### HTTP 401 / Unauthorized

Check that the key is correct, active, and copied without extra spaces. Revoke and replace it if it was exposed.

### HTTP 403 / permission error

Check your Groq account, API access, and model permissions.

### HTTP 404 / model not found

The configured model may not be available or may have changed. Check Groq's current model list and update `_model` in `lib/Service.dart`.

### HTTP 429 / rate limit

You may have reached an API rate limit or quota. Check your Groq Console usage and limits, then retry when permitted.

### Network error

Check the device's internet connection. The Android manifest already declares the Internet permission. If testing on a physical device, confirm it has network access.

### Dependency or build errors

From the project root, try:

```bash
flutter clean
flutter pub get
flutter run
```

If the error persists, read the first relevant error in the terminal and check your Flutter/Dart version against the SDK constraints in `pubspec.yaml`.

## Security and Privacy

- Keep API keys out of Git, README files, screenshots, and public releases.
- Do not commit `lib/api_key.dart`.
- Rotate any key that was exposed.
- Use a backend proxy and server-side secret storage for a publicly distributed app.
- Do not assume chat messages are stored persistently: the inspected app keeps its conversation list in memory, and it clears when the app process/session is reset.
- Review the relevant provider's privacy and API terms before sending sensitive information.

## Contributing

Suggestions and improvements are welcome. Open an issue to describe a bug or proposed change, or submit a pull request with a clear explanation.

## Author

**Abhay Gupta** — Flutter and app development projects

- GitHub: [@abhayguptadev](https://github.com/abhayguptadev)
- Portfolio: [abhayguptadev.com](https://abhayguptadev.com/)
- LinkedIn: [Abhay Gupta](https://www.linkedin.com/in/abhayguptadev/)

---

<p align="center">
  Built with Flutter by <a href="https://github.com/abhayguptadev">Abhay Gupta (@abhayguptadev)</a>
</p>
