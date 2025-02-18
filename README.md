# IRD

## Running locally
### Requirements
1. Local Postgres Server, with a user account capable of creating databases
2. Local Opensearch server
2. Ruby environment (tested with 3.3.7)

### Process
(from this directory)
1. `bundle install`
2. Copy the `template.env` file and name this copy `.env`
3. Edit the ENV variables in the file `.env` appropriately
4. `rails db:create`
5. `rails db:migrate`
6. `rails db:seed`
7. `rails server`

## Reindexing
`bundle exec thor index:reindex`

## Running
`rails server`


## Automated building

## Deploy to Docker

#### Base Image
This is the base image and should not need to be built frequently. It is the base image for the application image. It is built with the following command:

replace:
- `0.29` with the correct version number
- `antleaf/ird_app` with your Docker Hub username and repository name

```bash
docker buildx build -f DockerfileBase --platform linux/amd64 --push -t antleaf/ird_base:0.29 .
```

Whenever the base image is updated with a new tag, this tag needs to be referenced correctly in the application image Docker file: `DockerfileApp`.

#### Application Image

This is the application image. It is automatically built by a GitHub action when pushing to the `main` branch, but you can build it manually if you need to.

In either case, you will need to set the `IRD_APP_VERSION` env variable which is injected into the Docker image.

Ensure the base image tag is referenced correctly in the application image Docker file: `DockerfileApp`.

##### Automated Build
1. Set the `IRD_APP_VERSION` variable in the file `/DockerfileApp.env`
2. `git push`

##### Manual Build
replace:
- `0.99` with the correct version number
- `antleaf/ird_app` with your Docker Hub username and repository name

```bash
export IRD_APP_VERSION=0.99 && \
  docker buildx build -f DockerfileApp --platform linux/amd64 --build-arg IRD_APP_VERSION=$IRD_APP_VERSION --push -t antleaf/ird_app:$IRD_APP_VERSION .
```

