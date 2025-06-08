### 1. **Introduction**

- Objectif du projet : permettre le déploiement de services cloud ou locaux de manière automatisée.
- Motivation : rendre accessible la gestion d’infrastructure via une interface simple.
- Hypothèse centrale : *"Le paradigme déclaratif permet une abstraction puissante et reproductible du déploiement de services."*
- Bref aperçu de l’approche technique : OpenTofu, S3, Docker, EC2, etc.



### 2. **Contexte et Choix Technologiques**

- **Pourquoi le paradigme déclaratif** ?
  - Comparaison rapide avec l’impératif
  - Avantages : simplicité, idempotence, auditabilité
- **Pourquoi OpenTofu ?**
  - Continuateur open source de Terraform
  - Intégration facile avec S3, AWS, Docker
- **Autres technologies clés** :
  - Node.js + Express
  - S3 (MinIO ou AWS)
  - Docker (local) et EC2 (cloud)
  - Frontend (brièvement)



### 3. **Architecture Globale**



#### 3.1 Vue d'ensemble du système

- Diagramme global Backend ↔ Frontend ↔ S3
- Explication des rôles de chaque composant
- Communication via REST et SSE



#### 3.2 Infrastructure locale (Docker)

- Structure des conteneurs
- Où tourne quoi ?
- Lancement des services via modules OpenTofu



#### 3.3 Auto-hébergement : "Eat your own dog food"

- Le backend de SpawnIt peut se déployer lui-même
- Diagramme "recursif"
- Pourquoi ce choix est pertinent et cohérent avec l'approche déclarative



#### 3.4 Déploiement de services (local vs AWS)

- Explication des deux chemins :
  - Local → Docker
  - Cloud → EC2 avec Docker via `user_data`
- Diagramme comparatif ou flowchart



### 4. **Fonctionnement détaillé**



#### 4.1 Chargement des templates

- JSON de `catalog.json`
- Endpoint `/catalog` et logique d'affichage



#### 4.2 Génération de la configuration

- Upload des `terraform.tfvars.json` vers S3
- Création d’un répertoire de travail local



#### 4.3 Boucle de planification continue (`tofu plan`)

- Mise à jour en temps réel via SSE
- Vérification de l’état ("compliant", "drifted", etc.)



#### 4.4 Application ou destruction

- `tofu apply`, `tofu destroy`
- Exécution isolée par client/service
- Gestion des jobs avec UUID



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