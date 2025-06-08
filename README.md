# Projet SpawnIt

**Auteurs : ** Massimo Stefani et Timothée Van Hove

## 1. **Introduction**

Le projet SpawnIt propose une plateforme web permettant de déployer des services complets en un clic, qu’ils soient exécutés localement (via Docker) ou dans le cloud (via AWS EC2). Pour répondre à cette ambition, nous avons fait le choix d’une approche déclarative, en nous appuyant sur OpenTofu, un moteur d’orchestration d’infrastructure issu de Terraform. Cette approche repose sur le principe : *"décrire ce que l’on souhaite obtenir, plutôt que comment y parvenir."*

SpawnIt permet à l’utilisateur de choisir un service (base de données, serveur de jeu, plateforme DevOps, etc.), de personnaliser sa configuration, puis de déclencher son déploiement. En arrière-plan, l’application génère automatiquement les fichiers de configuration nécessaires, les stocke dans un système de fichiers objet (S3), et exécute les commandes OpenTofu pour créer ou détruire l’infrastructure demandée.

Le projet utilise les bénéfices d’une IaC intégrée dans une interface simple, avec l'objectif de rendre le déploiement de services accessible et rapide. Nous avons poussé l'idée encore plus loin, car le projet peut se déployer lui-même, ce qui montre une forme d’auto-hébergement rendue possible grâce à sa propre architecture déclarative.



## 2. Contexte

Le déploiement d’infrastructure a longtemps reposé sur des approches impératives, où chaque étape est explicitement codée. Ce type de logique, est difficile à maintenir à grande échelle, car chaque détail de l’exécution doit être anticipé et géré. Le paradigme déclaratif repose sur une l'idée de décrire l’état final souhaité, et laisser à un moteur spécialisé le soin de converger vers cet état. Cette approche permet de garantir l'idempotence, car exécuter plusieurs fois la même configuration n’a pas d’effet secondaire.

Nous avons retenu OpenTofu, un moteur d’infrastructure open-source issu du projet Terraform. Contrairement à Terraform, OpenTofu conserve une licence ouverte et bénéficie du soutien de la Linux Foundation. OpenTofu permet de décrire des infrastructures sous forme de fichiers `.tf` et de piloter leur mise en place avec des commandes simples (`init`, `plan`, `apply`, `destroy`). Il s’intègre facilement avec :

- des providers **Docker** (pour déployer localement),
- des providers **AWS** (pour déployer sur le cloud),
- et des backends **S3** (pour stocker l’état de l’infrastructure).

### 3. Choix Technologiques

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

## 4. Architecture

L’architecture repose sur un découplage entre la présentation, la logique d’orchestration, et l’infrastructure cible. Elle est conçue de manière modulaire et stateless, avec une exécution conteneurisée, un backend unique pilotant OpenTofu, et un stockage persistant via S3. Le backend agit comme point de convergence, en orchestrant toutes les interactions entre les autres composants.

<img src="C:\Users\timot\Documents\HEIG\PLM\infra\doc\img\containers.png" style="zoom:50%;" />

**Backend**

Le backend est une application Node.js conteneurisée, qui expose une API REST et un canal Server-Sent Events (SSE). Il encapsule également l’exécution locale de commandes OpenTofu. Il ne maintient aucun état en mémoire, tout est lu et écrit depuis S3.

Chaque exécution de `tofu` est isolée dans un répertoire temporaire reconstruit à la volée à partir des fichiers distants. Cette approche garantit un découplage fort entre l’interface, les configurations utilisateur, et l’infrastructure sous-jacente. Le backend peut donc gérer plusieurs clients, services et environnements sans collisions ni état partagé.

**Frontend**

Le frontend est une application web statique, déployée dans un conteneur Docker distinct. Il ne contient aucune logique métier et ne connaît ni la structure des fichiers Terraform ni l’infrastructure cible. Il interagit exclusivement avec l’API backend. Cette séparation garantit une portabilité totale et une indépendance vis-à-vis du moteur d’infrastructure. L’interface est dynamique : elle charge le catalogue des services, récupère les templates associés, construit dynamiquement les formulaires, et suit l’exécution des plans en temps réel via SSE.

**OpenTofu (moteur d’infrastructure)**

OpenTofu est intégré dans le conteneur backend. Il est déclenché par des sous-processus Node.js. Aucun plugin externe ou wrapper n’est utilisé. L’architecture est pensée pour que le backend soit agnostique du provider Terraform sous-jacent : que l’on déploie sur Docker ou AWS, la logique backend reste la même. Les modules Terraform sont organisés en sous-modules, chacun exposant une interface identique côté variable.

Cette structure permet l’extension vers d’autres providers triviale : il suffit d’ajouter un module avec les bonnes conventions, aucun changement n’est requis côté backend ou frontend.

**S3 (MinIO)**

Le stockage des fichiers est entièrement externalisé sur un backend S3-compatible. Tous les artefacts sont sérialisés et organisés sous la forme :

```
clients/
  └── <client_id>/
        ├── <service_id>/terraform.tfvars.json
        ├── <service_id>/terraform.tfstate
        └── network/<provider>/...
templates/
  └── *.template.tfvars.json
```

## 5. Déploiement

Le déploiement de l’application repose sur des scripts shell qui encapsulent chacun une étape du provisioning. Ces scripts n’exécutent pas des commandes Docker, mais appellent systématiquement OpenTofu avec les fichiers de configuration appropriés. Chaque brique de l’application (volumes, réseau, conteneurs, configuration) est décrite de façon déclarative, dans des modules Terraform versionnés localement.

Le script `all-deploy.sh` est le point d’entrée principal. Il déclenche successivement quatre sous-scripts. Chacun d'eux appelle `tofu init` et `tofu apply` sur le module Terraform correspondant, dans un répertoire de travail isolé, en injectant les variables d’environnement nécessaires (en particulier celles liées à l’hôte ou au provider). Cette structure permet une réutilisabilité complète : chaque étape peut être rejouée indépendamment, ou intégrée dans un pipeline CI.

- Le script `volumes-deploy.sh` crée les volumes Docker persistants nécessaires à certains services (MinIO, bases de données)
- Le script `network-deploy.sh` crée le réseau Docker auquel tous les conteneurs applicatifs seront connectés.
- Le script `instances-deploy.sh` déclare les conteneurs de l’application (S3, Backend, Frontend, Keycloak) en utilisant le provider Docker.
- Enfin, `configs-deploy.sh` applique des modules supplémentaires pour injecter des configurations spécifiques dans les services lancés, par exemple la création de buckets dans MinIO ou l’initialisation d’un realm Keycloak.

Chacune de ces étapes est décrite de façon purement déclarative, dans des fichiers `main.tf` et `terraform.tfvars.json` propres à chaque module. Les modules .tf sont réutilisables : ils utilisent les mêmes interfaces (`var.instance`, `var.provider`, ... que les services déployés par l’interface web.

C’est là l’un des aspects les plus intéressants de cette architecture : le déploiement de SpawnIt lui-même est réalisé en appliquant exactement la même logique que celle utilisée pour déployer n’importe quel service depuis l’interface web. Les modules, les scripts, la structure des variables et le moteur d’exécution sont identiques. En d’autres termes, l’application se déploie avec les mêmes mécanismes qu’elle met à disposition de ses utilisateurs.

<img src="doc/img/deploy.png" style="zoom:50%;" />



## 6. Workflow

SpawnIt utilise un enchaînement d’étapes gérées par le backend, avec une séparation entre les phases de génération de configuration, de provisioning, et de supervision. L’ensemble du système est gérée via une API ou chaque endpoint déclenche des actions Terraform en local, sur la base de fichiers centralisés dans S3.

**Génération de configuration et persistance dans S3**

Tous les services deployables sont basés sur des templates JSON prééxistants. Lorsqu’un utilisateur choisit un service à déployer et renseigne ses paramètres dans l’interface, ces informations sont envoyées au backend. Le backend les encapsule dans une structure standardisée conforme au schéma d’entrée des modules Terraform. Il ajoute dynamiquement des valeurs et sérialise l’ensemble dans un fichier `terraform.tfvars.json`. Ce fichier est ensuite stocké sur S3.

Cette étape ne déclenche aucun déploiement. Elle sert uniquement à constituer une base déclarative persistée, qui pourra ensuite être appliquée ou modifiée. Le backend ne conserve aucun état local. Toutes les informations sont reconstruites à partir des fichiers distants, ce qui permet de redémarrer le backend à tout moment sans perte d’état.

<img src="C:\Users\timot\Documents\HEIG\PLM\infra\doc\img\config.png" style="zoom:50%;" />

**Préparation du répertoire de travail**

Pour chaque opération Terraform (`plan`, `apply`, `destroy`), le backend crée à la volée un répertoire de travail sous `./workdirs/{clientId}/{serviceId}/`. Il y télécharge depuis S3 tous les fichiers associés (variables et état). La logique d’initialisation est encapsulée dans une instance `OpenTofuCommand`, qui passe le contexte `(clientId, serviceId)`.

Avant chaque exécution, cette instance appelle `tofu init` avec les bons paramètres backend (bucket, chemin du fichier d’état, région, endpoint MinIO ou AWS, etc.), en injectant ces informations via des variables d’environnement. Cette initialisation est faite à froid pour chaque exécution, sauf si elle a déjà été faite dans le contexte courant. Elle est donc idempotente, mais évite les recharges inutiles.

<img src="C:\Users\timot\Documents\HEIG\PLM\infra\doc\img\workdir.png" style="zoom:50%;" />

**Validation, planification, application et destruction**

Avant de lancer un plan sur un service, le backend vérifie que la couche réseau associée est existante et conforme. Il le fait en lançant un plan sur le module réseau du provider spécifié (`network/local` ou `network/aws`) avec son propre fichier de variables. Si le plan indique une divergence, ou si le fichier de configuration est manquant, l’opération principale est bloquée. Cette validation réseau est déduite dynamiquement à partir des paramètres du service (`provider` et `network_name`), ce qui permet à deux services d’un même client de partager une même couche réseau tout en étant déployés indépendamment.

Une fois le répertoire de travail prêt et le réseau validé, le backend lance la commande `tofu plan`. La sortie de cette commande est capturée en flux et transmise au client via SSE. Le backend analyse également cette sortie pour en déduire un statut formel : "compliant" (aucune modification à prévoir), "drifted" (modifications planifiées), ou "error" (exécution échouée).

Si l’utilisateur confirme le plan, la commande `tofu apply` est déclenchée. Elle suit le même mécanisme que `plan` : création d’un processus local, capture de la sortie, transmission par SSE. L’apply est exécuté avec l’option `-auto-approve` pour garantir l’absence d’interaction.

La destruction (`tofu destroy`) suit le même schéma et est toujours précédée d’un plan implicite pour vérifier l’état du service à supprimer. Le backend ne fait pas de nettoyage automatique des répertoires de travail, mais ceux-ci peuvent être supprimés sans conséquence, puisque l’état est toujours sauvegardé dans S3.

<img src="C:\Users\timot\Documents\HEIG\PLM\infra\doc\img\plan.png" style="zoom:50%;" />

**Supervision et gestion des jobs**

SpawnIt utilise une boucle de planification continue sur tous les services. Un `setInterval` exécute toutes les 10 secondes un `plan` sur le service ciblé. Le résultat est envoyé aux clients connectés. Cette fonctionnalité est utile pour détecter des dérives manuelles (modifications de conteneurs ou d’instances en dehors de SpawnIt), sans avoir besoin d’un agent sur la machine cible.

Chaque exécution de `apply`, `destroy` ou `plan` est associée à un UUID et conservée dans une table en mémoire. Cela permet à l’utilisateur d’annuler un job en cours via une requête dédiée, ce qui envoie un `SIGTERM` au processus sous-jacent. En cas de plantage du backend, cette table est perdue, mais comme les processus sont exécutés localement et encapsulés, les effets secondaires sont limités. Les jobs terminés sont automatiquement retirés de la table.



## 7. Discussion et limites

Notre architecture modulaire permet à chaque composant, que ce soit le backend, les modules Terraform, ou les scripts de déploiement d'être facilement réutilisables et extensibles. Le modèle de configuration utilisant les templates et les variables rend l’extension du catalogue de services extrêmement simple. L’ajout d’un nouveau service ne nécessite aucune modification du backend ni du frontend : il suffit de déposer un nouveau fichier template et de l’enregistrer dans le fichier `catalog.json`. Le fait que l'application soit auto-déployable est une preuve de cohérence. Cette boucle fermée illustre bien l’intention initiale du projet de tirer parti de l'interface déclarative pour la gestion d’infrastructure.

Certaines limitations subsistent. La persistance de l’état repose sur le backend S3. Si ce dernier devient indisponible, l’application devient inutilisable, car le backend ne conserve aucun cache local. Ce choix est volontaire (stateless complet), mais introduit une dépendance forte à la disponibilité de S3. Enfin, l’expérience utilisateur peut être altérée en cas d’erreurs de configuration. L’application ne valide pas de manière exhaustive les champs du formulaire utilisateur, ce qui peut provoquer des erreurs à l’exécution de Terraform difficiles à diagnostiquer pour un utilisateur non technique. Ce point pourrait être amélioré par une phase de pré-validation plus stricte côté backend.



## 8. **Conclusion**

Notre projet démontre qu’il est possible de proposer une interface de déploiement légère et déclarative, sans sacrifier la flexibilité ni l’extensibilité. L’approche déclarative a joué un grand rôle dans la structuration du projet. En isolant chaque étape du déploiement et en les décrivant comme des modules indépendants, l’architecture reste lisible, reproductible et facilement testable. Cette structure a également facilité la mise en place de l’auto-hébergement, qui démontre la cohérence du modèle choisi.

Plusieurs perspectives d’évolution sont identifiées. Il serait pertinent d’ajouter le support d’autres providers, tels que Kubernetes, Azure ou GCP, afin d’ouvrir SpawnIt à de nouveaux environnements.  Enfin, l’ajout d’un système de monitoring post-déploiement  même simple permettrait d’offrir un retour d’état en temps réel sans avoir à s’appuyer uniquement sur les plans Terraform.

SpawnIt est donc à la fois une interface de déploiement, une démonstration de l’intérêt du paradigme déclaratif, et une base solide pour expérimenter ou industrialiser des workflows d’orchestration d’infrastructure modernes.