local ICON_SIZE = 30
local ICON_OFFSET = 1.75

local RG = _G["RoseGuilds"]
local RG_Icons = RG and RG.Icons
local GUILD_RANK_ICONS

local displayNamesPrepared = false
local displayNameTable = {}
local displayNameGuildRank = {}
local PrepareDisplayNameTable

if GetWorldName() == "NA Megaserver" then return end

-- Check if Ody/LCI is active and if player has an icon. Prioritise Ody/LCI
local function IsAddonActive(addonName)
    if addonName == "OdySupportIcons" then
        return _G["OSI"] ~= nil
    elseif addonName == "LibCustomIcons" then
        return _G["LibCustomIcons"] ~= nil
    end
    return false
end

-- Check if player has an icon from Ody/LCI
local function HasOSIIcon(displayName)
    if not IsAddonActive("OdySupportIcons") then
        return false
    end
    if not OSI or not OSI.special then
        return false
    end
    local name = string.lower(displayName)
    local iconData = OSI.special[name]
    return iconData ~= nil and iconData.texture ~= nil and iconData.texture ~= ""
end

local function GetOSIIconPath(displayName)
    if not IsAddonActive("OdySupportIcons") then
        return nil
    end
    if not OSI or not OSI.special then
        return nil
    end
    local name = string.lower(displayName)
    local iconData = OSI.special[name]
    if iconData and iconData.texture and iconData.texture ~= "" then
        return iconData.texture
    end
    return nil
end

local function GetLCIIconPath(displayName)
    if not IsAddonActive("LibCustomIcons") then
        return nil
    end
    local LCI = _G["LibCustomIcons"]
    if not LCI then
        return nil
    end

    if type(LCI.HasStatic) == "function" and LCI.HasStatic(displayName) then
        if type(LCI.GetStatic) == "function" then
            return (LCI.GetStatic(displayName))
        end
    end

    return nil
end

local function GetExternalIconPath(displayName)
    local osiIcon = GetOSIIconPath(displayName)
    if osiIcon then
        return osiIcon
    end

    return GetLCIIconPath(displayName)
end

local EXTERNAL_ICON_PRIORITY = 10000
local DEFAULT_STATIC_ICON_PRIORITY = 0

local function GetGuildRankPriority(rankIndex)
    if type(rankIndex) ~= "number" then
        return nil
    end

    return 1000 - rankIndex
end

local function GetIconCandidate(texturePath, priority)
    if not texturePath or texturePath == "" then
        return nil
    end

    return {
        texturePath = texturePath,
        priority = priority or 0,
    }
end

local function GetHighestPriorityIcon(candidates)
    local bestTexturePath = nil
    local bestPriority = nil

    for i = 1, #candidates do
        local candidate = candidates[i]
        if candidate and candidate.texturePath and candidate.texturePath ~= "" then
            local candidatePriority = candidate.priority or 0
            if not bestPriority or candidatePriority > bestPriority then
                bestTexturePath = candidate.texturePath
                bestPriority = candidatePriority
            end
        end
    end

    return bestTexturePath
end

local function GetManualIconCandidate(displayName)
    if not RG_Icons then
        return nil
    end

    if type(RG_Icons.GetPlayerIconWithPriority) == "function" then
        local texturePath, priority = RG_Icons:GetPlayerIconWithPriority(displayName)
        return GetIconCandidate(texturePath, priority or DEFAULT_STATIC_ICON_PRIORITY)
    end

    return GetIconCandidate(RG_Icons:GetPlayerIcon(displayName), DEFAULT_STATIC_ICON_PRIORITY)
end

local function GetGuildRankIconCandidate(displayName, guildName, rankIndex)
    if not guildName or not rankIndex then
        local guildInfo = displayNameGuildRank[displayName]
        if guildInfo then
            guildName = guildInfo.guildName
            rankIndex = guildInfo.rankIndex
        end
    end

    if not guildName or not rankIndex then
        return nil
    end

    local guildIcons = GUILD_RANK_ICONS[guildName]
    if guildIcons and guildIcons[rankIndex] then
        return GetIconCandidate(guildIcons[rankIndex], GetGuildRankPriority(rankIndex))
    end

    return nil
end

local function ResolveBestIconPath(displayName, guildName, rankIndex)
    return GetHighestPriorityIcon({
        GetIconCandidate(GetExternalIconPath(displayName), EXTERNAL_ICON_PRIORITY),
        GetManualIconCandidate(displayName),
        GetGuildRankIconCandidate(displayName, guildName, rankIndex),
    })
end

