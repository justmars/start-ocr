set dotenv-load

# install dependencies
install:
  uv sync

# create .env file from example
dumpenv:
  op inject -i env.example -o .env

# serve documentation
docs:
  uv run zensical serve --dev-addr localhost:8001

# run tests
test:
  uv run pytest

# run routine checks
check: test
  uv run zensical build

# build distribution artifacts
build:
  uv build

# upload to pypi
publish:
  uv run twine upload dist/* -u __token__ -p $PYPI_TOKEN
