# Make sure a user-space gh install is found
export PATH := $(HOME)/.local/bin:$(PATH)

VERSION  = $(shell node -p "require('./package.json').version")
TAG      = v$(VERSION)
ARTIFACT = goodwoolf-docs-$(TAG).zip
REPO ?= $(shell git remote get-url origin | sed -E 's#^(git@|ssh://git@|https://)[^:/]+[:/]##; s#\.git$$##')

.PHONY: release tick-version build run clean check-gh install-gh

tick-version:
	npm version patch --no-git-tag-version
	@echo "Version is now $$(node -p "require('./package.json').version")"

# Install the GitHub CLI into ~/.local/bin (Linux, no sudo).
# Skips if gh is already installed; use `make install-gh FORCE=1` to reinstall/update.
install-gh:
	@set -e; \
	if command -v gh >/dev/null 2>&1 && [ -z "$(FORCE)" ]; then \
		echo "gh already installed: $$(gh --version | head -1)"; exit 0; \
	fi; \
	[ "$$(uname -s)" = "Linux" ] || { echo "install-gh supports Linux only. On macOS use: brew install gh"; exit 1; }; \
	case "$$(uname -m)" in \
		x86_64) ARCH=amd64 ;; \
		aarch64|arm64) ARCH=arm64 ;; \
		*) echo "Unsupported arch: $$(uname -m)"; exit 1 ;; \
	esac; \
	VERSION=$$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest \
		| grep -m1 '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/'); \
	[ -n "$$VERSION" ] || { echo "Could not determine latest gh version"; exit 1; }; \
	echo "Installing gh $$VERSION ($$ARCH) to $(HOME)/.local/bin"; \
	TMP=$$(mktemp -d); \
	trap 'rm -rf "$$TMP"' EXIT; \
	curl -fsSL -o "$$TMP/gh.tgz" \
		"https://github.com/cli/cli/releases/download/v$$VERSION/gh_$${VERSION}_linux_$$ARCH.tar.gz"; \
	tar xzf "$$TMP/gh.tgz" -C "$$TMP"; \
	mkdir -p "$(HOME)/.local/bin"; \
	cp "$$TMP/gh_$${VERSION}_linux_$$ARCH/bin/gh" "$(HOME)/.local/bin/gh"; \
	echo "Installed: $$($(HOME)/.local/bin/gh --version | head -1)"; \
	echo "Next: run 'gh auth login' or set GH_TOKEN."

check-gh:
	@command -v gh >/dev/null 2>&1 || \
		(echo "gh CLI not found. Run 'make install-gh'." && exit 1)
	@gh auth status >/dev/null 2>&1 || \
		(echo "gh is not authenticated. Run 'gh auth login' or set GH_TOKEN." && exit 1)

build:
	npm run build

run:
	npm run start

.PHONY: check-version
check-version:
	@test -n "$(VERSION)" || { echo "Could not read version from pyproject.toml."; exit 1; }
	@git fetch --tags --quiet origin
	@if git rev-parse -q --verify "refs/tags/$(TAG)" >/dev/null; then \
		[ "$$(git rev-parse "$(TAG)^{commit}")" = "$$(git rev-parse HEAD)" ] || \
		{ echo "Tag $(TAG) exists but does not point at HEAD. Bump the version first."; exit 1; }; \
	fi

.PHONY: check-release
check-release:
	@test -f RELEASE.md || { echo "RELEASE.md not found."; exit 1; }
	@test -z "$$(git status --porcelain)" || \
		{ echo "Working tree has uncommitted changes. Commit them first."; exit 1; }

.PHONY: release
release: check-gh check-version check-release
	rm -rf dist
	$(MAKE) build
	rm -f $(ARTIFACT)
	(cd dist && zip -rq ../$(ARTIFACT) .)
	@git rev-parse -q --verify "refs/tags/$(TAG)" >/dev/null || git tag $(TAG)
	git push origin HEAD $(TAG)
	gh release create $(TAG) $(ARTIFACT) --repo $(REPO) --verify-tag --title "$(TAG)"

clean:
	rm -f $(ARTIFACT)
	rm -rf .docusaurus/
	rm -rf node_modules/.cache/
	rm -rf build
	npm run clear