local function SetRowIcon(parent, iconName, iconPath, status)
    if not parent or not iconPath then return end
    local icon = parent:GetNamedChild(iconName)
    if not icon then return end
    local overlay = icon:GetNamedChild("RoseGuildsOverlay")
    if not overlay then
        overlay = icon:CreateControl(icon:GetName() .. "RoseGuildsOverlay", CT_TEXTURE)
        overlay:ClearAnchors()
        overlay:SetParent(icon)
        overlay:SetAnchor(TOPLEFT, icon, TOPLEFT, ICON_OFFSET, ICON_OFFSET)
        overlay:SetDimensions(icon:GetWidth() - 2 * ICON_OFFSET, icon:GetHeight() - 2 * ICON_OFFSET)
        overlay:SetDrawLayer(1)
    end
    overlay:SetTexture(iconPath)
    overlay:SetHidden(false)

    icon:SetDrawLayer(2)
    if status == PLAYER_STATUS_OFFLINE then
        icon:SetTexture("RoseGuilds/icons/base/offline.dds")
    elseif status == PLAYER_STATUS_AWAY then
        icon:SetTexture("RoseGuilds/icons/base/away.dds")
    elseif status == PLAYER_STATUS_DO_NOT_DISTURB then
        icon:SetTexture("RoseGuilds/icons/base/dnd.dds")
    else
        icon:SetTexture("RoseGuilds/icons/base/online.dds")
    end
end

local function HideRowIcon(parent, iconName)
    local icon = parent:GetNamedChild(iconName)
    if not icon then return end
    local overlay = icon:GetNamedChild("RoseGuildsOverlay")
    if overlay then overlay:SetHidden(true) end
end

local ALLOWED_GUILD_NAMES = {
    ["Midnight Rose"] = true,
    ["Summer Rose"] = true,
    ["Spring Rose"] = true,
    ["Winter Rose"] = true,
    ["Autumn Rose"] = true,
}

local DEFAULT_ICON_PATH = "RoseGuilds/icons/base/whiterose.dds"

-- Table for icons based on rank within each rose guild
GUILD_RANK_ICONS = {
    ["Midnight Rose"] = {
        [1] = "RoseGuilds/icons/admin/tell.dds",
        [2] = "RoseGuilds/icons/admin/tell.dds",
        [3] = "RoseGuilds/icons/admin/tell.dds",
        [4] = "RoseGuilds/icons/admin/tell.dds",
        [5] = "RoseGuilds/icons/base/midnightrg.dds",
        [6] = "RoseGuilds/icons/base/midnightdiamond.dds",
        [7] = "RoseGuilds/icons/base/midnight.dds",
        [8] = "RoseGuilds/icons/base/necro.dds",
        [9] = "RoseGuilds/icons/base/whiterose.dds",
        [10] = "RoseGuilds/icons/base/baserose.dds",
    },
    ["Summer Rose"] = {
        [1] = "RoseGuilds/icons/admin/tell.dds",
        [2] = "RoseGuilds/icons/admin/tell.dds",
        [3] = "RoseGuilds/icons/admin/tell.dds",
        [4] = "RoseGuilds/icons/admin/tell.dds",
        [5] = "RoseGuilds/icons/base/summerrg.dds",
        [6] = "RoseGuilds/icons/base/summerdiamond.dds",
        [7] = "RoseGuilds/icons/base/summer.dds",
        [8] = "RoseGuilds/icons/base/necro.dds",
        [9] = "RoseGuilds/icons/base/whiterose.dds",
        [10] = "RoseGuilds/icons/base/baserose.dds",
    },
    ["Winter Rose"] = {
        [1] = "RoseGuilds/icons/admin/tell.dds",
        [2] = "RoseGuilds/icons/admin/tell.dds",
        [3] = "RoseGuilds/icons/admin/tell.dds",
        [4] = "RoseGuilds/icons/admin/tell.dds",
        [5] = "RoseGuilds/icons/base/winterrg.dds",
        [6] = "RoseGuilds/icons/base/winterdiamond.dds",
        [7] = "RoseGuilds/icons/base/winter.dds",
        [8] = "RoseGuilds/icons/base/necro.dds",
        [9] = "RoseGuilds/icons/base/whiterose.dds",
        [10] = "RoseGuilds/icons/base/baserose.dds",
    },
    ["Spring Rose"] = {
        [1] = "RoseGuilds/icons/admin/tell.dds",
        [2] = "RoseGuilds/icons/admin/tell.dds",
        [3] = "RoseGuilds/icons/admin/tell.dds",
        [4] = "RoseGuilds/icons/admin/tell.dds",
        [5] = "RoseGuilds/icons/base/springrg.dds",
        [6] = "RoseGuilds/icons/base/springdiamond.dds",
        [7] = "RoseGuilds/icons/base/spring.dds",
        [8] = "RoseGuilds/icons/base/necro.dds",
        [9] = "RoseGuilds/icons/base/whiterose.dds",
        [10] = "RoseGuilds/icons/base/baserose.dds",
    },
    ["Autumn Rose"] = {        
        [1] = "RoseGuilds/icons/admin/tell.dds",
        [2] = "RoseGuilds/icons/admin/tell.dds",
        [3] = "RoseGuilds/icons/admin/tell.dds",
        [4] = "RoseGuilds/icons/admin/tell.dds",
        [5] = "RoseGuilds/icons/base/autumnrg.dds",
        [6] = "RoseGuilds/icons/base/autumndiamond.dds",
        [7] = "RoseGuilds/icons/base/autumn.dds",
        [8] = "RoseGuilds/icons/base/necro.dds",
        [9] = "RoseGuilds/icons/base/whiterose.dds",
        [10] = "RoseGuilds/icons/base/baserose.dds",
    },
}

