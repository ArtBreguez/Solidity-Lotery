// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/// @title Lotery Based on Blockchain
/// @author Arthur Gonçalves Breguez
/// @notice Use this contract to simulate a Lotery system with reward to the admin

contract Lottery {

    address payable[] public players;
    address payable public admin;

    /// @notice Emit a log when a new winner is picked
    event LogNewWinner(address indexed winner, uint prize);

    constructor(){
        admin = payable(msg.sender);
    }

    /// @notice Contract receive money from players and add them to the list
    receive() external payable {
        require(msg.value >= 1 ether, "Must be at least 1 ether");
        require(msg.sender != admin, "ADM cant play");
        players.push(payable(msg.sender));
    }

    /// @notice Return the total prize of the lottery
    function getTotalPrize() public view returns(uint) {
        return address(this).balance * 4 / 5;
    }

    /// @notice Return the comission of the admin lottery based on the total pool
    function getBalanceAdm() internal view returns(uint) {
        uint total_balance = address(this).balance;
        uint adm_balance = total_balance / 5;
        return(adm_balance);
    }
    
    /// @notice Return the prize of the winner
    /// @dev Only used after the getBalanceAdm function or it will return the total balance of contract
    function getBalanceWinner() internal view returns(uint) {
        return address(this).balance;
    }
    
    /// @notice Pick a random number based on number of players on the lottery
    function random() public view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    /// @notice Choose a random winner from the list and transfer the prize, the comission of admin and reset the players list
    function pickWinner() public {
        require(admin == msg.sender, "Not the owner");
        require(players.length >= 3, "Not enough players");
        address payable winner;
        uint prize = getTotalPrize();
        winner = players[random() % players.length];
        admin.transfer(getBalanceAdm());
        winner.transfer(getBalanceWinner());
        players = new address payable[](0);
        emit LogNewWinner(
            winner,
            prize
        );
    }
}
