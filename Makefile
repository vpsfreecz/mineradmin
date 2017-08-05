PWD = $(shell pwd)
ENV = dev
TYPE = all
DOCKER_TARGET = ubuntu-16.04
DOCKER_FILE = docker/Dockerfile.$(DOCKER_TARGET)
DOCKER_TAG = mineradmin-build-$(ENV)-$(DOCKER_TARGET)
VERSION = $(shell cat VERSION)

define CLIENT_VERSION
module MinerAdmin
  module Client
    VERSION = '${VERSION}'
  end
end
endef

define MINERD_VERSION
module Minerd
  VERSION = '${VERSION}'
end
endef

define MINERDCTL_VERSION
module Minerdctl
  VERSION = '${VERSION}'
end
endef

export CLIENT_VERSION
export MINERD_VERSION
export MINERDCTL_VERSION

.PHONY: version prep release clean
.PHONY: build_core release_core core
.PHONY: mineradmin-client minerd minerdctl

all: release

version:
	@echo -n "$(VERSION)" > VERSION
	@echo "$$CLIENT_VERSION" > mineradmin-client/lib/mineradmin/client/version.rb
	@echo "$$MINERD_VERSION" > minerd/lib/minerd/version.rb
	@echo "$$MINERDCTL_VERSION" > minerdctl/lib/minerdctl/version.rb

prep:
	mkdir -p releases/$(ENV)

build_core:
	docker build --tag=$(DOCKER_TAG) -f $(DOCKER_FILE) .

release_core: prep
	docker run \
	    -v "$(PWD)"/releases:/opt/mineradmin/releases \
	    --env MIX_ENV=$(ENV) \
	    --env COOKIE=$(COOKIE) \
	    --env NODE=$(NODE) \
	    $(DOCKER_TAG) mix release --name=$(TYPE) --env=$(ENV)
	cp releases/prod/_build/core/releases/$(shell cat VERSION)/$(TYPE).tar.gz \
	   "releases/prod/$(NODE)-$(TYPE).tar.gz"

core: build_core release_core

mineradmin-client: prep
	cd mineradmin-client && rake build
	mv mineradmin-client/pkg/mineradmin-client-$(VERSION).gem releases/$(ENV)/

minerd: prep
	cd minerd && rake build
	mv minerd/pkg/minerd-$(VERSION).gem releases/$(ENV)/

minerdctl: prep
	cd minerdctl && rake build
	mv minerdctl/pkg/minerdctl-$(VERSION).gem releases/$(ENV)/

release: core mineradmin-client minerd minerdctl

clean:
	rm -rf releases/*/_build
