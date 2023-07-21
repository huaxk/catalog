output: {
	name: "addon-tidb"
	type: "helm"
	properties: {
		repoType: "helm"
		url:      "https://charts.pingcap.org/"
		chart:    "tidb-operator"
		targetNamespace: parameter.namespace
		version:  "v1.4.1"
	}
}