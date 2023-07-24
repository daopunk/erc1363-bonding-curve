#  Attack Vectors: ECR777, ERC1363, SafeERC20

### ERC777 Problems & ERC1363 Proposed Solutions... and Problems

ERC777 is backwards compatible with ERC20 with additional hooks to provide user control over send and recieve functionality of specified tokens. This could prevent tokens from being sent to incorrect addresses that may not have the capacity to access the tokens; thus locking the tokens in the contract forever.

However, the hook feature allows the recieving contract to callback into the sending contract with the `tokensReceived` function, which exposes the possibility of a reentrancy attack.

ERC1363 attempts to solve this problem by reverting the transfer function back to the normal ERC20 implementation, but adding an additional function, `transferAndCall`, which reintroduces the reentrancy vulnerability.

#

### SafeERC20

Open Zeppelin created the SafeERC20, which implements `safeTransfer` and `safeTransferFrom` to address the same concerns that ERC777 and ERC1363 sought to solve. These functions also work by requiring a callback from the receiving contract to confirm that the tokens were receieved. Callbacks during a token transfer expose the possibility of reentrancy attacks if not anticipated and accounted for.
