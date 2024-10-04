//Ronald Deche Mwandonga 23AG71P03 MSP IIT KGP
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
//Product side contract
/*stakeholders, libraries which contain essential details of stakeholders involved, arranged in the form of reusable structs within a library*/
//Importing the Admin Contract as per OOP principles
import './QALab_contract.sol';
/*the title is Process contract
the processor contract inherits functions from the QALab contract
this helps in pre-processing QA data entry and initiates payments to the beneficiary
if the batch is found to be satisfactory quality and the processing parameters
are added by the shrimp, this enhances trust in the system */
contract Processcontract is QALabcontract{
    bool public _pcsStatus;
    /*The ShrimpQA struct stores preprocessing parameters, Adopted as per the standards proposed by FSSAI
    REFERENCE: //https://www.fssai.gov.in/upload/advisories/2018/02/5a93f6a4ded6dOrder_Nestle.pdf */

    struct ShrimpQA{
        uint shrimpTemp; // this captures the temperature of the shrimp
        uint prdctFat;  //this give the fat content in the product
        uint pH;           // this outlines the pH of the batch
        uint InhouseQAtime;  //This logs the time of the test
        bool SensData;     //Senses evaluation time data (True = if the sample passes the sensor evaluation)
        bool NoAdulterants; //Testing for Adulteration boolean (True=No adulterants, safe batch)
        bool NoChemCont;  // testing for chemical using boolean (true=No chemical)
        bool NoMicroCont; // testing for microbial contamination test booolean (true= satisfactory test results, safe batch)
        bool preProcTestpass; // Boolean to indicate if the overall quality is satisfactory
        bool ModStatus;  // this is for modification check
    }

    /* this process struct contains the processing data parameters relevant to FSSAI standards */

    struct ShrimpDataValidCerts{
        uint _FSSAIRegNo;
        uint _FSSAILicenseValidUpto;

    }
    /*the processData struct contains processing side parameters, relevant to shrimp*/
    struct ProcessData{
        string pcsHash;    // this IPFS hash of the IOT device data (time-temp data or other data)
        string pcsMethod;  //this processing method employed  (...)
        uint BBD;          // the Best Before Date of the productuct
        uint processTime;  // Logs the time when the processing was done (block.timestamp)
        bool finalPrdctQuality; // this is the inhouse QA Test Status, just before being released to the market
        bool pcsStatus;      // this is a boolean that restricts the data entry to only once
        address ProDoneBy;    // it stores the Ethrereum Address of the processor
    }
    /*mapping ProcessData and Pre-processing data to the QRCode (uint)*/

    mapping (uint => ProcessData) internal ProcessParam;
    mapping (uint => ShrimpQA) internal InhouseQAResults;
    mapping (uint => ShrimpDataValidCerts) internal  ShrimpPlantValidCerts;


    //function to check the if the shrimp batch has passed
    function checkShrimp(address _sender) public returns (bool){

    }
    
    /*this modifier to restrict the data entry to only the registered shrimp Plant*/
    modifier onlyIndustry(){
        require(checkShrimp(msg.sender) == true,
        "You are not registered as a ShrimpPlant");
        _;
    }
    /*the inhouse QA test results at the plant level is updated. 
    once the batch is found to be satisfactory quality,
     payments are processed to the reception QA lab address*/
    function addShrimpQAData(address payable _VSCS,   // the Ethereum EOA address of the vscs QALab
                             uint _batchQR, // the QR code of the batch
                             uint _ShrimpTemp, // the temperature of shimp at reception
                             uint _fatPrecent,  // the fat percentage in the sample tested
                             uint _batchpH,    //the pH of the sample tested
                             bool _sensoryTestPass,     // the sensory test status of the samplel
                             bool _adulterantTestPass, // the adulteration test for the sample
                             bool _chemContTestPass, //the chemical content test
                             bool _microContamTestPass,  //the microbial contamination test status of the sample 
                             bool _preprocessTestPass //the processing QA test status of the batch
                            ) public payable onlyIndustry{
                                /*this checks for permission status of the plant*/
                                require(QRquery[msg.value].QAPass == true,
                                        "Your permission status has been revoked");

                                /* checking to confirm the batch belonging to the right vscs, 
                                as payments are initiated in the function */        
                                require(keccak256(abi.encodePacked(_VSCS)) == 
                                keccak256(abi.encodePacked(QRquery[_batchQR].QRCode)),
                                "Entered Data Does Not Match");

                            /*checking for NABL License Validity of the ShrimpPlant */
                                require(block.timestamp <= ProcessIndustryQuery[msg.sender].NABLvalidity,
                                "NABL License Validity Expired!, please contact Admin");    

                            /*checking to see if the batch has passed the VSCS QALab test  */
                                require(QRquery[_batchQR].QAPass == true,
                                "The batch Does Not Meet the Necessary Standards!");

                            /*checking to confirm the batch data has not been previously modified*/
                                require(InhouseQAResults[_batchQR].ModStatus == false,
                                "The ShrimpQA data has already been modified for the batch!");
                                InhouseQAResults[_batchQR] = ShrimpQA(_ShrimpTemp,
                                                                      _fatPrecent,
                                                                      _batchpH,
                                                                      block.timestamp,
                                                                      _sensoryTestPass,
                                                                      _adulterantTestPass,
                                                                      _chemContTestPass,
                                                                      _microContamTestPass,
                                                                      _preprocessTestPass,
                                                                      true);
                            /* Here payments are sent to the vscs once the data entry is done*/
                            _VSCS.transfer(msg.value);
                        }
                        /*Here the processing parameters are updated by the Plant
                          batches of shrimp (different QRcodes) are usually processed together,
                          for simplicty array of batches can be updated all at once which also saves gas costs*/
                        function addProcessData(uint _ShrimpQAquery,
                                                uint _batchCount,       //the number of batches that are processed at once
                                                uint[] memory _QRCodes, //the QR codes of the Shrimp batches are processed
                                                string memory _pcsHash,  // The IPFS hash of the processing data (if available)
                                                string memory _pcsMethod,  //the processing method employed
                                                uint _BBD,                // the Best Before Date of the processed batch
                                                bool _PrdctQualityPass                
                                                ) public onlyIndustry{
                                                    //for loop to run through the QR codes
                                                    for(uint p = 0; p < _batchCount; p ++){

                                                        /*checking for permission status of the ShrimpPlant*/
                                                        require(ProcessIndustryQuery[msg.sender].plantStatus == true,
                                                        "Your Permission Has Been Revoked ");

                                                        /*  FSSAI License validity check */
                                                        require(block.timestamp <= ProcessIndustryQuery[msg.sender].FSSAIregnoValidUpto,
                                                        "The FSSAI License Validity has expired, please contact Admin");


                                                        /*Checking to ensure that the batches have passed the inhouse ShrimpQA tests*/
                                                        require(InhouseQAResults[_QRCodes[p]].preProcTestpass == true,
                                                        "The batch is Not of satisfactory quality");

                                                        /* checking to ensure that the data can only be modified once */
                                                        require(bool(ProcessParam[_QRCodes[p]].pcsStatus) == false,
                                                        "The Process Parameters have already been modified for some QR");
                                                        ProcessParam[_QRCodes[p]] = ProcessData(_pcsHash,
                                                                                                _pcsMethod,
                                                                                                _BBD,
                                                                                                block.timestamp,
                                                                                                _PrdctQualityPass,
                                                                                                true,
                                                                                                msg.sender);
                            }
                        }
}