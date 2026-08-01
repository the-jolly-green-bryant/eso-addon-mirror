CitizenResistanceMeter = {
    name = "CitizenResistanceMeter",
    lockUi = true
}

--Refresh resistances
---CitizenAddon.name .."ResistanceMeter", 500
local function Refresh()
    local physicResist = GetPlayerStat(STAT_DAMAGE_RESIST_PHYSICAL)
    CitizenRM_PhysicalResist:SetText(physicResist)

    local spellResist = GetPlayerStat(STAT_DAMAGE_RESIST_MAGIC)
    CitizenRM_SpellResist:SetText(spellResist)
end

function CitizenResistanceMeter.Start()
    local CitizenRM = CreateControl("CitizenRM", GuiRoot, CT_TOPLEVELCONTROL)
    CitizenRM:SetDimensions(200, 60)
    CitizenRM:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CitizenAddon.combatOptions.resistanceMeter.left, CitizenAddon.combatOptions.resistanceMeter.top)
    CitizenRM:SetMouseEnabled(true)
    CitizenRM:SetMovable(false)
    CitizenRM:SetHidden(true)
    CitizenRM:SetHandler("OnMoveStop", function ()
        CitizenAddon.combatOptions.resistanceMeter.left = CitizenRM:GetLeft()
        CitizenAddon.combatOptions.resistanceMeter.top = CitizenRM:GetTop()
    end)
    -- Border Backdrop
    local border = CreateControl("CitizenRM_Border", CitizenRM, CT_BACKDROP)
    border:SetDimensions(190, 52)
    border:SetAnchor(CENTER, CitizenRM, CENTER)
    border:SetCenterColor(0, 0, 0, 0.7)
    border:SetEdgeColor(1, 1, 1, 0.7)
    border:SetEdgeTexture("", 1, 1, 3)
    -- Physical Resist Label
    local physicalResist = CreateControl("CitizenRM_PhysicalResist", CitizenRM, CT_LABEL)
    physicalResist:SetAnchor(LEFT, border, LEFT, 5, 0)
    physicalResist:SetFont("$(GAMEPAD_BOLD_FONT)|33|thin-outline")
    physicalResist:SetColor(1, 1, 1, 1)
    physicalResist:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    physicalResist:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    -- PR Text Label
    local physicalResistLabel = CreateControl("CitizenRM_PhysicalResistLabel", CitizenRM, CT_LABEL)
    physicalResistLabel:SetAnchor(TOPLEFT, physicalResist, TOPRIGHT, 0, 0)
    physicalResistLabel:SetFont("$(BOLD_FONT)|14|thin-outline")
    physicalResistLabel:SetColor(0.6, 0.6, 0.6, 1)
    physicalResistLabel:SetText("PR")
    physicalResistLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    physicalResistLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    -- Spell Resist Label
    local spellResist = CreateControl("CitizenRM_SpellResist", CitizenRM, CT_LABEL)
    spellResist:SetAnchor(LEFT, border, CENTER, 0, 0)
    spellResist:SetFont("$(GAMEPAD_BOLD_FONT)|33|thin-outline")
    spellResist:SetColor(1, 1, 1, 1)
    spellResist:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    spellResist:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    -- SR Text Label
    local spellResistLabel = CreateControl("CitizenRM_SpellResistLabel", CitizenRM, CT_LABEL)
    spellResistLabel:SetAnchor(TOPLEFT, spellResist, TOPRIGHT, 0, 0)
    spellResistLabel:SetFont("$(BOLD_FONT)|14|thin-outline")
    spellResistLabel:SetColor(0.6, 0.6, 0.6, 1)
    spellResistLabel:SetText("SR")
    spellResistLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    spellResistLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    EVENT_MANAGER:RegisterForUpdate(CitizenResistanceMeter.name .."Refresh", 500, Refresh)
end