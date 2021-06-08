# SOMMAIRE
* Docker commands
* Dockerfile
* Docker compose
* DOCKERRUN.AWS.JSON
* Kubernetes
* Kubctl


# DOCKER COMMANDS

### CREATE
* `docker create <image_name>`=> create a container from an image

### LIST
* `docker ps`=> list all running containers
* `docker ps -a`=> list all containers on our machine
* `docker image ls`=> list all images on our machine

### START
* `docker start <container_id>`=> run a container 
* `docker start -a <container_id>`=> -a option: pour voir l'output du container

### RUN
* `docker run <image>`=> create AND run a container from an image
* `docker run <image> <command>` => override command that will be executed inside the container; no possibility to replace the command after the container is created
* `docker run -d <image>`=> create and run a container in the background from an image
* `docker run -p <port> : <port> <image>` => route incoming requests to the local port to the port inside the container
* `docker run -it <image> sh` => start a container and override the default command with an interactive shell
* `docker run -v $(pwd):/folder <image>`=> create, run the container, and map the current working directory in the container specified folder
* `docker run -v <app/node_modules> <image>`=> put a bookmark on the node_module folder (: in the sythax means that we map two folders, without : we saying dont try to map this folder oustide the container)

### STOP & KILL
* `docker stop <container_id>`=> stop the container; send a SIGTERM message (terminate signal) ; allow the code to do somes cleanup before the container stop 
* `docker kill <container_id>`=> stop the container; send a SIGKILL message (terminate signal) ; the container shut down immediatly

### REMOVE
* `docker container prune`=> remove stopped containers
* `docker system prune`=> remove stopped containers, dangling images, and build cache
* `docker image prune`=> Remove unused images
* `docker image rm <image>`=> Remove specific image

### LOGS
* `docker logs <container_id>`=> display all logs that happens in the container; not rerunning the container

### EXEC
* `docker exec -it <container_id> <command>`=> execute a command inside the container; -it : -i for attaching to the STDINn and -t for nice formating
* `docker exec -it <container_id> sh>`=> sh: command shell inside the container


# DOCKERFILE
## command
* `docker build .`=> build image from the dockerfile in the current directory (. = build context)
* `docker build -t <docker_id/name:version> .`=> build and tag the image, we can run the container with the id or the tag 
* `docker build -f <filename>`=> specify the file to be use for the build (utile si Dockerfile.dev)

## file
* `FROM`=> specify a base image
* `RUN` => execute additional command while the image is preparing
* `CMD` => what should be executed when the container is started
* `COPY <path> <path>` => move file inside our machine in the filesystem of the container; ./ path take all files in the current working directory inside
the container working directory
* `WORKDIR <pathfolder>` => specify a working dir inside the container; the files copied by the COPY instruction will be copied in the working dir


# DOCKER COMPOSE
docker-compose crée les containers spécifiés dans le fichier et les mets automatiquement dans le même networking, leur permettant de communiquer entre eux.
on peut donc accéder au container redis-server par son nom dans le fichier index.js automatiquement

## command
* `docker-compose up`=> similar to docker run myimage, look for the docker-compose.yml in the current directory
* `docker-compose up --build`=> start and build the containers
* `docker-compose build`=> only build the containers
* `docker-compose up -d`=> start the containers in the background
* `docker-compose down`=> stop the running containers
* `docker-compose ps`=> list the running compose containers from the docker-compose.yml with status

## file
* `restart` => specify the restart policies: 
    * `"no"` => never attemp to restart the container
    * `always` => always attemp to restart the container if he stops for any reason
    * `on-failure` => only restart if the container stop with a error code
    * `unless-stopped` => always restart unless we (developers) forcibly stop it

# DOCKERRUN.AWS.JSON

Fichier de config dans le cas de multiple containers sur AWS.
Dans le cas du déploiement d'un unique container, AWS Beanstalk va automatiquement prendre le Dockerfile du dossier, build et run le container.
Dans le cas de multiple container, il faut créer un fichier de config.

https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/single-container-docker.html
https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker_ecs.html


docker-compose sert a dire comment les images et containers doivent etre build, et le dockerrun sert a spécifier a AWS quel images et containers sont a utiliser

Quand on utilise AWS Beanstalk pour héberger des containers, AWS Beanstalk délégue l'hébergement à un autre service AWS, qui est ECS (Elastic Container Service)

On utilise ECS en créant des fichiers task definition, qui donne des instructions a ECS comment run un container.

https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definitions.html

## containerDefinition 

