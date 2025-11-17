# Notes
Make sure that the below api-token isn't the global key, but a token with access to that zone.
`kubectl create secret generic cloudflare-api-key-secret --from-literal api-key=<api-token> -n cert-manager`
