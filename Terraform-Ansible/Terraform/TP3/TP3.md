<!--- 
Ceci est la version en markdown !
Utilisez l'aperçu pour avoir une version plus lisible
-->
# Terraform - TP3: Syntaxe HCL - Rendre son code paramétrable

> **Objectifs du TP** :
>- Se familiariser avec la paramétisation du code Terraform
>

## 1- Objectifs détaillés

Dans le TP 2, nous avons créé une topology dont les valeurs étaient codées en dur.

Nous allons maintenant dans le TP 3:
* rendre notre code paramétrable avec les variables, les datasources et les locals
* surcharger des valeurs de variables
* sortir des informations en console via la commande output

## 2- Mise à jour de la topology

Récupérez le contenu du fichier topology.tf que vous avez créé sur le TP1 afin d'y appliquer les changements suivants : 

Créez un fichier **variables.tf** avec les variables :
* user
* tp
* subnet_cidr_block
* availability_zone_suffx

Créez un fichier **terraform.tfvars** avec comme valeurs :
* user valant `votre user_id`
* tp valant `TP3`
* subnet_cidr_block valant `la valeur 10.0.X.0/24 que vous avez saisi`
* availability_zone_suffix valant `a`

Créez un fichier **datasources.tf** qui doit avoir :
* un datasource, s'appelant my_vpc, qui doit chercher un vpc filtré par:
  * l'id suivant : `vpc-0856032ce82ce8221`
* un datasource, s'appelant `current`, qui doit chercher la région courante (sans filtre ou paramètre, car comportement par défaut)

Créez un fichier **locals.tf** qui doit avoir les champs :
* "availability_zone" valant la concaténation de `data.aws_region.current.name` et `var.availability_zone_suffix`

Créez un fichier **output.tf** qui doit avoir les champs :
* "instance_ip" valant `aws_instance.my_instance.public_ip`

Remplacer maintenant dans le fichier **topology.tf** les valeurs suivantes par l’appels aux variables/datasource/locals que vous avez créées :
* [local] availability_zone (dans la ressource aws_subnet) par la local : `availability_zone`
* [variable] cidr_block (dans la ressource aws_subnet) par la variable : `subnet_cidr_block`
* [datasource] vpc_id (dans la ressource aws_subnet et aws_security_group) par la datasource : `my_vpc`
* [variable] tp (dans la ressource aws_security_group) par la variable : `tp`

Vérifier/corriger la syntaxe terraform:
```bash
$ terraform fmt
```

Initialiser le provider:
```bash
$ terraform init
```

Visualiser le plan d'exécution:
```bash
$ terraform plan
```

Appliquer le plan d'exécution:
```bash
$ terraform apply
```

Vous devriez voir en Output l’ip de l’instance

## 3- Bonus

Essayer d’utiliser la datasource suivante :

Datasource:
* Récupérer la dernière AMI ubuntu disponible sur AWS. (La Doc Terraform vous aidera)
* Récupérer la route table qui porte l'ID : `rtb-0418a191a893f8d1` (remplacer ensuite cette valeur par cette datasource)

## 4- Un petit coup de ménage

Pour détruire votre topology :
```bash
$ terraform destroy
```
