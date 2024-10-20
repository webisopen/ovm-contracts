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


```shell
forge script script/Deploy.s.sol:Deploy \
--chain-id $CHAIN_ID \
--rpc-url $RPC_URL \
--private-key $PRIVATE_KEY \
--verifier-url $VERIFIER_URL \
--verifier $VERIFIER \
--verify \
--broadcast --ffi -vvvv

# generate easily readable abi to /deployments
forge script script/Deploy.s.sol:Deploy --sig 'sync()' --rpc-url $RPC_URL --broadcast --ffi
```
