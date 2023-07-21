package main

harbor: {
	type: "helm"
	name: "harbor"
	properties: {
		repoType:        "helm"
		url:             "https://helm.goharbor.io"
		chart:           "harbor"
		version:         "1.10.2"
		targetNamespace: parameter.namespace
		releaseName:     "harbor"
		values: {
			expose: type: parameter.serviceType
			expose: tls: {
				certSource: "secret"
				secret: {
					secretName:       "harbor-ingress"
					notarySecretName: "notary-ingress"
				}
			}
			externalURL: parameter.externalURL

			if parameter.serviceType == "ingress" && parameter.ingress != _|_ {
				expose: ingress: hosts: {
					core:   parameter.ingress.hosts.core
					notary: parameter.ingress.hosts.notary
				}

				if parameter.ingress.clusterIssuer != _|_ {
					expose: ingress: harbor: annotations: {"cert-manager.io/cluster-issuer": parameter.ingress.clusterIssuer}
					expose: ingress: notary: annotations: {"cert-manager.io/cluster-issuer": parameter.ingress.clusterIssuer}
				}
			}

			if parameter.proxy != _|_ {
				proxy: httpProxy:  parameter.proxy.httpProxy
				proxy: httpsProxy: parameter.proxy.httpsProxy
				proxy: noProxy:    parameter.proxy.noProxy
				components: ["core", "jobservice", "trivy"]
			}
		}
	}
}
