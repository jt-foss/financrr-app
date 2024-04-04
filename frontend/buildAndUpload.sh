flutter clean &&
flutter pub get &&

# Build & Upload iOS

flutter build ipa --obfuscate --split-debug-info=debug_info &&
xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey FCNM7TV5AK --apiIssuer 9717842e-73fe-4f11-bb0b-22eced17b1db &&
cd ios &&
cd .. || exit
