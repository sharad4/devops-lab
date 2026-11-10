// Multibranch pipeline. Mirrors GitHub Actions CI so you can compare both tools.
pipeline {
  agent any

  options {
    timestamps()
    timeout(time: 40, unit: 'MINUTES')
    buildDiscarder(logRotator(numToKeepStr: '20'))
    disableConcurrentBuilds(abortPrevious: true)
  }

  environment {
    REGISTRY    = 'ghcr.io'
    IMAGE_OWNER = "${env.GHCR_OWNER ?: 'sharad4'}"   // set GHCR_OWNER in Manage Jenkins > System > Global properties
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        script { env.SHORT_SHA = sh(returnStdout: true, script: 'git rev-parse --short=7 HEAD').trim() }
        sh 'git log -1 --oneline'
      }
    }

    stage('Test') {
      parallel {
        stage('Backend') {
          agent { docker { image 'composer:2'; args '-u root'; reuseNode true } }
          environment { DB_CONNECTION = 'sqlite'; DB_DATABASE = ':memory:' }
          steps {
            dir('backend') {
              sh 'composer install --prefer-dist --no-progress --no-interaction'
              sh 'cp -n .env.example .env && php artisan key:generate'
              sh './vendor/bin/pint --test'
              sh 'php artisan test --log-junit=../backend-junit.xml'
            }
          }
          post { always { junit allowEmptyResults: true, testResults: 'backend-junit.xml' } }
        }
        stage('Frontend') {
          agent { docker { image 'node:20-alpine'; reuseNode true } }
          steps {
            dir('frontend') {
              sh 'npm ci'
              sh 'npm run lint'
              sh 'npm test'
              sh 'npm run build'
            }
          }
        }
      }
    }

    stage('Build & Push Images') {
      when { anyOf { branch 'main'; buildingTag() } }
      steps {
        withCredentials([usernamePassword(credentialsId: 'ghcr-creds', usernameVariable: 'U', passwordVariable: 'P')]) {
          sh '''
            echo "$P" | docker login $REGISTRY -u "$U" --password-stdin
            for svc in backend frontend; do
              IMG=$REGISTRY/$(echo $IMAGE_OWNER | tr A-Z a-z)/devops-lab-$svc
              docker build -f docker/$svc.Dockerfile --build-arg APP_VERSION=$SHORT_SHA -t $IMG:$SHORT_SHA -t $IMG:latest .
              docker push $IMG:$SHORT_SHA
              docker push $IMG:latest
            done
          '''
        }
      }
      post { always { sh 'docker logout $REGISTRY || true' } }
    }

    stage('Deploy Staging') {
      when { branch 'main' }
      steps {
        sshagent(credentials: ['deploy-ssh']) {
          withCredentials([string(credentialsId: 'deploy-host', variable: 'HOST'),
                           string(credentialsId: 'deploy-user', variable: 'DUSER')]) {
            sh '''
              scp -o StrictHostKeyChecking=accept-new docker-compose.prod.yml scripts/deploy.sh $DUSER@$HOST:/opt/devops-lab/
              ssh -o StrictHostKeyChecking=accept-new $DUSER@$HOST "cd /opt/devops-lab && chmod +x deploy.sh && ./deploy.sh $SHORT_SHA"
            '''
          }
        }
      }
    }

    stage('Approve Production') {
      when { branch 'main' }
      steps {
        timeout(time: 1, unit: 'HOURS') {
          input message: "Deploy ${env.SHORT_SHA} to PRODUCTION?", ok: 'Deploy', submitter: 'admin'
        }
      }
    }

    stage('Deploy Production') {
      when { branch 'main' }
      steps {
        sshagent(credentials: ['deploy-ssh-prod']) {
          withCredentials([string(credentialsId: 'deploy-host-prod', variable: 'HOST'),
                           string(credentialsId: 'deploy-user', variable: 'DUSER')]) {
            sh '''
              scp -o StrictHostKeyChecking=accept-new docker-compose.prod.yml scripts/deploy.sh $DUSER@$HOST:/opt/devops-lab/
              ssh -o StrictHostKeyChecking=accept-new $DUSER@$HOST "cd /opt/devops-lab && chmod +x deploy.sh && ./deploy.sh $SHORT_SHA"
            '''
          }
        }
      }
    }
  }

  post {
    success { echo "Build OK: ${env.BRANCH_NAME} @ ${env.SHORT_SHA}" }
    failure { echo "Build FAILED - check console output; see docs/05-troubleshooting.md" }
    cleanup { cleanWs() }
  }
}
