pipeline {
    agent any
    parameters {
        string(name: 'IMAGE_NAME')
        string(name: 'TAGS')
    }
    environment {
        GCLOUD_PROJECT = 'cranjana'
        CLUSTER_NAME = 'cicd-cluster'
        CLUSTER_ZONE = 'us-central1-c'
        GCLOUD_CREDS = credentials('cdjenkinskey')
        
    }
    stages {
        stage('code checkout') {
            steps {
                git url: 'https://github.com/sainath1589/devops-automation.git', branch: 'main'
            }
        }
        stage('Authenticate to GCP') {
          steps {
                withCredentials([file(credentialsId: 'cdjenkinskey', variable: 'GCLOUD_KEYFILE_JSON')]) {
                    echo 'Authenticating with Google Cloud using service account key...'
                    sh '''
                        gcloud version
                        gcloud auth activate-service-account --key-file="$GCLOUD_KEYFILE_JSON"
                    '''
                }
            }
        }
        stage('Artifact Image existance') {
            steps {
                script {
                    def imageName = "${params.IMAGE_NAME}"
                    def imageTag = "${params.TAGS}"
                    def fullImageName = "us-central1-docker.pkg.dev/cranjana/java-app/${IMAGE_NAME}"
                    def result = sh(returnStdout: true, script: "gcloud artifacts files list --project=cranjana --repository=java-app --location=us-central1 --package=${IMAGE_NAME} --tag=${TAGS}")
                    if (result.trim() != "") {
                        echo "Image ${IMAGE_NAME}:${TAGS} exists in Artifact Registry!"
                    } else {
                        error "Image ${IMAGE_NAME}:${TAGS} does not exist in Artifact Registry. Aborting deployment."
                    }
                }
            }
        }
        stage('Deploy on Google Kubernetes Engine') {
            steps {
                sh '''
                    gcloud auth activate-service-account --key-file="$GCLOUD_CREDS"
                    gcloud config set compute/zone $CLUSTER_ZONE
                    gcloud container clusters get-credentials $CLUSTER_NAME
                    kubectl apply -f deploymentservice.yaml
                    kubectl apply -f service.yaml 
                    kubectl apply -f ingress.yaml 
                '''
            }
        }
    }
    post {
        success {
            echo 'Pipeline succeeded!'
            mail to: 'sainathreddy250@gmail.com',
                 subject: "Pipeline Succeeded: ${currentBuild.fullDisplayName}",
                 body: "The pipeline ${env.BUILD_URL} has successfully completed."
        }
        failure {
            echo 'Pipeline failed!'
            mail to: 'sainathreddy250@gmail.com',
                 subject: "Pipeline Failed: ${currentBuild.fullDisplayName}",
                 body: "The pipeline ${env.BUILD_URL} has failed. Check the logs for details."
        }
    }
}
