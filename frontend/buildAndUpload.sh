flutter clean &&
flutter pub get &&

# Build & Upload iOS

flutter build ipa --obfuscate --split-debug-info=debug_info &&
xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey M8Z6SQRJSH --apiIssuer bbb652dd-4490-4912-b117-423cae11d325 &&
cd ios &&
cd .. || exit
