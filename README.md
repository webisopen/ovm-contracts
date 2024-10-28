## ovm-contracts

[![Tests](https://github.com/webisopen/ovm-contracts/actions/workflows/test.yml/badge.svg)](https://github.com/webisopen/ovm-contracts/actions/workflows/test.yml)
[![checks](https://github.com/webisopen/ovm-contracts/actions/workflows/checks.yml/badge.svg)](https://github.com/webisopen/ovm-contracts/actions/workflows/checks.yml)
[![codecov](https://codecov.io/gh/webisopen/ovm-contracts/graph/badge.svg?token=Q0GMj4Epjx)](https://codecov.io/gh/webisopen/ovm-contracts)


## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

Currently supported network:
VLS Testnet
LocalDevNet

To add new network, you need to:
1. update local .env
2. edit `./deploy-config/{chain_id}.json`, add required params.

```shell
# With verification
forge script script/Deploy.s.sol:Deploy \
--chain-id $CHAIN_ID \
--rpc-url $RPC_URL \
--private-key $PRIVATE_KEY \
--verifier-url $VERIFIER_URL \
--verifier $VERIFIER \
--verify \
--broadcast --ffi -vvvv

# Without verification
forge script script/Deploy.s.sol:Deploy \
--chain-id $CHAIN_ID \
--rpc-url $RPC_URL \
--private-key $PRIVATE_KEY \
--broadcast --ffi -vvvv


# generate easily readable abi to /deployments
forge script script/Deploy.s.sol:Deploy --sig 'sync()' --rpc-url $RPC_URL --broadcast --ffi
```
