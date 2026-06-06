# Role: testuser

Deze role maakt de gebruiker `testuser` aan op de doelhosts en configureert SSH-toegang.

## Doel

De eindopdracht vereist dat `testuser` vanaf de ESXi VM kan inloggen op de Azure VM. Daarom plaatst deze role:

- de public key in `authorized_keys` op beide hosts;
- de private key alleen op de ESXi host;
- een public key file op de ESXi host voor controle;
- correcte rechten op de `.ssh` directory en keybestanden.

## Variabelen

| Variabele | Beschrijving |
|---|---|
| `testuser_name` | Naam van de gebruiker. Standaard `testuser`. |
| `testuser_public_key` | Public key uit 1Password. |
| `testuser_private_key` | Private key uit 1Password. Wordt alleen op ESXi geplaatst. |

## Gebruik

```yaml
- hosts: docker_hosts
  become: true
  roles:
    - role: testuser