local KRT = KwibusRandomThings

local DEFAULTS = { guid = {
    enabled = true,
    stripAtSymbol = true,
} }

KRT.GUID = {
    id = "guid",
    defaults = DEFAULTS.guid,
}
local self = KRT.GUID

-- SAFE SV fetcher
local function SV() 
    if KRT.sv and type(KRT.sv.guid) == "table" then 
        if KRT.sv.guid.stripAtSymbol == nil then
            KRT.sv.guid.stripAtSymbol = DEFAULTS.guid.stripAtSymbol
        end
        return KRT.sv.guid 
    end
    return DEFAULTS.guid 
end

-- Helper to remove the "@" at the start of a string
local function StripAt(name)
    if type(name) == "string" and SV().stripAtSymbol then
        return name:gsub("^@", "")
    end
    return name
end

-- Post-hook functions — each returns false to allow normal execution to continue
local function groupEntryPostHook(selfControl, control, data)
    if not SV().enabled then return false end
    if not ZO_ShouldPreferUserId() then return false end
    
    control.characterNameLabel:SetText(zo_strformat(SI_GROUP_LIST_PANEL_CHARACTER_NAME, data.index, StripAt(data.displayName)))
    return true
end

local function leaderboardEntryPostHook(selfControl, control, data)
    if not SV().enabled then return false end
    if not ZO_ShouldPreferUserId() then return false end
    
    control.nameLabel:SetText(StripAt(data.displayName))
    return false
end

local function refreshEmperorPostHook(selfControl, control, data)
    if not SV().enabled then return false end
    if not ZO_ShouldPreferUserId() then return false end
    
    if DoesCampaignHaveEmperor(selfControl.campaignId) then
        local alliance, characterName, displayName = GetCampaignEmperorInfo(selfControl.campaignId)
        local emperorName = selfControl.emperorName
        if not emperorName then return false end
        
        emperorName:SetText(StripAt(displayName))
        emperorName:SetMouseEnabled(true)
        emperorName:SetHandler("OnMouseEnter", function(empControl)
            ZO_Tooltips_ShowTextTooltip(empControl, TOP, characterName)
        end)
        emperorName:SetHandler("OnMouseExit", function(empControl)
            ZO_Tooltips_HideTextTooltip()
        end)
    end
    return false
end

local function socialListOnMouseEnterPostHook(selfControl, control)
    if not SV().enabled then return false end
    if not ZO_ShouldPreferUserId() then return false end
    
    local row = control:GetParent()
    local data = ZO_ScrollList_GetData(row)
    InitializeTooltip(InformationTooltip)
    local textwidth = control:GetTextDimensions()
    InformationTooltip:ClearAnchors()
    InformationTooltip:SetAnchor(BOTTOM, control, TOPLEFT, textwidth * 0.5, 0)
    
    local tooltipText = data.characterName or data.name
    SetTooltipText(InformationTooltip, StripAt(tooltipText))
    
    return false
end

-- New Hooks for Friends and Guild List
local function friendsListEntryPostHook(selfControl, control, data)
    if not SV().enabled then return false end
    
    local nameLabel = control:GetNamedChild("Name")
    if nameLabel and ZO_ShouldPreferUserId() then
        nameLabel:SetText(StripAt(data.displayName))
    end
    return false
end

local function guildRosterEntryPostHook(selfControl, control, data)
    if not SV().enabled then return false end
    
    local nameLabel = control:GetNamedChild("DisplayName")
    if nameLabel and ZO_ShouldPreferUserId() then
        nameLabel:SetText(StripAt(data.displayName))
    end
    return false
end

function KRT.GUID:Initialize()
    ZO_PostHook(GROUP_LIST, "SetupGroupEntry", groupEntryPostHook)
    ZO_PostHook(ZO_LeaderboardsManager_Shared, "SetupLeaderboardPlayerEntry", leaderboardEntryPostHook)
    ZO_PostHook(CampaignEmperor_Shared, "SetupLeaderboardEntry", leaderboardEntryPostHook)
    ZO_PostHook(CampaignEmperor_Shared, "RefreshEmperor", refreshEmperorPostHook)
    ZO_PostHook(ZO_SocialListKeyboard, "CharacterName_OnMouseEnter", socialListOnMouseEnterPostHook)
    
    -- Added Hooks for Friends and Guild lists
    ZO_PostHook(ZO_KeyboardFriendsList, "SetupFriendRow", friendsListEntryPostHook)
    ZO_PostHook(ZO_GuildRosterManager, "SetupGuildRosterRow", guildRosterEntryPostHook)
end

function KRT.GUID:GetLAMSubmenu()
    return {
        type = "submenu",
        name = "Group User ID",
        controls = {
            {
                type = "checkbox",
                name = "Enable Module",
                tooltip = "When ESO's 'Prefer User IDs' setting is enabled, this ensures account names are shown consistently in the group list, leaderboards, Emperor display, and social panels.",
                getFunc = function() return SV().enabled end,
                setFunc = function(v) SV().enabled = v end,
                default = DEFAULTS.guid.enabled,
                width = "full",
            },
           -- {
            --    type = "checkbox",
           --     name = "Remove @ from User IDs",
           --     tooltip = "Strips the '@' symbol from the beginning of player display names in all managed lists.",
           --     getFunc = function() return SV().stripAtSymbol end,
           --     setFunc = function(v) SV().stripAtSymbol = v end,
            --    default = DEFAULTS.guid.stripAtSymbol,
            --    width = "full",
           -- },
        }
    }
end

KRT:RegisterModule(KRT.GUID)
