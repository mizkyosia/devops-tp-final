# DevOps - TP Final

> *Léo Lewandowski  
> Anaïs Masson   
> Mathis Van Uytvanck*

## Partie 1 - Préparation

Nous avons décidé d'utiliser Vagrant pour le déploiement de la VM, par simplicité d'utilisation. La configuration se situe dans le [Vagrantfile](./Vagrantfile) à la racine du projet

Nous avons choisi la distribution Debian Bookworm (Debian 12) car il s'agit de la dernière version stable en date, et donc la mieux maintenue.

Pour mettre en route la VM, il suffit d'utiliser la commande `vagrant up` dans le dossier racine du TP. Il suffit ensuite d'utiliser `vagrant ssh vm-kubernetes` (dans le même dossier) pour se connecter à la machine virtuelle.

Lors de sa création, la VM sera automatiquement provisionné par un [playbook](./ansible/playbook.yaml) Ansible, permettant d'installer automatiquement `k3s` ainsi que de copier le manifest kubernetes dans la VM.

## Partie 2 - Conteneurisation

La configuration Docker du projet se situe dans le [Dockerfile](./Dockerfile) à la racine du projet. Il consiste en 8 grandes étapes :

- Création d'une nouvelle image intermédiaire qui servira à "build" l'image finale
- Copie du `package.json` et installation des packages `npm` nécessaires. Les packages de développement (`devDependencies`) sont exclus par le flag `--production` de `npm install`
- Copie du contenu de l'API. Le fichier [.dockerignore](./.dockerignore) permet d'ignorer les fichiers inutiles au déploiement/bon fonctionnement de l'API (assets, config de Prettier, ...)
- Création de l'image finale
- Copie du code source + packages dans la nouvelle image

Le build multi-stage n'est pas réellement nécessaire, mais permet de retirer ~25MB de l'image finale, à la fois en enlevant le cache d'installation NPM, et en réduisant le nombre de layers de l'image.

La taille finale de l'image est donc de **_174MB_** (contre 202MB sans multi-stage build)

L'image a été publiée sur Dockerhub sous le nom [`mizkyosia/devops-tp-final`](https://hub.docker.com/repository/docker/mizkyosia/devops-tp-final/general)

## Partie 3 - Kubernetes

On crée notre [manifest](./manifest.yml) de déploiement Kubernetes, qui contient 4 systèmes :

- Un `StatefulSet` permettant de déployer la BDD. Ici, il n'y a pas réellement de différence entre StatefulSet et Deployment car on ne mets qu'une seule réplique de la BDD
- Un `Deployment` permettant de déployer l'API elle-même, depuis le container Docker publié sur DockerHub
- 2 services `NodePort` permettant à Prometheus de se connecter à la BDD et l'API pour le monitoring

## Partie 4 - CI/CD

On définit notre [pipeline CI/CD](./.github/workflows/ci.yaml), qui est composée de 5 grands steps :

- Checkout du repo : Permet de mettre à jour le repo Git, ainsi que les sous-modules Git (on en utilise 1 pour l'API)
- Vérifier que les exécutables nécessaires sont bien installés sur l'hôte du runner
- Créer/lancer les VMs avec `vagrant up`
- Build l'image Docker et la tag localement
- Lancer le cluster k3s dans la VM dédiée à cet effet

## Partie 5 - Monitoring

Nous avons ici besoin d'une seconde VM. Nous allons donc rajouter une nouvelle déclaration de VM dans le [Vagrantfile](./Vagrantfile).

Nous allons aussi avoir besoin d'un nouveau provisioning Ansible.
On crée donc un [2ème playbook](./ansible/playbook2.yaml) qui permet de mettre en place tous les outils nécessaires au monitoring. Il va :

- Installer et lancer Docker
- Installer docker compose
- Configurer Prometheus
- Créer `docker compose` avec Prometheus, Grafana et `prometheus/node_exporter`
- Créer les ressources nécessaires à Grafana (monitoring directories)
- Télécharger le dashboard et l'ajouter à Grafana
- Lancer le `docker compose`
- Vérifier que les 3 processus marchent bien

Enfin, on modifie le manifest Kubernetes pour rajouter un pod `prometheus/node_exporter` pour monitorer nos déploiements.