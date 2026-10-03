# Deployment Guide

This document is a sanitized reproduction guide derived from the original Azure
SOC setup notes.

> **Security:** Never publish your real subscription ID, tenant ID, public IP,
> credentials, SSH private key, access token, client secret, or resource ID.
> Replace placeholders locally.

## 1. Azure Cloud Shell

Use Azure Cloud Shell with Bash and Azure CLI.

Verify the active account:

```bash
az account show
```

Create the project resource group:

```bash
az group create --name soc-lab-rg --location <AZURE_REGION>
```

## 2. Network

The lab network uses a private address space:

```text
VNet       10.0.0.0/16
workload   10.0.1.0/24
management 10.0.2.0/24
```

Deploy the sanitized Bicep template:

```bash
az deployment group create \
  --resource-group soc-lab-rg \
  --template-file infrastructure/network.bicep
```

## 3. Windows target

The documented lab used an Azure Windows Server VM as the monitored target.

When creating your own VM, use your own strong credential or SSH/key-based
administration method. Do not place credentials in this repository.

After creation, assign a managed identity:

```bash
az vm identity assign \
  --resource-group soc-lab-rg \
  --name <WINDOWS_VM_NAME>
```

## 4. Telemetry collection

Configure Azure Monitor Agent and a Data Collection Rule to collect the required
Windows Security Events.

The core authentication events used by the project are:

```text
4624
4625
4648
4672
```

Verify telemetry in Sentinel/Log Analytics before creating the analytics rule.

## 5. Sentinel

Create a Log Analytics workspace and enable Microsoft Sentinel on that workspace.

The original lab used Sentinel for:

- telemetry investigation
- KQL queries
- scheduled analytics rules
- incident generation
- automation integration

## 6. Analytics rule

Create a scheduled Sentinel analytics rule using the KQL in:

```text
detections/rdp-brute-force-followed-by-success.kql
```

Map the relevant account and IP entities so that the resulting incident
contains the information required by the SOAR playbook.

## 7. SOAR

Create the Logic App described in:

```text
playbooks/block-malicious-ip.md
```

Grant its managed identity only the required Azure permissions.

## 8. Validation

Validate each stage independently:

```text
Attack activity
    ↓
WindowsEvent telemetry
    ↓
KQL query
    ↓
Sentinel incident
    ↓
Logic App run
    ↓
NSG deny rule
```

Do not test against an account or system that you are not authorized to test.

## 9. Cost controls

The original lab emphasized:

- deallocating VMs when not in use
- enabling auto-shutdown where appropriate
- manually deallocating the Kali test VM after attack simulations
- periodically checking Azure consumption
- removing the lab resource group when the project is finished

Example:

```bash
az vm deallocate \
  --resource-group soc-lab-rg \
  --name <VM_NAME>
```

Teardown:

```bash
az group delete \
  --name soc-lab-rg \
  --yes
```

## 10. Troubleshooting notes

### VM SKU unavailable

Check available sizes in your chosen region:

```bash
az vm list-skus \
  --location <AZURE_REGION> \
  --size Standard_B \
  --resource-type virtualMachines \
  --output table
```

### SSH public-key failure

Check whether the Cloud Shell SSH key exists:

```bash
ls -la ~/.ssh/
```

### Azure Monitor Agent cannot authenticate

A VM managed identity is required for the documented AMA/Sentinel setup:

```bash
az vm identity assign \
  --resource-group soc-lab-rg \
  --name <VM_NAME>
```

### Disk-full problems

Check:

```bash
df -h /
```

For the Linux lab, the original setup recommended periodic Docker and journal
cleanup:

```bash
sudo docker system prune -af
sudo journalctl --vacuum-size=200M
```

### Sentinel DCR association after VM rebuild

A VM rebuild may require recreating the DCR association. Always verify the
association after rebuilding a monitored VM.
