#!/bin/bash

set -x

echo "Build project"
rojo build tests.project.json --output model.rbxmx

echo "Remove .robloxrc from dev dependencies"
find Packages/Dev -name "*.robloxrc" | xargs rm -f
find Packages/_Index -name "*.robloxrc" | xargs rm -f

echo "Run static analysis"
selene src
roblox-cli analyze tests.project.json
stylua -c src

echo "Run tests"
roblox-cli run --load.model model.rbxmx --run bin/spec.lua --fastFlags.allOnLuau --fastFlags.overrides "UseDateTimeType3=true" "EnableLoadModule=true"
