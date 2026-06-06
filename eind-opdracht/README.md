# Eindopdracht - Hybrid Cloud Deployment

## Inleiding

Deze eindopdracht bevat een geautomatiseerde hybrid cloud deployment waarin een Azure VM en een ESXi VM worden gecombineerd. De infrastructuur wordt uitgerold met Terraform en daarna geconfigureerd met Ansible. Op beide systemen wordt Docker geïnstalleerd via een zelfgemaakte Ansible Galaxy role. Vervolgens draait op beide systemen een zelfgebouwde Hello World Docker container.

De opdracht is opgebouwd volgens een CI/CD-aanpak met GitHub Actions en een self-hosted runner op de jumphost.

## Doel van de opdracht

Het doel van deze eindopdracht is om aan te tonen dat een hybrid cloud omgeving volledig geautomatiseerd kan worden uitgerold en geconfigureerd.

De oplossing voldoet aan de volgende eisen:

- Er wordt een Azure VM aangemaakt met Terraform.
- Er wordt een ESXi VM aangemaakt met Terraform.
- Op beide VM’s wordt een gebruiker testuser aangemaakt.
- De gebruiker testuser kan vanaf de ESXi VM via SSH verbinden naar de Azure VM.
- Op beide systemen wordt Docker geïnstalleerd via een zelfgemaakte Ansible Galaxy role.
- Op beide systemen draait een zelfgebouwde Hello World Docker container.
- De container wordt beheerd via de Ansible community.docker collection.
- De deployment wordt uitgevoerd via GitHub Actions op een self-hosted runner.

## Globale architectuur

De omgeving bestaat uit twee virtuele machines:

| Onderdeel | Platform | Naamgeving | Doel |
|---|---|---|---|
| Azure VM | Microsoft Azure | webserver-01 | Webserver / Docker host |
| ESXi VM | VMware ESXi | database-server-01 | Database-server / Docker host / SSH-bronhost |

Beide systemen worden opgenomen in de Ansible groep docker_hosts. Daardoor kan dezelfde Docker- en containerconfiguratie op beide hosts worden toegepast.

## Gebruikte technieken

| Techniek | Toepassing |
|---|---|
| Terraform | Aanmaken van Azure en ESXi resources |
| Ansible | Configuratie van gebruikers, SSH, Docker en containers |
| Ansible Galaxy | Ophalen van de zelfgemaakte Docker role |
| community.docker | Starten en beheren van de Docker container |
| GitHub Actions | CI/CD workflows |
| Self-hosted runner | Uitvoering van Terraform, Ansible en Docker build |
| 1Password | Beheer van secrets en SSH keys |
| GHCR | Opslag van de zelfgebouwde Docker image |

## Directorystructuur

 eind-opdracht/
├── ansible/
│   ├── group_vars/
│   │   └── docker_hosts.yml
│   ├── roles/
│   │   ├── hello_container/
│   │   └── testuser/
│   ├── playbook.yml
│   └── requirements.yml
├── app/
│   ├── Dockerfile
│   └── index.html
├── terraform/
│   ├── azure/
│   └── esxi/
└── README.md

## CI/CD workflows

De eindopdracht gebruikt meerdere GitHub Actions workflows. De workflows zijn bewust gescheiden, zodat infrastructuur, configuratie en container build logisch van elkaar gescheiden blijven.

| Workflow | Doel |
|---|---|
| eind-opdracht-build-container.yml | Bouwt en pusht de Hello World Docker image naar GHCR |
| eind-opdracht-deploy-infra.yml | Maakt de Azure en ESXi infrastructuur aan met Terraform |
| eind-opdracht-configure.yml | Configureert de VM’s met Ansible |
| eind-opdracht-destroy.yml | Verwijdert de aangemaakte infrastructuur |

De normale uitvoervolgorde is:

1. Eindopdracht - Build Hello World Container
2. Eindopdracht - Deploy Infra
3. Eindopdracht - Configure Hosts

De destroy workflow wordt alleen gebruikt wanneer de omgeving verwijderd moet worden.

