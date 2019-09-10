# This Makefile is meant to be used by people that do not usually work
# with Go source code. If you know what GOPATH is then you probably
# don't need to bother with make.

.PHONY: grbd android ios grbd-cross evm all test clean
.PHONY: grbd-linux grbd-linux-386 grbd-linux-amd64 grbd-linux-mips64 grbd-linux-mips64le
.PHONY: grbd-linux-arm grbd-linux-arm-5 grbd-linux-arm-6 grbd-linux-arm-7 grbd-linux-arm64
.PHONY: grbd-darwin grbd-darwin-386 grbd-darwin-amd64
.PHONY: grbd-windows grbd-windows-386 grbd-windows-amd64

GOBIN = $(shell pwd)/build/bin
GO ?= latest

grbd:
	build/env.sh go run build/ci.go install ./cmd/grbd
	@echo "Done building."
	@echo "Run \"$(GOBIN)/grbd\" to launch grbd."

all:
	build/env.sh go run build/ci.go install

android:
	build/env.sh go run build/ci.go aar --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/grbd.aar\" to use the library."

ios:
	build/env.sh go run build/ci.go xcode --local
	@echo "Done building."
	@echo "Import \"$(GOBIN)/Grbd.framework\" to use the library."

test: all
	build/env.sh go run build/ci.go test

lint: ## Run linters.
	build/env.sh go run build/ci.go lint

clean:
	./build/clean_go_build_cache.sh
	rm -fr build/_workspace/pkg/ $(GOBIN)/*

# The devtools target installs tools required for 'go generate'.
# You need to put $GOBIN (or $GOPATH/bin) in your PATH to use 'go generate'.

devtools:
	env GOBIN= go get -u golang.org/x/tools/cmd/stringer
	env GOBIN= go get -u github.com/kevinburke/go-bindata/go-bindata
	env GOBIN= go get -u github.com/fjl/gencodec
	env GOBIN= go get -u github.com/golang/protobuf/protoc-gen-go
	env GOBIN= go install ./cmd/abigen
	@type "npm" 2> /dev/null || echo 'Please install node.js and npm'
	@type "solc" 2> /dev/null || echo 'Please install solc'
	@type "protoc" 2> /dev/null || echo 'Please install protoc'

# Cross Compilation Targets (xgo)

grbd-cross: grbd-linux grbd-darwin grbd-windows grbd-android grbd-ios
	@echo "Full cross compilation done:"
	@ls -ld $(GOBIN)/grbd-*

grbd-linux: grbd-linux-386 grbd-linux-amd64 grbd-linux-arm grbd-linux-mips64 grbd-linux-mips64le
	@echo "Linux cross compilation done:"
	@ls -ld $(GOBIN)/grbd-linux-*

grbd-linux-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/386 -v ./cmd/grbd
	@echo "Linux 386 cross compilation done:"
	@ls -ld $(GOBIN)/grbd-linux-* | grep 386

grbd-linux-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/amd64 -v ./cmd/grbd
	@echo "Linux amd64 cross compilation done:"
	@ls -ld $(GOBIN)/grbd-linux-* | grep amd64

grbd-linux-arm: grbd-linux-arm-5 grbd-linux-arm-6 grbd-linux-arm-7 grbd-linux-arm64
	@echo "Linux ARM cross compilation done:"
	@ls -ld $(GOBIN)/grbd-linux-* | grep arm

grbd-linux-arm-5:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-5 -v ./cmd/grbd
	@echo "Linux ARMv5 cross compilation done:"
	@ls -ld $(GOBIN)/grbd-linux-* | grep arm-5

grbd-linux-arm-6:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-6 -v ./cmd/grbd
	@echo "Linux ARMv6 cross compilation done:"
	@ls -ld $(GOBIN)/grbd-linux-* | grep arm-6

grbd-linux-arm-7:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm-7 -v ./cmd/grbd
	@echo "Linux ARMv7 cross compilation done:"
	@ls -ld $(GOBIN)/grbd-linux-* | grep arm-7

grbd-linux-arm64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/arm64 -v ./cmd/grbd
	@echo "Linux ARM64 cross compilation done:"
	@ls -ld $(GOBIN)/grbd-linux-* | grep arm64

grbd-linux-mips:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips --ldflags '-extldflags "-static"' -v ./cmd/grbd
	@echo "Linux MIPS cross compilation done:"
	@ls -ld $(GOBIN)/grbd-linux-* | grep mips

grbd-linux-mipsle:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mipsle --ldflags '-extldflags "-static"' -v ./cmd/grbd
	@echo "Linux MIPSle cross compilation done:"
	@ls -ld $(GOBIN)/grbd-linux-* | grep mipsle

grbd-linux-mips64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64 --ldflags '-extldflags "-static"' -v ./cmd/grbd
	@echo "Linux MIPS64 cross compilation done:"
	@ls -ld $(GOBIN)/grbd-linux-* | grep mips64

grbd-linux-mips64le:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=linux/mips64le --ldflags '-extldflags "-static"' -v ./cmd/grbd
	@echo "Linux MIPS64le cross compilation done:"
	@ls -ld $(GOBIN)/grbd-linux-* | grep mips64le

grbd-darwin: grbd-darwin-386 grbd-darwin-amd64
	@echo "Darwin cross compilation done:"
	@ls -ld $(GOBIN)/grbd-darwin-*

grbd-darwin-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/386 -v ./cmd/grbd
	@echo "Darwin 386 cross compilation done:"
	@ls -ld $(GOBIN)/grbd-darwin-* | grep 386

grbd-darwin-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=darwin/amd64 -v ./cmd/grbd
	@echo "Darwin amd64 cross compilation done:"
	@ls -ld $(GOBIN)/grbd-darwin-* | grep amd64

grbd-windows: grbd-windows-386 grbd-windows-amd64
	@echo "Windows cross compilation done:"
	@ls -ld $(GOBIN)/grbd-windows-*

grbd-windows-386:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/386 -v ./cmd/grbd
	@echo "Windows 386 cross compilation done:"
	@ls -ld $(GOBIN)/grbd-windows-* | grep 386

grbd-windows-amd64:
	build/env.sh go run build/ci.go xgo -- --go=$(GO) --targets=windows/amd64 -v ./cmd/grbd
	@echo "Windows amd64 cross compilation done:"
	@ls -ld $(GOBIN)/grbd-windows-* | grep amd64
