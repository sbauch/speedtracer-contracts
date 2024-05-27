// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {IDelegateRegistry} from "./IDelegateRegistry.sol";
import {IERC721A} from "erc721a/contracts/IERC721A.sol";
import {IThemeRenderer} from "./themes/Season2/IThemeRenderer.sol";

import {Base64} from "solady/src/utils/Base64.sol";
import {Context} from "openzeppelin/contracts/utils/Context.sol";
import {DynamicBuffer} from "./DynamicBuffer.sol";
import {Strings} from "openzeppelin/contracts/utils/Strings.sol";
import {TrackUtils} from "./TrackUtils.sol";

/// @author sammybauch.eth
/// @title  Speedtracer tracetrack renderer
/// @notice Render an SVG racetrack for a given seed
contract TrackRenderer is TrackUtils, Context {
    using DynamicBuffer for bytes;
    using Strings for uint256;
    using Strings for uint24;

    uint64 private immutable maxSupply = 28;
    uint256 public immutable greenFlag = 1704895200;

    uint64 private constant CANVAS_WIDTH = 1200;
    uint64 private constant CANVAS_HEIGHT = 1950;
    uint64 private constant CANVAS_OFFSET = 260;

    address[] private themes;

    uint64 private constant minPointDistance = 215;
    uint64 private constant minCurveDistance = 268;
    uint64 private constant newWidth = CANVAS_WIDTH - 2 * CANVAS_OFFSET;
    uint64 private constant newHeight = CANVAS_HEIGHT - 2 * CANVAS_OFFSET;

    IERC721A public nftContract;

    address public constant DELEGATE_REGISTRY =
        0x00000000000000447e69651d841bD8D104Bed493;

    mapping(uint256 => uint256) public curatedTracks;
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
        themes = _themes;
        nftContract = IERC721A(_nftContract);
    }

    // ************** //
    // *** ERC721 *** //
    // ************** //

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            theme(tokenId).name(tokenId),
                            '", "description":"Speedtracer is a longform generative project that creates skeuomorphic racetrack artworks, or tracetracks.", "image": "data:image/svg+xml;base64,',
                            Base64.encode(render(tokenId), false, false),
                            '", "animation_url": "ipfs://QmPmaNHgFKvL5V3pBBVTTPTudPvToYoRjgB3ZSCuQE7ypQ?id=',
                            tokenId.toString(),
                            attributes(tokenId),
                            "}]}"
                        )
                    )
                )
            )
        );
    }

    function attributes(uint256 tokenId) internal view returns (bytes memory) {
        return abi.encodePacked(
            '", "attributes": [{"trait_type": "theme", "value": "',
            theme(tokenId).themeName(),
            '"}, {"trait_type": "season", "value": 2}, { "display_type": "date", "trait_type": "race date", "value": ',
            (greenFlag + (1 days * tokenId) - 1 days).toString(),
            '}, {"trait_type": "authorship", "value": ',
            customTracks[tokenId].length == 0
                ? (curatedTracks[tokenId] == 0 ? '"Algorithmic"' : '"Curated"')
                : '"Human Augmented"'
        );
    }

    function curateTrack(uint256 id, uint256 trackId) external {
        assertOwnerOrDelegate(id);

        curatedTracks[id] = trackId;
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

    function setTheme(uint256 id, address themeRenderer) external {
        assertOwnerOrDelegate(id);

        customTheme[id] = themeRenderer;
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
        if (seed > 900) return IThemeRenderer(themes[4]);
        if (seed > 750) return IThemeRenderer(themes[3]);
        if (seed > 550) return IThemeRenderer(themes[2]);
        if (seed > 300) return IThemeRenderer(themes[1]);
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

        if (curatedTracks[id] > 0) {
            return renderGeneratedTrack(curatedTracks[id]);
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
        track = DynamicBuffer.allocate(2 ** 16);

        track.appendSafe(moveTo(points[0]));

        // Start the track with a straightaway starting block
        track.appendSafe(line(points[1]));

        Point memory cp1;
        Point memory cp2;
        Point memory cp3;
        Point memory cp4;
        uint8 prevCurveType;
        uint64 i = 2;

        for (; i < points.length; i += 1) {
            if (points[i].x == 0 && points[i].y == 0) {
                --i;
                break;
            }

            currentSeed = nextRandom(currentSeed);
            uint256 distance = distanceBetweenPoints(points[i - 1], points[i]);

            // Turn One
            if (i == 3 || (i == 4 && prevCurveType != BEZIER_CURVE)) {
                if (
                    points[i - 2].y > points[i - 1].y
                        && points[i - 1].y > points[i].y
                ) {
                    (cp1, cp2) = arcTurn(points, cp2, i, distance, true);
                    track.appendSafe(cubicBezierCurve(cp1, cp2, points[i]));

                    prevCurveType = BEZIER_CURVE;

                    continue;
                }

                if (abs(int256(points[i - 1].x) - int256(points[i].x)) < 80) {
                    (cp1, cp2) = hairpinTurn(points, cp2, i, distance);
                    track.appendSafe(cubicBezierCurve(cp1, cp2, points[i]));

                    prevCurveType = BEZIER_CURVE;

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

                    prevCurveType = BEZIER_CURVE;

                    cp1 = cp3;
                    cp2 = cp4;
                    continue;
                }
            }

            // Turn Two
            if (i == 6) {
                if (
                    distanceBetweenPoints(points[i], points[i + 1])
                        < minCurveDistance
                ) {
                    continue;
                }

                if (points[i + 1].y < points[i - 1].y) {
                    cp2 = connector(points[i - 1], points[i], currentSeed);
                    track.appendSafe(reflectingCubicBezierCurve(cp2, points[i]));
                    ++i;
                    cp2.x = points[i].x;
                    cp2.y =
                        points[i - 1].y + (points[i - 1].y - points[i - 2].y);
                    track.appendSafe(reflectingCubicBezierCurve(cp2, points[i]));

                    prevCurveType = BEZIER_CURVE;

                    continue;
                }
                if (points[i + 1].x > points[i - 1].x) {
                    Point memory midpoint = collinearPoint(
                        points[i],
                        points[i - 1],
                        points[i],
                        int256(distance) * -1 + int64(minCurveDistance)
                    );

                    track.appendSafe(
                        reflectingCubicBezierCurve(
                            Point(midpoint.x, midpoint.y), midpoint
                        )
                    );

                    track.appendSafe(
                        abi.encodePacked(
                            " A 1 1 0 0 1 ",
                            intString(
                                points[i].x + int256(distance / 9)
                                    - int64(CANVAS_OFFSET)
                            ),
                            " ",
                            intString(points[i + 1].y + 10)
                        )
                    );

                    prevCurveType = STRAIGHT;
                    ++i;
                    continue;
                }
            }

            // To ensure continuity out of a short straight segment, we need to use a straight cap
            // connector control point to lead into our next segment
            if (prevCurveType == STRAIGHT) {
                (cp1, cp2) =
                    straightCap(points[i - 2], points[i - 1], points[i]);
                track.appendSafe(cubicBezierCurve(cp1, cp2, points[i]));
                prevCurveType = BEZIER_CURVE;
                continue;
            }

            uint8 curveType =
                determineSegmentType(currentSeed, prevCurveType, distance);

            if (i == 7 && curveType == REFLECTING_CURVE) {
                cp2 = connector(points[i - 1], points[i], currentSeed);
                Point memory midpoint = collinearPoint(
                    points[i], points[i - 1], points[i], int256(distance) / -2
                );
                cp2.y =
                    midpoint.y + int256(abs(midpoint.y - points[i - 1].y) * 4);
                track.appendSafe(reflectingCubicBezierCurve(cp2, points[i]));
                continue;
            }

            if (curveType == STRAIGHT) {
                track.appendSafe(line(points[i]));
            }

            if (curveType == REFLECTING_CURVE) {
                cp2 = connector(points[i - 1], points[i], currentSeed);
                track.appendSafe(reflectingCubicBezierCurve(cp2, points[i]));
            }

            if (curveType == BEZIER_CURVE) {
                Point memory midpoint = collinearPoint(
                    points[i], points[i - 1], points[i], int256(distance) / -2
                );

                (cp1, cp2, cp3, cp4) =
                    chicane(points[i - 1], midpoint, points[i], cp2, distance);

                track.appendSafe(cubicBezierCurve(cp1, cp2, midpoint));

                track.appendSafe(cubicBezierCurve(cp3, cp4, points[i]));

                cp1 = cp3;
                cp2 = cp4;
            }

            currentSeed = nextRandom(currentSeed);
            prevCurveType = curveType;
        }

        // Append the closing curve to the path
        closeCurve(cp2, points[i], points[0], points[1], track);
    }

    uint8 constant STRAIGHT = 0;
    uint8 constant REFLECTING_CURVE = 1;
    uint8 constant BEZIER_CURVE = 2;

    function determineSegmentType(
        uint256 currentSeed,
        uint8 prevCurveType,
        uint256 distance
    ) internal pure returns (uint8 segmentType) {
        uint256 curveThreshold = minCurveDistance; // Minimum distance required for a curve
        uint256 complexCurveThreshold = curveThreshold * 10 / 8; // Minimum distance for a complex curve

        // Implement randomness
        uint256 rand = currentSeed % 100;

        // Decision logic
        if (distance < curveThreshold) {
            // TODO: could be connector segment?
            return STRAIGHT;
        } else if (
            distance >= curveThreshold && distance < complexCurveThreshold
        ) {
            // If we have enough distance for a simple curve but not a complex one
            // Adjust curve type based on randomness and previous curve type
            if (prevCurveType == REFLECTING_CURVE && rand < 30) {
                return STRAIGHT;
            } else {
                // Otherwise, return a simple curve
                return REFLECTING_CURVE;
            }
        } else {
            // If we have enough distance for a complex curve
            if (prevCurveType == BEZIER_CURVE && rand < 30) {
                // 30% chance to switch to straight if previous was a complex curve
                return STRAIGHT;
            } else if (prevCurveType != STRAIGHT && rand < 10) {
                // 30% chance to switch to simple curve if previous was not straight
                return BEZIER_CURVE;
            } else {
                // Otherwise, return a complex curve
                return REFLECTING_CURVE;
            }
        }
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

    /// @notice Close the track with a curve that provides G2 continuity into the starting block
    /// TODO: ASCII art
    function closeCurve(
        Point memory cp2,
        Point memory lastPoint,
        Point memory firstPoint,
        Point memory secondPoint,
        bytes memory _track
    ) internal pure returns (bytes memory track) {
        track = _track;
        Point memory _cp1;
        Point memory _cp2;

        if (
            abs(lastPoint.y - firstPoint.y) < 100
                || abs(lastPoint.y - secondPoint.y) < 100
        ) {
            _cp1 = collinearPoint(firstPoint, _cp2, secondPoint, 50);
            _cp2 = collinearClosePoint(firstPoint, secondPoint);

            track.appendSafe(
                abi.encodePacked(
                    " C ",
                    intString(_cp1.x),
                    ",",
                    intString(_cp1.y),
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
            return track;
        }

        if (distanceBetweenPoints(lastPoint, firstPoint) < 100) {
            (_cp1, _cp2) = straightCap(secondPoint, firstPoint, lastPoint);
            track.appendSafe(cubicBezierCurve(_cp1, _cp2, firstPoint));
            return track;
        }

        _cp1 = collinearPoint(
            firstPoint,
            cp2,
            lastPoint,
            int256(distanceBetweenPoints(lastPoint, firstPoint)) / 3
        );

        _cp2 = collinearClosePoint(firstPoint, secondPoint);
        track.appendSafe(
            abi.encodePacked(
                " C ",
                intString(_cp1.x),
                ",",
                intString(_cp1.y),
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
        int256 ratio = 6;
        cp1.x = int256(p1.x) + (int256(p1.x) - int256(p0.x)) * 2 / ratio;
        cp1.y = int256(p1.y) + (int256(p1.y) - int256(p0.y)) * 2 / ratio;

        cp2.x = (int256(cp1.x) + int256(p3.x)) / 2;

        // Calculate the difference between cp1.y and p3.y
        int256 minY = int256(p3.y) < cp1.y ? cp1.y - int256(p3.y) : int256(p3.y);
        // Set the largest acceptable value to p3.y
        int256 maxY = int256(p3.y) / 2;

        // Calculate cp2.y using the previous approach with the custom ratio
        cp2.y = int256(cp1.y) + (int256(p1.y) - int256(p0.y)) / ratio;

        // Ensure cp2.y falls within the acceptable range
        if (cp2.y < minY) {
            cp2.y = minY;
        } else if (cp2.y > maxY) {
            cp2.y = maxY;
        }

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
        Point memory p0,
        Point memory p1,
        Point memory p2,
        Point memory p3
    ) internal pure returns (Point memory cp1, Point memory cp2) {
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
        Point memory directionVector =
            Point(int256(int256(p1.x) - p0.x), int256(int256(p1.y) - p0.y));

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

        int256 desiredDistance = requiredDistance == 0
            ? calculateDesiredDistance(distanceBetweenPoints(distancePoint, p1))
            : requiredDistance;
        Point memory scaledVector = Point(
            (normalizedVector.x * desiredDistance) / scalingFactor,
            (normalizedVector.y * desiredDistance) / scalingFactor
        );

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
            max(-40, int256(p0.x) - scaledVector.x),
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

            cp.x = clamp(
                cp.x,
                min(prevPoint.x, currentPoint.x),
                max(prevPoint.x, currentPoint.x)
            );

            if (
                distanceBetweenPoints(prevPoint, cp) < minDistance
                    || distanceBetweenPoints(currentPoint, cp) < minDistance
                    || distanceBetweenPoints(nextPoint, cp) < minDistance
                    || distanceBetweenPoints(prevControlPoint, cp) < minDistance
            ) {
                int256 sign =
                    cp.x >= int256(currentPoint.x) ? int256(-1) : int256(1);

                if (distanceBetweenPoints(prevControlPoint, cp) < minDistance) {
                    sign *= 2;
                }
                cp.x = int256(cp.x) + sign * int256(minDistance);
            }

            bool isWithinRangeX = (
                int256(currentPoint.x) >= min(prevPoint.x, nextPoint.x)
            ) && int256(currentPoint.x) <= max(prevPoint.x, nextPoint.x);

            if (isWithinRangeX) {
                int256 sign =
                    currentPoint.x >= prevPoint.x ? int256(-1) : int256(1);
                cp.x = int256(prevPoint.x)
                    - sign * int256(abs(int256(prevPoint.x) - int256(cp.x)));
            }
        } else {
            cp.y += adjustment;

            cp.y = clamp(
                cp.y,
                min(prevPoint.y, currentPoint.y),
                max(prevPoint.y, currentPoint.y)
            );

            if (
                distanceBetweenPoints(prevPoint, cp) < minDistance
                    || distanceBetweenPoints(prevControlPoint, cp) < minDistance
            ) {
                int256 sign =
                    cp.y >= int256(prevPoint.y) ? int256(1) : int256(-1);
                cp.y = int256(prevPoint.y) + sign * int256(minDistance);
            }

            bool isWithinRangeY = (
                int256(currentPoint.y) >= min(prevPoint.y, nextPoint.y)
            ) && int256(currentPoint.y) <= max(prevPoint.y, nextPoint.y);

            if (isWithinRangeY) {
                int256 sign =
                    currentPoint.y >= prevPoint.y ? int256(1) : int256(-1);
                cp.y = int256(prevPoint.y)
                    - sign * int256(abs(int256(prevPoint.y) - int256(cp.y)));
            }
        }

        if (cp.x < int64(CANVAS_OFFSET)) {
            cp.x = int64(CANVAS_OFFSET);
        }

        if (cp.x > int64(CANVAS_WIDTH)) {
            cp.x = int64(CANVAS_WIDTH);
        }

        if (cp.y < int64(CANVAS_OFFSET)) {
            cp.y = int64(CANVAS_OFFSET);
        }

        if (cp.y > int64(CANVAS_HEIGHT)) {
            cp.y = int64(CANVAS_HEIGHT);
        }
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
}
