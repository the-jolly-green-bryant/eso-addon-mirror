--------------------------------------------------
-- ChatTravel
-- Adds a "Travel To" keybind to the gamepad chat
-- player menu. Works for friends, guildmates, and
-- group members only -- the same restriction the
-- game itself enforces on JumpToFriend /
-- JumpToGuildMember / JumpToGroupMember.
--
-- No external libraries. No settings. Hardcoded,
-- same as the rest of my addons.
--------------------------------------------------

ChatTravel = {}
ChatTravel.name = "ChatTravel"

--------------------------------------------------
-- Eligibility checks
--------------------------------------------------
-- These read CHAT_MENU_GAMEPAD.socialData, which the
-- game itself populates when you highlight a player
-- link in chat and the menu opens.

-- Instead of trusting a cached copy of the target (which can go stale
-- whenever something -- like subtitles -- doesn't route through our
-- OnTargetChanged hook), ask the game for the live target every time.
-- This is the exact same call the official chat menu code itself uses.
local function GetLiveSocialData()
    local list = CHAT_MENU_GAMEPAD.list
    if not list then return nil end

    local ok, targetData = pcall(function() return list:GetTargetData() end)
    if not ok or not targetData then return nil end

    local entry = targetData.data or targetData
    if not entry or not entry.fromDisplayName then return nil end

    return {
        displayName   = entry.fromDisplayName,
        category      = entry.category,
        targetChannel = entry.targetChannel,
    }
end

local function IsCurrentGroupMember(displayName)
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if tag and GetUnitDisplayName(tag) == displayName then
            return true
        end
    end
    return false
end

local function IsFriendJumpable()
    local data = GetLiveSocialData()
    if not data or not data.displayName then return false end
    return IsFriend(data.displayName)
end

local function IsGroupJumpable()
    if IsFriendJumpable() then return false end
    local data = GetLiveSocialData()
    if not data or not data.category then return false end
    return data.category == CHAT_CATEGORY_PARTY
        and IsCurrentGroupMember(data.displayName)
end

local function IsGuildJumpable()
    if IsFriendJumpable() then return false end
    local data = GetLiveSocialData()
    if not data or not data.category then return false end
    local cat = data.category
    return cat == CHAT_CATEGORY_GUILD_1   or cat == CHAT_CATEGORY_GUILD_2   or
           cat == CHAT_CATEGORY_GUILD_3   or cat == CHAT_CATEGORY_GUILD_4   or
           cat == CHAT_CATEGORY_GUILD_5   or
           cat == CHAT_CATEGORY_OFFICER_1 or cat == CHAT_CATEGORY_OFFICER_2 or
           cat == CHAT_CATEGORY_OFFICER_3 or cat == CHAT_CATEGORY_OFFICER_4 or
           cat == CHAT_CATEGORY_OFFICER_5
end

local function IsTypingInChat()
    local focalArea = CHAT_MENU_GAMEPAD.chatEntryPanelFocalArea
    if not focalArea then return false end
    return not focalArea:IsFocused()
end

local function IsAnyJumpable()
    if IsTypingInChat() then return false end
    if not GetLiveSocialData() then return false end
    return IsFriendJumpable() or IsGuildJumpable() or IsGroupJumpable()
end

--------------------------------------------------
-- The actual travel attempt
--------------------------------------------------
-- Fires the right JumpTo___ call, then watches real
-- game events to know whether it actually worked --
-- rather than assuming success the instant it's called.

local activeCancel = nil
local attemptId = 0

local function FireJump(displayName, isGroup, isFriend, isGuild)
    if isGroup then
        JumpToGroupMember(displayName)
    elseif isFriend then
        JumpToFriend(displayName)
    elseif isGuild then
        JumpToGuildMember(displayName)
    end
end

