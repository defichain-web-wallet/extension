# Jellywallet extension

You can find the latest version of Jellywallet on [our official website](https://jellywallet.io/).

Jellywallet supports Google Chrome, and Chromium-based browsers. We recommend using the latest available browser version.

## Getting Started

1. Install flutter from [official site](https://docs.flutter.dev/get-started/install):

2. Clone this repository:

3. Go to directory with app and install dependencies:

        flutter pub get

## Build
Make build for upload to chrome extensions

    flutter build web --csp --web-renderer html  --no-sound-null-safety

## Deploy
1. In Chrome, open chrome://extensions/
2. Click + Developer mode
3. Click Load unpacked extension…
4. Navigate to the extension’s folder `/build/web` and click OK

Where `/build/web` is directory with ready extension

## Debug
    flutter run -d chrome --no-sound-null-safety

## License & Disclaimer

By using `Jellywallet extension` (this repo), you (the user) agree to be bound by [the terms of this license](LICENSE).
