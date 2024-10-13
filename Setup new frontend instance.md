 GHT-NETWORK  using the repo docker-v2frontends .  help setup new frontend instance following the ./README.md  file on the steps with below values . 

Staging : 
staging-firegaming-ns2-app instance 
[GROUP=firegaming-ns2] 
[APP_MODE=staging]
- Pls add these domain to point to this instance   :
Stg Test Website : https://stgfiregaming.web-ns2.live  [port=3005] 
APK API (all agents' apk  use this url): https://stg-api-firegaming-ns2.web-sample.live [port=7004]


production-firegaming-ns2-app instance 
[GROUP=firegaming-ns2] 
[APP_MODE=production]
- Pls add these domain to point to this instance   :
PRod Test Website : https://prodfiregaming.web-ns2.live  [port=3000]
Prod Demo Websites : demofiregaming.web-ns2.live , https://demo00-firegaming.web-ns2.live to demo16-firegaming.web-ns2.live  [port=3001]
APK API (all agents' apk  use this url): https://prod-api-vega-ns2.web-sample.live [port=7004]


Ald done the configurations as below , pls Pull latest for it :
http://ghtrepo.hippo-server.com/seamlessapp/3m-env/merge_requests/113
http://ghtrepo.hippo-server.com/v4system/docker-v2frontends/merge_requests/18