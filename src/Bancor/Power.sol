// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Power {
    string public version = "0.3";

    uint256 private constant _ONE = 1;
    uint32 private constant _MAX_WEIGHT = 1_000_000;
    uint8 private constant _MIN_PRECISION = 32;
    uint8 private constant _MAX_PRECISION = 127;

    /**
     * The values below depend on _MAX_PRECISION. If you choose to change it:
     */
    uint256 private constant _FIXED_1 = 0x080000000000000000000000000000000;
    uint256 private constant _FIXED_2 = 0x100000000000000000000000000000000;
    uint256 private constant _MAX_NUM = 0x1ffffffffffffffffffffffffffffffff;

    /**
     * The values below depend on _MAX_PRECISION. If you choose to change it:
     */
    uint256 private constant _LN2_MANTISSA = 0x2c5c85fdf473de6af278ece600fcbda;
    uint8 private constant _LN2_EXPONENT = 122;

    /**
     * The values below depend on _MIN_PRECISION and _MAX_PRECISION. If you choose to change either one of them:
     */
    uint256[128] private _maxExpArray;

    // function pwr() public {
    //     _maxExpArray[32] = 0x1c35fedd14ffffffffffffffffffffffff;
    //     _maxExpArray[33] = 0x1b0ce43b323fffffffffffffffffffffff;
    //     _maxExpArray[34] = 0x19f0028ec1ffffffffffffffffffffffff;
    //     _maxExpArray[35] = 0x18ded91f0e7fffffffffffffffffffffff;
    //     _maxExpArray[36] = 0x17d8ec7f0417ffffffffffffffffffffff;
    //     _maxExpArray[37] = 0x16ddc6556cdbffffffffffffffffffffff;
    //     _maxExpArray[38] = 0x15ecf52776a1ffffffffffffffffffffff;
    //     _maxExpArray[39] = 0x15060c256cb2ffffffffffffffffffffff;
    //     _maxExpArray[40] = 0x1428a2f98d72ffffffffffffffffffffff;
    //     _maxExpArray[41] = 0x13545598e5c23fffffffffffffffffffff;
    //     _maxExpArray[42] = 0x1288c4161ce1dfffffffffffffffffffff;
    //     _maxExpArray[43] = 0x11c592761c666fffffffffffffffffffff;
    //     _maxExpArray[44] = 0x110a688680a757ffffffffffffffffffff;
    //     _maxExpArray[45] = 0x1056f1b5bedf77ffffffffffffffffffff;
    //     _maxExpArray[46] = 0x0faadceceeff8bffffffffffffffffffff;
    //     _maxExpArray[47] = 0x0f05dc6b27edadffffffffffffffffffff;
    //     _maxExpArray[48] = 0x0e67a5a25da4107fffffffffffffffffff;
    //     _maxExpArray[49] = 0x0dcff115b14eedffffffffffffffffffff;
    //     _maxExpArray[50] = 0x0d3e7a392431239fffffffffffffffffff;
    //     _maxExpArray[51] = 0x0cb2ff529eb71e4fffffffffffffffffff;
    //     _maxExpArray[52] = 0x0c2d415c3db974afffffffffffffffffff;
    //     _maxExpArray[53] = 0x0bad03e7d883f69bffffffffffffffffff;
    //     _maxExpArray[54] = 0x0b320d03b2c343d5ffffffffffffffffff;
    //     _maxExpArray[55] = 0x0abc25204e02828dffffffffffffffffff;
    //     _maxExpArray[56] = 0x0a4b16f74ee4bb207fffffffffffffffff;
    //     _maxExpArray[57] = 0x09deaf736ac1f569ffffffffffffffffff;
    //     _maxExpArray[58] = 0x0976bd9952c7aa957fffffffffffffffff;
    //     _maxExpArray[59] = 0x09131271922eaa606fffffffffffffffff;
    //     _maxExpArray[60] = 0x08b380f3558668c46fffffffffffffffff;
    //     _maxExpArray[61] = 0x0857ddf0117efa215bffffffffffffffff;
    //     _maxExpArray[62] = 0x07ffffffffffffffffffffffffffffffff;
    //     _maxExpArray[63] = 0x07abbf6f6abb9d087fffffffffffffffff;
    //     _maxExpArray[64] = 0x075af62cbac95f7dfa7fffffffffffffff;
    //     _maxExpArray[65] = 0x070d7fb7452e187ac13fffffffffffffff;
    //     _maxExpArray[66] = 0x06c3390ecc8af379295fffffffffffffff;
    //     _maxExpArray[67] = 0x067c00a3b07ffc01fd6fffffffffffffff;
    //     _maxExpArray[68] = 0x0637b647c39cbb9d3d27ffffffffffffff;
    //     _maxExpArray[69] = 0x05f63b1fc104dbd39587ffffffffffffff;
    //     _maxExpArray[70] = 0x05b771955b36e12f7235ffffffffffffff;
    //     _maxExpArray[71] = 0x057b3d49dda84556d6f6ffffffffffffff;
    //     _maxExpArray[72] = 0x054183095b2c8ececf30ffffffffffffff;
    //     _maxExpArray[73] = 0x050a28be635ca2b888f77fffffffffffff;
    //     _maxExpArray[74] = 0x04d5156639708c9db33c3fffffffffffff;
    //     _maxExpArray[75] = 0x04a23105873875bd52dfdfffffffffffff;
    //     _maxExpArray[76] = 0x0471649d87199aa990756fffffffffffff;
    //     _maxExpArray[77] = 0x04429a21a029d4c1457cfbffffffffffff;
    //     _maxExpArray[78] = 0x0415bc6d6fb7dd71af2cb3ffffffffffff;
    //     _maxExpArray[79] = 0x03eab73b3bbfe282243ce1ffffffffffff;
    //     _maxExpArray[80] = 0x03c1771ac9fb6b4c18e229ffffffffffff;
    //     _maxExpArray[81] = 0x0399e96897690418f785257fffffffffff;
    //     _maxExpArray[82] = 0x0373fc456c53bb779bf0ea9fffffffffff;
    //     _maxExpArray[83] = 0x034f9e8e490c48e67e6ab8bfffffffffff;
    //     _maxExpArray[84] = 0x032cbfd4a7adc790560b3337ffffffffff;
    //     _maxExpArray[85] = 0x030b50570f6e5d2acca94613ffffffffff;
    //     _maxExpArray[86] = 0x02eb40f9f620fda6b56c2861ffffffffff;
    //     _maxExpArray[87] = 0x02cc8340ecb0d0f520a6af58ffffffffff;
    //     _maxExpArray[88] = 0x02af09481380a0a35cf1ba02ffffffffff;
    //     _maxExpArray[89] = 0x0292c5bdd3b92ec810287b1b3fffffffff;
    //     _maxExpArray[90] = 0x0277abdcdab07d5a77ac6d6b9fffffffff;
    //     _maxExpArray[91] = 0x025daf6654b1eaa55fd64df5efffffffff;
    //     _maxExpArray[92] = 0x0244c49c648baa98192dce88b7ffffffff;
    //     _maxExpArray[93] = 0x022ce03cd5619a311b2471268bffffffff;
    //     _maxExpArray[94] = 0x0215f77c045fbe885654a44a0fffffffff;
    //     _maxExpArray[95] = 0x01ffffffffffffffffffffffffffffffff;
    //     _maxExpArray[96] = 0x01eaefdbdaaee7421fc4d3ede5ffffffff;
    //     _maxExpArray[97] = 0x01d6bd8b2eb257df7e8ca57b09bfffffff;
    //     _maxExpArray[98] = 0x01c35fedd14b861eb0443f7f133fffffff;
    //     _maxExpArray[99] = 0x01b0ce43b322bcde4a56e8ada5afffffff;
    //     _maxExpArray[100] = 0x019f0028ec1fff007f5a195a39dfffffff;
    //     _maxExpArray[101] = 0x018ded91f0e72ee74f49b15ba527ffffff;
    //     _maxExpArray[102] = 0x017d8ec7f04136f4e5615fd41a63ffffff;
    //     _maxExpArray[103] = 0x016ddc6556cdb84bdc8d12d22e6fffffff;
    //     _maxExpArray[104] = 0x015ecf52776a1155b5bd8395814f7fffff;
    //     _maxExpArray[105] = 0x015060c256cb23b3b3cc3754cf40ffffff;
    //     _maxExpArray[106] = 0x01428a2f98d728ae223ddab715be3fffff;
    //     _maxExpArray[107] = 0x013545598e5c23276ccf0ede68034fffff;
    //     _maxExpArray[108] = 0x01288c4161ce1d6f54b7f61081194fffff;
    //     _maxExpArray[109] = 0x011c592761c666aa641d5a01a40f17ffff;
    //     _maxExpArray[110] = 0x0110a688680a7530515f3e6e6cfdcdffff;
    //     _maxExpArray[111] = 0x01056f1b5bedf75c6bcb2ce8aed428ffff;
    //     _maxExpArray[112] = 0x00faadceceeff8a0890f3875f008277fff;
    //     _maxExpArray[113] = 0x00f05dc6b27edad306388a600f6ba0bfff;
    //     _maxExpArray[114] = 0x00e67a5a25da41063de1495d5b18cdbfff;
    //     _maxExpArray[115] = 0x00dcff115b14eedde6fc3aa5353f2e4fff;
    //     _maxExpArray[116] = 0x00d3e7a3924312399f9aae2e0f868f8fff;
    //     _maxExpArray[117] = 0x00cb2ff529eb71e41582cccd5a1ee26fff;
    //     _maxExpArray[118] = 0x00c2d415c3db974ab32a51840c0b67edff;
    //     _maxExpArray[119] = 0x00bad03e7d883f69ad5b0a186184e06bff;
    //     _maxExpArray[120] = 0x00b320d03b2c343d4829abd6075f0cc5ff;
    //     _maxExpArray[121] = 0x00abc25204e02828d73c6e80bcdb1a95bf;
    //     _maxExpArray[122] = 0x00a4b16f74ee4bb2040a1ec6c15fbbf2df;
    //     _maxExpArray[123] = 0x009deaf736ac1f569deb1b5ae3f36c130f;
    //     _maxExpArray[124] = 0x00976bd9952c7aa957f5937d790ef65037;
    //     _maxExpArray[125] = 0x009131271922eaa6064b73a22d0bd4f2bf;
    //     _maxExpArray[126] = 0x008b380f3558668c46c91c49a2f8e967b9;
    //     _maxExpArray[127] = 0x00857ddf0117efa215952912839f6473e6;
    // }

    /**
     * General Description:
     *     Determine a value of precision.
     *     Calculate an integer approximation of (_baseN / _baseD) ^ (_expN / _expD) * 2 ^ precision.
     *     Return the result along with the precision used.
     *
     * Detailed Description:
     *     Instead of calculating "base ^ exp", we calculate "e ^ (ln(base) * exp)".
     *     The value of "ln(base)" is represented with an integer slightly smaller than "ln(base) * 2 ^ precision".
     *     The larger "precision" is, the more accurately this value represents the real value.
     *     However, the larger "precision" is, the more bits are required in order to store this value.
     *     And the exponentiation function, which takes "x" and calculates "e ^ x", is limited to a maximum exponent (maximum value of "x").
     *     This maximum exponent depends on the "precision" used, and it is given by "_maxExpArray[precision] >> (_MAX_PRECISION - precision)".
     *     Hence we need to determine the highest precision which can be used for the given input, before calling the exponentiation function.
     *     This allows us to compute "base ^ exp" with maximum accuracy and without exceeding 256 bits in any of the intermediate computations.
     */
    function _power(uint256 _baseN, uint256 _baseD, uint32 _expN, uint32 _expD)
        internal
        view
        returns (uint256, uint8)
    {
        uint256 lnBaseTimesExp = _ln(_baseN, _baseD) * _expN / _expD;
        uint8 precision = _findPositionInMaxExpArray(lnBaseTimesExp);
        return (_fixedExp(lnBaseTimesExp >> (_MAX_PRECISION - precision), precision), precision);
    }

    /**
     * Return floor(ln(numerator / denominator) * 2 ^ _MAX_PRECISION), where:
     * - The numerator   is a value between 1 and 2 ^ (256 - _MAX_PRECISION) - 1
     * - The denominator is a value between 1 and 2 ^ (256 - _MAX_PRECISION) - 1
     * - The output      is a value between 0 and floor(ln(2 ^ (256 - _MAX_PRECISION) - 1) * 2 ^ _MAX_PRECISION)
     * This functions assumes that the numerator is larger than or equal to the denominator, because the output would be negative otherwise.
     */
    function _ln(uint256 _numerator, uint256 _denominator) internal pure returns (uint256) {
        assert(_numerator <= _MAX_NUM);

        uint256 res = 0;
        uint256 x = _numerator * _FIXED_1 / _denominator;

        // If x >= 2, then we compute the integer part of log2(x), which is larger than 0.
        if (x >= _FIXED_2) {
            uint8 count = _floorLog2(x / _FIXED_1);
            x >>= count; // now x < 2
            res = count * _FIXED_1;
        }

        // If x > 1, then we compute the fraction part of log2(x), which is larger than 0.
        if (x > _FIXED_1) {
            for (uint8 i = _MAX_PRECISION; i > 0; --i) {
                x = (x * x) / _FIXED_1; // now 1 < x < 4
                if (x >= _FIXED_2) {
                    x >>= 1; // now 1 < x < 2
                    res += _ONE << (i - 1);
                }
            }
        }

        return (res * _LN2_MANTISSA) >> _LN2_EXPONENT;
    }

    /**
     * Compute the largest integer smaller than or equal to the binary logarithm of the input.
     */
    function _floorLog2(uint256 _n) internal pure returns (uint8) {
        uint8 res = 0;
        uint256 n = _n;

        if (n < 256) {
            // At most 8 iterations
            while (n > 1) {
                n >>= 1;
                res += 1;
            }
        } else {
            // Exactly 8 iterations
            for (uint8 s = 128; s > 0; s >>= 1) {
                if (n >= (_ONE << s)) {
                    n >>= s;
                    res |= s;
                }
            }
        }

        return res;
    }

    /**
     * The global "_maxExpArray" is sorted in descending order, and therefore the following statements are equivalent:
     *   - This function finds the position of [the smallest value in "_maxExpArray" larger than or equal to "x"]
     *   - This function finds the highest position of [a value in "_maxExpArray" larger than or equal to "x"]
     */
    function _findPositionInMaxExpArray(uint256 _x) internal view returns (uint8) {
        uint8 lo = _MIN_PRECISION;
        uint8 hi = _MAX_PRECISION;

        while (lo + 1 < hi) {
            uint8 mid = (lo + hi) / 2;
            if (_maxExpArray[mid] >= _x) {
                lo = mid;
            } else {
                hi = mid;
            }
        }

        if (_maxExpArray[hi] >= _x) {
            return hi;
        }
        if (_maxExpArray[lo] >= _x) {
            return lo;
        }

        // assert(false);
        return 0;
    }

    /**
     * This function can be auto-generated by the script 'PrintFunctionFixedExp.py'.
     *   It approximates "e ^ x" via maclaurin summation: "(x^0)/0! + (x^1)/1! + ... + (x^n)/n!".
     *   It returns "e ^ (x / 2 ^ precision) * 2 ^ precision", that is, the result is upshifted for accuracy.
     *   The global "_maxExpArray" maps each "precision" to "((maximumExponent + 1) << (_MAX_PRECISION - precision)) - 1".
     *   The maximum permitted value for "x" is therefore given by "_maxExpArray[precision] >> (_MAX_PRECISION - precision)".
     */
    function _fixedExp(uint256 _x, uint8 _precision) internal pure returns (uint256) {
        uint256 xi = _x;
        uint256 res = 0;

        xi = (xi * _x) >> _precision;
        res += xi * 0x03442c4e6074a82f1797f72ac0000000; // add x^2 * (33! / 2!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0116b96f757c380fb287fd0e40000000; // add x^3 * (33! / 3!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0045ae5bdd5f0e03eca1ff4390000000; // add x^4 * (33! / 4!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000defabf91302cd95b9ffda50000000; // add x^5 * (33! / 5!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0002529ca9832b22439efff9b8000000; // add x^6 * (33! / 6!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000054f1cf12bd04e516b6da88000000; // add x^7 * (33! / 7!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000a9e39e257a09ca2d6db51000000; // add x^8 * (33! / 8!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000012e066e7b839fa050c309000000; // add x^9 * (33! / 9!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000001e33d7d926c329a1ad1a800000; // add x^10 * (33! / 10!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000002bee513bdb4a6b19b5f800000; // add x^11 * (33! / 11!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000003a9316fa79b88eccf2a00000; // add x^12 * (33! / 12!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000048177ebe1fa812375200000; // add x^13 * (33! / 13!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000005263fe90242dcbacf00000; // add x^14 * (33! / 14!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000057e22099c030d94100000; // add x^15 * (33! / 15!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000057e22099c030d9410000; // add x^16 * (33! / 16!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000052b6b54569976310000; // add x^17 * (33! / 17!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000004985f67696bf748000; // add x^18 * (33! / 18!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000000003dea12ea99e498000; // add x^19 * (33! / 19!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000000031880f2214b6e000; // add x^20 * (33! / 20!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000000000025bcff56eb36000; // add x^21 * (33! / 21!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000000000001b722e10ab1000; // add x^22 * (33! / 22!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000000001317c70077000; // add x^23 * (33! / 23!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000000000000cba84aafa00; // add x^24 * (33! / 24!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000000000000082573a0a00; // add x^25 * (33! / 25!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000000000000005035ad900; // add x^26 * (33! / 26!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x0000000000000000000000002f881b00; // add x^27 * (33! / 27!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000000000000001b29340; // add x^28 * (33! / 28!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x000000000000000000000000000efc40; // add x^29 * (33! / 29!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000000000000000007fe0; // add x^30 * (33! / 30!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000000000000000000420; // add x^31 * (33! / 31!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000000000000000000021; // add x^32 * (33! / 32!)
        xi = (xi * _x) >> _precision;
        res += xi * 0x00000000000000000000000000000001; // add x^33 * (33! / 33!)

        return res / 0x688589cc0e9505e2f2fee5580000000 + _x + (_ONE << _precision); // divide by 33! and then add x^1 / 1! + x^0 / 0!
    }
}
