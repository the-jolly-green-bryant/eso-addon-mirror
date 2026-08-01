# M0RMarkers Opulent Ordeal Analysis

Decoded from:

`C:\Users\Donlup\Documents\Elder Scrolls Online\live\SavedVariables\M0RMarkers.lua`

Output file:

`data/M0RMarkersDecoded_1565.csv`

Generated route profile file:

`data/M0RRouteProfiles.lua`

## Decode Notes

M0RMarkers stores profile strings in a compressed format:

```text
<zoneId]timestamp]baseX:baseY:baseZ]...marker offsets...>
```

The marker coordinates in the tail are hex offsets from the base coordinate. The decoded CSV contains absolute coordinates:

```text
x = baseX + offX
y = baseY + offY
z = baseZ + offZ
```

## Found Profiles From Updated Export

The June 7 export has clearer route names and decodes to 20 Opulent profiles with 247 marker points.

| MoreMarkers profile | Marker count | Generated key |
| --- | ---: | --- |
| `Hand in Orange orb from Purple` | 9 | `hand_in_orange_orb_from_purple` |
| `Hand in Orange orb from red side` | 9 | `hand_in_orange_orb_from_red_side` |
| `Hand in Purple orb from Orange side` | 6 | `hand_in_purple_orb_from_orange_side` |
| `Hand in purple orb from red side` | 6 | `hand_in_purple_orb_from_red_side` |
| `Hand in red orb from orange side` | 10 | `hand_in_red_orb_from_orange_side` |
| `Hand In red orb from purple side` | 8 | `hand_in_red_orb_from_purple_side` |
| `Lamps in purple` | 6 | `lamps_in_purple` |
| `Orange orb from purple trough red hand to orange` | 18 | `orange_orb_from_purple_through_red_hand_to_orange` |
| `Orange orb from red trough purple hand to orange` | 18 | `orange_orb_from_red_through_purple_hand_to_orange` |
| `Pickup orange in purple hand to red` | 14 | `pickup_orange_in_purple_hand_to_red` |
| `Pickup orange in red hand to purple` | 10 | `pickup_orange_in_red_hand_to_purple` |
| `Pickup purple in orange hand to red` | 16 | `pickup_purple_in_orange_hand_to_red` |
| `Pickup purple in red hand to orange` | 13 | `pickup_purple_in_red_hand_to_orange` |
| `Pickup red in orange hand to purple` | 14 | `pickup_red_in_orange_hand_to_purple` |
| `Pickup Red in Purple hand to Orange` | 14 | `pickup_red_in_purple_hand_to_orange` |
| `Preset: Opulent Ordeal General` | 10 | `preset_opulent_ordeal_general` |
| `Purple orb from Orange through Red hand to Purple` | 16 | `purple_orb_from_orange_through_red_hand_to_purple` |
| `Purple orb from red trough orange hand to pruple` | 17 | `purple_orb_from_red_through_orange_hand_to_purple` |
| `Red orb from orange trough purple hand to red` | 17 | `red_orb_from_orange_through_purple_hand_to_red` |
| `Red orb from purple trough orange hand to red` | 16 | `red_orb_from_purple_through_orange_hand_to_red` |

The generated keys normalize typos in profile names: `trough` becomes `through`, and `pruple` becomes `purple`.

Test any imported profile in-game with:

```text
/oon profile <generatedKey>
```

For example:

```text
/oon profile pickup_red_in_purple_hand_to_orange
```

## Older Export Notes

| MoreMarkers profile | Marker count | Likely addon use |
| --- | ---: | --- |
| `Preset: Opulent Ordeal General` | 10 | General static area labels: Sand, Shadow, Grapple |
| `Pick red to purple` | 10 | Red pickup/east route toward Purple |
| `Pickup red to orange` | 13 | Red pickup/west route toward Orange |
| `Red to orange though purple` | 17 | Full route for Red essence/orb to Orange via Purple |
| `Red to purple trough orange` | 17 | Full route for Red team/orb toward Purple via Orange |
| `Orange to red` | 16 | Direct Orange to Red leg |
| `Orange to purple` | 14 | Direct Orange to Purple leg |
| `Orange to purple through red` | 18 | Full Orange to Purple via Red |
| `Orange to red trough purple` | 18 | Full Orange to Red via Purple |
| `Purple to red` | 14 | Direct Purple to Red leg |
| `Purple to orange` | 14 | Direct Purple to Orange leg |
| `Purple to read through orange` | 16 | Full Purple to Red via Orange |
| `Purple to Orange though red` | 16 | Full Purple to Orange via Red |
| `Lamps in purple` | 6 | Purple lamp/soak/final helper markers, needs in-game naming |

