# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

all: clean install build foundry-test

# Clean the repo
clean  :; forge clean

# Install the Modules
install :; forge install --no-commit

# Update Dependencies
update:; forge update

# Builds
build  :; forge build

# Tests
# --ffi # enable if you need the `ffi` cheat code on HEVM
foundry-test :; forge clean && forge test --optimize --optimizer-runs 200 -v

# Run solhint
# npm install -g solhint
solhint :; solhint -f table "{src,test,script}/**/*.sol"

# slither
# to install slither, visit [https://github.com/crytic/slither]
slither :; slither . --fail-low #--triage-mode

# mythril
mythril :
	@echo " > \033[32mChecking contracts with mythril...\033[0m"
	./tools/mythril.sh

mythx :
	@echo " > \033[32mChecking contracts with mythx...\033[0m"
	mythx analyze

# cargo install aderyn
aderyn :; aderyn .


# Lints
lint :; forge fmt

abi:
	@echo " > \033[32mGenerating abi...\033[0m"
	./tools/generateABI.sh

# Generate Gas Snapshots
snapshot :; forge clean && forge snapshot
