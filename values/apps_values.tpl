applications:
%{ for microservice in microservices_list ~}
  - name: ${microservice}
    project: default
    source:
      repoURL: ${charts_repo_url}
      targetRevision: main
      path: charts
      helm:
        valueFiles:
          - ../microservices/${microservice}/environments/${environment}/values.yaml
    destination:
      server: https://kubernetes.default.svc
      namespace: ${microservices_namespace}
    syncPolicy:
      automated:
        prune: false
        selfHeal: false
      syncOptions:
        - CreateNamespace=true
%{ endfor ~}