variable "region" {
  default = "us-east1"
  description = "informar a regiao do provedor cloud que sera utilizada"
}

variable "network_name" {
  default = "default"
  description = "informar o nome da rede onde os recursos serao criados"
}

variable "subnet1_name" {
  default = "default"
  description = "informar o nome da subnet onde os recrusos serao criados"
}

variable "zone_aza" {
  default = "us-east1-c"
  description = "informar a zona de disponibilidade do provedor cloud que sera utilizada"
}

variable "cluster_name" {
  default = "owncloud"
  description = "informar o nome do cluster de kubernetes"
}

variable "ks8_version" {
  default = "1.10.5-gke.0"
  description = "informar a versao de kubernetes que ser criada"
}

variable "legacy_auth" {
  default = "true"
  description = "informar se a autenticacao legada do kubernetes estara ativa"
}

variable "k8s-username" {
  default = "admin"
  description = "informar o login administrativo do kubernetes"
}

variable "k8s-password" {
  default = "password"
  description = "informar a senha do login administrativo do kubernetes"
}

variable "node_size" {
  default = "n1-standard-2"
  description = "informar o tipo de instancia do cluster de kubernetes"
}

variable "cloudsql_name" {
  default = "owncloud-db"
  description = "informar o nome da instancia de mysql"
}

variable "database_version" {
  default = "MYSQL_5_7"
  description = "informar a versao de mysql"
}

variable "database_user" {
  default = "root"
  description = "informar o nome de superusuario do mysql"
}

variable "database_password" {
  default = "password"
  description = "informar a senha do superusuario do mysql"
}

variable "proxy_user" {
  default = "proxyuser"
  description = "informar a senha de conexao do usuario do cloudproxy com o mysql"
}

variable "proxy_password" {
  default = "password"
  description = "informar a senha do usuario do cloudproxy com o mysql"
}

variable "database_name" {
  default = "owncloud_db"
  description = "informar o nome do banco de dados que sera utilizado pela aplicacao"
}

variable "mysql_size_instance" {
  default = "db-f1-micro"
  description = "informar o tipo da instancia de cloudsql"
}

variable "mysql_disk_size" {
  default = "10"
  description = "informar tamanho do disco reservado para o cloudsql"
}
