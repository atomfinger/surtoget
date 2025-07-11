
generate-css:
	npx tailwindcss -o ./priv/css/tailwind.css && gzip -k -f ./priv/css/tailwind.css

gleam-format:
	gleam format

run: gleam-format generate-css 
	gleam run
