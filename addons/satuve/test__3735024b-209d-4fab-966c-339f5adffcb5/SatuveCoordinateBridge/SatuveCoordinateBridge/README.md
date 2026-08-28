# Satuve Coordinate Bridge

Standalone, read-only ESO addon that displays the player's current map position and measured movement as a machine-readable binary grid. It performs no navigation, automation, input, file access, network access or external-process communication.

## Protocol V2

The display is a fixed 20-column by 8-row grid (160 bits). Bits are written row-major, left to right and top to bottom. Every integer is unsigned and encoded most-significant bit first.

| Bits | Field | Type | Meaning |
|---:|---|---|---|
| 0-15 | SYNC | uint16 | `0xA55A` |
| 16-23 | VERSION | uint8 | `2` |
| 24-31 | STATUS | uint8 | validity flags |
| 32-47 | SEQUENCE | uint16 | increments for every published frame |
| 48-71 | MAP_ID | uint24 | current ESO map ID |
| 72-91 | PLAYER_X | uint20 | normalized X multiplied by 1,000,000 |
| 92-111 | PLAYER_Y | uint20 | normalized Y multiplied by 1,000,000 |
| 112-127 | MOVE_DIRECTION | uint16 | `0..65535` maps to `0..360 degrees` |
| 128-143 | MOVE_SPEED | uint16 | speed in `0.01 m/s` |
| 144-159 | CRC16 | uint16 | CRC-16/CCITT-FALSE |

Constants:

- X/Y scale: `1,000,000`
- Direction scale: `0..65535 -> 0..360 degrees`
- Direction convention: north/up `0°`, east/right `90°`, south/down `180°`, west/left `270°`
- Speed scale: `100 -> 1.00 m/s`
- Bit order: MSB first
- Grid: `20 x 8`
- Protocol: version `2`
- CRC: CRC-16/CCITT-FALSE, polynomial `0x1021`, initial value `0xFFFF`, no reflection, xor-out `0x0000`
- CRC input: the exact 128 payload bits from VERSION through MOVE_SPEED, packed MSB-first into 16 bytes; SYNC and CRC are excluded

STATUS byte:

- bit 0: player/map coordinates valid
- bit 1: actual movement direction valid
- bit 2: movement speed valid
- bits 3-7: reserved and always zero

Stationary frames normally use STATUS `0b00000101`: coordinates and speed are valid, direction is invalid, and speed is approximately `0.00 m/s`.

## Position and motion

Current map data is read without changing ESO's map state:

- `GetCurrentMapId()`
- `GetMapPlayerPosition("player")`

Actual movement direction is calculated from map-position displacement with `atan2(dx, -dy)`. It does not use camera heading, reticle direction or character facing.

Speed is calculated from horizontal displacement returned by `GetUnitWorldPosition("player")`. This build uses the scale already observed by the surrounding project and ESO community addons: 100 world-coordinate units per meter. If usable world coordinates are unavailable, MOVE_SPEED is zero and the speed-valid STATUS bit is cleared. Position is never smoothed; only direction and speed use a short 100 ms sample window and lightweight smoothing.

Movement history is reset on player activation/deactivation, zone or map changes, world-zone changes, long sampling gaps and implausible jumps. A transition therefore cannot become a false high-speed frame.

## Display and updates

- Default grid cell: `3 x 3` pixels
- Default grid position: `5 / 5` pixels from the upper-left corner
- Zero bit: opaque black
- One bit: opaque white
- Default update interval: `50 ms` (`20 Hz`)
- Available intervals: `25`, `50`, or `100 ms`
- The 160 cells are created once; only changed cells are recolored
- The bridge stays active during combat
- Debug text is disabled by default and is never part of the protocol

## Settings

`/scb` or `/scb menu` opens the standalone settings window. The following chat commands are also available and are useful with console text chat:

- `/scb on`
- `/scb off`
- `/scb x <pixels>`
- `/scb y <pixels>`
- `/scb size <3-12>`
- `/scb rate <25|50|100>`
- `/scb debug <on|off>`
- `/scb test`

Saved variables use `SatuveCoordinateBridgeSavedVariables` and contain only `enabled`, `offsetX`, `offsetY`, `cellSize`, `updateMs`, and `showDebugText`.

## Encoder self-test

`/scb test` encodes this deterministic vector and verifies all field boundaries, the complete 160-bit length and the CRC field:

```text
VERSION = 2
STATUS = 7
SEQUENCE = 123
MAP_ID = 456
X = 523481
Y = 381927
MOVE_DIRECTION = 13500
MOVE_SPEED = 642
```

Expected packed payload bytes: `0207007B0001C87FCD95D3E734BC0282`  
Expected CRC: `F416`

## API limitations

- Normalized map coordinates depend on ESO's current read-only map context. The addon deliberately never calls `SetMapToPlayerLocation()` or another map-changing function.
- ESO does not directly expose a single authoritative meters-per-second value to addons. Speed is derived from world-coordinate displacement and is marked invalid when that measurement is unavailable.
- The built-in settings window is mouse-operable. Console users can configure every setting through `/scb` chat commands without any library dependency.
