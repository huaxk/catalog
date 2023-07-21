parameter: {
	clashConfig: {
		dns: {
			nameserver: ["dns.com"]
		}

		// proxies: [{
		//  name:               "xxx"
		//  type:               "trojan"
		//  server:             "IEPL.okzdns.com.cn"
		//  port:               20427
		//  password:           "f8dbad27-9a46-4672-b968-8d081fa3738d"
		//  udp:                true
		//  sni:                "cn-hinet-36.okzdns.com"
		//  "skip-cert-verify": true
		// }]
		// proxyEditor: {
		//  trojanProxy: [{
		//   name:               "剩余流量：772.55 GB"
		//   type:               "trojan"
		//   server:             "IEPL.okzdns.com"
		//   port:               20427
		//   password:           "f8dbad27-9a46-4672-b968-8d081fa3738d"
		//   udp:                true
		//   sni:                "cn-hinet-36.okzdns.com"
		//   "skip-cert-verify": true
		//  }, {
		//   name:               "剩余流量：772.55 GB"
		//   type:               "trojan"
		//   server:             "IEPL.okzdns.com"
		//   port:               20427
		//   password:           "f8dbad27-9a46-4672-b968-8d081fa3738d"
		//   udp:                true
		//   sni:                "cn-hinet-36.okzdns.com"
		//   "skip-cert-verify": true
		//  }]
		//  shadowsocksProxy: [{
		//   name:     "香港5-专线-全解鎖"
		//   type:     "ss"
		//   server:   "IPLC.okztwo.com"
		//   port:     10005
		//   cipher:   "aes-256-gcm"
		//   password: "f8dbad27-9a46-4672-b968-8d081fa3738d"
		//   udp:      true
		//  }]
		// }

		// "proxy-providers": {
		//  bj: {
		//   type:     "http"
		//   path:     "./bj.yaml"
		//   url:      "http://remote.lancelinked.icu/files/hk.yaml"
		//   interval: 3600
		//   "health-check": {
		//    enable:   true
		//    url:      "http://www.gstatic.com/generate_204"
		//    interval: 300
		//   }
		//  }
		// }

		// proxyProviderEditor: [{
		//  name:     "hk"
		//  type:     "http"
		//  path:     "./hk.yaml"
		//  url:      "http://remote.lancelinked.icu/files/hk.yaml"
		//  interval: 3600
		//  "health-check": {
		//   enable:   true
		//   url:      "http://www.gstatic.com/generate_204"
		//   interval: 300
		//  }
		// }]

		// "proxy-groups": [
		//  {
		//   name:             "Direct en1"
		//   type:             "select"
		//   "interface-name": "en1"
		//   proxies: ["DIRECT"]
		//  },
		//  {
		//   name:             "Direct en0"
		//   type:             "select"
		//   "interface-name": "en0"
		//   proxies: ["DIRECT"]

		//  },
		// ]

		// "rule-providers": {
		//  "rule1": {
		//   type:     "http"
		//   behavior: "domain"
		//   url:      "http://remote.lancelinked.icu/files/hk.yaml"
		//   path:     "/rule"
		//   interval: 86400
		//  }
		// }

		// ruleProviderEditor: [{
		//  name:     "testrule"
		//  type:     "http"
		//  behavior: "domain"
		//  url:      "http://remote.lancelinked.icu/files/hk.yaml"
		//  path:     "/rule"
		//  interval: 86400
		// }]

		// rules: [
		//  "DOMAIN-SUFFIX,google.com,auto",
		//  "DOMAIN-KEYWORD,google,auto",
		//  "DOMAIN,ad.com,REJECT",
		//  "SRC-IP-CIDR,192.168.1.201/32,DIRECT",
		//  "IP-CIDR,127.0.0.0/8,DIRECT",
		//  "IP-CIDR6,2620:0:2d0:200::7/32,auto",
		//  "GEOIP,CN,DIRECT",
		//  "DST-PORT,80,DIRECT",
		//  "SRC-PORT,7777,DIRECT",
		//  "MATCH,auto",
		// ]

		"rules": [
			"RULE-SET,proxy,PROXY",
			"MATCH,DIRECT",
		]
		"proxyProviderEditor": [
			{
				"interval": 3600
				"name":     "okz2"
				"path":     "./proxies/okz2.yaml"
				"type":     "http"
				"url":      "https://proxy-provider-converter-huaxk.vercel.app/api/convert?url=https%3A%2F%2Fsub.okz2.xyz%2Fapi%2Fv1%2Fclient%2Fsubscribe%3Ftoken%3De6f89e34bc1715e29bdfe1a8a8ec29fd&target=clash"
			},
		]
		"ruleProviderEditor": [
			{
				"behavior": "domain"
				"interval": 86400
				"name":     "proxy"
				"path":     "./rules/proxy.yaml"
				"type":     "http"
				"url":      "https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/proxy.txt"
			},
		]
		"proxy-groups": [
			{
				"name": "PROXY"
				"type": "select"
				"use": [
					"okz2",
				]
				"proxies": [
					"DIRECT",
				]
			},
		]

	}
}
