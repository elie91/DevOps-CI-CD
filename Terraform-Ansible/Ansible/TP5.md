# TP #5 - Modularisation du code

> **Objectifs du TP**
>
> Réorganiser notre code pour utiliser des rôles
> Ajouter une gestion «propre» des handlers
>
> **Prérequis**
>
> Avant de commencer ce TP, vous devez avoir satisfait les prérequis suivants
> - Vous avez validé votre accès à vos VMs cibles
> - Vous êtes familier de Linux, des commandes shells
> - Vous disposez du code fonctionnel produit lors du TP précédent

## Organisation des rôles

Nous allons réorganiser le code présent dans `install.yml` sous forme de 3 rôles :
- Un rôle `common` qui contiendra les éléments communs à toutes les machines
- Un rôle `haproxy`
- Un rôle `tomcat`

Pour ce faire, nous allons créer l’arborescence suivante dans le répertoire de travail TP :

```
roles
  +- common
  |   +- meta
  |   |   +- main.yml
  |   |
  |   +- tasks
  |       +- main.yml
  |
  +- haproxy
  |   +- handlers
  |   |   +- main.yml
  |   |
  |   +- meta
  |   |   +- main.yml
  |   |
  |   +- tasks
  |   |   +- main.yml
  |   |   +- tests.yml
  |   |
  |   +- templates
  |       +- haproxy.cfg.j2
  |
  +- tomcat
      +- meta
      |   +- main.yml
      |
      +- tasks
          +- main.yml
          +- tests.yml
```

Le refactoring consiste donc à n’utiliser plus que des rôles à importer dans le playbook qui doit ressembler maintenant à ça :

```yaml
# install.yml
---
- hosts: all
  gather_facts: true
  become: true
  tasks:
  - import_role:
      name: common
    tags: common

- hosts: load_balancer
  become: true
  tasks:
  - import_role:
      name: haproxy
    tags: haproxy

- hosts: app_server
  gather_facts: false
  become: true
  tasks:
  - import_role:
      name: tomcat
    tags: tomcat
```

Le playbook a bien maigri et c’est une bonne nouvelle, la complexité a été déplacée dans les rôles.
Le travail de refactoring est un travail classique de développement qui arrive très régulièrement au cours de la vie du code Ansible. N’ayez pas peur de casser le code pour le rendre meilleur. Le commit Git de l’état précédent est votre garde-fou pour revenir à un état fonctionnel. Les tests sont également là pour vous assurez que vous n’avez pas cassé tout votre travail.

## Écriture des rôles

Nous allons réorganiser le code en suivant les principes suivants :
Les tests (`wait_for`, `uri`) doivent être déplacés dans les fichiers `tests.yml` dans les répertoires `tasks` des rôles correspondant. Leur inclusion dans le fichier `main.yml` doit se faire en fin de fichier, et doit être taggé avec le label tests.

Laissez pour le moment les fichiers `meta/main.yml` (dans tous les rôles) et `handlers/main.yml` (dans le rôle haproxy) vides.

Travaillez rôle par rôle et lancez souvent Ansible pour savoir si vous avez cassé quelque chose.

```
roles
  +- common
  |   +- meta
  |   |   +- main.yml -> (vide)
  |   |
  |   +- tasks
  |       +- main.yml -> (récupérer une partie de install.yml)
  |
  +- haproxy
  |   +- handlers
  |   |   +- main.yml -> (vide)
  |   |
  |   +- meta
  |   |   +- main.yml -> (vide)
  |   |
  |   +- tasks
  |   |   +- main.yml -> (récupérer une partie de install.yml)
  |   |   +- tests.yml -> (récupérer une partie de install.yml)
  |   |
  |   +- templates
  |       +- haproxy.cfg.j2 -> déplacer haproxy.cfg.j2 ici
  |
  +- tomcat
      +- meta
      |   +- main.yml -> (vide)
      |
      +- tasks
          +- main.yml -> (récupérer une partie de install.yml)
          +- tests.yml -> (récupérer une partie de install.yml)
```

## Refactoring de Tomcat

Commencez par refactorer la partie Tomcat comme amuse-bouche

### Avant :

```yaml
# install.yml
---
# ... Les parties précédentes du code ont été masquées
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

### Après:

```yaml
# install.yml
---
# ... Les parties précédentes du code ont été masquées
- hosts: app_server
  gather_facts: false
  become: true
  tasks:
  - import_role:
      name: tomcat
    tags: tomcat
