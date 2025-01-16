pipeline {
    agent any
	options {
		buildDiscarder(logRotator(numToKeepStr: '10'))
	}

	// parameters {
		// booleanParam(name: 'destroy', defaultValue: false, description: 'Check the box if you want destroy the project') 
        // choice(name: 'ENVIRONMENT', choices: ['demo', 'prod'], description: 'Target environment to deploy to')
	// }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        CUSTOMER           = 'CESI'
        ENV                = "${params.ENVIRONMENT}"
    }

	stages {

		stage('iac:terraform plan') {
		    // agent {
            //     docker {
            //         image 'hashicorp/terraform'
            //         reuseNode true
            //         args '-e HOME=$WORKSPACE -e NPM_CONFIG_PREFIX=$WORKSPACE/.npm-global -v /etc/pki:/etc/pki -v /etc/passwd:/etc/passwd'
            //     }
            // }
            // when {
            //     expression { params.destroy == true }
            // }
			steps {
				script {
					sh '''
                        terraform init
                        terraform plan
                    '''
				}
			}
		}

        stage('confirm:deploy') {
            when {
                expression { params.destroy == false }
            }
            steps {
                input(id: 'confirm', message: """
                    You choose to deploy:
                    - branch: ${env.GIT_BRANCH}
                    - for environment ${env.ENVIRONMENT}
                    Do you confirm the deployment
                """)
            }
        }

		stage('iac:terraform apply') {
		    // agent {
            //     docker {
            //         image 'hashicorp/terraform'
            //         reuseNode true
            //         args '-e HOME=$WORKSPACE -e NPM_CONFIG_PREFIX=$WORKSPACE/.npm-global -v /etc/pki:/etc/pki -v /etc/passwd:/etc/passwd'
            //     }
            // }
            // when {
            //     expression { params.destroy == true }
            // }
			steps {
				script {
					sh '''
                        terraform init
                        terraform apply -auto-approve
                    '''
				}
			}
		}
        // stage('confirm:destroy') {
        //     when {
        //         expression { params.destroy == true }
        //     }
        //     steps {
        //         input(id: 'confirm', message: """
        //             You choose to remove the project:
        //             - for environment ${env.ENVIRONMENT}
        //             Do you confirm the removal ?
        //         """)
        //     }
        // }

		stage('iac:destroy') {
		    // agent {
            //     docker {
            //         image 'hashicorp/terraform'
            //         reuseNode true
            //         args '-e HOME=$WORKSPACE -e NPM_CONFIG_PREFIX=$WORKSPACE/.npm-global -v /etc/pki:/etc/pki -v /etc/passwd:/etc/passwd'
            //     }
            // }
            when {
                expression { params.destroy == true }
            }
			steps {
				script {
					sh '''
                        terraform destroy -force
                    '''
				}
			}
		}
	}

    post { 
        always { 
            cleanWs()
        }
    }

}
