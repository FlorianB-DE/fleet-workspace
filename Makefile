.PHONY: build

BASE_IMAGES="ubuntu" "gradle" "python" "rust"



build:
	for base in $(BASE_IMAGES) ; do \
		docker buildx build --push --platform linux/arm64/v8,linux/amd64 --tag florianbde/fleet-workspace:$$base --build-arg BASE=$$base .  ; \
	done