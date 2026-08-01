local AST = AsylumTracker

-- Makes the Notifications movable on screen
function AST.ToggleMovable()
     AST.isMovable = not AST.isMovable
     if AST.isMovable then
          local hex_olms_hp = AST.RGBToHex(unpack(AST.sv["color_olms_hp"]))
          local hex_olms_hp2 = AST.RGBToHex(unpack(AST.sv["color_olms_hp2"]))
          AsylumTrackerOlmsHPLabel:SetText("|c" .. hex_olms_hp .. GetString(AST_PREVIEW_OLMS_HP_1) .. "|r|c" .. hex_olms_hp2 .. GetString(AST_PREVIEW_OLMS_HP_2) .. "|r")
          local hex_storm = AST.RGBToHex(unpack(AST.sv["color_storm"]))
          local hex_storm2 = AST.RGBToHex(unpack(AST.sv["color_storm2"]))
          AsylumTrackerStormLabel:SetText("|c" .. hex_storm .. GetString(AST_PREVIEW_STORM_1) .. "|r|c" .. hex_storm2 .. GetString(AST_PREVIEW_STORM_2) .. "|r")
          AsylumTrackerBlastLabel:SetText(GetString(AST_PREVIEW_BLAST))
          local hex_sphere = AST.RGBToHex(unpack(AST.sv["color_sphere"]))
          local hex_sphere2 = AST.RGBToHex(unpack(AST.sv["color_sphere2"]))
          AsylumTrackerSphereLabel:SetText("|c" .. hex_sphere .. GetString(AST_PREVIEW_SPHERE_1) .. "|r|c" .. hex_sphere2 .. GetString(AST_PREVIEW_SPHERE_2) .. "|r")
          AsylumTrackerTeleportStrikeLabel:SetText(GetString(AST_PREVIEW_JUMP))
          AsylumTrackerOppressiveBoltsLabel:SetText(GetString(AST_PREVIEW_BOLTS))
          AsylumTrackerFireLabel:SetText(GetString(AST_PREVIEW_FIRE))
          AsylumTrackerSteamLabel:SetText(GetString(AST_PREVIEW_STEAM))
          AsylumTrackerMaimLabel:SetText(GetString(AST_PREVIEW_MAIM))
          AsylumTrackerChargesLabel:SetText(GetString(AST_PREVIEW_CHARGES))

          -- Makes the backdrop behind the notifications visible while they are movable and adjusts the dimensions of the control to the size of the text.
          AsylumTrackerOlmsHPBackdrop:SetHidden(false) AsylumTrackerOlmsHP:SetDimensions(AsylumTrackerOlmsHPLabel:GetTextWidth(), AsylumTrackerOlmsHPLabel:GetTextHeight())
          AsylumTrackerStormBackdrop:SetHidden(false) AsylumTrackerStorm:SetDimensions(AsylumTrackerStormLabel:GetTextWidth(), AsylumTrackerStormLabel:GetTextHeight())
          AsylumTrackerBlastBackdrop:SetHidden(false) AsylumTrackerBlast:SetDimensions(AsylumTrackerBlastLabel:GetTextWidth(), AsylumTrackerBlastLabel:GetTextHeight())
          AsylumTrackerSphereBackdrop:SetHidden(false) AsylumTrackerSphere:SetDimensions(AsylumTrackerSphereLabel:GetTextWidth(), AsylumTrackerSphereLabel:GetTextHeight())
          AsylumTrackerTeleportStrikeBackdrop:SetHidden(false) AsylumTrackerTeleportStrike:SetDimensions(AsylumTrackerTeleportStrikeLabel:GetTextWidth(), AsylumTrackerTeleportStrikeLabel:GetTextHeight())
          AsylumTrackerOppressiveBoltsBackdrop:SetHidden(false) AsylumTrackerOppressiveBolts:SetDimensions(AsylumTrackerOppressiveBoltsLabel:GetTextWidth(), AsylumTrackerOppressiveBoltsLabel:GetTextHeight())
          AsylumTrackerFireBackdrop:SetHidden(false) AsylumTrackerFire:SetDimensions(AsylumTrackerFireLabel:GetTextWidth(), AsylumTrackerFireLabel:GetTextHeight())
          AsylumTrackerSteamBackdrop:SetHidden(false) AsylumTrackerSteam:SetDimensions(AsylumTrackerSteamLabel:GetTextWidth(), AsylumTrackerSteamLabel:GetTextHeight())
          AsylumTrackerMaimBackdrop:SetHidden(false) AsylumTrackerMaim:SetDimensions(AsylumTrackerMaimLabel:GetTextWidth(), AsylumTrackerMaimLabel:GetTextHeight())
          AsylumTrackerChargesBackdrop:SetHidden(false) AsylumTrackerCharges:SetDimensions(AsylumTrackerChargesLabel:GetTextWidth(), AsylumTrackerChargesLabel:GetTextHeight())

          AsylumTrackerOlmsHP:SetMovable(true) -- Olms' HP is always enabled, so there's no check for if it's enabled.
          if AST.sv["storm_the_heavens"] then AsylumTrackerStorm:SetMovable(true) end
          if AST.sv["defiling_blast"] then AsylumTrackerBlast:SetMovable(true) end
          if AST.sv["static_shield"] then AsylumTrackerSphere:SetMovable(true) end
          if AST.sv["teleport_strike"] then AsylumTrackerTeleportStrike:SetMovable(true) end
          if AST.sv["oppressive_bolts"] then AsylumTrackerOppressiveBolts:SetMovable(true) end
          if AST.sv["trial_by_fire"] then AsylumTrackerFire:SetMovable(true) end
          if AST.sv["scalding_roar"] then AsylumTrackerSteam:SetMovable(true) end
          if AST.sv["maim"] then AsylumTrackerMaim:SetMovable(true) end
          if AST.sv["exhaustive_charges"] then AsylumTrackerCharges:SetMovable(true) end

          AsylumTrackerOlmsHP:SetHidden(false)
          if AST.sv["storm_the_heavens"] then AsylumTrackerStorm:SetHidden(false) end
          if AST.sv["defiling_blast"] then AsylumTrackerBlast:SetHidden(false) end
          if AST.sv["static_shield"] then AsylumTrackerSphere:SetHidden(false) end
          if AST.sv["teleport_strike"] then AsylumTrackerTeleportStrike:SetHidden(false) end
          if AST.sv["oppressive_bolts"] then AsylumTrackerOppressiveBolts:SetHidden(false) end
          if AST.sv["trial_by_fire"] then AsylumTrackerFire:SetHidden(false) end
          if AST.sv["scalding_roar"] then AsylumTrackerSteam:SetHidden(false) end
          if AST.sv["maim"] then AsylumTrackerMaim:SetHidden(false) end
          if AST.sv["exhaustive_charges"] then AsylumTrackerCharges:SetHidden(false) end
     else
          -- Hides the backdrop behind the notifications
          AsylumTrackerOlmsHPBackdrop:SetHidden(true)
          AsylumTrackerStormBackdrop:SetHidden(true)
          AsylumTrackerBlastBackdrop:SetHidden(true)
          AsylumTrackerSphereBackdrop:SetHidden(true)
          AsylumTrackerTeleportStrikeBackdrop:SetHidden(true)
          AsylumTrackerOppressiveBoltsBackdrop:SetHidden(true)
          AsylumTrackerFireBackdrop:SetHidden(true)
          AsylumTrackerSteamBackdrop:SetHidden(true)
          AsylumTrackerMaimBackdrop:SetHidden(true)
          AsylumTrackerChargesBackdrop:SetHidden(true)

          AsylumTrackerOlmsHP:SetMovable(false)
          AsylumTrackerStorm:SetMovable(false)
          AsylumTrackerBlast:SetMovable(false)
          AsylumTrackerSphere:SetMovable(false)
          AsylumTrackerTeleportStrike:SetMovable(false)
          AsylumTrackerOppressiveBolts:SetMovable(false)
          AsylumTrackerFire:SetMovable(false)
          AsylumTrackerSteam:SetMovable(false)
          AsylumTrackerMaim:SetMovable(false)
          AsylumTrackerCharges:SetMovable(false)

          AsylumTrackerOlmsHP:SetHidden(true)
          AsylumTrackerStorm:SetHidden(true)
          AsylumTrackerBlast:SetHidden(true)
          AsylumTrackerSphere:SetHidden(true)
          AsylumTrackerTeleportStrike:SetHidden(true)
          AsylumTrackerOppressiveBolts:SetHidden(true)
          AsylumTrackerFire:SetHidden(true)
          AsylumTrackerSteam:SetHidden(true)
          AsylumTrackerMaim:SetHidden(true)
          AsylumTrackerCharges:SetHidden(true)
     end
