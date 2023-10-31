### ПАРУС в Облаках

ПАРУС ERP достаточно давно использует привычные продукты, имеющие официальные докер образы: redis, kafka, apache httpd. 
Осталось только построить образы с серверными компонентами самой ERP и написать yaml манифесты kubernetes.
В настоящее время приходится запускать минимум с десяток инсталляторов, кроме вышеперечисленных: jdk, aspnet разных версий одновременно, еще zookeeper используется.
Потом полсотни конфигов отредактировать, так что попробуем упростить эту работу: kubernetes будет оркестрировать, все продукты будут запускаться в контейнерах.
(Раскатка кластера и запуск СУБД Oracle в частном облаке были рассмотрены мной в предыдущих статьях).

Так как ERP Парус 8 имеет более 200 версий, для интеграции и поставки докер образов с нужными компонентами используется достаточно лаконичный пайплайн jenkins:

```
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
```

Для сборки в пайплайне указано частное облако, настройте свой jenkins в разделе "clouds". В podtemplates облака укажите метку контейнера для запуска podman.
В шаге пайплайна для деплоймента подразумевается наличие утилиты kubectl на агенте, в моем случае данная утилита установлена на контроллере jenkins. В целевом облаке, куда осуществляется деплоймент, должен быть пользователь, у которого в соответствии с RBAC политикой кластера есть достаточные права. Файл конфигурации такого пользователя загрузите в jenkins secrets и полученный credentialsId поместите в пайплайн в параметры плагина kubeconfig.

Для хранилища артефактов и реестра образов тут используется nexus, укажите свой сервер.

Серверные компоненты ПАРУС ERP поставляются вместе с каждым релизом, сейчас мной сгенерирован образ под релиз 08.2023.

Готовые консервы также выложил в репозиторий на quay:
```
docker pull quay.io/itoracle/parusweb2:8.561.42
```
# Тестирование

Если имеются готовые рабочие файлы конфигурации микросервисов, на которых уже проверена работа приложений dotnet до миграции в кластер, можно примонтировать их в этот контейнер. Путь в контейнере сохранен, как было до этого на железе в соответствии с документацией: "/extra/" и имя сервиса.
Попробуем достучаться до микросервиса, предназначенного для приема пакетов от СУБД Oracle и продюсирования в kafka:
```
curl embwebproxy.parus:5121/api/Mq
Ping? Pong!
```
Запрос также отображается в логах:





