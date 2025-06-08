## 1. **Introduction**

Le projet **SpawnIt** propose une plateforme web permettant de déployer des services complets en un clic, qu’ils soient exécutés localement (via Docker) ou dans le cloud (via AWS EC2). Pour répondre à cette ambition, nous avons fait le choix d’une approche déclarative, en nous appuyant sur OpenTofu, un moteur d’orchestration d’infrastructure issu de Terraform. Cette approche repose sur le principe : *"décrire ce que l’on souhaite obtenir, plutôt que comment y parvenir."*

SpawnIt permet à l’utilisateur de choisir un service (base de données, serveur de jeu, plateforme DevOps, etc.), de personnaliser sa configuration, puis de déclencher son déploiement. En arrière-plan, l’application génère automatiquement les fichiers de configuration nécessaires, les stocke dans un système de fichiers objet (S3), et exécute les commandes OpenTofu pour créer ou détruire l’infrastructure demandée.

Le projet utilise les bénéfices d’une IaC intégrée dans une interface simple, avec l'objectif de rendre le déploiement de services accessible et rapide. Nous avons poussé l'idée encore plus loin, car le projet peut se déployer lui-même, ce qui montre une forme d’auto-hébergement rendue possible grâce à sa propre architecture déclarative.



## 2. **Contexte et Choix Technologiques**

### 2.1 Le paradigme déclaratif

Le déploiement d’infrastructure a longtemps reposé sur des approches impératives, où chaque étape est explicitement codée. Ce type de logique, est difficile à maintenir à grande échelle, car chaque détail de l’exécution doit être anticipé et géré. Le paradigme déclaratif repose sur une l'idée de décrire l’état final souhaité, et laisser à un moteur spécialisé le soin de converger vers cet état. Cette approche permet de garantir l'idempotence, car exécuter plusieurs fois la même configuration n’a pas d’effet secondaire.

### 2.2 Pourquoi OpenTofu ?

Nous avons retenu OpenTofu, un moteur d’infrastructure open-source issu du projet Terraform. Contrairement à Terraform, OpenTofu conserve une licence ouverte et bénéficie du soutien de la Linux Foundation. OpenTofu permet de décrire des infrastructures sous forme de fichiers `.tf` et de piloter leur mise en place avec des commandes simples (`init`, `plan`, `apply`, `destroy`). Il s’intègre facilement avec :

- des providers **Docker** (pour déployer localement),
- des providers **AWS** (pour déployer sur le cloud),
- et des backends **S3** (pour stocker l’état de l’infrastructure).

### 2.3 Notre Stack

**Infrastructure as Code (IaC) & Orchestration :**

- OpenTofu : utilisé pour la définition déclarative et le provisionnement de l'infrastructure des services.
- Provider AWS pour OpenTofu : Permet la création et la gestion d'instances EC2, de Security Groups.
- Provider Docker pour OpenTofu : Permet la gestion des conteneurs, réseaux et volumes Docker

**Backend & API :**

- Node.js avec Express.js : Express.js est utilisé pour la gestion des routes, des middlewares et des requêtes HTTP.
- Server-Sent Events (SSE) : fournit un retour au client web pendant les opérations OpenTofu (planification, application).

**Stockage des Configurations & Données :**

