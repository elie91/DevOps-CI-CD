# TP #3 - Playbooks Ansible

> **Objectifs du TP** :
> - Écrire un premier playbook
> - Déployer des vrais logiciels sur des machines
>
> **Prérequis** :
> Avant de commencer ce TP, vous devez avoir satisfait les prérequis suivants
> - Vous êtes familier de Linux, des commandes shells
> - Vous disposez du code fonctionnel produit lors du TP précédent

## Répertoire de travail
Nous allons commencer par nous assurer que nous sommes bien dans le même répertoire de travai que d'habitude.

```bash
$ pwd
```

Vous devriez avoir dedans l'état du code de la fin du TP2. 

## Premier playbook

Nous allons commencer l’écriture d’un premier playbook que nous allons nommer `install.yml`. Le fichier devra se trouver à la racine du dossier courant.

Nous allons créer un premier play qui installe tomcat sur les machines du groupe `app_server`.

```yaml
# install.yml
---
- hosts: app_server
  gather_facts: false
  tasks:
  - name: install tomcat
    package:
      name: tomcat8
```

Nous allons explicitement préciser que l’on ne souhaite pas collecter les facts des machines, car _a priori_, nous n’avons pas besoin de cette fonction.

Lançons la commande en mode test (dry-run) pour voir ce qu’ansible-playbook souhaite réaliser :

```bash
$ ansible-playbook install.yml --check
```

Avec une sortie de la forme :
```bash
PLAY [app_server] ********************************************************************************

TASK [install tomcat] ********************************************************************************
changed: [18.194.210.238]

PLAY RECAP ********************************************************************************
18.194.210.238              : ok=1    changed=1    unreachable=0    failed=0
```

Dans les versions antérieures d’Ansible, le module package nécessitait de collecter les faits (`gather_facts`) : Ansible devait savoir sur quelle distribution le code s’exécutait pour savoir quelle était la commande à lancer pour installer un paquet (`yum`, `apt-get`…).

Relancez la commande une seconde fois.

> **Question 3.1**
> - La sortie est-elle identique ?
> - Pourquoi a-t-on toujours des lignes changed ?

Relançons le playbook, mais en modifiant les options sur la ligne de commande

```bash
$ ansible-playbook install.yml
```

Nous devrions cette fois-ci avoir une sortie de la forme

```bash
ubuntu@ip-172-31-21-203:~/tp$ ansible-playbook install.yml

PLAY [app_server] ********************************************************************************

TASK [install tomcat] ********************************************************************************
fatal: [18.194.210.238]: FAILED! => {"cache_update_time": 1510241596, "cache_updated": false, "changed": false, "failed": true, "msg": "'/usr/bin/apt-get -y -o \"Dpkg::Options::=--force-confdef\" -o \"Dpkg::Options::=--force-confold\"     install 'tomcat8'' failed: E: Could not open lock file /var/lib/dpkg/lock - open (13: Permission denied)\nE: Unable to lock the administration directory (/var/lib/dpkg/), are you root?\n", "rc": 100, "stderr": "E: Could not open lock file /var/lib/dpkg/lock - open (13: Permission denied)\nE: Unable to lock the administration directory (/var/lib/dpkg/), are you root?\n", "stderr_lines": ["E: Could not open lock file /var/lib/dpkg/lock - open (13: Permission denied)", "E: Unable to lock the administration directory (/var/lib/dpkg/), are you root?"], "stdout": "", "stdout_lines": []}
	to retry, use: --limit @/home/ubuntu/tp/install.retry

PLAY RECAP ********************************************************************************
18.194.210.238             : ok=0    changed=0    unreachable=0    failed=1
```

On obtient une erreur, mince.

Cette fois-ci, au milieu du message rouge, on distingue notamment `Permission denied ...  are you root?`. En effet, pour installer un paquet sous Linux, il faut des droits d’administrateur. Nous allons donc modifier le playbook comme suit :

```yaml
# install.yml
---

- hosts: app_server
  gather_facts: false
  become: true
  tasks:
  - name: install tomcat
    package:
      name: tomcat8
```

Refaisons une tentative. Cette fois-ci, la commande a dû mettre plus de temps à s’exécuter, signe que quelque chose s’est vraiment exécuté.
Relançons la commande une seconde fois. La commande a dû rendre la main bien plus vite cette fois-ci.

> **Question 3.2**
> - La sortie est-elle identique ?
> - Pourquoi ?

Aller plus loin dans notre playbook : gestion du service

Il est temps d’enrichir notre playbook en y ajoutant désormais le démarrage de Tomcat.

```yaml
# install.yml
---

- hosts: app_server
  gather_facts: false
  become: true
  tasks:
  - name: install tomcat
    package:
      name: tomcat8
  - name: start / enable tomcat
    service:
      name: tomcat8
      enabled: true
      state: started
```

En lançant la commande, vous devriez voir le résultat suivant :

```
PLAY ***************************************************************************

TASK [install tomcat] **********************************************************
ok: [18.194.210.238 ]

TASK [start / enable tomcat] ***************************************************
ok: [18.194.210.238 ]

PLAY RECAP *********************************************************************
18.194.210.238               : ok=2    changed=0    unreachable=0    failed=0   
```

