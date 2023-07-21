package main

output: {
	apiVersion: "core.oam.dev/v1beta1"
	kind:       "Application"
	metadata: {
		name:      "addon-harbor"
		namespace: "vela-system"
	}
	spec: {
		components: [
			{
				type: "k8s-objects"
				name: "harbor-ns"
				properties: objects: [{
					apiVersion: "v1"
					kind:       "Namespace"
					metadata: name: parameter.namespace
				}]
			},
			harbor,
		]
		policies: [
			{
				type: "shared-resource"
				name: "namespace"
				properties: rules: [{
					selector: resourceTypes: ["Namespace"]
				}]
			},
			{
				type: "topology"
				name: "deploy-topology"
				properties: {
					namespace: parameter.namespace
					if parameter.clusters != _|_ {
						clusters: parameter.clusters
					}
					if parameter.clusters == _|_ {
						clusterLabelSelector: {}
					}
				}
			}]
		workflow: steps: [{
			type: "deploy"
			name: "deploy-harbor"
			properties: policies: ["deploy-topology"]
		}]
	}
}
