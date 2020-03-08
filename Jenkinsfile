pipeline {
	agent { dockerfile true }
	stages {
		stage('fetch') {
			steps {
				script {
					if (env.JOB_NAME.endsWith("_pull-requests"))
						setGitHubPullRequestStatus state: 'PENDING', context: "${env.JOB_NAME}", message: "Fetching dependencies"
				}
				ansiColor('xterm') {
					sh '''
					DMD_VERSION=$(cat DMD_VERSION)

					if [ -e dmd ]; then
						pushd dmd
						git fetch
						git checkout -f ${DMD_VERSION}
						popd
					else
						git clone https://github.com/dlang/dmd.git --branch ${DMD_VERSION}
					fi

					pushd dmd

					git config user.name "WildBot"
					git config user.email "xwildn00bx+wildbot@gmail.com"

					git am <../*.patch

					popd
					'''
				}
			}
		}

		stage('build') {
			steps {
				script {
					if (env.JOB_NAME.endsWith("_pull-requests"))
						setGitHubPullRequestStatus state: 'PENDING', context: "${env.JOB_NAME}", message: "Building powernex-dmd"
				}
				ansiColor('xterm') {
					sh '''
					pushd dmd
					make -f powernex.mak
					mv generated/powernex/release/64/dmd ../powernex-dmd
					popd
					'''
				}
			}
		}

		stage('archive') {
			steps {
				script {
					if (env.JOB_NAME.endsWith("_pull-requests"))
						setGitHubPullRequestStatus state: 'PENDING', context: "${env.JOB_NAME}", message: "Archiving powernex-dmd"
				}
				ansiColor('xterm') {
					sh '''
					mkdir bin
					cp powernex-dmd dmd.conf bin
					tar cvfJ powernex-dmd.tar.xz bin
					'''
					archiveArtifacts artifacts: 'powernex-dmd.tar.xz', fingerprint: true
				}
			}
		}
	}

	post {
		success {
			script {
				if (env.JOB_NAME.endsWith("_pull-requests"))
					setGitHubPullRequestStatus state: 'SUCCESS', context: "${env.JOB_NAME}", message: "powernex-dmd building successed"
			}
		}
		failure {
			script {
				if (env.JOB_NAME.endsWith("_pull-requests"))
					setGitHubPullRequestStatus state: 'FAILURE', context: "${env.JOB_NAME}", message: "powernex-dmd building failed"
			}
		}
	}
}