local function AttemptTravel(displayName, isGroup, isFriend, isGuild)
    if activeCancel then activeCancel() end
    attemptId = attemptId + 1
    local id = attemptId

    local prepareName = "ChatTravel_Prepare_" .. id
    local activName   = "ChatTravel_Activ_"   .. id
    local deactivName = "ChatTravel_Deactiv_" .. id
    local socialName  = "ChatTravel_Social_"  .. id

    local done = false
    local cancel

    local function cleanup()
        EVENT_MANAGER:UnregisterForEvent(prepareName, EVENT_PREPARE_FOR_JUMP)
        EVENT_MANAGER:UnregisterForEvent(activName,   EVENT_PLAYER_ACTIVATED)
        EVENT_MANAGER:UnregisterForEvent(deactivName, EVENT_PLAYER_DEACTIVATED)
        EVENT_MANAGER:UnregisterForEvent(socialName,  EVENT_SOCIAL_ERROR)
        if activeCancel == cancel then activeCancel = nil end
    end

    cancel = function()
        done = true
        cleanup()
    end
    activeCancel = cancel

    -- Success: the jump actually committed.
    EVENT_MANAGER:RegisterForEvent(prepareName, EVENT_PREPARE_FOR_JUMP, function()
        if done then return end
        done = true
        cleanup()
    end)

    -- Defensive backup in case the client skips EVENT_PREPARE_FOR_JUMP.
    EVENT_MANAGER:RegisterForEvent(activName, EVENT_PLAYER_ACTIVATED, function()
        if done then return end
        done = true
        cleanup()
    end)

    EVENT_MANAGER:RegisterForEvent(deactivName, EVENT_PLAYER_DEACTIVATED, function()
        if done then return end
        done = true
        cleanup()
    end)

    -- Failure: the game rejected the request (player unavailable,
    -- can't afford the recall fee, too far, etc.)
    EVENT_MANAGER:RegisterForEvent(socialName, EVENT_SOCIAL_ERROR, function(_, errorCode)
        if done then return end
        done = true
        cleanup()
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK,
            string.format("Could not travel to %s.", displayName))
    end)

    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, string.format("Traveling to %s...", displayName))
    FireJump(displayName, isGroup, isFriend, isGuild)
end

--------------------------------------------------
-- Chat menu keybind hook
--------------------------------------------------

local CHAT_TRAVEL_KEYBIND_DESCRIPTOR = nil
local keybindBuilt = false

local function BuildKeybindDescriptor()
    CHAT_TRAVEL_KEYBIND_DESCRIPTOR = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        {
            name = "Travel To",
            keybind = "UI_SHORTCUT_QUINARY",
            order = 10000,
            enabled = function()
                return IsAnyJumpable()
                    and CanLeaveCurrentLocationViaTeleport()
                    and not IsUnitDead("player")
            end,
            visible = function() return IsAnyJumpable() end,
            callback = function()
                local data = GetLiveSocialData()
                if not data or not IsAnyJumpable() then
                    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "No valid travel target.")
                    return
                end
                local displayName = data.displayName
                local isGroup  = IsGroupJumpable()
                local isFriend = IsFriendJumpable()
                local isGuild  = IsGuildJumpable()
                AttemptTravel(displayName, isGroup, isFriend, isGuild)
                SCENE_MANAGER:ShowBaseScene()
            end,
        },
    }
end

local REFRESH_TIMER_NAME = "ChatTravel_RefreshTimer"

local function OnChatMenuShow()
    if not keybindBuilt then
        keybindBuilt = true
        BuildKeybindDescriptor()
    end
    KEYBIND_STRIP:AddKeybindButtonGroup(CHAT_TRAVEL_KEYBIND_DESCRIPTOR)
    KEYBIND_STRIP:UpdateKeybindButtonGroup(CHAT_TRAVEL_KEYBIND_DESCRIPTOR)

    EVENT_MANAGER:RegisterForUpdate(REFRESH_TIMER_NAME, 150, function()
        KEYBIND_STRIP:UpdateKeybindButtonGroup(CHAT_TRAVEL_KEYBIND_DESCRIPTOR)
    end)
end

local function OnChatMenuHide()
    EVENT_MANAGER:UnregisterForUpdate(REFRESH_TIMER_NAME)
    if CHAT_TRAVEL_KEYBIND_DESCRIPTOR then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(CHAT_TRAVEL_KEYBIND_DESCRIPTOR)
    end
end

--------------------------------------------------
-- Addon Loaded
--------------------------------------------------

local function OnAddonLoaded(event, addonName)
    if addonName ~= ChatTravel.name then return end
    EVENT_MANAGER:UnregisterForEvent(ChatTravel.name, EVENT_ADD_ON_LOADED)

    if CHAT_MENU_GAMEPAD then
        ZO_PreHook(CHAT_MENU_GAMEPAD, "OnShow", OnChatMenuShow)
        ZO_PreHook(CHAT_MENU_GAMEPAD, "OnHide", OnChatMenuHide)
    end
end

EVENT_MANAGER:RegisterForEvent(ChatTravel.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
