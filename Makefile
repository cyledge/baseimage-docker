NAME = cyledge/base
VERSION = latest

.PHONY: all build test tag_version release

all: build

build:
	docker build -t $(NAME):latest --rm image
	@echo "built image: cyledge/base:latest"

test:
	env NAME=$(NAME) VERSION=$(VERSION) ./test/runner.sh

tag_version: test
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F latest; then echo "$(NAME):latest is not yet built. Please run 'make build'"; false; fi
	docker tag -f $(NAME):latest $(NAME):$(VERSION) 
	@echo "tagged created: cyledge/base:$(VERSION)"

release: test
	ifeq ($(VERSION),latest)
	  $(error VERSION is set to "latest". Please set real version string for a release in Makefile)
	endif
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build && make tag_version'"; false; fi
	@if ! head -n 1 Changelog.md | grep -q '## cyLEDGE-$(VERSION)'; then echo 'Please note the release cyLEDGE-$(VERSION) in Changelog.md.' && false; fi
	docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag cyLEDGE-$(VERSION) && git push origin cyLEDGE-$(VERSION)"
