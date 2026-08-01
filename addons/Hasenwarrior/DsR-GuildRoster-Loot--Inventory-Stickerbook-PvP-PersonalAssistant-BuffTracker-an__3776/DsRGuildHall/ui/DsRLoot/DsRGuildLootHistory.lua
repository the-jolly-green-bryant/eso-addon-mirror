-- Create namespace
DsRGuildLootHistory = {}
local DsRGuildLootHistory = DsRGuildLootHistory  or {}

DsRGuildLootHistory.name = "DsRGuildLootHistory"

local DSRLH_LOOTITEM_TYPE_STOLEN        = "/esoui/art/inventory/inventory_stolenitem_icon.dds"
local DSRLH_LOOTITEM_TYPE_XP            = "DsRGuildHall/misc/DsR_XP.dds"
local DSRLH_LOOTITEM_TYPE_AP            = "DsRGuildHall/misc/DsR_AP.dds"
local DSRLH_LOOT_HISTORY_HIGHLIGHT_BG   = "DsRGuildHall/misc/loothistory_highlight.dds"

local DSRLH_BACKGROUND_COLOR_STOLEN    = ZO_ColorDef:New("220000") -- red
local DSRLH_BACKGROUND_COLOR_FINE      = ZO_ColorDef:New("008000") -- green
local DSRLH_BACKGROUND_COLOR_SUPERIOR  = ZO_ColorDef:New("240faa") -- blue
local DSRLH_BACKGROUND_COLOR_EPIC      = ZO_ColorDef:New("521252") -- lila
local DSRLH_BACKGROUND_COLOR_LEGENDARY = ZO_ColorDef:New("ffd700") -- gold
local DSRLH_BACKGROUND_COLOR_MYTHIC    = ZO_ColorDef:New("ffa500") -- orange
local DSRLH_BACKGROUND_COLOR_DEFAULT   = ZO_BLACK

local DSRLH_WORLD_ICONS =
{
    [DSRLH_WORLD_LEGERDEMAIN]  = "/esoui/art/icons/crownstore_skillline_legerdemain.dds",
    [DSRLH_WORLD_SOUL]         = "/esoui/art/icons/crownstore_skillline_soulmagic.dds",
    [DSRLH_WORLD_VAMPIRE]      = "/esoui/art/icons/store_vampirebite_01.dds",
    [DSRLH_WORLD_WEREWOLF]     = "/esoui/art/icons/store_werewolfbite_01.dds",
    [DSRLH_WORLD_SCRYING]      = "/esoui/art/icons/skilllinexp_scrying.dds",
    [DSRLH_WORLD_EXCAVATION]   = "/esoui/art/icons/u26_ability_digging_02.dds",
}

-------------------------------------------------------------------------------------------------------------------------------------------------
--- Check if the default Loot History is disabled
local function LootHistoryDisabled()
    return tonumber(GetSetting(SETTING_TYPE_LOOT, LOOT_SETTING_LOOT_HISTORY)) ~= 1
end

-------------------------------------------------------------------------------------------------------------------------------------------------
--- Original function from ingame\zo_loot\loothistory_shared.lua:51
local function SetupEntryText(control, data)
	local BagPackIcon     = [[esoui/art/inventory/inventory_tabicon_craftbag_up.dds]]
	local BagPackIconText = zo_iconTextFormat(BagPackIcon, 20, 20, "")
	local colorBagPack    = "|cA4A4A4"

	local tradeIcon     = [[/DsRGuildHall/misc/tradehammer.dds]]
	local tradeIconText = zo_iconTextFormat(tradeIcon, 20, 20, "")
	local colortrade    = "|cFFAE42"

    local text    = data.text
    local textNEW = data.text

    if type(text) == "function" then
        text = text(data)
    elseif zo_strfind(data.icon, "Experience") or zo_strfind(data.icon, "alliancepoints") or zo_strfind(data.icon, "telvarstone") then
        text = data.text
    elseif zo_strfind(data.icon, "AVA_Siege_") then  -- Bezirke eingenommen / verteidigt
        text = data.text  
    elseif data.companionId ~= nil or zo_strfind(data.icon, "soulgem") or zo_strfind(data.icon, "coinbag") or zo_strfind(data.icon, "quest_plan")  or zo_strfind(data.icon, "heavy_sack") then 
        text = data.text  
    else
        local CheckLen = zo_strlen(data.text)
        if tonumber(CheckLen) > 30 then
            textNEW = data.text:sub(1, 30) .. "...."
        else
            textNEW = data.text
        end
        if LootHistoryTable[1] ~= nil then
            if DsRGuildLoot.sV.HistoryTradePrice then
                BagTradeText  = colorBagPack .. LootHistoryTable[1].BCount .. BagPackIconText .. "/ " .. colortrade .. tradeIconText ..  LootHistoryTable[1].Price .. "g"
            else
                BagTradeText  = colorBagPack ..  LootHistoryTable[1].BCount .. BagPackIconText
            end
            text = textNEW .. "\n" .. BagTradeText
        else
            text = textNEW
        end
    end

    control.label:SetText(text)
    control.label:SetColor(data.color:UnpackRGBA())

    local fontFile = ZoFontGame:GetFontInfo()
    local fontSize = 15
    local fontDecoration = "soft-shadow-thin"
    control.label:SetFont(string.format("%s|%d|%s", fontFile, fontSize, fontDecoration))
