local AST = AsylumTracker

-- Per-control data. Backdrop and Label names are derived by appending "Backdrop"/"Label" to name.
local controls = {
     {
          name        = "AsylumTrackerOlmsHP",
          svKey       = nil, -- always enabled
          offsetX     = "olms_hp_offsetX",
          offsetY     = "olms_hp_offsetY",
          fontSizeKey = "font_size_olms_hp",
          scaleKey    = "olms_hp_scale",
          previewText = function()
               local h1 = AST.RGBToHex(unpack(AST.sv.color_olms_hp))
               local h2 = AST.RGBToHex(unpack(AST.sv.color_olms_hp2))
               return "|c" .. h1 .. GetString(AST_PREVIEW_OLMS_HP_1) .. "|r|c" .. h2 .. GetString(AST_PREVIEW_OLMS_HP_2) .. "|r"
          end,
     },
     {
          name        = "AsylumTrackerStorm",
          svKey       = "storm_the_heavens",
          offsetX     = "storm_offsetX",
          offsetY     = "storm_offsetY",
          fontSizeKey = "font_size_storm",
          scaleKey    = "storm_scale",
          previewText = function()
               local h1 = AST.RGBToHex(unpack(AST.sv.color_storm))
               local h2 = AST.RGBToHex(unpack(AST.sv.color_storm2))
               return "|c" .. h1 .. GetString(AST_PREVIEW_STORM_1) .. "|r|c" .. h2 .. GetString(AST_PREVIEW_STORM_2) .. "|r"
          end,
     },
     {
          name        = "AsylumTrackerBlast",
          svKey       = "defiling_blast",
          offsetX     = "blast_offsetX",
          offsetY     = "blast_offsetY",
          fontSizeKey = "font_size_blast",
          scaleKey    = "blast_scale",
          previewText = function() return GetString(AST_PREVIEW_BLAST) end,
     },
     {
          name        = "AsylumTrackerSphere",
          svKey       = "static_shield",
          offsetX     = "sphere_offsetX",
          offsetY     = "sphere_offsetY",
          fontSizeKey = "font_size_sphere",
          scaleKey    = "sphere_scale",
          previewText = function()
               local h1 = AST.RGBToHex(unpack(AST.sv.color_sphere))
               local h2 = AST.RGBToHex(unpack(AST.sv.color_sphere2))
               return "|c" .. h1 .. GetString(AST_PREVIEW_SPHERE_1) .. "|r|c" .. h2 .. GetString(AST_PREVIEW_SPHERE_2) .. "|r"
          end,
     },
     {
          name        = "AsylumTrackerTeleportStrike",
          svKey       = "teleport_strike",
          offsetX     = "teleport_strike_offsetX",
          offsetY     = "teleport_strike_offsetY",
          fontSizeKey = "font_size_teleport_strike",
          scaleKey    = "teleport_strike_scale",
          previewText = function() return GetString(AST_PREVIEW_JUMP) end,
     },
     {
          name        = "AsylumTrackerOppressiveBolts",
          svKey       = "oppressive_bolts",
          offsetX     = "oppressive_bolts_offsetX",
          offsetY     = "oppressive_bolts_offsetY",
          fontSizeKey = "font_size_oppressive_bolts",
          scaleKey    = "oppressive_bolts_scale",
          previewText = function() return GetString(AST_PREVIEW_BOLTS) end,
     },
     {
          name        = "AsylumTrackerFire",
          svKey       = "trial_by_fire",
          offsetX     = "fire_offsetX",
          offsetY     = "fire_offsetY",
          fontSizeKey = "font_size_fire",
          scaleKey    = "fire_scale",
          previewText = function() return GetString(AST_PREVIEW_FIRE) end,
     },
     {
          name        = "AsylumTrackerSteam",
          svKey       = "scalding_roar",
          offsetX     = "steam_offsetX",
          offsetY     = "steam_offsetY",
          fontSizeKey = "font_size_scalding_roar",
          scaleKey    = "scalding_roar_scale",
          previewText = function() return GetString(AST_PREVIEW_STEAM) end,
     },
     {
          name        = "AsylumTrackerMaim",
          svKey       = "maim",
          offsetX     = "maim_offsetX",
          offsetY     = "maim_offsetY",
          fontSizeKey = "font_size_maim",
          scaleKey    = "maim_scale",
          previewText = function() return GetString(AST_PREVIEW_MAIM) end,
     },
     {
          name        = "AsylumTrackerCharges",
          svKey       = "exhaustive_charges",
          offsetX     = "exhaustive_charges_offsetX",
          offsetY     = "exhaustive_charges_offsetY",
          fontSizeKey = "font_size_exhaustive_charges",
          scaleKey    = "exhaustive_charges_scale",
          previewText = function() return GetString(AST_PREVIEW_CHARGES) end,
     },
}

function AST.ToggleMovable()
     AST.isMovable = not AST.isMovable
     if AST.isMovable then
          for _, c in ipairs(controls) do
               _G[c.name .. "Backdrop"]:SetHidden(false)
               if not c.svKey or AST.sv[c.svKey] then
                    _G[c.name]:SetMovable(true)
               end
          end
          AST.RefreshPreview()
     else
          for _, c in ipairs(controls) do
               _G[c.name .. "Backdrop"]:SetHidden(true)
               _G[c.name]:SetMovable(false)
               _G[c.name]:SetHidden(true)
          end
     end
end

-- Updates label text, dimensions, and visibility to reflect current sv values.
-- Only runs while in preview/movable mode; no-op otherwise.
function AST.RefreshPreview()
     if not AST.isMovable then return end

     for _, c in ipairs(controls) do
          local frame = _G[c.name]
          local label = _G[c.name .. "Label"]
          label:SetText(c.previewText())
          frame:SetDimensions(label:GetTextWidth(), label:GetTextHeight())
          frame:SetHidden(c.svKey and not AST.sv[c.svKey] or false)
     end
end

function AST.HideAllControls()
     for _, c in ipairs(controls) do
          _G[c.name]:SetHidden(true)
     end
end

function AST.InitializeControlSizes()
     for _, c in ipairs(controls) do
          local frame = _G[c.name]
          local label = _G[c.name .. "Label"]
          AST.SetFontSize(frame, label, AST.sv[c.fontSizeKey])
          label:SetScale(AST.sv[c.scaleKey])
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
     for _, c in ipairs(controls) do
          local frame = _G[c.name]
          frame:ClearAnchors()
          frame:SetAnchor(CENTER, GuiRoot, TOPLEFT, AST.sv[c.offsetX], AST.sv[c.offsetY])
     end
end

function AST.SavePosition(control, controlAsString)
     for _, c in ipairs(controls) do
          if c.name == controlAsString then
               local centerX, centerY = control:GetCenter()
               AST.sv[c.offsetX] = centerX
               AST.sv[c.offsetY] = centerY
               return
          end
     end
end

function AST.ResetToDefaults()
     for _, c in ipairs(controls) do
          AST.sv[c.offsetX] = AST.defaults[c.offsetX]
          AST.sv[c.offsetY] = AST.defaults[c.offsetY]
     end
     AST.ResetAnchors()
end