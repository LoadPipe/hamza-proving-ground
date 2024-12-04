# Initial Foundry Setup


```shell
$ forge install OpenZeppelin/openzeppelin-contracts --no-commit 
```

```shell
$ forge install vectorized/solady --no-commit 
$ forge install sol-dao/solbase --no-commit
$ forge install foundry-rs/forge-std --no-commit
$ forge install OpenZeppelin/openzeppelin-contracts --no-commit
```    

```shell
$ forge build
$ anvil
```

```shell
$ source .env
```

```shell
$ forge script script/Hats.s.sol:DeployHats --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

```shell
$ forge script script/DeployEscrow.s.sol:DeployEscrow --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```