* **image**: lorsque on met l'image du container sous la forme  `elie91/multi-client` (dockerid/name), AWS comprend automatiquement qu'il doit pull cette image du repo DockerHub depuis le profil du dockerid spécifié

* **hostname**: spécifie le hostname d'un container. Les autres container pourront faire appel à ce container directement par son hostname 
`hostname: "client"` 
appel: `http://client`

* **essential**: propriété booléene indiquant si le container est essential. Si un container est marqué comme essential, et que ce container crashe pour une raison x, tout les autres container du groupe seront fermés en même temps
**Au moins un** container dans le fichier doit être déclaré commme essential


# KUBERNETES

Comment scale son application correctement ? Dans le dernier projet multi-container AWS, imaginons que l'on souhaite scale notre worker container, qui réalise le plus gros du travail dans l'app.

Le problème avec AWS Beanstaclk, est que sa stratégie de scaling fonctionne comme ca : 
Un load balancer répartie les charges sur différentes repliques de l'app (voir capture dossier kubernetes)

On n'a donc pas de control réelle sur un container spécifiquement, donc sur notre worker container.

Kubernetes vient résoudre ce problème, en nous proposant une approche permettant de dupliquer et de scale un container en particulier

Donc on utilise Kubernetes quand on souhaite **une application composée de nombreux types de conteneurs différents s'exécutant en différentes quantités sur plusieurs ordinateurs différents.**

## Notions

* **Cluster** : association d'un **Master** et de un ou plusieures **Node** (voir capture)

* **Node** : machine virtuelle ou physique, utilisé pour run un ou plusieurs containers

* **Master**: Gére les différents noeud du Cluster. Utilisé pour interagir avec le cluster. 

* A l'exterieur du Cluster, un **Load Balancer** récupère les request et  les répartit entre les différents noeud du Cluster.


## Utilisation

On va prendre le projet multi-container pour le transformer en cluster Kubernetes. Pour ca, il faut réaliser 3 étapes :
* S'assurer que nos images sont push sur Docker Hub. Kubernetes s'attend en effet a des images déja build
* Ecrire un fichier de config par objet 
* Ecrire un fichier de config pour mettre en place le networking

**Object**: On utilise un fichier de config yml pour créer un objet dans le cluster. Ces objets peuvent servir à différents buts, comme run un container, monitoring de container, mettre en place un networking, etc...

Exemple de types d'objets: 