--Guild Roster
local function HookGuildRoster()
    local setupEntry = GUILD_ROSTER_MANAGER.SetupEntry
    function GUILD_ROSTER_MANAGER:SetupEntry(control, data, selected)
        setupEntry(self, control, data, selected)
        
        local guildId = GUILD_ROSTER_MANAGER.guildId
        local guildName = GetGuildName and GetGuildName(guildId) or nil
        if guildName and ALLOWED_GUILD_NAMES[guildName] then
            local iconPath = ResolveBestIconPath(data.displayName, guildName, data.rankIndex)
            if not iconPath then
                iconPath = DEFAULT_ICON_PATH
            end
            SetRowIcon(control, "StatusIcon", iconPath, data.status)
        else
            HideRowIcon(control, "StatusIcon")
        end
    end
end

-- Friends List
local function HookFriendsList()
    local setupEntry = FRIENDS_LIST_MANAGER.SetupEntry
    function FRIENDS_LIST_MANAGER:SetupEntry(control, data, selected)
        setupEntry(self, control, data, selected)

        if not displayNameGuildRank[data.displayName] then
            HideRowIcon(control, "StatusIcon")
            return
        end

        local iconPath = ResolveBestIconPath(data.displayName)
        if iconPath then
            SetRowIcon(control, "StatusIcon", iconPath, data.status)
        else
            HideRowIcon(control, "StatusIcon")
        end
    end
end

