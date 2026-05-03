Nordea Infrastructure as Code Challenge
Overview

This project provisions a secure, highly available web application infrastructure on Microsoft Azure using Terraform.

The solution follows a Hub-and-Spoke network topology and implements best practices for:

Network isolation
Secure access
Traffic distribution
Private service connectivity

The application itself is a simple Nginx web server deployed on a Virtual Machine Scale Set (VMSS).

Architecture Summary
High-Level Design
Hub VNet (10.50.0.0/16)
Azure Firewall (egress control)
Azure Bastion (secure admin access)
Spoke VNet (10.40.0.0/16)
Application Gateway (WAF, HTTPS entry point)
VMSS (web tier)
Private Endpoints (Key Vault + SQL)
Network Security Groups (segmentation)
Global / Platform Services
Azure Entra ID (identity & RBAC)
Azure Key Vault (secrets)
Azure SQL Database (data tier)
Azure DNS (custom domain)
Key Components
1. Compute Tier
Azure Virtual Machine Scale Set (VMSS)
Runs Nginx via cloud-init
Autoscaling-ready and highly available
2. Data Tier
Azure SQL Database
Private endpoint enabled
Public access disabled
3. Traffic Distribution
Azure Application Gateway (WAF_v2)
HTTPS listener with TLS termination
Routes traffic to VMSS backend pool
4. Security & Networking
Hub-Spoke topology with VNet peering
Azure Firewall for outbound control
NSGs to restrict traffic between tiers
Private Endpoints for PaaS services
No public access to database or Key Vault
5. DNS & Routing
Azure DNS Zone
Custom hostname mapped to Application Gateway
Local hosts file can be used for testing
Architectural Decisions
Hub-Spoke Model

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
