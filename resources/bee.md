# Bee (EthSwarm)

Minimal configuration:

```yaml
# bee.yaml
blockchain-rpc-endpoint: https://rpc.gnosischain.com # or your own node
full-node: true | false
swap-enable: true | false # false for ultra-light node
data-directory: /home/shtuka/.bee
password-file: "" # no password file
                  # maybe easier to use one if running inside a container
                  # use podman secret
# postage-stamp-address: 
# postage-stamp-start-block: 29470428
```

Directory layout;:

```sh
~/.bee/
       keys/
            swarm.key # keys to GC address
            libp2p.key
            pss.key
       statestore/ # leveldb stuff
       localstore/ # only for full node
       swapperstore/ # full node ?
```

Pro tips:

- API up: `localhost:1633/health`

- Peer list: `localhost:1635/peers`

- State to preserve for recovery or migration:

  - EOA keypair (`$DATADIR/keys/swarm.key`, format is standard [web3 secret store](https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition)).
  - Database of used postage stamps (could be as simple as first unused).
  - Chequebook contract address, if using cheques (state channels).

  Items 2 and 3 are kept in the state db, so essentially this entire db needs to be backed up.

## Issues

RPM package dependencies not compatible with OpenSUSE (depends on `shadow-utils` but this package is called `shadow` on SUSE systems).

Wrong HTTP version (fails because this is the libp2p port!).

```sh
[root@abe6432677a3 /]# curl localhost:1634/health
curl: (1) Received HTTP/0.9 when not allowed
```



## Resources

Repos.

- Bee node (Go). https://github.com/ethersphere/bee
- Swarm CLI (Typescript). https://github.com/ethersphere/swarm-cli

Documentation.

- Node types. https://docs.ethswarm.org/docs/bee/installation/quick-start
- Secrets format. https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition