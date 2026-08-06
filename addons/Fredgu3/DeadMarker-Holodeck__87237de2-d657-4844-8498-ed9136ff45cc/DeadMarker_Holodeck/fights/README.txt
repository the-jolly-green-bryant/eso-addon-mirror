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

Team training:
  Everyone installs same Holodeck version + same fight packs,
  plant on the same landmark, /hd load <id>, /hd play once, walk the room.
