# Role: hello_container

Deze Ansible role start de zelfgebouwde Hello World container op een Docker host.

## Doel

De role is onderdeel van de eindopdracht voor de hybrid cloud deployment. De Docker Engine zelf wordt geïnstalleerd via de aparte Ansible Galaxy role IngmarRaw.docker. Deze role gebruikt daarna de community.docker.docker_container module om de container te starten en bereikbaar te maken.

De container draait op zowel de Azure VM als de ESXi VM.

## Taken

Deze role voert de volgende acties uit:

1. Pullt de opgegeven container image.
2. Start de container met een vaste naam.
3. Publiceert de containerpoort naar de host.
4. Controleert of de container via HTTP bereikbaar is.
5. Toont een korte statusmelding wanneer de controle succesvol is.

## Variabelen

| Variabele | Beschrijving | Voorbeeld |
|---|---|---|
| hello_container_name | Naam van de container op de host. | eindopdracht-hello-world |
| hello_container_image | Container image die gestart moet worden. | ghcr.io/ingmarraw/infrastructure-as-code/eind-opdracht-hello-world:latest |
| hello_container_port | Hostpoort waarop de container beschikbaar wordt gemaakt. | 8080 |

## Vereisten

Deze role verwacht dat Docker al op de doelhost is geïnstalleerd. In deze eindopdracht wordt dat verzorgd door de Ansible Galaxy role:

yaml - role: IngmarRaw.docker 

Daarnaast moet de collection community.docker geïnstalleerd zijn via requirements.yml.

## Voorbeeldgebruik

yaml --- - name: Configureer Docker container   hosts: docker_hosts   become: true    roles:     - role: hello_container 

## Opmerking

De container image wordt niet in deze role gebouwd. De image wordt gebouwd en gepubliceerd via de aparte GitHub Actions workflow eind-opdracht-build-container.yml.