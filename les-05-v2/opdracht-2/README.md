# Les 05 - Opdracht 2

## Doel van de opdracht

In deze opdracht wordt gebruikgemaakt van een lokale GitHub Runner om automatisch een Ansible playbook uit te voeren via GitHub Actions. Het playbook installeert een package op een Azure VM. De workflow wordt automatisch gestart bij een push naar de repository.

De opdracht richt zich op CI/CD met Ansible:

* Een lokale self-hosted GitHub Runner wordt gebruikt.
* GitHub Actions voert de Ansible workflow uit.
* Azure dynamic inventory wordt gebruikt om de VM uit Azure op te halen.
* De VM wordt gegroepeerd op basis van Azure-tags.
* Het playbook installeert automatisch een package op de server.

## Gebruikte technieken

Voor deze opdracht zijn de volgende technieken gebruikt:

* GitHub Actions
* Self-hosted GitHub Runner
* Azure
* Azure CLI
* Ansible
* Azure dynamic inventory
* Ansible roles
* Python virtual environment

## Mappenstructuur

De opdracht heeft de volgende structuur:

```text
opdracht-2/
├── ansible.cfg
├── inventory.azure_rm.yml
├── playbook.yml
├── requirements.yml
├── group_vars/
│   └── role_webserver.yml
└── install_packages/
    ├── defaults/
    │   └── main.yml
    ├── handlers/
    │   └── main.yml
    ├── meta/
    │   └── main.yml
    └── tasks/
        └── main.yml
```

De GitHub Actions workflow staat in:

```text
.github/workflows/les-05-opdracht-2.yml
```

## Azure dynamic inventory

Voor deze opdracht wordt geen statisch inventorybestand gebruikt. In plaats daarvan wordt gebruikgemaakt van de Azure dynamic inventory plugin:

```yaml
plugin: azure.azcollection.azure_rm
auth_source: cli
```

Hiermee haalt Ansible de VM-informatie rechtstreeks uit Azure op.

De VM wordt geselecteerd op basis van Azure-tags. In Terraform zijn tags toegevoegd zoals:

```text
project = les-05
role    = webserver
```

Met `keyed_groups` wordt automatisch een Ansible-groep gemaakt op basis van de tag `role`.

Voorbeeld:

```yaml
keyed_groups:
  - key: tags.role
    prefix: role
    separator: "_"
```

Hierdoor ontstaat de groep:

```text
role_webserver
```

Het playbook gebruikt daarom:

```yaml
hosts: role_webserver
```

## Ansible-configuratie

In `ansible.cfg` is vastgelegd welke inventory en role-path gebruikt worden:

```ini
[defaults]
inventory = inventory.azure_rm.yml
roles_path = .
host_key_checking = False
retry_files_enabled = False

[privilege_escalation]
become = True
become_method = sudo
```

## Verbinding met de Azure VM

Omdat de Azure VM met de gebruiker `iacuser` is aangemaakt, staat de verbindingsconfiguratie in:

```text
group_vars/role_webserver.yml
```

Voorbeeld:

```yaml
---
ansible_user: iacuser
ansible_ssh_private_key_file: ~/.ssh/id_ed25519
ansible_python_interpreter: /usr/bin/python3
```

Hierdoor gebruikt Ansible niet de lokale Linux-gebruiker van de jumphost, maar de juiste gebruiker op de Azure VM.

## Python virtual environment

Voor de Azure dynamic inventory is een Python virtual environment gebruikt. Dit voorkomt dat packages globaal op het systeem geïnstalleerd moeten worden.

Voorbeeld:

```bash
python3 -m venv ~/venvs/ansible-azure
source ~/venvs/ansible-azure/bin/activate
```

Binnen deze virtual environment zijn Ansible en de Azure collection beschikbaar.

## Lokaal testen op de jumphost

Vanaf de jumphost kan de opdracht lokaal getest worden met:

```bash
cd ~/InfrastructureAsCode/infrastructure-as-code/les-05-v2/opdracht-2
source ~/venvs/ansible-azure/bin/activate
```

Controleer eerst of Azure login werkt:

```bash
az account show
```

Controleer daarna of de dynamic inventory de VM vindt:

```bash
ansible-inventory -i inventory.azure_rm.yml --graph
```

Verwacht resultaat:

```text
@all:
  |--@role_webserver:
  |  |--les05-webserver
```

Test daarna de verbinding:

```bash
ansible -i inventory.azure_rm.yml role_webserver -m ping
```

Verwacht resultaat:

```text
les05-webserver | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Daarna kan het playbook getest worden:

```bash
ansible-playbook -i inventory.azure_rm.yml playbook.yml --syntax-check
ansible-playbook -i inventory.azure_rm.yml playbook.yml
```

## GitHub Actions workflow

De workflow gebruikt de lokale self-hosted runner. De workflow bestaat uit twee jobs:

1. `syntax-check`
2. `deploy`

De syntax-check controleert of de Ansible-code geldig is. De deploy-job voert het playbook uit op de Azure VM.

De workflow gebruikt bewust `working-directory: les-05-v2/opdracht-2`, zodat Ansible de juiste bestanden gebruikt:

* `ansible.cfg`
* `inventory.azure_rm.yml`
* `group_vars/role_webserver.yml`
* `playbook.yml`

## Workflow-trigger

De workflow wordt automatisch gestart bij een push naar de branch `test`, maar alleen wanneer bestanden in opdracht 2 of de workflow zelf wijzigen.

Voorbeeld:

```yaml
on:
  push:
    branches:
      - test
    paths:
      - "les-05-v2/opdracht-2/**"
      - ".github/workflows/les-05-opdracht-2.yml"
  workflow_dispatch:
```

Door `workflow_dispatch` kan de workflow ook handmatig gestart worden via GitHub Actions.

## Opmerking over warnings

Bij het gebruik van de Azure dynamic inventory plugin kunnen waarschuwingen verschijnen zoals:

```text
Found variable using reserved name: name
Found variable using reserved name: tags
```

Deze waarschuwingen komen vanuit de Azure dynamic inventory plugin, die standaard Azure-metadata als host variables meegeeft. De werking wordt hierdoor niet beïnvloed. De VM wordt correct gevonden op basis van Azure-tags en het playbook wordt succesvol uitgevoerd.

## Best practices

In deze opdracht zijn de volgende best practices toegepast:

* Gebruik van een self-hosted GitHub Runner.
* Gebruik van GitHub Actions voor CI/CD.
* Geen statische inventory in Git.
* Gebruik van Azure als bron van waarheid.
* Gebruik van Azure-tags voor hostgroepering.
* Gebruik van een Ansible role voor package-installatie.
* Gebruik van een Python virtual environment.
* Scheiding tussen inventory, group variables en playbooklogica.
* Automatische syntax-check voordat deployment wordt uitgevoerd.
* Workflow wordt alleen uitgevoerd bij relevante wijzigingen.

## Conclusie

Met deze opdracht is een CI/CD-proces ingericht waarbij GitHub Actions via een lokale self-hosted runner automatisch een Ansible playbook uitvoert. Door Azure dynamic inventory te gebruiken, hoeft er geen statisch inventorybestand beheerd te worden. De VM wordt dynamisch uit Azure opgehaald en gegroepeerd op basis van tags. Dit maakt de oplossing beter schaalbaar en professioneler dan een handmatig beheerde inventory.
