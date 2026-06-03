# Les 05 - CI/CD, Terraform en Ansible

## Inleiding

Deze repository bevat de uitwerking van les 05. In deze week is gewerkt met CI/CD, Terraform, Ansible, Azure en een lokale GitHub self-hosted runner.

De opdrachten bouwen op elkaar voort. Eerst is een Azure VM uitgerold en geconfigureerd met Ansible. Daarna is een CI/CD-pipeline ingericht met een lokale runner. Vervolgens is Terraform via GitHub Actions automatisch uitgevoerd. Tot slot is uitgewerkt hoe CI/CD toegepast kan worden binnen mijn eigen werkomgeving.

De focus ligt op het automatiseren van infrastructuur en configuratie op een reproduceerbare, veilige en controleerbare manier.

## Gebruikte technieken

Tijdens deze week zijn onder andere de volgende technieken gebruikt:

* Terraform
* Ansible
* Azure
* Azure CLI
* Azure dynamic inventory
* GitHub Actions
* GitHub self-hosted runner
* GitHub Actions Secrets
* GitHub Actions Variables
* Azure Storage remote backend
* Python virtual environment
* SSH-key authenticatie
* Cloud-init

## Repositorystructuur

De opdrachten zijn onderverdeeld per map:

```text
les-05-v2/
├── opdracht-1/
│   ├── README.md
│   ├── terraform/
│   └── ansible/
├── opdracht-2/
│   ├── README.md
│   ├── inventory.azure_rm.yml
│   ├── playbook.yml
│   ├── group_vars/
│   └── install_packages/
├── opdracht-3/
│   ├── README.md
│   └── terraform/
└── opdracht-4/
    └── README.md
```

De GitHub Actions workflows staan in:

```text
.github/workflows/
├── les-05-opdracht-2.yml
├── les-05-opdracht-3-terraform.yml
└── les-05-opdracht-3-destroy.yml
```

## Opdracht 1 - Azure VM uitrollen en configureren met Ansible

In opdracht 1 is een Azure VM uitgerold met Terraform. Daarna is Ansible gebruikt om de VM te configureren als webserver.

Terraform maakt de benodigde infrastructuur aan:

* Public IP-adres
* Network Interface
* Ubuntu Linux Virtual Machine
* Cloud-init configuratie
* Ansible inventory

Ansible wordt daarna gebruikt om `apache2` te installeren. Dit gebeurt bewust zonder de Ansible `apt` module, omdat dit onderdeel is van de opdracht. Hiervoor wordt de `command` module gebruikt met `apt-get install`.

De Ansible-configuratie is uitgewerkt in een role-structuur met onder andere:

* `tasks`
* `handlers`
* `meta`
* `templates`

Daarnaast is een bewuste foutieve taak toegevoegd, zodat zichtbaar wordt dat Ansible een fout netjes toont in de uitvoer.

Meer informatie staat in:

```text
les-05-v2/opdracht-1/README.md
```

## Opdracht 2 - CI/CD met Ansible en een lokale GitHub Runner

In opdracht 2 is gebruikgemaakt van de lokale GitHub self-hosted runner. Deze runner voert een GitHub Actions workflow uit waarmee een Ansible playbook automatisch draait.

De opdracht maakt gebruik van Azure dynamic inventory. Hierdoor wordt geen statisch inventorybestand in Git opgeslagen. Ansible haalt de VM rechtstreeks op uit Azure op basis van tags.

De Azure VM is bijvoorbeeld getagd met:

```text
project = les-05
role    = webserver
```

Met `keyed_groups` wordt hiervan automatisch een Ansible-groep gemaakt:

```text
role_webserver
```

De verbindingsinstellingen staan in:

```text
group_vars/role_webserver.yml
```

De workflow bestaat uit twee stappen:

1. Syntax-check van het Ansible playbook.
2. Uitvoeren van het playbook op de Azure VM.

De workflow draait automatisch bij wijzigingen in opdracht 2 en kan ook handmatig worden gestart via `workflow_dispatch`.

Meer informatie staat in:

```text
les-05-v2/opdracht-2/README.md
```

## Opdracht 3 - Terraform CI/CD met automatische apply en handmatige destroy

In opdracht 3 is een Terraform CI/CD-pipeline gemaakt met GitHub Actions. De pipeline draait op de lokale self-hosted runner.

De workflow wordt automatisch gestart wanneer Terraform-bestanden in opdracht 3 worden aangepast. De workflow voert de volgende controles uit:

```text
terraform fmt -check -recursive
terraform init -reconfigure -input=false
terraform validate
terraform plan -input=false
```

Als deze controles succesvol zijn, wordt de infrastructuur automatisch uitgerold met:

```text
terraform apply -auto-approve -input=false
```

Voor het verwijderen van infrastructuur is een aparte workflow gemaakt. Deze destroy workflow draait niet automatisch, maar alleen handmatig via GitHub Actions.

Hierdoor wordt voorkomen dat infrastructuur per ongeluk verwijderd wordt bij een normale push.

De Terraform state wordt opgeslagen in een Azure Storage remote backend. De benodigde Terraform-variabelen worden in de workflow meegegeven via `TF_VAR_...`.

Daarbij is onderscheid gemaakt tussen GitHub Actions Variables en Secrets.

Algemene configuratie staat in Variables, zoals:

```text
AZURE_LOCATION
AZURE_VM_SIZE
AZURE_VM_NAME
```

Gevoeligere of omgevingsspecifieke waarden staan in Secrets, zoals:

```text
AZURE_SUBSCRIPTION_ID
AZURE_RESOURCE_GROUP_NAME
AZURE_VIRTUAL_NETWORK_NAME
AZURE_SUBNET_NAME
AZURE_ADMIN_USERNAME
AZURE_SSH_PUBLIC_KEY
```

