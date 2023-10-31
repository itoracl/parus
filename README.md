# # ПАРУС в Облаках

ПАРУС ERP достаточно давно использует привычные продукты, имеющие официальные докер образы: redis, kafka, apache httpd. 
Осталось только построить образы с серверными компонентами самой ERP и написать yaml манифесты kubernetes.
В настоящее время приходится запускать минимум с десяток инсталляторов, кроме вышеперечисленных: jdk, aspnet разных версий одновременно, еще zookeeper используется.
Потом полсотни конфигов отредактировать, так что попробуем упростить эту работу: kubernetes будет оркестрировать, все продукты будут запускаться в контейнерах.
(Раскатка кластера и запуск СУБД Oracle в частном облаке были рассмотрены мной в предыдущих статьях).

Так как ERP Парус 8 имеет более 200 версий, для интеграции и поставки докер образов с нужными компонентами используется достаточно лаконичный пайплайн jenkins:

pipeline { 
  agent {
    kubernetes {
      cloud 'local'
      inheritFrom 'podman'
    }
  }
  stages {
      stage('Parus Web Extra Build') {
       steps {
         container ('podman') {
           script {
             sh "podman build -t parusweb2:8.561.${BUILD_NUMBER} dockerfiles/web2/. && \
                 podman push --creds=jenkins:jenkins --tls-verify=false parusweb2:8.561.${BUILD_NUMBER} \
                  nexus-nexus-repository-manager-docker-5000.nexus:5000/parusweb2:8.561.${BUILD_NUMBER}"

           }
         }
       }
      }
      stage("Parus Web Extra Deployment") {
        agent any
        steps {
          kubeconfig(credentialsId: '8ea73d9c-ecc0-42cf-a7a0-76e3a1526fc2', serverUrl: '', caCertificate: '') {
            sh "kubectl apply -f samples/kubernetes/embwebproxy.yaml"
          }
        }
      }
  }
}

Серверные компоненты ПАРУС ERP поставляются вместе с каждым релизом, сейчас сгенерирован образ под релиз 08.2023.


Parus Web 2 docker images
