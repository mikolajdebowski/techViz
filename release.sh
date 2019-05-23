#!/usr/bin/env bash

# change Runner/Info.plist CFBundleVersion and CFBundleShortVersionString

#IOS
#IPA file will be in build/ios/Temp/Runner.ipa

flutter clean

flutter analyze

flutter test

flutter build ios

xcodebuild -workspace ios/Runner.xcworkspace \
            -scheme Runner -sdk iphoneos \
            -configuration Release archive \
            -archivePath build/ios/Temp/temp.xcarchive

xcodebuild -exportArchive \
            -archivePath build/ios/Temp/temp.xcarchive \
            -exportOptionsPlist ios/Runner/exportOptionsAdHoc.plist -exportPath build/ios/Temp/


#ANDROID
#APK file will be build/app/outputs/apk/release/app-release.apk
#export location folder can be changed at android/app/build.gradle

flutter clean

flutter analyze

flutter test

flutter build apk
