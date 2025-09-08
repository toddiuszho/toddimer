# Docker Multi-Stage Build Tips & Tricks

**NOTE:** emphasis on **Node** ecosystem

## Git

- **sparse checkout**
  - include project metadata directories
  - include workspace in monorepo you are deploying  
- **fetch depth of 1** if history not needed for things like detecting recent changes, exploring tag history

## Node

- **less output:**
  - --no-audit
  - --no-fund
  - --no-progress
  - --loglevel error
- **monorepo, but focus on single workspace**
  - npm: --no-workspaces
  - yarn: workspaces focus WORKSPACE
  - npnpm: deploy WORKSPACE
- **tooling install**
  - **NODE_PATH** envar
  - **--prefix** install option
 
## Docker

- **docker inspect IMAGE** - good image post-mortem tool
- **RUN --mount=type=secret** to inject secrets needed only at build-time, NOT in final image fs
- Header in Dockerfile `# syntax = docker/dockerfile:1` to force allowing deprecated mounting of host envar as a secret
- [Dockerfile COPY wildcard trick](https://stackoverflow.com/a/31532674)
- **DOCKER_DEBUG** envar
- **tree** command
  - `apk add --no-cache tree`
  - `tree -a /app`
  - `tree -a -I node_nodules /app # ignore node_modules`

### Docker Multi-Stage Articles

- [Yarn Workspaces](https://dev.to/siddharthvenkatesh/docker-setup-for-yarn-workspaces-4pnj)
- [Typescript](https://medium.com/@emilefugulin/building-a-sane-docker-image-for-typescript-lerna-and-prisma-2-76d8ff9926e4)
- **Members Only** [Docker Layer Caching](https://medium.com/@sohail_saifi/the-docker-layer-caching-trick-that-cut-our-build-times-by-80-6159d6115ab6)

