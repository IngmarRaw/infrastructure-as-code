# Les 05 - Opdracht 3

## Doel van de opdracht

In deze opdracht wordt een Terraform CI/CD-pipeline ingericht met GitHub Actions en een lokale self-hosted runner. De pipeline rolt automatisch een eenvoudige Azure VM uit wanneer Terraform-bestanden worden aangepast. Daarnaast is er een aparte workflow gemaakt waarmee de infrastructuur alleen handmatig verwijderd kan worden.

De opdracht richt zich op CI/CD voor Infrastructure as Code:

* Terraform-code wordt automatisch gecontroleerd.
* Terraform-code wordt gevalideerd.
* Terraform maakt een plan.
* Terraform voert automatisch een apply uit.
* Destroy is gescheiden in een aparte handmatige workflow.
* De workflow draait alleen bij wijzigingen in Terraform-bestanden.

## Gebruikte technieken

Voor deze opdracht zijn de volgende technieken gebruikt:

* Terraform
* Azure
* Azure Storage remote backend
* GitHub Actions
* Self-hosted GitHub Runner
* GitHub Actions Variables
* GitHub Actions Secrets
* Cloud-init
* SSH-key authenticatie

## Mappenstructuur

De opdracht heeft de volgende structuur:

```text
opdracht-3/
└── terraform/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── backend.tf
    ├── cloudinit.tftpl
    └── terraform.tfvars.example
```

De workflows staan in:

```text
.github/workflows/les-05-opdracht-3-terraform.yml
.github/workflows/les-05-opdracht-3-destroy.yml
```

## Terraform

Terraform wordt gebruikt om een eenvoudige Ubuntu VM in Azure te deployen. De configuratie maakt onder andere de volgende resources aan:

* Public IP-adres
* Network Interface
* Ubuntu Linux Virtual Machine

De VM wordt aangemaakt met SSH-key authenticatie. Wachtwoordauthenticatie is uitgeschakeld.

## Remote backend

Voor deze opdracht wordt een Azure Storage backend gebruikt voor Terraform state. Hierdoor staat de Terraform state niet lokaal in de repository en kan de workflow dezelfde state gebruiken als de jumphost.

Voorbeeld van `backend.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "S1073133"
    storage_account_name = "ingmarrawstorage"
    container_name       = "tfstate"
    key                  = "les-05-opdracht-3.tfstate"
  }
}
```

De state-key is specifiek voor opdracht 3:

```text
les-05-opdracht-3.tfstate
```

Hierdoor blijft de state van opdracht 3 gescheiden van andere opdrachten.

## Variabelen

Er wordt geen echte `terraform.tfvars` naar Git gepusht. In Git staat alleen:

```text
terraform.tfvars.example
```

De workflow gebruikt `TF_VAR_...` environment variables om Terraform-variabelen automatisch te vullen. Hierdoor kan Terraform non-interactief draaien binnen GitHub Actions.

Voor lokale uitvoering kan op de jumphost een eigen `terraform.tfvars` bestand worden gebruikt. Dit bestand wordt genegeerd door Git en bevat de lokale waarden die nodig zijn om Terraform handmatig te testen.

## GitHub Actions Variables en Secrets

Voor de CI/CD-workflow is onderscheid gemaakt tussen algemene configuratie en gevoeligere waarden. Hierdoor blijft de repository schoon en worden omgevingsspecifieke waarden niet rechtstreeks in Git opgeslagen.

### GitHub Actions Variables

Algemene configuratie staat in GitHub Actions Variables:

```text
AZURE_LOCATION
AZURE_VM_SIZE
AZURE_VM_NAME
```

Deze waarden zijn niet gevoelig en bepalen algemene deploymentinstellingen.

### GitHub Actions Secrets

Omgevingsspecifieke of gevoeligere waarden staan in GitHub Actions Secrets:

```text
AZURE_SUBSCRIPTION_ID
AZURE_RESOURCE_GROUP_NAME
AZURE_VIRTUAL_NETWORK_NAME
AZURE_SUBNET_NAME
AZURE_ADMIN_USERNAME
AZURE_SSH_PUBLIC_KEY
```

