// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IDelegateRegistry} from "./IDelegateRegistry.sol";
import {IERC721A} from "erc721a/contracts/IERC721A.sol";
import {IThemeRenderer} from "./themes/IThemeRenderer.sol";

import {Base64} from "solady/src/utils/Base64.sol";
import {Context} from "openzeppelin/contracts/utils/Context.sol";
import {DynamicBuffer} from "./DynamicBuffer.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";
import {TrackUtils} from "./TrackUtils.sol";

/// @author sammybauch.eth
/// @title  Speedtracer tracetrack renderer
/// @notice Render an SVG racetrack for a given seed
contract BetaTrackRenderer is TrackUtils, Context {
    using DynamicBuffer for bytes;
    using Strings for uint256;
    using Strings for uint24;

    uint64 private constant maxSupply = 366;
    uint256 public immutable greenFlag;

    uint64 private constant CANVAS_WIDTH = 1200;
    uint64 private constant CANVAS_HEIGHT = 1950;
    uint64 private constant CANVAS_OFFSET = 240;

    address[] private themes;

    uint64 private constant minPointDistance = 220;
    uint64 private constant minCurveDistance = 220;
    uint64 private constant newWidth = CANVAS_WIDTH - 2 * CANVAS_OFFSET;
    uint64 private constant newHeight = CANVAS_HEIGHT - 2 * CANVAS_OFFSET;
    uint64 private constant perimeter = 2 * newWidth + 2 * newHeight;

    IERC721A public nftContract;

    address public constant DELEGATE_REGISTRY =
        0x00000000000000447e69651d841bD8D104Bed493;

    mapping(uint256 => bytes) public customTracks;
    mapping(uint256 => address) public customTheme;

    struct AdUnit {
        uint32 width;
        uint32 height;
        uint32 x;
        uint32 y;
        int32 rotation;
        string src;
    }

    struct RaceResultAd {
        string src;
        string href;
    }

    mapping(uint256 => AdUnit[]) public adBoards;
    mapping(uint256 => RaceResultAd) public raceResultAds;

    error NotOwnerOrDelegate();

    event TrackUpdated(uint256 id);
    // ****************** //
    // *** INITIALIZE *** //
    // ****************** //

    constructor(address _nftContract, address[] memory _themes) {
        greenFlag = 1704895200;
        themes = _themes;
        nftContract = IERC721A(_nftContract);
    }

    // ************** //
    // *** ERC721 *** //
    // ************** //

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        string memory trackName = theme(tokenId).name(tokenId);
        string memory themeName = theme(tokenId).themeName();

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            trackName,
                            '", "description":"Speedtracer is a longform generative project that creates skeuomorphic racetrack artworks, or tracetracks.", "image": "data:image/svg+xml;base64,',
                            Base64.encode(render(tokenId), false, false),
                            '", "attributes": [{"trait_type": "theme", "value": "',
                            themeName,
                            '"}, {"trait_type": "season", "value": 0}, { "display_type": "date", "trait_type": "race date", "value": ',
                            (greenFlag + (1 days * tokenId)).toString(),
                            '}, {"trait_type": "authorship", "value": ',
                            customTracks[tokenId].length == 0
                                ? '"Algorithmic"'
                                : '"Human Augmented"',
                            "}]}"
                        )
                    )
                )
            )
        );
    }

    function setTheme(uint256 id, address themeRenderer) external {
        assertOwnerOrDelegate(id);

        customTheme[id] = themeRenderer;
        emit TrackUpdated(id);
    }

    function setTrack(uint256 id, bytes calldata trackData) external {
        assertOwnerOrDelegate(id);

        customTracks[id] = trackData;
        emit TrackUpdated(id);
    }

    function setAds(uint256 id, AdUnit[] memory ads) external {
        assertOwnerOrDelegate(id);

        delete adBoards[id];

        for (uint256 index = 0; index < ads.length; index++) {
            adBoards[id].push(ads[index]);
        }
    }

    function getAds(uint256 id) external view returns (AdUnit[] memory) {
        return adBoards[id];
    }

    function setRaceResultAd(uint256 id, RaceResultAd calldata ad) external {
        assertOwnerOrDelegate(id);

        raceResultAds[id] = ad;
    }

    function assertOwnerOrDelegate(uint256 id) internal view {
        address owner = nftContract.ownerOf(id);
        if (_msgSender() == owner) return;
        if (
            IDelegateRegistry(DELEGATE_REGISTRY).checkDelegateForERC721(
                _msgSender(), owner, address(nftContract), id, ""
            )
        ) return;

        revert NotOwnerOrDelegate();
    }

    // ********************* //
    // *** COMPOSABILITY *** //
    // ********************* //

    /// @notice Time-based ID for today's track - new track every day
    function currentId() external view returns (uint256) {
        if (block.timestamp < greenFlag) {
            return pseudoRandom((greenFlag - block.timestamp) / 1 days);
        }
        uint256 secondsSinceDeploy = block.timestamp - greenFlag;
        uint256 daysSinceDeploy = secondsSinceDeploy / 86400;
        if (daysSinceDeploy >= maxSupply) {
            daysSinceDeploy = daysSinceDeploy % maxSupply;
        }
        return daysSinceDeploy + 1;
    }

    /// @notice Full SVG of the racetrack
    /// @param id The seed for the racetrack to render. Use 0 to get today's track.
    /// @return The SVG of the racetrack as a string for full display
    function svg(uint256 id) external view returns (string memory) {
        return string(render(id == 0 ? this.currentId() : id));
    }

    /// @notice SVG path string of the racetrack
    /// @param id The seed for the racetrack to render. Use 0 to get today's track.
    /// @return _d string to be used in the `d` attribute of an SVG path element
    /// @dev Returns the path of the racetrack without control point handles, styling or other SVG elements
    ///      to allow for composability with other SVG elements.
    function d(uint256 id) external view returns (string memory _d) {
        _d = string(renderTrack(id == 0 ? this.currentId() : id));
    }

    function render(uint256 id) internal view returns (bytes memory _svg) {
        _svg = DynamicBuffer.allocate(2 ** 16);

        _svg.appendSafe(
            abi.encodePacked(
                "<svg viewBox='0 0 1200 1950' xmlns='http://www.w3.org/2000/svg'><style> @font-face { font-family: TF; src:",
                themeAndFilters(id),
                theme(id).background(),
                kerbs(id),
                road(id),
                midline(id),
                name(id),
                "</svg>"
            )
        );
    }

    // ************** //
    // *** MARKUP *** //
    // ************** //

    function themeAndFilters(uint256 id) internal view returns (bytes memory) {
        return abi.encodePacked(
            theme(id).font(),
            " } </style><defs>",
            theme(id).filter(id),
            "</defs>"
        );
    }

    function kerbs(uint256 id) internal view returns (bytes memory) {
        return abi.encodePacked(
            "<path id='x' stroke-linecap='round' fill='none' stroke-width='100' stroke-linejoin='round' stroke='#",
            theme(id).kerb(),
            fullD(id),
            " />"
        );
    }

    function road(uint256 id) internal view returns (bytes memory) {
        return abi.encodePacked(
            "<path id='t' filter='url(#noise)' stroke-linecap='round' fill='none' stroke-width='88' stroke-linejoin='round' stroke='#",
            theme(id).road(),
            fullD(id),
            " />"
        );
    }

    function midline(uint256 id) internal view returns (bytes memory) {
        return abi.encodePacked(
            "<path id='mid' fill='none' stroke-width='",
            "3",
            "' stroke-dasharray='",
            (8 + (4 * (id % 5))).toString(),
            ", ",
            id % 69 == 0 ? "0" : "48",
            "' stroke='#",
            theme(id).midline(),
            fullD(id),
            " />"
        );
    }

    function name(uint256 id) internal view returns (bytes memory) {
        return abi.encodePacked(
            "<text style='filter: url(#tf);' x='40' y='1910' font-family='TF' font-size='80' width='20%' fill='#",
            theme(id).road(),
            "'>",
            theme(id).name(id),
            "</text>",
            "<text x='40' y='1910' font-family='TF' font-size='80' width='20%' fill='#",
            theme(id).kerb(),
            "'>",
            theme(id).name(id),
            "</text>"
        );
    }

    function theme(uint256 id) internal view returns (IThemeRenderer) {
        if (customTheme[id] != address(0)) {
            return IThemeRenderer(customTheme[id]);
        }

        uint256 seed = pseudoRandom(id) % 1000;
        if (seed > 990) return IThemeRenderer(themes[5]);
        if (seed > 900) return IThemeRenderer(themes[4]);
        if (seed > 850) return IThemeRenderer(themes[3]);
        if (seed > 750) return IThemeRenderer(themes[2]);
        if (seed > 500) return IThemeRenderer(themes[1]);
        return IThemeRenderer(themes[0]);
    }

    function fullD(uint256 id) internal view returns (bytes memory) {
        return abi.encodePacked("' d='", renderTrack(id), "'");
    }

    // ************* //
    // *** TRACK *** //
    // ************* //

    /// @notice Generate a bytes string containing the SVG path data for a racetrack.
    /// @param id The seed for the racetrack
    /// @return track The SVG path data for the racetrack
    /// @dev Return value can be used in the `d` attribute of an SVG path element
    function renderTrack(uint256 id)
        internal
        view
        returns (bytes memory track)
    {
        if (customTracks[id].length > 0) {
            return customTracks[id];
        }

        return renderGeneratedTrack(id);
    }

    // Segment Types
    // 0 = straight, L
    // 1 = cubic bezier curve
    // 2 = reflecting cubic bezier curve
    // 3 = hairpin turn

    // prevCurveType
    // 0 - straight, needs cap
    // 1 - straight cap, unrestricted
    // 2 - complex curve, needs simple

    /// @notice Generate a bytes string containing the SVG path data for a racetrack.
    /// @param id The seed for the racetrack
    /// @return track The SVG path data for the racetrack
    function renderGeneratedTrack(uint256 id)
        internal
        pure
        returns (bytes memory track)
    {
        uint256 currentSeed = pseudoRandom(id);

        Point[] memory points = generateRacetrack(currentSeed);
        // bytes memory circles = DynamicBuffer.allocate(2 ** 16);
        track = DynamicBuffer.allocate(2 ** 16);

        track.appendSafe(moveTo(points[0]));
        // circles.appendSafe(circle(points[0], 0, 0));

        // // Start the track with a straightaway starting block
        track.appendSafe(line(points[1]));
        // circles.appendSafe(circle(points[1], 1, 0));

        Point memory cp1;
        Point memory cp2;
        Point memory cp3;
        Point memory cp4;
        uint8 prevCurveType;
        uint64 i = 2;
        int256 adjustment = 0;
        for (; i < points.length; i += 1) {
            if (points[i].x == 0 && points[i].y == 0) {
                --i;
                break;
            }

            currentSeed = nextRandom(currentSeed);
            uint256 distance = distanceBetweenPoints(points[i - 1], points[i]);
            uint8 curveType =
                (distance < minCurveDistance) ? 1 : 1 + uint8(currentSeed % 2);

            // We need tp choose a next segment type based on some criteria
            // 1. Custom Segments
            //   a. For things like the starting block and closing the circuit, we have specific functions
            //   b. We need to ensure our corner segments point in the right direction. We know our first corner,
            //      but may need to use math to identify the second and third corners
            // 2. Connectors
            //   a. We need to connect complex segments together with simpler segments
            // 3. Complex Segments
            //   a. If we have space, we should use a complex segment like S curves, chicanes, etc

            // Turn One
            if (i == 3) {
                // If we're moving up, we need to arc turn to change direction
                if (
                    points[i - 2].y > points[i - 1].y
                        && points[i - 1].y > points[i].y
                ) {
                    (cp1, cp2) = arcTurn(points, cp2, i, distance, true);
                    track.appendSafe(cubicBezierCurve(cp1, cp2, points[i]));
                    // circles.appendSafe(circle(cp2, i, 2));
                    // circles.appendSafe(circle(cp1, i, 1));
                    // circles.appendSafe(circle(points[i], i, 0));

                    prevCurveType = 3;

                    continue;
                }

                if (abs(int256(points[i - 1].x) - int256(points[i].x)) < 80) {
                    (cp1, cp2) = hairpinTurn(points, cp2, i, distance);
                    track.appendSafe(cubicBezierCurve(cp1, cp2, points[i]));
                    // circles.appendSafe(circle(cp2, i, 2));
                    // circles.appendSafe(circle(cp1, i, 1));
                    // circles.appendSafe(circle(points[i], i, 0));

                    prevCurveType = 3;

                    continue;
                }
                if (
                    points[i - 1].y > points[i].y
                        && abs(int256(points[i - 1].x) - int256(points[i].x)) > 160
                ) {
                    Point memory midpoint = collinearPoint(
                        points[i],
                        points[i - 1],
                        points[i],
                        int256(distance) / -2
                    );

                    (cp1, cp2, cp3, cp4) = chicane(
                        points[i - 1], midpoint, points[i], cp2, distance
                    );

                    track.appendSafe(cubicBezierCurve(cp1, cp2, midpoint));

                    track.appendSafe(cubicBezierCurve(cp3, cp4, points[i]));

                    // circles.appendSafe(circle(cp2, i, 2));
                    // circles.appendSafe(circle(cp1, i, 1));
                    // circles.appendSafe(circle(midpoint, i, 0));

                    // circles.appendSafe(circle(cp4, i*11, 2));
                    // circles.appendSafe(circle(cp3, i*11, 1));
                    // circles.appendSafe(circle(points[i], i*11, 0));
                    prevCurveType = 3;

                    cp1 = cp3;
                    cp2 = cp4;
                    continue;
                }
            }

            // Turn Two
            if (i == 6) {
                adjustment = -100;
                if (points[i + 1].y < points[i - 1].y) {
                    cp2 = connector(points[i - 1], points[i], currentSeed);
                    track.appendSafe(reflectingCubicBezierCurve(cp2, points[i]));
                    ++i;
                    cp2.x = points[i].x;
                    cp2.y =
                        points[i - 1].y + (points[i - 1].y - points[i - 2].y);
                    track.appendSafe(reflectingCubicBezierCurve(cp2, points[i]));
                    // circles.appendSafe(circle(cp2, i, 2));
                    // circles.appendSafe(circle(cp1, i, 1));
                    // circles.appendSafe(circle(points[i], i, 0));

                    prevCurveType = 3;

                    continue;
                }
                if (points[i + 1].x > points[i - 1].x) {
                    Point memory midpoint = collinearPoint(
                        points[i],
                        points[i - 1],
                        points[i],
                        int256(distance) * -1 + 172
                    );
                    // circles.appendSafe(circle(midpoint, 99, 0));

                    track.appendSafe(
                        reflectingCubicBezierCurve(
                            Point(midpoint.x - 44, midpoint.y + 44), midpoint
                        )
                    );

                    // circles.appendSafe(circle(Point(midpoint.x - 44, midpoint.y + 44), 99, 2));

                    track.appendSafe(
                        abi.encodePacked(
                            " A 2 2 0 0 1 ",
                            intString(points[i].x + 88),
                            " ",
                            intString(points[i].y)
                        )
                    );

                    cp2 = connector(
                        Point(points[i].x + 22, points[i].y),
                        points[i],
                        currentSeed
                    );

                    track.appendSafe(reflectingCubicBezierCurve(cp2, points[i]));

                    // circles.appendSafe(circle(Point(points[i].x + 88, points[i].y), 77, 0));
                    // circles.appendSafe(circle(Point(points[i].x + 66, points[i].y), 77, 2));

                    // circles.appendSafe(circle(cp2, i, 2));
                    // circles.appendSafe(circle(cp1, i, 1));
                    // circles.appendSafe(circle(points[i], i, 0));

                    prevCurveType = 3;

                    continue;
                }
                // // If we're moving up, we need to arc turn to change direction
                // if (points[i-2].y > points[i - 1].y && points[i-1].y > points[i].y) {
                //     (cp1, cp2) = arcTurn(points, cp2, i, distance, true);
                //         track.appendSafe(
                //         cubicBezierCurve(
                //             cp1,
                //             cp2,
                //             points[i]
                //         )
                //     );
                //     circles.appendSafe(circle(cp2, i, 2));
                //     circles.appendSafe(circle(cp1, i, 1));
                //     circles.appendSafe(circle(points[i], i, 0));

                //     prevCurveType = 3;

                //     continue;
                // }

                // if (abs(int256(points[i-1].x) - int256(points[i].x)) < 80) {
                //     (cp1, cp2) = hairpinTurn(points, cp2, i, distance);
                //         track.appendSafe(
                //         cubicBezierCurve(
                //             cp1,
                //             cp2,
                //             points[i]
                //         )
                //     );
                //     circles.appendSafe(circle(cp2, i, 2));
                //     circles.appendSafe(circle(cp1, i, 1));
                //     circles.appendSafe(circle(points[i], i, 0));

                //     prevCurveType = 3;

                //     continue;
                // }
                // if (points[i-1].y >  points[i].y  && abs(int256(points[i-1].x) - int256(points[i].x)) > 160) {
                //     Point memory midpoint = collinearPoint(points[i], points[i-1], points[i], int256(distance) /-2 );

                //     (cp1, cp2, cp3, cp4) = chicane(points[i-1], midpoint, points[i], cp2, distance);

                //     track.appendSafe(
                //         cubicBezierCurve(cp1, cp2, midpoint)
                //     );

                //     track.appendSafe(
                //         cubicBezierCurve(cp3, cp4, points[i])
                //     );

                //     circles.appendSafe(circle(cp2, i, 2));
                //     circles.appendSafe(circle(cp1, i, 1));
                //     circles.appendSafe(circle(midpoint, i, 0));

                //     circles.appendSafe(circle(cp4, i*11, 2));
                //     circles.appendSafe(circle(cp3, i*11, 1));
                //     circles.appendSafe(circle(points[i], i*11, 0));
                //     prevCurveType = 3;

                //     cp1 = cp3;
                //     cp2 = cp4;
                //     continue;
                // }
            }

            if (prevCurveType == 0) {
                (cp1, cp2) =
                    straightCap(points[i - 2], points[i - 1], points[i]);
                track.appendSafe(cubicBezierCurve(cp1, cp2, points[i]));

                // circles.appendSafe(circle(points[i], i, 0));
                // circles.appendSafe(circle(cp1, i, 1));
                // circles.appendSafe(circle(cp2, i, 2));
                prevCurveType = 1;
                continue;
            }

            // if (prevCurveType == 1) {
            //     track.appendSafe(line(points[i]));
            //     circles.appendSafe(circle(points[i], i, 0));
            //     prevCurveType = 0;
            //     continue;
            // }

            if (prevCurveType == 2) {
                track.appendSafe(line(points[i]));
                // circles.appendSafe(circle(points[i], i, 0));
                prevCurveType = 0;
                continue;
            }

            if (prevCurveType == 3) {
                cp2 = connector(points[i - 1], points[i], currentSeed);
                track.appendSafe(reflectingCubicBezierCurve(cp2, points[i]));
                // circles.appendSafe(circle(cp2, i, 2));
                // circles.appendSafe(circle(points[i], i, 0));
                prevCurveType = 1;

                currentSeed = nextRandom(currentSeed);
                continue;
            }

            // Short distance between points, so we customize our control points rather
            // than automatically reflecting them
            if (curveType == 0) {
                (cp1, cp2) =
                    calculateContinuity(points[i - 1], cp1, cp2, points[i]);
                track.appendSafe(cubicBezierCurve(cp1, cp2, points[i]));

                // circles.appendSafe(circle(cp2, i, 2));
                // circles.appendSafe(circle(cp1, i, 1));
                // circles.appendSafe(circle(points[i], i, 0));

                prevCurveType = 2;
                continue;
            }

            // If the previous segment was a reflecting curve we may need to customize the control points
            if (prevCurveType == 8) {
                if (abs(adjustment) > 120) {
                    Point memory midpoint = collinearPoint(
                        points[i],
                        points[i - 1],
                        points[i],
                        int256(distance) / -2
                    );

                    (cp1, cp2, cp3, cp4) = chicane(
                        points[i - 1], midpoint, points[i], cp2, distance
                    );

                    track.appendSafe(cubicBezierCurve(cp1, cp2, midpoint));

                    track.appendSafe(cubicBezierCurve(cp3, cp4, points[i]));
                    // circles.appendSafe(circle(cp2, i, 2));
                    // circles.appendSafe(circle(cp1, i, 1));
                    // circles.appendSafe(circle(midpoint, i, 0));

                    // circles.appendSafe(circle(cp4, i*11, 2));
                    // circles.appendSafe(circle(cp3, i*11, 1));
                    // circles.appendSafe(circle(points[i], i*11, 0));
                    prevCurveType = 1;

                    cp1 = cp3;
                    cp2 = cp4;
                    continue;
                }

                cp2 = connector(points[i - 1], points[i], currentSeed);
                track.appendSafe(reflectingCubicBezierCurve(cp2, points[i]));
                // circles.appendSafe(circle(cp2, i, 2));
                // circles.appendSafe(circle(points[i], i, 0));
                prevCurveType = 8;

                currentSeed = nextRandom(currentSeed);
                continue;
            }

            adjustment = int256(currentSeed) % int256(distance / 2)
                - int256(distance / 2) / (adjustment > 0 ? int8(-1) : int8(1));

            cp2 = sweepingTurn(
                points[i - 1], points[i], points[i + 1], cp2, adjustment
            );

            track.appendSafe(reflectingCubicBezierCurve(cp2, points[i]));
            // circles.appendSafe(circle(cp2, i, 2));
            // circles.appendSafe(circle(points[i], i, 0));
            prevCurveType = 8;

            currentSeed = nextRandom(currentSeed);
        }

        // Append the closing curve to the path
        // if (segs == points.length) {
        closeCurve(cp2, points[i], points[0], points[1], track, ""); //circles
            // }
    }

    /// @notice Calculate control points for continuity when exiting a straightaway
    /// TODO: better name, ASCII art
    function straightCap(Point memory p0, Point memory p1, Point memory p3)
        internal
        pure
        returns (Point memory cp1, Point memory cp2)
    {
        // Ensure continuity from a previous straight segment
        (cp1, cp2) = calculateLineContinuity(p0, p1, p3);
    }

    function arcTurn(
        Point[] memory points,
        Point memory _cp2,
        uint256 i,
        uint256 distance,
        bool vertical
    ) internal pure returns (Point memory cp1, Point memory cp2) {
        cp1 = collinearPoint(
            points[i - 2], _cp2, points[i - 1], int256(distance / 2)
        );

        cp2 = collinearPoint(
            points[i - 1],
            vertical ? points[i + 1] : points[i],
            vertical ? points[i] : points[i + 1],
            int256(points[i].y) - cp1.y
        );
    }

    function chicane(
        Point memory startPoint,
        Point memory midPoint,
        Point memory endPoint,
        Point memory _cp2,
        uint256 distance
    )
        internal
        pure
        returns (
            Point memory cp1,
            Point memory cp2,
            Point memory cp3,
            Point memory cp4
        )
    {
        cp1 = collinearPoint(startPoint, _cp2, startPoint, int256(distance / 5));

        cp2 = collinearPoint(startPoint, startPoint, cp1, int256(distance) / 5);

        cp3 = collinearPoint(
            startPoint,
            cp2,
            midPoint,
            int256(distanceBetweenPoints(cp2, midPoint))
        );
        cp4 = collinearPoint(startPoint, cp3, endPoint, int256(distance) / -5);
    }

    function hairpinTurn(
        Point[] memory points,
        Point memory _cp2,
        uint256 i,
        uint256 distance
    ) internal pure returns (Point memory cp1, Point memory cp2) {
        cp1 = collinearPoint(
            points[i - 2], _cp2, points[i - 1], int256(distance / 2)
        );

        cp2 = collinearPoint(
            points[i - 1], points[i - 2], points[i - 1], int256(distance)
        );
    }

    function connector(
        Point memory startPoint,
        Point memory endPoint,
        uint256 seed
    ) internal pure returns (Point memory cp2) {
        cp2 = connectorSecondControlPoint(startPoint, endPoint, seed);
    }

    function sweepingTurn(
        Point memory startPoint,
        Point memory endPoint,
        Point memory nextPoint,
        Point memory _cp2,
        int256 adjustment
    ) internal pure returns (Point memory cp2) {
        cp2 = calculateSecondPoint(
            startPoint, endPoint, nextPoint, _cp2, adjustment
        );
    }

    function mirrorTurn(
        Point memory startPoint,
        Point memory endPoint,
        Point memory nextPoint,
        Point memory _cp2,
        uint256 currentSeed
    ) internal pure returns (Point memory cp2) {
        int256 adjustment =
            int256(currentSeed % distanceBetweenPoints(startPoint, endPoint));
        cp2 = calculateSecondPoint(
            startPoint, endPoint, nextPoint, _cp2, adjustment
        );
    }

    /// @notice Close the track with a curve that provides continuity into the starting block
    /// TODO: ASCII art
    function closeCurve(
        Point memory cp2,
        Point memory lastPoint,
        Point memory firstPoint,
        Point memory secondPoint,
        bytes memory _track,
        bytes memory _circles
    ) internal pure returns (bytes memory track, bytes memory circles) {
        track = _track;
        circles = _circles;
        Point memory cp1 = collinearPoint(
            firstPoint,
            cp2,
            lastPoint,
            int256(distanceBetweenPoints(lastPoint, firstPoint)) / 3
        );
        Point memory _cp2 = collinearClosePoint(firstPoint, secondPoint);
        track.appendSafe(
            abi.encodePacked(
                " C ",
                intString(cp1.x),
                ",",
                intString(cp1.y),
                " ",
                intString(_cp2.x),
                ",",
                intString(_cp2.y),
                " ",
                intString(firstPoint.x),
                ",",
                intString(firstPoint.y)
            )
        );
        // circles.appendSafe(circle(_cp2, 100, 2));
        // circles.appendSafe(circle(cp1, 100, 1));
    }

    int256 private constant M = 2;

    /// @dev Calculate the control points for a Bezier curve with G1 and G2 continuity
    /// @param p0 The first point of the previous segment
    /// @param p1 The first control point of the previous segment
    /// @param p3 The end point of the previous segment
    function calculateLineContinuity(
        Point memory p0,
        Point memory p1,
        Point memory p3
    ) internal pure returns (Point memory cp1, Point memory cp2) {
        // Ensure G1 continuity by making cp1 collinear with p0 and p1
        int256 ratio = 6; // Using ratio of 1.5 (3/2)
        cp1.x = int256(p1.x) + (int256(p1.x) - int256(p0.x)) * 2 / ratio;
        cp1.y = int256(p1.y) + (int256(p1.y) - int256(p0.y)) * 2 / ratio;

        cp2.x = (int256(cp1.x) + int256(p3.x)) / 2;

        // cp2.x = int256(p3.x);

        // // Calculate the difference between cp1.y and p3.y
        // int256 minY = int256(p3.y) < cp1.y ? cp1.y - int256(p3.y) : int256(p3.y);
        // // Set the largest acceptable value to p3.y
        // int256 maxY = int256(p3.y) / 2;

        // Calculate cp2.y using the previous approach with the custom ratio
        cp2.y = int256(cp1.y) + (int256(p1.y) - int256(p0.y)) / ratio;

        // Ensure cp2.y falls within the acceptable range
        // if (cp2.y < minY) {
        //     cp2.y = minY;
        // } else if (cp2.y > maxY) {
        //     cp2.y = maxY;
        // }
        // Adjust control point cp2 for better G2 continuity and rounding
        cp2.x = int256(cp1.x) + (int256(cp2.x) - int256(cp1.x)) * 2 / ratio;
        cp2.y = int256(cp1.y) + (int256(cp2.y) - int256(cp1.y)) * 2 / ratio;
    }

    uint256 private constant constantMultiplier = 1e6;

    /// @dev Calculate the control points for a Bezier curve with G1 and G2 continuity
    /// @param p0 The end point of the previous curve
    /// @param p1 The first control point of the previous curve
    /// @param p2 The second control point of the previous curve
    /// @param p3 The end point of the current curve
    function calculateContinuity(
        Point memory p0, // points[i - 1],
        Point memory p1, // cp1
        Point memory p2, // cp2
        Point memory p3 // point
    ) internal pure returns (Point memory cp1, Point memory cp2) {
        // 2. Tangent continuity (G1): The tangent at the end of previos segment (from p2 to p3)
        // must be the same as the tangent at the beginning of this segment (from p3 to cp1).
        // This means that P2, P3, and cp1 must be collinear (lie along a straight line).

        // In our output, blue(n-1), green, and red(n) points must be collinear.

        // The direction and ratio of the distances between these points are important.
        // For example, if P3 is the midpoint between P2 and Q1, the tangents at P3/Q0 will be continuous.

        uint256 xDist = abs(int256(p3.x) - int256(p0.x));
        uint256 yDist = abs(int256(p3.y) - int256(p0.y));

        uint256 length =
            sqrt(uint256((xDist) * (xDist)) + uint256((yDist) * (yDist)));

        uint256 maxDistance = length - (length / 3);
        int256 ratio = 5; // Using ratio of 1.5 (3/2)
        cp1.x = int256(p3.x) + (int256(p3.x) - int256(p2.x)) * 2 / ratio;
        cp1.y = int256(p3.y) + (int256(p3.y) - int256(p2.y)) * 2 / ratio;
        cp1 = clampPoint(p0, cp1, maxDistance);

        int256 cp2x = int256(2) * int256(cp1.x) - int256(p3.x)
            + M * (int256(p2.x) - int256(2) * int256(p1.x) + int256(p0.x));

        cp2.x = cp2x < 0 ? int64(CANVAS_OFFSET) : cp2x;

        cp2.y = int256(2) * int256(cp1.y) - int256(p3.y)
            + M * (int256(p2.y) - int256(2) * int256(p1.y) + int256(p0.y));

        cp2 = clampPoint(p0, cp2, maxDistance);
    }

    // AI shit

    /// @notice Find a point that is collinear with 2 provided points placed at a custom or calculated distance
    /// @param distancePoint Point to calculate distance relative to p1
    /// @param p0 The first point we need to find collinearity with
    /// @param p1 The second point we need to find collinearity with
    /// @param requiredDistance Override distance calculation with required distance
    /// @dev We often need to place a control point on a line extending from 2 other points.
    /// i.e. for G1 continuity, CP1 must be collinear with the previous CP2 and the start point of the current segment.
    /// Passing a requiredDistance of 0 will calculate a distance based on the distance between `distancePoint` and `p1`.
    /// Alternatively, pass a `requiredDistance` to place the point at `requiredDistance` from `p1`.
    function collinearPoint(
        Point memory distancePoint,
        Point memory p0,
        Point memory p1,
        int256 requiredDistance
    ) private pure returns (Point memory newPoint) {
        // 1. Calculate the direction vector
        Point memory directionVector =
            Point(int256(int256(p1.x) - p0.x), int256(int256(p1.y) - p0.y));

        // 2. Normalize the direction vector
        int256 magnitude = int256(
            sqrt(
                uint256(
                    directionVector.x * directionVector.x
                        + directionVector.y * directionVector.y
                )
            )
        );
        int256 scalingFactor = 1e18; // Use a scaling factor to handle fixed-point arithmetic
        Point memory normalizedVector = Point(
            (directionVector.x * scalingFactor) / magnitude,
            (directionVector.y * scalingFactor) / magnitude
        );

        // 3. Scale the normalized vector
        int256 desiredDistance = requiredDistance == 0
            ? calculateDesiredDistance(distanceBetweenPoints(distancePoint, p1))
            : requiredDistance; // Adjust this value based on the desired curvature or segment type
        Point memory scaledVector = Point(
            (normalizedVector.x * desiredDistance) / scalingFactor,
            (normalizedVector.y * desiredDistance) / scalingFactor
        );

        // if (scaledVector.x == 0 && scaledVector.y == 0) {
        //     revert("scaledVector is 0");
        // }

        // 4. Calculate the new control point
        newPoint =
            Point(int256(p1.x) + scaledVector.x, int256(p1.y) + scaledVector.y);
    }

    /// @notice Find a point that is collinear with 2 provided points placed at a custom or calculated distance
    /// @param p0 The first point we need to find collinearity with
    /// @param p1 The second point we need to find collinearity with
    /// @dev We often need to place a control point on a line extending from 2 other points.
    /// i.e. for G1 continuity, CP1 must be collinear with the previous CP2 and the start point of the current segment.
    /// Passing a requiredDistance of 0 will calculate a distance based on the distance between `distancePoint` and `p1`.
    /// Alternatively, pass a `requiredDistance` to place the point at `requiredDistance` from `p1`.
    function collinearClosePoint(Point memory p0, Point memory p1)
        private
        pure
        returns (Point memory newPoint)
    {
        // 1. Calculate the direction vector
        Point memory directionVector =
            Point(int256(int256(p1.x) - p0.x), int256(int256(p1.y) - p0.y));

        // 2. Normalize the direction vector
        int256 magnitude = int256(
            sqrt(
                uint256(
                    directionVector.x * directionVector.x
                        + directionVector.y * directionVector.y
                )
            )
        );
        int256 scalingFactor = 1e18; // Use a scaling factor to handle fixed-point arithmetic
        Point memory normalizedVector = Point(
            (directionVector.x * scalingFactor) / magnitude,
            (directionVector.y * scalingFactor) / magnitude
        );

        // 3. Scale the normalized vector
        int256 desiredDistance = int256(distanceBetweenPoints(p0, p1));

        Point memory scaledVector = Point(
            (normalizedVector.x * desiredDistance) / scalingFactor,
            (normalizedVector.y * desiredDistance) / scalingFactor
        );

        // if (scaledVector.x == 0 && scaledVector.y == 0) {
        //     revert("scaledVector is 0");
        // }

        // 4. Calculate the new control point
        newPoint = Point(
            max(-80, int256(p0.x) - scaledVector.x),
            int256(p0.y) - scaledVector.y
        );
    }

    /// @notice Calculates the desired distance between the start point and
    /// the control point of the current segment as a function of the previous segment distance
    /// @param segmentDistance The distance of the previous segment
    /// @dev GPT4 offers the following explanation:
    /// - When the `ratio` is set to 0, the `effectiveScalingFactor` will be equal to the `minScalingFactor` (1/4 of the segment distance). In this case, the desired distance will be 1/4 of the current segment distance for all segments, regardless of their size.
    /// - When the `ratio` is set to 1 (represented as 1e18 in fixed-point arithmetic), the `effectiveScalingFactor` will be equal to the `maxScalingFactor` (2 times the segment distance). In this case, the desired distance will be 2 times the current segment distance for all segments, regardless of their size.
    /// - When the `ratio` is set to a value between 0 and 1, the `effectiveScalingFactor` will be a linear interpolation between the `minScalingFactor` and `maxScalingFactor`. This means that the desired distance will be a value between 1/4 and 2 times the current segment distance, depending on the `ratio` value.
    /// By adjusting the `ratio` value, you can control the desired distance within the specified range (1/4 to 2 times the segment distance) based on the current segment distance. A lower `ratio` value will result in a smaller desired distance for shorter segments relative to larger segments, while a higher `ratio` value will result in a larger desired distance for shorter segments relative to larger segments.
    function calculateDesiredDistance(uint256 segmentDistance)
        private
        pure
        returns (int256 desiredDistance)
    {
        // Define scaling factors to adjust the desired distance based on the current segment distance
        uint256 minScalingFactor = 1e18 / 4; // 1/4 of the segment distance
        uint256 maxScalingFactor = 2 * 1e18; // 2 times the segment distance

        // Define a ratio to control the relationship between the current segment distance and the desired distance
        uint256 ratio = 1e16; // Adjust this value based on your specific requirements (range: 0 to 1, represented as fixed-point number)

        // Calculate the effective scaling factor based on the ratio
        uint256 effectiveScalingFactor = minScalingFactor
            + (maxScalingFactor - minScalingFactor) * ratio / 1e18;

        // Calculate the desired distance based on the current segment distance and the effective scaling factor
        desiredDistance =
            int256((segmentDistance * effectiveScalingFactor) / 1e18);
    }

    function connectorSecondControlPoint(
        Point memory prevPoint,
        Point memory currentPoint,
        uint256 seed
    ) internal pure returns (Point memory cp) {
        int256 adjustment = int256(seed) % 88 - 44;
        cp.x = int256(prevPoint.x)
            + (int256(currentPoint.x) - int256(prevPoint.x)) / 2;
        cp.y = int256(prevPoint.y)
            + (int256(currentPoint.y) - int256(prevPoint.y)) / 2;

        if (
            abs(currentPoint.y - prevPoint.y)
                < abs(currentPoint.x - prevPoint.x)
        ) {
            cp.x += adjustment;
        } else {
            cp.y += adjustment;
        }
    }

    function calculateSecondPoint(
        Point memory prevPoint,
        Point memory currentPoint,
        Point memory nextPoint,
        Point memory prevControlPoint,
        int256 adjustment
    ) internal pure returns (Point memory cp) {
        // Set the control point's x and y values to the midpoint between prevPoint and currentPoint
        cp.x = int256(prevPoint.x)
            + (int256(currentPoint.x) - int256(prevPoint.x)) / 2;
        cp.y = int256(prevPoint.y)
            + (int256(currentPoint.y) - int256(prevPoint.y)) / 2;

        // Apply the adjustment to the control point's x and y values
        uint256 minDistance = 172;

        // Vertical bearing
        if (
            abs(currentPoint.y - prevPoint.y)
                > abs(currentPoint.x - prevPoint.x)
        ) {
            cp.x += adjustment;

            // when moving vertically, clamp the X value to avoid loop-backs
            cp.x = clamp(
                cp.x,
                min(prevPoint.x, currentPoint.x),
                max(prevPoint.x, currentPoint.x)
            );

            // If cps are too close, move them apart
            if (
                distanceBetweenPoints(prevPoint, cp) < minDistance
                    || distanceBetweenPoints(currentPoint, cp) < minDistance
                    || distanceBetweenPoints(nextPoint, cp) < minDistance
            ) {
                int256 sign =
                    cp.x >= int256(currentPoint.x) ? int256(-1) : int256(1);

                if (distanceBetweenPoints(nextPoint, cp) < minDistance) {
                    sign *= 2;
                }
                cp.x = int256(prevPoint.x) + sign * int256(minDistance);
            }

            // Determine if the control point's X value is within the range of the current and next points' X values
            bool isWithinRangeX = (
                int256(currentPoint.x) >= min(prevPoint.x, nextPoint.x)
            ) && int256(currentPoint.x) <= max(prevPoint.x, nextPoint.x);

            // Adjust the control point's X value to reverse the convexity of the curve if needed
            if (isWithinRangeX) {
                int256 sign =
                    currentPoint.x >= prevPoint.x ? int256(-1) : int256(1);
                cp.x = int256(prevPoint.x)
                    - sign * int256(abs(int256(prevPoint.x) - int256(cp.x)));
            }
        } else {
            cp.y += adjustment;
            // cp.x = currentPoint.x;

            // when moving horizontally, clamp the Y value to avoid loop-backs
            cp.y = clamp(
                cp.y,
                min(prevPoint.y, currentPoint.y),
                max(prevPoint.y, currentPoint.y)
            );
            // If cps are too close, move them apart
            if (
                distanceBetweenPoints(prevPoint, cp) < minDistance
                    || distanceBetweenPoints(prevControlPoint, cp) < minDistance
            ) {
                int256 sign =
                    cp.y >= int256(prevPoint.y) ? int256(1) : int256(-1);
                cp.y = int256(prevPoint.y) + sign * int256(minDistance);
            }

            // Determine if the control point's X value is within the range of the current and next points' X values
            bool isWithinRangeY = (
                int256(currentPoint.y) >= min(prevPoint.y, nextPoint.y)
            ) && int256(currentPoint.y) <= max(prevPoint.y, nextPoint.y);

            // Adjust the control point's X value to reverse the convexity of the curve if needed
            if (isWithinRangeY) {
                int256 sign =
                    currentPoint.y >= prevPoint.y ? int256(1) : int256(-1);
                cp.y = int256(prevPoint.y)
                    - sign * int256(abs(int256(prevPoint.y) - int256(cp.y)));
            }
        }

        // if (cp.x < int64(CANVAS_OFFSET)) {
        //     cp.x = int64(CANVAS_OFFSET);
        // }

        // if (cp.x > int64(CANVAS_WIDTH)) {
        //     cp.x = int64(CANVAS_WIDTH);
        // }

        // if (cp.y < int64(CANVAS_OFFSET)) {
        //     cp.y = int64(CANVAS_OFFSET);
        // }

        // if (cp.y > int64(CANVAS_HEIGHT)) {
        //     cp.y = int64(CANVAS_HEIGHT);
        // }
    }

    function clampPoint(Point memory p0, Point memory cp, uint256 maxDistance)
        internal
        pure
        returns (Point memory _cp)
    {
        uint256 distance = sqrt(
            uint256(
                (int256(cp.x) - int256(p0.x)) * (int256(cp.x) - int256(p0.x))
            )
                + uint256(
                    (int256(cp.y) - int256(p0.y)) * (int256(cp.y) - int256(p0.y))
                )
        );

        if (distance > maxDistance) {
            int256 scaleFactor =
                int256(maxDistance * constantMultiplier / distance);
            int256 cp1x = int256(p0.x)
                + (scaleFactor * (int256(cp.x) - int256(p0.x)))
                    / int256(constantMultiplier);

            _cp.x = cp1x > 0 ? cp1x : int64(CANVAS_OFFSET);

            _cp.y = int256(p0.y)
                + (scaleFactor * (int256(cp.y) - int256(p0.y)))
                    / int256(constantMultiplier);
        }
    }

    // ************************** //
    // *** TRACK WAYPOINT GEN *** //
    // ************************** //

    function generateRacetrack(uint256 seed)
        private
        pure
        returns (Point[] memory)
    {
        uint256 currentSeed = pseudoRandom(seed);
        uint8 numCols = 4;

        // uint8 minRows = numCols + 1;
        uint8 numRows = 6;
        // minRows + uint8(nextRandom(currentSeed) % (6 - minRows + 1));

        uint8 numPoints = (numRows * 2) + (numCols * 2) - 8;
        Point[] memory racetrack = new Point[](numPoints);
        uint8 i = 0;

        // Top row
        for (uint8 col = 0; col < numCols - 1;) {
            uint256 x = (newWidth * col) / (numCols - 1)
                + (nextRandom(currentSeed) % (newWidth / (numCols - 1)))
                + CANVAS_OFFSET / 2;
            uint256 y = (nextRandom(currentSeed) % (newHeight / (numRows - 1)))
                + CANVAS_OFFSET;

            if (col == 0) {
                x += 44;
                y += 44;
            }

            if (col == 0) {
                racetrack[i] = Point(int256(x), int256(y));
                i++;
                col++;
            } else {
                Point memory p = Point(int256(x), int256(y));
                bool consec = distanceBetweenPoints(racetrack[i - 1], p)
                    > minPointDistance;
                if (consec) {
                    racetrack[i] = p;
                    i++;
                    col++;
                }
            }
            currentSeed = nextRandom(currentSeed);
        }

        // Right column
        for (uint8 row = 1; row < numRows - 2;) {
            uint256 min = row == 3
                ? CANVAS_WIDTH / 2
                : CANVAS_OFFSET / 2 + CANVAS_WIDTH / 2;
            uint256 x = (min) + (nextRandom(currentSeed) % (newWidth / 2));

            uint256 y = (newHeight * row) / (numRows - 1)
                + (nextRandom(currentSeed) % (newHeight / (numRows - 1)));

            Point memory a = racetrack[i - 2];
            Point memory b = racetrack[i - 1];
            Point memory c = Point(int256(x), int256(y));

            if (pointsDistanceValid(a, b, c)) {
                racetrack[i] = c;
                unchecked {
                    row++;
                    i++;
                }
            }
            currentSeed = nextRandom(currentSeed);
        }

        // Bottom row
        for (uint8 col = numCols - 2; col > 0;) {
            uint256 x = (newWidth * col) / (numCols - 1)
                + (nextRandom(currentSeed) % (newWidth / (numCols - 2)))
                + CANVAS_OFFSET;
            uint256 y = (newHeight * (numRows - 2)) / (numRows - 1)
                + (nextRandom(currentSeed) % (newHeight / (numRows - 1)))
                + CANVAS_OFFSET;

            Point memory a = racetrack[i - 2];
            Point memory b = racetrack[i - 1];
            Point memory c = Point(int256(x), int256(y));

            if (pointsDistanceValid(a, b, c)) {
                racetrack[i] = c;
                i++;
                col--;
            }
            currentSeed = nextRandom(currentSeed);
        }

        // Left column
        for (uint8 row = numRows - 2; row > 1; row--) {
            uint256 x =
                (nextRandom(currentSeed) % (newWidth / 2)) + CANVAS_OFFSET / 2;

            uint256 y = (newHeight * row) / (numRows - 1)
                + (nextRandom(currentSeed) % (newHeight / (numRows - 1)));

            Point memory a = racetrack[i - 2];
            Point memory b = racetrack[i - 1];
            Point memory c = Point(int256(x), int256(y));

            if (row == 2) {
                bool consec =
                    distanceBetweenPoints(racetrack[0], c) > minPointDistance;
                if (!consec || c.x > racetrack[0].x + int64(minCurveDistance)) {
                    continue;
                }
            }

            if (pointsDistanceValid(a, b, c)) {
                racetrack[i] = c;
                i++;
            } else {
                racetrack[i - 1] = c;
            }
            currentSeed = nextRandom(currentSeed);
        }

        return racetrack;
    }

    function pointsDistanceValid(Point memory a, Point memory b, Point memory c)
        private
        pure
        returns (bool valid)
    {
        bool skip = distanceBetweenPoints(a, c) > minPointDistance;
        bool consec = distanceBetweenPoints(b, c) > minPointDistance;
        valid = skip && consec;
    }

    // ************************* //
    // *** SVG PATH COMMANDS *** //
    // ************************* //
    function moveTo(Point memory point) internal pure returns (bytes memory) {
        return
            abi.encodePacked("M ", intString(point.x), ",", intString(point.y));
    }

    function line(Point memory point) internal pure returns (bytes memory) {
        return
            abi.encodePacked(" L ", intString(point.x), ",", intString(point.y));
    }

    function cubicBezierCurve(
        Point memory cp1,
        Point memory cp2,
        Point memory point
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(
            " C ",
            intString(cp1.x),
            ",",
            intString(cp1.y),
            " ",
            intString(cp2.x),
            ",",
            intString(cp2.y),
            " ",
            intString(point.x),
            ",",
            intString(point.y)
        );
    }

    // The start control point is the reflection of the end control point of the previous curve command about the current point.
    function reflectingCubicBezierCurve(Point memory cp2, Point memory point)
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(
            " S ",
            intString(cp2.x),
            ",",
            intString(cp2.y),
            " ",
            intString(point.x),
            ",",
            intString(point.y)
        );
    }

    // ************************* //
    // *** SVG DEBUG HANDLES *** //
    // ************************* //

    // function circle(Point memory cp, uint256 i, uint256 redBlue)
    //     internal
    //     pure
    //     returns (bytes memory)
    // {
    //     return abi.encodePacked(
    //         "<circle cx='",
    //         intString(cp.x),
    //         "' cy='",
    //         intString(cp.y),
    //         redBlue == 0
    //             ? "' r='6' fill='red' />"
    //             : redBlue == 1
    //                 ? "' r='8' fill='blue' />"
    //                 : "' r='10' fill='green' />",
    //         "<text font-size='32' x='",
    //         intString(cp.x),
    //         "' y='",
    //         intString(cp.y + 10),
    //         "' fill='white'>",
    //         i.toString(),
    //         "</text>"
    //     );
    // }
}
