Holodeck fight packs (library)
==============================

Drop .lua packs here and add them to DeadMarker_Holodeck.txt / .addon load list.

Each pack should call:
  Holodeck.RegisterFight({ id=..., name=..., durationSec=..., phases=..., entities=... })

Coords: meters relative to /hd plant origin.

Examples:
  house_demo.lua — shipped demo

Authoring:
  Record lean (bosses + reticle elites) or manual stopadd/snap/hold,
  /hd export, paste into a new fights/<id>.lua, RegisterFight, reload.

  PC: bake from a public esologs.com report
  (scripts live in ../HolodeckDocs/tools — not this upload folder):
    cd ..\HolodeckDocs
    python tools\bake_esologs_pack.py REPORTCODE --id MoL-TwinsJump --fight 8 --install
    python tools\bake_esologs_pack.py REPORTCODE --id MoL-TwinsJump-Wipe --fight 4 --players --install
    (see HolodeckDocs\tools\ESOLOGS_PROBE.md)

  Load key is fight.id inside the lua (e.g. /hd load MoL-TwinsJump), not the esologs hash.
  Renaming: edit id/name/trial/boss/variant in the lua + the filename + both manifests. No recapture.

Team training:
  Everyone installs same Holodeck version + same fight packs,
  plant on the same landmark, /hd load <id>, /hd play once, walk the room.
