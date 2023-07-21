package main

"tidb-dashboard": {
	alias: "tidbcluster"
	annotations: {}
	attributes: workload: type: "autodetects.core.oam.dev"
	description: "Tidb dashboard"
	labels: {}
	type: "component"
}

// #Cluster: {name: string}

template: {
	output: {
		apiVersion: "pingcap.com/v1alpha1"
		kind:       "TidbDashboard"
		metadata: name: context.name
		spec: parameter
	}

	parameter: {
		// +usage=At least one of a DNS Name, URI, or IP address is required
		baseImage: *"pingcap/tidb-dashboard" | string
		version:   *"v6.5.0" | string
		clusters: [...{name: string}]
		requests: {
			cpu?:    string
			memory?: string
			storage: *"5Gi" | string
			limits?: {
				cpu?:    string
				memory?: string
			}
		}
		service: {
			type: *"ClusterIP" | "NodePort" | "LoadBalancer"
		}
	}
}
