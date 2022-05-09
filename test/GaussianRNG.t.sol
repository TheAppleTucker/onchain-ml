pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/GaussianRNG.sol";

contract ContractTest is Test {
    GaussianRandomNumberGenerator model = new GaussianRandomNumberGenerator();

    function setUp() public {
    }

    function testTryOut() public {
        int256[] memory output = model.getGaussianRandomNumbers(1, 10);
        for (uint i = 0; i < 10; i++){
            console.logInt(output[i]);

        }
    }
}
