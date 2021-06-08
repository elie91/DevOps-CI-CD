<!--- 
Ceci est la version en markdown !
Utilisez l'aperçu pour avoir une version plus lisible
-->
# Terraform - TP0 : Installation Terraform

> **Objectifs du TP** :
>- Installer l’outillage nécessaire pour accéder à AWS via Terraform
>- Installer Terraform
>

## 1- Installer Terraform

Mac : `brew install terraform`

Les autres, commencez par vous acheter un mac... lol
Plus sérieusement, récupérez le binaire [terraform](https://www.terraform.io/downloads.html) à télécharger. 

Bien évidemment dans les commandes suivantes il est possible que le nom change en fonction de la version que vous avez téléchargé, faites donc attention.

```sh
$ sudo unzip terraform_0.14.7_darwin_amd64.zip -d /usr/local/bin/
$ rm terraform_0.14.7_darwin_amd64.zip
```

## 2- Valider l'installation de Terraform

Vérifier que la version de terraform correspond à la version téléchargée.

```sh
$ terraform --version
Terraform v0.14.7
```

## 3- Configurer votre compte AWS :

Pour permettre à Terraform d'utiliser les apis d’AWS il faut évidemment renseigner des credentials.
Vos credentials vous seront partagés si cela n'a pas déjà été fait. 

```sh
$ export AWS_ACCESS_KEY_ID=<votre_access_key>
$ export AWS_SECRET_ACCESS_KEY=<votre_secret_key>
$ export AWS_DEFAULT_REGION="eu-west-1"
```
