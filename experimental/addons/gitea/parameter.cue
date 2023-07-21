package main

parameter: {
	//+usage=Deploy to specified clusters. Leave empty to deploy to all clusters.
	clusters?: [...string]
	//+usage=Namespace to deploy to, defaults to gitea
	namespace: *"gitea" | string
	image?: {
		registry:   *"" | string
		repository: *"gitea/gitea" | string
		tag:        *"" | string
		pullPolicy: *"Always" | "IfNotPresent" | "Never"
		rootless:   *false | true
		imagePullSecrets: [...string]
	}
	//+usage=Domain for core and notary
	ingress?: {
		host: string
		//+usage=Cert-manager cluster issuer
		clusterIssuer?: string
	}
	gitea?: {
		admin?: {
			username?:       string
			password?:       string
			email?:          string
			existingSecret?: string
		}
		config?: {
			APP_NAME?: string
			server?: {
				LFS_START_SERVER?: bool
			}
			webhook?: {
				ALLOWED_HOST_LIST?: "loopback" | "private" | "external" | "*"
			}
			api?: {
				ENABLE_SWAGGER: bool
			}
			actions?: {
				ENABLED:              bool
				DEFAULT_ACTIONS_URL?: string
			}
			proxy?: {
				PROXY_ENABLED: bool
				PROXY_URL:     string
				PROXY_HOSTS?:  "*.github.com"
			}
			migrations?: {
				ALLOW_LOCALNETWORKS: bool
			}
			service?: {
				DISABLE_REGISTRATION?: bool
			}
		}
	}
}
