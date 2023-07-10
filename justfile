vectis-version := "v0.2.1"
vectis-contracts := "vectis_proxy vectis_factory"
set dotenv-load

build: 
  @echo "Building Optimised WASM file(s)"
  if [[ $(uname -m) =~ "arm64" ]]; then \
  docker run --rm -v "$(pwd)":/code \
    --mount type=volume,source="$(basename "$(pwd)")_cache",target=/code/target \
    --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
    --platform linux/arm64 \
    cosmwasm/workspace-optimizer-arm64:0.13; else \
  docker run --rm -v "$(pwd)":/code \
    --mount type=volume,source="$(basename "$(pwd)")_cache",target=/code/target \
    --mount type=volume,source=registry_cache,target=/usr/local/cargo/registry \
    --platform linux/amd64 \
    cosmwasm/workspace-optimizer:0.13; fi

test contract="":
  cargo test --locked --{{ if contract == "" { "workspace" } else { "package" } }} {{contract}} 


dl-vectis-contracts:
  #!/usr/bin/env bash
  if [ ! -d "vectis-wasm" ]; then \
    mkdir vectis-wasm; \
  fi
  for contract in {{vectis-contracts}}; do \
    URL="https://github.com/nymlab/vectis/releases/download/{{vectis-version}}/$contract.wasm"; \
    echo $URL; \
    curl -Lv $URL -o "./vectis-wasm/$contract.wasm"
  done

run-local:
  ./scripts/rm-local-node.sh
  ./scripts/run-test-node.sh

stop-local:
  ./scripts/rm-local-node.sh

deploy-vectis network:
  #!/usr/bin/env bash
   vectis {{network}} deploy-vectis 
  




