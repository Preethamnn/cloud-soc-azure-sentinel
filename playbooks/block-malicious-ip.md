# `block-malicious-ip` — Sentinel SOAR playbook

## Purpose

Automatically contain a high-confidence malicious source IP by creating or
updating a deny rule on the target Azure Network Security Group.

## Workflow

```text
Sentinel incident
      |
      v
Check severity
      |
      v
Get IP entities
      |
      v
For each IP
      |
      v
Azure Resource Manager
      |
      v
Create/update NSG security rule
      |
      v
Deny source address
```

## Logic App configuration

### Trigger

Use the Microsoft Sentinel incident trigger.

### Condition

The documented lab workflow used a severity condition before performing the
automated containment action.

### Entity extraction

Use the Sentinel action:

```text
Entities - Get IPs
```

The action reads IP entities associated with the incident.

### Azure Resource Manager action

Use:

```text
Create or update a resource
```

Resource provider:

```text
Microsoft.Network/networkSecurityGroups/securityRules
```

The rule properties should conceptually be:

```json
{
  "properties": {
    "direction": "Inbound",
    "access": "Deny",
    "protocol": "*",
    "sourceAddressPrefix": "<IP_ENTITY_FROM_INCIDENT>",
    "sourcePortRange": "*",
    "destinationAddressPrefix": "*",
    "destinationPortRange": "*"
  }
}
```

Do not copy an actual subscription ID or resource ID into this repository.

## Identity and permissions

The Logic App uses a system-assigned managed identity. The identity should
receive only the Azure permissions required to modify the intended NSG.

## Important production safeguards

Fully automatic IP blocking can cause false positives. A production version
should consider:

- allowlisting trusted administrator/VPN ranges
- confidence/severity thresholds
- analyst approval for borderline incidents
- automatic expiration of temporary blocks
- detailed audit logging
- rollback capability

## Troubleshooting lesson

One issue encountered during testing was a Logic App condition that compared
hard-coded text rather than the incident's dynamic severity value.

The workflow must reference the trigger's dynamic content so the condition
evaluates the actual incoming incident data.

Logic App run history and code view were used to diagnose this behavior.
