applications:
#-----
# bigfantech-cloud
#-----
%{ for microservice in bigfantech-cloud_microservices_list ~}
  - name: ${microservice}
    project: default
    source:
      repoURL: ${bigfantech-cloud_charts_repo_url}
      targetRevision: main
      path: charts
      helm:
        valueFiles:
          - ../microservices/${microservice}/environments/${environment}/values.yaml
    destination:
      server: https://kubernetes.default.svc
      namespace: ${bigfantech-cloud_microservices_namespace}
    syncPolicy:
      automated:
        prune: false
        selfHeal: false
      syncOptions:
        - CreateNamespace=true
%{ endfor ~}

#-----
# bigfantech-cloud AIP
#-----
%{ for microservice in bigfantech-cloud_aip_microservices_list ~}
  - name: ${microservice}
    project: default
    source:
      repoURL: ${bigfantech-cloud_aip_charts_repo_url}
      targetRevision: main
      path: charts
      helm:
        valueFiles:
          - ../microservices/${microservice}/environments/${environment}/values.yaml
    destination:
      server: https://kubernetes.default.svc
      namespace: ${bigfantech-cloud_aip_microservices_namespace}
    syncPolicy:
      automated:
        prune: false
        selfHeal: false
      syncOptions:
        - CreateNamespace=true
%{ endfor ~}