-- Group Window
local function HookGroupWindow()
    local setupEntry = GROUP_LIST.SetupGroupEntry
    function GROUP_LIST:SetupGroupEntry(control, data)
        setupEntry(self, control, data)

        if not displayNameGuildRank[data.displayName] then
            HideRowIcon(control, "leaderIcon")
            return
        end

        local iconPath = ResolveBestIconPath(data.displayName)
        if iconPath then
            SetRowIcon(control, "leaderIcon", iconPath, data.status)
        else
            HideRowIcon(control, "leaderIcon")
        end
    end
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= "RoseGuilds" then return end
    HookGuildRoster()
    HookFriendsList()
    HookGroupWindow()
    PrepareDisplayNameTable()
    EVENT_MANAGER:UnregisterForEvent("RoseGuildsRowIcons", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("RoseGuildsRowIcons", EVENT_ADD_ON_LOADED, OnAddonLoaded)


-- Chat Hook
local function GetDefaultGuildIcon(displayName)
    local guildInfo = displayNameGuildRank[displayName]
    if not guildInfo then
        return nil
    end

    local guildIcon = GetGuildRankIconCandidate(displayName, guildInfo.guildName, guildInfo.rankIndex)
    if guildIcon then
        return guildIcon.texturePath
    end

    return DEFAULT_ICON_PATH
end

local function BuildDisplayNameTable()
    displayNameTable[zo_strformat(SI_UNIT_NAME, GetUnitName("player"))] = GetDisplayName()

    local guilds = GetNumGuilds()
    for i = 1, guilds do
        local id = GetGuildId(i)
        local guildName = GetGuildName and GetGuildName(id) or nil
        local members = GetNumGuildMembers(id)
        for j = 1, members do
            local displayName, _, rankIndex = GetGuildMemberInfo(id, j)
            local hasChar, name = GetGuildMemberCharacterInfo(id, j)
            if hasChar and name then
                displayNameTable[zo_strformat(SI_UNIT_NAME, name)] = displayName
            end
            if guildName and ALLOWED_GUILD_NAMES[guildName] and displayName and rankIndex then
                displayNameGuildRank[displayName] = { guildName = guildName, rankIndex = rankIndex }
            end
        end
    end

    local friends = GetNumFriends()
    for i = 1, friends do
        local displayName = GetFriendInfo(i)
        local hasChar, name = GetFriendCharacterInfo(i)
        if hasChar and name then
            displayNameTable[zo_strformat(SI_UNIT_NAME, name)] = displayName
        end
    end

    for i = 1, GROUP_SIZE_MAX do
        local unit = "group" .. i
        local name = GetUnitName(unit)
        local displayName = GetUnitDisplayName(unit)
        if name and displayName then
            displayNameTable[zo_strformat(SI_UNIT_NAME, name)] = displayName
        end
    end
end

function PrepareDisplayNameTable()
    if displayNamesPrepared then
        return
    end
    displayNamesPrepared = true

    BuildDisplayNameTable()

    EVENT_MANAGER:RegisterForEvent("RoseGuilds_DisplayNames_Guild", EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, function(_, id, displayName)
        local guildName = GetGuildName and GetGuildName(id) or nil
        local members = GetNumGuildMembers(id)
        for i = 1, members do
            local memberDisplayName, _, rankIndex = GetGuildMemberInfo(id, i)
            if displayName == memberDisplayName then
                local hasChar, name = GetGuildMemberCharacterInfo(id, i)
                if hasChar and name then
                    displayNameTable[zo_strformat(SI_UNIT_NAME, name)] = displayName
                end
                if guildName and ALLOWED_GUILD_NAMES[guildName] and rankIndex then
                    displayNameGuildRank[displayName] = { guildName = guildName, rankIndex = rankIndex }
                end
                break
            end
        end
    end)

    EVENT_MANAGER:RegisterForEvent("RoseGuilds_DisplayNames_GuildRank", EVENT_GUILD_MEMBER_RANK_CHANGED, function(_, id, displayName)
        local guildName = GetGuildName and GetGuildName(id) or nil
        if not guildName or not ALLOWED_GUILD_NAMES[guildName] or not displayName then
            return
        end

        local members = GetNumGuildMembers(id)
        for i = 1, members do
            local memberDisplayName, _, rankIndex = GetGuildMemberInfo(id, i)
            if displayName == memberDisplayName and rankIndex then
                displayNameGuildRank[displayName] = { guildName = guildName, rankIndex = rankIndex }
                break
            end
        end
    end)

    EVENT_MANAGER:RegisterForEvent("RoseGuilds_DisplayNames_Friends", EVENT_FRIEND_PLAYER_STATUS_CHANGED, function(_, displayName, name)
        displayNameTable[zo_strformat(SI_UNIT_NAME, name)] = displayName
    end)

    EVENT_MANAGER:RegisterForEvent("RoseGuilds_DisplayNames_Group", EVENT_GROUP_MEMBER_JOINED, function(_, name, displayName)
        if displayName == GetDisplayName() then
            BuildDisplayNameTable()
        else
            displayNameTable[zo_strformat(SI_UNIT_NAME, name)] = displayName
        end
    end)
end

local function SetupChatHook()
    if not SharedChatContainer then
        return false
    end

    PrepareDisplayNameTable()
    
    local addwin = SharedChatContainer.AddWindow
    SharedChatContainer.AddWindow = function(...)
        local window = addwin(...)
        local buffer = window.buffer
        local addmsg = buffer.AddMessage
        
        buffer.AddMessage = function(self, message, ...)
            if not message or #message == 0 then
                return addmsg(self, message, ...)
            end
            
            local tag = nil
            local i, j = nil, nil
            
            i, j = message:find("|H%d:display:.-|h", 1)
            if i then
                tag = message:sub(i + 12, j - 2)
                if not tag:find("@") then
                    tag = "@" .. tag
                end
            else
                i, j = message:find("|H%d:character:.-|h", 1)
                if i then
                    local charName = zo_strformat(SI_UNIT_NAME, message:sub(i + 14, j - 2))
                    tag = displayNameTable[charName]
                end
            end
            
            if tag then
                local icon = ResolveBestIconPath(tag)
                if not icon then
                    icon = GetDefaultGuildIcon(tag)
                end
                if icon then
                    local prefix = message:sub(1, i - 1)
                    while true do
                        local updated, count = prefix:gsub("|t%d+:%d+:[^|]+|t%s*$", "")
                        if count == 0 then
                            break
                        end
                        prefix = updated
                    end
                    message = prefix .. "|t23:23:" .. icon .. "|t" .. message:sub(i)
                end
            end
            
            addmsg(self, message, ...)
        end
        
        return window
    end
    
    return true
end

local function TrySetupChatHook()
    if not SetupChatHook() then
        zo_callLater(TrySetupChatHook, 100)
    end
end

TrySetupChatHook()


-- Map pins - Conflicts with ody/lci 
local GROUP_DEFAULT_ICON_PATH = "RoseGuilds/icons/base/whiterose.dds"
local groupGuildRankCache = {}
local groupCacheReady = false

local function BuildGroupGuildRankCache()
    groupGuildRankCache = {}

    local guilds = GetNumGuilds and GetNumGuilds() or 0
    for i = 1, guilds do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)
        local guildIcons = guildName and GUILD_RANK_ICONS[guildName] or nil

        if guildIcons then
            local members = GetNumGuildMembers(guildId)
            for j = 1, members do
                local displayName, _, rankIndex = GetGuildMemberInfo(guildId, j)
                if displayName and rankIndex then
                    groupGuildRankCache[displayName] = {
                        texturePath = guildIcons[rankIndex] or GROUP_DEFAULT_ICON_PATH,
                        priority = GetGuildRankPriority(rankIndex) or 0,
                    }
                end
            end
        end
    end

    groupCacheReady = true
