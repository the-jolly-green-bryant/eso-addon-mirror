local CT = ControllerTweaks

local Chat = CT_Plugin:Subclass()

local function BuildJumpToFriend()
    return CHAT_MENU_GAMEPAD:BuildOptionEntry(nil, 
            GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER), 
            function() JumpToFriend(CHAT_MENU_GAMEPAD.socialData.displayName) end)
end

local function IsFriendJumpable()
    return IsFriend(CHAT_MENU_GAMEPAD.socialData.displayName)
end

local function BuildJumpToGuildMember()
    if IsFriendJumpable() then return false end

    return CHAT_MENU_GAMEPAD:BuildOptionEntry(nil, 
            GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER), 
            function() JumpToGuildMember(CHAT_MENU_GAMEPAD.socialData.displayName) end)
end

local function IsGuildJumpable()
    if CHAT_MENU_GAMEPAD.socialData.category == CHAT_CATEGORY_GUILD_1 or
        CHAT_MENU_GAMEPAD.socialData.category == CHAT_CATEGORY_GUILD_2 or
        CHAT_MENU_GAMEPAD.socialData.category == CHAT_CATEGORY_GUILD_3 or
        CHAT_MENU_GAMEPAD.socialData.category == CHAT_CATEGORY_GUILD_4 or
        CHAT_MENU_GAMEPAD.socialData.category == CHAT_CATEGORY_GUILD_5 or
        CHAT_MENU_GAMEPAD.socialData.category == CHAT_CATEGORY_OFFICER_1 or
        CHAT_MENU_GAMEPAD.socialData.category == CHAT_CATEGORY_OFFICER_2 or
        CHAT_MENU_GAMEPAD.socialData.category == CHAT_CATEGORY_OFFICER_3 or
        CHAT_MENU_GAMEPAD.socialData.category == CHAT_CATEGORY_OFFICER_4 or
        CHAT_MENU_GAMEPAD.socialData.category == CHAT_CATEGORY_OFFICER_5
    then
        return CHAT_MENU_GAMEPAD:SelectedDataIsNotPlayer()
    end

    return false
end

local function BuildJumpToGroupMember()
    return CHAT_MENU_GAMEPAD:BuildOptionEntry(nil, 
            GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER), 
            function() JumpToGroupMember(DecorateDisplayName(CHAT_MENU_GAMEPAD.socialData.displayName)) end)
end

local function IsGroupJumpable()
    if IsFriendJumpable() then return false end

    return CHAT_MENU_GAMEPAD.socialData.category == CHAT_CATEGORY_PARTY
end

local _optionsInitialized = nil
local function GamepadChatInit()
    if _optionsInitialized then
        return false
    end
    _optionsInitialized = true

    CHAT_MENU_GAMEPAD:AddOptionTemplate(1, BuildJumpToFriend, IsFriendJumpable)
    CHAT_MENU_GAMEPAD:AddOptionTemplate(1, BuildJumpToGuildMember, IsGuildJumpable)
    CHAT_MENU_GAMEPAD:AddOptionTemplate(1, BuildJumpToGroupMember, IsGroupJumpable)

    return false
end

function Chat:Init()
    ZO_PreHook(CHAT_MENU_GAMEPAD, "OnShow", GamepadChatInit)
end

CT.Chat = Chat