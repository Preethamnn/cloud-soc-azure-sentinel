# Architecture

## End-to-end flow

```text
                 Azure Cloud
                      |
          +-----------+-----------+
          |                       |
          v                       v
   Linux test/attacker      Windows target VM
                                  |
                         Windows Security Events
                                  |
                                  v
                       Azure Monitor Agent
                                  |
                                  v
                       Data Collection Rule
                                  |
                                  v
                        Log Analytics Workspace
                                  |
                                  v
                         Microsoft Sentinel
                                  |
                         KQL Analytics Rule
                                  |
                                  v
                           Incident created
                                  |
                                  v
                          Azure Logic App
                                  |
                           Get IP entities
                                  |
                                  v
                     Azure Resource Manager
                                  |
                                  v
                     Network Security Group
                                  |
                                  v
                         Deny source IP
```

## Security boundaries

- The Windows VM is the monitored target.
- Telemetry leaves the host through Azure Monitor Agent.
- Log Analytics provides centralized storage/querying.
- Sentinel performs correlation and incident generation.
- Logic Apps performs the automated response.
- NSG provides the network enforcement point.

## Identity

The Logic App uses a system-assigned managed identity. This avoids embedding
a long-lived credential in the workflow and allows Azure RBAC to scope the
automation to the resources it actually needs.
