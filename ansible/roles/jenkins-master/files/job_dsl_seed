pipelineJob('pipeline-safe_client_libs') {
  triggers {
    scm('H/5 * * * *')
  }

  description("Pipeline for Safe Client Libs")

  definition {
    cpsScm {
      scm {
        git {
          remote { url('https://github.com/jacderida/safe-build-infrastructure.git') }
          branches('safe_core_build')
          scriptPath('jenkins/pipeline-safe_client_libs/Jenkinsfile')
          extensions { }
        }
      }
    }
  }
}
