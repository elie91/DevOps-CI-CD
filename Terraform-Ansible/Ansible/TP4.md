# TP #4 - Déploiement dynamique

> **Objectifs du TP**
> * Écrire un playbook avec un template dynamique
> * Apprendre et manipuler Jinja2
> 
> **Prérequis**
> Avant de commencer ce TP, vous devez avoir satisfait les prérequis suivants
> * Vous avez validé votre accès à votre VM cible AWS
> * Vous êtes familier de Linux, des commandes shells
> * Vous disposez du code fonctionnel produit lors du TP précédent

## Architecture de notre système
Vous travaillez aujourd'hui avec une instance EC2 comme machine cible : 

```
+---------------v---+   
|                   | 
|    app-server 1   | 
|                   |
+-------------------+
```

Afin de pouvoir avancer sur la suite du TP vous devrez créer une instance supplémentaire sur AWS en utilisant le meta-argument `count=2` 

On aura ainsi 2 machines avec lesquelles travailler. Afin de complexifier un peu le TP, vous devrez ajouter dans votre fichier `inventory.ini` le bloc suivant : 

```INI
# inventories/inv.ini

[app_server]
<ip machine créée sur aws>

[load_balancer]
<2eme ip machine créée sur AWS>
```

Nous allons donc maintenant nous attaquer au composant de load-balancing. Pour cela nous allons utiliser HAProxy, qui est un logiciel libre très efficace pour ce genre de fonctions.

Nous allons continuer à enrichir le playbook du TP précédent pour mettre en œuvre HAProxy

## Installation de HAProxy

L’installation de HAProxy ressemble à l’installation de Tomcat que nous avons vu précédemment. Commençons à ajouter un nouveau play :

```yaml
# install.yml
---

- hosts: load_balancer
  gather_facts: false
  become: true
  tasks:
  - name: install HAProxy
    package:
      name: haproxy

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

> **Remarque**
> Ce TP ne va modifier que le play sur le groupe `load_balancer`. Dans la suite du TP, seule cette section du fichier `install.yml` sera précisée, mais le reste du fichier doit être conservé en l'état.

Le lancement d’ansible-playbook peut-être réalisé. Pour gagner du temps, nous allons restreindre son exécution uniquement aux machines du groupe load-balancer grace à l’option `-l <subset>/--limit="<subset>"` :

```bash
$ ansible-playbook install.yml -l load_balancer
```

Le retour de l’exécution donne ceci :

```
PLAY [load_balancer] ********************************************************************************

TASK [install HAProxy] ********************************************************************************
changed: [18.195.91.219]

PLAY [app_server] ********************************************************************************
skipping: no hosts matched

PLAY RECAP ********************************************************************************
18.195.91.219              : ok=1    changed=1    unreachable=0    failed=0 
```

L’exécution se passe comme prévu. Notez que puisque l’on a réduit le champ d’application du playbook à une machine, on découvre qu’un play a été passé (skipping) car aucune machine du groupe utilisé n’appartient au critère (groupe) pour lancer ce play.

## Configuration de HAProxy

Pour démarrer le service, il va être nécessaire de modifier un fichier de configuration :
* `/etc/haproxy/haproxy.cfg` pour paramétrer le démon avec une configuration applicative qui implémente l’architecture décrite précédemment.

Nous allons à présent nous assurer que le service HAProxy est démarré :

```yaml
- hosts: load_balancer
  gather_facts: false
  become: true
  tasks:
  - name: install HAProxy
    package:
      name: haproxy
  - name: start / enable HAProxy
    service:
      name: haproxy
      enabled: true
      state: started
```

## Configuration applicative d’HAProxy

Nous allons utiliser le module template pour créer un fichier de configuration de HAProxy
Créez un nouveau fichier dans votre répertoire TP avec comme nom `haproxy.cfg.j2`. Le contenu à y insérer est le suivant :

```
global
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /var/lib/haproxy
    user haproxy
    group haproxy
    daemon
    stats socket /var/run/haproxy.sock

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    option                  redispatch
    retries                 3
    timeout http-request    1s
    timeout http-keep-alive 1s
    timeout check           1s
    timeout client          50s
    timeout server          50s
    timeout connect         1s
    maxconn                 3000

listen stats
    bind 0.0.0.0:8080
    stats enable
    stats uri /
 
frontend  my_frontend
    bind *:80
    default_backend be_app_server