end

local function EnsureGroupGuildRankCache()
    if not groupCacheReady then
        BuildGroupGuildRankCache()
    end
end

local function InvalidateGroupGuildRankCache()
    groupCacheReady = false
end

local function GetGroupDisplayNameFromPinTag(pinTag)
    if not pinTag then
        return nil
    end

    if type(pinTag) == "table" then
        local unitTag = pinTag.unitTag or pinTag.tag or pinTag.m_UnitTag or pinTag.unit
        if unitTag and type(unitTag) == "string" then
            return GetUnitDisplayName(unitTag)
        end

        local displayName = pinTag.displayName or pinTag.name or pinTag.m_DisplayName
        if displayName and type(displayName) == "string" then
            return displayName
        end

        local idx = pinTag.index or pinTag.groupIndex or pinTag.memberIndex
        if idx and type(idx) == "number" then
            local groupTag = "group" .. tostring(idx)
            return GetUnitDisplayName(groupTag)
        end
    end

    if type(pinTag) == "string" then
        if pinTag:find("^group") or pinTag == "player" then
            return GetUnitDisplayName(pinTag)
        end
        if pinTag:find("^@") then
            return pinTag
        end
    end

    return nil
end

local function ResolveGroupIconPath(displayName)
    if not displayName or displayName == "" then
        return nil
    end

    EnsureGroupGuildRankCache()
    return GetHighestPriorityIcon({
        GetIconCandidate(GetExternalIconPath(displayName), EXTERNAL_ICON_PRIORITY),
        GetManualIconCandidate(displayName),
        groupGuildRankCache[displayName],
    })
end

local function FindGroupTextureControl(control)
    if not control then
        return nil
    end

    if control.SetTexture then
        return control
    end

    if control.GetNamedChild then
        local candidates = { "Icon", "icon", "Pin", "pin", "Background", "background" }
        for i = 1, #candidates do
            local child = control:GetNamedChild(candidates[i])
            if child and child.SetTexture then
                return child
            end
        end
    end

    return nil
end

local function SetGroupPinTexture(pin, iconPath)
    if not pin or not iconPath then
        return
    end

    local control = nil
    if type(pin.GetControl) == "function" then
        control = pin:GetControl()
    elseif pin.m_Control then
        control = pin.m_Control
    elseif pin.m_Pin then
        control = pin.m_Pin
    elseif pin.control then
        control = pin.control
    end

    if not control then
        return
    end

    local textureControl = FindGroupTextureControl(control)
    if textureControl and textureControl.SetTexture then
        textureControl:SetTexture(iconPath)
    end
end

local groupPinTypes = {}
if MAP_PIN_TYPE_GROUP then
    groupPinTypes[MAP_PIN_TYPE_GROUP] = true
end
if MAP_PIN_TYPE_GROUP_LEADER then
    groupPinTypes[MAP_PIN_TYPE_GROUP_LEADER] = true
end
if MAP_PIN_TYPE_GROUP_MEMBER then
    groupPinTypes[MAP_PIN_TYPE_GROUP_MEMBER] = true
end

local function IsGroupPinType(pinType)
    return groupPinTypes[pinType] == true
end

local function ApplyGroupPinIcon(pin, pinTag)
    local displayName = GetGroupDisplayNameFromPinTag(pinTag)
    if not displayName or displayName == "" then
        return
    end
    
    local iconPath = ResolveGroupIconPath(displayName)
    if iconPath then
        SetGroupPinTexture(pin, iconPath)
    end
end

local function HookWorldMapPins()
    if not ZO_WorldMapPins then
        return false
    end

    local createPin = ZO_WorldMapPins.CreatePin
    if type(createPin) ~= "function" then
        return false
    end

    ZO_WorldMapPins.RoseGuildsOriginalCreatePin = createPin

    ZO_WorldMapPins.CreatePin = function(self, pinType, pinTag, ...)
        local originalCreatePin = ZO_WorldMapPins.RoseGuildsOriginalCreatePin or createPin
        local pin = originalCreatePin(self, pinType, pinTag, ...)
        if pin and IsGroupPinType(pinType) then
            ApplyGroupPinIcon(pin, pinTag)
        end
        return pin
    end

    return true
end