Meer informatie staat in:

```text
les-05-v2/opdracht-3/README.md
```

## Opdracht 4 - Toepassing van CI/CD in mijn eigen werk

In opdracht 4 is uitgewerkt hoe CI/CD toegepast kan worden binnen mijn eigen werkomgeving.

Ik werk in een organisatie die IT-infrastructuur beheert voor klanten. Deze klantomgevingen zijn vooral Microsoft-gebaseerd en bestaan uit zowel on-premises als cloudomgevingen.

CI/CD kan in deze context worden ingezet voor onder andere:

* Uitrollen van Azure-infrastructuur.
* Configureren van Windows Servers.
* Installeren van monitoring agents.
* Inrichten van fileservers.
* Beheren van Microsoft 365- en Entra ID-configuratie.
* Uitvoeren van gecontroleerde wijzigingen met logging en review.

Belangrijke aandachtspunten hierbij zijn:

* Secrets veilig opslaan.
* Runners goed beveiligen.
* Least privilege toepassen.
* Test- en productieomgevingen scheiden.
* Wijzigingen laten controleren via pull requests.
* Productiewijzigingen eventueel handmatig laten goedkeuren.

Meer informatie staat in:

```text
les-05-v2/opdracht-4/README.md
```

## Self-hosted GitHub Runner

Voor de opdrachten is gebruikgemaakt van een lokale self-hosted GitHub Runner. Deze runner draait op de jumphost en heeft toegang tot de benodigde tools en omgevingen.

De runner is gebruikt omdat:

* De opdracht hier expliciet om vraagt.
* De runner toegang heeft tot de beheeromgeving.
* Terraform en Ansible lokaal op de jumphost beschikbaar zijn.
* Azure CLI-login beschikbaar is op de runner.
* Workflows gecontroleerd kunnen worden uitgevoerd vanuit de eigen omgeving.

De runner wordt gebruikt door de workflows in opdracht 2 en opdracht 3.

## Secrets en variabelen

Er is bewust gekozen om geen echte `terraform.tfvars` bestanden in Git te plaatsen. In plaats daarvan worden voorbeeldbestanden gebruikt, zoals:

```text
terraform.tfvars.example
```

Voor CI/CD worden waarden meegegeven via GitHub Actions Secrets en Variables. Terraform leest deze automatisch via environment variables met het patroon:

```text
TF_VAR_<variabelenaam>
```

Dit voorkomt dat de workflow interactief om waarden vraagt en zorgt ervoor dat gevoelige of omgevingsspecifieke informatie niet in de repository staat.

## Remote Terraform state

Voor Terraform wordt gebruikgemaakt van remote state in Azure Storage. Hierdoor staat de state niet lokaal in de repository.

Voordelen hiervan zijn:

* State wordt centraal opgeslagen.
* De runner kan dezelfde state gebruiken.
* State-bestanden worden niet per ongeluk naar Git gepusht.
* Infrastructuur kan reproduceerbaar worden beheerd.

Elke opdracht gebruikt een eigen state-key, zodat de state van opdrachten gescheiden blijft.

## Best practices die zijn toegepast

Tijdens deze week zijn verschillende best practices toegepast:

* Geen echte secrets in Git.
* Geen echte `terraform.tfvars` in Git.
* Gebruik van `terraform.tfvars.example`.
* Gebruik van remote Terraform state.
* Gebruik van SSH-key authenticatie.
* Gebruik van Ansible roles.
* Gebruik van Azure-tags voor dynamic inventory.
* Gebruik van een self-hosted runner.
* Workflows draaien alleen bij relevante wijzigingen.
* Destroy is gescheiden in een handmatige workflow.
* Gebruik van `terraform fmt -check`.
* Gebruik van `terraform validate`.
* Gebruik van `-input=false` in CI/CD.
* Gebruik van GitHub Actions Secrets en Variables.
* Gebruik van een Python virtual environment voor Ansible Azure dependencies.

## Belangrijke leerpunten

Tijdens deze opdrachten zijn de volgende leerpunten naar voren gekomen:

* CI/CD is niet alleen nuttig voor applicaties, maar ook voor infrastructuurbeheer.
* Terraform en Ansible vullen elkaar goed aan.
* Een self-hosted runner is handig wanneer een workflow toegang nodig heeft tot interne of beheerde omgevingen.
* Dynamic inventory voorkomt dat statische inventorybestanden handmatig beheerd moeten worden.
* Terraform pipelines moeten non-interactief zijn.
* Gevoelige waarden horen niet in Git.
* Destroy-acties moeten bewust en gecontroleerd worden uitgevoerd.
* Een duidelijke scheiding tussen test, deploy en destroy maakt een pipeline veiliger.

## Conclusie

Les 05 laat zien hoe CI/CD kan worden toegepast op infrastructuur en configuratiebeheer. Door Terraform, Ansible, Azure en GitHub Actions te combineren, kunnen omgevingen automatisch worden uitgerold en beheerd.

De opdrachten tonen verschillende onderdelen van een professionele automatiseringsaanpak:

* Infrastructuur uitrollen met Terraform.
* Servers configureren met Ansible.
* CI/CD uitvoeren via een self-hosted runner.
* Azure gebruiken als bron van waarheid.
* Terraform-code automatisch controleren.
* Infrastructuur gecontroleerd verwijderen via een handmatige workflow.
* CI/CD toepassen op een realistische werkomgeving.

Deze aanpak sluit goed aan bij professioneel infrastructuurbeheer, vooral binnen organisaties die klantomgevingen beheren en terugkerende werkzaamheden willen standaardiseren.
