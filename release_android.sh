#!/usr/bin/env bash

# to change version at android/app/build.gradle first

##ANDROID
##APK file will be build/app/outputs/apk/release/app-release.apk
##export location folder can be changed at android/app/build.gradle

flutter clean

flutter analyze

flutter test

flutter build apk

curl \
  -F "status=2" \
  -F "notify=0" \
  -F "notes=testing" \
  -F "notes_type=0" \
  -F "apk=@build/app/outputs/apk/release/app-release.apk" \
  -H "X-HockeyAppToken: a14bddac17c24ce1b81a2791fc673272" \
  https://rink.hockeyapp.net/api/2/apps/upload

