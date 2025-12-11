//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract shirleyToken is ERC20{
    constructor()
       ERC20("shirley","sy")
       {
        _mint(msg.sender,1000*10**18);
       }
}
