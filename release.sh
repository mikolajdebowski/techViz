#!/usr/bin/env bash

# change Runner/Info.plist CFBundleVersion and CFBundleShortVersionString
version = "v07b46"

flutter clean

flutter analyze

flutter test

flutter build ios

xcodebuild -workspace ios/Runner.xcworkspace \
            -scheme Runner -sdk iphoneos \
            -configuration Release archive \
            -archivePath ios/Temp/Build/v08b49.xcarchive

xcodebuild -exportArchive \
            -archivePath ios/Temp/Build/v08b49.xcarchive \
            -exportOptionsPlist ios/Runner/exportOptionsAdHoc.plist -exportPath ios/Temp/Build/v08b49

