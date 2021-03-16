def appname = "Runner" //DON'T CHANGE THIS. This refers to the flutter 'Runner' target.
def xcarchive = "${appname}.xcarchive"

pipeline {
    agent any //Change this to whatever your flutter jenkins nodes are labeled. Any is ok
    environment {
        DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer/"  //This is necessary for Fastlane to access iOS Build things.
        PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/aplanetbit/Development/flutter/bin:/System/Volumes/Data/Users/aplanetbit/Library/Android/sdk/platform-tools/:/Users/aplanetbit/Development/flutter/.pub-cache/bin:/Users/aplanetbit/Development/flutter/bin/cache/dart-sdk/bin/:/Users/aplanetbit/Development/sonar-scanner-4.5.0.2216-macosx/bin/:/Library/Apple/usr/bin"
    }
    stages {
            stage ('Checkout') {
                steps {
                    step([$class: 'WsCleanup'])
                    checkout scm
                    sh "rm -rf brbuild_ios" //This removes the previous checkout of brbuild_ios if it exists.
                    sh "rm -rf ios/fastlane/brbuild_ios" //This removes the brbuild_ios from the fastlane directory if it somehow still exists
                    sh "git clone https://github.com/pedrosc1967/diccionario_panocho.git"
                    sh "cp /Users/aplanetbit/StudioProjects/diccionario_panocho/android/key.properties /Users/aplanetbit/.jenkins/workspace/Diccionario_Panocho/diccionario_panocho/android/key.properties"

                }
            }

            stage ('Flutter Build APK') {
                steps {
                    sh "flutter build apk"
                    sh "cp /Users/aplanetbit/.jenkins/workspace/Diccionario_Panocho/build/app/outputs/flutter-apk/app-release.apk /Users/aplanetbit/Downloads/app-release.apk"
                    sh "cd /Users/aplanetbit/Downloads"
                    sh "/Users/aplanetbit/resignapk.sh"
                }
            }

            stage ('Flutter Build iOS') {
                 steps {
                     sh "flutter build ios --release --no-codesign"
                 }
            }
            stage ('Make iOS IPA ') {
                 steps {
                      dir('ios'){
                               sh "bundle install"
                               sh "bundle exec fastlane buildAdHoc --verbose"
                               sh "cp /Users/aplanetbit/.jenkins/workspace/Diccionario_Panocho/ios/Runner.ipa /Users/aplanetbit/Downloads/Runner.ipa"
                      }
                 }
            }
            stage ('Notify Result') {
                 steps {
                      notifyEvents  token: 'XCGa5nO7EOw-1u_vuJG5E_cLh17wieAF' , message: '<b>$BUILD_ID</b> - Built successfully'
                      }
           }
      }
}
