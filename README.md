# docker-v2frontends

This repo contains all the deployment files to server. Do not change any file locations, the files will be auto deployed using docker

## DEPLOY STEPS  --> Please follow below Steps exactly TO(must use same folder names except for the root folder): 

[APP_MODE] = Production | Staging | Streaming 
[GROUP] = wingaming-ns2 | vega | onix .... `this is defined in the .env in 3m-env repo` 


# Initial - Docker Repo 
1. on Server, create the root folder example : "[APP_MODE]-[GROUP]-v2-app"(you may also another naming method the root folder name)

2. cd to "[APP_MODE]-[GROUP]-v2-app" and git pull this repo "master" branch

- clone this repo . Do not omit the "." at the end . so that the clone will not create another directory
`git clone git@ghtrepo.hippo-server.com:v4system/docker-v2frontends.git .`

`git fetch origin`

- base on the [APP_MODE] checkout corresponding branch. Production and Streaming is always master branch. Difference between the two is that Streaming connects to staging DB (`APP_ENV = staging`)
@if [APP_MODE]  == Production  OR  [APP_MODE]  == Streaming
`git checkout -b master origin/master`
@else 
`git checkout -b release origin/release`
@endif 

3.  in `3m-env` repo, search on the GROUP and APP_MODE   e.g. `GROUP=wingaming-ns2` . then make sure the .env is having the correct `APP_MODE` e.g. `APP_MODE=production` you want.
 
 

# Cloudflare tunnel. Skip this if not using CF tunnel 
1. $ cd ./tunnel

2. copy the .env.deploy folder in same folder and rename copied file to ".env" 

3. See /docs/cloudflare_tunnel.md file on steps to configure cloudflare tunnel on CF side. 

4. after done step 7 . update the tunnel token given by CF 

5. build and run the TUNNEL image and container  ( the CF tunnel is able to use for all apps in th  AWS EC2 cloud virtual machine )  
// run below to start the tunnel container 
-- docker compose build && docker compose up --force-recreate -d 

6. make sure below Cloudflare features is disabled :
 
Email Obfuscation
Rocket Loader
Server Side Excludes (SSE)
Mirage
HTML , JS and CSS ,Minification   (including Create a page rule and set Auto Minify: Off )
Automatic HTTPS Rewrites
 


# Project 
# API PHP/laravel repo   
1. create folder name `api` at top level of the root folder ,  and run below
`cd ./api`


- clone this repo . Do not omit the "." at the end . so that the clone will not create another directory
`git clone git@ghtrepo.hippo-server.com:seamlessapp/3mplay.git . `
`git fetch origin`

- base on the [APP_MODE] checkout corresponding branch. Production and Streaming is always master branch. Difference between the two is that Streaming connects to staging DB (`APP_ENV = staging`)
@if [APP_MODE]  == Production  OR  [APP_MODE]  == Streaming
` git checkout -b master-onixv2 origin/master-onixv2 `
@else 
`git checkout -b onixv2 origin/onixv2 `
@endif 

2. using the same `.env` file from step 3 in `# Initial - Docker Repo` , put the .env file inside `./api` folder

# UI Node repo 
1. create folder name `ui` at top level of the root folder ,  and run below
`cd ./ui`

- clone this repo . Do not omit the "." at the end . so that the clone will not create another directory
` git clone git@ghtrepo.hippo-server.com:seamlessapp/v2nsfrontends.git . `
` git fetch origin `

@if [APP_MODE]  == Production  OR  [APP_MODE]  
` git checkout -b master origin/master `
@else 
` git checkout -b release origin/release `
@endif 

   
2. using the same `.env` file from step `# Initial - Docker Repo (3)` , see the [HOST_UI_PATH] and  put inside  [HOST_UI_PATH] node application folder.e.g. [HOST_UI_PATH] = `./ui/frontends/onix-app` then put inside it.

 

# BELOW is for "uploads" folder ON PRODUCTION ONLY.
5.   create folder name "uploads" at top level of the root folder ,  and run below
cd ./uploads

