pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/GaussianRNG.sol";

contract ContractTest is Test {
    using ABDKMath64x64 for int128;
    GaussianRandomNumberGenerator model = new GaussianRandomNumberGenerator();

    function setUp() public {
    }

    function testTryOut() public {
        uint256 sampleSize = 5000;
        int128[] memory output = model.getGaussianRandomNumbers(2, sampleSize);
        int128 sum = 0;
        for (uint i = 0; i < sampleSize; i++){
            sum = sum.add(output[i]);
        }
        // Arbitrary test to make sure it's roughly normally distributed,
        // I don't really feel like doing more
        assertTrue(sum.abs() < ABDKMath64x64.fromUInt(10));
    }
}
