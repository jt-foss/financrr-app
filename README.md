# Financrr Backend

The backend for your personal finance manager.
<br>
Know your money!

## Swagger-UI

We have a swagger-ui instance running at `http://localhost:8080/swagger-ui/`.<br>
**DO NOT REMOVE THE TRAILING SLASH**
**Be aware that you have to change the url based on your settings. (`.env` config file and/or reverse proxies)**<br>
You can use it to test the API and to get a better understanding of the API.

## We only support PostgreSQL!!!

There is no exception to this rule.<br>
We just include the PostgreSQL driver in our application.<br>
There is no way to use another database!

**Why is that?**<br>

- easier to develop, maintain and test
- we can optimize both (the database and the application) for each other -> better performance

## Default Login

We provide a default user for every fresh installation.
<br>
You can log in with the following credentials:

| Username | Password    |
|----------|-------------|
| admin    | Financrr123 |

**We strongly advise you to change the password for production deployments!**

## Docker

We use docker to run the application.<br>
It is designed to run behind a reverse proxy.<br>
To run it:

1. execute `bash bin/build.bash`
2. execute `docker compose up -d`

## Development

We use docker in two different ways.<br>
In development we use docker to only run the databases.<br>
We do this with the following command: `docker compose up -d db cache`

In production, we use docker to run the whole application.<br>
We do this with the following command: `docker compose up -d`

That's because we want to have a good development experience (we couldn't use the debugger etc.) but we also don't
want to clutter our system with a lot of dependencies.

### Requirements

- [Docker](https://www.docker.com/)
- [Rust](https://www.rust-lang.org/)  (latest stable version)

### Setup

1. execute `bin/install.bash`
2. execute `bin/build.bash`
3. starte the docker containers with `docker compose up -d`
4. (optional) see the logs with `docker compose logs -f`

