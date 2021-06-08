
# Introduction

Nous allons agrémenter plusieurs TP qui vont successivement vous permettre de constituer un déploiement Ansible assez élaboré.
D’abord assez simples, **les TP se basent à chaque fois sur le résultat du TP précédent**.

Si vous avez eu du mal lors d’un TP, à chaque étape, un joker vous permet de repartir d’un état correct pour continuer l’aventure sur le TP suivant.

Au fur et à mesure des TPs, des questions vous seront posées sous la forme suivante :

> **Question**
> * Ceci est une question d’exemple, l’avez-vous bien lue ?

Durant certains exercices, des zones d’aides ou de suggestion vous permettront d’aller au delà des concepts étudiés dans la partie théorique de la formation. Libre à vous de relever les défis qui vous seront proposés !!

## Démarrage

Pour réaliser les TPs Ansible il vous faudra avoir accès à une VM en SSH. Pour cela, vous devriez maintenant savoir comment créer une VM (EC2) sur AWS à l'aide de l'outil Terraform. Pensez à utiliser les "Outputs" afin de récupérer l'adresse ip public de votre instance, elle vous sera utile pour tous les TPs Ansible ! 

Cette machine que vous avez créée, vous est dédiée et vous avez les droits d’administrateur dessus, ce qui implique notamment la capacité de tout y détruire. De grands pouvoirs impliquant de grandes responsabilités, prenez-en grand soin ;)

# TP #1 - Installation d’Ansible

> **Objectifs du TP** :
> - Installer Ansible !!
>
> **Prérequis** :
>
> Avant de commencer ce TP, vous devez avoir vérifié les prérequis suivants :
> - Vous êtes familier de Linux, des commandes shells


## Installation d’Ansible
Notre premier objectif est d’installer Ansible. Une fois installé, Ansible est accessible notamment au travers de la commande :

```bash
$ ansible
```

Afin d'installer Ansible passez par ce lien et suivez les instructions liées à votre environnement OS : https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html


Pour ceux qui ont python et pip d'installé, vous pouvez lancer la commande suivante afin d'installer Ansible : 

```bash
$ sudo pip install ansible==2.9
```

Vérifiez que la commande se termine bien par deux lignes semblables à :

```bash
...
Successfully installed MarkupSafe-1.1.1 PyYAML-5.1.2 ansible-2.9.0 asn1crypto-1.2.0 cffi-1.13.0 cryptography-2.7 jinja2-2.10.3 pycparser-2.19 six-1.12.0
.
.
.
```

## Vérification de la version d’Ansible installée

Lancez la commande suivante :
```bash
$ ansible --version
```

>**Question 1.2**
>-   Quelle est la version d’Ansible qui a été installée ?
