//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract FeeCollector{

    //for identify the contract's owner, specify variable, types and determine in constructor. 
    address public owner;

    constructor() {
        owner = msg.sender;
    };

    uint256 public balance;

    //wrote receive function and describe payable and external for sending ethers.
    receive() external payable {
        balance += msg.value;
    };

    //function for the withdraw ethers. we can use 3 way to withdraw: transfer,send,call 
    function withdraw(uint256 _amount, address payable withAddress) public {
       //for secure contrat and withdraws, the caller needs to be equal to owner.
        require(msg.sender == owner, "Only owner can withdraw!" )
        // withAddress.transfer(_amount);
        withAddress.send(_amount);
        balance -= _amount;
        //for secure the all ethers in contract.
        require(_amount =< balance, "Insufficent funds.")

    }
    
}