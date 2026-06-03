# Les 05 - Opdracht 1

## Doel van de opdracht

In deze opdracht wordt een eenvoudige webserveromgeving uitgerold in Azure met Terraform. Daarna wordt met Ansible het pakket `apache2` geïnstalleerd zonder gebruik te maken van de Ansible `apt` module. Daarnaast wordt bewust een foutieve taak toegevoegd, zodat zichtbaar wordt dat Ansible correct laat zien wanneer een taak faalt.

De opdracht combineert Infrastructure as Code met configuratiebeheer:

* Terraform wordt gebruikt voor het uitrollen van de Azure-infrastructuur.
* Ansible wordt gebruikt voor het configureren van de server.
* De Ansible-role is opgebouwd met een nette role-structuur.

## Gebruikte technieken

Voor deze opdracht zijn de volgende technieken gebruikt:

* Terraform
* Azure
* Ubuntu Server
* Ansible
* Ansible roles
* Cloud-init
* SSH-key authenticatie

## Mappenstructuur

De opdracht heeft de volgende globale structuur:

```text
opdracht-1/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── cloudinit.tftpl
│   └── terraform.tfvars.example
└── ansible/
    ├── ansible.cfg
    ├── playbook.yml
    ├── inventory.ini
    ├── group_vars/
    │   └── all/
    │       └── vault.yml.example
    └── roles/
        └── webserver/
            ├── tasks/
            │   └── main.yml
            ├── handlers/
            │   └── main.yml
            ├── meta/
            │   └── main.yml
            └── templates/
                └── index.html.j2
```

## Terraform

Terraform wordt gebruikt om een Ubuntu Server VM in Azure uit te rollen. Hierbij wordt gebruikgemaakt van een bestaande resource group, een bestaand virtual network en een bestaande subnet.

De Terraform-configuratie maakt onder andere de volgende onderdelen aan:

* Public IP-adres
* Network Interface
* Ubuntu Linux Virtual Machine
* Cloud-init configuratie
* Ansible inventorybestand

De VM wordt aangemaakt met SSH-key authenticatie. Wachtwoordauthenticatie is uitgeschakeld.

## Variabelen

De echte variabelen staan niet in Git. Hiervoor wordt lokaal een `terraform.tfvars` bestand gebruikt. In Git staat alleen een voorbeeldbestand:

```text
terraform.tfvars.example
```

Dit voorkomt dat omgevingsspecifieke waarden onnodig in de repository terechtkomen.

Voorbeeld:

```hcl
subscription_id       = "00000000-0000-0000-0000-000000000000"
resource_group_name  = "S1073133"
location             = "westeurope"

virtual_network_name = "jouw-vnet"
subnet_name          = "jouw-subnet"

vm_name              = "les05-webserver"
vm_size              = "Standard_DS1_v2"
admin_username       = "iacuser"

ssh_public_key_path  = "~/.ssh/id_ed25519.pub"
ssh_private_key_path = "~/.ssh/id_ed25519"
```

## Uitvoeren van Terraform

Vanaf de jumphost kan Terraform als volgt worden uitgevoerd:

```bash
cd ~/InfrastructureAsCode/infrastructure-as-code/les-05-v2/opdracht-1/terraform

cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Na het uitvoeren van `terraform apply` wordt de Azure VM aangemaakt en wordt een Ansible inventory gegenereerd.

## Ansible

Ansible wordt gebruikt om de webserver te configureren. De configuratie staat in een role met de naam `webserver`.

De role voert onder andere de volgende stappen uit:

* Controleren of `apache2` al geïnstalleerd is.
* `apache2` installeren zonder de Ansible `apt` module.
* Een indexpagina plaatsen via een Jinja2-template.
* De Apache-service starten en inschakelen.
* De status van Apache controleren.
* Bewust een taak laten falen voor de opdracht.

## Waarom apache2 zonder apt module?

De opdracht vraagt expliciet om een pakket te installeren zonder de `apt` module. Daarom wordt `apt-get install -y apache2` uitgevoerd via de Ansible `command` module.

Om te voorkomen dat de taak altijd als gewijzigd wordt gezien, wordt eerst gecontroleerd of `apache2` al aanwezig is met:

```bash
dpkg -s apache2
```

Alleen wanneer Apache nog niet is geïnstalleerd, wordt het installatiecommando uitgevoerd. Hierdoor blijft de playbook-uitvoering beter idempotent.

## Uitvoeren van Ansible

Vanaf de jumphost:

```bash
cd ~/InfrastructureAsCode/infrastructure-as-code/les-05-v2/opdracht-1/ansible

ansible webservers -m ping
ansible-playbook playbook.yml
```

De laatste taak faalt bewust. Dit hoort bij de opdracht, zodat zichtbaar wordt dat Ansible fouten duidelijk rapporteert.

## Verwacht resultaat

Bij een succesvolle uitvoering wordt:

* De Azure VM aangemaakt.
* SSH-toegang mogelijk met de ingestelde gebruiker.
* Apache2 geïnstalleerd.
* Een eenvoudige webpagina geplaatst.
* De Apache-service gestart.
* Een bewuste foutmelding getoond door de laatste taak.

## Best practices

In deze opdracht zijn de volgende best practices toegepast:

* Gebruik van Terraform voor reproduceerbare infrastructuur.
* Gebruik van variabelen in plaats van hardcoded waarden.
* Geen echte `terraform.tfvars` in Git.
* SSH-key authenticatie in plaats van wachtwoorden.
* Gebruik van een Ansible role-structuur.
* Gebruik van handlers voor servicebeheer.
* Gebruik van templates voor configuratiebestanden.
* Gebruik van `terraform fmt` en `terraform validate`.
* Bewuste scheiding tussen infrastructuur en configuratiebeheer.

## Conclusie

Met deze opdracht is een Azure VM uitgerold met Terraform en daarna geconfigureerd met Ansible. De opdracht laat zien hoe infrastructuur en configuratiebeheer gecombineerd kunnen worden. Door gebruik te maken van Terraform, cloud-init, Ansible roles en SSH-key authenticatie is de oplossing reproduceerbaar, overzichtelijk en geschikt als basis voor verdere automatisering.
