--[[
    Traveller by Patrick Smyth
    
    Module to handle fast travel to players using player names

--]]
Players = { }

-- ==========================================================================================
--
-- Local routines
--

local function l_Undecorate(name)
    local decor = IsDecoratedDisplayName(name)
    local lowerName = ""

    if decor then
        lowerName = UndecorateDisplayName(name)
        lowerName = string.lower(lowerName)
    else
        lowerName = LocaleAwareToLower(name)
    end

    return lowerName
end

-- ==========================================================================================
--
-- Callback routines
--

local function c_PlayerCallback(playerDesc, param)
    local gotName = false

    if playerDesc.characterName ~= nil then
        gotName = Players:AreNamesEqual(param.name, playerDesc.characterName)
    end

    if (not gotName) and (playerDesc.displayName ~= nil) then
        gotName = Players:AreNamesEqual(param.name, playerDesc.displayName)
    end

    if gotName then
        Gotos:SingleJump(playerDesc.orderChar, playerDesc.displayName, playerDesc.characterName)
        param.gotplayer = true
    end

    return gotName
end

local function c_LeaderCallback(playerDesc, param)

    Gotos:AddToQueue(G_JUMP_GROUP, playerDesc.displayName, playerDesc.characterName)

    return false
end

-- ==========================================================================================
--
--  External Interface
--

function Players:AreNamesEqual(nameA, nameB)
    local namesEqual = false
    local aNameA = nameA
    local aNameB = nameB

    if (aNameA ~= nil) and (aNameB ~= nil) then

        local uNameA = ZO_StripGrammarMarkupFromCharacterName(aNameA)
        local uNameB = ZO_StripGrammarMarkupFromCharacterName(aNameB)
        namesEqual = (uNameA == uNameB)

        if not namesEqual then
            local lowerA = l_Undecorate(uNameA)
            local lowerB = l_Undecorate(uNameB)
            namesEqual = (lowerA == lowerB)
        end
    end

    return namesEqual
end

function Players:IsNameSelf(playerName)
    local tagName = ""
    local nameSelf = false

    tagName = ZO_GetPrimaryPlayerNameFromUnitTag("player", false)
    if tagName == nil then
        Traveller:Diag("Get primary name fail - <" .. playerName .. ">")
    else
        -- Traveller:Diag("Primary name - <" .. tagName .. ">")
        nameSelf = self:AreNamesEqual(tagName, playerName)
    end

    if not nameSelf then
        tagName = ZO_GetSecondaryPlayerNameFromUnitTag("player", false)
        if tagName == nil then
            Traveller:Diag("Get secondary name fail - <" .. playerName .. ">")
        else
            -- Traveller:Diag("Secondary name - <" .. tagName .. ">")
            nameSelf = self:AreNamesEqual(tagName, playerName)
        end
    end

    return nameSelf
end

function Players:ValidateName(playerName)
    local badName = false
    local pName = Utils:Trim(playerName)

    if pName == "" then
        Traveller:Diag("Empty player name")
        badName = true
    else
        -- must have character name OR display name (not both)
        local decorPlace = string.find(pName, "@")

        if decorPlace ~= nil then
            -- (decorPlace == 1) assume display name
            if decorPlace > 1 then
                local nameLen = string.len(pName)
                
                if nameLen < 2 then
                    -- just an @ symbol
                    Traveller:Diag("Empty player name")
                    badName = true
                elseif decorPlace == nameLen then
                    -- strip @ from end (assume character name)
                    pName = string.sub(pName, 1, nameLen - 1)
                else
                    -- strip character name (display name gets priority)
                    pName = string.sub(pName, decorPlace, nameLen)
                end
            end
        end
    end

    if badname then
        return
    else
        return pName
    end
end

function Players:Goto(playerName)
    local badName = false
    local pName = self:ValidateName(playerName)

    badname = (pName == nil)

    if not badName then
        badName = self:IsNameSelf(pName)

        if badName then
            Traveller:Diag("Cannot Goto Yourself - " .. playerName)
        end
    end

    if not badName then
        local param = { name = pName,
                        gotplayer = false }

        Order:Process(c_PlayerCallback, param)

        if not param.gotplayer then
            Traveller:Diag("Player not found - " .. playerName)
        end
    end
end

function Players:GotoLeader()
    local inGroup = false

    -- Are we in a group?
    inGroup = IsUnitGrouped("player")

    if inGroup then
        local leader = IsUnitGroupLeader("player")

        if leader then
            local countMembers = GetGroupSize()

            if countMembers >= 2 then
                -- special case - go to another group member
                local playersFound = false
                local param = { }

                Order:Process(c_LeaderCallback, param, G_JUMP_GROUP)

                playersFound = not Gotos:IsQueueEmpty()

                if playersFound then
                    Gotos:ActionQueue(G_JUMP_GROUP)
                else
                    Traveller:Diag("No players available")
                end
            else
                Traveller:Diag("Player is solo")
            end
        else
            Gotos:SingleJump(G_JUMP_LEADER)
        end
    else
        Traveller:Diag("Not in group")
    end
end