Deze waarden worden door de workflow doorgegeven aan Terraform met `TF_VAR_...`.

Voorbeeld:

```yaml
env:
  TF_VAR_subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  TF_VAR_resource_group_name: ${{ secrets.AZURE_RESOURCE_GROUP_NAME }}
  TF_VAR_location: ${{ vars.AZURE_LOCATION }}
  TF_VAR_virtual_network_name: ${{ secrets.AZURE_VIRTUAL_NETWORK_NAME }}
  TF_VAR_subnet_name: ${{ secrets.AZURE_SUBNET_NAME }}
  TF_VAR_vm_name: ${{ vars.AZURE_VM_NAME }}
  TF_VAR_vm_size: ${{ vars.AZURE_VM_SIZE }}
  TF_VAR_admin_username: ${{ secrets.AZURE_ADMIN_USERNAME }}
  TF_VAR_ssh_public_key: ${{ secrets.AZURE_SSH_PUBLIC_KEY }}
```

Door deze aanpak hoeft er geen echte `terraform.tfvars` in Git te staan. De workflow kan toch volledig automatisch en non-interactief draaien.

## Mogelijke verbetering: Azure Key Vault

Voor deze opdracht is gekozen voor GitHub Actions Variables en Secrets. Dit is een praktische en nette oplossing binnen de scope van de opdracht, omdat er geen gevoelige of omgevingsspecifieke waarden in de repository worden opgeslagen.

In een enterprise-omgeving zou Azure Key Vault een nog professionelere oplossing zijn voor het beheren van gevoelige waarden. Secrets zoals SSH keys, service principal credentials, tokens en andere gevoelige configuratie kunnen dan centraal in Azure worden beheerd.

Een mogelijke enterprise-aanpak zou zijn:

```text
GitHub Actions self-hosted runner
        ↓
Azure-authenticatie
        ↓
Secrets ophalen uit Azure Key Vault
        ↓
TF_VAR_* environment variables zetten
        ↓
terraform plan / apply
```

Het voordeel van Azure Key Vault is dat secrets centraal beheerd, gecontroleerd en geroteerd kunnen worden. Daarnaast kan toegang worden geregeld via Microsoft Entra ID en Azure RBAC. Dit sluit beter aan bij professioneel beheer in Microsoft-gebaseerde omgevingen.

Voor deze opdracht is Azure Key Vault niet toegepast, omdat dit extra complexiteit toevoegt die niet noodzakelijk is voor de opdracht. GitHub Actions Secrets en Variables zijn in deze context voldoende, maar Azure Key Vault zou een logische vervolgstap zijn wanneer deze oplossing in een productie- of enterprise-omgeving gebruikt zou worden.

## SSH public key

In de workflow wordt niet verwezen naar een lokaal public-keybestand. In plaats daarvan wordt de inhoud van de public key als GitHub Secret meegegeven aan Terraform.

Hierdoor is de workflow niet afhankelijk van een lokaal bestandspad op de runner.

Lokaal kan Terraform nog steeds gebruikmaken van:

```hcl
ssh_public_key_path = "~/.ssh/id_ed25519.pub"
```

In de workflow wordt gebruikgemaakt van:

```hcl
ssh_public_key
```

Hierdoor werkt de code zowel lokaal als binnen de CI/CD-pipeline.

## CI/CD workflow

De CI/CD workflow staat in:

```text
.github/workflows/les-05-opdracht-3-terraform.yml
```

Deze workflow wordt automatisch gestart bij een push naar de branch `test`, maar alleen wanneer Terraform-bestanden wijzigen:

```yaml
on:
  push:
    branches:
      - test
    paths:
      - "les-05-v2/opdracht-3/terraform/**/*.tf"
      - "les-05-v2/opdracht-3/terraform/**/*.tftpl"
      - ".github/workflows/les-05-opdracht-3-terraform.yml"
  workflow_dispatch:
```

De workflow bestaat uit twee jobs:

1. `terraform-check`
2. `terraform-apply`

### terraform-check

Deze job controleert de Terraform-code:

```bash
terraform fmt -check -recursive
terraform init -reconfigure -input=false
terraform validate
terraform plan -input=false
```

