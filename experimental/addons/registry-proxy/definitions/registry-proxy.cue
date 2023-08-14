"registry-proxy": {
	alias: ""
	annotations: {}
	attributes: workload: {
		definition: {
			apiVersion: "apps/v1"
			kind:       "Deployment"
		}
		type: "deployments.apps"
	}
	description: ""
	labels: {}
	type: "component"
}

template: {
	_configMapName: context.name + "-config"
	_secrectName:   context.name + "-htpasswd"
	_serviceName:   context.name
	_configPath:    "/etc/docker/registry"

	output: {
		apiVersion: "apps/v1"
		kind:       "Deployment"
		metadata: name: context.name
		spec: {
			replicas: 1
			selector: matchLabels: {
				"app.oam.dev/component": context.name
			}
			template: {
				metadata: labels: {
					"app.oam.dev/component": context.name
					"app.oam.dev/name":      context.name
				}
				spec: {
					containers: [{
						name:  context.name
						image: parameter.image
						if parameter.imagePullPolicy != _|_ {
							imagePullPolicy: parameter.imagePullPolicy
						}
						if parameter.imagePullSecrets != _|_ {
							imagePullSecrets: [ for v in parameter.imagePullSecrets {
								name: v
							}]
						}
						ports: [{containerPort: parameter.port}]
						if parameter.env != _|_ {
							env: parameter.env
						}
						ports: [{
							containerPort: 5000
							name:          "port-5000"
							protocol:      "TCP"
						}]
						if parameter["cpu"] != _|_ {
							resources: {
								limits: cpu:   parameter.cpu
								requests: cpu: parameter.cpu
							}
						}

						if parameter["memory"] != _|_ {
							resources: {
								limits: memory:   parameter.memory
								requests: memory: parameter.memory
							}
						}
						volumeMounts: [{
							mountPath: _configPath
							name:      "config"
						}]
					}]
					volumes: [{
						name: "config"
						projected: sources: [{
							configMap: name: _configMapName
						}, {
							secret: name: _secrectName
						}]
					}]
					// volumes: [{
					//  configMap: {
					//   defaultMode: 420
					//   name:        "config"
					//  }
					//  name: "configmap-config"
					// }, {
					//  name: "secret-htpasswd"
					//  secret: {
					//   defaultMode: 420
					//   secretName:  "htpasswd"
					//  }
					// }]
				}
			}
		}
	}

	outputs: {
		config: {
			apiVersion: "v1"
			kind:       "ConfigMap"
			metadata: name:     _configMapName
			data: "config.yml": """
version: 0.1
log:
    accesslog:
      disabled: true
level: debug
formatter: text
fields:
    service: registry
    environment: staging
storage:
    delete:
        enabled: true
    cache:
        blobdescriptor: inmemory
    filesystem:
        rootdirectory: /var/lib/registry
auth:
    htpasswd:
        realm: basic-realm
        path:  \(_configPath)/htpasswd
proxy:
    remoteurl: \(parameter.remoteURL)
http:
    addr: :\(parameter.port)
    headers:
        X-Content-Type-Options:           [nosniff]
        Access-Control-Allow-Origin:      ["*"]
        Access-Control-Allow-Methods:     ["*"]
        Access-Control-Allow-Headers:     ["Authorization Accept"]
        Access-Control-Max-Age:           [1728000]
        Access-Control-Allow-Credentials: [true]
        Access-Control-Expose-Headers:    [Docker-Content-Digest]
health:
    storagedriver:
        enabled:   true
        interval:  10s
        threshold: 3
"""
		}

		htpasswd: {
			apiVersion: "v1"
			kind:       "Secret"
			metadata: name: _secrectName
			type: "Opaque"
			stringData: htpasswd: parameter.htpasswd
		}

		service: {
			apiVersion: "v1"
			kind:       "Service"
			metadata: name: _serviceName
			spec: {
				selector: "app.oam.dev/component": context.name
				ports: [{
					port: parameter.port
				}]
				type: parameter.exposeType
			}
		}

		if parameter.domain != _|_ {
			ingress: {
				apiVersion: "networking.k8s.io/v1"
				kind:       "Ingress"
				metadata: {
					name: context.name
					annotations: "cert-manager.io/cluster-issuer": parameter.clusterIssuer
				}
				spec: {
					rules: [{
						host: parameter.domain
						http: paths: [{
							backend: service: {
								name: _serviceName
								port: number: parameter.port
							}
							path:     "/"
							pathType: "ImplementationSpecific"
						}]
					}]
					tls: [{
						hosts: [parameter.domain]
						secretName: context.name + "-ingress"
					}]
				}
			}
		}
	}

	parameter: {
		// +usage=Image for registry
		image:            *"registry:2" | string
		imagePullPolicy?: "Always" | "Never" | "IfNotPresent"
		imagePullSecrets?: [...string]

		// +usage=Number of port to expose
		port: *5000 | int

		// +usage=Specify what kind of Service you want. options: "ClusterIP", "NodePort", "LoadBalancer"
		exposeType: *"ClusterIP" | "NodePort" | "LoadBalancer"
		// +usage=Number of CPU units for the service, like `0.5` (0.5 CPU core), `1` (1 CPU core)
		cpu?: string
		// +usage=Specifies the attributes of the memory resource required for the container.
		memory?: string

		// +usage=The URL for the registry repository to be proxied
		remoteURL: *"https://registry-1.docker.io" | string
		// +usage=The htpasswd authentication backed, example: htpasswd -Bbn usename password
		htpasswd: string
		// +usage=Specify the domain for registry proxy
		domain?: string
		// +usage=Support cluster issuer of cert-manager
		clusterIssuer?: string
		// +usage=Define environment variables
		env?: [...{
			name:  string
			value: string
		}]
	}
}
