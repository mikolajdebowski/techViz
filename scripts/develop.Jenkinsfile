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
                sh 'genhtml coverage/lcov.info -o coverage'
            }
        }
    }
    post{
        success{
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
