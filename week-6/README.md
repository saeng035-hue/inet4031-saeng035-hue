
# Week 6, GitHub Actions and Observability

## What this does

- A GitHub Actions workflow that runs OpenTofu formatting and validation checks on pull requests that change week-5/.
- Prometheus installed on the local k3s cluster using Helm.
- A small script called pq.sh that queries Prometheus metrics.

## Requirements

- Helm
- Week 5 application running on k3s
- GitHub CLI with workflow permission

## Install Prometheus

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus \
  --version 29.35.0 \
  --namespace monitoring \
  --create-namespace \
  --values week-6/prometheus-values.yaml
```

## Ask Prometheus a question

Open a terminal and run:

```bash
kubectl port-forward --namespace monitoring service/prometheus-server 9090:80
```

In another terminal, run:

```bash
./week-6/pq.sh 'up'
```

## Remove Prometheus

```bash
helm uninstall prometheus --namespace monitoring
```

## Known limitation

Prometheus stores its metrics temporarily, so restarting its pod can erase the history. It also has no login, so the port-forward is restricted to the VM's local address.
