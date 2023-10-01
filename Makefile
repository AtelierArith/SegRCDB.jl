.phony : all build dataset test clean

DOCKER_IMAGE=segrcdbjl

all: build

build:
	-rm -f Manifest.toml docs/Manifest.toml
	docker build -t ${DOCKER_IMAGE} . --build-arg NB_UID=`id -u`
	docker compose build
	docker compose run --rm shell julia --project=@. -e 'using Pkg; Pkg.instantiate()'
	docker compose run --rm shell julia --project=docs -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'

dataset: build
	docker compose run --rm shell julia --project=@. generate_params.jl
	docker compose run --rm shell julia --threads auto --project=@. generate_dataset.jl

test: build
	docker compose run --rm shell julia -e 'using Pkg; Pkg.activate("."); Pkg.test()'

clean:
	docker compose down
	-find $(CURDIR) -name "*.ipynb" -type f -delete
	-find $(CURDIR) -name "*.ipynb_checkpoints" -type d -exec rm -rf "{}" +
	-rm -f  Manifest.toml docs/Manifest.toml
	-rm -rf docs/build
	-rm -rf SegRCDB-dataset
