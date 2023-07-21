"tidb-ng-monitoring": {
	alias: "tidbngmonitoring"
	annotations: {}
	attributes: workload: type: "autodetects.core.oam.dev"
	description: "Tidb ng monitoring"
	labels: {}
	type: "component"
}

template: {
	output: {
		apiVersion: "pingcap.com/v1alpha1"
		kind:       "TidbNGMonitoring"
		metadata: name: context.name
		spec: parameter
	}

	parameter: {
		// +usage=At least one of a DNS Name, URI, or IP address is required
		clusters: [...{
			name:           string
			namespace?:     string
			clusterDomain?: string
		}]
		configUpdateStrategy: "InPlace" | *"RollingUpdate"
		pvReclaimPolicy:      *"Retain" | "Recycle" | "Delete"
		ngMonitoring: {
			baseImage: *"pingcap/ng-monitoring" | string
			version:   *"v6.5.0" | string
			requests: {
				cpu?:    string
				memory?: string
				storage: *"5Gi" | string
				limits?: {
					cpu?:    string
					memory?: string
				}
			}
			config?: string
		}

	}
}