end

function AST.SetFontSize(control, label, size)
     local path = "EsoUI/Common/Fonts/univers67.otf"
     local outline = "soft-shadow-thick"
     label:SetFont(path .. "|" .. size .. "|" .. outline)
     control:SetDimensions(label:GetTextWidth(), label:GetTextHeight())
end

function AST.SetScale(label, scale)
     label:SetScale(scale)
end

function AST.ResetAnchors()
     AsylumTrackerOlmsHP:ClearAnchors()
     AsylumTrackerStorm:ClearAnchors()
     AsylumTrackerBlast:ClearAnchors()
     AsylumTrackerSphere:ClearAnchors()
     AsylumTrackerTeleportStrike:ClearAnchors()
     AsylumTrackerOppressiveBolts:ClearAnchors()
     AsylumTrackerFire:ClearAnchors()
     AsylumTrackerSteam:ClearAnchors()
     AsylumTrackerMaim:ClearAnchors()
     AsylumTrackerCharges:ClearAnchors()

     AsylumTrackerOlmsHP:SetAnchor(CENTER, GuiRoot, TOPLEFT, AST.sv["olms_hp_offsetX"], AST.sv["olms_hp_offsetY"])
     AsylumTrackerStorm:SetAnchor(CENTER, GuiRoot, TOPLEFT, AST.sv["storm_offsetX"], AST.sv["storm_offsetY"])
     AsylumTrackerBlast:SetAnchor(CENTER, GuiRoot, TOPLEFT, AST.sv["blast_offsetX"], AST.sv["blast_offsetY"])
     AsylumTrackerSphere:SetAnchor(CENTER, GuiRoot, TOPLEFT, AST.sv["sphere_offsetX"], AST.sv["sphere_offsetY"])
     AsylumTrackerTeleportStrike:SetAnchor(CENTER, GuiRoot, TOPLEFT, AST.sv["teleport_strike_offsetX"], AST.sv["teleport_strike_offsetY"])
     AsylumTrackerOppressiveBolts:SetAnchor(CENTER, GuiRoot, TOPLEFT, AST.sv["oppressive_bolts_offsetX"], AST.sv["oppressive_bolts_offsetY"])
     AsylumTrackerFire:SetAnchor(CENTER, GuiRoot, TOPLEFT, AST.sv["fire_offsetX"], AST.sv["fire_offsetY"])
     AsylumTrackerSteam:SetAnchor(CENTER, GuiRoot, TOPLEFT, AST.sv["steam_offsetX"], AST.sv["steam_offsetY"])
     AsylumTrackerMaim:SetAnchor(CENTER, GuiRoot, TOPLEFT, AST.sv["maim_offsetX"], AST.sv["maim_offsetY"])
     AsylumTrackerCharges:SetAnchor(CENTER, GuiRoot, TOPLEFT, AST.sv["exhaustive_charges_offsetX"], AST.sv["exhaustive_charges_offsetY"])
