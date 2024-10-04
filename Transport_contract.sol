//Ronald Deche Mwandonga 23AG71P03 MSP IIT KGP
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
//Product side contract
/*stakeholders, libraries which contain essential details of stakeholders involved, arranged in the form of reusable structs within a library*/
//Importing the Specified Contract as per OOP principles
import './Admin_contract.sol';

contract Transportcontract is Admincontract{
    /* Truck data struct contains parameters usually tested at the packing of the batch  */
    struct TruckData{
        address addTruck;
        address PayableBeneficiary;
        uint QR;
        string TruckName;
        uint TruckCapacity;
        uint DepartureDate;
        uint carrierTemp;
        uint carrierCondition;
        uint damageProof;
        address testdoneby;
        uint TruckHash;
        bool TruckStatus;
    }
    uint QR;
     /* 
    The QR code generated is mapped (QRquery) to the Truck struct
    the address of the Truck is mapped (Truck Count) to the total number of product carried
    a Nested mapping (TruckTag) is used to make a Truck entry. This helps in verifying data before sending Ethers*/

    mapping(uint => TruckData) private TruckDataQuery;
    mapping(address => uint) private TruckCount;
    mapping(address => mapping(uint => TruckData)) public TruckTag;

    /* Truck entry is done only by registered companies. A check if the truck verification status is true
    this helps restrict data entry
    parameter _TruckName the name of the given Truck (with Number plates, and License Certificates)
    parameter _TruckHash the IPFS HASH (if available), for the truck
    parameter _TruckCapacity is the quantity of batch truck can carry in tonnes
    parameter _dataOfDepaturetime and the date of Departure from the firm
    parameter _carrierTemp this is the carriage temperature of the truck
    parameter _carrierCondition the condition of truckloader, for the batch
    parameter _damageproof to confirm the safety of the batch
    return the QR code and product count or sample ID of the truck */

    function addTruckData(address,
                        address _PayableBeneficiary,
                        string memory _TruckName,
                        uint _TruckCapacity,
                        uint _DepartureDate,
                        uint _carrierTemp,
                        uint _carrierCondition,
                        uint _damageProof,
                        address,
                        uint _TruckHash,
                        bool _TruckStatus) public onlyTruck returns(uint,
                                                                    uint){

                        require(keccak256(abi.encodePacked(QR)) == 
                        keccak256(abi.encodePacked(TruckTag[_PayableBeneficiary][_TruckHash].testdoneby)),
                        "Your Truck Verification status has been revoked, contact Admin");

                        //checking to ensure that only Truck details are modified once
                        require(TruckTag[_PayableBeneficiary][_TruckHash].TruckStatus == false,
                                "Trucktest details already modified");

                        //it generates the QR code 
                        QR = genQRCode(msg.sender, admin);
                       
                                                                    
                        //check to confirm the added data it right
                                    //

                                    //check to ensure that only the lab data is modified once
                                    //require(TruckTag[_PayableBeneficiary][_TruckHash].TruckStatus == false,
                                            //"Truck details already modified" );
                    
                        TruckTag[msg.sender][TruckCount[msg.sender]].PayableBeneficiary = _PayableBeneficiary;
                        TruckTag[msg.sender][TruckCount[msg.sender]].addTruck = msg.sender;
                        TruckTag[msg.sender][TruckCount[msg.sender]].QR = QR;
                        TruckTag[msg.sender][TruckCount[msg.sender]].TruckName = _TruckName;
                        TruckTag[msg.sender][TruckCount[msg.sender]].TruckCapacity = _TruckCapacity;
                        TruckTag[msg.sender][TruckCount[msg.sender]].DepartureDate = _DepartureDate;
                        TruckTag[msg.sender][TruckCount[msg.sender]].carrierTemp = _carrierTemp;
                        TruckTag[msg.sender][TruckCount[msg.sender]].carrierCondition = _carrierCondition;
                        TruckTag[msg.sender][TruckCount[msg.sender]].damageProof = _damageProof;
                        TruckTag[msg.sender][TruckCount[msg.sender]].testdoneby = msg.sender;
                        TruckTag[msg.sender][TruckCount[msg.sender]].TruckHash = _TruckHash;
                        TruckTag[msg.sender][TruckCount[msg.sender]].TruckStatus = _TruckStatus;

                        //TruckTag[msg.sender][TruckCount1[msg.sender]]=TruckData({
                            //PayableBeneficiary: _PayableBeneficiary,
                            //addTruck: msg.sender,
                            //QR: 0, //or any default value you want to set
                            //TruckName: "", // any default Name string
                            //TruckCapacity: _TruckCapacity,
                            //DepartureDate: _DepartureDate,
                            //carrierTemp: _carrierTemp,
                            //carrierCondition: _carrierCondition,
                            //damageProof: _damageProof,
                            //testdoneby: msg.sender,
                            //TruckHash: _TruckHash,
                            //TruckStatus: _TruckStatus

                        //});

                        /* this initiates payments to the Truck/TransportCompany  */
                        //payable(_PayableBeneficiary).transfer(msg.value);

                        //Updating QRquery mapping for traceback
                        TruckDataQuery[QR].TruckName =_TruckName;
                        TruckDataQuery[QR].TruckCapacity =_TruckCapacity;
                        TruckDataQuery[QR].DepartureDate =_DepartureDate;
                        TruckDataQuery[QR].TruckHash =_TruckHash;
                        TruckDataQuery[QR].TruckStatus = _TruckStatus;
                        TruckDataQuery[QR].testdoneby = msg.sender;

                        return (QR,TruckCount[msg.sender]);
                    }
} 