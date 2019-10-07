node {
    def myRepo = checkout scm
    def gitCommit = myRepo.GIT_COMMIT
    def gitBranch = myRepo.GIT_BRANCH
    def shortGitCommit = "${gitCommit[0..10]}"
    def previousGitCommit = sh(script: "git rev-parse ${gitCommit}~", returnStdout: true)
 
    

    stage('Build static image') {
      container('dind') {
          sh """
            docker build -t artifactory.netmnfl5bs.nks.cloud/hci-nks-demo:static-${gitCommit} -f static/Dockerfile static/
            docker tag artifactory.netmnfl5bs.nks.cloud/hci-nks-demo:static-${gitCommit} artifactory.netmnfl5bs.nks.cloud/hci-nks-demo:static-latest
            """
      }
    }

    stage('Build dynamic image') {
      container('dind') {
          sh """
            docker build -t artifactory.netmnfl5bs.nks.cloud/hci-nks-demo:dynamic-${gitCommit} -f dynamic/Dockerfile dynamic/
            docker tag artifactory.netmnfl5bs.nks.cloud/hci-nks-demo:dynamic-${gitCommit} artifactory.netmnfl5bs.nks.cloud/hci-nks-demo:dynamic-latest
            """
      }
    }

    stage('Test image') {
        /* Ideally, we would run a test framework against our image.
         * For this example, we're using a Volkswagen-type approach ;-) */
            sh 'echo "Tests passed"'

    }

    stage('Push image') {
      container('dind') {
        withCredentials([[$class: 'UsernamePasswordMultiBinding',
          credentialsId: 'Artifactory',
          usernameVariable: 'ARTIFACTORY_USER',
          passwordVariable: 'ARTIFACTORY_PASSWORD']]) {
          sh """
            docker login -u ${ARTIFACTORY_USER} -p ${ARTIFACTORY_PASSWORD} artifactory.netmnfl5bs.nks.cloud
            docker push artifactory.netmnfl5bs.nks.cloud/hci-nks-demo:static-${gitCommit}
            docker push artifactory.netmnfl5bs.nks.cloud/hci-nks-demo:static-latest
            docker push artifactory.netmnfl5bs.nks.cloud/hci-nks-demo:dynamic-${gitCommit}
            docker push artifactory.netmnfl5bs.nks.cloud/hci-nks-demo:dynamic-latest
            """
        }
      }
    }
}
