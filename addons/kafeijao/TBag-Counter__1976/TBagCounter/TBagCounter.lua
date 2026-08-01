-------------------------------------------------------------------------------------------------
--  Libraries --
-------------------------------------------------------------------------------------------------
local LAM2 = LibAddonMenu2
local chat = LibChatMessage("TBag Counter", "TBag")


-------------------------------------
-- Addon data.
-------------------------------------
TBagCounter = {}
TBagCounter.name = "TBagCounter"
TBagCounter.tbagCount = {}
TBagCounter.tbaggedCount = {}
TBagCounter.tbagCollected = {}
TBagCounter.tbagDistance = 3.6

TBagCounter.variableVersion = 2
TBagCounter.Default = {
    Verbose = "Single TBag"
}


-------------------------------------
-- Initialize the addon.
-------------------------------------
function TBagCounter.OnAddOnLoaded(event, addonName)
    if addonName == TBagCounter.name then
        TBagCounter:Initialize()
    end
end


-------------------------------------
-- Load saved variables and register the event listeners.
-------------------------------------
function TBagCounter:Initialize()
    TBagCounter.savedVariables = ZO_SavedVars:NewAccountWide("TBagCounterVars", TBagCounter.variableVersion, nil, TBagCounter.Default)

    TBagCounter.CreateSettingsWindow()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_STEALTH_STATE_CHANGED, self.onEventStealthStateChanged)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_UNIT_DEATH_STATE_CHANGED, self.onEventUnitDeathStateChanged)

    -- check for existant dead players
    for i = 1, GetGroupSize() do
        local possibleDeadPlayer = (i ~= 0) and ("group" .. i)
        if IsUnitDead(possibleDeadPlayer) then TBagCounter.onEventUnitDeathStateChanged(nil, possibleDeadPlayer, true) end
    end

    --d("TBagCounter Initialized! by @kafeijao (EU)")
end


