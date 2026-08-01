ResistOMeter = {
    name = "ResistOMeter",
    version = "1.2.0",
    author = "@Complicative",
}

ResistOMeter.Settings = {}

ResistOMeter.Default = {
    mainWindowX = 10,
    mainWindowY = 10,
    mainWindowWidth = 480,
    mainWindowHeight = 140,
    hidden = false,
    fontSize = 24,
    nameType = "long",
    hideMax = false,
    hidePhysicalResistance = false,
    hideSpellResistance = false,
    hideBlockMitigation = false,
    customPhysicalResistance = "Physical Resistance",
    customSpellResistance = "Spell Resistance",
    customBlockMitigation = "Block Mitigation",
    backdrop = "ZO_DarkThinFrame"
}

local LAM2 = LibAddonMenu2
local mainFragment = ZO_SimpleSceneFragment:New(ResistOMeterMainWindow)

local function cStart(hex)
    return "|c" .. hex
end

local function cEnd()
    return "|r"
end

function ResistOMeter.GetStringNames()
    local physicalResistString = "\n"
    local spellResistString = "\n"
    local blockMitigationString = ""

    if ResistOMeter.Settings.nameType == "long" then
        physicalResistString = "Physical Resistance\n"
        spellResistString = "Spell Resistance\n"
        blockMitigationString = "Block Mitigation"
    elseif ResistOMeter.Settings.nameType == "short" then
        physicalResistString = "P-Resist." .. "\n"
        spellResistString = "S-Resist." .. "\n"
        blockMitigationString = "B-Miti."
    elseif ResistOMeter.Settings.nameType == "initials" then
        physicalResistString = "PR" .. "\n"
        spellResistString = "SB" .. "\n"
        blockMitigationString = "BM"
    elseif ResistOMeter.Settings.nameType == "icon" then
        physicalResistString = string.format("|t%d:%d:esoui/art/icons/alchemy/crafting_alchemy_trait_increasearmor.dds|t"
            ,
            ResistOMeter.Settings.fontSize, ResistOMeter.Settings.fontSize) .. "\n"
        spellResistString = string.format("|t%d:%d:/esoui/art/icons/alchemy/crafting_alchemy_trait_increasespellresist.dds|t"
            ,
            ResistOMeter.Settings.fontSize, ResistOMeter.Settings.fontSize) .. "\n"
        blockMitigationString = string.format("|t%d:%d:esoui/art/tutorial/gamepad/gp_lfg_tank.dds|t",
            ResistOMeter.Settings.fontSize, ResistOMeter.Settings.fontSize)
    elseif ResistOMeter.Settings.nameType == "custom" then
        physicalResistString = ResistOMeter.Settings.customPhysicalResistance .. "\n"
        spellResistString = ResistOMeter.Settings.customSpellResistance .. "\n"
        blockMitigationString = ResistOMeter.Settings.customBlockMitigation
    end

    if ResistOMeter.Settings.hidePhysicalResistance then physicalResistString = "" end
    if ResistOMeter.Settings.hideSpellResistance then spellResistString = "" end
    if ResistOMeter.Settings.hideBlockMitigation then blockMitigationString = "" end

    return physicalResistString .. spellResistString .. blockMitigationString
end

function ResistOMeter.GetStringValues(physicalResist, spellResist, blockMitigation)
    local physicalResistColor = "FFFFFF"
    local spellResistColor = "FFFFFF"
    local blockMitigationColor = "FFFFFF"

    if physicalResist >= 34000 then physicalResistColor = "FF0000" elseif physicalResist > 33000 then physicalResistColor = "FFFF00" end
    if spellResist >= 34000 then spellResistColor = "FF0000" elseif spellResist > 33000 then spellResistColor = "FFFF00" end
    if blockMitigation >= 95 then blockMitigationColor = "FF0000" elseif blockMitigation > 90 then blockMitigationColor = "FFFF00" end

    local physicalResistMax = "/" .. ZO_CommaDelimitNumber(33000)
    local spellResistMax = "/" .. ZO_CommaDelimitNumber(33000)
    local blockMitigationMax = "/" .. ZO_CommaDelimitNumber(90) .. "%"
    if ResistOMeter.Settings.hideMax then
        physicalResistMax = ""
        spellResistMax = ""
        blockMitigationMax = ""
    end

    local physicalResistString = cStart(physicalResistColor) ..
        ZO_CommaDelimitNumber(physicalResist) .. cEnd() .. physicalResistMax .. "\n"
    local spellResistString = cStart(spellResistColor) ..
        ZO_CommaDelimitNumber(spellResist) .. cEnd() .. spellResistMax .. "\n"
    local blockMitigationString = cStart(blockMitigationColor) ..
        ZO_CommaDelimitNumber(blockMitigation) .. "%" .. cEnd() .. blockMitigationMax

    if ResistOMeter.Settings.hidePhysicalResistance then physicalResistString = "" end
    if ResistOMeter.Settings.hideSpellResistance then spellResistString = "" end
    if ResistOMeter.Settings.hideBlockMitigation then blockMitigationString = "" end

    return physicalResistString .. spellResistString .. blockMitigationString
