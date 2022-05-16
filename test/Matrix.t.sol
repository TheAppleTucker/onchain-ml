// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Matrix.sol";

contract ContractTest is Test {
    using ABDKMath64x64 for int128;

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

    function testHeInitialization() public {
        int128[][] memory test = Matrix.instantiateMatrix(Matrix.InstantiationParam(50, 50, 'he', 1));
        int128 sum = 0;
        for (uint i = 0; i < 50; i++){
            for (uint j = 0; j < 50; j++){
                sum = sum.add(test[i][j]);
            }
        }
        assertTrue(sum.abs() < ABDKMath64x64.fromUInt(50));
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

    function testMatrixAddition() public {
        int128[][] memory output = Matrix.add(l1, l2);
        for (uint i = 0; i < height; i++){
            for (uint j = 0; j < width; j++){
                assertTrue(output[i][j] == l1value + l2value);
            }
        }
        
    }

    function testMatrixSubtraction() public {
        int128[][] memory output = Matrix.sub(l1, l2);
        for (uint i = 0; i < height; i++){
            for (uint j = 0; j < width; j++){
                assertTrue(output[i][j] == l1value - l2value);
            }
        }
    }

    function testRelu() public {
        uint h = 10; uint w = 10;
        int128[][] memory test = Matrix.instantiateMatrix(Matrix.InstantiationParam(h, w, 'he', 1));
        test = test.relu();
        for (uint i = 0; i < h; i++){
            for (uint j = 0; j < w; j++){
                assertTrue(test[i][j] >= 0);
            }
        }
    }

    function testScalarMul() public {
        int128 k = ABDKMath64x64.fromUInt(2);
        int128[][] memory output = l1.scalarMul(k);
        for (uint i = 0; i < height; i++){
            for (uint j = 0; j < width; j++){
                assertTrue(output[i][j] == k.mul(l1[i][j]));
            }
        }
    }
    
    function testScalarDiv() public {
        int128 k = ABDKMath64x64.fromUInt(2);
        int128[][] memory output = l1.scalarDiv(k);
        for (uint i = 0; i < height; i++){
            for (uint j = 0; j < width; j++){
                assertTrue(output[i][j] == l1[i][j].div(k));
            }
        }
    }

    function testRow() public {
        int128[][] memory test = Matrix.instantiateMatrix(Matrix.InstantiationParam(height, width, 'range', 0));
        for (uint i = 0; i < height; i++){
            int128[] memory row = test.row(i);
            for (uint j = 0; j < width; j++){
                assertTrue(row[j] == test[i][j]);
            }
        }
    }

    function testCol() public {
        int128[][] memory test = Matrix.instantiateMatrix(Matrix.InstantiationParam(height, width, 'range', 0));
        for (uint j = 0; j < width; j++){
            int128[] memory col = test.col(j);
            for (uint i = 0; i < height; i++){
                assertTrue(col[i] == test[i][j]);
            }
        }
    }

    function testMatmulShape() public {
        int128[][] memory one = Matrix.instantiateMatrix(Matrix.InstantiationParam(5, 10, 'range', 0));
        int128[][] memory two = Matrix.instantiateMatrix(Matrix.InstantiationParam(10, 7, 'range', 0));
        int128[][] memory output = one.matmul(two);
        (uint h, uint w) = output.shape();
        assert(h == 5 && w == 7);
    }

    function testMatmulValue() public {
        int128[][] memory one = Matrix.instantiateMatrix(Matrix.InstantiationParam(1, 6, 'range', 0));
        int128[][] memory two = Matrix.instantiateMatrix(Matrix.InstantiationParam(6, 1, 'range', 0));
        int128[][] memory output = one.matmul(two);
        assert(output[0][0] == int128(int(55)));
    }

    function testHadamardProduct() public {
        int128[][] memory one = Matrix.instantiateMatrix(Matrix.InstantiationParam(1, 6, 'range', 0));
        int128[][] memory two = Matrix.instantiateMatrix(Matrix.InstantiationParam(1, 6, 'range', 0));
        int128[][] memory output = one.hadamardProduct(two);
        for (uint j = 0; j < 6; j++){
            output[0][j] = int128(int(j ** 2));
        }
    }
}
