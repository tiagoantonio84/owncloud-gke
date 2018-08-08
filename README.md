# EXECUTANDO O OWNLCOUD NO GOOGLE KUBERNETES ENGINE 

### OBJETIVO
Implantar o Ownlcoud, Software de Colaboração em Nuvem, no serviço gerenciado de Kubenetes do Google Cloud Platform.

### PRÉ-REQUISITO

1. Terraform: para criação da infraestrutura (https://www.terraform.io/downloads.html)
2. Google Cloud SDK: para interação com o Google Cloud via linha de comando (https://cloud.google.com/sdk/install)
3. Kubectl: para interação com o Kubernetes (https://cloud.google.com/kubernetes-engine/docs/quickstart)
4. Conta Google e Projeto: para criação da infraestrutura necessária (https://cloud.google.com/resource-manager/docs/creating-managing-projects)
5. Service Account (GCP) com permissão nos serviços de ClouSQL (MySQL) e Kubernetes Engine: para uso do terraform (https://cloud.google.com/iam/docs/creating-managing-service-accounts) 

### ESTRUTURA DO REPOSITÓRIO
    .
    ├── k8s                   # código de infraestrutura para criação dos recursos no Kubernetes    
    └── terraform             # código de infraestrutura para criação dos recursos no GCP


### CONFIGURAÇÃO E ALTERAÇÕES NO TERRAFORM

Para configuração do terraform com GCP, no arquivo terraform/config.tf, alterar a linha credentials informando o path para o json gerado na criação na criação da conta de serviço no GCP e a linha project para o ID do projeto no GCP:

```bash
provider "google" {
  credentials = "${file("/path/to/service-account.json")}"
  project     = "google-project"
  region      = "${var.region}"
}
```

Os parâmetros que geralmente são alterados de acordo com cada ambiente (nome de recursos, tipos de instâncias, senhas, usuários, regiões e etc..) estão referênciados por meio de variáveis, no arquivo `terraform/variables.tf`. E devem ser alterados de acordo com a necessidade.

### EXECUÇÃO DO TERRAFORM
```bash
$ cd terrform
$ terraform init
$ terraform plan
$ terraform apply
```

### AUTENTICAÇÃO DO GCLOUD E KUBECTL
Realizar a autenticação do gcloud e kubectl:

```bash
$ gcloud init
$ gcloud container clusters get-credentials cluster-name --zone us-east1-c --project project-id
```

O primeiro comando exibirá algumas opções na tela para selecionar o projeto e configurar uma região padrão.

No segundo comando, alterar os parâmetros do nome do cluster, zona e projeto de acordo com o ambiente criado.

### CONFIGURAÇÃO DOS YAML's DO KUBERNETES

1. Criar uma service account no painel do Google com permissão de acesso ao CloudSQL,conforme documentação: https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine.

O GCP ainda não permite acesso ao serviço gerenciado de banco de dados pela VPC. O CloudProxy, na infraestrutura do Kubernetes, é um container que roda junto com o container da aplicação (sidecar), fazendo proxy para o MySQL.

2. Converter o json gerado para base64
```bash
$ cat /path/to/service-account.json | base64
```

3. Inserir o hash gerado na linha `credentials.json` do arquivo `secret-cloudsql-serviceaccount.yaml`

4. Gerar o base64 para o primeiro login e senha do owncloud e inserir no arquivo `secret-owncloud-userpass.yaml`
```bash
$ echo admin | base64
$ echo password | base64
```

5. Alterar a string de conexão do cloudproxy com o CloudSQL no arquivo `deployment-owncloud.yaml`
```bash
command: ["/cloud_sql_proxy",
               "-instances=project-name:us-east1:cloudsql-instance-name=tcp:3306",
               "-credential_file=/secrets/cloudsql/credentials.json"]
```
A string `project-name:us-east1:cloudsql-instance-name` é composta pelo ID do projeto no GCP, região e nome da instância do CloudSQL.

6. Alterar as variáveis de ambiente do Owncloud no arquivo `deployment-owncloud.yaml` de acordo com o ambiente.

Abaixo está um breve descritivo de cada arquivo:

    ├── k8s                    
    │   ├── deployment-owncloud.yaml                     # Criação do deploymnent no kubernetes
    │   ├── pvc-owncloud.yaml                            # Criação volume persistente para os dados dos usuários do sistema
    │   ├── secret-cloudsql-serviceaccount.yaml          # Armazenamento da conta de serviço criada para o cloudproxy acessar o cloudsql, em base64
    │   ├── secret-owncloud-userpass.yaml                # Armazenamento do login inical e senha do owncloud, em base64
    │   └── service-ownloud.yaml                         # Exposição do serviço via loadbalancer TCP do GCP



### CRIAÇÃO DOS RECURSOS NO KUBERNETES
```bash
$ cd k8s
$ kubectl create -f .
```

### VERIFICAÇÃO DO STATUS DOS PODS E DO SERVICE

Verificar o status do POD:

```bash
kubectl get pods
NAME                        READY     STATUS    RESTARTS   AGE
owncloud-75d574c965-jdrks   2/2       Running   0          2m
```

Executar um "tail" no console do container `owncloud` no POD:
```bash
kubectl logs -f owncloud-75d574c965-jdrks -c owncloud
Creating volume folders...
Creating hook folders...
Waiting for MySQL...
wait-for-it: waiting 180 seconds for 127.0.0.1:3306
wait-for-it: 127.0.0.1:3306 is available after 3 seconds
Removing custom folder...
Linking custom folder...
Removing config folder...
Linking config folder...
Copying config file...
Copying domains file...
Copying db file...
Fixing hook perms...
Fixing base perms...
Fixing data perms...
Installing server database...
ownCloud was successfully installed
Enabling files_external app...
files_external enabled
files_external enabled
ownCloud is already latest version
Generating default cert...
Generating a 4096 bit RSA private key
..........++
.........................++
writing new private key to '/mnt/data/certs/ssl-cert.key'
-----
Enforcing cli url...
System config value overwrite.cli.url set to string http://localhost/
Disabling update checks...
System config value updatechecker set to string false
Disabling upgrade web...
System config value upgrade.disable-web set to string true
Disabling memcached config...
System config value memcache.distributed deleted
System config value memcache.locking deleted
System config value memcached_servers deleted
Disabling redis config...
System config value memcache.distributed deleted
System config value memcache.locking deleted
System config value redis deleted
Enabling file locking...
System config value filelocking.enabled set to string true
Configure locale caching...
System config value memcache.local set to string \OC\Memcache\APCu
Disabling maintenance mode...
Maintenance mode disabled
Touching log file...
Setting log level...
System config value loglevel set to string 2
Setting default language...
System config value default_language set to string en
Enabling background cron...
Set mode for background jobs to 'cron'
Removing object storage...
Disabling object storage...
System config value objectstore deleted
Setting rewrite base...
System config value htaccess.RewriteBase set to string /
Updating htaccess config...
.htaccess has been updated
Writing apache config...
Writing php config...
Touching cron configs...
Starting cron daemon...
Starting apache daemon...
Finishing ownCloud launch...
```

Exibir o status do serviço:

```bash
- kubectl get svc
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)        AGE
owncloud     LoadBalancer   10.3.248.89   35.199.70.75   80:31754/TCP   5m
```

O acesso ao sistema deve ser feito pelo `EXTERNAL-IP` do service (http://EXTERNAL-IP).

### CENTRALIZAÇÃO DE LOGS
Por padrão todos os logs da solução são centralizados no Stackdriver do GCP.

### TO DO
1. Utilizar secret para armazenar senha de conexão com o MySQL;
2. Criação do deployment e service do Redis;
3. Criação do arquivo de configuração do Ingress e alteração do Service para NodePort e usar o loadbalancer l7 do Google com certificado (https).