end

function AST.SavePosition(control, controlAsString)
     local offsets = {
          ["AsylumTrackerOlmsHP"] = {"olms_hp_offsetX", "olms_hp_offsetY"},
          ["AsylumTrackerStorm"] = {"storm_offsetX", "storm_offsetY"},
          ["AsylumTrackerBlast"] = {"blast_offsetX", "blast_offsetY"},
          ["AsylumTrackerSphere"] = {"sphere_offsetX", "sphere_offsetY"},
          ["AsylumTrackerTeleportStrike"] = {"teleport_strike_offsetX", "teleport_strike_offsetY"},
          ["AsylumTrackerOppressiveBolts"] = {"oppressive_bolts_offsetX", "oppressive_bolts_offsetY"},
          ["AsylumTrackerFire"] = {"fire_offsetX", "fire_offsetY"},
          ["AsylumTrackerSteam"] = {"steam_offsetX", "steam_offsetY"},
          ["AsylumTrackerMaim"] = {"maim_offsetX", "maim_offsetY"},
          ["AsylumTrackerCharges"] = {"exhaustive_charges_offsetX", "exhaustive_charges_offsetY"},
     }

     local centerX, centerY = control:GetCenter()
     AST.sv[offsets[controlAsString][1]] = centerX
     AST.sv[offsets[controlAsString][2]] = centerY
end

function AST.ResetToDefaults()
     AST.sv["olms_hp_offsetX"] = AST.defaults["olms_hp_offsetX"]
     AST.sv["olms_hp_offsetY"] = AST.defaults["olms_hp_offsetY"]
     AST.sv["storm_offsetX"] = AST.defaults["storm_offsetX"]
     AST.sv["storm_offsetY"] = AST.defaults["storm_offsetY"]
     AST.sv["blast_offsetX"] = AST.defaults["blast_offsetX"]
     AST.sv["blast_offsetY"] = AST.defaults["blast_offsetY"]
     AST.sv["sphere_offsetX"] = AST.defaults["sphere_offsetX"]
     AST.sv["sphere_offsetY"] = AST.defaults["sphere_offsetY"]
     AST.sv["teleport_strike_offsetX"] = AST.defaults["teleport_strike_offsetX"]
     AST.sv["teleport_strike_offsetY"] = AST.defaults["teleport_strike_offsetY"]
     AST.sv["oppressive_bolts_offsetX"] = AST.defaults["oppressive_bolts_offsetX"]
     AST.sv["oppressive_bolts_offsetY"] = AST.defaults["oppressive_bolts_offsetY"]
     AST.sv["fire_offsetX"] = AST.defaults["fire_offsetX"]
     AST.sv["fire_offsetY"] = AST.defaults["fire_offsetY"]
     AST.sv["steam_offsetX"] = AST.defaults["steam_offsetX"]
     AST.sv["steam_offsetY"] = AST.defaults["steam_offsetY"]
     AST.sv["maim_offsetX"] = AST.defaults["maim_offsetX"]
     AST.sv["maim_offsetY"] = AST.defaults["maim_offsetY"]
     AST.sv["exhaustive_charges_offsetX"] = AST.defaults["exhaustive_charges_offsetX"]
     AST.sv["exhaustive_charges_offsetY"] = AST.defaults["exhaustive_charges_offsetY"]

     AST.ResetAnchors()
end
