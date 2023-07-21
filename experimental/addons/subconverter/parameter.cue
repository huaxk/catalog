package main

parameter: {
	//+usage=Namespace to deploy to, defaults to subconverter
	namespace: *"subconverter" | string
	image:     *"tindy2013/subconverter:0.7.2" | string
	// +usage=Service type
	serviceType:    *"ClusterIP" | "NodePort" | "LoadBalancer"
	domain?:        string
	clusterIssuer?: string
	web?: {
		image:       *"harbor.zongqu.com.cn/library/subweb:0.0.3" | string
		serviceType: *"ClusterIP" | "NodePort" | "LoadBalancer"
		domain?:     string
	}
}

parameter: {
	domain:        "subconverter.zongqu.com.cn"
	clusterIssuer: "letsencrypt"
	web: {
		domain: "subweb.zongqu.com.cn"
	}
}
