pipeline {
    agent any
       stages {
        stage('Test Scala code') {
            steps {
                echo 'Testing Scala code....'
                sh "${tool name: 'sbt-0.13.15', type: 'org.jvnet.hudson.plugins.SbtPluginBuilder$SbtInstallation'}/bin/sbt test"
            }
            post {
              always {
                junit '**/target/test-reports/*.xml'
              }
            }
        }

        stage('Test shell code') {
                    steps {
                        echo 'Testing shell code....'
                        sh "bin/test/test_CODEX.sh"
                    }
                    post {
                      always {
                        junit '**bin/test/results/*.xml'
                      }
                    }
         }
        stage('Test R code') {
                    steps {
                        echo 'Testing R code....'
                        sh "cd R/tests && Rscript run_tests.R"
                    }
                    post {
                      always {
                        junit '**R/tests/*.xml'
                      }
                    }
         }

        stage('Assembly scala code') {
                    steps {
                        echo 'Building Scala code....'
                        sh "${tool name: 'sbt-0.13.15', type: 'org.jvnet.hudson.plugins.SbtPluginBuilder$SbtInstallation'}/bin/sbt assembly"

                    }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}
