pipeline {
    agent any
    // tools{
    //     terraform 'terraform'
    // }
    // options { ansiColor('xterm') }
    stages {
        stage('Checkout Repo') {
            steps {
                cleanWs()
                sh 'git clone https://github.com/twuu1992/Learning-DevOps-Terraform.git'
            }
        }
        stage ('Terraform version') { 
            steps {
            sh '''
            terraform --version
            ''' 
            }
        }
        stage ('Assume AWS role') { 
            steps {
            sh '''
            echo 'Assume AWS Role'
            whoami
            key=$(aws sts assume-role --role-arn arn:aws:iam::912752405432:role/terraform-creation-role --role-session-name JenkinsSession --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" --output text)
            export AWS_ACCES_KEY_ID=$(echo $key | aws '{print $1}')
            export AWS_SECRET_ACCESS_KEY=$(echo $key | aws '{print $2}')
            export AWS_SESSION_TOKEN=$(echo $key | aws '{print $3}')
            export AWS_DEFAULT_REGION=ap-southeast-2
            export AWS_PROFILE=jenkins
            ''' 
            }
        }
                
        stage ('Terraform init') { 
            steps {
                dir("Learning-DevOps-Terraform"){
                sh '''
                terraform init
                ''' 
                }
            
            }
        }
            
        stage ('Terraform plan') { 
            steps {
                dir("Learning-DevOps-Terraform"){
                sh '''
                terraform plan
                ''' 
                }
            }
        }
            
        stage ('Terraform apply') { 
            steps {
                dir("Learning-DevOps-Terraform"){
                sh '''
                terraform apply --auto-approve
                ''' 
                }
            
            }
        }
    }
}