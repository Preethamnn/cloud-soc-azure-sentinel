# Diagrams

Add sanitized architecture screenshots/diagrams here.

Before committing an Azure portal screenshot, check that it does not expose:

- subscription ID
- tenant ID
- resource ID
- email address
- public IP
- username
- access token
- secret
- private endpoint
- connection string

Recommended files:

```text
cloud-soc-architecture.png
sentinel-detection-flow.png
soar-response-flow.png
```

## Figure labels for current screenshots

Use these captions when adding the current Azure portal screenshots to the repository.

- Figure 1: Azure Resource Visualizer – soc-lab-rg resource group
- Figure 2: Logic App workflow – disable-compromised-account
- Figure 3: Logic App run history – block-malicious-ip
- Figure 4: Microsoft Defender incident – unusual number of failed sign-in attempts

```markdown
![Figure 1: Azure Resource Visualizer – soc-lab-rg resource group](./cloud-soc-architecture.png)

![Figure 2: Logic App workflow – disable-compromised-account](./disable-compromised-account-workflow.png)

![Figure 3: Logic App run history – block-malicious-ip](./block-malicious-ip-run-history.png)

![Figure 4: Microsoft Defender incident – unusual number of failed sign-in attempts](./defender-incident-unusual-sign-in-attempts.png)
```
