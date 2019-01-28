pipelineJob('pipeline-safe_client_libs') {
    parameters {
        stringParam('IMAGE_NAME', 'maidsafe/safe-client-libs-build')
        stringParam('IMAGE_TAG', '0.9.0')
        stringParam('REPO_URL', 'https://github.com/jacderida/safe_client_libs.git')
        stringParam('MOUNT_POINT', '/usr/src/safe_client_libs')
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
                    branches('docker_build')
                    scriptPath('scripts/Jenkinsfile')
                    extensions { }
                }
            }
        }
    }
}

freeStyleJob('windows-shell-test') {
    steps {
        shell('env')
    }
}
