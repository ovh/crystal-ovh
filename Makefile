CRYSTAL_BIN ?= $(shell which crystal)

.PHONY: test

test:
	@$(CRYSTAL_BIN) spec -v spec/*.cr