-------------------------------------------------------------------------------------------------
--  Settings menu creation.
-------------------------------------------------------------------------------------------------
function TBagCounter.CreateSettingsWindow()
    local panelData = {
        type = "panel",
        name = "Tbag Counter",
        displayName = "Tbag Counter",
        author = "Kafeijao",
        version = TBagCounter.version,
        slashCommand = "/tbagconfig",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM2:RegisterAddonPanel("TBag_Counter", panelData)

    local optionsData = {
        [1] = {
            type = "header",
            name = "Tbag Counter Settings"
        },
        [2] = {
            type = "description",
            text = "Here you can adjust the Tbag Counter settings."
        },
        [3] = {
            type = "dropdown",
            name = "Select Chat Info detail",
            tooltip = "Ajusts the chat info about someone tbagging.",
            choices = {"Off", "Single TBag", "All TBags"},
            getFunc = function() return TBagCounter.savedVariables.Verbose end,
            setFunc = function(newValue)
                TBagCounter.savedVariables.Verbose = newValue
            end,
            width = "full",
            default = TBagCounter.Default.Verbose,
        }
    }

    LAM2:RegisterOptionControls("TBag_Counter", optionsData)
end


-------------------------------------
-- Prints tbag count statistics.
-------------------------------------
function TBagCounter.printTBag()
    local function compare(a,b)
        return TBagCounter.tbagCount[a] > TBagCounter.tbagCount[b]
    end

    TBagCounter.printToChatOrderedTable("TOP TBaggers", TBagCounter.tbagCount, compare)
end


-------------------------------------
-- Prints tbagged count statistics.
-------------------------------------
function TBagCounter.printTBagged()
    local function compare(a,b)
        return TBagCounter.tbaggedCount[a] > TBagCounter.tbaggedCount[b]
    end

    TBagCounter.printToChatOrderedTable("TOP TBagged Victims", TBagCounter.tbaggedCount, compare)
end

-------------------------------------
-- Resets the statistics.
-------------------------------------
function TBagCounter.reset()
    TBagCounter.tbagCount = {}
    TBagCounter.tbaggedCount = {}
    TBagCounter.tbagCollected = {}
end


-------------------------------------
-- Prints an ordered table to chat's text area.
-------------------------------------
function TBagCounter.printToChatOrderedTable(prefix, items, compare)

    local keys = {}
    for k in pairs(items) do table.insert(keys, k) end
    table.sort(keys, compare)

    local outputString = prefix .. ": "
    local isFirst = true

    for key, value in pairs(keys) do
        if(isFirst) then
            outputString = outputString .. "| "
            isFirst = false
        end
        outputString = outputString .. tostring(value) .. ": " .. tostring(items[value]) .. " | "
    end

    local channel = IsUnitGrouped('player') and "/p " or "/say "
    CHAT_SYSTEM.textEntry:SetText( channel .. outputString )
    CHAT_SYSTEM:Maximize()
    CHAT_SYSTEM.textEntry:Open()
    CHAT_SYSTEM.textEntry:FadeIn()
end


-------------------------------------
-- Slash commands listeners.
-------------------------------------
SLASH_COMMANDS["/tbag"] = TBagCounter.printTBag
SLASH_COMMANDS["/tbagged"] = TBagCounter.printTBagged
SLASH_COMMANDS["/tbagreset"] = TBagCounter.reset


-------------------------------------
-- Handler for stealth changing events.
-- @eventCode id of the event.
-- @unitTag id of unit.
-- @stealthState id of new sealth state.
-------------------------------------
function TBagCounter.onEventStealthStateChanged(eventCode, unitTag, stealthState)
    local tbaggerUnitTag = unitTag
    if stealthState == STEALTH_STATE_DETECTED and IsUnitGrouped(unitTag) then

        local groupSize = GetGroupSize()

        local tbaggerName = GetUnitDisplayName(tbaggerUnitTag)
        local tbaggerX, tbaggerY, tbaggerHeading = GetMapPlayerPosition(tbaggerUnitTag)

        local possibleTBaggedUnitTag, possibleTBaggedName, x, y, heading, possibleTBaggedZone, possibleTBaggedIsOnline

        local zone, sameZone, dist, text, ctrl_class

        for i = 1, groupSize do

            possibleTBaggedUnitTag = (i ~= 0) and ("group" .. i) or tbaggerUnitTag
            possibleTBaggedName = GetUnitDisplayName(possibleTBaggedUnitTag)
            x, y, heading = GetMapPlayerPosition(possibleTBaggedUnitTag)
            possibleTBaggedZone = GetUnitZone(possibleTBaggedUnitTag)
            possibleTBaggedIsOnline = IsUnitOnline(possibleTBaggedUnitTag) and not (possibleTBaggedName == "" or (x == 0 and y == 0)) -- last condition prevent issue
            sameZone = GetUnitZone(tbaggerUnitTag) == possibleTBaggedZone and possibleTBaggedZone == GetUnitZone("player") -- if the player is in a diff zone, the other group members will have same pos

            if possibleTBaggedIsOnline and tbaggerName ~= possibleTBaggedName and sameZone and IsUnitDead(possibleTBaggedUnitTag) then
                x = (x - tbaggerX)
                y = (y - tbaggerY)
                dist = math.sqrt(x * x + y * y) * 800 / 1 -- meters

                if dist < TBagCounter.tbagDistance then
                    if TBagCounter.savedVariables.Verbose == "All TBags" then
                        --d(tbaggerName .. " has TBagged " .. possibleTBaggedName)
                        chat:Print(tbaggerName .. " has TBagged " .. possibleTBaggedName)
                    end

                    TBagCounter.hasTBagged(tbaggerName, possibleTBaggedName)
                end
            end
        end
    end
end


-------------------------------------
-- Handler for death changing events.
-- @eventCode id of the event.
-- @unitTag id of unit.
-- @isDead whether the unit is dead or not.
------------------------------------
function TBagCounter.onEventUnitDeathStateChanged(eventCode, unitTag, isDead)
    if IsUnitPlayer(unitTag) and  IsUnitGrouped(unitTag) then
        local player = GetUnitDisplayName(unitTag)
        if isDead then
            TBagCounter.tbagCollected[player] = {}
        end
    end
end


-------------------------------------
-- Handler for tbag events.
-- @tbaggerUserID userid of the player that tabbged.
-- @tbaggedUserID userid of the player that has been tbagged.
------------------------------------
function TBagCounter.hasTBagged(tbaggerUserID, tbaggedUserID)
    if TBagCounter.tbagCollected[tbaggedUserID][tbaggerUserID] == nil then -- if it's the first tbag to that player in that death

        local aux = TBagCounter.tbagCount[tbaggerUserID]
        if aux == nil then
            TBagCounter.tbagCount[tbaggerUserID] = 1
        else
            TBagCounter.tbagCount[tbaggerUserID] = aux + 1
        end

        aux = TBagCounter.tbaggedCount[tbaggedUserID]
        if aux == nil then
            TBagCounter.tbaggedCount[tbaggedUserID] = 1
        else
            TBagCounter.tbaggedCount[tbaggedUserID] = aux + 1
        end

        TBagCounter.tbagCollected[tbaggedUserID][tbaggerUserID] = true
        --if TBagCounter.savedVariables.Verbose == "Single TBag" then d(tbaggerUserID .. " has TBagged " .. tbaggedUserID) end
        if TBagCounter.savedVariables.Verbose == "Single TBag" then chat:Print(tbaggerUserID .. " has TBagged " .. tbaggedUserID) end
    end
end


-------------------------------------
-- Initialization Register.
------------------------------------
EVENT_MANAGER:RegisterForEvent(TBagCounter.name, EVENT_ADD_ON_LOADED, TBagCounter.OnAddOnLoaded)