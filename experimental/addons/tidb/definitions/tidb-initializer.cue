package main

"tidb-initializer": {
	alias: "tidbinitializer"
	annotations: {}
	attributes: workload: type: "autodetects.core.oam.dev"
	description: "Tidb initializer"
	labels: {}
	type: "component"
}

// #Cluster: {name: string}

template: {
	output: {
		apiVersion: "pingcap.com/v1alpha1"
		kind:       "TidbInitializer"
		metadata: name: context.name
		spec: parameter
	}

	parameter: {
		// +usage=At least one of a DNS Name, URI, or IP address is required
		image: *"tnir/mysqlclient" | string
		cluster: {
			name:           string
			namespace?:     string
			clusterDomain?: string
		}
		imagePullPolicy?:  "IfNotPresent" | "Always" | "Never"
		permitHost?:       string
		initSql?:          string
		initSqlConfigMap?: string
		passwordSecret?:   string
		resources?: {
			requests?: {
				cpu?:    string
				memory?: string
			}
			limits?: {
				cpu?:    string
				memory?: string
			}
		}
		timezone?:            string
		tlsClientSecretName?: string
		podSecurityContext?: {
			runAsUser?:           int
			runAsGroup?:          int
			fsGroup?:             int
			fsGroupChangePolicy?: string
			runAsNonRoot?:        bool
		}
	}
}
