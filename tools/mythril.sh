#!/usr/bin/env bash
#set -x

if [ ! -d "src" ]; then
	echo "error: script needs to be run from project root './tools/mythril.sh'"
	exit 1
fi

platform=""
if [[ "$(uname -s)" == "Darwin" ]]; then
    platform="--platform linux/amd64"
fi

echo '
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ComputingNode: "
myth analyze src/ComputingNode.sol --solc-json mythril.config.json --solv 0.8.24 --max-depth 10 --execution-timeout 900  --solver-timeout 900 &&
echo "SingleParamSingleResponse: "
myth analyze src/templates/SingleParamSingleResponse.sol --solc-json mythril.config.json --solv 0.8.24 --max-depth 10 --execution-timeout 900  --solver-timeout 900 &&
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" ' |
docker run --rm -v "$PWD":/project -i --workdir=/project --entrypoint=sh ${platform} mythril/myth
