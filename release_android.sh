#!/usr/bin/env bash

# to change version at android/app/build.gradle first

##ANDROID
##APK file will be build/app/outputs/apk/release/app-release.apk
##export location folder can be changed at android/app/build.gradle

echo Performing clean
flutter clean

#flutter analyze
#flutter test

echo Building IOS Dart Code and exporting APK
flutter build apk

echo Pushing to HockeyApp
curl \
  -F "status=2" \
  -F "notify=0" \
  -F "notes=testing" \
  -F "notes_type=0" \
  -F "ipa=@build/app/outputs/apk/release/app-release.apk" \
  -H "X-HockeyAppToken: a14bddac17c24ce1b81a2791fc673272" \
  https://rink.hockeyapp.net/api/2/apps/upload

US:
ACT-1344 - (Open) Tasks Summary
ACT-1398 - Make reservation

Tasks:
ACT-1421 - Count of Overdue open tasks are not colored red
ACT-1422 - Count of Out of Service machines are not colored red
ACT-1424 - It is possible to reserve a machine that is IN USE on Active Games tab
ACT-1411 - [Improvement] "User" column does not make sense on Unassigned metric for Open Tasks because it would be always blank