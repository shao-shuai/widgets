# Scaffold-eth Notes

1. open a private browser to get a new `burner` wallet
2. how to show events in UI?
3. `https://solidity-by-example.org/interface/`, the interface example is confusing, not sure where `ICounter(_counter).count()` comes from

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Counter {
    uint public count;

    function increment() external {
        count += 1;
    }
}

interface ICounter {
    function count() external view returns (uint);

    function increment() external;
}

contract MyContract {
    function incrementCounter(address _counter) external {
        ICounter(_counter).increment();
    }

    function getCount(address _counter) external view returns (uint) {
        return ICounter(_counter).count();
    }
}
```

The above `interface` example is confusing. `Counter` contract does not have `count()` function, but `MyContract` call this function vai the interface. The reason is solidity will automatically create a `getter` function for public variable. Check [here](https://docs.soliditylang.org/en/v0.8.17/contracts.html#visibility-and-getters).

