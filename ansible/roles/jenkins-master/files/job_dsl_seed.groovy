pipelineJob('pipeline-safe_client_libs') {
    parameters {
        stringParam('BRANCH', 'scl_windows_jenkins_build')
        stringParam('IMAGE_NAME', 'maidsafe/safe-client-libs-build')
        stringParam('IMAGE_TAG', '0.9.0')
        stringParam('REPO_URL', 'https://github.com/jacderida/safe_client_libs.git')
        stringParam('MOUNT_POINT', '/usr/src/safe_client_libs')
        stringParam('ARTIFACTS_BUCKET', 'safe-client-libs-jenkins')
        stringParam('DEPLOY_BUCKET', 'safe-client-libs')
    }
    triggers {
        scm('H/5 * * * *')
    }

    description("Pipeline for Safe Client Libs")

    definition {
        cpsScm {
            scm {
                git {
                    remote { url('https://github.com/jacderida/safe_client_libs.git') }
                    branches('scl_windows_jenkins_build')
                    scriptPath('scripts/Jenkinsfile')
                    extensions { }
                }
            }
        }
    }
}
