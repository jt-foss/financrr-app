#!/bin/bash

# Check if exactly one argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <major|minor|patch|none>"
    exit 1
fi

# Store the argument in a variable
version_type=$1

# Check if the version type is valid
if [[ ! "$version_type" =~ ^(major|minor|patch|build)$ ]]; then
    echo "Invalid version type. Please specify either: major, minor, patch, or build."
    exit 1
fi

# Increment version on separate branch
git branch frontend/release/next &&
git checkout frontend/release/next &&

flutter pub run pub_increment --type "$version_type"  &&
git commit -a -m "publish: ${version_type/none/build}" &&
git push --set-upstream origin frontend/release/next &&

# Clean & Get Dependencies
flutter clean &&
flutter pub get &&

# Build & Upload iOS
flutter build ipa --obfuscate --split-debug-info=debug_info &&
xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey FCNM7TV5AK --apiIssuer 9717842e-73fe-4f11-bb0b-22eced17b1db &&
cd ios &&
cd .. || exit
