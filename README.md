# surtoget

## Prerequisites

To run this project, you need:

- [Gleam](https://gleam.run/getting-started/installing/)
- [Node.js](https://nodejs.org/en/download/) and [npm](https://www.npmjs.com/get-npm)

## Development

First, install the Node.js dependencies for Tailwind CSS:

```sh
npm install
```

Then you need to generate the actual CSS for Tailwind:

```sh
 npx tailwindcss -o ./priv/css/tailwind.css && gzip -k -f ./priv/css/tailwind.css
```

If you have [Gleam](https://gleam.run/getting-started/installing/) installed, you can use the `gleam` CLI to start a new project:

```sh
gleam new --template=surtoget my_app
cd my_app
gleam run
```

The easiest approach is to use the make commands to run the server:

```sh
make run
```

This command will:

1. Format the Gleam code.
2. Generate the Tailwind CSS file (`./priv/css/tailwind.css`).
3. Start the Gleam server.

When the server starts it starts on port 8000 and can be reached on:
[localhost:8000](http://localhost:8000)
