
# client infrastructure

## À propos

client infrastructure décrit par le code un aspect de l'infrastructure à provisionner pour __PROJECT.

## Table des matières

- 🪧 [À propos](#à-propos)
- 📦 [Prérequis](#prérequis)
- 🚀 [Installation](#installation)
- 🛠️ [Utilisation Locale](#utilisation-locale)
- 🤝 [Contribution](#contribution)
- 🏗️ [Construit avec](#construit-avec)
- 📝 [Licence](#licence)

## Prérequis

- [Docker](https://www.docker.com/) ou [Terraform CLI](https://www.terraform.io/cli)

## Installation

La commande suivante permet d'utiliser la ligne de commande terraform via Docker :
```shell
docker run --rm -it --name terraform -v ~/:/root/ -v $(pwd):/workspace -w /workspace hashicorp/terraform:light
```

Pour une utilisation simplifiée, il est possible de créer un alias :
```shell
alias terraform='docker run --rm -it --name terraform -v ~/:/root/ -v $(pwd):/workspace -w /workspace hashicorp/terraform:light'
```

Avec cet alias, il n'y a plus de différence entre une commande terraform exécutée avec Docker ou avec Terraform CLI.

## Utilisation Locale

<details>
<summary><b>Cliquez pour afficher les commandes</b></summary>

### Vérifier et corriger la syntaxe des fichiers `.tf`

```shell
terraform fmt --recursive
```

### Vérifier la cohérence de l'infrastructure

```shell
terraform validate
```

### Récupérer un jeton d'authentification à Terraform Cloud en local

```shell
terraform login
```

### Initialiser l'état et les plugins en local

```shell
terraform init
```

### Planifier une exécution pour voir les différences avec l'état précédent de l'infrastructure

```shell
terraform plan
```

</details>


## Contribution

### Appliquer la mise à jour de l'infrastructure

Pour que les modifications de la description de l'infrastructure soient appliquées en production, il suffit de publier les changements sur la branche `main`.

## Construit avec

### Langages & Frameworks

- [Terraform](https://www.terraform.io/) est un outil de description d'infrastructure par le code qui permet de créer et de maintenir une infrastructure de manière sûre et prévisible.

### Outils

#### CI

- [Github Actions](https://docs.github.com/en/actions) est l'outil d'intégration et de déploiement continu intégré à GitHub
    - L'historique des déploiements est disponible [sous l'onglet Actions](https://github.com/__ORGANIZATION/__REPOSITORY/actions/)
- Secrets du dépôt :
    - `TF_API_TOKEN` : Le token d'api Terraform Cloud qui permet à la CI d'opérer des actions sur Terraform Cloud
      - Provisionné par le organization.deployer du compte AWS parent de l'organization

#### Déploiement

- [AWS](https://aws.amazon.com/) est la plateforme de services Cloud proposée par Amazon.
    - Utilisateur : `__PROJECT.client.infrastructure`
    - Groupe : `client.deployer`
- [Terraform Cloud](https://app.terraform.io/) est la plateforme proposée par HashiCorp pour administrer les modifications d'infrastructure
    - Organisation : [__ORGANIZATION](https://app.terraform.io/app/__ORGANIZATION/workspaces)
    - Workspaces : `client`
        - [client](https://app.terraform.io/app/__ORGANIZATION/workspaces/client)
    - Variables
        - `AWS_SECRET_ACCESS_KEY`
            - Value : Sensitive - write only
            - Category : env
            - Provisionnée par le iam.deployer du compte AWS
          
        - `AWS_ACCESS_KEY_ID`
            - Value : Sensitive - write only
            - Category : env
            - Provisionnée par le iam.deployer du compte AWS

## Licence

Voir le fichier [LICENSE.md](./LICENSE.md) du dépôt.