// clone this repo . Do not omit the "." at the end . so that the clone will not create another directory

git clone git@ghtrepo.hippo-server.com:v4system/frontend-uploads.git .
git fetch origin
git checkout -b master origin/master




# BUILDING THE CONTAINERS
`php ` container uses the "api" folder. 
`node ` container uses the "ui" folder.   
`nginx ` container contains all the agents nginx configuration
`build` container is only used during building the `node` container. is not used at runtime.
 

1. first time to build all the images and run it up as containers : 
@if this docker instance is for APK api then  
overrride_compose_yml = `-f docker-compose.override-apk-api.yml` 

command would be : 
` docker compose -f docker-compose.override-apk-api.yml build && docker compose -f docker-compose.override-apk-api.yml up --force-recreate -d `
@else 
overrride_compose_yml = ``

command would be : 
` docker compose build && docker compose up --force-recreate -d `
@end 


` docker compose {overrride_compose_yml} build && docker compose {overrride_compose_yml} up --force-recreate -d `


2. if hv changes to the php repo , is not need to build the `php` image / container. just pull latest code on server to `api` folder and the container will hv the latest chgs 

3. if hv changes to the .env for "php" container , need to restart the php container only , no need build image by doing below :
@if this docker instance is for APK api then  
overrride_compose_yml = `-f docker-compose.override-apk-api.yml` 

command would be : 
`docker compose  -f docker-compose.override-apk-api.yml up php --force-recreate -d `
@else 
overrride_compose_yml = `` 
command would be : 
 `docker compose up php --force-recreate -d ` 
@end 

3. if hv changes to the node repo or the chgs to the .env in node container , as usual is pull latest code to `ui` folder on server. but need to rebuild the `node` container (as state in docker compose.yml, this container depends on `build` and `nginx` container so these two will getre build first ): 

@if this docker instance is for APK api then  
overrride_compose_yml = `-f docker-compose.override-apk-api.yml` 

command would be :  
 ` docker compose -f docker-compose.override-apk-api.yml build build && docker compose -f docker-compose.override-apk-api.yml build nginx && docker compose -f docker-compose.override-apk-api.yml build node && docker compose -f docker-compose.override-apk-api.yml up build nginx node --force-recreate -d ` 
@else 
overrride_compose_yml = ``

command would be : 
 ` docker compose build build && docker compose build nginx && docker compose build node && docker compose up build nginx node --force-recreate -d ` 

@end 

` docker compose {overrride_compose_yml} build build && docker compose {overrride_compose_yml} build nginx && docker compose {overrride_compose_yml} build node && docker compose {overrride_compose_yml}  up build nginx node --force-recreate -d `
 
4. if hv changes to nginx configs , is pull latest this docker repo only, no need to rebuild any images. just recreate the container

@if this docker instance is for APK api then  
overrride_compose_yml = `-f docker-compose.override-apk-api.yml` 

command would be : 
`docker compose  -f docker-compose.override-apk-api.yml up nginx --force-recreate -d `
@else 
overrride_compose_yml = ``

command would be : 
 `docker compose up nginx --force-recreate -d ` 
@end 

`docker compose {overrride_compose_yml} up nginx --force-recreate -d `

5.  but if have changes to the entrypoint.sh files , need to rebuild the image 


# Additional Useful Docker commands :

//build and run individual service container
docker compose build ${SERVICE_CONTAINER_NAME} && docker compose up ${SERVICE_CONTAINER_NAME}  --force-recreate -d
e.g. docker compose build nginx && docker compose up nginx --force-recreate -d


# Additional Useful Git operations :
//Navigate to the local repository directory using the cd command.
//Check the current remote repositories by running the following command:
git remote -v

//check current branch 
git branch --show-current

//To add a remote repository, use the following command:
git remote add <remote-name> <remote-url>
//e.g
git remote add origin https://github.com/username/repo.git


//If  you want to update the URL of an existing remote repository, use the following command:
git remote set-url <remote-name> <new-remote-url>