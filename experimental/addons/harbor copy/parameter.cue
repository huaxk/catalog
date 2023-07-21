package main

parameter: {
	// +usage=Service type
	serviceType: *"ingress" | "clusterIP" | "loadBalancer" | "nodePort"
	// +usage=Specify the URL for harbor
	externalURL: string
	// +usage=The clusters to install
	clusters?: [...string]
	//+usage=Namespace to deploy to, defaults to harbor
	namespace: *"harbor" | string
	//+usage=Domain for core and notary
	ingress?: {
		//+usage=Cert-manager cluster issuer
		clusterIssuer?: string
		hosts: {
			core:   *"core.harbor.domain" | string
			notary: *"notary.harbor.domain" | string
		}
	}
	proxy?: {
		httpProxy:  string
		httpsProxy: string
		noProxy:    *"127.0.0.1,localhost,.local,.internal" | string
	}
}

parameter: {
	externalURL: "https://harbor.zongqu.com.cn"
	ingress: {
		clusterIssuer: "letsencrypt"
		hosts: {
			core:   "harbor.zongqu.com.cn"
			notary: "notary.zongqu.com.cn"
		}
	}
	proxy: {
		httpProxy: "http://192.168.88.200:7890"
		httpsProxy: "http://192.168.88.200:7890"
	}
}
