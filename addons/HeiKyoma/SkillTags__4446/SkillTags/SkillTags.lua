SkillTags = SkillTags or {}
local ST = SkillTags

ST.name = "SkillTags"

ST.colors = { -- RGB
    active   = { 1.00, 0.60, 1.00 }, -- pink
    inactive = { 0.40, 0.40, 0.40 }, -- grey
    buff     = { 0.95, 0.70, 0.30 }, -- warm
    text     = { 1.00, 1.00, 1.00 }, -- white
    bg       = { 0.05, 0.05, 0.05, 0.92 },
    edge     = { 0.55, 0.55, 0.55, 0.60 },
    unknown  = { 1.00, 0.20, 0.20 }, -- red
    -- 
    magic    = { 0.45, 0.85, 1.00 }, -- blue
    phys     = { 0.35, 1.00, 0.45 }, -- green
    hybrid   = { 0.75, 1.00, 0.20 }, -- acid
    notype   = { 0.95, 0.70, 0.30 }, -- warm
}

local DEBUG = false

SLASH_COMMANDS["/skilltagsdebug"] = function(arg)
    if arg == "on" then
        DEBUG = true
    elseif arg == "off" then
        DEBUG = false
    else
        DEBUG = not DEBUG
    end
    d("[SkillTags] debug = " .. tostring(DEBUG))
end

local function Log(msg)
    if DEBUG then
        d("[SkillTags] " .. tostring(msg))
    end
end

local function NormalizeSearchText(text)
    text = tostring(text or "")
    text = zo_strlower(text)
    text = text:gsub("|c%x%x%x%x%x%x", "")
    text = text:gsub("|r", "")
    return text
end

function ST.GetRealtimeDamageTypeFromTooltip(tooltip, abilityId)
    local text = ""

    if tooltip and tooltip.GetNamedChild then
        local candidates = {
            "Description",
            "description",
            "Body",
            "body",
        }

        for _, childName in ipairs(candidates) do
            local child = tooltip:GetNamedChild(childName)
            if child and child.GetText then
                local part = child:GetText()
                if part and part ~= "" then
                    text = text .. " " .. tostring(part)
                end
            end
        end
    end

    if text == "" and abilityId and GetAbilityDescription then
        local ok, result = pcall(function() return GetAbilityDescription(abilityId) end)
        if ok and result then
            text = tostring(result)
        end
    end

    text = NormalizeSearchText(text)

    local hasMagic = false
    local hasPhys = false

    if ST.DamageTypeLoc and ST.DamageTypeLoc.magicPatterns then
        for _, pattern in ipairs(ST.DamageTypeLoc.magicPatterns) do
            if text:find(pattern) then
                hasMagic = true
                break
            end
        end
    end
    
    if ST.DamageTypeLoc and ST.DamageTypeLoc.physPatterns then
        for _, pattern in ipairs(ST.DamageTypeLoc.physPatterns) do
            if text:find(pattern) then
                hasPhys = true
                break
            end
        end
    end

    if hasMagic and hasPhys then
        return "phys+magic", ST.colors.hybrid
    elseif hasMagic then
        return "magic", ST.colors.magic
    elseif hasPhys then
        return "phys", ST.colors.phys
    end

    return "no type", ST.colors.notype
end

function ST.GetTagData(abilityId)
    if not abilityId then return nil end
    if not ST.Data then return nil end
    return ST.Data[abilityId]
end

