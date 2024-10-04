//Ronald Deche Mwandonga 23AG71P03 MSP IIT KGP
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
//Product side contract
/*stakeholders, libraries which contain essential details of stakeholders involved, 
arranged in the form of reusable structs within a library*/
//Importing the Admin Contract as per OOP principles
import './Processor_contract.sol';

/*The title is CustomerContract
this customer contract contains functions that fetches the details of the product;
the stakeholders details (the farmer, etc)
the QRLab and the Shrimp plant that has processed the batch), the technical details such as
the QALab test details can also be querid for complete
transparency. the functions are view only and do not incur any gas fees/transaction charges*/
contract Customercontract is Processcontract{
        function fetchProductBasicDetails(uint _QRData) public view returns(PrdctData memory,
                                                                        stakeholders.FarmerRegister memory,
                                                                        stakeholders.QALabRegister memory,
                                                                        stakeholders.IndustryData memory){
                
                return (QRquery[_QRData],
                        FarmerQuery[QRquery[_QRData].Farmer],
                        LabQuery[QRquery[_QRData].TestDoneBy],
                        ProcessIndustryQuery[ProcessParam[_QRData].ProDoneBy]
                        );
        }                            
        /*A function that fetches the technical parameters; The QA lab test detail,
        the pre-processing QA test results and the aspects relevant to the shrimp processing.
        parameter batchQRcode  the QR code of the batch
        return TechData The TechData struct containing the initial QA Lab test detals.
        return Process Data The ProcessData struct that contains parameters relevant to shrimp processing*/
        function fetchProductTechDetails(uint _batchQRCode) public view returns(TechData memory,
                                                                                ShrimpQA memory,
                                                                                ProcessData memory){
                                                          return(Techparam[_batchQRCode],
                                                                                InhouseQAResults[_batchQRCode],
                                                                                ProcessParam[_batchQRCode]);
        }
}