```

```yaml
# roles/tomcat/tasks/main.yml
---
- name: install tomcat
  package:
    name: tomcat8

- name: start / enable tomcat
  service:
    name: tomcat8
    enabled: true
    state: started

- name: include tests
  include_tasks: tests.yml
  tags: tests
```

```yaml
# roles/tomcat/tasks/tests.yml
---

- name: wait for Tomcat to be up on port 8080
  wait_for:
    port: 8080

- name: ensure home page returns 200
  uri:
    url: http://127.0.0.1:8080/
```

Exemple de lancement d’ansible-playbook après refactoring de la partie Tomcat :

```bash
$ ansible-playbook install.yml -t tomcat
```

Produit le résultat suivant :
```
PLAY [app_server] ********************************************************************************

TASK [tomcat : install tomcat] ********************************************************************************
ok: [18.194.210.238]

TASK [tomcat : start / enable tomcat] ********************************************************************************
ok: [18.194.210.238]

TASK [tomcat : include tests] ********************************************************************************
included: /home/ubuntu/tp-ansible/roles/tomcat/tasks/tests.yml for 18.194.210.238, 18.194.135.36

TASK [tomcat : wait for Tomcat to be up on port 8080] ********************************************************************************
ok: [18.194.210.238]

TASK [tomcat : ensure home page returns 200] ********************************************************************************
ok: [18.194.210.238]

PLAY RECAP ********************************************************************************
18.194.135.36              : ok=5    changed=0    unreachable=0    failed=0   
18.194.210.238             : ok=5    changed=0    unreachable=0    failed=0
```


Vous noterez que les tâches exécutées dans le rôle tomcat sont toutes préfixées par `tomcat:`.

## Refactoring des deux autres rôles

Faites de même pour le rôle `haproxy`. N’oubliez pas de déplacer le template` haproxy.cfg.j2` dans le répertoire `roles/haproxy/templates/`, sans quoi vous allez faire connaissance avec de nouveaux messages d’erreur d’Ansible.

Quand vous aurez fini ce travail, le répertoire `tp-ansible` ne doit plus contenir que le playbook `install.yml` et les répertoires `inventories` et `roles`.

Une exécution d’ansible-playbook complète (sans limitation avec l’option `-l` ou `-t`) doit ressembler à ceci :

```
PLAY [load_balancer] ********************************************************************************

TASK [Gathering Facts] ********************************************************************************
ok: [18.195.91.219]

TASK [haproxy : install HAProxy] ********************************************************************************
ok: [18.195.91.219]

TASK [haproxy : Install configuration file] ********************************************************************************
ok: [18.195.91.219]

TASK [haproxy : Include tests for haproxy] ********************************************************************************
included: /home/ubuntu/tp-ansible/roles/haproxy/tasks/tests.yml for 18.195.91.219

TASK [haproxy : wait for HAProxy to be up on port 8080] ********************************************************************************
ok: [18.195.91.219]

TASK [haproxy : wait for HAProxy to be up on port 80] ********************************************************************************
ok: [18.195.91.219]

TASK [haproxy : ensure stat page returns 200] ********************************************************************************
ok: [18.195.91.219]

PLAY [app_server] ********************************************************************************

TASK [tomcat : install tomcat] ********************************************************************************
ok: [18.194.210.238]

TASK [tomcat : start / enable tomcat] ********************************************************************************
ok: [18.194.210.238]

TASK [tomcat : include tests] ********************************************************************************
included: /home/ubuntu/tp-ansible/roles/tomcat/tasks/tests.yml for 18.194.210.238, 18.194.135.36

TASK [tomcat : wait for Tomcat to be up on port 8080] ********************************************************************************
ok: [18.194.210.238]

TASK [tomcat : ensure home page returns 200] ********************************************************************************
ok: [18.194.210.238]

PLAY RECAP ********************************************************************************
18.194.210.238             : ok=5    changed=0    unreachable=0    failed=0   
```

## Ajout des handlers/notify pour HAProxy

Il nous reste un travail à réaliser : faire en sorte que des modifications du template `haproxy.cfg.j2` donne lieu au redémarrage du service haproxy.

Ça tombe bien, nous avons justement un changement à faire dans ledit fichier de configuration. En effet, la ligne :
```
       stats socket /var/run/haproxy.sock