* **Pod** : Utilisé pour run ou monitorer un ou plusieurs containers ayant une même utilisation.
[doc](https://kubernetes.io/docs/concepts/workloads/pods/) 
On regroupe en général dans un Pod plusieurs containers uniquement si ils ont une très forte dépendance entre eux, et que l'un ne peut fonctionner sans l'autre.
Un Pod est le plus petit objet que l'on peux utiliser pour déployer un container; on ne peut pas en effet déployer juste un container, comme on le ferait avec docker-compose.
On ne peut pas modifier directement certaines propriétés d'un pod, comme le port par exemple. C'est la raison pour laquelle on utilise en général un objet Deployment pour gérér nos pods

* **Deployment**: Objet utilisé afin de maintenir un set de pods identiques, qui s'assure qu'ils ont la bonne config et que le nombre demandé soit exacte.
regarde constamment les pods afin de s'assurer qu'ils ont le correcte state

* **Secrets**: securely store one or more pieces of information inside of your cluster.
  Commande impérative par nature, on n'écrit pas de fichier de config pour créer l'object, puisque la donnée sensible serait exposé dans le fichier

**Service**: Objets utilisées pour mettre en place du networking dans le cluster. Un node de type Service possède 4 subtypes:
* **ClusterIp**: expose un **set de pods** aux autres objets dans le cluster. Pas d'accès pour le monde extérieure. On doit donc passer par un service Ingress pour accèder au ClusterIp. Le ClusterIp va load balancer la requete entre les différents pods du Deployment qu'il gère
* **NodePort** : expose un set de pods au monde extérieure (utile uniquement pour dev)
* **LoadBalancer**: Ancienne façon utilisée pour obtenir le traffic réseau au sein du cluster
* **Ingress**: expose un **set de services** au monde extérieure. Plusieures implémentations possibles. Nous allons utiliser au sein du projet le **Nginx Ingress**
  github.com/kubernetes/ingress-nginx


## Fichier de networking 

Voir client-node-port.yml dans dossier 4
* **spec**: **type**: spécifie le subtype du Service
* **selector**: sert à relier le Service avec les Pode ayant le meme key:value que celui spécifié ici.
On précise dans les Pode un Label, et dans les services un Selector. Les Pode et service qui auront la même paire key:value seront reliés entre eux, et donc le networking spécifié dans le Service seront appliqués sur les Pode correspondants
* **ports**: array de ports qui seront appliqués sur les Podes. Chaque array contient: 
    * **port**: le port spécifié ici sert aux autres pods ou container du cluster, s'ils veulent accèder au pod qui matche avec le service (match grace au targetPort)
    * **targetPort**: port du pod matché pour lequel on souhaite ouvrir un traffic
    * **nodePort**: port avec lequel on saisit dans le navigateur pour accèder au pod.
    Si on ne saisit pas cette propriété, un nodePort random sera assigné au Pod (entre 30000 et 32767)
the nodePort is what gets exposed to the outside world and the targetPort is what gets opened up inside of the targeted pod


# KUBCTL & MINIKUBE

## minikube

* `minikube start (--vm-driver=hyperkit)`=> start the local cluster
* `minikube status`=> print the status of the local cluster
* `minikube ip`=> print the ip address of the local cluster
* `minikube stop`=> stop the local cluster
* `minikube delete`=> delete the local cluster
* `minikube service <service>`=> ouvre une connexion et un navigateur pour le service spécifié
* **`eval $(minikube docker-env)`**: configure le docker-client local pour accèder au docker-server à l'intérieur du cluster; le cluster run en effet une instance de docker différente de celle que l'on a en local
C'est une config **temporaire** du docker-client, valable uniquement dans ce même terminal
* `minikube dashboard`=> open the minikube dashboard

## kubectl

* `kubectl apply -f <filename or directory>`=> **apply** change the current configuration of our cluster, -f specify the file with the config, or the directory for apply all config files

* `kubectl delete -f <filename>`=> **delete** we want to delete a running object, -f specify the file that created the object 

* `kubectl delete <object_type> <object_name>`=> **delete** specify type and name

* `kubectl get pods`=> **get** : we want to retrieve info about a running object; **pods**: Specifies the object type that we want to get information about (pod, services)

* `kubectl get pods -o wide`=> List all pods in ps output format with more information (such as node name).

* `kubectl get services`=> get all services

* `kubectl get deployment`=> get all deployment

* `kubectl get pv`=> get all persistent volumes

* `kubectl get pvc`=> get all persistent volumes claim

* `kubectl get secrets`=> get secrets objects

* `kubectl get events`=> display the cluster events

* `kubectl config views`=> display the cluster config

* `kubectl describe <object_type> <object_name>`=> get detailed info about the object that has the type and name specified

* `kubectl rollout restart -f Deployment.yml` : ? réponse au problème de l'update du Deployment lorsque l'image a changé ?

* `kubectl get storageclass`=> affiche les différentes options de stockage de volumes disponibles

* `kubectl create secret generic <secret_name> --from-literal key=value`=> Commande pour créér un Secret; generic est un type de secret fonctionnant par clé-valeur (il y'a aussi **docker-registry** et **tls**)
https://kubernetes.io/docs/concepts/configuration/secret/

* `kubectl get pods -n kube-system`: pour voir le ingress controller


## Construction et modification du cluster

On peut utiliser deux approches différentes: **Déclarative**(fichiers de config) ou **Impérative**(commandes). 
On priviligera le façon déclarative, et le master gérera lui même le cluster.

Lorsqu'on modifie le fichier de config, le master va regarder dans le cluster si un objet existe avec le nom et le type spécifié dans le fichier.
Si oui, il va le mettre à jour l'objet, sinon il en crée un nouveau

Cependant, on peut modifier dans un **pod** uniquement les propriétés:  `spec.containers[*].image`, `spec.initContainers[*].image`, `spec.activeDeadlineSeconds` or `spec.tolerations`.
Donc si on crée un objet Pod avec un port 3000 par exemple, on ne peut plus modifier ce port.
C'est pourquoi on utilise en général des Deployment pour gérér nos pods

# KUBERNETES volumes

On peut créér 3 sortes de volumes différents avec Kubernetes:

* **Volume**: Ce type de volumes est un objet permettant a un container de stocker de la data au niveau du pod.
C'est a dire que les volumes survivront en cas de rédemarrage du container, mais si le pod crash, toutes les données du volumes seront perdu.
Les volumes Kubernetes sont différents de ceux de Docker, dans le sens ou ils sont stocké au niveau du pod, et non pas dans la machine hote.
https://kubernetes.io/fr/docs/concepts/storage/volumes/

* **Persistent Volume**: les données sont stockés à l'extérieur du pod; pas de risque de perdre les données si le pod crash. Le master créera un nouveau pod qui se connetera au volumes
https://kubernetes.io/fr/docs/concepts/storage/persistent-volumes/

* **Persistent Volume Claim**: N'est pas réellement un volume, ne peut en effet rien stocker; c'est en réalité une sorte d'annonce, qui présente les différentes options de stockage que l'on souhaite avoir. Ces différentes options de stockage sont écrite par le développeur dans un fichier de config.
Ce fichier est ensuite envoyé a Kubernetes, qui va regarder si l'option de stockage choisi existe déja dans le cluster. Il y'a en effet des volumes disponibles immédiatement, les **Statically provisioned Persistent Volumes**.
Si l'option de stockage choisi n'existe pas, kubernetes va créér au vol un **Dynamically provisioned Persistent Volumes**, répondant au besoin. 
Par défaut, Kubernetes va prendre une partie de notre disque dur local pour le transformer en un persistent volumes communiquant avec le pod.
Cependant, pour la mise en production, il faut choisir un provider, et chaque provider propose par défaut un service de stockage (Persistent Disk pour Google, Block Store pour AWS)
https://kubernetes.io/docs/concepts/storage/storage-classes/


# GOOGLE CLOUD PLATFORM

## GCP vs AWS for Kubernetes

* Google created Kubernetes
* Far easy to use Kubernetes on GCP
* Excellent documentation


## GCP 

* Créér un projet avec billing
* Aller dans Kubernetes Engine section, create cluster: 
  * Type d'emplacement: Zonal
  * zone: de préfèrence proche de notre location
  * Version maitre: stable
* Cliquer sur Pools de noeud sur le coté
    * choisir le nombre de noeuds
    * type de noeuds (micro ou small pour - de cout)

* Aller dans IAM - admin / compte de services
  * Créer un compte de service 
  * donner le role Admin de cluster Kubernetes (gestion complète)
  * Cliquer ensuite sur le nouveau service créé, et ajouter une clé
  * Créer une clé, type JSON (cela va télécharger un fichier json contenant nos clés). Le déplacer dans le projet et l'ajouter dans le gitignore ou le supprimer après l'avoir encrypté (voir plus bas)


* Nous allons maintenant encrypter le fichier account avec travis 
  Pour cela, il nous faut ruby installé. Au lieu de l'installer en local, nous allons utiliser un container docker avec une image ruby, communiquant grace aux volumes a notre dossier de projet.
  Se rendre dans le dossier du projet, et lancer les commandes:
  * `docker run -it -v $(pwd):/app ruby:2.4 sh`
  * `cd app`
  * `gem install travis`
  * Verifier que travis est installé avec la commande `travis`
  * Lancer la commande `travis login --com`, saisir username et password
  * `travis encrypt-file service-account.json -r elie91/DockerKubernetes-KubernetesProject --com`
  * Ajouter la commande généré par travis dans le fichier .travis.yml
  * supprimer le service-account.json

* Nous allons ensuite configurer le google SDK avec notre fichier service-account: 
  fichier travis.yml: 
  * `gcloud config set project <gcloud project id>`
  * `gcloud config set compute/zone <zone>`
  * `gcloud container clusters get-credentials <cluster name>`

* On build ensuite notre image react de Dev, et on lance les tests
* Ensuite, nous allons attaquer le déploiement si les tests se sont bien effectués:
  * on précise a Travis que nous allons utiliser un fichier .deploy.sh comme provider
  * on build nos images dans ce fichier et on les push sur docker hub
  
* Nous allons maintenant créér un service secret sur notre cluster GCP:
  * Cliquer en haut a droite sur Cloud Shell Terminal
  * Une fois dans le terminal, lancer:
  * `gcloud config set project multi-k8s-286908`
  * `gcloud config set compute/zone europe-west2-c`
  * `gcloud container clusters get-credentials cluster-1`
  * Nous avons bien configuré kubctl de notre cluster sur le cloud shell
  * On peut maintenant créer le secret: 
  * si on recharge la page, et qu'on clique sur configuration sur la gauche, le secret crée devrait apparaitre
  * On va ensuite installer HELM (utilitaire permettant d'installer des third-party-modules sur un cluster kubernetes)
  * `curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3`
  * `chmod 700 get_helm.sh`
  * `./get_helm.sh`
  * On peut ensuite installer ingress-nginx
  * `helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx`
  * `helm install my-release ingress-nginx/ingress-nginx`
  * On peut ensuite vérifier que notre deployment ingress est disponible en allant dans services et entrées
  * On peut également voir notre load-balancer ingress et notre cluster-ip