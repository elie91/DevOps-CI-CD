# Ansible - TP2 : Inventaires et commandes simples

> **Objectifs du TP**
> - Écrire un premier inventaire
> - lancer des commandes sur cet inventaire
>
> **Prérequis**
>
> Avant de commencer ce TP, vous devez avoir satisfait les prérequis suivants :
> - Vous êtes familier de Linux, des commandes shell
> - Vous disposez d’Ansible installé

## Création d’une structure pour notre code Ansible

Nous allons commencer par créer un répertoire pour y stocker le code Ansible que nous allons écrire durant les TP. Ce répertoire sera géré avec Git.

Ouvrez une console et placez-vous dans une dossier vierge "ansible" par exemple. 

À partir de ce moment, et sauf indication particulière, nous allons toujours supposer que c’est le répertoire courant de votre terminal. Si vous fermez et ré-ouvrez votre console, pensez bien à y retourner !
Créer ensuite la structure git pour ce répertoire :

```bash
$ git init .
```

La commande `ls -a` doit vous montrer la présence désormais d’un répertoire `.git` dans ce dossier.

## Fingerprint des serveurs

Ansible repose sur SSH pour les connexions aux serveurs, et l'établissement de 1ère connexion SSH
demande la confirmation de l'autenticité du serveur :

```bash
$ ssh-keyscan -p 22 adresse_ip_serveur  >> ~/.ssh/known_hosts
# adresse_serveur1:22 SSH-2.0-OpenSSH_7.6p1 Ubuntu-4ubuntu0.3
# adresse_serveur2:22 SSH-2.0-OpenSSH_7.6p1 Ubuntu-4ubuntu0.3
# adresse_serveur2:22 SSH-2.0-OpenSSH_7.6p1 Ubuntu-4ubuntu0.3
# adresse_serveur2:22 SSH-2.0-OpenSSH_7.6p1 Ubuntu-4ubuntu0.3
# adresse_serveur3:22 SSH-2.0-OpenSSH_7.6p1 Ubuntu-4ubuntu0.3
# adresse_serveur3:22 SSH-2.0-OpenSSH_7.6p1 Ubuntu-4ubuntu0.3
# adresse_serveur3:22 SSH-2.0-OpenSSH_7.6p1 Ubuntu-4ubuntu0.3
# adresse_serveur1:22 SSH-2.0-OpenSSH_7.6p1 Ubuntu-4ubuntu0.3
# adresse_serveur1:22 SSH-2.0-OpenSSH_7.6p1 Ubuntu-4ubuntu0.3
```

Il existe d'autres moyens de contourner cette étape, en positionnant `host_key_checking` dans `ansible.cfg` par exemple.

## Création d’un fichier d’inventaire

Nous allons maintenant créer un nouveau répertoire qui va contenir notre fichier d’inventaire :

```bash
$ mkdir inventories
```

Ouvrez à présent un éditeur de texte pour saisir le contenu du fichier d’inventaire.

Nous allons créer un fichier inv.ini avec comme contenu 1 machine que nous allons contrôler avec Ansible. 

```ini
# inventories/inv.ini

[app_server]
<ip machine créee sur aws>

```

N’oubliez pas de remplacer `<ip machine>`, par l'adresses IP de la machine que vous avez créée avec Terraform.

> **Question 2.1**
> - Comment vérifier que nous y avons accès ?

Assurez-vous au moment de sauvegarder le fichier qu’il se trouve bien dans `.../inventories/` et qu’il se nomme bien `inv.ini`.

Dans la console, lancez à présent la commande suivante, pour vérifier que le fichier d’inventaire est correct : 

```bash
$ ansible -i inventories/inv.ini all --list-hosts
```

Cette commande devrait vous afficher la liste des 3 machines (si vous avez mis un count=3, sinon une seule en effet).

Dans la ligne de commande précédente, remplacez `all` par successivement :
- `app_server`


> **Question 2.2**
> - Combien de machines sont remontées avec l’argument `load_balancers` ?
> - Avec `app-server` ?

## ansible.cfg

Avec Ansible 2.9, un message d'obsolescence peut s'afficher lors de l'execution de commandes :

```
[DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host adresse_serveur should use /usr/bin/python3, but is using /usr/bin/python for backward
compatibility with prior Ansible releases. A future Ansible release will default to using the discovered platform python for this host. See
https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html for more information. This feature will be removed in version 2.12.
Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
```


Ce message informe d'une future modification du comportement d'Ansible concernant la détection de l'interpreteur Python à utiliser.
Actuellement, c'est l'interpreteur `python2` qui est privilégié et l'interpreteur `python3` sera le nouvel interpreteur dès Ansible 2.12.

