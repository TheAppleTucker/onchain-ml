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
        // if t == constant, value is the value
        // if t == he, value represents the seed used for initialization
        // This feels like bad practice, but it's more concise
        // Really annoying that Solidity doesn't have OOP or optional args lmao
        int128 value;
    }

    function instantiateMatrix(InstantiationParam memory ip) public returns (int128[][] memory m){
        m =  new int128[][](ip.height);
        for (uint i; i < ip.height; i++) {
            int128[] memory v;
            if (compareStrings(ip.t, 'he')){
                GaussianRandomNumberGenerator rng = new GaussianRandomNumberGenerator();
                v = rng.getGaussianRandomNumbers(uint256(int256(ip.value)), ip.width);
            }
            else {
                v = new int128[](ip.width);
                for (uint j = 0; j < ip.width; j++){
                    if (compareStrings(ip.t, 'constant')){
                        v[j] = ip.value;
                    }
                    else if (compareStrings(ip.t, 'range')){
                        // just use this for testing purposes (because each value is different and known)
                        v[j] = int128(int(i * ip.width + j));
                    }
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

    function sub(int128[][] memory one, int128[][] memory two) public returns (int128[][] memory) {
        (uint oneHeight, uint oneWidth) = shape(one);
        (uint twoHeight, uint twoWidth) = shape(two);
        assert(oneHeight == twoHeight && oneWidth == twoWidth);
        int128[][] memory output = instantiateMatrix(InstantiationParam(oneHeight, oneWidth, 'constant', 0));

        for (uint i = 0; i < oneHeight; i++){
            for (uint j = 0; j < oneWidth; j++){
                output[i][j] = one[i][j].sub(two[i][j]);
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

    function row(int128[][] memory m, uint i) public returns (int128[] memory r) {
        (uint height, uint width) = shape(m);
        r = new int128[](width);
        for (uint j = 0; j < width; j++) {
            r[j] = m[i][j];
        }
    }

    function col(int128[][] memory m, uint j) public returns (int128[] memory c) {
        (uint height, uint width) = shape(m);
        c = new int128[](height);
        for (uint i = 0; i < height; i++){
            c[i] = m[i][j];
        }
    }

    function matmul(int128[][] memory one, int128[][] memory two) public returns (int128[][] memory r){
        (uint h1, uint w1) = shape(one);
        (uint h2, uint w2) = shape(two);
        assert(h2 == w1);
        r = instantiateMatrix(InstantiationParam(h1, w2, 'constant', 0));
        for (uint a = 0; a < h1; a++){
            for (uint d = 0; d < w2; d++){
                for (uint b = 0; b < w1; b++){
                    r[a][d] += one[a][b] * two[b][d];
                }
            }
        }
    }

    function hadamardProduct(int128[][] memory one, int128[][] memory two) public returns (int128[][] memory r){
        (uint h1, uint w1) = shape(one);
        (uint h2, uint w2) = shape(two);
        assert(h1 == h2 && w1 == w2);
        r = instantiateMatrix(InstantiationParam(h1, w1, 'constant', 0));
        for (uint i = 0; i < h1; i++) {
            for (uint j = 0; j < h2; j++){
                r[i][j] += one[i][j].mul(two[i][j]);
            }
        }
    }
}
