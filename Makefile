NAME = cyledge/base
VERSION = 0.0.2

.PHONY: all build tag_latest release

all: build

build:
	docker build -t $(NAME):latest --rm image
	@echo "built image: cyledge/base:latest"

tag_version:
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F latest; then echo "$(NAME):latest is not yet built. Please run 'make build'"; false; fi
	docker tag -f $(NAME):latest $(NAME):$(VERSION) 
	@echo "tagged created: cyledge/base:$(VERSION)"

release:
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build && make tag_version'"; false; fi
	@if ! head -n 1 Changelog.md | grep -q '## cyLEDGE-$(VERSION)'; then echo 'Please note the release cyLEDGE-$(VERSION) in Changelog.md.' && false; fi
	docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag cyLEDGE-$(VERSION) && git push origin cyLEDGE-$(VERSION)"
