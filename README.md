# Kubernetes Dashboard Installation

## Prerequisites
- cert-manager installed
- contour installed
- wildcard entry pointing to the envoy IP

## Configuration needed
- edit the username and password in install-dashboard.sh
- edit fqdn: in the kubernetes_dashboard_proxy.yaml
- edit dnsNames: in kubernetes_dashboard_cert.yaml
