GroupLootHighscore = ZO_Object:Subclass()
local highscoreSettings = nil
local highscoreWindowIsHidden = true

function GroupLootHighscore:New()
    local obj = ZO_Object.New(self)
    obj:Initialize()
    return obj
end

function GroupLootHighscore:Initialize()
    highscoreSettings = ZO_SavedVars:New("GroupLootHighscore_db", 1, nil, { members = {}, memberCount = 0, positionLeft = 0, positionTop = 0, })

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_JOINED, function(...) self:OnMemberJoined(...) end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_GROUP_MEMBER_LEFT, function(...) self:OnMemberLeft(...) end)

    GroupLootHighscoreWindow:SetHidden(true)
    GroupLootHighscoreWindow:ClearAnchors()
    GroupLootHighscoreWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, highscoreSettings.positionLeft, highscoreSettings.positionTop)

    self:ConsoleCommands()
    self:UpdateHighscoreWindow()
end

-- EVENT_GROUP_MEMBER_JOINED
function GroupLootHighscore:OnMemberJoined(event, memberName)
    self:AddAllMembersInGroup()
end

-- EVENT_GROUP_MEMBER_LEFT
function GroupLootHighscore:OnMemberLeft(event, memberName, reason, wasLocalPlayer)
    self:RemoveMember(memberName)
end

--[[
    Member functions
]]--
function GroupLootHighscore:NewMember(name)
    name = zo_strformat(SI_UNIT_NAME, name)

    if not highscoreSettings.members[name] then
        highscoreSettings.members[name] = {
            trash       = 0,
            normal      = 0,
            magic       = 0,
            arcane      = 0,
            artifact    = 0,
            legendary   = 0,
            bestLoot    = "None (0g)",
            deaths      = 0,
            totalValue  = 0,
            isRowHidden = false,
            rowPosition = 0, -- maybe useless
        }

        highscoreSettings.memberCount               = highscoreSettings.memberCount + 1
        highscoreSettings.members[name].rowPosition = highscoreSettings.memberCount
    end

    return highscoreSettings.members[name]
end

function GroupLootHighscore:RemoveMember(name)
    name = zo_strformat(SI_UNIT_NAME, name)
    highscoreSettings.members[name] = nil
    highscoreSettings.memberCount = highscoreSettings.memberCount - 1
    self:UpdateHighscoreWindow()
end

function GroupLootHighscore:DeleteMembers()
    ZO_ClearTable(highscoreSettings.members)
    highscoreSettings.memberCount = 0
    self:UpdateHighscoreWindow()
end

function GroupLootHighscore:MemberExists(name)
    name = zo_strformat(SI_UNIT_NAME, name)
    return highscoreSettings.members[name] ~= nil
end

function GroupLootHighscore:ResetMembers()
    for k, v in pairs(highscoreSettings.members) do

        highscoreSettings.members[k] = {
            trash       = 0,
            normal      = 0,
            magic       = 0,
            arcane      = 0,
            artifact    = 0,
            legendary   = 0,
            bestLoot    = "None (0g)",
            deaths      = 0,
            totalValue  = 0,
            isRowHidden = false,
            rowPosition = 0,
        }
    end

    self:UpdateHighscoreWindow()
end

function GroupLootHighscore:AddAllMembersInGroup()
    local countMembers = GetGroupSize()

    -- Get list of member names in current group
    local members = {}
    for i = 1, countMembers do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then
            local name = zo_strformat(SI_UNIT_NAME, GetUnitName(unitTag))
            members[name] = true
        end
    end

    -- Add all missing members
    for name in pairs(members) do
        if not self:MemberExists(name) then self:NewMember(name) end
    end

    -- Check memberCount, if it's not equal to countMembers, it must be more then that
    -- (each call self:NewMember adds one to the counter). So we have to remove invalid
    -- items from the master list
    if highscoreSettings.memberCount ~= countMembers then
        for name in pairs(highscoreSettings.members) do
            if members[name] == nil then
                highscoreSettings.members[name] = nil
                highscoreSettings.memberCount = highscoreSettings.memberCount - 1
                if highscoreSettings.memberCount == countMembers then break end
            end
        end
    end

    self:UpdateHighscoreWindow()
