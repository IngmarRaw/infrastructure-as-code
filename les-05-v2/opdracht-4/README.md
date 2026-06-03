# Les 05 - Opdracht 4

## Toepassing van CI/CD in mijn eigen organisatie

## Inleiding

In deze opdracht wordt uitgewerkt hoe CI/CD kan worden toegepast binnen mijn eigen werkomgeving. Ik werk bij een organisatie die IT-infrastructuur beheert voor verschillende klanten. Deze klantomgevingen bestaan vooral uit Microsoft-gebaseerde infrastructuur, zowel on-premises als in de cloud.

Binnen deze omgeving komen veel werkzaamheden regelmatig terug. Denk bijvoorbeeld aan het uitrollen van servers, het aanpassen van configuraties, het installeren van agents, het beheren van standaardinstellingen en het uitvoeren van wijzigingen op klantomgevingen. Veel van deze werkzaamheden worden nu deels handmatig uitgevoerd of vereisen controle door een beheerder.

CI/CD kan helpen om dit soort werkzaamheden consistenter, veiliger en beter controleerbaar uit te voeren.

## Wat is CI/CD?

CI/CD staat voor Continuous Integration en Continuous Deployment of Delivery.

Bij Continuous Integration wordt code of configuratie automatisch gecontroleerd zodra deze wordt aangepast. Denk hierbij aan controles op syntax, formatting, validatie en eventuele tests.

Bij Continuous Deployment of Delivery wordt een wijziging na goedkeuring of na succesvolle controles automatisch uitgerold naar een omgeving.

Binnen softwareontwikkeling wordt CI/CD vaak gebruikt voor applicaties. Binnen infrastructuurbeheer kan hetzelfde principe worden toegepast op Infrastructure as Code en configuratiebeheer.

Voorbeelden hiervan zijn:

* Terraform-code automatisch controleren en toepassen.
* Ansible playbooks automatisch uitvoeren.
* PowerShell-scripts gecontroleerd uitvoeren.
* Azure-resources automatisch uitrollen.
* Configuraties op Windows Servers automatisch beheren.
* Monitoring agents automatisch installeren of bijwerken.

## Omgeving waarin CI/CD toegepast kan worden

Binnen mijn organisatie zou CI/CD vooral waardevol zijn voor klantomgevingen die regelmatig beheerd of aangepast worden. De omgeving bestaat voornamelijk uit Microsoft-technologie, zoals:

* Windows Server
* Active Directory
* Microsoft Entra ID
* Azure
* Microsoft 365
* Intune
* Exchange Online
* Remote Desktop Services
* Fileservers
* IIS
* Monitoring- en backupsoftware

Linux wordt binnen onze organisatie minder gebruikt. Daarom zou CI/CD vooral gericht moeten zijn op Windows Server-, Azure- en Microsoft 365-gerelateerde werkzaamheden.

Een mogelijke CI/CD-omgeving kan bestaan uit:

```text
GitHub repository
        ↓
Pull request of push
        ↓
GitHub Actions workflow
        ↓
Self-hosted runner in beheeromgeving
        ↓
Terraform / Ansible / PowerShell
        ↓
Wijziging in klantomgeving
```

De self-hosted runner is hierbij belangrijk, omdat klantomgevingen vaak niet direct vanaf GitHub-hosted runners bereikbaar zijn. Een lokale runner binnen het beheer- of klantnetwerk kan wel toegang hebben tot interne systemen, VPN-verbindingen of beheerinterfaces.

## Mogelijke toepassingen in mijn werk

### 1. Uitrollen van Azure-infrastructuur

Een belangrijke toepassing is het uitrollen van Azure-resources met Terraform. Denk hierbij aan:

* Resource groups
* Virtual networks
* Subnets
* Network security groups
* Virtual machines
* Public IP-adressen
* Storage accounts
* Backup configuraties

In plaats van deze resources handmatig via de Azure Portal aan te maken, kan Terraform worden gebruikt om de infrastructuur reproduceerbaar vast te leggen.

Een CI/CD-pipeline kan dan automatisch controleren of de Terraform-code goed is opgebouwd. Bijvoorbeeld met:

```text
terraform fmt -check
terraform validate
terraform plan
```

