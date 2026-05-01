# NordeaChallengeTerraform Azure IaC Challenge — Secure VM Web Tier + Azure SQL Managed Instance

## Reference architecture

Use Microsoft’s **Azure Virtual Machines baseline architecture** as the base pattern because the challenge requires virtual machines for the compute tier. Adapt it with:

- Azure Application Gateway WAF v2 for public HTTPS ingress
- VM Scale Set for the web tier
- Azure SQL Managed Instance for the data tier
- Private endpoints for Azure PaaS dependencies
- Strong subnet segmentation and network controls

## Architecture

```text
Internet
  |
  | HTTPS 443
  v
Azure DNS Public Zone
  |
  v
Public IP
  |
  v
Application Gateway WAF v2
  |
  | HTTP 80 or HTTPS 443 to backend
  v
VM Scale Set subnet, no public IPs
  |
  | SQL over private endpoint / private routing
  v
Private Endpoint subnet
  |
  v
Azure SQL Managed Instance

Supporting private endpoints:
- Key Vault private endpoint
- Storage private endpoint, optional for diagnostics/bootstrapping
- SQL MI private endpoint, optional but included for explicit private endpoint requirement
```

## Security design

### Segmentation

Use separate subnets:

| Subnet | Purpose | Publicly reachable? |
|---|---|---|
| `snet-appgw` | Application Gateway only | Indirectly via public frontend |
| `snet-web` | VM Scale Set web instances | No |
| `snet-sqlmi` | Azure SQL Managed Instance delegated subnet | No |
| `snet-private-endpoints` | Private endpoints for Key Vault, SQL MI, Storage | No |
| `AzureBastionSubnet` | Optional secure admin access | Public IP only on Bastion |
| `AzureFirewallSubnet` | Optional egress control | Public IP only on Firewall |

### Ingress

- Only Application Gateway has public exposure.
- Application Gateway terminates TLS.
- WAF runs OWASP managed rules in prevention mode.
- VMSS instances do not have public IPs.

### East-west traffic

- Application Gateway subnet may reach VMSS subnet only on backend app port.
- VMSS subnet may reach SQL MI only on SQL port 1433.
- VMSS subnet may reach Key Vault through Private Link.
- Deny broad lateral movement between subnets.

### Data tier

- Azure SQL Managed Instance is deployed into a dedicated delegated subnet.
- Public data endpoint is disabled.
- SQL MI private endpoint is added for explicit private endpoint usage and stable private access patterns.
- SQL authentication admin password is generated and stored in Key Vault.

### Identity and secrets

- VMSS uses a system-assigned managed identity.
- Key Vault public network access is disabled.
- Key Vault has a private endpoint.
- VMSS identity can read only required secrets.

### Operations

- Log Analytics workspace receives diagnostic logs.
- Application Gateway access logs and WAF logs enabled.
- VMSS diagnostics recommended.
- SQL MI auditing and vulnerability assessment recommended.

## Repository layout

```text
azure-iac-challenge/
├── README.md
├── versions.tf
├── providers.tf
├── variables.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── terraform.tfvars.example
├── cloud-init/
│   └── nginx.yaml
└── modules/
    ├── network/
    ├── keyvault/
    ├── app_gateway/
    ├── compute/
    ├── sql_managed_instance/
    ├── private_endpoints/
    ├── dns/
    └── monitoring/
```
