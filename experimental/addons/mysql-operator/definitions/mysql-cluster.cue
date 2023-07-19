"mysql-cluster": {
	annotations: {}
	attributes: {
		workload: definition: {
			apiVersion: "mysql.presslabs.org/v1alpha1"
			kind:       "MysqlCluster"
		}
		status: {
			healthPolicy: #"""
				isHealth: (context.output.status.readyNodes > 0) && (context.output.status.readyNodes == parameter.replicas)
				"""#
		}
	}
	description: ""
	labels: {}
	type: "component"
}

template: {
	output: {
		apiVersion: "mysql.presslabs.org/v1alpha1"
		kind:       "MysqlCluster"
		metadata: {
			name:      context.name
			namespace: context.namespace
		}
		spec: {
			replicas:   parameter.replicas
			secretName: _secretName

			if parameter.image != _|_ {
				image: parameter.image
			}

			if parameter.mysqlVersion != _|_ {
				mysqlVersion: parameter.mysqlVersion
			}

			if parameter.mysqlConf != _|_ {
				mysqlConf: parameter.mysqlConf
			}
			if parameter.initFileExtraSQL != _|_ {
				initFileExtraSQL: parameter.initFileExtraSQL
			}

			if parameter.queryLimits != _|_ {
				queryLimits: parameter.queryLimits
			}

			if parameter.volumeSpec != _|_ {
				if parameter.volumeSpec.emptyDir != _|_ {
					volumeSpec: emptyDir: parameter.volumeSpec.emptyDir
				}
				if parameter.volumeSpec.hostPath != _|_ {
					volumeSpec: hostPath: parameter.volumeSpec.hostPath
				}
				if parameter.volumeSpec.pvc != _|_ {
					volumeSpec: persistentVolumeClaim: {
						resources: {
							limits: storage:   parameter.volumeSpec.pvc.storage
							requests: storage: parameter.volumeSpec.pvc.storage
						}
						accessModes: parameter.volumeSpec.pvc.accessModes
						if _storageClassName != _|_ {
							storageClassName: _storageClassName
						}
						if parameter.volumeSpec.pvc.volumeMode != _|_ {
							volumeMode: parameter.volumeSpec.pvc.volumeMode
						}
						if parameter.volumeSpec.pvc.volumeName != _|_ {
							volumeName: parameter.volumeSpec.pvc.volumeName
						}
						if parameter.volumeSpec.pvc.dataSource != _|_ {
							dataSource: parameter.volumeSpec.pvc.dataSource
						}
						if parameter.volumeSpec.pvc.selector != _|_ {
							selector: parameter.volumeSpec.pvc.selector
						}
					}
				}
			}

			if parameter.imagePullSecrets != _|_ {
				podSpec: imagePullSecrets: parameter.imagePullSecrets
			}
			if parameter.imagePullPolicy != _|_ {
				podSpec: imagePullPolicy: parameter.imagePullPolicy
			}
			if parameter.cpu != _|_ {
				podSpec: resources: {
					limits: cpu:   parameter.cpu
					requests: cpu: parameter.cpu
				}
			}
			if parameter.memory != _|_ {
				podSpec: resources: {
					limits: memory:   parameter.memory
					requests: memory: parameter.memory
				}
			}
		}
	}

	outputs: {
		mysqlSecret: {
			apiVersion: "v1"
			kind:       "Secret"
			metadata: {
				name:      _secretName
				namespace: context.namespace
			}
			type: "Opaque"
			stringData: {
				ROOT_PASSWORD: parameter.rootpassword
			}
			if parameter.database != _|_ {
				stringData: DATABASE: parameter.database
			}
			if parameter.user != _|_ {
				stringData: USER: parameter.user
			}
			if parameter.password != _|_ {
				stringData: PASSWORD: parameter.password
			}
		}

		if parameter.volumeSpec.pvc != _|_ && parameter.volumeSpec.pvc.provisioner != _|_ {
			"mysql-sc": {
				apiVersion: "storage.k8s.io/v1"
				kind:       "StorageClass"
				metadata: name: _storageClassName
				provisioner:          parameter.volumeSpec.pvc.provisioner.name
				reclaimPolicy:        parameter.volumeSpec.pvc.provisioner.reclaimPolicy
				volumeBindingMode:    "WaitForFirstConsumer"
				allowVolumeExpansion: true
				if parameter.volumeSpec.pvc.provisioner.parameters != _|_ {
					parameters: parameter.volumeSpec.pvc.provisioner.parameters
				}
			}
		}
	}

	_secretName: context.name + "-mysql"

	_storageClassName?: string
	if parameter.volumeSpec.pvc != _|_ && parameter.volumeSpec.pvc.provisioner == _|_ {
		_storageClassName: parameter.volumeSpec.pvc.storageClassName
	}
	if parameter.volumeSpec.pvc != _|_ && parameter.volumeSpec.pvc.provisioner != _|_ {
		if parameter.volumeSpec.pvc.storageClassName != _|_ {
			_storageClassName: parameter.volumeSpec.pvc.storageClassName
		}
		if parameter.volumeSpec.pvc.storageClassName == _|_ {
			_storageClassName: context.namespace + "-" + context.name + "-mysql"
		}
	}

	parameter: {
		// +usage=The cluster replicas, how many nodes to deploy
		replicas: *1 | int
		// +usage=root password
		rootpassword: string
		// +usage=The database name which will be created
		database?: string
		// +usage=The name of the user that will be created
		user?: string
		// +usage=The password for the user
		password?: string
		// +usage=Specify mysql version
		mysqlVersion?: "5.6" | "5.7" | "8.0"
		// +usage=Set custom docker image or specifying mysql version, has priority over mysqlVersion
		image?: string
		// +usage=Policy for if/when to pull a container image
		imagePullSecrets?: [...string]
		// +usage=Policy for if/when to pull a container image
		imagePullPolicy?: "Always" | "Never" | "IfNotPresent"
		// +usage=Number of CPU units for
		cpu?: string
		// +usage=Specifies the attributes of the memory resource required for the container
		memory?: string
		// +usage=PVC extra specifiaction
		volumeSpec?: {
			volumeType: *"pvc" | "hostPath"
			// +usage=EmptyDir to use as data volume for mysql
			emptyDir?: {
				//+usage=What type of storage medium should back this directory
				medium?: *"" | "Memory"
				//+usage=Total amount of local storage required for this EmptyDir volume
				sizeLimit?: =~"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$"
			}
			// +usage=HostPath to use as data volume for mysql
			hostPath?: {
				//+usage=Path of the directory on the host
				path: string
				//+usage=Type for HostPath Volume defaults to ""
				type?: "Directory" | "DirectoryOrCreate" | "FileOrCreate" | "File" | "Socket" | "CharDevice" | "BlockDevice"
			}
			// +usage=PersistentVolumeClaim to specify PVC spec for the volume for mysql data
			pvc?: {
				//+usage=Represents the minimum resources the volume should have
				storage: =~"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$"
				// resources: {
				//  requests: storage: =~"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$"
				//  limits?: storage:  =~"^([1-9][0-9]{0,63})(E|P|T|G|M|K|Ei|Pi|Ti|Gi|Mi|Ki)$"
				// }
				//+usage=AccessModes contains the desired access modes the volume should have
				accessModes: *["ReadWriteOnce"] | [...string]
				//+usage=What type of volume is required by the claim, defaults to Filesystem
				volumeMode?: string
				//+usage=Binding reference to the PersistentVolume backing this claim
				volumeName?: string
				//+usage=Name of the StorageClass required by the claim
				storageClassName?: string
				//+usage=Create a separate storage class
				provisioner?: {
					name:          string
					reclaimPolicy: *"Delete" | "Retain"
					parameters?: [string]: string
				}
				//+usage=Create a new volume based on the contents of the specified data source
				dataSource?: {
					name:     string
					kind:     string
					apiGroup: string
				}
				//+usage=A label query over volumes to consider for binding
				selector?: {
					matchLabels?: [string]: string
					matchExpressions?: {
						key: string
						values: [...string]
						operator: string
					}
				}
			}
		}
		// +usage=Configs that will be added to my.cnf for cluster
		mysqlConf?: [string]: string
		// +usage=List of extra sql commands to append to init_file
		initFileExtraSQL?: [...string]
		// +usage=Enabling and configuring pt-kill
		queryLimits?: {
			// +usage=Match queries that have been running for longer then this time, in seconds (--busy-time flag)
			maxQueryTime: string
			// +usage=Match queries that have been idle for longer then this time, in seconds (--idle-time flag)
			maxIdleTime?: string
			// +usage=The mode of which the matching queries in each class will be killed (the --victims flag)
			kill?: "oldest" | "all" | "all-but-oldest"
			// +usage=A query is matched the connection is killed (using --kill flag) or the query is killed (using --kill-query flag)
			killMode?: "query" | "connection"
			// +usage=The list of commands to be ignored
			ignoreCommand?: [...string]
			// +usage=the list of database that are ignored by pt-kill (--ignore-db flag)
			ignoreDb?: [...string]
			// +usage=The list of users to be ignored
			ignoreUser?: [...string]
		}
	}
}