## Secrets management

Voor deze opdracht wordt gebruikgemaakt van 1Password voor het beheren van gevoelige gegevens. GitHub bevat alleen de service account token waarmee de workflow secrets uit 1Password kan ophalen.

In GitHub Actions is hiervoor één repository secret nodig:

text OP_SERVICE_ACCOUNT_TOKEN 

De overige waarden worden uit de 1Password vault IAC geladen.

Voorbeelden van waarden die uit 1Password worden opgehaald:

- Azure subscription ID
- Azure resource group
- Azure netwerkgegevens
- ESXi hostname
- ESXi gebruikersnaam en wachtwoord
- SSH public en private keys
- Terraform backendgegevens
- Container image naam

Hierdoor worden wachtwoorden, private keys en andere gevoelige gegevens niet in Git opgeslagen.

## Terraform

Terraform wordt gebruikt voor het aanmaken van de infrastructuur.

Er zijn twee Terraform onderdelen:

text terraform/azure terraform/esxi 

### Azure

Het Azure Terraform onderdeel maakt onder andere aan:

- Public IP
- Network Interface
- Network Security Group
- Linux VM
- SSH-toegang voor de admin gebruiker

De Azure VM gebruikt de naamgeving:

text webserver-01 

De naam wordt opgebouwd met een prefix en een instance count. Hierdoor kan de configuratie later eenvoudig worden uitgebreid naar meerdere VM’s.

### ESXi

Het ESXi Terraform onderdeel maakt een Ubuntu VM aan op de ESXi omgeving.

De ESXi VM gebruikt de naamgeving:

text database-server-01 

Ook hier wordt gewerkt met een prefix en een instance count.

### Terraform plan en apply

De workflows gebruiken een opgeslagen planbestand. Dit voorkomt dat terraform apply een ander plan uitvoert dan eerder is gecontroleerd.

Voorbeeld:

bash terraform plan -input=false -out=tfplan terraform apply -input=false -auto-approve tfplan 

Voor destroy wordt dezelfde aanpak gebruikt:

bash terraform plan -destroy -input=false -out=tfdestroyplan terraform apply -input=false -auto-approve tfdestroyplan 

## Ansible

Ansible wordt gebruikt om de aangemaakte VM’s te configureren.

Het hoofdplaybook is:

text ansible/playbook.yml 

Het playbook voert de volgende rollen uit:

1. testuser
2. IngmarRaw.docker
3. hello_container

### Role: testuser

De lokale role testuser maakt de gebruiker testuser aan op beide hosts.

De role zorgt voor:

- aanmaken van de Linux-gebruiker testuser;
- aanmaken van de .ssh directory;
- plaatsen van de public key in authorized_keys;
- plaatsen van de private key op de ESXi VM;
- controle of de private key correct leesbaar is.

De private key wordt alleen op de ESXi VM geplaatst, omdat de opdracht vereist dat testuser vanaf de ESXi VM naar de Azure VM kan verbinden.

### Role: IngmarRaw.docker

Docker wordt geïnstalleerd via de zelfgemaakte Ansible Galaxy role:

text IngmarRaw.docker 

Deze role is los ondergebracht in een aparte repository en gepubliceerd via Ansible Galaxy. De role volgt de officiële Docker-installatiestappen voor Ubuntu:

- conflicterende Docker packages verwijderen;
- benodigde packages installeren;
- Docker GPG key toevoegen;
- Docker apt repository toevoegen;
- Docker Engine packages installeren;
- Docker service starten en enablen;
- gebruikers toevoegen aan de Docker groep.

### Role: hello_container

De lokale role hello_container start de zelfgebouwde Hello World container op beide Docker hosts.

Hiervoor wordt de Ansible module gebruikt:

text community.docker.docker_container 

Deze module pullt de image en zorgt dat de container actief is.

## Ansible requirements

De benodigde Ansible role en collections staan in:

text ansible/requirements.yml 

Hierin staan onder andere:

yaml roles:   - name: IngmarRaw.docker  collections:   - name: community.docker   - name: azure.azcollection 

De workflow installeert deze requirements met:

bash ansible-galaxy install -r requirements.yml --force 

## Dynamic inventory

De Azure VM wordt gevonden via de Azure dynamic inventory plugin. De workflow genereert hiervoor tijdens de run een inventorybestand op basis van de resource group uit 1Password.

De ESXi inventory wordt gegenereerd op basis van Terraform outputs. Hierdoor hoeft het IP-adres van de ESXi VM niet handmatig in Git opgeslagen te worden.

De gecombineerde Ansible groep is:

text docker_hosts 

Hierin zitten zowel de Azure VM als de ESXi VM.

## SSH-test

Na de configuratie voert de workflow een SSH-test uit. Hierbij logt testuser vanaf de ESXi VM in op de Azure VM.

De test gebruikt expliciet de geplaatste private key:

bash ssh -o BatchMode=yes \     -o IdentitiesOnly=yes \     -o StrictHostKeyChecking=no \     -i /home/testuser/.ssh/id_ed25519 \     testuser@<azure-public-ip> hostname 

Met BatchMode=yes wordt voorkomen dat de workflow interactief om een wachtwoord of passphrase vraagt. Als de key niet correct werkt, faalt de workflow direct.

## Container image

De Hello World container wordt gebouwd vanuit:

text eind-opdracht/app 

De build workflow bouwt de image en pusht deze naar GitHub Container Registry.

Voorbeeld image:

text ghcr.io/ingmarraw/infrastructure-as-code/eind-opdracht-hello-world:latest 

De configure workflow gebruikt deze image vervolgens om de container op beide VM’s te starten.

## Beveiligingskeuzes

Er zijn meerdere beveiligingskeuzes gemaakt:

- Secrets worden niet in Git opgeslagen.
- 1Password wordt gebruikt als centrale secret vault.
- GitHub bevat alleen de 1Password service account token.
- SSH private keys worden niet geprint in logs.
- Inventorybestanden worden tijdens de workflow gegenereerd.
- Terraform backendgegevens worden via 1Password geladen.
- Ansible controleert of SSH keys correct geplaatst zijn.
- De SSH-test gebruikt BatchMode=yes en IdentitiesOnly=yes.

## Uitvoeren

### 1. Container image bouwen

Start de workflow:

text Eindopdracht - Build Hello World Container 

Deze workflow bouwt en pusht de Hello World container image.

### 2. Infrastructuur deployen

Start de workflow:

text Eindopdracht - Deploy Infra 

Deze workflow maakt de Azure en ESXi VM’s aan met Terraform.

### 3. Hosts configureren

Start de workflow:

text Eindopdracht - Configure Hosts 

Deze workflow configureert beide VM’s met Ansible, installeert Docker, start de container en voert de SSH-test uit.

### 4. Infrastructuur verwijderen

Start de workflow:

text Eindopdracht - Destroy 

Voor deze workflow moet bewust bevestigd worden dat de infrastructuur verwijderd mag worden.

## Controlepunten voor de demo

Tijdens de demo kunnen de volgende onderdelen worden getoond:

1. De GitHub Actions workflows.
2. De succesvolle Terraform plan/apply stappen.
3. De Azure VM in Azure.
4. De ESXi VM op de ESXi omgeving.
5. De Ansible playbook run.
6. De installatie van Docker via IngmarRaw.docker.
7. Het gebruik van community.docker.docker_container.
8. De draaiende Hello World container op beide hosts.
9. De SSH-verbinding van testuser vanaf de ESXi VM naar de Azure VM.

## Conclusie

Deze eindopdracht toont aan dat een hybrid cloud omgeving geautomatiseerd kan worden uitgerold met Terraform en geconfigureerd met Ansible. Door Terraform, Ansible, Ansible Galaxy, 1Password en GitHub Actions te combineren ontstaat een reproduceerbare CI/CD-oplossing waarin zowel infrastructuur als applicatieconfiguratie automatisch worden uitgevoerd.