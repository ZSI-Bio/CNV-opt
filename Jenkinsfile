pipeline {
    agent any
       stages {

        /*stage('Test R code') {
                    steps {
                        echo 'Testing R code....'
                        sh 'docker run -i --rm --network="host" -e CNV_OPT_PSQL_USER="cnv-opt" -e CNV_OPT_PSQL_PASSWORD="zsibio321" -e CNV_OPT_PSQL_DRV_URL="http://zsibio.ii.pw.edu.pl/nexus/repository/zsi-bio-raw/common/jdbc/postgresql-42.1.1.jar" -e CNV_OPT_PSQL_CONN_URL="jdbc:postgresql://cdh00.ii.pw.edu.pl:15432/cnv-opt" -w="/tmp" -v $(pwd | sed "s|/var/jenkins_home|/data/home/jenkins|g")/R:/tmp zsibio.ii.pw.edu.pl:50009/zsi-bio-toolset Rscript tests/run_tests.R'
                    }
                    post {
                      always {
                        junit '**R/tests/*.xml'
                      }
                    }
         }*/

         stage('Build R package') {
                             steps {
                                 echo 'Building R package....'
                                 sh "cd R && R CMD build TARGET.QC/ && curl -v --user ${NEXUS_USER}:${NEXUS_PASS} --upload-file TARGET.QC_0.0.1.tar.gz http://zsibio.ii.pw.edu.pl/nexus/repository/r-zsibio/src/contrib/TARGET.QC_0.0.1.tar.gz"
                                 sh "cd R && R CMD build REFERENCE.SAMPLE.SET.SELECTOR/ && curl -v --user ${NEXUS_USER}:${NEXUS_PASS} --upload-file REFERENCE.SAMPLE.SET.SELECTOR_0.0.1.tar.gz http://zsibio.ii.pw.edu.pl/nexus/repository/r-zsibio/src/contrib/REFERENCE.SAMPLE.SET.SELECTOR_0.0.1.tar.gz"
                                 sh "cd R && R CMD build CODEXCOV/ && curl -v --user ${NEXUS_USER}:${NEXUS_PASS} --upload-file CODEXCOV_0.0.1.tar.gz http://zsibio.ii.pw.edu.pl/nexus/repository/r-zsibio/src/contrib/CODEXCOV_0.0.1.tar.gz"
                                 sh "cd R && R CMD build EXOMEDEPTHCOV/ && curl -v --user ${NEXUS_USER}:${NEXUS_PASS} --upload-file EXOMEDEPTHCOV_0.0.1.tar.gz http://zsibio.ii.pw.edu.pl/nexus/repository/r-zsibio/src/contrib/EXOMEDEPTHCOV_0.0.1.tar.gz"
                                 sh "cd R && R CMD build CANOESCOV/ && curl -v --user ${NEXUS_USER}:${NEXUS_PASS} --upload-file CANOESCOV_0.0.1.tar.gz http://zsibio.ii.pw.edu.pl/nexus/repository/r-zsibio/src/contrib/CANOESCOV_0.0.1.tar.gz"
                                 sh "cd R && R CMD build CANOES/ && curl -v --user ${NEXUS_USER}:${NEXUS_PASS} --upload-file CANOES_0.0.1.tar.gz http://zsibio.ii.pw.edu.pl/nexus/repository/r-zsibio/src/contrib/CANOES_0.0.1.tar.gz"
                                 sh "cd R && R CMD build CNVCALLER.RUNNER/ && curl -v --user ${NEXUS_USER}:${NEXUS_PASS} --upload-file CNVCALLER.RUNNER_0.0.1.tar.gz http://zsibio.ii.pw.edu.pl/nexus/repository/r-zsibio/src/contrib/CNVCALLER.RUNNER_0.0.1.tar.gz"
                                 sh "cd R && R CMD build CNVCALLER.EVALUATOR/ && curl -v --user ${NEXUS_USER}:${NEXUS_PASS} --upload-file CNVCALLER.EVALUATOR_0.0.1.tar.gz http://zsibio.ii.pw.edu.pl/nexus/repository/r-zsibio/src/contrib/CNVCALLER.EVALUATOR_0.0.1.tar.gz"
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

        stage('Build Docker images') {
                    steps {
                        echo 'Building Docker images....'
                        sh './build.sh'
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
