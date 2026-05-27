# railm (Railway Mobile App)

smart railway tracking and database management mobile app.

## Dependencies
- flutter v3.41.9
- android emulator v36 (tested on)

## Build
```bash
# run the railapi server first
# then start the emulator
emulator -avd # android
open -a Simulator # iOS

# check if flutter detected the virtual device
flutter devices

# then run with
flutter run --dart-define=TOKEN=<token> --dart-define=URL="https://railm-railapi.vercel.app"
# or
flutter run --dart-define=TOKEN=<token> --dart-define=URL="https://railm-railapi.vercel.app" -d <device>

# Build
flutter build apk --release --dart-define=TOKEN=<token> --dart-define=URL="https://railm-railapi.vercel.app"
```

## Install
Download the prebuilt apk from the **Release** and install it.

## Tested On
- Pixel 9A (emulator)
- iPhone 16e (simulator)
