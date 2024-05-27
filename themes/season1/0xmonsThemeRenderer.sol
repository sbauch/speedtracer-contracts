// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IThemeRenderer} from "../IThemeRenderer.sol";
import {LibString} from "solady/src/utils/LibString.sol";

/// @author sammybauch.eth
/// @title  Speedtracer Unlooped Theme
/// @notice Colors, font and names for Unlooped themed Speedtracer track
contract XmonsThemeRenderer is IThemeRenderer {
    bytes16 private constant SYMBOLS = "0123456789ABCDEF";

    uint24 public constant BACKGROUND_COLOR = 0x070F25;
    uint24 public constant KERB_COLOR = 0x66DFCD;
    uint24 public constant ROAD_COLOR = 0x070F25;
    uint24 public constant MIDLINE_COLOR = 0x66DFCD;

    string public constant FONT =
        "url(data:font/woff2;base64,d09GMgABAAAAABJsAA0AAAAASJgAABIXAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGhYcgzwGYACEdBEICvEc0xcLg0YAATYCJAOGeAQgBYRKB4RoG+g2VUaHjQMaBipCoigXpAXZ/9cJnNzfWYHGliDicktanI7Lg1M0I4lm/2zsQjCwZJ/bnriTj0iQQVIIN5ZlfJi+dWMknmsQXjab5FhrS12/BvIgdSqWWgCpsfcA0Tq//06U0ifb6/A8cbX39wLZWeAISuQ6dKnTGl+MEw0sgyiwZhN83F+9ij5RETFqxOijzj0W+tg9/6v0VZKbdKQB8y8vaaWB778bvxZmhUnnZB9X+a3Mlzug9JKp1tD/z2bazkgHUthAZUDGLikqwD4VvT5FZ/2Zv+PZ0WgiWOHJLJN8Nt8lvLPS+a1kAChdBbB0LoBY5aXClqgpUzWXLm2dos+2f9UT3IGTlDe88FIIpnoqJTpM5scf7b6X/fSBLbbb6A/nP0CKR4gxBDzP46TZviIgAEUAABA3MFgsApCKsxgzi4hLg6wvbmuAMl1kGpxGIQW5XMMQEJMgYKzPEeHASehHEpIeS+ubkGT9/63B1RBzo311ZTHCGo2ldQgQpAhE2Sjz7gGhz1ivRQw/yjgAIUYYY2iSymjkYUxR2vQ4mEHlIsR9LyI8pe+nZSgS6vv+uXoxUhFEEqXfAUM7//NNxFpkCIYyoQlIjddqULFzBxpMeFuGBSkWxFGnaTURgKBG0KjSj4T1ASRLYrqFNRaSSp1AuQbjhpv2taTiypdkIgTADJEFINY/KdlAlsMAIDBdVeRdhs5TwnEQzDr2JQCwX9JBgQUAML/QEaigz9fEIqO4ouiL9kBxtAFKnHnrT05cSSqzN44zt5m7LKGaVJ8aUzNqRX1oGG2ja03NTCeZTjHTksuBMy3lwsfC3pQZQVuqSw0v2fs7wvEbIBEAuTn8N/pd/wX/bgAPX8DDk2Ydouk+VHmw8YH3A6/7q0AAgAyQ4DqQJ6Y8GTbN4f841kzzzbbbKecssMJKkxww3RpzLDLNQkcddsRcZ3EUKVGhRpsOXXqMmaDMmLPkyJkLVzJuvHjz4cvfMpMtd91i9wWIEClarCTJUqTKliNXvgJFqtSoVadBozbtOnTqscRVSx23wyw77bXLPtdccM9FvHVOWOuSB644ZrQxbjvpvCnuGKW/9SYYb6J5xASEpEQkFCjTok6DJiP6DBhSZcGWFWv2bBxkx1M/7jz4cVIvRKAgYYKFChclUZx4CbKky5ApRqEyxUpUKHVIuVZNmrXoUq2bg0qrrbLZFpsQZJQbAOAxAOQDkD+g9gA0GwBCgA0AYAEAAISUmqNBCDM6lZYrAIHRtyebpmDYKUPciWSTZUItyp0ohgRR8BJCWAQbupN7i2LnF6zqnl5JOIqKBUN4TATPIrNVQsLQF5qvz770XzXRVEZqcQDUpslrsluSTkH0qhzOyI8k5QesZnkX2/8p2DY6AMDTXCTV6v5VIaFLL0vOBOyYvO4+LzXe4hC3ln5a2oIuz3y0c3qOvDMBO5InR0PaNQ+KBV2fug8MKStvwWQ0+IRHD+UJGcPV6h5AZD3Ob4LPAe6yuTmf3gi925UgqYoizac4Ictzq/UYT5HF75viV8kKVdaC5OJG5ZjHN61nQAi4mH+b+jdr7TyRHInXKbJQIqDpLGv1oW6wuUQhCVuGDhQ7Iib8hFk892P3qrKjoDDFxTQLhpvYkUVR0Cb6MuwCpTlHoJSoohjR4rmKM+KKe1MXfKATFn9kfhpngTcA4lcRaZ7b5mlZkgP8APFlhsgyakBE06BTyBr3I1hdeFXsbSOnMhLKFqdCfp+w4R5Q8ZlTq2+MfEzkRAhP5zgl53aOs2Ld5wrURzk6oNAx0Gxzhsr/LwX+V0ZE93lnNjW8cK8N4keROxRV1QZ6Rc8gVnDvqPROma54UZNI40KAog7PFQrpecRXgyWECPZFjRBU+JEXraRZE7W4CeWcV1Vpjlr1oX/u3WpXeUUTR8MAgazhOsJRcI6mCGKXwdAqOtXyFLW8cyqcRNmB4vWnWvq7ewwO5AvLPYpivVdZq4+5qexV5pQ5IkHyOiF+tUuxmxbr0a9JIz+OYRWhDVni3Vr95OVdBabckUmoXRemlNsxaR3O/N7Mymo0wN9adgtn1R0Ll1XmoQsecR7rlQDMB9XwYlSQp41+DBIIE77niL6pghsxSiLlpi6c+RN39YUdGJRB4JO5rIYz141jdQjkOC4FdYhFs7emNW7JhM9+toIZIX4mOo/UV5hylmNHt/apSBFz0PF01KkDq4IoPLsYAyxhOpQENZY1q8EijPqVRYgjExsgPYsrkSRmI1lEUVVP6mYPIRfrHwwIosDCW0NNjaJ3n4jNsAoWV/qh/rGjLKE0pV+NFVNsNgiYJWUQGL0QSRNL1w3xq15laGxBhkRWTcwFQ0DWwHrqjRDRcHaC0vKt4WJoJ1i1JM4ymgIaL6G58ofVZAlcED25wMoyhjt1JfNq+KlUOIrsR1skUKMWVG0RGuFiZkHYXXjYMIWMJhLy3CenzlhoKUhZD4VqBorym3mR94ZCiwudpD4NqdKbSIKGFSoUsngFgjBypKcUmSYIm9FkLDgzLQu1zBabBZhGCTDKVXi02SlanLrcni22tPn1jj+d/kDDlDKR+fmRrUYpp5IdOwUIRK45dZPOPKl8VFPnBAugDujgDiAS0QBpfjE1mE8sQaVA70IjcA+rJulUxGH9piBwLQ+JMQkfhWsdwt19kj2TLp2wVZj6g0CrfR2OHN0pboJEYJnLhb42iDngAEtuzPOI0JZ6DYIlsOXkJ0MqeITKHQQ0M/w99jy1Ppx36gNYNGPtdu62IxhXWIEurvUSkdYM0pMngrFYpBjlbspZMuiaxko+3R3uaVyQznES0+z1Qn1yUhBeQEg1TGg6EA2mVijUutOkGYFiD3S3CNuQzLBUdI/Mgw34op/9aBmRKnkMgchmYvtkKdcNnPuCmkVb7Ux6szd6MxLV5LEYc80Rnq6C2O/h/FrEIcu93wc2c2A9wRaR77XX0DjyzeZsqr635qTd0woZfVahRTFgMX9FdOo+CF/FIbrRWS2a5eHyt9uwgEiFXDJzQUMcId3hDuqGB0esVckDp2RzQtt0BfuMVxJhEBt191O+34x64JjaWHj0B8eVL/kSl2gbPpv+TxN+7Rbsed/dn3yB6wTnfGf3Yj608l8xnwy3iYY+Q3xe0LVdYkDB/IVd3B/E/2c+7wpRi9lZkb22DYcnN21xyILzJPjZswMah6nTfcKGKAtLDJIAZhCXuKnsqT7Dn6dabZkwIIKnGcu2znqY1WI0o0gZ+uzpB3kGbsfm3hrqhQ4rXKbwyu8IZKXTCSyvXW7EfKoz9gcRRBm45br37n06LjbWfK//SZv+B9luSfHQnzcWGOdgIZQn2zhwP2+q7TRkw5dnSAb7GGfclTTBAOUJEICpMRGAejQA70ZY8Eci5SC27NT4/sbumxep7QoE5PcL0O50Up2t/5v5nSviruB5DjQ3tTGRSJO9e2WWJTqTUFWLbGswjJTHAUmmuTdmzqngdaMBLfINuMxvGe/asvCQwE6P398+5THW3trtK8UuFdP1Y96GdxzzGDxt2onJrBdQCDsc8yqK+h3eb+gLc+RiuG0r9rmsHkPCPR1eSJeHSfx74WLjlOP3LmeqOuMDABIxHkxBz6L6wZW6QpO2a6E7MViQ4/FTmTrd2VSEQV0xPM1m2VoqvJuHGzYiXUNzrgC1s3WQYOq1gf1Ym7wThvZnw/xacXdmgs+tVE2IhONUJDcOiVrklV/cj1L9+4Eh65AEr1VLie2+EYC/oA1xxjaHh1MjPFubw4T6t5kvJOU2ExugVJfiCLf8gAZot7lMj+p7gSGirfMEK4GflEO1lQWlfdBWB1I9HpyRUjH2Qljb2cO2nS5+TGm8D0LLAwRGk5+6wAZUUUAsK3ntXDehxsbGy8g1nwkPECqme7oJruRL7FZ+wi4gEOOJrh8+e8fQjAMSX8PVu6G/HW61Qp9vMM/ul/vgDuG8vtklEGxXpENMQnzYtm3HYZsjX3g+PaPIBIO8BSsx6gX7PhD8+aAcZiY1Nx+mE4GAsD8RsKx1fH/gwZCT7in9Kv7JfW/lRbsccA+T5q7RhXIQ8zpyP0Mz5tdgBdGtyFtJ6tptr2BTs2ugiZUzMVdykoj0hdu6IncihXfl6ImDdcv1fZzgO+b+wbp2/whr4g900HsrdYXCwLobpFJTmrdvM6Yo/aGTHuN9ak/OuXl6wgtx7GbfRkdYZ+b0ZonlP3EKRh1jdMQ9Q4lvMdz8E+8mdJdrnLFL4qTxr76St6RC7nwZCyIb62qhZm3FBpcg2XjJadFg2vU80BAOPgZgF1s0O0zB2p15xHfjnbXNDM3xjzU91qmkj/023eEWywvxElxBhuAldJwPDjr93/o9hFOCjHxImbFLQrrzh5Getl3NzqEOnmKlZTtHgoOyoBygW5SfWPYq9zamfMJ3ro12rhFysAgmlVBHRs7cFeOIfL1qbJ8jXblLVbSpZ+aEjhp8tNcCgpO/OxI2CV07O3H6IqWi/XwK62rg3UaQfR2puYVmEt9AAdRRPHHCKjxJd9LTA+iaW/5jnaYfy2tfsoEdD+QYUYvpi8TmzDaL16Zje9uJNi6Fu+HbvO1mV0lLj3eCoUCFx/F6Ry2uchUBLerd3VClxWudOENVyFgkF0w7E3wP54+HW7+gs7g1tQtLWTNU0PbOLdnrctYjw7E43J+h76S1iy+Gqw87fpneuh4ODdO7GQyqSWdMd15obhNG47QJNnN6FN5W33ZeaCqv/1cDB8XlPO8gebzZiu35nqkP1NYdCs2l4+n2Uc8N//dJeyVYCuVAwDapnfO7EBKiNh9xtmIeroTYlvoMa4eE0MDTkLBOdDB3EqPCeO699VgSdbjBUbeU7coiE8dGiO1CWE35YXC0uPSc1bReq+mjNZB40F08SumH3Md5/pOkFoO/jTIoShJt7Fpv2FbrQljXd191IUjPe//bCFC1bE4qEfH4XYS2e5DX+BUn8/blkpWMwXAg3aPre61ssV3/vcl3r7J+TzLZm8nf5tkzkdD9x12LSdUCOPQorI3scl2P+Yd/d4c5EN8Ktf42QR4/nWtb3GuPGMKlDND0fVP13/FpOuK3m/42sjcSYALdNLz+bsde9rtq+kUIbd2umg5UaY9HucjTdLanLO3hKH0x1E7+oJ5T95Rpe04dQ+SsUSv648RXLtS7b2xzKxIHFvOusC4zUQ5phBYukoPT9vl+ymSAsQg7XYXx7vmyln0JAmBh+vvOsMLh940s+xIArk7od3/bW5P/Xv8/Ol/GtIhNCGDYzUx4QA5rkrchxSdH7uYS+cD4CMg/9PTF+JFUclP5DcW/gS8T4UdCCy4v3/ZbbQhKN2/RLV4nXnWjM+9t3ZzajU3gJdrqEtEy3jDvI1E2Tzo304CHfz7ufLgFueM3eLyP8H8SAnjMiyILos+kIvj5xCqwSCUBcDvSc4Iw9D7BUPYwwQqwOMFx0JEQ0JeXELLRTyqbpUCVtvncJj6cV29VqkW1lm16lJNWWedlY0RWplZPFCFOEpLl8G5apWpTrEUbmSSOUpSr1K5OywylWvjDNWpAuXHiMvu+hKlS1F4C9TN+bXyFypYinG95G7Vecu1QjZp0116rVBXjvQNlKi0g5S2zMVFuVJNUpZFysHalqloH5OFtlGpUpluQnobQcull4ThcG1sOqE7VDN4E1dpA2aEbZagIDXkbCYrVy9l0M/sXmmEAAOTbyEzf9MdACjBYFk45ocQ6pdabyJKVMtZesVHupNPOsGXHnoOzzjnvAkdOnMPChasKMhddUumKSTbYyM27joXH8+TlqmuqXO/DuK2fN/yFqe6wkDW2UW+h8PrWjvRalKaWvZpm0WLEinNDmw6d2rscqonhejZkl/18uvXq02MR3iap3kuTLsMombL0N9AgAzo73liet3bLd9Ah88ynQZNW9wjvvPgvjoAIiYiIsddXfMN3KAl0xAhGVKzBWUJIjZnFBKSMqQtRoEiAIAoUbbGZaiRYZbX9Djhmq2222+FopBhqH1EUMMz0KELZR+xEmTIxRbGlUYI4ykQF5iRGGm6M0cYaotBLwVElakQd49x303ihbrvn1iv+o9DVubjnxjaubnsHUfunaheXEG/fLYu4TZS5ePYD7AWHQdaF+xXsM4fklbEyV/dZIeoixd9aGjvbmyTQx9Yu+ZvD28v//e2ZYXVtb3OMWJGFhAIA) format('woff2')";

    function themeName() external pure returns (string memory) {
        return "0xmons";
    }

    function name(uint256) external pure returns (string memory trackName) {
        return "0xmons MotoGP";
    }

    function background() external pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<rect id='bg' width='1200' height='1950' fill='#",
                toHexString(BACKGROUND_COLOR),
                "' />  <rect x='30' y='30' width='1140' height='1890' fill='url(#grid)' filter='url(#glow)' stroke-width='1' stroke='#66DFCD' />"
            )
        );
    }

    function road() external pure returns (string memory) {
        return toHexString(ROAD_COLOR);
    }

    function kerb() external pure returns (string memory) {
        return toHexString(KERB_COLOR);
    }

    function midline() external pure returns (string memory) {
        return toHexString(MIDLINE_COLOR);
    }

    function font() external pure returns (string memory) {
        return FONT;
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        bytes memory buffer = new bytes(6);
        for (uint256 i = 0; i < 6; ++i) {
            buffer[5 - i] = SYMBOLS[value & 0xF];
            value >>= 4;
        }
        return string(buffer);
    }

    function filter(uint256) external pure returns (string memory) {
        return
        '<filter id="noise"><feComponentTransfer><feFuncR type="identity" /><feFuncG type="identity" /><feFuncB type="identity" /><feFuncA type="identity" /></feComponentTransfer></filter><filter id="tf" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur in="SourceGraphic" stdDeviation="2" result="blurred"></feGaussianBlur><feMerge><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /><feMergeNode in="blurred" /></feMerge></filter><filter id="glow" x="-50%" y="-50%" width="200%" height="200%"><feFlood result="flood" flood-color="#66DFCD" flood-opacity="1"></feFlood><feComposite in="flood" result="mask" in2="SourceGraphic" operator="in"></feComposite><feGaussianBlur in="mask" result="blurred" stdDeviation="1"></feGaussianBlur><feMerge><feMergeNode in="blurred"></feMergeNode><feMergeNode in="SourceGraphic"></feMergeNode></feMerge></filter><pattern id="grid" width="30" height="30" patternUnits="userSpaceOnUse"><path d="M 30 0 L 0 0 0 30" fill="none" stroke="#66DFCD" stroke-width="1"/></pattern>';
    }
}
