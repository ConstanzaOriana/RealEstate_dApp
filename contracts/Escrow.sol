//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _id
    ) external;
}

contract Escrow {
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
    function depositEarnest(uint256 _TokenID) onlyBuyer public payable {
		uint256 _payedAmount = msg.value;
		require(_payedAmount >= escrowAmount[_TokenID], "Not enough");
	}

    // Update Inspection Status (only inspector)
    function updateInspectionStatus () public view onlyInspector returns (bool) {
		require(isListed[_nftID] == true, "That NFT doesnt exist");
		inspectionPassed[_nftID] == !inspectionPassed[_nftID];
	}
    

    // Approve Sale
    function approveSale  /*complete*/ (uint256 _nftID) public returns (bool){
        //approval[_nftID][msg.sender] = true;
		require(isListed[_nftID] == true, "The NFT is not listed");
		require(inspectionPassed[_nftID]  == true, "The inspection hasnt been approved");
    }

    // Finalize Sale
	function finalizeSale() public onlyInspector{
	// -> Require inspection status 
    // -> Require sale to be authorized
    // -> Require funds to be correct amount
    // -> Transfer NFT to buyer
    // -> Transfer Funds to Seller
	}
    
    // Cancel Sale (handle earnest deposit)
    function cancelSale () /*complete*/ {
	// -> if inspection status is not approved, then refund, otherwise send to seller
	}

    //implement a special receive function in order to receive funds and increase the balance
    function receive() external payable {

	}

    //function getBalance to check the current balance
    function getBalance() /*complete*/ public view returns (uint256) {        
		return address(this).balance;
	}

}