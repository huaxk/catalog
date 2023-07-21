package main

subweb:     _
subwebPort: 80

if parameter.web != _|_ {
	subweb: {
		name: "subweb"
		type: "webservice"
		properties: {
			image: parameter.web.image
			ports: [{
				port:   subwebPort
				expose: true
			}]
			exposeType: parameter.web.serviceType
			livenessProbe: {
				tcpSocket: {
					port: subwebPort
				}
				initialDelaySeconds: 5
			}
			readinessProbe: {
				tcpSocket: {
					port: subwebPort
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
			if parameter.web.domain != _|_ {
				type: "gateway"
				properties: {
					domain: parameter.web.domain
					http: {
						"/": subwebPort
					}
					secretName: "subweb-tls"
				}
			},
			if parameter.web.domain != _|_ {
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
}
