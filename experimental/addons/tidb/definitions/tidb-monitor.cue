package main

"tidb-monitor": {
	alias: "tidbmonitor"
	annotations: {}
	attributes: workload: type: "autodetects.core.oam.dev"
	description: "Tidb monitor"
	labels: {}
	type: "component"
}

// #PvReclaimPolicy: *"Retain" | "Recycle" | "Delete"
// #ServiceType:      *"ClusterIP" | "NodePort" | "LoadBalancer"

template: {
	output: {
		apiVersion: "pingcap.com/v1alpha1"
		kind:       "TidbMonitor"
		metadata: name: context.name
		spec: parameter
	}

	parameter: {
		// +usage=At least one of a DNS Name, URI, or IP address is required
		clusters: [...{
			name:       string
			namespace?: string
		}]
		replicas:          *1 | int
		pvReclaimPolicy:   *"Retain" | "Recycle" | "Delete"
		persistent:        *false | bool
		storageClassName?: string
		storage?:          string
		prometheus: {
			baseImage: *"prom/prometheus" | string
			version:   *"v2.27.1" | string
			requests: {
				cpu?:    string
				memory?: string
				limits?: {
					cpu?:    string
					memory?: string
				}
			}
			logLevel?: *"info" | string
			service: {
				// portName: "http-prometheus"
				type: *"ClusterIP" | "NodePort" | "LoadBalancer"
			}
		}
		grafana: {
			baseImage: *"grafana/grafana" | string
			version:   *"7.5.11" | string
			requests: {
				cpu?:    string
				memory?: string
				limits?: {
					cpu?:    string
					memory?: string
				}
			}
			logLevel?: *"info" | string
			service: {
				type: *"ClusterIP" | "NodePort" | "LoadBalancer"
			}
		}
		reloader: {
			baseImage: *"pingcap/tidb-monitor-reloader" | string
			version:   *"v1.0.1" | string
		}
		initializer: {
			baseImage: *"pingcap/tidb-monitor-initializer" | string
			version:   *"v6.5.0" | string
		}
		prometheusReloader?: {
			baseImage: *"quay.io/prometheus-operator/prometheus-config-reloader" | string
			version:   *"v0.49.0" | string
		}
	}
}