Hiermee wordt gecontroleerd of:

* De code netjes geformatteerd is.
* Terraform correct kan initialiseren.
* De configuratie valide is.
* Er een geldig plan gemaakt kan worden.

### terraform-apply

Deze job draait alleen als `terraform-check` succesvol is. Daarna wordt de infrastructuur uitgerold met:

```bash
terraform apply -auto-approve -input=false
```

## Best-practice check

De opdracht vraagt om een stap die controleert of de Terraform-code voldoet aan best practices. Hiervoor wordt onder andere gebruikt:

```bash
terraform fmt -check -recursive
```

Deze controle zorgt ervoor dat Terraform-bestanden volgens de standaard Terraform-opmaak geschreven zijn.

Daarnaast wordt ook gebruikgemaakt van:

```bash
terraform validate
```

Hiermee wordt gecontroleerd of de Terraform-configuratie syntactisch en inhoudelijk geldig is.

## Handmatige destroy workflow

De destroy workflow staat in:

```text
.github/workflows/les-05-opdracht-3-destroy.yml
```

Deze workflow wordt niet automatisch uitgevoerd. Hij kan alleen handmatig gestart worden via GitHub Actions:

```yaml
on:
  workflow_dispatch:
```

De workflow voert uit:

```bash
terraform init -reconfigure -input=false
terraform destroy -auto-approve -input=false
```

Hierdoor wordt voorkomen dat infrastructuur per ongeluk verwijderd wordt bij een gewone push.

## Lokaal testen op de jumphost

Omdat Terraform op de jumphost is geïnstalleerd, kan de configuratie lokaal getest worden met:

```bash
cd ~/InfrastructureAsCode/infrastructure-as-code/les-05-v2/opdracht-3/terraform

terraform init -reconfigure
terraform fmt -check -recursive
terraform validate
terraform plan
```

Voor lokale uitvoering kan een eigen `terraform.tfvars` worden gebruikt. Dit bestand staat niet in Git.

## Workflow handmatig starten

De CI/CD workflow kan handmatig gestart worden via GitHub:

```text
GitHub → Actions → Les 05 - Opdracht 3 Terraform CI/CD → Run workflow
```

De destroy workflow kan handmatig gestart worden via:

```text
GitHub → Actions → Les 05 - Opdracht 3 Destroy → Run workflow
```

## Best practices

In deze opdracht zijn de volgende best practices toegepast:

* Gebruik van Terraform voor Infrastructure as Code.
* Gebruik van een remote backend voor Terraform state.
* Geen echte `terraform.tfvars` in Git.
* Gebruik van `terraform.tfvars.example` als template.
* Gebruik van `TF_VAR_...` voor CI/CD-variabelen.
* Scheiding tussen GitHub Actions Variables en Secrets.
* SSH-key authenticatie in plaats van wachtwoorden.
* Workflow draait alleen bij wijzigingen in Terraform-bestanden.
* Destroy is gescheiden in een aparte handmatige workflow.
* `terraform fmt -check` en `terraform validate` worden gebruikt als kwaliteitscontrole.
* Gebruik van `-input=false` zodat de workflow niet interactief wordt.
* Gebruik van een self-hosted GitHub Runner zoals vereist in de opdracht.
* Gebruik van een aparte Terraform state-key voor opdracht 3.
* Gevoelige of omgevingsspecifieke waarden worden niet in Git opgeslagen.

## Conclusie

Met deze opdracht is een professionele Terraform CI/CD-pipeline ingericht. De pipeline controleert de Terraform-code, maakt een plan en rolt automatisch infrastructuur uit wanneer relevante bestanden wijzigen. Het verwijderen van infrastructuur is bewust gescheiden in een aparte handmatige workflow.

Door gebruik te maken van remote state, GitHub Actions Secrets/Variables en non-interactieve Terraform-commando’s is de oplossing geschikt voor reproduceerbare en gecontroleerde infrastructuurdeployment. Voor een productie- of enterpriseomgeving zou Azure Key Vault een logische vervolgstap zijn voor centraal en beter auditbaar beheer van secrets.
