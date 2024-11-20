#!/usr/bin/env bash
set -x

ABI_DIR=./deployments/abi/

forge build --silent

for contract in OVMClient OVMGateway
do
  # extract abi and bin files
  forge inspect ${contract} abi > ${ABI_DIR}/${contract}.abi
done
