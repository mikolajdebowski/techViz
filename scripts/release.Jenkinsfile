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
    stages{
        stage('Get Packages'){
            steps{
                sshagent(['4230b7aa-33c5-4a34-94ae-9fb5b004d637']) {
                    sh 'flutter packages get'
                }
            }
        }
        stage('Analyze/Lint') {
            steps {
                sh 'flutter analyze'
            }
        }
        stage('Tests'){
            steps {
                sh 'flutter test --coverage'
            }
        }
        stage('Version'){
            steps{
                script {
                    def build = readJSON file: './config/buildInfo.json'
                    build.buildNumber = currentBuild.number
                    env.VERSION = "${build.version}"
                    env.ARTEFACT_NAME_IOS = "build/ios/Temp/TechViz_v${VERSION}_${BUILD_NUMBER}.ipa"
                    env.ARTEFACT_NAME_ANDROID = "build/app/outputs/apk/release/TechViz_v${VERSION}_${BUILD_NUMBER}.apk"
                }
            }
        }
        stage('Parallel builds'){
            parallel {
                stage("iOS"){
                    stages{
                        stage('Version'){
                            steps{
                                sh "sed -i .original 's/\${APP_VERSION}/${VERSION}/g' ios/Runner/Info.plist"
                                sh "sed -i .original 's/\${APP_BUILD_NUMBER}/${BUILD_NUMBER}/g' ios/Runner/Info.plist"
                            }
                        }
                        stage('Unlocking keychain'){
                            steps {
                                sh 'security unlock-keychain -p !@#$%^ ~/Library/Keychains/login.keychain'
                            }
                        }
                        stage('Build IOS - Dart'){
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
                            sh 'mv build/ios/Temp/Runner.ipa ${ARTEFACT_NAME_IOS}'
                            }
                        }
                        stage('Push .IPA to HockeyApp'){
                            steps{
                                sh '''
                            curl \
                                      -F "status=2" \
                                      -F "notify=0" \
                                      -F "notes_type=0" \
                                      -F "ipa=@${ARTEFACT_NAME_IOS}" \
                                      -H "X-HockeyAppToken: a14bddac17c24ce1b81a2791fc673272" \
                                      https://rink.hockeyapp.net/api/2/apps/upload
                            '''
                            }
                        }

                    }
                }
                 stage("Android"){
                    stages{
                        stage('Setup Android Version'){
                            steps{
                                sh "sed -i .original 's/rootProject.appVersionName/\"1.0.0\"/g' android/app/build.gradle"
                                sh "sed -i .original 's/rootProject.appVersionCode.toInteger()/${BUILD_NUMBER}/g' android/app/build.gradle"
                            }
                        }
                        stage('Build Android - Dart'){
                            steps {
                                sh 'flutter build apk'
                                sh 'mv build/app/outputs/apk/release/app-release.apk ${ARTEFACT_NAME_ANDROID}'
                            }
                        }
                        stage('Push .APK to HockeyApp'){
                            steps{
                                sh '''
                                    curl \
                                        -F "status=2" \
                                        -F "notify=0" \
                                        -F "notes_type=0" \
                                        -F "ipa=@${ARTEFACT_NAME_ANDROID}" \
                                        -H "X-HockeyAppToken: a14bddac17c24ce1b81a2791fc673272" \
                                        https://rink.hockeyapp.net/api/2/apps/upload
                                    '''
                            }
                        }
                    }
                 }
                 stage("Coverage report"){
                    steps {
                        sh 'genhtml coverage/lcov.info -o coverage'
                    }
                 }
            }
        }

    }
    post{
        success{
            archiveArtifacts ARTEFACT_NAME_IOS
            archiveArtifacts ARTEFACT_NAME_ANDROID
            publishHTML (target: [
                allowMissing: false,
                alwaysLinkToLastBuild: false,
                keepAll: true,
                reportDir: 'coverage',
                reportFiles: 'index.html',
                reportName: "Coverage"
            ])
        }
        cleanup{
            cleanWs()
        }
    }
}
