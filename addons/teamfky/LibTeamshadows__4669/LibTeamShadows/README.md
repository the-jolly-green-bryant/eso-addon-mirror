# LibTeamShadows

Lightweight group communication + world markers for the Team Shadows addons.

## Transport (since 1.1.0)

All group communication goes through **LibGroupBroadcast** (by sirinsidiator).
Protocol ids and names are reserved on the ESOUI wiki, as required:
https://wiki.esoui.com/LibGroupBroadcast_IDs
Handler `LibTeamShadows`, range 440-449: `440 = TeamShadowsPull`,
`441 = TeamShadowsMarker`, 442-449 kept for future protocols.

The legacy transports were removed in 1.1.0:

- **LibDataShare** map pings: the library relies on a deprecated game API, is no
  longer supported, and its map slots conflict with other addons.
- Chat-channel messages: blocked by ESO secure execution and obsolete.

## Marker rendering (since 1.1.0)

Rewritten from scratch on the game's **native 3D render space API**
(`Create3DRenderSpace`, `Set3DRenderSpaceOrigin`,
`WorldPositionToGuiRender3DPosition`) — the same pattern ZOS uses for the
housing editor gizmos and crown crates. The engine handles projection,
perspective and depth; Lua only refreshes marker origins and copies the camera
orientation for billboarding.

The world-marker concept was inspired by **OdySupportIcons (OSI)** by Odylon,
maintained by ExoY (https://www.esoui.com/downloads/info2834-OdySupportIcons-GroupRoleIconsMore.html).
No OSI-derived code or assets remain in this library — thanks to ExoY for
pointing out that the legacy screen-projection approach should not be used in
new addons anymore.

All marker textures are original (256×256 DXT5).

## Développement

Parts of this library were developed with AI assistance. All code is reviewed,
adapted and tested in-game by the author.