local function RefreshGroupPins()
    if ZO_WorldMapPins then
        if ZO_WorldMapPins.RefreshGroupPins then
            ZO_WorldMapPins:RefreshGroupPins()
        end
        if ZO_WorldMapPins.RefreshVisibleMapPins then
            ZO_WorldMapPins:RefreshVisibleMapPins()
        end
        if ZO_WorldMapPins.m_PinManager and ZO_WorldMapPins.m_PinManager.RefreshAllPins then
            ZO_WorldMapPins.m_PinManager:RefreshAllPins()
        end
    end
end

local function TryRefreshGroupPins()
    if not ZO_WorldMapPins or not ZO_WorldMapPins.m_PinManager then
        zo_callLater(TryRefreshGroupPins, 500)
        return
    end

    local ok = pcall(RefreshGroupPins)
    if not ok then
        zo_callLater(TryRefreshGroupPins, 500)
    end
end

local function SetupGroupMapHooks()
    local worldHooked = HookWorldMapPins()
    
    if worldHooked then
        zo_callLater(TryRefreshGroupPins, 500)
    end
end

local function OnAddonLoadedGroupPins(_, addonName)
    if addonName ~= "RoseGuilds" then
        return
    end

    BuildGroupGuildRankCache()

    EVENT_MANAGER:RegisterForEvent("RoseGuilds_GroupPins_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        SetupGroupMapHooks()
        EVENT_MANAGER:UnregisterForEvent("RoseGuilds_GroupPins_PlayerActivated", EVENT_PLAYER_ACTIVATED)
    end)

    EVENT_MANAGER:RegisterForEvent("RoseGuilds_GroupPins_MemberJoined", EVENT_GROUP_MEMBER_JOINED, function()
        zo_callLater(TryRefreshGroupPins, 100)
    end)
    
    EVENT_MANAGER:RegisterForEvent("RoseGuilds_GroupPins_MemberLeft", EVENT_GROUP_MEMBER_LEFT, function()
        zo_callLater(TryRefreshGroupPins, 100)
    end)

    EVENT_MANAGER:RegisterForEvent("RoseGuilds_GroupPins_GuildAdd", EVENT_GUILD_MEMBER_ADDED, InvalidateGroupGuildRankCache)
    EVENT_MANAGER:RegisterForEvent("RoseGuilds_GroupPins_GuildRemove", EVENT_GUILD_MEMBER_REMOVED, InvalidateGroupGuildRankCache)
    EVENT_MANAGER:RegisterForEvent("RoseGuilds_GroupPins_GuildRank", EVENT_GUILD_MEMBER_RANK_CHANGED, InvalidateGroupGuildRankCache)

    EVENT_MANAGER:UnregisterForEvent("RoseGuilds_GroupPins_Load", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("RoseGuilds_GroupPins_Load", EVENT_ADD_ON_LOADED, OnAddonLoadedGroupPins)


-- Overhead Icons
local RG_Overhead = {}
local iconPool = {}
local unitLUT = {}

local function CreateOverheadIcon(name, size)
    local win = RG_Overhead.win
    local icon = WINDOW_MANAGER:GetControlByName(name)
    if not icon then
        icon = WINDOW_MANAGER:CreateControl(name, win, CT_TEXTURE)
    end
    icon:ClearAnchors()
    icon:SetAnchor(BOTTOM, win, CENTER, 0, 0)
    icon:SetDimensions(size, size)
    icon:SetPixelRoundingEnabled(false)
    icon:SetHidden(true)

    return {
        use = false,
        name = nil,
        tex = nil,
        ctrl = icon,
    }
end

local function GetUnusedOverheadIcon(name)
    for i = 1, GROUP_SIZE_MAX do
        local icon = iconPool[i]
        if not icon.use then
            icon.name = name
            icon.use = true
            return icon
        end
    end
    return nil
end

local function GetOverheadSettings()
    local RG = _G["RoseGuilds"]
    if RG and RG.savedVars then
        return {
            enabled = RG.savedVars.IconAboveHeadVisible ~= false,
            size = RG.savedVars.IconAboveHeadSize or 64,
            showPlayerIcon = RG.savedVars.IconAboveHeadShowPlayer ~= false,
            groupOnly = RG.savedVars.IconAboveHeadGroupOnly == true,
            offset = RG.savedVars.IconAboveHeadOffset or 3.2,
        }
    end
    return {
        enabled = true,
        size = 64,
        showPlayerIcon = true,
        groupOnly = false,
        offset = 3.2,
    }
end

local function ResetOverheadIcons()
    local settings = GetOverheadSettings()
    local unitTable = {}
    
    for i = 1, GROUP_SIZE_MAX do
        local name = GetUnitDisplayName("group" .. i)
        if name and name ~= "" then
            unitTable[name] = true
        end
        iconPool[i].ctrl:SetHidden(true)
    end

    for unit, icon in pairs(unitLUT) do
        if not unitTable[unit] then
            icon.use = false
            icon.ctrl:SetHidden(true)
        end
    end

    for unit, _ in pairs(unitTable) do
        unitTable[unit] = unitLUT[unit] or GetUnusedOverheadIcon(unit)
    end

    local playerName = GetUnitDisplayName("player")
    if playerName and playerName ~= "" then
        if settings.showPlayerIcon then
            unitTable[playerName] = unitLUT[playerName] or GetUnusedOverheadIcon(playerName)
        else
            unitTable[playerName] = nil
            if unitLUT[playerName] then
                unitLUT[playerName].use = false
                unitLUT[playerName].ctrl:SetHidden(true)
            end
        end
    end

    unitLUT = unitTable
end

local function OnOverheadUpdate()
    local settings = GetOverheadSettings()

    if not settings.enabled then
        ResetOverheadIcons()
        return
    end

    -- Check group setting and if player is grouped
    if settings.groupOnly and not IsUnitGrouped("player") then
        ResetOverheadIcons()
        return
    end

    ResetOverheadIcons()

    Set3DRenderSpaceToCurrentCamera(RG_Overhead.ctrl:GetName())

    -- Get player position
    local playerZone, playerX, playerY, playerZ = GetUnitRawWorldPosition("player")

    local cX, cY, cZ = GuiRender3DPositionToWorldPosition(RG_Overhead.ctrl:Get3DRenderSpaceOrigin())
    local fX, fY, fZ = RG_Overhead.ctrl:Get3DRenderSpaceForward()
    local rX, rY, rZ = RG_Overhead.ctrl:Get3DRenderSpaceRight()
    local uX, uY, uZ = RG_Overhead.ctrl:Get3DRenderSpaceUp()

    local i11 = -(uY * fZ - uZ * fY)
    local i12 = -(rZ * fY - rY * fZ)
    local i13 = -(rY * uZ - rZ * uY)
    local i21 = -(uZ * fX - uX * fZ)
    local i22 = -(rX * fZ - rZ * fX)
    local i23 = -(rZ * uX - rX * uZ)
    local i31 = -(uX * fY - uY * fX)
    local i32 = -(rY * fX - rX * fY)
    local i33 = -(rX * uY - rY * uX)
    local i41 = -(uZ * fY * cX + uY * fX * cZ + uX * fZ * cY - uX * fY * cZ - uY * fZ * cX - uZ * fX * cY)
    local i42 = -(rX * fY * cZ + rY * fZ * cX + rZ * fX * cY - rZ * fY * cX - rY * fX * cZ - rX * fZ * cY)
    local i43 = -(rZ * uY * cX + rY * uX * cZ + rX * uZ * cY - rX * uY * cZ - rY * uZ * cX - rZ * uX * cY)

    local uiW, uiH = GuiRoot:GetDimensions()
    local size = settings.size
    local offset = settings.offset

    local unitTags = { "player" }
    for i = 1, GROUP_SIZE_MAX do
        table.insert(unitTags, "group" .. i)
    end

    for _, unitTag in ipairs(unitTags) do
        if DoesUnitExist(unitTag) then
            local displayName = GetUnitDisplayName(unitTag)
            if displayName and displayName ~= "" then
                local icon = unitLUT[displayName]

                if icon then
                    -- avoid double icons if Ody has an icon set
                    local externalIcon = GetExternalIconPath(displayName)
                    if externalIcon then
                        icon.ctrl:SetHidden(true)
                    else
                        local zone, wX, wY, wZ = GetUnitRawWorldPosition(unitTag)
                        wY = wY + offset * 100

                        local pX = wX * i11 + wY * i21 + wZ * i31 + i41
                        local pY = wX * i12 + wY * i22 + wZ * i32 + i42
                        local pZ = wX * i13 + wY * i23 + wZ * i33 + i43

                        if pZ > 0 then
                            local iconPath = ResolveGroupIconPath(displayName)

                        if iconPath then
                            local w, h = GetWorldDimensionsOfViewFrustumAtDepth(pZ)
                            local x, y = pX * uiW / w, -pY * uiH / h

                            local dX, dY, dZ = wX - cX, wY - cY, wZ - cZ
                            local dist = 1 + math.sqrt(dX * dX + dY * dY + dZ * dZ)

                            local ctrl = icon.ctrl
                            ctrl:ClearAnchors()
                            ctrl:SetAnchor(BOTTOM, RG_Overhead.win, CENTER, x, y)

                            if icon.tex ~= iconPath then
                                ctrl:SetTexture(iconPath)
                                icon.tex = iconPath
                            end

                            ctrl:SetDimensions(size, size)
                            ctrl:SetScale(1000 / dist)
                            ctrl:SetHidden(false)
                        end
                    end
                    end
                end
            end
        end
    end
end

local function OnAddonLoadedOverhead(_, addonName)
    if addonName ~= "RoseGuilds" then
        return
    end

    if RG_Overhead.ctrl then
        return
    end

    RG_Overhead.ctrl = WINDOW_MANAGER:GetControlByName("RoseGuilds_OverheadCtrl")
    if not RG_Overhead.ctrl then
        RG_Overhead.ctrl = WINDOW_MANAGER:CreateControl("RoseGuilds_OverheadCtrl", GuiRoot, CT_CONTROL)
        RG_Overhead.ctrl:SetAnchorFill(GuiRoot)
        RG_Overhead.ctrl:Create3DRenderSpace()
    end
    RG_Overhead.ctrl:SetHidden(true)

    RG_Overhead.win = WINDOW_MANAGER:GetControlByName("RoseGuilds_OverheadWin")
    if not RG_Overhead.win then
        RG_Overhead.win = WINDOW_MANAGER:CreateTopLevelWindow("RoseGuilds_OverheadWin")
        RG_Overhead.win:SetAnchorFill(GuiRoot)
    end

    EVENT_MANAGER:RegisterForUpdate("RoseGuilds_Overhead_Update", 25, OnOverheadUpdate)

    _G["RoseGuilds_ToggleOverheadIcons"] = function(enabled)
        local RG = _G["RoseGuilds"]
        if RG and RG.savedVars then
            RG.savedVars.IconAboveHeadVisible = enabled
        end
    end

    _G["RoseGuilds_TogglePlayerOverheadIcon"] = function(enabled)
        local RG = _G["RoseGuilds"]
        if RG and RG.savedVars then
            RG.savedVars.IconAboveHeadShowPlayer = enabled
        end
    end

    _G["RoseGuilds_SetOverheadIconSize"] = function(size)
        local RG = _G["RoseGuilds"]
        if RG and RG.savedVars then
            RG.savedVars.IconAboveHeadSize = size
            for i = 1, GROUP_SIZE_MAX do
                if iconPool[i] then
                    iconPool[i].ctrl:SetDimensions(size, size)
                end
            end
        end
    end
    local frag = ZO_HUDFadeSceneFragment:New(RG_Overhead.win)
    HUD_UI_SCENE:AddFragment(frag)
    HUD_SCENE:AddFragment(frag)
    LOOT_SCENE:AddFragment(frag)

    settings = GetOverheadSettings()
    for i = 1, GROUP_SIZE_MAX do
        iconPool[i] = CreateOverheadIcon("RoseGuilds_3DIcon" .. i, settings.size)
    end

    -- Hopefully fix the icons not showing for new group joins
    local function RefreshOnGroup(eventCode)
        if eventCode == EVENT_GROUP_MEMBER_JOINED or eventCode == EVENT_GROUP_MEMBER_LEFT then
            ResetOverheadIcons()
        end
    end

    EVENT_MANAGER:RegisterForEvent("RoseGuilds_Overhead_MemberJoined", EVENT_GROUP_MEMBER_JOINED, RefreshOnGroup)
    EVENT_MANAGER:RegisterForEvent("RoseGuilds_Overhead_MemberLeft", EVENT_GROUP_MEMBER_LEFT, RefreshOnGroup)
	EVENT_MANAGER:RegisterForEvent("RoseGuilds_Overhead_GroupUpdate", EVENT_GROUP_UPDATE, RefreshOnGroup)
    EVENT_MANAGER:RegisterForEvent("RoseGuilds_Overhead_MemberZoneChanged", EVENT_GROUP_MEMBER_ZONE_CHANGED, RefreshOnGroup)
    EVENT_MANAGER:RegisterForEvent("RoseGuilds_Overhead_ZoneChanged", EVENT_ZONE_CHANGED, RefreshOnGroup)
    EVENT_MANAGER:RegisterForEvent("RoseGuilds_Overhead_PlayerActivated", EVENT_PLAYER_ACTIVATED, RefreshOnGroup)

    EVENT_MANAGER:RegisterForEvent("RoseGuilds_Overhead_GuildAdd", EVENT_GUILD_MEMBER_ADDED, InvalidateGroupGuildRankCache)
    EVENT_MANAGER:RegisterForEvent("RoseGuilds_Overhead_GuildRemove", EVENT_GUILD_MEMBER_REMOVED, InvalidateGroupGuildRankCache)
    EVENT_MANAGER:RegisterForEvent("RoseGuilds_Overhead_GuildRank", EVENT_GUILD_MEMBER_RANK_CHANGED, InvalidateGroupGuildRankCache)

    EVENT_MANAGER:UnregisterForEvent("RoseGuilds_Overhead_Load", EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("RoseGuilds_Overhead_Load", EVENT_ADD_ON_LOADED, OnAddonLoadedOverhead)
