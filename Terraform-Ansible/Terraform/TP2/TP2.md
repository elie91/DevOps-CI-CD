<!--- 
Ceci est la version en markdown !
Utilisez l'aperçu pour avoir une version plus lisible
-->
# Terraform - TP2: Syntaxe HCL - Utilisation basique

> **Objectifs du TP** :
>- Se familiariser avec la déclaration de ressources AWS via Terraform
>- Manipuler les commandes de base de Terraform
>- Comprendre le fonctionnement et la manipulation des ressources
>

## 1- Objectifs détaillés

Dans ce TP, nous allons déployer une Topologie composée de :
* un subnet publique
* une table de routage pour le subnet publique
* un Security Group autorisant le port 80 et 443 en entrée puis 80 en sortie
* une instance

Nous allons donc utiliser différentes ressources aws.

La documentation terraform associé à AWS est disponible [ici](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

Attention, la documentation commence par la partie datasource, dans ce tp nous utiliserons que la partie ressource disponible plus bas dans la page.


## 2- Création de la topology

Créez le fichier topology.tf et y implementer les ressources décrites ci-dessous à l'aide des éléments vus en cours avec les informations suivantes:

Un vpc **(SI VOUS ETES SUR VOTRE PROPRE COMPTE AWS UNIQUEMENT)**, s'appelant my_vpc, composé : 
* d'un attribut "cidr_block" avec la valeur `10.0.0.0/16`

Une internet gateway **(SI VOUS ETES SUR VOTRE PROPRE COMPTE AWS UNIQUEMENT)**, s'appelant my_ig, composé : 
* d'un attribut "vpc_id" avec comme valeur `l'id du vpc que vous venez de créé`

Une route table **(SI VOUS ETES SUR VOTRE PROPRE COMPTE AWS UNIQUEMENT)**, s'appelant my_route_table, composé : 
* d'un attribut "vpc_id" avec comme valeur `l'id du vpc que vous venez de créé`
* d'un bloc "route" avec composé :
    * d'un cidr_block valant `0.0.0.0/0`
    * d'un gateway_id avec comme valeur `l'id de l'internet gateway que vous venez de créé`

Un subnet, s'appelant my_subnet, composé:
* d'un attribut "availability_zone" avec la valeur: `eu-west-1a`
* d'un attribut "cidr_block" avec la valeur: `10.0.1.0/24` # Si lors du lancement du code vous avez une erreur (The CIDR '10.0.X.0/24' conflicts with another subnet), remplacez le "1" par un chiffre aléatoire inférieur à 254. Comme vous travaillez tous dans un même compte AWS il faut que chacun ai un chiffre différent. 
* d'un attribut "vpc_id" avec la valeur: `vpc-0856032ce82ce8221` (ou bien l'id du vpc que vous a créé au dessus **si vous utilisez votre compte AWS**)
* d’un tag "Name" valant : `votre user_id`
* d’un tag "User" valant : `votre user_id`
* d'un tag "TP" valant : `TP2`

Une route table association s'appelant my_route_table_association, composée : 
* d'un attribut "subnet_id" avec comme valeur : `l’id du subnet créé précédemment`
* d'un attribut "route_table_id" avec comme valeur : `rtb-0418a191a893f8d1f` (ou bien l'id de la route table que vous a créée au dessus **si vous utilisez votre compte AWS**)

Un security group, s'appelant my_security_group, composé:
* d'un attribut "name_prefix"  valant : `votre user_id`
* d'un attribut "vpc_id" avec la valeur: `vpc-0856032ce82ce8221` (ou bien l'id du vpc que vous a créé au dessus **si vous utilisez votre compte AWS**)
* d’un tag "Name" valant : `votre user_id`
* d’un tag "User" valant : `votre user_id`
* d'un tag "TP" valant : `TP2`

Une règle de security group, s'appelant my_security_group_rule_out_http, composée:
* d'un attribut "type" correspondant au flux sortant `egress`
* d'un attribut "from_port" valant : `80`
* d'un attribut "to_port" valant : `80`
* d'un attribut "protocol" valant : `tcp`
* d'un attribut "cidr_blocks" acceptant toutes les IPs `0.0.0.0/0`
* d'un attribut "security_group_id" correspondant à `l’id du security group créé précédemment`

Une règle de security group, s'appelant my_security_group_rule_out_https, composée:
* d'un attribut "type" correspondant au flux sortant `egress`
* d'un attribut "from_port" valant : `443`
* d'un attribut "to_port" valant : `443`
* d'un attribut "protocol" valant :  `tcp`
* d'un attribut "cidr_blocks" acceptant toutes les IPs  `0.0.0.0/0`
* d'un attribut "security_group_id" correspondant à `l’id du security group créé précédemment`

Une règle de security group, s'appelant my_security_group_rule_http_in, composée:
* d'un attribut "type" correspondant au flux entrant `ìngress`
* d'un attribut "from_port" valant : `80`
* d'un attribut "to_port" valant : `80`
* d'un attribut "protocol" valant : `tcp`
* d'un attribut "cidr_blocks" acceptant toutes les IPs `0.0.0.0/0`
* d'un attribut "security_group_id" correspondant à `l’id du security group créé précédemment`

Une instance, s'appelant web, composée:
* d'un attribut "ami" avec la valeur: `ami-02297540444991cc0`
* d'un attribut "subnet_id" correspondant à `l’id du subnet créé précédemment`
* d'un attribut "instance_type" valant: `t2.micro`
* d'un attribut "vpc_security_group_ids" correspondant à `l’id du security group créé précédemment`
* d'un attribut "associate_public_ip_address" à : `true`
* d’un tag "Name" valant : `votre user_id`
* d’un tag "User" valant : `votre user_id`
* d'un tag "TP" valant : `TP2`

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

Les ressources sont maintenant créées.
Si tout s'est bien passé vous devriez avoir une VM accessible depuis internet sur le port 80, cependant vous ne connaissez pas l'adresse IP publique de cette VM afin d'y accéder pour voir s'il se passe quelque chose...

A vous de jouer : 
> Trouvez sur la doc Terraform le moyen d'afficher sur le terminal l'adresse IP publique d'une instance AWS créée en Terraform.

Une vois que vous aurez trouver ce moyen, mettez-le en place et relancez la commande `terraform apply` afin de récupérer l'adresse IP.
Ouvrez un onglet de votre navigateur et mettez-y l'adresse IP.

> Que constatez-vous ? 

## 3- Un petit coup de ménage

Pour détruire votre topology :
```bash
$ terraform destroy
```