Na succesvolle controle kan een beheerder bepalen of de wijziging mag worden toegepast. Voor productieomgevingen zou ik niet direct automatisch `terraform apply` uitvoeren zonder controle. Voor test- of acceptatieomgevingen kan automatische deployment wel passend zijn.

### 2. Uitrollen van standaard Windows Server configuraties

Veel klanten gebruiken Windows Servers met vergelijkbare basisinstellingen. CI/CD kan gebruikt worden om standaardconfiguraties gecontroleerd uit te rollen.

Voorbeelden:

* Lokale firewallregels
* Windows features
* Basis security hardening
* Tijdzone-instellingen
* Monitoring agents
* Backup agents
* Event log instellingen
* Lokale gebruikers of groepen
* IIS-configuratie

Deze configuratie kan bijvoorbeeld met Ansible, PowerShell DSC of PowerShell-scripts worden uitgevoerd.

Een pipeline kan eerst controleren of scripts geldig zijn en daarna de wijziging uitvoeren op een testserver. Pas daarna kan dezelfde wijziging naar productie worden uitgerold.

### 3. Installatie van monitoring agents

Een concreet voorbeeld uit mijn werk is het installeren of bijwerken van een monitoring agent op servers van klanten.

Dit gebeurt bij veel klanten op ongeveer dezelfde manier, maar met kleine verschillen, zoals:

* Klantnaam
* Monitoringserver
* Agentgroep
* Omgevingstype
* Serverrol

Met CI/CD kan hiervoor een standaardproces worden gemaakt:

```text
Wijziging in configuratie
        ↓
Code check
        ↓
Test op één server
        ↓
Uitrol naar servergroep
        ↓
Controle of agent actief is
```

Hierdoor wordt voorkomen dat agents handmatig verschillend worden geïnstalleerd. Ook kan beter worden vastgelegd welke versie wanneer is uitgerold.

### 4. Fileserverconfiguratie

Bij klanten moeten regelmatig fileservers worden ingericht of aangepast. Denk hierbij aan:

* Mappenstructuren
* Shares
* NTFS-rechten
* Groepsstructuren
* Afdelingsmappen
* Home drives

Dit zijn werkzaamheden waarbij fouten snel kunnen ontstaan, vooral bij rechtenstructuren. Met CI/CD kan de gewenste configuratie eerst in code worden vastgelegd en gecontroleerd voordat deze wordt toegepast.

Bijvoorbeeld:

```text
fileserver-config/
├── shares.yml
├── groups.yml
├── permissions.yml
└── playbook.yml
```

De pipeline kan dan controleren of de configuratie geldig is en daarna de wijzigingen gecontroleerd uitvoeren.

### 5. Microsoft 365 en Entra ID beheer

Ook voor Microsoft 365 en Entra ID kan CI/CD nuttig zijn. Denk aan wijzigingen in:

* Security groups
* App assignments
* Conditional Access policies
* Intune configuratieprofielen
* Device compliance policies
* Gebruikers- of groepsinstellingen

In een professionele omgeving moet hierbij wel extra voorzichtig worden gewerkt, omdat fouten direct impact kunnen hebben op gebruikers of beveiliging. Daarom zou ik voor dit soort wijzigingen altijd werken met:

* Pull requests
* Code review
* Testomgeving
* Handmatige goedkeuring voor productie
* Logging van wijzigingen

## Voorbeeld van een CI/CD-proces

Een praktisch CI/CD-proces voor infrastructuurbeheer kan er als volgt uitzien:

```text
1. Beheerder past Terraform-, Ansible- of PowerShell-code aan
2. Wijziging wordt gepusht naar GitHub
3. GitHub Actions workflow start automatisch
4. Code wordt gecontroleerd op formatting en syntax
5. Er wordt een plan of dry-run uitgevoerd
6. Bij akkoord wordt de wijziging toegepast
7. De pipeline controleert of de wijziging succesvol is
8. Resultaten zijn zichtbaar in de workflow logs
```

Voor productieomgevingen zou ik een extra goedkeuringsstap toevoegen. Niet elke wijziging moet automatisch naar productie gaan.

## Welke tools zouden gebruikt kunnen worden?

Binnen mijn organisatie zouden de volgende tools logisch zijn:

### GitHub