end

-------------------------------------------------------------------------------------------------------------------------------------------------
--- Original function from ingame\zo_loot\loothistory_shared.lua:59
local function SetupIconOverlayText(control, data)
    local overlayText = ZO_LootHistory_Shared.GetIconOverlayTextFromData(data)
    control.iconOverlayText:SetText(overlayText)

    local showOverlayText = ZO_LootHistory_Shared.GetShowIconOverlayTextFromData(data)
    control.iconOverlayText:SetHidden(not showOverlayText)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function SetupHighlightBackground(control, data)

    control.backgroundHighlight:SetHidden(true)

    local hidden = false
    if data.isStolen then
        control.backgroundHighlight:SetTexture(DSRLH_LOOT_HISTORY_HIGHLIGHT_BG)
        control.backgroundHighlight:SetColor(DSRLH_BACKGROUND_COLOR_STOLEN:UnpackRGB())
    elseif data.highlight then
        if data.quality == 2 then
            control.backgroundHighlight:SetTexture(DSRLH_LOOT_HISTORY_HIGHLIGHT_BG)
            control.backgroundHighlight:SetColor(DSRLH_BACKGROUND_COLOR_FINE:UnpackRGB())
        elseif data.quality == 3 then
            control.backgroundHighlight:SetTexture(DSRLH_LOOT_HISTORY_HIGHLIGHT_BG)
            control.backgroundHighlight:SetColor(DSRLH_BACKGROUND_COLOR_SUPERIOR:UnpackRGB())
        elseif data.quality == 4 then
            control.backgroundHighlight:SetTexture(DSRLH_LOOT_HISTORY_HIGHLIGHT_BG)
            control.backgroundHighlight:SetColor(DSRLH_BACKGROUND_COLOR_EPIC:UnpackRGB())
        elseif data.quality == 5 then
            control.backgroundHighlight:SetTexture(DSRLH_LOOT_HISTORY_HIGHLIGHT_BG)
            control.backgroundHighlight:SetColor(DSRLH_BACKGROUND_COLOR_LEGENDARY:UnpackRGB())
        elseif data.quality == 6 then
            control.backgroundHighlight:SetTexture(DSRLH_LOOT_HISTORY_HIGHLIGHT_BG)
            control.backgroundHighlight:SetColor(DSRLH_BACKGROUND_COLOR_MYTHIC:UnpackRGB())
        else
            control.backgroundHighlight:SetTexture(DSRLH_LOOT_HISTORY_HIGHLIGHT_BG)
            control.backgroundHighlight:SetColor(DSRLH_BACKGROUND_COLOR_DEFAULT:UnpackRGB())
        end
    else
        hidden = true
    end
    control.backgroundHighlight:SetHidden(hidden)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function SetupBackground(control, data)
    control.background:SetScale(0.5)
    control.background:SetTexture(DSRLH_LOOT_HISTORY_HIGHLIGHT_BG)
    
    if data.isStolen then
        local r, g, b = DSRLH_BACKGROUND_COLOR_STOLEN:UnpackRGB()
        control.background:SetColor(r, g, b, 0.1)
    elseif data.backgroundColor then
        control.background:SetColor(data.backgroundColor:UnpackRGB())
    elseif data.quality == 2 then
        local r, g, b = DSRLH_BACKGROUND_COLOR_FINE:UnpackRGB()
        control.background:SetColor(r, g, b, 0.1)
    elseif data.quality == 3 then
        local r, g, b = DSRLH_BACKGROUND_COLOR_SUPERIOR:UnpackRGB()
        control.background:SetColor(r, g, b, 0.2)
    elseif data.quality == 4 then
        local r, g, b = DSRLH_BACKGROUND_COLOR_EPIC:UnpackRGB()
        control.background:SetColor(r, g, b, 0.1)
    elseif data.quality == 5 then
        local r, g, b = DSRLH_BACKGROUND_COLOR_LEGENDARY:UnpackRGB()
        control.background:SetColor(r, g, b, 0.1)
    elseif data.quality == 6 then
        local r, g, b = DSRLH_BACKGROUND_COLOR_MYTHIC:UnpackRGB()
        control.background:SetColor(r, g, b, 0.1)
    else
        control.background:SetColor(DSRLH_BACKGROUND_COLOR_DEFAULT:UnpackRGB())
    end
    
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function SetupStatusIcon(control, data)
    local hidden = false
    if data.isStolen then
        control.statusIcon:SetTexture(DSRLH_LOOTITEM_TYPE_STOLEN)
    elseif zo_strfind(data.icon, "alliancepoints") then
        control.statusIcon:SetTexture(DSRLH_LOOTITEM_TYPE_AP)
    elseif zo_strfind(data.icon, "Experience") then
        control.statusIcon:SetTexture(DSRLH_LOOTITEM_TYPE_XP)
    elseif data.statusIcon then
        control.statusIcon:SetTexture("/esoui/art/tooltips/icon_craft_bag.dds")
        control.statusIcon:SetDimensions(30, 30)
    else
        hidden = true
    end
    control.statusIcon:SetHidden(hidden)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function SetupIcon(control, data)
    local icon = data.icon
    if data.entryType == LOOT_ENTRY_TYPE_SKILL_EXPERIENCE then
        if data.skillLineData.skillTypeData:GetSkillType() == SKILL_TYPE_WORLD then
            icon = DSRLH_WORLD_ICONS[data.skillLineData.skillLineIndex]
        end
    end
    control.icon:SetTexture(icon)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function LootSetupFunction(control, data)
    SetupEntryText(control, data)
    SetupIcon(control, data)
    SetupIconOverlayText(control, data)
    SetupBackground(control, data)
    SetupHighlightBackground(control, data)
    SetupStatusIcon(control, data)

    table.remove(LootHistoryTable, 1)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function AllowExtendedSkillHistory(skillType, skillLineIndex, skillLineData)
    return skillType == SKILL_TYPE_WORLD and skillLineData.isActive and DsRGuildLoot.sV.HistoryShowType[skillLineIndex]
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function OnSkillExperienceUpdated(skillType, skillLineIndex, reason, rank, previousXP, currentXP)
    local xpGain = currentXP - previousXP
    if  LootHistoryDisabled() or xpGain <= 0 then return end

    local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(skillType, skillLineIndex)

    if AllowExtendedSkillHistory(skillType, skillLineIndex, skillLineData) then
        DsRGuildLootHistory.ZoLootHistory:AddSkillEntry(skillLineData, xpGain)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLootHistory.UpdatePersistentContainerShowTime()
    DsRGuildLootHistory.ZoLootHistory.lootStreamPersistent:SetContainerShowTime(DsRGuildLoot.sV.HistoryPersistantContainerShowTime * 1000)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLootHistory.UpdateContainerShowTime()
    DsRGuildLootHistory.ZoLootHistory.lootStream:SetContainerShowTime(DsRGuildLoot.sV.HistoryContainerShowTime * 1000)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLootHistory.UpdateMaxEntries()
    DsRGuildLootHistory.ZoLootHistory.lootStreamPersistent.maxDisplayedEntries = DsRGuildLoot.sV.HistoryMaxItems
    DsRGuildLootHistory.ZoLootHistory.lootStream.maxDisplayedEntries = DsRGuildLoot.sV.HistoryMaxItems
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLootHistory.UpdateLootHistoryDisplayInMenus()
    for _, scene in pairs(DsRglobals.MenuScenes) do
        if DsRGuildLoot.sV.HistoryShowInMenus then
            scene:AddFragment(KEYBOARD_LOOT_HISTORY_FRAGMENT)
        else
            scene:RemoveFragment(KEYBOARD_LOOT_HISTORY_FRAGMENT)
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLootHistory.OverrideLootSetupFunctions()
    local mode = "ZO_LootHistory_KeyboardEntry"
    if IsInGamepadPreferredMode() then
        mode = "ZO_LootHistory_GamepadEntry"
    end
    DsRGuildLootHistory.ZoLootHistory.lootStreamPersistent.templates[mode].setup = LootSetupFunction
    DsRGuildLootHistory.ZoLootHistory.lootStream.templates[mode].setup           = LootSetupFunction
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLootHistory_Load()
    DsRGuildLootHistory.ZoLootHistory = SYSTEMS:GetObject(ZO_LOOT_HISTORY_NAME)
    DsRGuildLootHistory.UpdatePersistentContainerShowTime()
    DsRGuildLootHistory.UpdateContainerShowTime()
    DsRGuildLootHistory.UpdateMaxEntries()
    DsRGuildLootHistory.UpdateLootHistoryDisplayInMenus()

    DsRGuildLootHistory.OverrideLootSetupFunctions()

    EVENT_MANAGER:RegisterForEvent(DsRGuildLootHistory.AddonName, EVENT_SKILL_XP_UPDATE, function(eventId, ...) OnSkillExperienceUpdated(...) end)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- On addon loaded
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildLootHistory.OnAddonLoaded(event, name)
    if DsRGuildLoot.sV.HistoryOnOff then return end
    DsRGuildLootHistory_Load()
end