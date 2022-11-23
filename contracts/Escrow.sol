//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _id
    ) external;
}

contract Escrow{
    address public nftAddress;
    address payable public seller;
    address public inspector;

	// modifier onlyInspector => verify for "Only inspector call this method"
	modifier onlyInspector() {
		require(msg.sender == inspector);
		_;
	}

 	// modifier onlyBuyer => verify for "Only buyer call this method"
	modifier onlyBuyer(){
        require(msg.sender == buyer);
        _;
    }

	// modifier onlySeller => verify for "Only seller call this method"
	modifier onlySeller(){
	require(msg.sender == seller);
	_;
	}  
    
    
	mapping(uint256 => bool) isListed; 
	mapping(uint256 => uint256) purchasePrice;
	mapping(uint256 => uint256) escrowAmount;
	mapping(address => uint256) buyer;
	mapping(uint256 => uint256) buyerList;
	mapping(uint256 => bool) inspectionPassed;

    constructor(address _nftAddress, address payable _seller, address _inspector, address _buyer) {
        nftAddress = _nftAddress;
        seller = _seller;
        inspector = _inspector;
    }

    function list (uint256 _nftID, address _buyer, uint256 _purchasePrice, uint256 _escrowAmount) public payable onlySeller {
        // Transfer NFT from seller to this contract
        IERC721(nftAddress).transferFrom(msg.sender, address(this), _nftID);

        isListed[_nftID] = true;
        purchasePrice[_nftID] = _purchasePrice;
        escrowAmount[_nftID] = _escrowAmount;
        buyerList[_nftID] = _buyer;
    }

    // Put Under Contract (only buyer - payable escrow)   
    function depositEarnest(uint256 _nftID) onlyBuyer public payable {
		uint256 _payedAmount = msg.value;
		require(_payedAmount >= escrowAmount[_nftID], "Not enough");
	}

    // Update Inspection Status (only inspector)
    function updateInspectionStatus (uint256 _nftID) public view onlyInspector returns (bool) {
		require(isListed[_nftID] == true, "That NFT doesnt exist");
		inspectionPassed[_nftID] == !inspectionPassed[_nftID];
	}
    

    // Approve Sale
    function approveSale (uint256 _nftID) public returns (bool){
		require(isListed[_nftID] == true, "The NFT is not listed");
		require(inspectionPassed[_nftID]  == true, "The inspection hasnt been approved");
    }

    // Finalize Sale
	function finalizeSale(uint256 _nftID, uint256 _escrowAmount, bool approval) public onlyInspector{
		// -> Require inspection status 
		require(inspectionPassed[_nftID]  == true, "The inspection hasnt been approved");
		// -> Require funds to be correct amount
		require(escrowAmount[_nftID] == _escrowAmount, "Funds are not received in the correct amount");
		// -> Require sale to be authorized
		require(approveSale[_nftID][msg.sender] == true, "Sale is not authorized");
		// -> Transfer NFT to buyer
		transferFrom(seller, msg.sender, _nftID);
        purchasePrice[_nftID] = 0; // not for sale anymore
    	// -> Transfer Funds to Seller
		payable(seller).transfer(msg.value);
	}
    
    // Cancel Sale (handle earnest deposit) if inspection status is not approved, then refund, otherwise send to seller
    function cancelSale (uint256 _nftID) public view {
		if(!inspectionPassed[_nftID]){
			transferFrom(seller, msg.sender, _nftID);
		} else {
			payable(seller).transfer(msg.value);
		}
	}

    //implement a special receive function in order to receive funds and increase the balance
    // function receive() external payable {
		
	// }

    //function getBalance to check the current balance
    function getBalance() /*complete*/ public view returns (uint256) {        
		return address(this).balance;
	}

}