end


function GroupLootHighscore:UpdateWindowSize()
    GroupLootHighscoreWindow:SetDimensions(1000, 122 + (highscoreSettings.memberCount * 26))
end

function GroupLootHighscore:UpdateHighscoreWindow()
    self:UpdateWindowSize()

    local count = 0
    for k, v in pairs(highscoreSettings.members) do
        count = count + 1

        if count > 24 then break end

        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "NAME"):SetText(k)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "TRASH"):SetText(v.trash)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "NORMAL"):SetText(v.normal)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "MAGIC"):SetText(v.magic)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "ARCANE"):SetText(v.arcane)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "ARTIFACT"):SetText(v.artifact)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "LEGENDARY"):SetText(v.legendary)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "BESTLOOT"):SetText(v.bestLoot)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "DEATHS"):SetText(v.deaths)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "TOTALVALUE"):SetText(v.totalValue)

        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "NAME"):SetHidden(false)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "TRASH"):SetHidden(false)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "NORMAL"):SetHidden(false)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "MAGIC"):SetHidden(false)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "ARCANE"):SetHidden(false)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "ARTIFACT"):SetHidden(false)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "LEGENDARY"):SetHidden(false)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "BESTLOOT"):SetHidden(false)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "DEATHS"):SetHidden(false)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "TOTALVALUE"):SetHidden(false)
    end

    -- Make sure that the memberCount is correct
    highscoreSettings.memberCount = count

    -- Hide all the rest lines that are not needed
    -- 24 is the max amount of rows
    while count < 24 do
        count = count + 1
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "NAME"):SetHidden(true)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "TRASH"):SetHidden(true)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "NORMAL"):SetHidden(true)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "MAGIC"):SetHidden(true)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "ARCANE"):SetHidden(true)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "ARTIFACT"):SetHidden(true)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "LEGENDARY"):SetHidden(true)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "BESTLOOT"):SetHidden(true)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "DEATHS"):SetHidden(true)
        GroupLootHighscoreWindow:GetNamedChild("ROW" .. count .. "TOTALVALUE"):SetHidden(true)
    end
end

function GroupLootHighscore:MoveStop()
    highscoreSettings.positionLeft = math.floor(GroupLootHighscoreWindow:GetLeft())
    highscoreSettings.positionTop = math.floor(GroupLootHighscoreWindow:GetTop())
end

--[[
    Update functions
]]--
function GroupLootHighscore:IsBestLoot(name, newLootValue)
    name = zo_strformat(SI_UNIT_NAME, name)
    local currentBestLootValue = tonumber(string.match(highscoreSettings.members[name].bestLoot, "%d+"))
    return newLootValue > currentBestLootValue
end

function GroupLootHighscore:UpdateBestLoot(name, itemLink)
    name = zo_strformat(SI_UNIT_NAME, name)
    local oldValue = tonumber(string.match(highscoreSettings.members[name].bestLoot, "%d+"))
    highscoreSettings.members[name].bestLoot = zo_strformat("<<t:1>> (<<2>>g)", GetItemLinkName(itemLink), GetItemLinkValue(itemLink, true))
    self:UpdateHighscoreWindow()
end

function GroupLootHighscore:UpdateTotalValue(name, newValue)
    name = zo_strformat(SI_UNIT_NAME, name)
    local oldValue = highscoreSettings.members[name].totalValue
    newValue = oldValue + newValue
    highscoreSettings.members[name].totalValue = newValue
    self:UpdateHighscoreWindow()
end

function GroupLootHighscore:UpdateDeath(name, newValue)
    name = zo_strformat(SI_UNIT_NAME, name)
    local oldValue = highscoreSettings.members[name].deaths
    newValue = oldValue + newValue
    highscoreSettings.members[name].deaths = newValue
    self:UpdateHighscoreWindow()
