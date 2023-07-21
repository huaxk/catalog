package main

gitea: {
	type: "helm"
	name: "gitea"
	properties: {
		repoType:        "helm"
		url:             "https://dl.gitea.io/charts"
		chart:           "gitea"
		version:         "8.3.0"
		targetNamespace: parameter.namespace
		releaseName:     "gitea"
		values: {
			if parameter.image != _|_ {
				image: parameter.image
			}
			if parameter.ingress != _|_ {
				ingress: {
					enabled: true
					annotations: {"cert-manager.io/cluster-issuer": parameter.ingress.clussterIssuer}
					hosts: [{
						host: parameter.ingress.host
						paths: [{
							path:     "/"
							pathType: "ImplementationSpecific"
						}]
					}]
					tls: [{
						secretName: "gitea-letsencrypt"
						hosts: [
							parameter.ingress.host,
						]
					}]
				}
			}
			if parameter.gitea != _|_ {
				gitea: parameter.gitea
			}
		}
	}
}
