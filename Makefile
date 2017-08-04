PWD = $(shell pwd)
ENV = dev
DOCKER_TARGET = ubuntu-16.04
DOCKER_FILE = docker/Dockerfile.$(DOCKER_TARGET)
DOCKER_TAG = mineradmin-build-$(ENV)-$(DOCKER_TARGET)

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

.PHONY: version release

all: release

version:
	@echo -n "$(VERSION)" > VERSION
	@echo "$$CLIENT_VERSION" > mineradmin-client/lib/mineradmin/client/version.rb
	@echo "$$MINERD_VERSION" > minerd/lib/minerd/version.rb
	@echo "$$MINERDCTL_VERSION" > minerdctl/lib/minerdctl/version.rb

release:
	docker build --tag=$(DOCKER_TAG) -f $(DOCKER_FILE) .
	docker run \
	    -v "$(PWD)"/releases:/opt/mineradmin/releases \
	    -v "$(PWD)"/haveapi:/opt/mineradmin/haveapi \
	    -v "$(PWD)"/haveapi_client:/opt/mineradmin/haveapi_client \
	    --env MIX_ENV=$(ENV) \
	    $(DOCKER_TAG) mix do deps.get, release --name=all --env=$(ENV)