- Amazon S3 (ou compatible, ex: MinIO) : Utilisé comme datastore principal pour les états OpenTofu des différentes infrastructures déployées (via la configuration du backend S3 d'OpenTofu). Aussi utilisé pour les configurations de service spécifiques à chaque client et les templates de service de base qui sont servis au frontend.

**Frontend :**

- Next.js (React) : Choisi pour ses capacités de rendu côté serveur, et son écosystème React.
- Material UI : Utilisée comme librairie de composants UI.
- Keycloak : Intégré pour la gestion de l'authentification et de l'autorisation des utilisateurs.

**Conteneurisation & Déploiement :**

- Docker : Utilisé pour conteneuriser les composants de l'infrastructure de base de SpawnIt (MinIO, Keycloak, frontend, backend) en local, mais aussi pour déployer les services par les utilisateurs que ce soit localement ou sur des instances cloud.

### 3. **Architecture**

L’architecture repose sur une séparation des responsabilités entre les couches d’orchestration, de stockage et d’exécution, tout en permettant une composition des services grâce à OpenTofu. Le backend est conteneurisé et encapsule à la fois l’API applicative et l’exécution des commandes `tofu`. Il communique exclusivement avec un backend objet S3, qui joue le rôle de couche de persistance unique : configurations utilisateur, templates de services, états Terraform (`terraform.tfstate`) y sont tous centralisés, ce qui permet un fonctionnement stateless côté serveur.

Lorsqu’un utilisateur configure un service à lancer, le backend génère un fichier `terraform.tfvars.json` structuré selon un schéma rigide (`instance.{...}`), qu’il stocke dans S3 sous le chemin `clients/{clientId}/{serviceId}/terraform.tfvars.json`. Ce fichier est interprété par les modules Terraform (OpenTofu) situés en local, organisés de manière modulaire. Chaque provider cible dispose de son propre module, appelé en fonction du champ `provider`.

Le code est structuré de façon à isoler complètement la logique liée au réseau (réseaux Docker ou sous-infra cloud) . Chaque client peut avoir son propre réseau logique, préconfiguré avec un backend distinct, mais piloté via la même interface et les mêmes abstractions. Cela permet, entre autres, de planifier, créer ou détruire une topologie réseau indépendamment des services qui y seront rattachés. Le backend génère dynamiquement les fichiers Terraform `.tfvars.json` liés à ces réseaux, et les place dans un espace S3 séparé, ce qui permet de versionner et réutiliser des couches réseau par client ou environnement.

L’exécution de chaque action (plan, apply, destroy) repose sur l'utilisation d’un répertoire de travail local, reconstruit à chaque appel à partir des fichiers présents sur S3. Cette approche garantit un comportement idempotent et évite les effets de bord dus à des états locaux persistés. Une instance d’exécution `OpenTofuCommand` est instanciée par couple `(clientId, serviceId)`, et encapsule l’environnement d’exécution (répertoire de code, répertoire de données, variables d’environnement spécifiques, etc.). La sortie standard et les erreurs sont capturées en flux, puis transmises au frontend via SSE, permettant un suivi sans polling.

L’architecture permet une composition dynamique à plusieurs niveaux. Du point de vue du frontend, le catalogue des services est défini entièrement dans un fichier JSON qui spécifie, pour chaque item, un template de configuration. Ces templates sont des fichiers `*.template.tfvars.json` versionnés dans S3 et pouvant être personnalisés par l’utilisateur. Cette conception rend le système extensible sans redéploiement, ni changement de code : pour ajouter un service, il suffit d’ajouter un fichier de template et une entrée JSON.

L'application entière est conçue comme un service déclaratif — y compris elle-même. Le backend de SpawnIt peut être lancé comme n’importe quel autre service à l’aide de son propre module Terraform, qui provisionne une machine EC2, injecte un script `user_data` via le provider AWS, et exécute dans cette machine un conteneur Docker contenant l’application. Cette capacité à s’auto-instancier permet de valider que l’architecture déclarative tient même pour l’orchestrateur lui-même. Le code ne fait pas de distinction entre “SpawnIt” et “un service quelconque” ; seul le template de départ diffère.

Il y a aussi un découplage entre les étapes de génération de configuration, de provisioning réseau, de déploiement de service, et de supervision. Par exemple, lorsqu’un `tofu plan` est lancé sur un service, le backend commence par valider que le réseau déclaré par ce service est existant et conforme. Cette vérification passe par un `plan` sur le module réseau correspondant. Si le réseau est manquant ou divergent, l’opération est interrompue. Cette étape impose une cohérence topologique sans centraliser ni synchroniser l’état entre composants — tout est dérivé du contenu de S3, qui fait foi.

Enfin, le backend conserve une table mémoire des jobs en cours, identifiés par UUID, ce qui permet une annulation d’un processus en cas de timeout ou d’interruption utilisateur. De même, un service peut être surveillé par une boucle de planification (plan loop) exécutée à intervalle régulier. Ce mécanisme permet d’assurer un niveau minimal de détection de dérive sans infrastructure supplémentaire.

Le système est donc entièrement modulaire (chaque service, chaque client, chaque couche réseau est isolée), entièrement déclaratif (toutes les actions passent par un fichier `*.tfvars.json` et un appel OpenTofu), et entièrement pilotable via un backend minimaliste et stateless. Cette architecture permet de reproduire des environnements complexes avec peu de dépendances techniques.

## 4. Workflow

Le fonctionnement de SpawnIt utilise un enchaînement d’étapes gérées par le backend, avec une séparation entre les phases de génération de configuration, de provisioning, et de supervision. L’ensemble du système est gérée via une API ou chaque endpoint déclenche des actions Terraform en local, sur la base de fichiers centralisés dans S3.

### 4.1 Génération de configuration et persistance dans S3

Tous les services deployables sont basés sur des templates JSON prééxistants. Lorsqu’un utilisateur choisit un service à déployer et renseigne ses paramètres dans l’interface, ces informations sont envoyées au backend. Le backend les encapsule dans une structure standardisée conforme au schéma d’entrée des modules Terraform. Il ajoute dynamiquement des valeurs et sérialise l’ensemble dans un fichier `terraform.tfvars.json`. Ce fichier est ensuite stocké sur S3 dans un chemin déterministe de la forme `clients/{clientId}/{serviceId}/terraform.tfvars.json`.

Cette étape ne déclenche aucun déploiement. Elle sert uniquement à constituer une base déclarative persistée, qui pourra ensuite être appliquée ou modifiée. Le backend ne conserve aucun état local. Toutes les informations sont reconstruites à partir des fichiers distants, ce qui permet de redémarrer le backend à tout moment sans perte d’état.

### 4.2 Préparation du répertoire de travail

Pour chaque opération Terraform (`plan`, `apply`, `destroy`), le backend crée à la volée un répertoire de travail sous `./workdirs/{clientId}/{serviceId}/`. Il y télécharge depuis S3 tous les fichiers associés (variables et état). La logique d’initialisation est encapsulée dans une instance `OpenTofuCommand`, qui passe le contexte `(clientId, serviceId)`.

Avant chaque exécution, cette instance appelle `tofu init` avec les bons paramètres backend (bucket, chemin du fichier d’état, région, endpoint MinIO ou AWS, etc.), en injectant ces informations via des variables d’environnement. Cette initialisation est faite à froid pour chaque exécution, sauf si elle a déjà été faite dans le contexte courant. Elle est donc idempotente, mais évite les recharges inutiles.

### 4.3 Validation du réseau

Avant de lancer un plan sur un service, le backend vérifie que la couche réseau associée est existante et conforme. Il le fait en lançant un plan sur le module réseau du provider spécifié (`network/local` ou `network/aws`) avec son propre fichier de variables. Si le plan indique une divergence, ou si le fichier de configuration est manquant, l’opération principale est bloquée.

Cette validation réseau est déduite dynamiquement à partir des paramètres du service (`provider` et `network_name`), ce qui permet à deux services d’un même client de partager une même couche réseau tout en étant déployés indépendamment.

### 4.4 Planification, application et destruction

Une fois le répertoire de travail prêt et le réseau validé, le backend lance la commande `tofu plan`. La sortie de cette commande est capturée en flux et transmise au client via SSE. Le backend analyse également cette sortie pour en déduire un statut formel : "compliant" (aucune modification à prévoir), "drifted" (modifications planifiées), ou "error" (exécution échouée).

Si l’utilisateur confirme le plan, la commande `tofu apply` est déclenchée. Elle suit le même mécanisme que `plan` : création d’un processus local, capture de la sortie, transmission par SSE. L’apply est exécuté avec l’option `-auto-approve` pour garantir l’absence d’interaction.

La destruction (`tofu destroy`) suit le même schéma et est toujours précédée d’un plan implicite pour vérifier l’état du service à supprimer. Le backend ne fait pas de nettoyage automatique des répertoires de travail, mais ceux-ci peuvent être supprimés sans conséquence, puisque l’état est toujours sauvegardé dans S3.

### 4.5 Supervision continue

SpawnIt utilise une boucle de planification continue sur tous les services. Un `setInterval` exécute toutes les 10 secondes un `plan` sur le service ciblé. Le résultat est envoyé aux clients connectés. Cette fonctionnalité est utile pour détecter des dérives manuelles (modifications de conteneurs ou d’instances en dehors de SpawnIt), sans avoir besoin d’un agent sur la machine cible.

### 4.6 Annulation et gestion des jobs

Chaque exécution de `apply`, `destroy` ou `plan` est associée à un UUID et conservée dans une table en mémoire. Cela permet à l’utilisateur d’annuler un job en cours via une requête dédiée, ce qui envoie un `SIGTERM` au processus sous-jacent. En cas de plantage du backend, cette table est perdue, mais comme les processus sont exécutés localement et encapsulés, les effets secondaires sont limités. Les jobs terminés sont automatiquement retirés de la table.



### 5. **Discussion et Limites**

- Ce qui marche bien :
  - Modularité poussée
  - Extension facile du catalogue
  - Auto-hébergement = démonstration technique
- Limites :
  - Pas encore d’authentification multi-utilisateur
  - Pas de persistance hors S3
  - Sensible aux erreurs de config



### 6. **Conclusion**

- Bilan du projet
- Ce que le paradigme déclaratif a permis de réaliser
- Ouvertures possibles :
  - Ajouter des providers (Kubernetes ? Azure ?)
  - Générer dynamiquement les templates
  - Ajout de monitoring post-déploiement