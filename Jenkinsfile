pipeline {
    agent any
    parameters {
        string(name: 'IMAGE_NAME')
        string(name: 'NAMESPACE')
        string(name: 'TAGS')
    }
    environment {
        GCLOUD_PROJECT = 'oval-cyclist-426414-p0'
        CLUSTER_NAME = 'cicd-cluster'
        CLUSTER_ZONE = 'europe-west1-c'
        GCLOUD_CREDS = credentials('gcloud-creds')
    }
    stages {
        stage('code checkout') {
            steps {
                git url: 'https://github.com/sainath1589/devops-automation.git', branch: 'main'
            }
        }
        stage('Authenticate to GCP') {
            steps {
                withCredentials([file(credentialsId: 'gcloud-creds', variable: 'GCLOUD_CREDS')]) {
                    sh '''
                    gcloud version
                    gcloud auth activate-service-account --key-file="$GCLOUD_CREDS"
                    gcloud config set project $GCLOUD_PROJECT
                    '''
                }
            }
        }
        stage('Validate Namespace Existence/Creation') {
            steps {
               script {
                    def exists = sh(script: "kubectl get namespace ${NAMESPACE} -o yaml", returnStatus: true) == 0
                    if (exists) {
                        echo "Namespace '${NAMESPACE}' already exists."
                    } else {
                        sh(script: "kubectl create namespace ${NAMESPACE}", returnStatus: true)
                        echo "Namespace '${NAMESPACE}' created."
                    }
                }
            }
        }
        stage('Artifact Image existance') {
            steps {
                script {
                    def imageName = "${params.IMAGE_NAME}"
                    def imageTag = "${params.TAGS}"
                    def fullImageName = "europe-west1-docker.pkg.dev/oval-cyclist-426414-p0/java-app/${IMAGE_NAME}"
                    def result = sh(returnStdout: true, script: "gcloud artifacts files list --project=oval-cyclist-426414-p0 --repository=java-app --location=europe-west1 --package=${IMAGE_NAME} --tag=${TAGS}")
                    if (result.trim() != "") {
                        echo "Image ${IMAGE_NAME}:${TAGS} exists in Artifact Registry!"
                    } else {
                        error "Image ${IMAGE_NAME}:${TAGS} does not exist in Artifact Registry. Aborting deployment."
                    }
                }
            }
        }
        stage('Deploy to k8s') {
            steps {
                sh '''
                    gcloud auth activate-service-account --key-file="$GCLOUD_CREDS"
                    gcloud config set compute/zone $CLUSTER_ZONE
                    gcloud container clusters get-credentials $CLUSTER_NAME
                    kubectl apply -f deploymentservice.yaml -n "${NAMESPACE}"
                    kubectl apply -f service.yaml -n "${NAMESPACE}"
                    kubectl apply -f ingress.yaml -n "${NAMESPACE}"
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
