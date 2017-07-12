pipeline {
    agent any
       stages {

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

         stage('Build R package') {
                             steps {
                                 echo 'Building R package....'
                                 sh "cd R && R CMD build CODEXCOV/ && curl -v --user ${NEXUS_USER}:${NEXUS_PASS} --upload-file CODEXCOV_0.0.1.tar.gz http://zsibio.ii.pw.edu.pl:50007/repository/r-zsibio/src/contrib/CODEXCOV_0.0.1.tar.gz"
                             }

                  }

        stage('Test Scala code') {
                    steps {
                        slackSend botUser: true, channel: '#development', message: 'started ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)', teamDomain: 'zsibio.slack.com'
                        echo 'Testing Scala code....'
                        sh "${tool name: 'sbt-0.13.15', type: 'org.jvnet.hudson.plugins.SbtPluginBuilder$SbtInstallation'}/bin/sbt test"
                    }
                    post {
                      always {
                        junit '**/target/test-reports/*.xml'
                      }
                    }
                }

         stage('Package scala code') {
                            steps {
                                echo 'Building Scala code....'
                                sh "${tool name: 'sbt-0.13.15', type: 'org.jvnet.hudson.plugins.SbtPluginBuilder$SbtInstallation'}/bin/sbt package"
        			            echo "Generating documentation"
        			            sh "${tool name: 'sbt-0.13.15', type: 'org.jvnet.hudson.plugins.SbtPluginBuilder$SbtInstallation'}/bin/sbt doc"
        			            publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: false, reportDir: 'target/scala-2.11/api/', reportFiles: 'package.html', reportName: 'Scala Doc', reportTitles: ''])

                            }

                }
         stage('Publish to Nexus snapshots and copying assembly fat jar to the edge server') {
                   when {
                         branch 'master'
                        }
                    steps {
                            echo "branch: ${env.BRANCH_NAME}"
                            echo 'Publishing to ZSI-BIO snapshots repository....'
                            sh "${tool name: 'sbt-0.13.15', type: 'org.jvnet.hudson.plugins.SbtPluginBuilder$SbtInstallation'}/bin/sbt publish"

                            echo "Copying assembly to the edge server cdh00:/data/local/projects/jars folder"
                            sh "${tool name: 'sbt-0.13.15', type: 'org.jvnet.hudson.plugins.SbtPluginBuilder$SbtInstallation'}/bin/sbt assembly"
                            sh "find target/ -name *assembly*.jar | xargs -i scp {} zsibio-jenkins@cdh00:/data/local/projects/jars"

                             echo "Triggering zsi-bio-docker-image build proceses"
                             build job: 'ZSI-Bio/zsi-bio-docker-image/master', wait: false
                    }
                }
    }
}
