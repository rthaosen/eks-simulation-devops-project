#!/bin/bash
set -e

# Check if Kind cluster already exists
if kind get clusters | grep -q '^kind$'; then
  echo "⚠️ Kind cluster already exists. Skipping creation."
else
  echo "🚀 Creating Kind cluster..."
  kind create cluster --config kind-k8s-cluster/kind-config.yaml
fi

echo "📦 Installing Helm and dependencies..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "🧪 Deploying sample app..."
helm install hello-release kind-k8s-cluster/helm-chart

echo "📁 Creating dashboard configmap..."
kubectl apply -f kind-k8s-cluster/monitoring/dashboard-configmap.yaml

echo "📊 Deploying Prometheus & Grafana..."
helm install prometheus prometheus-community/prometheus \
  -f kind-k8s-cluster/monitoring/prometheus-values.yaml \
  --namespace monitoring --create-namespace

helm install grafana grafana/grafana \
  -f kind-k8s-cluster/monitoring/grafana-values.yaml

echo "⏳ Waiting for Grafana pod to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana --timeout=300s

echo "⏳ Waiting for Prometheus server to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s

echo "📁 Importing dashboard..."
DASHBOARD_FILE="kind-k8s-cluster/monitoring/dashboards/cluster-overview.json"
DASHBOARD_JSON=$(cat "$DASHBOARD_FILE")
GRAFANA_POD=$(kubectl get pods -l app.kubernetes.io/name=grafana -o jsonpath="{.items[0].metadata.name}")

kubectl exec -i "$GRAFANA_POD" -- curl -X POST -H "Content-Type: application/json" \
  -d "$DASHBOARD_JSON" \
  http://admin:admin@localhost:3000/api/dashboards/db || echo "⚠️ Failed to import dashboard"

echo "🚪 Port forwarding Grafana to localhost:3000..."
kubectl port-forward svc/grafana 3000:80 >/dev/null 2>&1 &

echo "🚪 Port forwarding hello-release app to localhost:8080..."
kubectl port-forward svc/hello-release 8080:80 >/dev/null 2>&1 &

echo "🚪 Port forwarding Prometheus to localhost:9090..."
kubectl port-forward -n monitoring svc/prometheus-server 9090:80 >/dev/null 2>&1 &

echo "✅ All services deployed successfully!"
echo ""
echo "🌐 Open hello-release app at: http://localhost:8080"
echo "🌐 Open Grafana at: http://localhost:3000"
echo "🌐 Open Prometheus at: http://localhost:9090"
echo "   Login: admin / admin"
echo ""
echo "💡 Tip: To see the app pods:"
echo "   kubectl get pods"
echo ""
echo "🔚 To stop everything:"
echo "   bash scripts/cleanup.sh"