end

function GroupLootHighscore:UpdateTrash(name, newValue)
    name = zo_strformat(SI_UNIT_NAME, name)
    local oldValue = highscoreSettings.members[name].trash
    newValue = oldValue + newValue
    highscoreSettings.members[name].trash = newValue
    self:UpdateHighscoreWindow()
end

function GroupLootHighscore:UpdateNormal(name, newValue)
    name = zo_strformat(SI_UNIT_NAME, name)
    local oldValue = highscoreSettings.members[name].normal
    newValue = oldValue + newValue
    highscoreSettings.members[name].normal = newValue
    self:UpdateHighscoreWindow()
end

function GroupLootHighscore:UpdateMagic(name, newValue)
    name = zo_strformat(SI_UNIT_NAME, name)
    local oldValue = highscoreSettings.members[name].magic
    newValue = oldValue + newValue
    highscoreSettings.members[name].magic = newValue
    self:UpdateHighscoreWindow()
end

function GroupLootHighscore:UpdateArcane(name, newValue)
    name = zo_strformat(SI_UNIT_NAME, name)
    local oldValue = highscoreSettings.members[name].arcane
    newValue = oldValue + newValue
    highscoreSettings.members[name].arcane = newValue
    self:UpdateHighscoreWindow()
end

function GroupLootHighscore:UpdateArtifact(name, newValue)
    name = zo_strformat(SI_UNIT_NAME, name)
    local oldValue = highscoreSettings.members[name].artifact
    newValue = oldValue + newValue
    highscoreSettings.members[name].artifact = newValue
    self:UpdateHighscoreWindow()
end

function GroupLootHighscore:UpdateLegendary(name, newValue)
    name = zo_strformat(SI_UNIT_NAME, name)
    local oldValue = highscoreSettings.members[name].legendary
    newValue = oldValue + newValue
    highscoreSettings.members[name].legendary = newValue
    self:UpdateHighscoreWindow()
end

--[[
    Console commands
]]--
function GroupLootHighscore:ConsoleCommands()
    -- Print all available commands to chat
    SLASH_COMMANDS["/glhelp"] = function ()
        d("-- Group Loot commands --")
        d("/glh         Show or hide the highscore window.")
        d("/glhc        Print highscores to the chat.")
        d("/glhreset    Reset all highscore values (doesn't remove).")
        d("/glhdelete   Remove everything from highscores.")
    end

    -- Toggle the highscore window
    SLASH_COMMANDS["/glh"] = function ()
        if highscoreWindowIsHidden then
            GroupLootHighscoreWindow:SetHidden(false)
            highscoreWindowIsHidden = false
        else
            GroupLootHighscoreWindow:SetHidden(true)
            highscoreWindowIsHidden = true
        end
    end

    -- Print highscores to the chat
    SLASH_COMMANDS["/glhc"] = function ()
        local next = next
        if next(highscoreSettings.members) ~= nil then
            d("Name: Trash | Normal | Magic | Arcane | Artifact | Legendary | Best Loot | Deaths | Total Value")
            for k, v in pairs(highscoreSettings.members) do
                d(k .. ": " .. v.trash .. " | " .. v.normal .. " | " .. v.magic .. " | " .. v.arcane .. " | " .. v.artifact .. " | " .. v.legendary .. " | " .. v.bestLoot .. " | " .. v.deaths .. " | " .. v.totalValue)
            end
        else
            d("Nothing recorded yet.")
        end
    end

    -- Reset all stats from the .member table
    SLASH_COMMANDS["/glhreset"] = function ()
        GroupLootHighscore:ResetMembers()
        d("Group Loot highscores have been reset")
    end

    -- Clear all members from the .member table
    SLASH_COMMANDS["/glhdelete"] = function ()
        GroupLootHighscore:DeleteMembers()
        d("Group Loot highscores have been deleted")
    end
end