backend be_app_server
    balance roundrobin
    option httpchk
{% for server in groups['app_server'] %}
    server      vm_{{ server|replace('.', '_') }} {{ server }}:8080 check
{% endfor %}
```

Nous avons ainsi un fichier qui contient deux cas d’utilisation de Jinja2 :
* une boucle sur les membres d’un groupes `{% for server… endfor %}`
* une variable à transformer : `{{ server|replace('.', '_') }}`, à l’intérieur de la boucle précédente

Si l’on venait à ajouter une nouvelle machine dans l’inventaire dans le groupe `app_server`, un nouveau passage d’ansible-playbook aurait pour conséquence de mettre à jour le fichier produit.

Reste ensuite à tester notre template en le référençant dans le playbook :

```yaml
- hosts: load_balancer
  gather_facts: false
  become: true
  tasks:
  - name: install HAProxy
    package:
      name: haproxy
  - name: Install configuration file
    template:
      src: haproxy.cfg.j2
      dest: /etc/haproxy/haproxy.cfg
  - name: start / enable HAProxy
    service:
      name: haproxy
      enabled: true
      state: started
```

Vous allez voir que la nouvelle configuration de HAProxy n’est pas prise en compte. Ceci parce que le service haproxy tourne déjà sur la machine. Pour qu’il puisse prendre en compte le changement, il faut le redémarrer avec la commande suivante :

```bash
$ ansible load_balancer -b -m systemd -a "name=haproxy state=restarted"
```

Si le service ne démarre toujours pas, l’erreur affichée doit pouvoir vous aider à détecter le problème dans le template.

> **Astuce**
>
> Lorsque vous mettez au point des templates, utilisez systématiquement l’option `--diff` au lancement d’ansible-playbook. Vous verrez ainsi passer les modifications du fichier sous forme de diff UNIX dans la sortie de l’exécution

Une fois que le service est démarré, vous pouvez faire des tests en consultant l'URL dans le navigateur. Récupérez d’adresse IP de votre instance EC2 placée dans le groupe load-balancer (`52.48.56.113` dans mon exemple).

Page de statistiques de HAProxy, qui montre la configuration du service, les frontends, les backends et le trafic :

`http://<IP du load-balancer>:8080`

## Ajout des tests

Ajoutez les tests sur HAProxy : celui-ci doit répondre sur les port 80 et 8080. Le port 8080 doit en outre répondre en HTTP/200

```yaml
- hosts: load_balancer
  gather_facts: false
  become: true
  tasks:
  - name: install HAProxy
    package:
      name: haproxy
  - name: allow service to start
    lineinfile:
      dest: /etc/default/haproxy
      regexp: ENABLED=.*
      line: ENABLED=1
  - name: Install configuration file
    template:
      src: haproxy.cfg.j2
      dest: /etc/haproxy/haproxy.cfg
  - name: start / enable HAProxy
    service:
      name: haproxy
      enabled: true
      state: started
  - name: wait for HAProxy to be up on port 8080
    wait_for:
      port: 8080
  - name: wait for HAProxy to be up on port 80
    wait_for:
      port: 80
  - name: ensure stat page returns 200
    uri:
      url: http://127.0.0.1:8080/
```

Relancez ansible-playbook, vérifiez que vous obtenez bien la sortie suivante :

```
PLAY ***************************************************************************

TASK [setup] *******************************************************************
ok: [52.48.56.113]

TASK [install HAProxy] *********************************************************
ok: [52.48.56.113]

TASK [allow service to start] **************************************************
ok: [52.48.56.113]

TASK [Install configuration file] **********************************************
ok: [52.48.56.113]

TASK [start / enable HAProxy] **************************************************
ok: [52.48.56.113]

TASK [wait for HAProxy to be up on port 8080] **********************************
ok: [52.48.56.113]

TASK [wait for HAProxy to be up on port 80] ************************************
ok: [52.48.56.113]

TASK [ensure stat page returns 200] ********************************************
ok: [52.48.56.113]

PLAY ***************************************************************************
skipping: no hosts matched

PLAY RECAP *********************************************************************
52.48.56.113               : ok=8   changed=0    unreachable=0    failed=0
```

> **Question 4.1**
> Pourquoi la mise en place d’un test HTTP avec le module `uri` sur le port 80 n’est a priori pas une bonne idée ?
> 
> **Réponse 4.1**
> Celle-ci je vous la donne... N'oubliez pas que dans le code vous avez d'abord configuré le load_balancer avant de configurer le app_server, ce qui veut dire que les instances qui seront derrière le load_balancer n'existeront pas lorsque celui-ci aura démaré, autrement dit, le test va échoué le temps du démarage de l'instance tomcat. 

## Commit Git

Il est temps d’enregistrer votre travail dans Git.

Voici les commandes à lancer pour enregistrer vos changements :

```bash
$ git checkout -b "tp4"
$ git add .
$ git commit -m "fin tp4"
$ git tag tp4
```

Plus tard, et si avez besoin, vous pourrez à tout moment revenir à cet état du code Ansible en tapant :

```bash
$ git checkout tp4
```
