<!--- 
Ceci est la version en markdown !
Utilisez l'aperçu pour avoir une version plus lisible
-->
# Terraform - TP5: Passage à l'échelle

> **Objectifs du TP** :
>- Modulariser le code
>

## 1- Objectifs détaillés

Nous allons voir maintenant comment factoriser notre code, en utilisant les modules:

## 2- Création d'un module

Récupérez les fichiers Terraform du TP4 et mettez-les dans le TP5. 

Maintenant que l'on est capable de créer une infrastructure avec une instance web, nous allons voir comment faire de votre code un module réutilisable. 
Dans le dossier TP5 ajoutez un dossier "modules" et dedans un dossier "my_instance_module" où vous allez créer un fichier `instance.tf` et y mettre la ressource aws_instance que vous avez dans fichier `topology.tf`. 

Une fois le fichier `instance.tf`créé, n'oubliez pas de variabiliser tous les champs que vous souhaitez pouvoir configurer à l'appel de votre module, à minima les éléments suivants : 
* la valeur du `subnet_id` 
* la valeur de `vpc_security_group_ids` 

Et à créer les `outputs` que vous souhaitez récupérer (vous aurez besoin à minima du `public_ip`). 

Il ne vous reste plus qu'à appeler votre module dans le fichier `topology.tf` qui se trouve à la racine de votre dossier TP5 et lui passer les valeurs que vous avez configurées.

Vérifier/corriger la syntaxe terraform:
```bash
$ terraform fmt
```

Visualiser le plan d'exécution:
```bash
$ terraform plan
```

Appliquer le plan d'exécution:
```bash
$ terraform apply
```

Si tout s'est bien passé vous devriez toujours avoir une adresse ip publique affichée dans la console, et accès à la page Nginx du TP2 si vous essayez d'y accéder via l'URL. 

## 3 - Utilisation d'un module de la communauté

Vous allez maintenant utiliser le module `ec2_cluster` de la registry Terraform mis à disposition par la communauté. Eh oui, parfois il faut accepter le fait qu'on n'a pas toujours à réinventer la roue. 
Editez le fichier topology.tf pour y appeler le module `ec2_cluster` afin de remplacer votre module à vous. Bien sûr, regardez la doc du module pour comprendre sa configuration. 

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

## 4- Bonus

Vous pouvez utiliser le mode console pour récupérer l’ip de l’instance :

Exemple:
```bash
$ terraform console
> module.my_instance_module.web.public_ip
172.32.2.14
```

## 5- Un petit coup de ménage

Pour détruire votre topology :
```bash
$ terraform destroy
```
