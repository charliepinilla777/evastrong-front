#!/bin/bash
curl
https://storage.googleapis.com/flutter_infra_release/releases/
stable/windows/flutter_windows_3.35.1-stable.zip -o
flutter.zip
unzip -q flutter.zip
export PATH="$PATH:$(pwd)/flutter/bin"
flutter pub get
flutter build web --release
