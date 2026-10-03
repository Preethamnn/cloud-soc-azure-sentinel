# Security, limitations and future improvements

## Repository security

The public repository must never contain:

- subscription IDs
- tenant IDs
- resource IDs
- object IDs
- client secrets
- passwords
- API tokens
- private keys
- connection strings
- personal email addresses
- public IP addresses belonging to the lab

Use placeholders such as:

```text
<YOUR_SUBSCRIPTION_ID>
<YOUR_TENANT_ID>
<YOUR_PUBLIC_IP>
<YOUR_EMAIL>
<YOUR_RESOURCE_ID>
```

## Project limitations

The verified core project is a lab-scale deployment.

Known limitations include:

- single monitored Windows host
- single primary detection pattern
- NSG-based containment as the main automated response
- no enterprise-scale redundancy/high availability
- no multi-host correlation
- no production EDR isolation workflow
- no integrated threat-intelligence feed

## Future improvements

Potential production-oriented extensions include:

1. Microsoft Defender for Endpoint integration.
2. Threat-intelligence enrichment.
3. Multi-host and cross-source correlation.
4. Additional MITRE ATT&CK detections.
5. Analyst approval gates for high-impact actions.
6. Temporary NSG blocks with automatic expiration.
7. Trusted IP allowlists.
8. Automated rollback.
9. Centralized audit reporting.
10. Entra-joined workloads and stronger identity-aware telemetry.
