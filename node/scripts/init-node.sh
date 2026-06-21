#!/bin/bash
# Crée le compte sealer
geth account new --datadir ./data --password ./password.txt
# Init la genesis
geth init --datadir ./data ./genesis.json
echo "Node initialized. Copy the sealer address to genesis.json extradata"