La sortie étant toute verte, aucun changement n’a eu lieu. La raison en est simple : l’installation du paquet avait déjà déclenché l’activation et le démarrage du service.

Nous pouvons nous assurer que le service est effectivement opérationnel en saisissant dans un navigateur l'IP de la machine "ip:8080" et obtenir la page `It works !` de tomcat. Bien évidemment si rien ne s'affiche demandez-vous si vous avez bien autorisé le port "8080" en entrée sur votre VM (les sécurity group), si ce n'est pas le cas, pensez à ajouter la règle d'ingress pour autoriser le port 8080.

## Tests du service

Il est important d’ajouter le maximum de tests pour valider que le service est effectivement fonctionnel, et ce, sans avoir à pratiquer de vérifications manuelles. Ces tests, écrits avec Ansible seront systématiquement exécutés et leur automatisation vous servira de harnais de non-régression.

> **Astuce**
> L’abus de tests est excellent pour la santé, à consommer sans modération

## wait_for

Ajoutons un test d’écoute de Tomcat sur le port par défaut (8080) :

```yaml
# install.yml
---

- hosts: app_server
  gather_facts: false
  become: true
  tasks:
  - name: install tomcat
    package:
      name: tomcat8
  - name: start / enable tomcat
    service:
      name: tomcat8
      enabled: true
      state: started
  - name: wait for Tomcat to be up on port 8080
    wait_for:
      port: 8080
```

Pour forcer Ansible à travailler un peu, nous allons provoquer un arrêt de tomcat sur une des machines :

```bash
$ ansible app_server -b -m service -a "name=tomcat8 state=stopped"
```

Cela doit vous retourner un message de la forme suivante :

```
18.194.210.238 | SUCCESS => {
    "changed": true, 
    "failed": false, 
    "name": "tomcat8", 
    "state": "stopped", 
    "status": {
        "ActiveEnterTimestamp": "Thu 2017-11-09 16:47:53 CET", 
        "ActiveEnterTimestampMonotonic": "1352140195", 
        "ActiveExitTimestamp": "Thu 2017-11-09 16:39:34 CET", 
        "ActiveExitTimestampMonotonic": "853462928", 
.
.
.
        "TimerSlackNSec": "50000", 
        "Transient": "no", 
        "Type": "forking", 
        "UMask": "0022", 
        "UnitFilePreset": "enabled", 
        "UnitFileState": "bad", 
        "UtmpMode": "init", 
        "WantedBy": "multi-user.target graphical.target", 
        "Wants": "network-online.target", 
        "WatchdogTimestamp": "Thu 2017-11-09 16:47:53 CET", 
        "WatchdogTimestampMonotonic": "1352140178", 
        "WatchdogUSec": "0"
    }
}
```

Par la suite, si l’on relance le playbook, on doit obtenir enfin la preuve qu’Ansible a fait du (bon) boulot :

```
PLAY ***************************************************************************

TASK [setup] *******************************************************************
ok: [18.194.210.238]

TASK [install tomcat] **********************************************************
ok: [18.194.210.238]

TASK [start / enable tomcat] ***************************************************
changed: [18.194.210.238]

TASK [wait for Tomcat to be up on port 8080] ***********************************
ok: [18.194.210.238]

PLAY RECAP *********************************************************************
18.194.210.238              : ok=4    changed=1    unreachable=0    failed=0
```

La machine a bien été modifiée. En effet, l’arrêt du service tomcat8 a eu lieu sur `app_servers`.

> **Astuce**
> On constate que le module `wait_for` ne provoque pas de changed (et n’en provoquera jamais). Ce n’est pas un module qui effectue de changement sur les machines cibles. Ce module attend (par défaut 300s) qu’un port soit dans un état attendu (en écoute par défaut). La documentation vous détaillera plusieurs autres cas d’utilisation très intéressants.

## test HTTP

Pour aller encore plus loin dans notre validation de l’application, nous allons ajouter l’appel à un nouveau module `uri` :

```yaml
# install.yml
---

- hosts: app_server
  gather_facts: false
  become: true
  tasks:
  - name: install tomcat
    package:
      name: tomcat8
  - name: start / enable tomcat
    service:
      name: tomcat8
      enabled: true
      state: started
  - name: wait for Tomcat to be up on port 8080
    wait_for:
      port: 8080
  - name: ensure home page returns 200
    uri:
      url: http://127.0.0.1:8080/
      timeout: 240
```

L’exécution du playbook se termine avec succès.

> **Astuce**
> Le module `uri` utilisé est très puissant et peut être utilisé dans de nombreux cas. Dans le cas présent nous avons principalement utilisé son comportement par défaut :
> - Interroger une URL avec la méthode HTTP GET
> - Retourner une erreur sur le code HTTP de retour est différent de 200
> 
> Nous aurions pu préciser une autre méthode, injecter des headers HTTP spécifiques voire même capturer la page retournée. Mais nous verrons cela plus tard...

## Commit Git

Il est temps d’enregistrer votre travail dans Git.

Voici les commandes à lancer pour enregistrer vos changements :

```bash
$ git checkout -b "tp3"
$ git add .
$ git commit -m "fin tp3"
```

Plus tard, et si avez besoin, vous pourrez à tout moment revenir à cet état du code Ansible en tapant :

```bash
$ git checkout tp3
```
