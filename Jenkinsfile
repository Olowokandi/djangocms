node {
    parameters {
        string(defaultValue: 'arsenal', description: '', name: 'project_endpoint')
    }
    stage 'Check out'
    echo 'Checking out...'
    checkout scm
    docker.withRegistry("${env.REGISTRY_PROTOCOL}://${env.REGISTRY_HOST}:${env.REGISTRY_PORT}", 'docker_registry_credentials_id') {
        stage 'Build Docker Image'
        echo 'Building docker image....'
        String imageName = "${env.REGISTRY_HOST}:${env.REGISTRY_PORT}/djangocms:latest"
        sh "docker build --build-arg PROJECT_NAME=mywebsite -t ${imageName}  ."
        def img = docker.image(imageName)
        stage 'Push Docker Image'
        echo 'Pushing docker image....'
        img.push()
    }
    stage 'Deploy to Kubernetes'
        echo 'Deploying....'
        dir('helm') {
        sh "helm dependency update"
        }
        sh "helm upgrade --install  djangocms ./helm --set image.repository=${env.REGISTRY_HOST}:${env.REGISTRY_PORT}/djangocms"
        sh "helm history djangocms"
}