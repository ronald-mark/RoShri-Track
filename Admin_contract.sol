//Ronald Deche Mwandonga
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
/*stakeholders, libraries which contain essential details of stakeholders involved, 
arranged in the form of reusable structs within a library*/
library stakeholders{
    //add farmers details
    struct FarmerRegister{
        address addFarmer;      //this is the Ethereum EOA address of the farmer.
        string FMname;
        string RegID;           //the registered ID details with the cooperative unions/ sacco
        uint32 FarmerPinCode;   //gives the appropriate location of the stakeholder
        bool  FSSAIcertified;   //this is the field verification by the designated authority
    }
    //struct to add the QALab Details
    struct QALabRegister{
        address addLab;          //this is the Ethereum EOA address of the QA lab
        string QAName;           
        string AcredNo;
        uint32 TestDoneBy;          
        uint32 LabPinCode;      //this is the accreditation No. example: "TA-98871" (string)
        
    }
    //struct to add shrimp plant
    struct IndustryData{
        address addIndustryAddress;     //the Ethereum EOA address of the shrimp Industry 
        string IndustryName;
        string NABL;             //NABL Accreditation number for the inhouseQALab (string)
        uint NABLvalidity;       //License validity for a period of 1 to 2 years from issue
        uint FSSAIregno;         //this is the FSSAI Registration number (14 digits, uint)
        uint FSSAIregnoValidUpto; // this is a 1 to 5 years validity based on the license (unix time, only Admin)
        uint plantPinCode;        //this is the plant location
        address ProDoneBy;
        bool plantStatus;        // prevention of further data entry until further 
                                  //investigation are complete in case of an inadvertent.
    }

    //struct to add Transport company
    struct TruckData{
        address PayableBeneficiary;
        address addTruck;
        string TruckName;
        uint TruckCapacity;
        uint DepartureDate;
        uint carrierTemp;
        uint carrierCondition;
        uint damageProof;
        address testdoneby;
        uint TestHash;
        bool TruckStatus;
    }


    //struct to add product data 
    struct PrdctData{
        address addProd;
        string prodName;
        uint prodHash;
        uint quantity;
        uint dateOfHarvesting;
        uint LabTestDate;
        uint QRCode;
        bool QAPass;
        address testDoneBy;
        address Farmer;
        bool LabTestStatus;
    }
}

    /*the title is Admincontract 
    this contract contains the basic controls for the system admin, functions; 
    to add Farmers, QALabs, Performs the necessary checks for the stakeholders
    and generate a QR code for a particular batch of milk upon reception  */
    contract Admincontract{

    //using Stakeholders.sol for*; //using the libraries here
    /*this is a counter to track the number of stakeholders*/
    uint public FarmerCount = 1;
    uint public LabCount = 1;
    uint public IndustryCount = 1;
    uint public AdminTruckCount = 1;
    uint public PrdctCount = 1;

    /* these are digits in QR code and the Modulus required for its computation*/
    uint   QRDigit;
    uint   QRCodeModulus;

    /* these are boolean statements for various checks*/
    bool FarmerStatus;
    bool LabStatus;
    bool ProcStatus;
    bool IndustryStatus;
    bool TruckStatus;
    bool PrdctStatus;

    /* this is mapping Ethereum to a counter, to track the total number of stakeholders  */
    mapping (uint => address) public FarmerList;
    mapping (uint => address) public QALablist;
    mapping (uint => address) public ProcessIndustryList;
    mapping (uint => address) public TruckList;
    mapping (uint => address) public PrdctList;

     /* thi is mapping Ethereum EOA to structs in stakeholders library, used in 
    retrieving data when a customer fetches product details*/
    mapping(address =>stakeholders.FarmerRegister) public FarmerQuery;
    mapping(address => stakeholders.QALabRegister) public LabQuery;
    mapping(address => stakeholders.IndustryData) public ProcessIndustryQuery;
    mapping(address => stakeholders.TruckData) public AdminTruckDataQuery;
    mapping(address => stakeholders.PrdctData) public PrdctDataQuery; 

    /*  this is the Ethereum EOA of the Admincontract */
    address public admin;
    /* a constructor to create the system admin */
    constructor() public{
        admin = msg.sender;
    }

    /* at this point it throws or reverts if called by any account other than the admin */
    modifier onlyAdmin(){
        require(msg.sender == admin,
        "Only the System Admin is Authorized For This Action");
        _;
    }
    /* at this point again it throws or reverts if it is called by
     any account other than the registered farmer*/
    modifier onlyFarmer(){
        require(checkFarmer(msg.sender) == true,
        "You are not Registered as a farmer");
        _;
    }   
    /* at this point, it throws or reverts, if it is called by any other account
     other than the registered QA Lab*/
    modifier onlyQALab(){
        require(checkQALab(msg.sender) == true,
        "Only The QALab Authoirized is to add this Entry");
        _;
    }
    /*Throwing reverts when called by any outside products account than the registered ones
    from known farms*/
    modifier onlyPrdct(){
        require(checkPrdctData(msg.sender) == true,
        "Only Authorized/Product");
        _;
    }
    /*Throwing reverts when called by any outside account other than the registered trucks*/
    modifier onlyTruck(){
        require(checkTruckData(msg.sender) == true,
        "Only the Registered Trucks or TruckCompany");
        _;
    }
    /*this add farmer to the system, only the system admin can call the function 
    parameter_farmer the Ethereum address of the farmer 
    parameter_farmerName the name of the farmer
    paramerter_RegistrationID The unique registration ID provided by the system admin, after field verification.
    paramerter_FarmerPincode the indian PIN code (location) or can be address code of the farmer location.
    parameter_KEYstatus boolean that helps in restricting entries, incase the status needs to be revoked */
    function CreateFamer(address _farmer,
                            string calldata memory_FarmerName, 
                            string calldata memory_regnID, 
                            uint32 _FarmerPinCode,
                            bool _keyStatus) public onlyAdmin{
            FarmerList[FarmerCount] = _farmer;
            FarmerQuery[_farmer] = stakeholders.FarmerRegister(
                _farmer,
                memory_FarmerName,     
                memory_regnID,
                _FarmerPinCode,
                _keyStatus);
        FarmerCount ++;
    }
    /*this checks if the Ethereum EOA address belongs to the list of registered farmers
    parameter for the Ethereum EOA address to be checked 
    Return Boolean representing the status of the address,
    a true if present in the list of registered farmers*/
    function checkFarmer(address) internal returns(bool){
        FarmerStatus = false;
        for (uint i = 1; i <= FarmerCount; i++){
            if(i == FarmerCount){
                FarmerStatus = true;
            }
        }
        return FarmerStatus;
    } 

    /* this adds the QA lab to the system, Only the system Admin can call the function
    parameters _QALab the ethereum EOA address of the QA lab
    parameters _QALabName the name of the QA lab/ Equipement (Eg. shrimp scan)
    parameters _NABLaccredNo the NABL Accredition number (string of the facility
    parameters _LabPinCode the indian PIN code (location of the QA lab) */
    function addQALab (address _QALab, 
                        string memory _QALabName,
                        string memory _NABLaccredNo,
                        uint32 _TestDoneBy,
                        uint32 _LabPinCode) public onlyAdmin{
            QALablist[LabCount] = _QALab;
            LabQuery[_QALab] = stakeholders.QALabRegister(_QALab,
                                                          _QALabName,
                                                          _NABLaccredNo,
                                                          _TestDoneBy,
                                                          _LabPinCode);
                
            LabCount ++;
        }  

    /* checking if the Ethereum EOA addres belongs to the list of registered QA labs
    parameters _lab the Ethereum EOA address to be shecked
    Return Boolean representing the status of the address
    true, if present in the list of registered QA labs */
    function checkQALab(address _lab) internal returns(bool){
        LabStatus = false;
        for (uint i = 1; i <= LabCount; i++){
            if(address(_lab) == address(QALablist[i])){
                LabStatus = true;
            }
        }
        return LabStatus;
    }


    /*Function to add Prdct Data */
    function addPrdctData (address _addProd,
                            string memory _prodName,
                            uint _ProdHash,
                            uint _quantity,
                            uint _dateOfHarvesting,
                            uint _LabTestDate,
                            uint _QRCode,
                            bool _QAPass,
                            address _testDoneBy,
                            address _Farmer,
                            bool _LabTestStatus) public onlyAdmin{
            PrdctList[PrdctCount] = _addProd;
            PrdctDataQuery[_addProd] = stakeholders.PrdctData(_addProd,
                                                              _prodName,
                                                              _ProdHash,
                                                              _quantity,
                                                              _dateOfHarvesting,
                                                              _LabTestDate,
                                                              _QRCode,
                                                              _QAPass,
                                                              _testDoneBy,
                                                              _Farmer,
                                                              _LabTestStatus                                                           
                                                              );
            PrdctCount ++;
        }
    //function to check the Product quality parameters
    function checkPrdctData(address) internal returns(bool){
        PrdctStatus = false;
        for (uint i = 1; i <= PrdctCount; i++){
            if(i == PrdctCount){
                PrdctStatus = true;
            }
        }
        return PrdctStatus;
    }


    /*Function to add Truck Data/information  */
    function addTruckData (address _addTruck,
                            address _PayableBeneficiary,
                            string memory _TruckName,
                            uint _quantity,
                            uint _dateOfDeparture,
                            uint _carrierTemp,
                            uint _carrierCondition,
                            uint _damageProof,
                            address _testdoneby,
                            uint32 _TruckHash,
                            bool _TruckStatus) public onlyAdmin{
            TruckList[AdminTruckCount] = _addTruck;
            AdminTruckDataQuery[_addTruck] = stakeholders.TruckData(_addTruck,
                                                               _PayableBeneficiary,
                                                               _TruckName,
                                                               _quantity,
                                                               _dateOfDeparture,
                                                               _carrierTemp,
                                                               _carrierCondition,
                                                               _damageProof,
                                                               _testdoneby,
                                                               _TruckHash,
                                                               _TruckStatus
                                                               );
            AdminTruckCount ++;
        }

    //function to check the Truck parameters
    function checkTruckData(address) internal returns(bool){
        TruckStatus = false;
        for (uint i = 1; i <= AdminTruckCount; i++){
            if(i == AdminTruckCount){
                TruckStatus = true;
            }
        }
        return TruckStatus;
    }


    /* adding the shrimp plant to the system, Only the system Admin can call the function
    parameters _ShrimpfARM Address the Ethereum EOA address of The Shrimp plant.
    parameters Shrimp plant The name of the Shrimp plant
    parameters NABLAccredNo The NABL Accreditaion number (string) of the facility 
    parameter _FSSAIRegNo the FSSAI License number of the facility (intergers, 14 digits)
    parameter _FSSAILicenseValidUpto the FSSAI License validity (unix time)
    parameter _ShrimpPinCode the Indian PIN code (location) of the Shrimp plant
    parameter _ ShrimpStatus boolean that helps in restricting entries, incase the status needs to be revoked or thrown*/
    function addShrimpIndustryData(address _ShrimpIndustryAddress,
                                address _ProDoneBy,
                                string memory _IndustryName,
                                string memory _NABLAccredNo,
                                uint _NABLAccredValidUpto,
                                uint _FSSAIRegNo,
                                uint _FSSAILicenseValidUpto,
                                uint _ShrimpPinCode,
                                bool _ShrimpStatus) public onlyAdmin{
            ProcessIndustryList[IndustryCount] = _ShrimpIndustryAddress;
            ProcessIndustryQuery[_ShrimpIndustryAddress] = stakeholders.IndustryData(_ShrimpIndustryAddress,
                                                                 _IndustryName,
                                                                 _NABLAccredNo,
                                                                 _NABLAccredValidUpto,
                                                                 _FSSAIRegNo,
                                                                 _FSSAILicenseValidUpto,
                                                                 _ShrimpPinCode,
                                                                 _ProDoneBy,
                                                                 _ShrimpStatus);
            IndustryCount++;
    }

    /* checking if the Ethereum EOA address belongs to the list of registered Shrimp plants
    parameter _Shrimp the Ethereum EOA address to be checked 
    return Boolean representing the status of the address,
    true, if present in the list of the registered shrimp plants*/
    function checkShrimpIndustry(address _ShrimpIndustryAddress) public returns(bool){
        IndustryStatus = false;
        for ( uint j = 1; j <= IndustryCount; j++){
            if(address(_ShrimpIndustryAddress) == address(ProcessIndustryList[j])){
                IndustryStatus = true; 
            }
        }
        return IndustryStatus;
    }

    /*The digits of the QR code are assigned, Only the system Admin can call the function
    parameter _digits The number of digits required for the QR code    */
    function setQRDigits(uint _digits) public onlyAdmin{
        QRDigit = _digits;
        QRCodeModulus = 10 ** QRDigit;
    }
    /*this generates a unique QR code using Ethereum Keccak256
    hash function and timestamp of the block
    parameter _rand1 the Ethereum EOA address to be used while hashing
    parameter _rand2 the Ethereum EOA address to be used while hashing
    return Interger QRcode generated as specified by the digits in the QR code*/
    function genQRCode(address _rand1,
                        address _rand2) internal view returns(uint){
                            uint hashedCode = uint(keccak256(abi.encodePacked(block.timestamp, _rand1, _rand2)));
                            uint Code = hashedCode % QRCodeModulus;
                        return Code;
    }
}