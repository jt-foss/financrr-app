# Money

Your personal finance manager.

## Swagger-UI

We have a swagger-ui instance running at `http://localhost:8080/swagger-ui/`.<br>
**Be aware that you have to change the url based on your settings. (`.env` config file and/or reverse proxies)**<br>
You can use it to test the API and to get a better understanding of the API.

## We only support PostgreSQL!!!

There is no exception to this rule.<br>
We just include the PostgreSQL driver in our application.<br>
There is no way to use another database!

**Why is that?**<br>

- easier to develop, maintain and test
- we can optimize both (the database and the application) for each other -> better performance

## Planned

- Publish to Dockerhub and supply installation instructions

## Docker

We use docker to run the application.<br>
It is designed to run behind a reverse proxy.<br>
To run it:

1. execute `sudo bin/build.bash`
2. execute `docker compose up -d`

## Related Projects

Here a projects listed that are related to this project.

- [Eh-Kurz GUI](https://github.com/DenuxPlays/EhKurz-Web) A GUI for this project.

## Development

We use docker in two different ways.<br>
In development we use docker to only run the database and (if you want) pgAdmin.<br>
We do this with the following command: `docker compose up -d db pgadmin`

In production, we use docker to run the whole application.<br>
We do this with the following command: `docker compose up -d`

That's because we want to have a good development experience (we couldn't use the debugger etc.) but we also don't
want to clutter our system with a lot of dependencies.

### Requirements

- [Docker](https://www.docker.com/)
- [Rust](https://www.rust-lang.org/)  (latest stable version)

### Setup

1. execute `bin/install.bash`
2. execute `sudo bin/build.bash`