end

function ResistOMeter.FillLabel()
    local physicalResist = GetPlayerStat(STAT_PHYSICAL_RESIST)
    local spellResist = GetPlayerStat(STAT_SPELL_RESIST)
    local _, _, blockMitigation = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_BLOCK_MITIGATION)
    blockMitigation = math.floor(blockMitigation) --Floating point things I guess

    ResistOMeterMainWindow:GetNamedChild("LabelName"):SetText(ResistOMeter.GetStringNames())
    ResistOMeterMainWindow:GetNamedChild("LabelValue"):SetText(ResistOMeter.GetStringValues(physicalResist, spellResist,
        blockMitigation))
end

function ResistOMeter.SaveConstraints()
    ResistOMeter.Settings.mainWindowX = ResistOMeterMainWindow:GetLeft()
    ResistOMeter.Settings.mainWindowY = ResistOMeterMainWindow:GetTop()
    ResistOMeter.Settings.mainWindowWidth = ResistOMeterMainWindow:GetWidth()
    ResistOMeter.Settings.mainWindowHeight = ResistOMeterMainWindow:GetHeight()
end

function ResistOMeter.createSettings()
    local panelData = {
        type = "panel",
        name = "Resist-O-Meter",
        author = 'Complicative',
        version = ResistOMeter.version,
        website = "https://www.esoui.com/downloads/author-68201.html"
    }

    LAM2:RegisterAddonPanel("ResistOMeterOptions", panelData)

    local optionsData = {}
    optionsData[#optionsData + 1] = {
        type = "description",
        text = "Shows Physical and Spell Resistance and Block Mitigation in a small window.\nTurns yellow, if a bit over cap. Red if far over cap!\n\n/resistometer to toggle on or off"
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Hide",
        getFunc = function() return ResistOMeter.Settings.hidden end,
        setFunc = function(value)
            ResistOMeter.Settings.hidden = value
            ResistOMeter.SetHidden(ResistOMeter.Settings.hidden)
        end
    }
    optionsData[#optionsData + 1] = {
        type = "divider",
        width = "full"
    }
    optionsData[#optionsData + 1] = {
        type = "slider",
        name = "Font Size",
        getFunc = function() return ResistOMeter.Settings.fontSize end,
        setFunc = function(value)
            ResistOMeter.Settings.fontSize = value
            ResistOMeterMainWindowLabelName:SetFont(string.format("$(MEDIUM_FONT)|$(KB_%d)|thick-outline", value))
            ResistOMeterMainWindowLabelValue:SetFont(string.format("$(MEDIUM_FONT)|$(KB_%d)|thick-outline", value))
            ResistOMeter.FillLabel()
        end,
        min = 12,
        max = 32,
        step = 1
    }
    optionsData[#optionsData + 1] = {
        type = "dropdown",
        name = "Name Type",
        choices = { "long", "short", "initials", "icon", "none", "custom" },
        getFunc = function() return ResistOMeter.Settings.nameType end,
        setFunc = function(value)
            ResistOMeter.Settings.nameType = value
            ResistOMeter.FillLabel()
        end
    }
    optionsData[#optionsData + 1] = {
        type = "editbox",
        name = "Custom Physical Resistance Name",
        tooltip = "custom needs to be selected in Name Type",
        getFunc = function() return ResistOMeter.Settings.customPhysicalResistance end,
        setFunc = function(text) ResistOMeter.Settings.customPhysicalResistance = text ResistOMeter.FillLabel() end,
        isMultiline = false,
        default = "Physical Resistance",
    }
    optionsData[#optionsData + 1] = {
        type = "editbox",
        name = "Custom Spell Resistance Name",
        tooltip = "custom needs to be selected in Name Type",
        getFunc = function() return ResistOMeter.Settings.customSpellResistance end,
        setFunc = function(text) ResistOMeter.Settings.customSpellResistance = text ResistOMeter.FillLabel() end,
        isMultiline = false,
        default = "Spell Resistance",
    }
    optionsData[#optionsData + 1] = {
        type = "editbox",
        name = "Custom Block Mitigation Name",
        tooltip = "custom needs to be selected in Name Type",
        getFunc = function() return ResistOMeter.Settings.customBlockMitigation end,
        setFunc = function(text) ResistOMeter.Settings.customBlockMitigation = text ResistOMeter.FillLabel() end,
        isMultiline = false,
        default = "Block Mitigation",
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Hide Max Values",
        getFunc = function() return ResistOMeter.Settings.hideMax end,
        setFunc = function(value)
            ResistOMeter.Settings.hideMax = value
            ResistOMeter.FillLabel()
        end
    }
    optionsData[#optionsData + 1] = {
        type = "divider",
        width = "full"
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Hide Physical Resistance",
        getFunc = function() return ResistOMeter.Settings.hidePhysicalResistance end,
        setFunc = function(value)
            ResistOMeter.Settings.hidePhysicalResistance = value
            ResistOMeter.FillLabel()
        end
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Hide Spell Resistance",
        getFunc = function() return ResistOMeter.Settings.hideSpellResistance end,
        setFunc = function(value)
            ResistOMeter.Settings.hideSpellResistance = value
            ResistOMeter.FillLabel()
        end
    }
    optionsData[#optionsData + 1] = {
        type = "checkbox",
        name = "Hide Block Mitigation",
        getFunc = function() return ResistOMeter.Settings.hideBlockMitigation end,
        setFunc = function(value)
            ResistOMeter.Settings.hideBlockMitigation = value
            ResistOMeter.FillLabel()
        end
    }
    optionsData[#optionsData + 1] = {
        type = "divider",
        width = "full"
    }
    optionsData[#optionsData + 1] = {
        type = "dropdown",
        name = "Background style",
        choices = { "ZO_CenterlessBackdrop", "ZO_DarkThinFrame", "ZO_DefaultBackdrop", "ZO_InsetBackdrop",
            "ZO_MinorMungeBackdrop_SemiTransparentBlack", "ZO_MinorMungeBackdrop_SolidWhite", "ZO_ThinBackdrop",
            "ZO_SelectionHighlight", "ZO_SliderBackdrop", "ZO_SmallKeyBackdrop" },
        getFunc = function() return ResistOMeter.Settings.backdrop end,
        setFunc = function(value)
            ResistOMeter.Settings.backdrop = value
        end,
        requiresReload = true,
        tooltip = "Screenshots of all styles are available on the ESOUI " .. ResistOMeter.name .. " webpage."
    }

    LAM2:RegisterOptionControls("ResistOMeterOptions", optionsData)
