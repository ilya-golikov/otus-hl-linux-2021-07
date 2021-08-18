# ДЗ №2 iscsi-gfs2

## В процессе сделано

- Написан код терраформ, разворачивающий 4 машины в облаке Яндекс;

- Добавлен код ansible, выполняющий настройку: 1й машины со iscsi, 3 машины с pacemaker и разделяемой файловой системой GFS2 поверх LVM;

## Как запустить проект

Клонировать репозиторий, и перейти в папку `hw2`

1. Экспортировать ключ сервисного аккаунта в файл: `./terraform-key.json`

2. Переименовать файл `terraform.tfvars.example` в `terraform.tfvars` и заполнить его.

3. Выполнить:

   `terraform init`

   `terraform plan`

   `terraform apply`

4. После успешного выполнения terraform, выполнить:

   `ansible-playbook playbooks/provision.yml`
