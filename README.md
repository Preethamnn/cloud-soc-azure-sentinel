# Cloud-Based SOC with Microsoft Sentinel

> **Automated Detection, Investigation and IP Blocking**

A hands-on Azure Security Operations Center (SOC) lab demonstrating an end-to-end
SIEM/SOAR workflow for detecting an RDP brute-force pattern and automatically
blocking the source IP at the Azure network layer.

## Project overview

This project was implemented in a live Microsoft Azure environment rather than
being designed only on paper.

The core workflow is:

```text
Simulated RDP brute-force activity
            |
            v
    Windows Security Events
            |
            v
    Azure Monitor Agent (AMA)
            |
            v
   Data Collection Rule (DCR)
            |
            v
    Log Analytics Workspace
            |
            v
      Microsoft Sentinel
            |
            v
     Custom KQL detection
            |
            v
      Sentinel Incident
            |
            v
      Azure Logic App
            |
            v
       Extract IP entity
            |
            v
   Azure Resource Manager API
            |
            v
   Network Security Group
            |
            v
     Deny source IP
```

## Objectives

- Deploy and monitor an Azure-hosted Windows target.
- Collect Windows Security Event telemetry with Azure Monitor Agent.
- Send selected events through a Data Collection Rule to Log Analytics.
- Use Microsoft Sentinel for detection and investigation.
- Detect repeated failed RDP authentication followed by a successful logon.
- Use an Azure Logic App as the SOAR response mechanism.
- Extract the offending IP from the Sentinel incident.
- Automatically create/update an NSG rule to deny the source IP.
- Validate the complete attack-to-response pipeline with simulated activity.

## Technology stack

| Technology | Role |
|---|---|
| Microsoft Azure | Cloud platform |
| Microsoft Sentinel | SIEM, analytics and incident management |
| Log Analytics Workspace | Central telemetry store |
| Azure Monitor Agent | Windows telemetry collection |
| Data Collection Rule | Defines telemetry collection |
| Kusto Query Language (KQL) | Detection and investigation |
| Azure Logic Apps | SOAR automation |
| Azure Resource Manager | Programmatic Azure resource changes |
| Network Security Group | Network-layer IP enforcement |
| Managed Identity | Secretless authentication for automation |

## Detection scenario

The primary scenario is an RDP brute-force pattern.

The detection focuses on:

- **Event ID 4625** — failed logon
- **Event ID 4624** — successful logon
- **Event ID 4648** — explicit credential logon
- **Event ID 4672** — special privileges assigned

The main correlation is repeated failed authentication followed by a successful
authentication from the same source/account within a defined time window.

This is mapped to MITRE ATT&CK **T1110 — Brute Force**.

See [`detections/rdp-brute-force-followed-by-success.kql`](detections/rdp-brute-force-followed-by-success.kql).

## SOAR response

When a qualifying Sentinel incident is created:

1. Sentinel triggers the Logic App.
2. The workflow evaluates the incident severity.
3. IP entities are extracted from the incident.
4. The workflow iterates through the IP entities.
5. Azure Resource Manager is called.
6. An NSG security rule is created/updated.
7. The extracted source IP is placed in a **Deny** rule.

See [`playbooks/block-malicious-ip.md`](playbooks/block-malicious-ip.md).

## Security design

The automation uses a **system-assigned managed identity** rather than storing
a long-lived secret in the workflow. The identity is granted only the Azure
permissions required for the intended NSG operation.

The project also considers safeguards against false-positive automated blocking,
including:

- trusted/allowlisted IP ranges
- higher confidence/severity thresholds
- analyst approval for lower-confidence cases
- temporary/expiring blocks
- detailed logging of automated actions

## Validation

The project was validated across the pipeline:

1. Generate simulated RDP authentication activity.
2. Confirm Windows authentication events arrive in Log Analytics.
3. Run the KQL detection and verify the expected pattern.
4. Confirm Sentinel creates the incident.
5. Confirm the Logic App executes.
6. Confirm the IP entity is extracted.
7. Confirm the NSG receives the deny rule.
8. Review Logic App run history and Sentinel incident details.

Example investigation query:

```kql
WindowsEvent
| where TimeGenerated > ago(1h)
| where Computer =~ "win-target"
| where EventID in (4624, 4625)
| project TimeGenerated, Computer, EventID
| order by TimeGenerated desc
```

Telemetry verification:

```kql
WindowsEvent
| where TimeGenerated > ago(1h)
| where Computer =~ "win-target"
| summarize Events=count(), LastEvent=max(TimeGenerated)
```

Event breakdown:

```kql
WindowsEvent
| where TimeGenerated > ago(1h)
| where Computer =~ "win-target"
| where EventID in (4624, 4625, 4648, 4672)
| summarize Count=count() by EventID
| order by Count desc
```

## Repository structure

```text
Cloud-SOC-Azure-Sentinel/
├── README.md
├── docs/
│   ├── architecture.md
│   ├── deployment-guide.md
│   └── security-and-limitations.md
├── detections/
│   └── rdp-brute-force-followed-by-success.kql
├── playbooks/
│   └── block-malicious-ip.md
├── infrastructure/
│   └── network.bicep
├── diagrams/
│   └── README.md
└── .gitignore
```

## Important note about this repository

This repository is a **sanitized portfolio/documentation version** of the
Azure lab.

It intentionally does **not** contain:

- Azure subscription IDs
- tenant IDs
- resource IDs
- object IDs
- public IP addresses
- personal email addresses
- passwords
- API keys
- access tokens
- private SSH keys
- connection strings
- other account-specific secrets

Replace placeholders locally when reproducing the environment.

## Implemented scope vs future work

The verified core project is intentionally focused on a single Windows target,
one primary brute-force detection pattern, and NSG-based automated IP
containment.

The following are future/extended capabilities rather than claims about the
core verified implementation:

- enterprise-scale IAM
- threat-intelligence feed integration
- multi-host correlation
- EDR-based response
- broader MITRE ATT&CK detection coverage
- production-scale high availability

Additional Azure SOC setup notes are included in
[`docs/deployment-guide.md`](docs/deployment-guide.md).

## Lessons learned

A major troubleshooting lesson was that low-code automation conditions must
reference the incident's actual dynamic content. A condition comparing
hard-coded text instead of the incident's severity value can silently prevent
the response branch from executing.

The Logic App run history and code view were useful for diagnosing this issue.

Another important lesson was least-privilege automation: the Logic App should
not receive broad subscription permissions simply because it needs to update
one NSG.

## Disclaimer

This repository documents a controlled security lab. Attack simulation should
only be performed against systems and accounts that you own or are explicitly
authorized to test.
