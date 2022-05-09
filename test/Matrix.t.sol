// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Matrix.sol";

contract ContractTest is Test {

    using Matrix for int128[][];

    int128[][] l1;
    int128[][] l2;
    uint height = 4;
    uint width = 11;
    int128 l1value = -1;
    int128 l2value = 2;

    uint256 salt = 0;

    function setUp() public {
        l1 = Matrix.instantiateMatrix(Matrix.InstantiationParam(height, width, 'constant', l1value));
        l2 = Matrix.instantiateMatrix(Matrix.InstantiationParam(height, width, 'constant', l2value));
    }

    function testMatrixShape() public {
        (uint rheight, uint rwidth) = l1.shape();
        assertTrue(rwidth == width && rheight == height);
    }

    function testRangeMatrixInstantiation() public {
        int128[][] memory test = Matrix.instantiateMatrix(Matrix.InstantiationParam(height, width, 'range', 0));
        for (uint i = 0; i < height; i++){
            for (uint j = 0; j < width; j++){
                assertTrue(test[i][j] == int128(int(i * width + j)));
            }
        }
    }

    function testConstantMatrixInstantiation() public {
        for (uint i = 0; i < height; i++){
            for (uint j = 0; j < width; j++){
                assertTrue(l1[i][j] == l1value);
            }
        }
    }

    function testTranspose() public {
        int128[][] memory output = l1.transpose();
        (uint outHeight, uint outWidth) = output.shape();
        assertTrue(outHeight == width && outWidth == height);
        for (uint i = 0; i < outHeight; i++){
            for (uint j = 0; j < outWidth; j++){
                assertTrue(output[i][j] == l1[j][i]);
            }
        }

    }

    function testMatrixAddition () public {
        int128[][] memory output = Matrix.add(l1, l2);
        for (uint i = 0; i < height; i++){
            for (uint j = 0; j < width; j++){
                assertTrue(output[i][j] == l1value + l2value);
            }
        }
        
    }

}
