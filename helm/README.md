### Commands
```bash
# dry-run
helm install RELEASE CHART --debug --dry-run
helm install RELEASE CHART --debug --dry-run=server
```
### Functions
```
# lookup
lookup apiVersion, kind, namespace, name -> resource or resource list.
# Example
{{ range $index, $service := (lookup "v1" "Service" "mynamespace" "").items }}
    {{/* do something with each service */}}
{{ end }}
```

### Ref
https://helm.sh/docs/chart_template_guide/functions_and_pipelines/