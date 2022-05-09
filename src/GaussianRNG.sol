// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";

// took this from some dude on the internet: https://medium.com/@maxareo/on-chain-gaussianity-is-available-now-1409c7f14cbe
// modified it to spit out 

contract GaussianRandomNumberGenerator {
    function getGaussianRandomNumbers(uint256 salt, uint256 n)
        public
        view
        returns(int256[] memory)
    {
        uint256 seed = salt + block.timestamp;
        uint256 _num = uint256(keccak256(abi.encodePacked(seed)));
        int256[] memory results = new int256[](n);
        for (uint256 i = 0; i < n; i++) {
            uint256 result = _countOnes(_num);
            console.log(result);
            results[i] = int256(result * 125) - 16000;
            _num = uint256(keccak256(abi.encodePacked(_num)));
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