end

function ResistOMeter.SetHidden(hidden)
    if hidden then
        HUD_SCENE:RemoveFragment(mainFragment)
        HUD_UI_SCENE:RemoveFragment(mainFragment)
        SCENE_MANAGER:GetScene("inventory"):RemoveFragment(mainFragment)
    end
    if not hidden then
        HUD_SCENE:AddFragment(mainFragment)
        HUD_UI_SCENE:AddFragment(mainFragment)
        SCENE_MANAGER:GetScene("inventory"):AddFragment(mainFragment)
    end
end

function ResistOMeter.OnAddOnLoaded(event, addonName)
    if addonName ~= ResistOMeter.name then
        return
    end
    -- SavedSettings
    ResistOMeter.Settings = ZO_SavedVars:NewAccountWide("ResistOMeterSettings", 1, nil, ResistOMeter.Default)

    ResistOMeterMainWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ResistOMeter.Settings.mainWindowX,
        ResistOMeter.Settings.mainWindowY)
    ResistOMeterMainWindow:SetWidth(ResistOMeter.Settings.mainWindowWidth)
    ResistOMeterMainWindow:SetHeight(ResistOMeter.Settings.mainWindowHeight)
    ResistOMeterMainWindowLabelName:SetFont(string.format("$(MEDIUM_FONT)|$(KB_%d)|thick-outline",
        ResistOMeter.Settings.fontSize))
    ResistOMeterMainWindowLabelValue:SetFont(string.format("$(MEDIUM_FONT)|$(KB_%d)|thick-outline",
        ResistOMeter.Settings.fontSize))

    ResistOMeter.ResistOMeterBackdrop = CreateControlFromVirtual("$(parent)BG", ResistOMeterMainWindow,
        ResistOMeter.Settings.backdrop)
    ResistOMeter.ResistOMeterBackdrop:SetAnchorFill(ResistOMeterMainWindow)

    ResistOMeter.SetHidden(ResistOMeter.Settings.hidden)
    ResistOMeter.createSettings()
    ResistOMeter.FillLabel()
end

EVENT_MANAGER:RegisterForEvent(ResistOMeter.name, EVENT_ADD_ON_LOADED, ResistOMeter.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(ResistOMeter.name, EVENT_EFFECT_CHANGED, ResistOMeter.FillLabel)
EVENT_MANAGER:RegisterForEvent(ResistOMeter.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ResistOMeter.FillLabel)
EVENT_MANAGER:AddFilterForEvent(ResistOMeter.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)

SLASH_COMMANDS["/resistometer"] = function()
    ResistOMeter.Settings.hidden = not ResistOMeter.Settings.hidden
    ResistOMeter.SetHidden(ResistOMeter.Settings.hidden)
end
