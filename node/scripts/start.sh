#!/bin/sh

# Lance geth v1.13 avec Clique
exec geth \
  --networkid 242626 \
  --datadir /root/.ethereum \
  --http \
  --http.addr 0.0.0.0 \
  --http.port 8545 \
  --http.api eth,net,web3 \
  --http.corsdomain "http://localhost:3000,http://localhost:3001" \
  --http.vhosts "localhost" \
  --nodiscover \
  --maxpeers 0 \
  --mine \
  --miner.etherbase 0x02cc32eE2afd4335b7b2aa0D49c1844471282643 \
  --unlock 0x02cc32eE2afd4335b7b2aa0D49c1844471282643 \
  --password /root/.ethereum/password.txt \
  --gcmode archive
