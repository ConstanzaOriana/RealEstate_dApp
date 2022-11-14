//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _id
    ) external;
}

contract Escrow {
    address payable public buyer;
    address payable public seller;
    address public inspector;
    mapping(address => uint) TotalAmount;

enum State{
	await_payment, await_delivery, completeTransaction
}

State public state;

modifier instate(State expected_state) {
	require(state == expected_state);
	_;
}

modifier onlyBuyer(){
        require(msg.sender == buyer || msg.sender == inspector);
        _;
    }

modifier onlySeller(){
	require(msg.sender == seller);
	_;
}

constructor(address payable _buyer, address payable _sender) {
	inspector = msg.sender;
	buyer = _buyer;
	seller = _sender;
	state = State.await_payment;
}

function confirm_payment() onlyBuyer instate(State.await_payment) public payable {
	state = State.await_delivery;	
}

function confirm_Delivery() onlyBuyer instate(State.await_delivery) public {
	seller.transfer(address(this).balance);
	state = State.completeTransaction;
}

function ReturnPayment() onlySeller instate(State.await_delivery) public {
	buyer.transfer(address(this).balance);
}

}
