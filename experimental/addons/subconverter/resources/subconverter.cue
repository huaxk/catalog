package main

subconverterPort: 25500

subconverter: {
	name: "subconverter"
	type: "webservice"
	properties: {
		image: parameter.image
		ports: [{
			port:   subconverterPort
			expose: true
		}]
		exposeType: parameter.serviceType
		livenessProbe: {
			tcpSocket: {
				port: subconverterPort
			}
			initialDelaySeconds: 5
		}
		readinessProbe: {
			tcpSocket: {
				port: subconverterPort
			}
			initialDelaySeconds: 5
		}
	}
	traits: [
		{
			type: "resource"
			properties: {
				requests: {
					cpu:    0.1
					memory: "100Mi"
				}

				limits: {
					cpu:    0.5
					memory: "500Mi"
				}
			}
		},
		if parameter.domain != _|_ {
			type: "gateway"
			properties: {
				domain: parameter.domain
				http: {
					"/": subconverterPort
				}
				secretName: "subconverter-tls"
			}
		},
		if parameter.domain != _|_ {
			_clusterIssuer: *"letsencrypt" | string
			if parameter.clusterIssuer != _|_ {
				_clusterIssuer: parameter.clusterIssuer
			}

			type: "ingress-annotation"
			properties: {
				"cert-manager.io/cluster-issuer": _clusterIssuer
			}
		},
	]
}
