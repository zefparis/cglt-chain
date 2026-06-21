# CGLT Chain

Réseau blockchain Ethereum privé basé sur Geth avec consensus Clique (Proof of Authority).

## Informations réseau

| Paramètre | Valeur |
|-----------|--------|
| Network Name | CGLT |
| Chain ID | 242626 |
| RPC URL | http://104.248.166.144:8545 |
| Symbol | CGLT |
| Block Time | ~5 secondes |
| Consensus | Clique (PoA) |

## Ajouter à MetaMask

1. Ouvrir MetaMask → Réseaux → Ajouter un réseau manuellement
2. Remplir avec les informations du tableau ci-dessus
3. Sauvegarder et basculer sur le réseau CGLT

## Rejoindre le réseau

### Prérequis

- [Geth v1.13+](https://geth.ethereum.org/downloads)

### Instructions

```bash
# 1. Cloner ce repo
git clone https://github.com/zefparis/cglt-chain.git
cd cglt-chain

# 2. Initialiser la base de données locale avec le bloc genesis
geth init --datadir ./data genesis.json

# 3. Lancer le nœud et se connecter au réseau
geth \
  --networkid 242626 \
  --datadir ./data \
  --port 30303 \
  --bootnodes "enode://31310629f0ed444a14e415e78c6f1a8a99d3b7d19a4707538135174f9668e0a6549971b8507b59d98a75bf4c6352743013279b8e4312cd6bd862cbd92693fd65@104.248.166.144:30303"
```

## Bootnode

```
enode://31310629f0ed444a14e415e78c6f1a8a99d3b7d19a4707538135174f9668e0a6549971b8507b59d98a75bf4c6352743013279b8e4312cd6bd862cbd92693fd65@104.248.166.144:30303
```

## Genesis

Voir [genesis.json](./node/genesis.json)

## Déploiement des contrats

1. Copier `contracts/.env.example` vers `contracts/.env`
2. Renseigner `DEPLOYER_PRIVATE_KEY` et `USDT_ADDRESS`
3. Exécuter `npm install` dans `contracts/`
4. Exécuter `npm run build`
5. Pour un déploiement de production : `npx hardhat run scripts/deploy-production.js --network cgltchain`

## Liens

- GitHub : https://github.com/zefparis/cglt-chain
