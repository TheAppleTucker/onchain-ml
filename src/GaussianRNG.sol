// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "./libraries/ABDKMath64x64.sol";

// took this from some dude on the internet: https://medium.com/@maxareo/on-chain-gaussianity-is-available-now-1409c7f14cbe
// modified it to spit out standard normal
// right now, gives binomial distribution sampleSize = 256, p = 1/2 with a uint256
// modify this to spit out a float (int128, use the library) mean 0, std dev 1

// maybe use sampleSize = 1024, p=1/2 variance = 256, stddev = 16
// convert to float then
// normalize by subtracting 512, divide by 16

contract GaussianRandomNumberGenerator {
    using ABDKMath64x64 for int128;

    function getGaussianRandomNumbers(uint256 salt, uint256 n)
        public
        view
        returns(int128[] memory)
    {
        uint256 seed = salt + block.timestamp;
        uint256 _num = uint256(keccak256(abi.encodePacked(seed)));
        int128[] memory results = new int128[](n);
        // sampleSize needs to be a multiple of 512
        uint256 sampleSize = 5120;
        for (uint256 i = 0; i < n; i++) {
            uint256 count = 0;
            for (uint256 j = 0; j < sampleSize / 256; j++){
                count += _countOnes(_num);
                _num = uint256(keccak256(abi.encodePacked(_num)));
            }
            int128 result = ABDKMath64x64.fromUInt(count);
            int128 mean = ABDKMath64x64.fromUInt(sampleSize / 2);
            int128 stddev = ABDKMath64x64.fromUInt(sampleSize / 4).sqrt();
            results[i] = (result.sub(mean)).div(stddev);
        }
        return results;
    }
    function _countOnes(uint256 n) 
        internal 
        pure 
        returns (uint256 count) 
    {
        assembly {
            for { } gt(n, 0) { } {
                n := and(n, sub(n, 1))
                count := add(count, 1)
            }
        }
    }
}