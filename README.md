# Rising Constellation

## License

This project contains parts released under different licenses:

### Images / Visuals

All images or visual assets are released under [Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)](https://creativecommons.org/licenses/by-nc/4.0/), *Copyright 2021 Clément Chassot / Loïc Lebas*.

### Music

All music files or sound assets are released under [Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)](https://creativecommons.org/licenses/by-nc/4.0/), *Copyright 2021 Jérôme Clavien*.

### Source Code

Source code is released under the MIT license, *Copyright 2021 Gil Clavien*.

## Local Setup

Running the project locally:

1. postgres (database)
2. phoenix (front+back)

### 1. Database

* `docker-compose up -d` to start a local postgres instance writing to `./pgdata`
* `mix ecto.create` to create the database
* `mix ecto.migrate` to setup the database schema
* `mix run priv/repo/seeds.exs` to insert fixtures

(using a prod DB backup locally: see [`db-restore.sh`](./db-restore.sh))

### 2. Front+Back

* `make ni`
* `mix deps.get` to fetch all dependencies
* `iex -S mix phx.server` (or simply `mix phx.server`)
* RC is now running at <http://localhost:4000>, portal at <http://localhost:4000/portal>

### Running Frontend Projects Independently

1. Disable the [corresponding watcher(s)](https://github.com/abdelaz3r/asylamba/blob/14c6a7ae18d929dab28651810a059f51f5fd1a2c/config/dev.exs#L15-L22)
2. Run the frontend project(s) manually: `npm run serve`

### Tests

* `MIX_ENV=test mix test`

## Distributed Local Setup

* Run at least two nodes:
  * `make a`
  * `make b`
  * (`make c`)

To shut down a node, type `:init.stop`

## Frontend Assets

### Vue Projects (front/(game|portal))

* For images and fonts, as `url()` in the CSS or `src=""` in HTML, put the assets in `public/` eg. `public/foo/bar.png` and reference them using `~public/foo/bar.png`
* Other static assets: put them in a subfolder of `public/`, eg. `public/media/foo.pdf` and they will become available at `/(game|portal)/media/foo.pdf`. Linking to them from of the vue projects then requires a relative link, eg. `href="media/foo.pdf`

### Phoenix (HTML or LiveView) Assets

* Assets in `/assets/static` will be available at `/`, eg. `/assets/static/FOO/logo.png` will be served at `/FOO/logo.png`

## Deployment

`make build upload`

* `make build` compiles the 3 frontends into a tar.gz and the backend as a release into a tar.gz, then extracts these archives.
* `make upload` sends these archives to a remote server.

The reason we assemble the release in a Docker image is to get a reproducible build on a linux system close to the prod servers.
Prod servers don't have access to the source code and don't have nodejs etc. installed.

### Adding a node

1. create instance from image `prod-template-1`
2. add IP as A record to nodes.rising-constellation.com
3. bashrc: export RELEASE_NODE=rc@163.172.181.27 (ip of the node), right after these (they should already be set):

```
export APPSIGNAL_PUSH_API_KEY=…
export RELEASE_COOKIE="…"
```
