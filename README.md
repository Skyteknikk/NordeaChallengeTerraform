##  Solution Overview

This project provisions a Tiered  VM based Scalable Azure Web Application (Compute + Data Tier) provided by SQL Database Provisioned using Terraform. 
The solution emphasizes cost-efficiency, security, and enterprise-grade best practices.
Since its a single region demo, the deployment has not used features like Azure Front door or CDN, the solution does not implement high availability in respect of production solution architecture.
The solution may also be low on Performance Efficiency if it cannot be scaled

### Solution Architecture Diagram

 ![Architectural](https://github.com/Skyteknikk/NordeaChallengeTerraform/blob/main/docs/Topology1.JPG)
This repository contains terraform code to deploy a stand alone Web app Azure App Services basic architecture.

### Solution Components Deployed

```
-- Hub VNet (10.50.0.0/16)
-- Azure Firewall (egress control)
-- Azure Bastion (secure admin access)
-- Spoke VNet (10.40.0.0/16)
-- Application Gateway (WAF, HTTPS entry point)
-- VMSS (web tier)
-- Private Endpoints (Key Vault + SQL)
-- Network Security Groups (segmentation)
-- Global / Platform Services
-- Azure Entra ID (identity & RBAC)
-- Azure Key Vault (secrets)
-- Azure SQL Database (data tier)
-- Azure DNS (custom domain)
```
  
### Key Components

```
#### 1. Compute Tier
> - Azure Virtual Machine Scale Set (VMSS)
> - Runs Nginx via cloud-init
> - Autoscaling-ready and highly available

#### 2. Data Tier
> - Azure SQL Database
> - Private endpoint enabled
> - Public access disabled

#### 3. Traffic Distribution
> - Azure Application Gateway (WAF_v2)
> - HTTPS listener with TLS termination
> - Routes traffic to VMSS backend pool

#### 4. Security & Networking
> - Hub-Spoke topology with VNet peering
> - Azure Firewall for outbound control
> - NSGs to restrict traffic between tiers
> - Private Endpoints for PaaS services
> - No public access to database or Key Vault

#### 5. DNS & Routing
> - Azure DNS Zone
> - Custom hostname mapped to Application Gateway
> - Local hosts file can be used for testing
> - Architectural Decisions
> - Hub-Spoke Model

```
-  Azure Application Gateway or Azure Front Door will achieve the same thing to secure ingress in this deployment we go with Application Gateway
-  Azure Key Vault is always recommended for secrets management either used by the application or database.

### Reference for the Architecture

[Basic SetApp](https://learn.microsoft.com/en-us/azure/architecture/web-apps/app-service/architectures/basic-web-app)
[Enterprise Deployment] (https://learn.microsoft.com/en-us/azure/architecture/web-apps/app-service-environment/architectures/ase-standard-deployment)

[Best Practices] (https://learn.microsoft.com/en-us/azure/well-architected/service-guides/app-service-web-apps)


### How the solution is setup


```
Microsoft Entra ID
└─ Authenticates Terraform user/service principal
└─ Provides managed identities and RBAC for Key Vault access

Hub VNet: vnet-hub-nordea-challenge-dev
├─ AzureFirewallSubnet
│  └─ Azure Firewall
│     └─ Central outbound inspection/control
│
├─ AzureBastionSubnet
│  └─ Azure Bastion
│     └─ Secure admin access to private VMs
│
└─ Public IPs
   ├─ Firewall Public IP
   └─ Bastion Public IP

Spoke VNet: vnet-nordea-challenge-dev
├─ snet-appgw
│  └─ Application Gateway WAF v2
│     └─ Public HTTPS entry point
│
├─ snet-web
│  └─ Linux VM Scale Set
│     └─ Nginx web tier
│
├─ snet-private-endpoints
│  ├─ Private Endpoint for Azure SQL Database
│  └─ Private Endpoint for Key Vault
│
└─ Route Table
   └─ 0.0.0.0/0 → Azure Firewall private IP

Private DNS Zones
├─ privatelink.database.windows.net
│  └─ Resolves Azure SQL private endpoint
│
└─ privatelink.vaultcore.azure.net
   └─ Resolves Key Vault private endpoint

Standalone / PaaS resources
├─ Azure SQL Database
│  └─ Public access disabled
│
├─ Azure Key Vault
│  └─ Public network access disabled
│
├─ Azure DNS zone
│  └─ nordea.local
│
└─ Log Analytics Workspace
   └─ Central diagnostics/log collection
```

## Project Structure


```
webapp-sql-terraform/
│
├── main.tf                # Main infrastructure definitions
├── variables.tf           # All input variables
├── terraform.tfvars       # Actual values for variables
├── outputs.tf             # Outputs like WebApp URL
│
└── .github/
    └── workflows/
        └── deploy.yml     # GitHub Actions CI/CD workflow
```

This project provisions a secure, highly available web application infrastructure on Microsoft Azure using Terraform.

The solution follows a Hub-and-Spoke network topology and implements best practices for:

Network isolation
Secure access
Traffic distribution
Private service connectivity

The application itself is a simple Nginx web server deployed on a Virtual Machine Scale Set (VMSS).

### Architecture Summary (High-Level Design)



Separates shared services (firewall, bastion) from application workloads.

Benefits:

Better security isolation
Centralized control
Scalable design
Azure Firewall for Egress Control

All outbound traffic from the web tier is routed via the firewall.

Why:

Enforces controlled internet access
Required for secure enterprise architecture
Solved package installation issues (apt-get)
Private Endpoints

Used for:

Key Vault
SQL Database

Why:

Eliminates public exposure
Aligns with zero-trust principles
Application Gateway (WAF)
Handles HTTPS
Provides Layer 7 load balancing
Protects against OWASP threats
Cloud-init for Configuration

Used to install and configure Nginx automatically.

Why:

Ensures full automation
No manual intervention required
Prerequisites

Before running Terraform:

Azure Subscription
Azure CLI installed and logged in:
az login
Terraform installed (>= 1.5)
How to Deploy
1. Initialize Terraform
terraform init
2. Validate Configuration
terraform validate
3. Deploy Infrastructure
terraform apply

Type:

yes
Verification
Step 1: Confirm VMSS is running
az vmss list-instances \
  --resource-group rg-nordea-challenge-dev \
  --name vmss-web-nordea-challenge-dev \
  -o table
Step 2: Test Application

If using local DNS override:

Add to hosts file:

<APP_GATEWAY_PUBLIC_IP> app.nordea.local

Then test:

Invoke-WebRequest https://app.nordea.local -SkipCertificateCheck

Expected output:

<h1>Nordea Challenge</h1>
Step 3: Backend Health
az network application-gateway show-backend-health \
  --name agw-nordea-challenge-dev \
  --resource-group rg-nordea-challenge-dev

Expected:

Healthy
Healthy
Notes / Known Limitations
Key Vault is configured with private access only; Terraform does not currently write secrets due to local execution context.
SQL Database is provisioned but not actively used by the web tier (not required for this challenge).
TLS certificate is self-signed (suitable for testing only).
Future Improvements
CI/CD pipeline (GitHub Actions)
Managed Identity integration with Key Vault
Autoscaling rules for VMSS
Replace self-signed cert with Azure-managed certificate
Observability (alerts + dashboards)
Conclusion

This solution demonstrates:

Secure Azure architecture design
Infrastructure as Code best practices
Full automation from zero to running application
Real-world enterprise patterns (Hub-Spoke, Private Link, WAF)
Author

Mutale Chewe
Senior Cloud Platform Engineer Candidate
Terraform Modules Used
Module	Purpose
hub_network	Firewall + Bastion hub
spoke_network	App + private resources
bastion	Secure VM access
compute	VM Scale Set (NGINX)
app_gateway	HTTPS + WAF
sql_database	Azure SQL + Private Endpoint
keyvault	Secrets management
monitoring	Log Analytics
dns	Private DNS + App record
Prerequisites

Install the following tools:

Terraform >= 1.5
Azure CLI
PowerShell
Azure Subscription

Verify:

terraform version
az version

Login:

az login

Select subscription:

az account set --subscription "<subscription-id>"
Required Files

Before running Terraform:

Create:

certs/appgw-cert.pfx

This certificate is used for:

HTTPS termination at Application Gateway

If using self-signed:

$cert = New-SelfSignedCertificate `
  -DnsName "app.nordea.local" `
  -CertStoreLocation "cert:\CurrentUser\My" `
  -KeyExportPolicy Exportable `
  -KeyLength 2048 `
  -NotAfter (Get-Date).AddYears(1)

$pwd = ConvertTo-SecureString `
  -String "ChangeMe123!" `
  -Force -AsPlainText

Export-PfxCertificate `
  -Cert $cert `
  -FilePath ".\certs\appgw-cert.pfx" `
  -Password $pwd
Terraform Initialization

Run:

terraform init

This:

Downloads providers
Initializes backend
Loads modules
Validate Configuration
terraform fmt -recursive
terraform validate
Deploy Infrastructure
terraform plan -out tfplan
terraform apply tfplan

Deployment time:

~15–25 minutes

Major resources:

Firewall
Bastion
Application Gateway
SQL Database
VM Scale Set
After Deployment

Retrieve outputs:

terraform output

Example:

app_gateway_public_ip
application_url
Configure Local DNS (Hosts File)

Edit:

C:\Windows\System32\drivers\etc\hosts

Add:

<APP_GATEWAY_PUBLIC_IP> app.nordea.local

Example:

52.174.xx.xx app.nordea.local
Verify Deployment

Open browser:

https://app.nordea.local

Expected:

NGINX welcome page

Or:

curl -k https://app.nordea.local
Security Features Implemented
Network Security
Hub-Spoke segmentation
NSGs applied per subnet
No public database access
Private endpoints enforced
Identity Security
System-assigned managed identities
Key Vault RBAC access control
Encryption
HTTPS enforced
TLS certificate configured
Azure SQL encrypted at rest
Private networking used
Traffic Inspection
Azure Firewall routing
WAF enabled on Application Gateway

OWASP WAF:

OWASP 3.2 Prevention Mode
PCI DSS Alignment

This architecture supports:

PCI Requirement	Implementation
Network Segmentation	Hub-Spoke VNet
Firewall Controls	Azure Firewall
Secure Admin Access	Azure Bastion
Encryption in Transit	HTTPS
Restricted DB Access	Private Endpoint
Logging	Log Analytics
Destroy Infrastructure

To remove all resources:

terraform destroy
Cost Considerations

Major cost drivers:

Azure Firewall
Application Gateway (WAF v2)
Bastion
VM Scale Set

Recommended:

Destroy resources after testing.
Architectural Decisions
Why Hub-and-Spoke?

Provides:

Centralized security
Easier compliance
Strong network segmentation

Used in:

Banking
Healthcare
PCI DSS workloads
Why Application Gateway?

Provides:

HTTPS termination
Layer 7 routing
Web Application Firewall
Backend load balancing
Why Private Endpoints?

Prevents:

Public internet database exposure

All database access remains:

Inside Azure private network
Why Bastion?

Removes:

Public SSH ports

Provides:

Browser-based secure access
Future Enhancements

Recommended production upgrades:

Azure Front Door
Azure DDoS Protection
Azure Sentinel integration
Multi-region deployment
Key Vault certificate automation
Private DNS forwarding
Repository Structure
.
├── modules/
│   ├── hub_network/
│   ├── spoke_network/
│   ├── bastion/
│   ├── compute/
│   ├── app_gateway/
│   ├── sql_database/
│   ├── keyvault/
│   ├── monitoring/
│   ├── dns/
│
├── cloud-init/
│   └── nginx.yaml
│
├── certs/
│   └── appgw-cert.pfx
│
├── main.tf
├── variables.tf
├── terraform.tfvars
└── README.md


## Identity Consideration

> - Us Microsoft Entra to provide a single identity control plane to manage permissions and roles for users accessing your web application. 
> - Aiming to easily integrates with App Service and simplifies authentication and authorization for web apps.

### Reliability Considerations

> - The App Service Plan is configured for the Standard tier, which doesn't have Azure availability zone support. 
> - The App Service becomes unavailable in the event of any issue with the instance, the rack, or the datacenter hosting the instance.
> - The Azure SQL Database is configured for the Basic tier, which doesn't support zone-redundancy. This means that data isn't replicated across Azure availability zones, risking loss of committed data in the event of an outage.
> - Deployments to this architecture might result in downtime with application deployments, as most deployment techniques require all running instances to be restarted. Users may experience 503 errors during this process. 
> - This deployment downtime is addressed in the baseline architecture through deployment slots. Careful application design, schema management, and application configuration handling are necessary to support concurrent slot deployment. 
> - Autoscaling isn't enabled in this basic architecture. Multi-region App Service app approaches for disaster recovery 

### Security Considerations

> - A single secure entry point for client traffic
> - Network traffic is filtered both at the packet level and at the DDoS level.
> - Data exfiltration is minimized by keeping traffic in Azure by using Private Link
> - Network resources are logically grouped and isolated from each other through network segmentation by subnets with own NSG.
> - Deployment of the Azure Web Application Firewall to protected against common exploits and vulnerabilities. 
> - Secrets are to be stored in Azure Key Vault for increased governance. 
> - Utilizing managed identity for authentication and not have secrets stored in the connection string is recommended
> - Disable local authentication to endpoints.
> - Enable Defender for App Service to generate security recommendations.
> - Azure App Service includes an SSL endpoint on a subdomain of azurewebsites.net at no extra cost. 
> - HTTP requests are redirected to the HTTPS endpoint by default and using a custom domain associated with application gateway
> - Using managed identity to authenticate to Azure SQL Server.

### Cost Optimization Considerations


The solution architecture is optimizes for cost with a few trade offs against 7 pillars of the Well-Architected Framework such as scalabity and high availability
The cost savings mainly effects the Baseline for highly available zone-redundant web application.

> - Single App Service instance, with no autoscaling enabled
> - Standard pricing tier for Azure App Service
> - No custom TLS certificate or static IP
> - Basic pricing tier for Azure SQL Database, with no backup retention policies
> - No private endpoints
> - Minimal logs and log retention period in Log Analytics

The estimated cost of this architecture can be computed using  the Pricing calculator estimate using this architecture's components.

### Operational Excellence Considerations

App configurations

App settings and connection strings are encrypted and decrypted 
Secrets are to be stored in Azure Key Vault to improve the governance of secrets.
Azure Key Vault enables the centralization of storing of secrets. 
Using Azure Key Vault enables able the logging of every interaction with secrets, including every time a secret is accessed.


### Performance Efficiency Considerations

> - Support for horizontal scaling by adjusting the number of compute instances deployed in the App Service Plan.
> - The Standard tier does support auto scale settings to allow the configuration of rule-based autoscaling. 
> - Considering production deployments, Premium tiers is recommended as it supports automatic autoscaling where the platform automatically handles scaling decisions.


## Security Considerations

- Web App traffic is secured via allowing only **HTTPS** connections
- SQL Server credentials are stored securely (use Azure Key Vault or GitHub Secrets)
- Security enhancement Suggestions: Private endpoints for SQL, Private DNS Zones for SQL and KeyVault.
- Infrastructure deployed with **Terraform** for auditability and version control

---

## Cost Optimization

- **Basic SKU** used for App Service Plan and SQL Database
- Minimum viable services deployed — scalable if needed
- Use of **tags** for cost tracking and governance

---

##  Deployment Instructions
   # Option 1
   
> - Prerequisites:
> - Terraform CLI installed
> - Azure CLI authenticated (`az login`)
> - Azure subscription assigned

### Clone your GitHub repository
git clone https://github.com/<your-org>/<your-repo>.git
cd terraform/

### Initialize Terraform
terraform init

### Review the deployment plan
terraform plan

### Apply the infrastructure
terraform apply

### Option 2

> - Visual Studio Code
> - Github Repository
> - Azure subscription assigned

git clone https://github.com/<your-org>/<your-repo>.git

### Option 2

> - Github Repo
> - Github Action


## Azure Client Credentials

We set the secrets in Github via Settings → Secrets and variables → Actions → New repository secret

Add:

```
ARM_CLIENT_ID  ..... client_id  

ARM_CLIENT_SECRET ..... client_secret 

ARM_SUBSCRIPTION_ID ...... subscription_id

ARM_TENANT_ID ..... tenant_id 

```

In deploy.yml, inject secrets as environment variables if needed.



