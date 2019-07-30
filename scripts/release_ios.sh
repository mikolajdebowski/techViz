#!/usr/bin/env bash

##IOS
##IPA file will be in build/ios/Temp/Runner.ipa
##to change Runner/Info.plist first

#echo Performing clean
#flutter clean

#echo Performing packages get
#flutter packages get
#flutter analyze
#flutter test

echo Building IOS Dart Code
flutter build ios

echo Performing XCODE Build
rm -rf build/ios/Temp

xcodebuild -workspace ios/Runner.xcworkspace \
            -scheme Runner -sdk iphoneos \
            -configuration Release archive \
            -archivePath build/ios/Temp/temp.xcarchive

echo Archiving IPA file
xcodebuild -exportArchive \
            -archivePath build/ios/Temp/temp.xcarchive \
            -exportOptionsPlist ios/Runner/exportOptionsAdHoc.plist -exportPath build/ios/Temp/

echo Pushing to HockeyApp
curl \
  -F "status=2" \
  -F "notify=0" \
  -F "notes=jenkins release attempt" \
  -F "notes_type=0" \
  -F "ipa=@/opt/benkins/workspace/Mobile/Techviz/build/ios/Temp/Runner.ipa" \
  -H "X-HockeyAppToken: a14bddac17c24ce1b81a2791fc673272" \
  https://rink.hockeyapp.net/api/2/apps/upload