```
Doit devenir :
```
       stats socket /var/run/haproxy.sock level admin
```

Pour faire ce changement, nous allons au préalable créer un handler qui va recharger le service haproxy en remplissant le fichier `roles/haproxy/handlers/main.yml` comme suit :

```yaml
# roles/haproxy/handlers/main.yml
---

- name: reload HAProxy service
  service:
    name: haproxy
    state: reloaded
```

**Attention !!**

Jusqu’à maintenant le nom (`name:`) des tâches n’avaient pas de réelle importance. Dans le cas d’un handler, c’est la clé qui permet de faire le lien entre les notify et les handlers. Prenez garde à vérifier la casse notamment (majuscules).

Une fois le handler écrit, nous pouvons mettre en place le notify :


```yaml
# roles/haproxy/tasks/main.yml
---
- name: install HAProxy
  package:
    name: haproxy

- name: Install configuration file
  template:
    src: haproxy.cfg.j2
    dest: /etc/haproxy/haproxy.cfg
  notify:
  - reload HAProxy service

- name: start / enable HAProxy
  service:
    name: haproxy
    enabled: true
    state: started

- name: include tests
  include_tasks: tests.yml
  tags: tests
```


Il ne reste plus qu’à faire la modification du fichier de template `roles/haproxy/templates/haproxy.cfg.j2` pour refléter le changement attendu et lancer ansible-playbook taggé sur haproxy pour gagner du temps :

```bash
$ ansible-playbook install.yml -t haproxy --diff
```

N’oubliez pas l’option `--diff` qui vous montrera précisément le changement effectué :

```
PLAY [all] *********************************************************************

TASK [setup] *******************************************************************
ok: [52.18.41.52]

PLAY [load_balancer] **********************************************************

TASK [haproxy : install HAProxy] ***********************************************
ok: [52.18.41.52]

TASK [haproxy : Install configuration file] ************************************
changed: [52.18.41.52]
--- before: /etc/haproxy/haproxy.cfg
+++ after: dynamically generated
@@ -1,18 +1,18 @@
 global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        user haproxy
        group haproxy
        daemon
-       stats socket /var/run/haproxy.sock
+       stats socket /var/run/haproxy.sock level admin

 defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        option                  redispatch
        retries                 3
        timeout http-request    1s
        timeout http-keep-alive 1s

TASK [haproxy : include tests] *************************************************
included: /home/ubuntu/tp-ansible/roles/haproxy/tasks/tests.yml for 52.18.41.52

TASK [haproxy : wait for HAProxy to be up on port 8080] ************************
ok: [52.18.41.52]

TASK [haproxy : wait for HAProxy to be up on port 80] **************************
ok: [52.18.41.52]

TASK [haproxy : ensure stat page returns 200] **********************************
ok: [52.18.41.52]

RUNNING HANDLER [haproxy : reload HAProxy service] *****************************
changed: [52.18.41.52]

PLAY [app_server] *************************************************************

TASK [tomcat : include tests] **************************************************
included: /home/ubuntu/tp-ansible/roles/tomcat/tasks/tests.yml for 52.50.169.220

PLAY RECAP *********************************************************************
52.18.41.52                : ok=10   changed=2    unreachable=0    failed=0   
```

> **Question 5.1**
> 
> Si on relance ansible-playbook à l’identique, est-ce que la sortie est identique ?
> Si non, quels sont les changements ?
> 
> **Réponse 5.1**
> 
> 

Pour vous convaincre de l’utilité des tags, relancer ansible-playbook avec le tag tests :

```bash
$ ansible-playbook install.yml -t tests
```

Vous venez de trouver une commande simple et rapide pour vérifier que votre plateforme a ses composants de base en état de marche !

## Commit Git

Il est temps d’enregistrer votre travail dans Git.

Voici les commandes à lancer pour enregistrer vos changements :

```bash
$ git checkout -b "tp5"
$ git add .
$ git commit -m "fin tp5"
$ git tag tp5
```

Plus tard, et si avez besoin, vous pourrez à tout moment revenir à cet état du code Ansible en tapant :

```bash
$ git checkout tp5
```

C'est donc la fin des TPs Ansible, bravo si vous avez réussi à tous les réaliser ! 
