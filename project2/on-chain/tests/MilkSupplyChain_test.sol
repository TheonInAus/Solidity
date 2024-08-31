// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "remix_tests.sol";
import "remix_accounts.sol";
import "../contracts/MilkSupplyChain.sol";

contract MilkSupplyChainTest {
    MilkSupplyChain milkSupplyChain;
    address owner;
    address farmer;
    address transporter;
    address inspector;
    address retailer;

    function beforeAll() public {
        owner = TestsAccounts.getAccount(0);
        farmer = TestsAccounts.getAccount(1);
        transporter = TestsAccounts.getAccount(2);
        inspector = TestsAccounts.getAccount(3);
        retailer = TestsAccounts.getAccount(4);
        milkSupplyChain = new MilkSupplyChain();
    }

    function testRoleManagement() public {
        milkSupplyChain.addFarmer(farmer);
        Assert.ok(milkSupplyChain.hasRole(milkSupplyChain.FARMER_ROLE(), farmer), "Farmer role was not assigned correctly");

        milkSupplyChain.addTransporter(transporter);
        Assert.ok(milkSupplyChain.hasRole(milkSupplyChain.TRANSPORTER_ROLE(), transporter), "Transporter role was not assigned correctly");

        milkSupplyChain.addInspector(inspector);
        Assert.ok(milkSupplyChain.hasRole(milkSupplyChain.INSPECTOR_ROLE(), inspector), "Inspector role was not assigned correctly");

        milkSupplyChain.addRetailer(retailer);
        Assert.ok(milkSupplyChain.hasRole(milkSupplyChain.RETAILER_ROLE(), retailer), "Retailer role was not assigned correctly");
    }
}