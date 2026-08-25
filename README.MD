# Namada Self Host
This repository helps to quickly spin up a local version of namada blockchain and some ecosystem services and tools in a matter of seconds.    
Including : 
- A Namada blockchain with 3 validators (configurable, see [Changing the number of validators](#changing-the-number-of-validators))
- Hermes for IBC transfer (by running a second namada blockchain called chain-b)


### Requirements
- Docker (or Docker Desktop on Windows/Mac) 
---

# Important!
IF YOU ARE UPGRADING THIS PACKAGE FROM OLDER VERSIONS IT IS RECOMMENDED TO REMOVE YOUR OLD `.env` FILE

## Initialize settings

Make an .env from sample file, and alter values as desired
```shell
cp .env.sample .env
```
Pull images from docker hub or build them from scratch.  
To pull images do 
```shell
docker compose --profile main pull
```
Or, build images from the dockerfile (takes more time and requires a lot of resources) :

```shell
docker compose --profile main build
```

# Run The Network

To start the blockchain with 3 validators
```shell
docker compose --profile main up -d
```
for the first time launching it give it 1-2 min to download necessary files and setup the chain. then you can use it   

## Changing the number of validators

The network runs 3 validators by default. To use a different number:

```shell
./scripts/set-validators.sh 6
```

This sets `VALIDATOR_COUNT` in your `.env` and generates a `docker-compose.override.yml`
that Compose picks up automatically, so the usual commands keep working unchanged:

```shell
docker compose --profile main up -d
```

Counts below 3 also work (`./scripts/set-validators.sh 1` gives a single-validator chain);
the surplus validators are moved out of the `main` profile rather than removed. Running
`./scripts/set-validators.sh 3` restores the default and deletes the override file.

> [!IMPORTANT]
> The validator set is fixed at genesis, so a change only takes effect on a **fresh**
> network. Tear the old one down first:
> ```shell
> docker compose --profile main down -v -t 0
> ```

`docker-compose.yml` is never modified by the script, and the generated override file is
gitignored.

#### Check logs
```shell
docker compose --profile main logs -f 
```
#### Execute commands
exec into one of the validators , e.g.
```shell
docker compose exec namada-1 bash
```
then you can run any commands over the blockchain. e.g. :
```shell
namada --version
```

there is a faucet account with huge amounts of NAM on container `namada-1`, you can use it to transfer funds to other accounts:

```bash
docker compose exec namada-1 bash
namadac transparent-transfer  --source faucet-1 --target namada-1-wallet --amount 200000 --token nam
```
for more information about commands, check the [official docs](https://docs.namada.net/users)

# Hermes and IBC transfers

> [!WARNING]
> **The Hermes setup has not been tested in a long time and may not work in this repository.**
> It has not been re-validated against recent Namada releases (including the current `v201.0.9`),
> and the pinned Hermes version has not been bumped alongside the Namada upgrades. Expect the
> `hermes` profile, chain-b bootstrap, and the IBC channel setup to need fixing before they work.
> The `main` profile (3-validator Namada network) is the supported path.

To test hermes on a Namada <> Namada channel , we need another instance of namada blockchain. this is included under hermes profile in docker compose file.   
To run chain B and the hermes container    

Pull images from docker hub or build them from scratch.  
To pull images do
```shell
docker compose --profile hermes pull
```
Or, build images from the dockerfile (takes more time and requires a lot of resources) :

```shell
docker compose --profile hermes build
```

Then run the hermes containers
```shell
docker compose --profile hermes up -d
```

this will create chain-b , another namada blockchain with single validator and sets configs on the hermes and create a channel between two blockchains.   
Hermes takes some time to be functional, so the check logs before start using it 
```shell
docker compose logs -f hermes
```
now exec into chain-b and get an address wallet from there
```shell
docker compose exec namada-chain-b bash
namadaw list
```
in another terminal exec into namada-1 and transfer any tokens to chain-b
```shell
docker compose exec namada-1 bash
namadac ibc-transfer --amount 5 --source namada-1-wallet --receiver <ADDRESS_WALLET_ON_CHAIN_B> --token nam --channel-id channel-0
```
get back into chain-b terminal, after a short time query the balance of your wallet and you should see tokens have arrived

# Tear Down
To remove everything
```shell
docker compose --profile main --profile hermes down -v -t 0
```