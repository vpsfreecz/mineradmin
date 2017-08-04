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

.PHONY: version

version:
	@echo -n "$(VERSION)" > VERSION
	@echo "$$CLIENT_VERSION" > mineradmin-client/lib/mineradmin/client/version.rb
	@echo "$$MINERD_VERSION" > minerd/lib/minerd/version.rb
	@echo "$$MINERDCTL_VERSION" > minerdctl/lib/minerdctl/version.rb
