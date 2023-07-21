"act-runner": {
	alias: ""
	annotations: {}
	attributes: workload: definition: {
		apiVersion: "apps/v1"
		kind:       "Deployment"
	}
	description: "act runner for gitea"
	labels: {}
	type: "component"
}

template: {
	output: {
		apiVersion: "apps/v1"
		kind:       "Deployment"
		metadata: {
			labels: app: "act-runner"
			name: "act-runner"
		}
		spec: {
			replicas: 1
			selector: matchLabels: app: "act-runner"
			strategy: {}
			template: {
				metadata: labels: app: "act-runner"
				spec: {
					containers: [{
						name:  "runner"
						image: "gitea/act_runner:nightly"
						command: ["sh", "-c", "while ! nc -z localhost 2376 </dev/null; do echo 'waiting for docker daemon...'; sleep 5; done; /sbin/tini -- /opt/act/run.sh"]
						env: [{
							name:  "DOCKER_HOST"
							value: "tcp://localhost:2376"
						}, {
							name:  "DOCKER_CERT_PATH"
							value: "/certs/client"
						}, {
							name:  "DOCKER_TLS_VERIFY"
							value: "1"
						}, {
							name:  "GITEA_INSTANCE_URL"
							value: parameter.instanceUrl
						}, {
							name:  "GITEA_RUNNER_REGISTRATION_TOKEN"
							value: parameter.token
						}]
						volumeMounts: [{
							mountPath: "/certs"
							name:      "docker-certs"
						}, {
							mountPath: "/data"
							name:      "runner-data"
						}]
					}, {
						name:  "daemon"
						image: "docker:23.0.6-dind"
						securityContext: privileged: true
						env: [{
							name:  "DOCKER_TLS_CERTDIR"
							value: "/certs"
						}]
						volumeMounts: [{
							mountPath: "/certs"
							name:      "docker-certs"
						}]
					}]
					restartPolicy: "Always"
					volumes: [{
						emptyDir: {}
						name: "docker-certs"
					}, {
						name: "runner-data"
						persistentVolumeClaim: claimName: "act-runner-vol"
					}]
				}
			}
		}
	}
	outputs: "act-runner-vol": {
		apiVersion: "v1"
		kind:       "PersistentVolumeClaim"
		metadata: name: "act-runner-vol"
		spec: {
			accessModes: ["ReadWriteOnce"]
			resources: requests: storage: parameter.storage
			// storageClassName: "standard"
		}
	}
	parameter: {
		instanceUrl: string
		token: string
		storage: *"1Gi" | string
	}
}
