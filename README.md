# Jellywallet extension

You can find the latest version of Jellywallet on [our official website](https://jellywallet.io/).

Jellywallet supports Google Chrome, and Chromium-based browsers. We recommend using the latest available browser version.

## Getting Started

1. Install flutter from [official site](https://docs.flutter.dev/get-started/install):

2. At the command prompt, go to the flutter directory and change the flutter version:

        cd flutter
        git checkout 2.10.3

3. Clone this repository:

4. Go to directory with app and install dependencies:

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

## Build JS
    cd web
    npm install
    npm run build

## Test Ledger Speculos
Start the Virtual Machine (TODO: Make a public virtual machine!)
Run Speculos using this command
   
   SPECULOS_APPNAME=DeFiChain:2.3.1 ./speculos.py ~/ledger-app-builder/app-bitcoin-new/bin/app.elf --apdu-port 9999  -s "SEED_PHRASE" 

Change the adapter in the ledger-base.ts to use the SpeculosTransport by uncommenting the code and change the ip address.
Rebuild, and reload the app. 

## License & Disclaimer

By using `Jellywallet extension` (this repo), you (the user) agree to be bound by [the terms of this license](LICENSE).