## Profile Structure

The file contains two useful kinds of marker sets:

- Route chains: ordered breadcrumb paths such as `Orange to red`, `Purple to orange`, and the longer `through` routes.
- Static labels: `Preset: Opulent Ordeal General`, which already names several direction/grapple helper positions.

Most route markers have no label text. Their meaning comes from profile name and marker order.

## Strong Anchor Points

These exact coordinates are reused by more than one profile and are likely shared hubs or red-side transition points:

| Coordinate | Used by |
| --- | --- |
| `53896,35234,41529` | `Pick red to purple#7`, `Pickup red to orange#3`, `Orange to purple through red#10`, `Purple to Orange though red#10` |
| `46202,35168,41728` | `Pickup red to orange#10`, `Orange to purple through red#14`, `Purple to Orange though red#5` |
| `57449,34897,41806` | `Pick red to purple#8`, `Purple to Orange though red#13` |

Those are good first candidates for named marker IDs because they bridge several routes.

## Red/Cobwebs Notes

The red side is different from the normal breadcrumb routes because it uses grapple movement.

The two short red pickup profiles appear to represent the two possible red pickup directions:

- `Pick red to purple`: 10 points, from `50060,35004,45008` toward `57775,35083,46797`.
- `Pickup red to orange`: 13 points, from `50131,35004,44956` toward `40196,35025,46452`.

The first two points in both red pickup profiles are almost identical:

- `50060,35004,45008`
- `50095,34750,41106`

This looks like a shared red pickup/start section before the route branches. Because red uses grapples, these should probably be imported as paired action markers:

```text
stand_here_to_grapple -> grapple_target
```

instead of animated one-by-one breadcrumbs.

## General Preset Labels

The `Preset: Opulent Ordeal General` profile is especially useful because it has real labels:

| Index | Coordinate | Label meaning |
| ---: | --- | --- |
| 1 | `58660,36854,46570` | Shadow / Grapple direction label |
| 2 | `41305,36854,46666` | Sand / Grapple direction label |
| 3 | `49853,36854,57349` | Shadow / Sand shared direction label |
| 4 | `49919,36634,34951` | Grapple label |
| 5 | `45731,35520,52100` | Sand label |
| 6 | `53522,35354,52460` | Shadow label |
| 7 | `38573,37825,38011` | Grapple / Shadow / Sand direction label |
| 8 | `61545,37825,38533` | Grapple / Sand / Shadow direction label |
| 9 | `39437,37825,59027` | Sand label |
| 10 | `59247,37825,59212` | Shadow label |

These are not enough for animated paths by themselves, but they are useful landmarks for validating route names in-game.

## Suggested Mapping Work

The decoded profiles are useful, but should not be blindly imported into `Routes.lua` yet. We still need to identify which points are:

- pickup markers
- joined-area markers
- grapple starts
- grapple targets
- drop/final markers
- return-to-middle markers
- soak left/right markers

For Red/Cobwebs, prefer classifying points as action pairs:

```text
grapple_start -> grapple_target
```

For Orange/Purple, the decoded points can become normal waypoint chains.

## Next Import Step

Use `data/M0RMarkersDecoded_1565.csv` and rename selected rows into our addon marker IDs in `data/MarkerOverrides.lua`.

The first practical target is to map:

- `red_pickup_west`
- `red_pickup_east`
- `red_west_grapple_start`
- `red_west_grapple_target`
- `red_east_grapple_start`
- `red_east_grapple_target`
- `red_join`
- `orange_join`
- `purple_join`
- `center_middle`

## Import Recommendation

Do the import in this order:

1. Import the non-red direct route chains first: `Orange to red`, `Orange to purple`, `Purple to red`, `Purple to orange`.
2. Import the longer non-red routes: `Orange to purple through red`, `Orange to red trough purple`, `Purple to read through orange`, `Purple to Orange though red`.
3. Manually classify red grapple pairs from `Pick red to purple` and `Pickup red to orange`.
4. Use `Preset: Opulent Ordeal General` only as landmarks until each point is confirmed in-game.
5. Keep `Lamps in purple` separate until we know whether those points are final holders, soak points, or lamp helpers.