Afin de ne pas avoir le message de dépréciation pour chaque commande nous allons renseigner le paramètre `interpreter_python` dans le fichier `ansible.cfg` que nous allons créer dans le répertoire courant.

```ini
[defaults]
interpreter_python=auto
remote_user=ubuntu
```

La valeur `auto` nous mettra dans les conditions du fonctionnement d'Ansible 2.12, qui utilisera `python3` comme interpreteur.

## Première commande simple

Une fois que vous avez vérifié que l’inventaire était correctement écrit et compris par Ansible, nous allons modifier la commande pour lancer (enfin) une vraie commande sur la(les) machine(s) :

```bash
$ ansible -i inventories/inv.ini all -u ubuntu -a "hostname"
```

Attention, si vous avez utilisé des AMI qui ne sont pas des ubuntu, vous devrez remplacer "ubuntu" par "ec2-user" ou un autre utilisateur en fonction de l'image utilisée. 

Vous devriez voir la première sortie de l’appel à la commande hostnamesur la machine. Vérifiez que le retour est bien en succès avec un code de retour (`rc`) égal à 0.

Modifiez la commande précédente pour compter le nombre de lignes dans le fichier `/etc/passwd` : 

```bash
$ ansible -i inventories/inv.ini all -u ubuntu -a "wc -l /etc/passwd"
```

Prenez garde à bien encadrer la commande entre des guillemets !!
Vérifier que la commande distante est bien exécutée en tant qu’utilisateur ubuntu avec la commande suivante : 

```bash
$ ansible -i inventories/inv.ini all -u ubuntu -a "whoami"
```

Recommencez la même commande sans l’option `-u ubuntu`.

```bash
$ ansible -i inventories/inv.ini all -a "whoami"
```

> **Question 2.3**
> - Est-ce que la commande fonctionne ?
> - Pourquoi ?

Relancer la commande en ajoutant l’option `-b`:

```bash
$ ansible -i inventories/inv.ini all -b -a "whoami"
```

La commande a été exécutée en tant que **root** en utilisant **sudo** pour passer administrateur. Ceci est possible car les comptes **ubuntu** sur la(les) machine(s) cibles sont autorisés à lancer n’importe quelle commande sans même à avoir à fournir un mot de passe.

le terme `-b` signifie **become** pour signifier qu’après la connexion, on souhaite devenir un autre utilisateur. Sans précision particulière, c’est l’utilisateur **root** qui est utilisé.

Lancez la commande `ansible --help` pour chercher l’option à ajouter pour devenir un autre utilisateur. une fois trouvée, utilisez cette option pour lancer la commande `id` en tant que l’utilisateur **nobody**.

> **Question 2.4**
> - Quel est l’uid de l’utilisateur `nobody` ?

La commande ansible permet de lancer plusieurs types d’opérations (appelé **modules**), et sans précision, c’est le module `command` qui est utilisé. Ainsi, les commandes

```bash
$ ansible -i inventories/inv.ini all -a "whoami"
```

 et
```bash
$ ansible -i inventories/inv.ini all -m command -a "whoami"
```
sont équivalentes.

Regardons quelques autres modules disponibles et utilisables facilement en ligne de commande.
Pour simplement vérifier la connectivité (connexion ssh OK, compte OK, python installé), le module `ping` est utile : 

```bash
$ ansible -i inventories/inv.ini all -m ping
```

## Création d’un ansible.cfg simple

Ajoutez à présent dans le fichier ansible.cfg le contenu suivant :

```ini
[defaults]
interpreter_python=auto
inventory = inventories/inv.ini
force_color = true
remote_user = ubuntu
```

Assurez-vous que désormais vous pouvez lancer les mêmes commandes que précédemment sans avoir à préciser le fichier d’inventaire à utiliser :

```bash
$ ansible all -a "pwd"
```

Profitons-en pour lancer un resynchronisation des caches apt qui nous servira plus tard :

```bash
$ ansible all -b -a "apt-get update"
```

## Commit Git
C’est la fin de ce premier TP réellement productif, bravo.
Il est temps d’enregistrer votre travail dans Git.

Si vous n’êtes pas familier avec Git, voici les commandes à lancer pour enregistrer vos changements : 

```bash
$ git checkout -b "tp2"
$ git add .
$ git commit -m "initial commit"
$ git push origin tp2
```

Plus tard, et si avez besoin, vous pourrez à tout moment revenir à cet état du code Ansible en tapant : 

```bash
$ git checkout tp2
```
