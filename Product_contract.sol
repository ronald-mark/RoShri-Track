//Ronald Deche Mwandonga 23AG71P03 MSP IIT KGP
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./Admin_contract.sol";
//Product side contract
//Importing the Admin Contract as per OOP principles
/* 
the title here is Productcontract the product contract inherits functions from the admin contract
it helps in farmer product entry and updates the mapping the customer calls to traceback the product details*/
//Defining the Admin Contract that will be inherited by the Product contract

//definition of the Productcontract which inherits from Admincontract
contract Productcontract is Admincontract{
    /*the product Struct contains essential details of the batch
     that the farmer adds onto the system*/
    struct PrdctData{
        address addProd;
        string prodName;
        uint prodHash;
        uint quantity;
        uint dateOfHarvesting;
        uint LabTestDate;
        uint QRCode;
        bool QAPass;
        bool LabTestStatus;
        address Farmer;
        address TestDoneBy;
    }

    uint QR;
    /*The QR code generated is mapped (QRquery) to the product struct
    the address of the farmer is mapped (prdctCount) to the total number of product entries,
    a Nested mapping (prdctTag) is used to make a product entry. This helps in verifying data before sending Ethers*/
    mapping(uint => PrdctData) public QRquery;
    mapping(address => uint) public prdctCount;
    mapping(address => mapping(uint => PrdctData)) public prdctTag;
    
    //uint _prodHash;   //_prodHash declared
    /* Product entry is done only by registered farmers. A check if the farmer verification status is true
    this helps restrict data entry,
    parameter _productName the name of the product (cooked shrimp, freezed shrimp etc)
    parameter _quantity the batch quantity
    parameter _dataOfHarvesting the date of Harvesting the batch of shrimp
    parameter _prodHash the IPFS HASH (if available), for the batch
    return the QR code and product count or sample ID of the Farmer */
    function addPrdct(string memory _prodName,
                        uint _quantity,
                        uint dateOfHarvesting,
                        uint,
                        bool,
                        address,
                        bool,
                        uint _prodHash) public onlyPrdct returns(uint,
                                                                uint){
                        require(FarmerQuery[msg.sender].FSSAIcertified == true,
                        "Your Farmer Verification status has been revoked, contact Admin");
                        prdctCount[msg.sender]++;
                        //it generates the QR code 
                        QR = genQRCode(msg.sender, admin);

                        prdctTag[msg.sender][prdctCount[msg.sender]].QRCode = QR;
                        prdctTag[msg.sender][prdctCount[msg.sender]].prodName = _prodName;
                        prdctTag[msg.sender][prdctCount[msg.sender]].quantity = _quantity;
                        prdctTag[msg.sender][prdctCount[msg.sender]].dateOfHarvesting = dateOfHarvesting;
                        prdctTag[msg.sender][prdctCount[msg.sender]].prodHash = _prodHash;
                        prdctTag[msg.sender][prdctCount[msg.sender]].Farmer = msg.sender;
                        prdctTag[msg.sender][prdctCount[msg.sender]].TestDoneBy = msg.sender;

                        //Updating QRquery mapping for traceback
                        QRquery[QR].prodName =_prodName;
                        QRquery[QR].quantity =_quantity;
                        QRquery[QR].dateOfHarvesting = dateOfHarvesting;
                        QRquery[QR].prodHash =_prodHash;
                        QRquery[QR].QRCode = QR;
                        QRquery[QR].Farmer = msg.sender;

                        return (QR,prdctCount[msg.sender]);
                    }
}