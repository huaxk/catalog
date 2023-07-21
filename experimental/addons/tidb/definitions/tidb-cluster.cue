"tidb-cluster": {
	alias: "tidbcluster"
	annotations: {}
	attributes: workload: type: "autodetects.core.oam.dev"
	description: "Tidb cluster"
	labels: {}
	type: "component"
}

template: {
	output: {
		apiVersion: "pingcap.com/v1alpha1"
		kind:       "TidbCluster"
		metadata: name: context.name
		spec: parameter
	}

	parameter: {
		// +usage=At least one of a DNS Name, URI, or IP address is required
		version:                    *"v6.5.0" | string
		timezone:                   *"UTC" | string
		pvReclaimPolicy:            *"Retain" | string
		enableDynamicConfiguration: *true | bool
		configUpdateStrategy:       *"InPlace" | "RollingUpdate"
		discovery?: [string]: string
		helper?: {
			image: *"alpine:3.16.0" | string
		}
		pd: {
			baseImage:        *"pingcap/pd" | string
			maxFailoverCount: *0 | int
			replicas:         *3 | int
			requests: {
				cpu?:    string
				memory?: string
				storage: *"1Gi" | string
				limits?: {
					cpu?:    string
					memory?: string
				}
			}
			storageClassName?: string
			service?: {
				type: *"ClusterIP" | "NodePorts" | "LoadBalancer"
			}
			config: *{} | string
		}
		tidb: {
			baseImage:        *"pingcap/tidb" | string
			maxFailoverCount: *0 | int
			replicas:         *3 | int
			requests: {
				cpu?:    string
				memory?: string
				limits?: {
					cpu?:    string
					memory?: string
				}
			}
			storageClassName?: string
			service?: {
				type: *"ClusterIP" | "NodePorts" | "LoadBalancer"
			}
			config: *{} | string
		}
		tikv: {
			baseImage:           *"pingcap/tikv" | string
			maxFailoverCount:    *0 | int
			replicas:            *3 | int
			evictLeaderTimeout?: string
			requests: {
				cpu?:    string
				memory?: string
				storage: *"5Gi" | string
				limits?: {
					cpu?:    string
					memory?: string
				}
			}
			storageClassName?: string
			config:            *{} | string
		}
		tiflash?: {
			baseImage:        *"pingcap/tiflash" | string
			maxFailoverCount: *0 | int
			replicas:         *1 | int
			storageClassName?: string
			config?: {
				config?: string
			}
		}
		ticdc?: {
			baseImage: *"pingcap/ticdc" | string
			replicas:  *1 | int
			storageClassName?: string
			config?:   string
		}
	}
}