function ST.CreateTagWindow()
    if ST.tagWindow then
        return
    end

    local wm = WINDOW_MANAGER

    local win = wm:CreateTopLevelWindow("SkillTagsWindow")
    win:SetHidden(true)
    win:SetMouseEnabled(false)
    win:SetMovable(false)
    win:SetClampedToScreen(true)
    win:SetDrawLayer(DL_OVERLAY)
    win:SetDrawTier(DT_HIGH)

    local bg = wm:CreateControl("$(parent)BG", win, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(unpack(ST.colors.bg))
    bg:SetEdgeColor(unpack(ST.colors.edge))

    local idLabel = wm:CreateControl("$(parent)IdLabel", win, CT_LABEL)
    idLabel:SetFont("ZoFontHeader3")
    idLabel:SetAnchor(TOPLEFT, win, TOPLEFT, 10, 8)
    idLabel:SetColor(unpack(ST.colors.text))

    local damageTypeLabel = wm:CreateControl("$(parent)DamageType", win, CT_LABEL)
    damageTypeLabel:SetFont("ZoFontGameLargeBold")
    damageTypeLabel:SetAnchor(TOPLEFT, idLabel, BOTTOMLEFT, 0, 8)
    -- damageTypeLabel:SetHidden(true)

    local directLabel = wm:CreateControl("$(parent)Direct", win, CT_LABEL)
    -- directLabel:SetFont("ZoFontGameLargeBold")
    directLabel:SetAnchor(TOPLEFT, damageTypeLabel, BOTTOMLEFT, 0, 8)

    local dotLabel = wm:CreateControl("$(parent)Dot", win, CT_LABEL)
    -- dotLabel:SetFont("ZoFontGameLargeBold")
    dotLabel:SetAnchor(LEFT, directLabel, RIGHT, 20, 0)

    local aoeLabel = wm:CreateControl("$(parent)Aoe", win, CT_LABEL)
    -- aoeLabel:SetFont("ZoFontGameLargeBold")
    aoeLabel:SetAnchor(TOPLEFT, directLabel, BOTTOMLEFT, 0, 8)

    local singleLabel = wm:CreateControl("$(parent)Single", win, CT_LABEL)
    -- singleLabel:SetFont("ZoFontGameLargeBold")
    singleLabel:SetAnchor(LEFT, aoeLabel, RIGHT, 20, 0)

    local buffLabel = wm:CreateControl("$(parent)Buff", win, CT_LABEL)
    buffLabel:SetFont("ZoFontGameLargeBold")
    buffLabel:SetAnchor(TOPLEFT, damageTypeLabel, BOTTOMLEFT, 0, 8)

    local unknownLabel = wm:CreateControl("$(parent)Unknown", win, CT_LABEL)
    unknownLabel:SetFont("ZoFontGameLargeBold")
    unknownLabel:SetAnchor(TOPLEFT, damageTypeLabel, BOTTOMLEFT, 0, 8)
    unknownLabel:SetText("?")
    unknownLabel:SetColor(unpack(ST.colors.unknown))
    unknownLabel:SetHidden(true)

    ST.tagWindow = win
    ST.idLabel = idLabel
    ST.damageTypeLabel = damageTypeLabel --
    ST.directLabel = directLabel
    ST.dotLabel = dotLabel
    ST.aoeLabel = aoeLabel
    ST.singleLabel = singleLabel
    ST.buffLabel = buffLabel
    ST.unknownLabel = unknownLabel
end

function ST.ApplyState(label, isActive, text)
    label:SetText(text)

    if isActive then
        label:SetColor(unpack(ST.colors.active))
        label:SetFont("ZoFontGameLargeBold")
    else
        label:SetColor(unpack(ST.colors.inactive))
        label:SetFont("ZoFontGameLarge")
    end
end

function ST.ResizeWindow()
    local row1w = ST.idLabel:GetTextWidth()

    local isDamageTypeVisible = ST.damageTypeLabel --and not ST.damageTypeLabel:IsHidden()
    local isBuffVisible = ST.buffLabel and not ST.buffLabel:IsHidden()
    local isUnknownVisible = ST.unknownLabel and not ST.unknownLabel:IsHidden()

    local row2w = 0
    local row3w, row4w, h

    if isDamageTypeVisible then
        row2w = ST.damageTypeLabel:GetTextWidth()
    end

    if isUnknownVisible then
        row3w = ST.unknownLabel:GetTextWidth()
        row4w = 0
        h = ST.idLabel:GetTextHeight()
            + (isDamageTypeVisible and ST.damageTypeLabel:GetTextHeight() or 0)
            + ST.unknownLabel:GetTextHeight()
            + (isDamageTypeVisible and 34 or 26)
    elseif isBuffVisible then
        row3w = ST.buffLabel:GetTextWidth()
        row4w = 0
        h = ST.idLabel:GetTextHeight()
            + (isDamageTypeVisible and ST.damageTypeLabel:GetTextHeight() or 0)
            + ST.buffLabel:GetTextHeight()
            + (isDamageTypeVisible and 34 or 26)
    else
        row3w = ST.directLabel:GetTextWidth() + 20 + ST.dotLabel:GetTextWidth()
        row4w = ST.aoeLabel:GetTextWidth() + 20 + ST.singleLabel:GetTextWidth()
        h = ST.idLabel:GetTextHeight()
            + (isDamageTypeVisible and ST.damageTypeLabel:GetTextHeight() or 0)
            + ST.directLabel:GetTextHeight()
            + ST.aoeLabel:GetTextHeight()
            + (isDamageTypeVisible and 42 or 34)
    end

    local w = math.max(row1w, row2w, row3w, row4w or 0) + 20
    ST.tagWindow:SetDimensions(w, h)
end

function ST.AnchorWindow()
    ST.tagWindow:ClearAnchors()

    if SkillTooltip then
        ST.tagWindow:SetAnchor(BOTTOMLEFT, SkillTooltip, TOPLEFT, 0, -6)
    else
        ST.tagWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
end

function ST.ShowTagsNearTooltip(abilityId, tooltip)
    ST.CreateTagWindow()

    ST.idLabel:SetText("AbilityId: " .. tostring(abilityId or "nil"))

    local damageTypeText, damageTypeColor = ST.GetRealtimeDamageTypeFromTooltip(tooltip, abilityId)
    ST.damageTypeLabel:SetText(damageTypeText)
    ST.damageTypeLabel:SetColor(unpack(damageTypeColor))

    if not abilityId then
        ST.unknownLabel:SetText("?")
        ST.unknownLabel:SetColor(unpack(ST.colors.unknown))
        ST.unknownLabel:SetHidden(false)

        ST.damageTypeLabel:SetHidden(true)
        ST.buffLabel:SetHidden(true)
        ST.directLabel:SetHidden(true)
        ST.dotLabel:SetHidden(true)
        ST.aoeLabel:SetHidden(true)
        ST.singleLabel:SetHidden(true)

        ST.ResizeWindow()
        ST.AnchorWindow()
        ST.tagWindow:SetHidden(false)
        return
    end

    local data = ST.GetTagData(abilityId)

    if data and data.buff == true then
        ST.buffLabel:SetText("Buff or Non-damage")
        ST.buffLabel:SetColor(unpack(ST.colors.buff))
        ST.buffLabel:SetHidden(false)
        
        ST.damageTypeLabel:SetHidden(false)

        ST.directLabel:SetHidden(true)
        ST.dotLabel:SetHidden(true)
        ST.aoeLabel:SetHidden(true)
        ST.singleLabel:SetHidden(true)
        ST.unknownLabel:SetHidden(true)
    else
        ST.buffLabel:SetHidden(true)
        ST.unknownLabel:SetHidden(true)

        ST.directLabel:SetHidden(false)
        ST.dotLabel:SetHidden(false)
        ST.aoeLabel:SetHidden(false)
        ST.singleLabel:SetHidden(false)

        if data then
            ST.ApplyState(ST.directLabel, data.direct == true, "Direct")
            ST.ApplyState(ST.dotLabel, data.dot == true, "DoT")
            ST.ApplyState(ST.aoeLabel, data.aoe == true, "AoE")
            ST.ApplyState(ST.singleLabel, data.single == true, "Single-target")
        else
            ST.ApplyState(ST.directLabel, false, "Direct")
            ST.ApplyState(ST.dotLabel, false, "DoT")
            ST.ApplyState(ST.aoeLabel, false, "AoE")
            ST.ApplyState(ST.singleLabel, false, "Single-target")
        end
    end

    ST.ResizeWindow()
    ST.AnchorWindow()
    ST.tagWindow:SetHidden(false)
end

function ST.HideTags()
    if ST.tagWindow then
        ST.tagWindow:SetHidden(true)
    end
end

function ST.TryHookTooltips()
    Log("TryHookTooltips start")

    if not ST._hookedKeyboardTooltip then
        ST._hookedKeyboardTooltip = true

        SecurePostHook(ZO_ActiveSkillProgressionData, "SetKeyboardTooltip", function(skillProgressionData, tooltip, ...)
            Log("ZO_ActiveSkillProgressionData:SetKeyboardTooltip fired")

            local skillType, skillLineIndex, skillIndex = skillProgressionData:GetIndices()
            local morphSlot = skillProgressionData:GetMorphSlot()
            local abilityId = GetSpecificSkillAbilityInfo(skillType, skillLineIndex, skillIndex, morphSlot, 4)

            Log("Resolved abilityId = " .. tostring(abilityId))

            if type(abilityId) == "number" and abilityId > 0 then
                ST.ShowTagsNearTooltip(abilityId,tooltip)
            else
                ST.ShowTagsNearTooltip(nil,tooltip)
            end
        end)
    end

    if SkillTooltip and SkillTooltip.SetHidden then
        Log("Hooking SkillTooltip:SetHidden")

        ZO_PreHook(SkillTooltip, "SetHidden", function(control, hidden)
            Log("SkillTooltip:SetHidden(" .. tostring(hidden) .. ")")

            if hidden then
                ST.HideTags()
            end
        end)
    else
        Log("SkillTooltip:SetHidden not found")
    end
end

function ST.OnAddonLoaded(event, addonName)
    if addonName ~= ST.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ST.name, EVENT_ADD_ON_LOADED)

    Log("Addon loaded")
    ST.CreateTagWindow()
    ST.TryHookTooltips()
end

EVENT_MANAGER:RegisterForEvent(ST.name, EVENT_ADD_ON_LOADED, function(...)
    ST.OnAddonLoaded(...)
end)