If Exist that frontend (that using same .env ) : 
@GHT-NETWORK please create and point https://stg-ugglobalv2-myr.web-sample.live/
 to the frontend of https://stg-ugglobalv2.web-sample.live but is PORT 3002.

If New Frontend Setup:

Configurations to do first : 
https://prnt.sc/E46Sae9mnBOU 
http://ghtrepo.hippo-server.com/seamlessapp/3m-env/merge_requests/113
http://ghtrepo.hippo-server.com/v4system/docker-v2frontends/merge_requests/18

@GHT-NETWORK using the repo docker-v2frontends. help setup nuew frontend following the ./README.md  file on the steps with below values . 
Frontend : 
MODE = staging
GROUP = wingaming_ns2  

Agent pointing to this new setup frontend
domain :stgwingaming.web-ns2.live
port  :  3000 
agent : IABAAAA

As per the ./README.md basically this is the location of the .env files to use : 
Docker .env 
1.  docker-v2frontends
path :  /.env.[MODE]  

the laravel / api folder .env 
1. 3m-env repo 
path : ./[GROUP]/[MODE]/.env

the ui folder .env 
1.  v2nsfrontends   
path: /frontends/onix-app/env_files/new_system/[GROUP]/[MODE]/.env



