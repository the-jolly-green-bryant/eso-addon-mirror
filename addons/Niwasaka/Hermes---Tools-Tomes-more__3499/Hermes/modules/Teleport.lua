local Hermes = _G['Hermes']

local LCM = LibCustomMenu
local GroupNames = {}

function Hermes:UpdateGroupMembers()
    local size = GetGroupSize()
    for i = 1, size do
        GroupNames[GetUnitName('group' .. i)] = GetUnitDisplayName('group' .. i)
    end
end

local function getAccountName(name)
    if (zo_strsub(name, 1, 1) == "@") then
        return name
    elseif IsPlayerInGroup(name) then
        return GroupNames[name]
    else
        return "@" .. name
    end
end

function Hermes:IsGuildMember(accountName)
    -- Check all guilds
    for index = 1, GetNumGuilds() do
        local guildId = GetGuildId(index)
        local memberIndex = GetGuildMemberIndexFromDisplayName(guildId, accountName)
        if memberIndex ~= nil then
            return true, false
        end
    end
    return false, false
end

function Hermes:InitializeChatMenu()
    LCM:RegisterPlayerContextMenu(function(playerName, rawName)
        local accountName = getAccountName(playerName)
        local isGuildMember = self:IsGuildMember(accountName)

        -- Fallback for special cases where chat account name and guild account name are different
        if (not isGuildMember and not IsPlayerInGroup(accountName)) then
            local fallbackName = getAccountName(zo_strformat("<<c:1>>", rawName))
            local fallbackMember = self:IsGuildMember(fallbackName)
            if (fallbackMember) then
                accountName, isGuildMember = fallbackName, fallbackMember
            end
        end

        -- New Mail
        if self.db.showMail then
            AddCustomMenuItem(GetString(SI_SOCIAL_MENU_SEND_MAIL), function()
                if MAIL_SEND:IsHidden() then
                    MAIL_SEND:ComposeMailTo(accountName)
                else
                    MAIL_SEND:SetReply(accountName)
                end
            end)
        end

        -- Teleport
        if self.db.showTeleport then
            if IsPlayerInGroup(accountName) then
                AddCustomMenuItem(GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER), function()
                    JumpToGroupMember(accountName)
                end)
            elseif IsFriend(accountName) then
                AddCustomMenuItem(GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER), function()
                    JumpToFriend(accountName)
                end)
            elseif isGuildMember then
                AddCustomMenuItem(GetString(SI_SOCIAL_MENU_JUMP_TO_PLAYER), function()
                    JumpToGuildMember(accountName)
                end)
            end
        end

        -- Teleport to primary House
        if self.db.showHouse then
            AddCustomMenuItem(GetString(SI_SOCIAL_MENU_VISIT_HOUSE), function()
                JumpToHouse(accountName)
            end)
        end
    end, LCM.CATEGORY_LATE)
end


