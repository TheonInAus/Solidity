// SPDX-License-Identifier: MIT
pragma solidity >=0.5.8 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface IMilkSupplyChain {
    struct BatchInfo {
        uint256 productionDate;
        uint256 weight;
        uint256 expiryDate;
    }

    struct TransportInfo {
        address transporter;
        string status;
        string reportCID;
    }

    struct InspectionInfo {
        address inspector;
        string status;
        string reportCID;
    }

    struct ReceivingInfo {
        address retailer;
        string status;
        string reportCID;
    }

    struct MilkBatch {
        BatchInfo batchInfo;
        TransportInfo transportInfo;
        InspectionInfo inspectionInfo;
        ReceivingInfo receivingInfo;
        address currentOwner;
    }
    
    function getBatchInfo(uint256 _batchId) external view returns (MilkBatch memory);
}

contract AutoPayment is AccessControl {
    IMilkSupplyChain public milkSupplyChain;
    mapping(uint256 => bool) public paidToFarmer;
    mapping(uint256 => bool) public paidToInspector;

    bytes32 public constant FARMER_ROLE = keccak256("FARMER_ROLE");
    bytes32 public constant INSPECTOR_ROLE = keccak256("INSPECTOR_ROLE");
    bytes32 public constant RETAILER_ROLE = keccak256("RETAILER_ROLE");

    event PaymentMadeToFarmer(uint256 batchId, address farmer, uint256 amount);
    event PaymentMadeToInspector(uint256 batchId, address inspector, uint256 amount);

    constructor(address _milkSupplyChainAddress) {
        milkSupplyChain = IMilkSupplyChain(_milkSupplyChainAddress);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function depositFundsInspector() public payable onlyRole(INSPECTOR_ROLE) {
       
    }

    function depositFundsRetailer() public payable onlyRole(RETAILER_ROLE) {
        
    }

    function withdrawFunds(uint256 amountEth) public {
        require(hasRole(INSPECTOR_ROLE, msg.sender) || hasRole(RETAILER_ROLE, msg.sender), "Only inspector or retailer can withdraw");
        uint256 amount = amountEth * 1 ether; // Convert ETH to wei
        require(address(this).balance >= amount, "Insufficient balance");
        payable(msg.sender).transfer(amount);
    }

    function checkAndPayToFarmer(uint256 batchId, uint256 paymentAmountEth, address farmer) public onlyRole(INSPECTOR_ROLE) {
        require(!paidToFarmer[batchId], "Batch already paid to farmer");
        require(hasRole(FARMER_ROLE, farmer), "Address is not a registered farmer");

        IMilkSupplyChain.MilkBatch memory batch = milkSupplyChain.getBatchInfo(batchId);

        require(keccak256(bytes(batch.inspectionInfo.status)) == keccak256(bytes("Passed")), "Inspection not passed");

        uint256 paymentAmount = paymentAmountEth * 1 ether; // Convert ETH to wei
        require(address(this).balance >= paymentAmount, "Insufficient contract balance");

        paidToFarmer[batchId] = true;
        payable(farmer).transfer(paymentAmount);

        emit PaymentMadeToFarmer(batchId, farmer, paymentAmount);
    }

    function checkAndPayToInspector(uint256 batchId, uint256 paymentAmountEth) public onlyRole(RETAILER_ROLE) {
        require(!paidToInspector[batchId], "Batch already paid to inspector");

        IMilkSupplyChain.MilkBatch memory batch = milkSupplyChain.getBatchInfo(batchId);

        require(keccak256(bytes(batch.receivingInfo.status)) == keccak256(bytes("Received")), "Batch not received");

        uint256 paymentAmount = paymentAmountEth * 1 ether; // Convert ETH to wei
        require(address(this).balance >= paymentAmount, "Insufficient contract balance");

        paidToInspector[batchId] = true;
        payable(batch.inspectionInfo.inspector).transfer(paymentAmount);

        emit PaymentMadeToInspector(batchId, batch.inspectionInfo.inspector, paymentAmount);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function addFarmer(address account) public {
        grantRole(FARMER_ROLE, account);
    }

    function addInspector(address account) public {
        grantRole(INSPECTOR_ROLE, account);
    }

    function addRetailer(address account) public {
        grantRole(RETAILER_ROLE, account);
    }
}