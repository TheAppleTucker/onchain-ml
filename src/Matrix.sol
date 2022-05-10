// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./libraries/ABDKMath64x64.sol";
import "forge-std/console.sol";
import "./GaussianRNG.sol";


function compareStrings(string memory a, string memory b) pure returns (bool) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
}


library Matrix {
    using ABDKMath64x64 for int128;
    /*
    shape, index (at)
    row
    col
    transpose
    mat multiply
    elementwise multiplication, division
    relu
    */

    struct InstantiationParam {
        uint height;
        uint width;
        string t;
        int128 value;
    }

    function instantiateMatrix(InstantiationParam memory ip) public pure returns (int128[][] memory m){
        m =  new int128[][](ip.height);
        for (uint i; i < ip.height; i++) {
            int128[] memory v = new int128[](ip.width);
            for (uint j = 0; j < ip.width; j++){
                if (compareStrings(ip.t, 'constant')){
                    v[j] = ip.value;
                }
                else if (compareStrings(ip.t, 'range')){
                    // just use this for testing purposes (because each value is different and known)
                    v[j] = int128(int(i * ip.width + j));
                }
                else if (compareStrings(ip.t, 'he')){

                }
            }
            m[i] = v;
        }
        return m;
    }

    function shape(int128[][] memory m) public pure returns (uint, uint) {
        uint height = m.length;
        assert (height > 0);
        uint width = m[0].length;
        return (height, width);
    }

    function transpose(int128[][] memory m) public returns (int128[][] memory) {
        (uint mHeight, uint mWidth) = shape(m);
        int128[][] memory output = instantiateMatrix(InstantiationParam(mWidth, mHeight, 'constant', 0));
        for (uint i = 0; i < mHeight; i++){
            for (uint j = 0; j < mWidth; j++){
                output[j][i] = m[i][j];
            }
        }
        return output;
    }

    function add(int128[][] memory one, int128[][] memory two) public returns (int128[][] memory) {
        (uint oneHeight, uint oneWidth) = shape(one);
        (uint twoHeight, uint twoWidth) = shape(two);
        assert(oneHeight == twoHeight && oneWidth == twoWidth);
        int128[][] memory output = instantiateMatrix(InstantiationParam(oneHeight, oneWidth, 'constant', 0));

        for (uint i = 0; i < oneHeight; i++){
            for (uint j = 0; j < oneWidth; j++){
                output[i][j] = one[i][j].add(two[i][j]);
            }
        }
        return output;
    }

    function relu(int128[][] memory m) public returns (int128[][] memory){
        (uint height, uint width) = shape(m);
        int128[][] memory output = instantiateMatrix(InstantiationParam(height, width, 'constant', 0));
        for (uint i = 0; i < height; i++){
            for (uint j = 0; j < width; j++){
                output[i][j] = m[i][j] >= int128(0) ? m[i][j] : int128(0);
            }
        }
        return output;
    }

    function scalarMul(int128[][] memory m, int128 k) public returns (int128[][] memory){
        (uint height, uint width) = shape(m);
        int128[][] memory output = instantiateMatrix(InstantiationParam(height, width, 'constant', 0));
        for (uint i = 0; i < height; i++){
            for (uint j = 0; j < width; j++){
                output[i][j] = m[i][j].mul(k);
            }
        }
        return output;
    }

    function scalarDiv(int128[][] memory m, int128 k) public returns (int128[][] memory){
        (uint height, uint width) = shape(m);
        int128[][] memory output = instantiateMatrix(InstantiationParam(height, width, 'constant', 0));
        for (uint i = 0; i < height; i++){
            for (uint j = 0; j < width; j++){
                output[i][j] = m[i][j].div(k);
            }
        }
        return output;
    }

}
