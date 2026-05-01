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
Most Important Reference for Your Design
Azure Virtual Machines Baseline Architecture

This is the core architecture your solution is based on.

🔗 Azure VM Baseline Architecture
Open Azure Virtual Machines baseline architecture

Why this matters:

It describes an internet-facing multi-tier web application
Uses VM Scale Sets
Uses Application Gateway with WAF
Uses Key Vault
Uses private VM networking

Microsoft explicitly states this architecture is designed for:

"an internet-facing multi-tier web application deployed on separate sets of virtual machines."

That matches your Terraform challenge exactly.

Additional Recommended Reference Links

These strengthen credibility when submitting your solution.

Azure Landing Zone + VM Architecture

🔗
Azure VM baseline architecture in a landing zone

Use this when referencing:

enterprise environments
subscription structure
governance
Networking Patterns (Hub-Spoke, Security)

Found inside the Architecture Center navigation.

Relevant section includes:

Hub-spoke topology
Secure hybrid networking
Firewall patterns

These are part of the official Azure networking guidance.

What You Should Add to Your README

Use this section exactly:

## Architecture references

This solution is based on Microsoft Azure Architecture Center
reference designs:

- Azure Virtual Machines baseline architecture  
  https://learn.microsoft.com/en-us/azure/architecture/example-scenario/infrastructure/iaas-high-availability-disaster-recovery

- Azure Architecture Center  
  https://learn.microsoft.com/en-us/azure/architecture/

The design adapts these reference architectures
to support:

- Virtual Machine Scale Sets
- Azure SQL Managed Instance
- Private endpoints
- WAF-secured HTTPS ingress
- Segmented virtual networking

This dramatically increases credibility.

Which Architecture Your Design Maps To

Your topology most closely matches:

Azure VM Baseline Architecture
+
Private Endpoint Architecture
+
SQL Managed Instance Networking

That combination is expected behavior — not a mistake.

Real production designs are built from multiple references, not one.

If This Is For an Interview or Submission

Use this explanation:

This architecture is based on Azure Virtual Machines baseline
architecture from Azure Architecture Center and extended
with SQL Managed Instance and private endpoint patterns
to implement secure network segmentation.

That line alone signals:

Senior-level architecture reasoning
If You Want, I Can Also Provide
Direct links for SQL Managed Instance networking
Direct links for Private Endpoint reference architecture
Direct links for Application Gateway WAF patterns

Those would complete your reference set.