GitHub kan gebruikt worden voor versiebeheer van infrastructuurcode, scripts en configuratiebestanden. Door gebruik te maken van branches en pull requests kunnen wijzigingen gecontroleerd worden voordat ze worden uitgevoerd.

### GitHub Actions

GitHub Actions kan gebruikt worden om workflows automatisch te starten bij wijzigingen. Bijvoorbeeld bij een push of pull request.

### Self-hosted runner

Een self-hosted runner is belangrijk omdat klantomgevingen vaak niet direct publiek bereikbaar zijn. De runner kan draaien op een beheerde jumphost of beheer-VM die toegang heeft tot de juiste klantomgeving.

### Terraform

Terraform kan gebruikt worden voor het aanmaken en beheren van cloudresources, vooral in Azure.

### Ansible

Ansible kan gebruikt worden voor configuratiebeheer. Hoewel onze organisatie vooral Microsoft-gebaseerd is, kan Ansible ook gebruikt worden voor Windowsbeheer via WinRM en voor Azure-integraties.

### PowerShell

PowerShell blijft binnen een Microsoft-gebaseerde organisatie erg belangrijk. Veel Microsoft 365-, Entra ID- en Windows Server-taken kunnen goed met PowerShell worden uitgevoerd.

### Azure Key Vault

Voor secrets en gevoelige gegevens zou Azure Key Vault gebruikt kunnen worden. Denk aan API keys, service account gegevens en certificaatwachtwoorden. Dit is netter dan secrets verspreid opslaan in losse scripts of configuratiebestanden.

## Voordelen van CI/CD in mijn werkomgeving

### Standaardisatie

CI/CD helpt om klantomgevingen op een consistente manier te beheren. Dezelfde configuratie kan bij meerdere klanten worden toegepast met andere variabelen.

### Minder handmatig werk

Veel terugkerende taken kunnen worden geautomatiseerd. Hierdoor hoeven beheerders minder handmatige stappen uit te voeren.

### Minder kans op fouten

Handmatige configuratie leidt sneller tot typefouten of verschillen tussen klantomgevingen. Door configuratie in code vast te leggen, worden wijzigingen beter voorspelbaar.

### Betere controle

Elke wijziging staat in Git. Hierdoor is zichtbaar wie iets heeft aangepast, wanneer dit is aangepast en waarom.

### Sneller terugdraaien

Wanneer een wijziging problemen veroorzaakt, kan makkelijker worden teruggekeken naar vorige versies van de configuratie.

### Betere samenwerking

Collega’s kunnen wijzigingen controleren via pull requests. Hierdoor wordt kennis beter gedeeld en worden fouten eerder opgemerkt.

### Betere overdraagbaarheid

Nieuwe collega’s kunnen sneller begrijpen hoe klantomgevingen zijn opgebouwd, omdat de configuratie in code staat.

## Consequenties en aandachtspunten

### Beveiliging van secrets

Secrets mogen nooit hardcoded in scripts, playbooks of Terraform-bestanden staan. Denk aan:

* Wachtwoorden
* API tokens
* Certificaatwachtwoorden
* Service account credentials
* Private keys

Deze gegevens moeten worden opgeslagen in een veilige secrets-oplossing, zoals GitHub Actions Secrets of Azure Key Vault.

### Rechten van de runner

Een self-hosted runner heeft toegang nodig tot klantomgevingen. Dat betekent dat de runner goed beveiligd moet worden. Als een runner te veel rechten heeft, kan een fout of misbruik grote impact hebben.

Daarom moet rekening worden gehouden met:

* Least privilege
* Gescheiden runners per klant of omgeving
* Beperkte netwerktoegang
* Logging
* Regelmatige updates
* Geen onnodige lokale secrets

### Scheiding tussen test en productie

Niet elke wijziging mag direct naar productie. Voor productieomgevingen is het verstandig om te werken met:

* Pull requests
* Code review
* Handmatige approval
* Change windows
* Rollbackplan

Voor testomgevingen kan meer automatisch worden uitgerold.

### Verschillen tussen klanten

Niet elke klantomgeving is hetzelfde. Daarom moeten klantverschillen worden vastgelegd in variabelen en niet hardcoded in scripts.

Bijvoorbeeld:

```yaml
customer_name: klant_a
environment: production
monitoring_server: mon01.klant-a.local
timezone: W. Europe Standard Time
```

Door met variabelen te werken kan dezelfde code voor meerdere klanten worden gebruikt.

### Testen van wijzigingen

Een fout in een CI/CD-pipeline kan impact hebben op meerdere servers of klanten. Daarom moeten wijzigingen eerst getest worden.

Een veilige volgorde is:

```text
1. Lokale syntax-check
2. Testomgeving
3. Eén testserver
4. Kleine servergroep
5. Productie
```

### Logging en audit

Omdat CI/CD automatisch wijzigingen uitvoert, moet goed worden vastgelegd wat er gebeurt. Workflow logs, Git commits en eventueel Azure Activity Logs kunnen hierbij helpen.

## Mogelijke repositorystructuur

Een mogelijke repositorystructuur voor CI/CD binnen mijn organisatie kan er zo uitzien:

```text
customer-infrastructure/
├── customers/
│   ├── klant-a/
│   │   ├── terraform/
│   │   ├── ansible/
│   │   └── variables/
│   ├── klant-b/
│   │   ├── terraform/
│   │   ├── ansible/
│   │   └── variables/
│   └── klant-c/
├── modules/
│   ├── azure-vm/
│   ├── storage-account/
│   └── network/
├── roles/
│   ├── windows-baseline/
│   ├── monitoring-agent/
│   ├── fileserver/
│   └── iis-webserver/
└── .github/
    └── workflows/
        ├── terraform-plan.yml
        ├── terraform-apply.yml
        ├── ansible-deploy.yml
        └── destroy-manual.yml
```

Hierdoor kunnen klantconfiguraties gescheiden worden, terwijl herbruikbare modules en roles centraal beheerd worden.

## Voorbeeldscenario

Een concreet scenario is het uitrollen van een nieuwe monitoring agent bij meerdere klanten.

### Huidige situatie

Een beheerder logt in op servers, downloadt de agent, installeert deze en controleert handmatig of de service draait.

### Gewenste situatie met CI/CD

De beheerder past de gewenste agentversie aan in Git. Daarna wordt automatisch een workflow gestart.

De workflow doet het volgende:

```text
1. Controleert de configuratie
2. Controleert of de juiste klantomgeving geselecteerd is
3. Draait eerst op één testserver
4. Installeert of update de monitoring agent
5. Controleert of de service actief is
6. Geeft het resultaat terug in GitHub Actions
```

Hierdoor is duidelijk welke versie is uitgerold en op welke servers dit is gebeurd.

## Wanneer CI/CD minder geschikt is

CI/CD is niet voor elke taak direct geschikt. Sommige wijzigingen vereisen handmatige controle of overleg met de klant.

Voorbeelden:

* Grote migraties
* Wijzigingen met veel gebruikersimpact
* Netwerkwijzigingen die beheerverbindingen kunnen verbreken
* Productiewijzigingen buiten afgesproken onderhoudsvensters
* Wijzigingen aan Conditional Access policies

Voor dit soort wijzigingen kan CI/CD nog steeds helpen met controles en voorbereiding, maar de uiteindelijke uitvoering moet dan mogelijk handmatig goedgekeurd worden.

## Conclusie

CI/CD kan binnen mijn organisatie veel waarde toevoegen, ook al werken wij vooral in Microsoft-gebaseerde omgevingen. De grootste winst zit in het standaardiseren en automatiseren van terugkerende beheertaken.

Voorbeelden zijn het uitrollen van Azure-infrastructuur, het installeren van monitoring agents, het configureren van Windows Servers, het beheren van fileservers en het uitvoeren van gecontroleerde wijzigingen in Microsoft 365 of Entra ID.

Belangrijke voorwaarden zijn wel dat secrets veilig worden beheerd, runners goed worden afgeschermd, wijzigingen getest worden en productieomgevingen niet zomaar automatisch worden aangepast. Door CI/CD zorgvuldig in te richten, kunnen klantomgevingen consistenter, veiliger en beter controleerbaar worden beheerd.

Voor mijn eigen werk zou CI/CD vooral nuttig zijn als hulpmiddel om terugkerende werkzaamheden sneller en betrouwbaarder uit te voeren, zonder de controle over klantomgevingen te verliezen.
