database: *[if parameter["database"] != _|_ {
"--datastore-database=" + parameter["database"]
}] | []

dbURL: *[if parameter["dbURL"] != _|_ {
"--datastore-url=" + parameter["dbURL"]
}] | []

output: {
	type: "webservice"
	properties: {
		image: parameter["repo"] + "oamdev/apiserver:" + parameter["version"]
		cmd: ["apiserver", "--datastore-type=" + parameter["dbType"]] + database + dbURL
		ports: [
			{
				port:     8000
				protocol: "TCP"
				expose:   true
			},
		]
		if parameter["serviceType"] != _|_ {
			exposeType: parameter["serviceType"]
		}
	}
	traits:[{
		type: "service-account"
		properties: name: parameter["serviceAccountName"]
	}]
}
