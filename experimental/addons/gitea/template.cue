package main

output: {
	apiVersion: "core.oam.dev/v1beta1"
	kind:       "Application"
	metadata: {
		name:      "addon-gitea"
		namespace: "vela-system"
	}
	spec: {
		components: [
			{
				type: "k8s-objects"
				name: "gitea-ns"
				properties: objects: [{
					apiVersion: "v1"
					kind:       "Namespace"
					metadata: name: parameter.namespace
				}]
			},
			gitea,
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
	}
}
