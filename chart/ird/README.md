# IRD Helm Chart

## Tools

### Install Helm

```bash
brew install helm
```

### Linting

```bash
helm lint ./
```

### See Template combined with values in terminal

```bash
helm template ./
```
## Install / Upgrade

1. Update helm version and (optionally) app version in Chart.yaml

2. Run the command: 

```bash
helm upgrade ird \
	--install \
	--set-literal secrets.SMTP_PASSWORD=$ANTLEAF_ROBOT_SMTP_PASSWORD \
	--set-literal secrets.IRD_DB_PASSWORD=$IRD_DB_PASSWORD \
	--set-literal secrets.S3_ACCESS_KEY_ID=$ANTLEAF_S3_ACCESS_KEY \
	--set-literal secrets.S3_SECRET_ACCESS_KEY=$ANTLEAF_S3_SECRET_KEY \
	--set-literal secrets.RAILS_MASTER_KEY=$IRD_RAILS_MASTER_KEY .
```

## Install / Upgrade

```bash
helm uninstall ird
```
