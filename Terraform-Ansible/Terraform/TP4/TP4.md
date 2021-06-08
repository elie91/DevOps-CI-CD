<!--- 
Ceci est la version en markdown !
Utilisez l'aperçu pour avoir une version plus lisible
-->
# Terraform - TP4: Syntaxe HCL - Utilisation avancée

> **Objectifs du TP** :
>- Se familiariser avec la syntaxe avancée de Terraform
>

## 1- Objectifs détaillés

Dans le TP 3, nous avons appris à rendre le code générique afin de pouvoir changer de contexte
d'éxécution rapidement en modifiant des fichiers de variables.

Dans ce TP, nous allons utiliser les **meta-parameter** et les **expressions** pour pouvoir apporter
une mise à l'échelle plus simple de notre code.

Dans le TP, nous allons manipuler:
* depends_on
* lifecycle
* count
* splat operator
* dynamic block

## 2- Mise à jour de la topology

Récupérez les fichiers Terraform utilisés dans le TP3 (après avoir réalisé un terraform destroy).
Ajoutez donc les fichiers dans le dossier TP4 de façon à partir du même état. 

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

### depends_on

Editer les fichiers suivants en y implementant les ressources décrites ci-dessous

Dans le fichier **topology.tf**:
 * ajoutez une nouvelle aws_instance identique à la premire en changeant les éléments suivants : 
   > remplacez le nom de la ressource en `web_slave`
   > remplacez la valeur du Tag "Name" en `${var.user}-slave`
 * ajouter une dépendence entre l'instance *web_slave* et l'instance *web*
   * *web_slave* dépend de *web*

Vérifier en re-créant l'infrastructure que l'instance web_slave est construite après l'instance web.
```bash
$ terraform destroy
$ terraform plan
$ terraform apply
```


### lifecycle

Dans le fichier **topology.tf** :
 * Changer la datasource utilisée pour l'ami des machines par celle de centos
 * Faites un `plan` de l'infrastructure à créer
 * Modifier le code en utilisant les *lifecycle* pour ignorer les changements d'ami sur les instances
 * Vérifier avec le `plan` que les instances ne sont pas recréées

### count

Dans le fichier **variables.tf**, rajouter la variable "number_of_instances" en tant que nombre et 
définir dans **terraform.tfvars** sa valeur à 2.

Dans le fichier **topology.tf** :
 * Modifier la création de l'instance `web_slave` pour qu'il crée le nombre de variables en fonction de la valeur de *number_of_instances* 

Appliquer les changements et vérifier la création d'une nouvelle instance (au total 3 : web + 2 x web_slave).

### splat operator

Dans le fichier **output.tf**, ajouter les output suivants:
 * "web" valant l'adresse ip de l'instance web
 * "web_slave" valant les adresses ip des 2 instances web_slave
 
Modifier le nombre de la varialbe number_of_instances à 3 et vérifier que l'output est bien mis à jour.

### Dynamic block

Dans le fichier **variables.tf** créer :
 * la variable "ingress_ports" comme étant la liste de port à ouvrir

Dans le fichier **terraform.tfvars** :
 * Assigner les port 80 et 443 comme valeur de la variable "ingress_ports"
 
Dans le fichier **topology.tf** :
 * Utiliser un *dynamic block* pour créer les règles d'ouverture de flux pour http et https dans le security group

Valider la création du security group possédant les 2 règles.

## 3- Bonus

### Dynamic block advanced

Dans le fichier **variables.tf** créer :
 * la variable "ingress_rules_configuration" comme étant :
    * la *liste d'objet* représentant la configuration des règles *ingress* des security group
    * contenant les champs port, protocol et cidr_blocks

Dans le fichier **terraform.tfvars** :
 * Déclarer la configuration pour l'ouverture des port :
   * 443 en tcp pour toutes les plages IP (0.0.0.0/0)
   * 80 en tcp pour les plages IP 192.168.0.0/16 et 10.0.0.0/16
 
Dans le fichier **topology.tf** :
 * Utiliser un *dynamic block* pour créer les règles d'ouverture de flux pour http et https dans le security group

## 4- Un petit coup de ménage

Pour détruire votre topology :
```bash
$ terraform destroy
```
