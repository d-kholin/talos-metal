Powershell command for pulling out the argo password
`kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | %{ [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }`

Command for pulling the public cert from sealed-secrets.
`kubeseal --fetch-cert --controller-name sealed-secrets --controller-namespace kube-system`