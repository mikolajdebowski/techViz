pipeline{
    agent{
        label 'macOs'
    }
    options{
        gitLabConnection 'git.internal.bis2.net'
        buildDiscarder(logRotator(numToKeepStr: '2', artifactNumToKeepStr: '10')) // discards old builds
        timeout(activity:true, time:1, unit:'HOURS') // if no build activity for 1 hour, attempt to kill the build
        disableConcurrentBuilds() // not a requirement but good to have if your builds require a lot of resources
        // if your build DOES use a lot of resources and you do not have this, you will get a discussion
    }
//    triggers{}
    stages{
        stage('Get Packages'){
            steps{
                sshagent(['4230b7aa-33c5-4a34-94ae-9fb5b004d637']) {
                    sh 'flutter packages get'
                }
            }
        }
        stage('Lint') {
            steps {
                sh 'flutter analyze'
            }
        }
        stage('Test'){
            steps {
                sh 'flutter test --coverage'
            }
        }
        stage('Setup'){
            steps{
                sh 'flutter clean'
                sh "sed -i .original 's/\${APP_VERSION}/0.8.1/g' ios/Runner/Info.plist"
                sh "sed -i .original 's/\${APP_BUILD_NUMBER}/66/g' ios/Runner/Info.plist"
            }
        }
        stage('Unlocking keychain'){
            steps {
                sh 'security unlock-keychain -p !@#$%^ ~/Library/Keychains/login.keychain'
            }
        }
        stage('Build IOS Dart Code'){
            steps {
                sh 'flutter build ios'
            }
        }
        stage('XCode Build'){
            steps{
                sh '''
             xcodebuild -workspace ios/Runner.xcworkspace \
            -scheme Runner -sdk iphoneos \
            -configuration Release archive \
            -archivePath build/ios/Temp/temp.xcarchive
            '''
            }
        }
        stage('Archiving IPA file'){
            steps{
                sh '''
            xcodebuild -exportArchive \
            -archivePath build/ios/Temp/temp.xcarchive \
            -exportOptionsPlist ios/Runner/exportOptionsAdHoc.plist \
            -exportPath build/ios/Temp/
            '''
            }
        }
        stage('Pushing to hockeyapp'){
            steps{
                sh '''
            curl \
                      -F "status=2" \
                      -F "notify=0" \
                      -F "notes=jenkins release attempt" \
                      -F "notes_type=0" \
                      -F "ipa=@/opt/benkins/workspace/Mobile/Techviz/build/ios/Temp/Runner.ipa" \
                      -H "X-HockeyAppToken: a14bddac17c24ce1b81a2791fc673272" \
                      https://rink.hockeyapp.net/api/2/apps/upload
            '''
            }
        }

//        stage('Generate Report'){
//            steps{
//                sh 'genhtml coverage/lcov.info -o coverage'
//            }
//        }
    }
}
