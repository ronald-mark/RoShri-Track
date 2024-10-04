//Ronald Deche Mwandonga 23AG71P03 MSP IIT KGP
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
//Product side contract
/*stakeholders, libraries which contain essential details of stakeholders involved, arranged in the form of reusable structs within a library*/
//Importing the Admin Contract as per OOP principles
import './Product_contract.sol';

/* the title is QALabContract
this QALab contract inherits functions from the product
contract, enters the details regarding QA test done at the reception level,
if found to be of satisfactory quality, initiation of payments is done to the farmer in ethers */
contract QALabcontract is Productcontract{
    /* Tech data struct contains parameters usually tested at the reception  */
    struct TechData{
        uint Temp;
        uint pH;
        uint protein;
        uint fatPercent;
        uint size;
        bool QALabTestPass;
    }

    /* the QR Code is mapped to the TechData struct, for traceback customer call  */
    mapping (uint => TechData) public Techparam;
    /* 
    Initially QA test results done at the reception level are added to the system and if the batch is found to be of satisfactory quality, the 
    payments are processed
    parameter _beneficiary The Ethereum EOA Address of the Famer
    parameter _sampleID  the product count/ sample ID of the batch
    patameter _QR the QR code of the batch
    parameter _Temperature of the shrimp is tested
    parameter _Protein present in the batch is tested
    parameter _fatpercent the fat Perecentage in the sample
    parameter _QAPass the quality test status of the batch */

    function addQAData(address payable_beneficiary,
                                uint _sampleID,
                                uint _QR,
                                uint _Temp,
                                uint _pH,
                                uint _protein,
                                uint _fatPercent,
                                uint _size,
                                bool _QAPass) public payable onlyQALab{
                                    //check to confirm the added data it right
                                    require(keccak256(abi.encodePacked(_QR)) == 
                                    keccak256(abi.encodePacked(prdctTag[payable_beneficiary][_sampleID].QRCode)),
                                    "Data Entered does not Match");

                                    //check to ensure that only the lab data is modified once
                                    require(prdctTag[payable_beneficiary][_sampleID].LabTestStatus == false,
                                            "Labtest details already modified" );

                                    prdctTag[payable_beneficiary][_sampleID].QAPass = _QAPass;
                                    prdctTag[payable_beneficiary][_sampleID].LabTestDate = block.timestamp;
                                    prdctTag[payable_beneficiary][_sampleID].LabTestStatus = true;
                                    prdctTag[payable_beneficiary][_sampleID].TestDoneBy = msg.sender;

                                    /*this is updating the data to the TechParameters mapping */
                                    Techparam[_QR] = TechData(_Temp,
                                                              _pH,
                                                              _protein,
                                                              _fatPercent,
                                                              _size,
                                                              _QAPass);
                                    /* this initiates payments to the Farmer  */
                                    payable(payable_beneficiary).transfer(msg.value);

                                    /* here updating the QR query mapping for customer traceback */
                                    QRquery[_QR].QAPass = _QAPass;
                                    QRquery[_QR].LabTestDate = block.timestamp;
                                    QRquery[_QR].LabTestStatus = true;
                                    QRquery[_QR].TestDoneBy = msg.sender;
                                    QRquery[_QR].Farmer = msg.sender;
                                    
                                }
}