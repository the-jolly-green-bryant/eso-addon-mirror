WingsOfWindGuildhall = {}

local WindsGH = WingsOfWindGuildhall

WindsGH.NAME = "WingsOfWindGuildhall"
WindsGH.DISPLAY_NAME = "Wings of Wind Guildhall"
WindsGH.VERSION = "2.0.2"
WindsGH.AUTHOR = "@Viralissa"

WindsGH.FORMATTED_GUILD_NAME = "|c00BFFFWings of Wind|r"

WindsGH.GUILD_ID = 535822

WindsGH.MAX_CUSTOM_POINTS = 5

WindsGH.HOUSES = {
    PRIMARY = 0,
    GRAND_TOPAL_HIDEAWAY = 40,
    ALINOR_CREST_TOWNHOUSE = 59,
    GRAND_PSIJIC_VILLA = 62,
    LAKEMIRE_XANMEER_MANOR = 64,
    MOON_SUGAR_MEADOW = 71,
    DRUIDSPRING_CONSERVATORY = 123,
}

WindsGH.guildHallList = {
    {
        house = WindsGH.HOUSES.DRUIDSPRING_CONSERVATORY,
        label = "Guildhall",
        key = "primaryResidence",
    },
}

WindsGH.callbackManager = ZO_CallbackObject:Subclass()
WindsGH.EVENTS = {
    ACTIVATED = WindsGH.NAME .. "ActivatedEvent",
    DEACTIVATED = WindsGH.NAME .. "DeactivatedEvent",
    INITIALIZED = WindsGH.NAME .. "InitializedEvent",
    TRAVEL_POINT_UPDATED = WindsGH.NAME .. "TravelPointUpdatedEvent",
}

WindsGH.LABELS = {
    JUMP_TO_GROUP_LEADER = "Jump to group leader",
}

WindsGH.ACTIONS = {
    DO_NOTHING = "nothing",
    TRAVEL_TO_PRIMARY_RESIDENCE = "travelToPrimaryResidence",
    TRAVEL_TO_GROUP_LEADER = "travelToGroupLeader",
    OPEN_TRAVEL_MENU = "openTravelMenu",
}

WindsGH.ACTION_TOOLTIPS = {
    [WindsGH.ACTIONS.DO_NOTHING] = "Do nothing",
    [WindsGH.ACTIONS.TRAVEL_TO_PRIMARY_RESIDENCE] = "Primary guild residence",
    [WindsGH.ACTIONS.TRAVEL_TO_GROUP_LEADER] = "Jump to group leader",
    [WindsGH.ACTIONS.OPEN_TRAVEL_MENU] = "Choose location",
}

WindsGH.defaultSettings = {
    useLibAddonMenu = true,
    leftMouseButtonAction = WindsGH.ACTIONS.TRAVEL_TO_PRIMARY_RESIDENCE,
    rightMouseButtonAction = WindsGH.ACTIONS.OPEN_TRAVEL_MENU,
    showTooltip = true,
    showChatIcon = true,
    showMinifiedChatIcon = true,
    showInGuildLeaderMenu = true,
    showTravelToGroupLeader = true,
    ownHouseTravel = {},
}

local SAVED_VARS_NAME = "WingsOfWindGuildhallVariables"
local SAVED_VARS_VERSION = 1

WindsGH.userSettings = WindsGH.defaultSettings

local travelFunctions

local deactivated = false

local function setupTravelFunctions()
    travelFunctions = {
        guildHalls = {},
        customPoints = {},
    }

    local guildHalls = WindsGH.guildHallList

    for i = 1, #guildHalls do
        if guildHalls[i].house == WindsGH.HOUSES.PRIMARY then
            travelFunctions.guildHalls[i] = function()
                if GetDisplayName() ~= "@Viralissa" then
                    JumpToHouse("@Viralissa")
                else
                    RequestJumpToHouse(GetHousingPrimaryHouse(), false)
                end
            end
        else
            travelFunctions.guildHalls[i] = function()
                if GetDisplayName() ~= "@Viralissa" then
                    JumpToSpecificHouse("@Viralissa", guildHalls[i].house)
                else
                    RequestJumpToHouse(guildHalls[i].house, false)
                end
            end
        end
    end

    if next(WindsGH.userSettings.ownHouseTravel) ~= nil then
        for i, house in ipairs(WindsGH.userSettings.ownHouseTravel) do
            travelFunctions.customPoints[i] = function () RequestJumpToHouse(house.houseId, house.outside) end
        end
    end
end

local function createLabelForCustomPoint(index)
    if WindsGH.userSettings.ownHouseTravel and WindsGH.userSettings.ownHouseTravel[index] then
        local house = WindsGH.userSettings.ownHouseTravel[index]

        if house.customName and house.customName ~= "" then
            return house.customName
        end

        return WindsGH.Util.GetHouseNameById(house.houseId) .. (house.outside and " (outside)" or "")
    end

    return "Custom point #" .. tostring(index)
end

local function createKeybindingLabels()
    local guildHalls = WindsGH.guildHallList

    for i = 1, #guildHalls do
        if guildHalls[i].key then
            ZO_CreateStringId("SI_BINDING_NAME_WINGSOFWIND_GH_" .. string.upper(guildHalls[i].key), guildHalls[i].label)
        end
    end

    ZO_CreateStringId("SI_BINDING_NAME_WINGSOFWIND_GH_GROUPLEADER", WindsGH.LABELS.JUMP_TO_GROUP_LEADER)

    for i = 1, WindsGH.MAX_CUSTOM_POINTS do
        ZO_CreateStringId("SI_BINDING_NAME_WINGSOFWIND_GH_CUSTOMPOINT_" .. tostring(i), createLabelForCustomPoint(i))
    end
end

function WindsGH.isDeactivated()
    return deactivated
end

function WindsGH.travelToGuildHall(key)
    if WindsGH.isDeactivated() then
        return
    end

    local guildHalls = WindsGH.guildHallList

    for i = 1, #guildHalls do
        if guildHalls[i].key == key then
            travelFunctions.guildHalls[i]()
        end
    end
end

function WindsGH.travelToCustomPoint(index)
    if WindsGH.isDeactivated() then
        return
    end

    if travelFunctions.customPoints[index] ~= nil then
        travelFunctions.customPoints[index]()
    end
end

function WindsGH.travelToGroupLeader()
    JumpToGroupLeader()
end

local function shouldBeDeactivated()
    local rankName = WindsGH.Util.GetPlayerRankNameInGuild(WindsGH.GUILD_ID)

    return rankName == nil or rankName == "Invited"
end

local function refreshActivationState()
    local isDeactivatedNow = shouldBeDeactivated()

    if isDeactivatedNow and not WindsGH.isDeactivated() then
        deactivated = true
        WindsGH.callbackManager:FireCallbacks(WindsGH.EVENTS.DEACTIVATED)
    elseif not isDeactivatedNow and WindsGH.isDeactivated() then
        deactivated = false
        WindsGH.callbackManager:FireCallbacks(WindsGH.EVENTS.ACTIVATED)
    end
end

local function initialize()
    if GetDisplayName() == "@Arrvis" then
        table.insert(WindsGH.guildHallList, {
            house = WindsGH.HOUSES.ALINOR_CREST_TOWNHOUSE,
            label = "First guildhall",
            playerMenuLabel = "Visit first guildhall",
            key = "firstGuildhall",
        })

        table.insert(WindsGH.guildHallList, {
            house = WindsGH.HOUSES.MOON_SUGAR_MEADOW,
            label = "Elsweyr guildhall",
            playerMenuLabel = "Visit Elsweyr guildhall",
            key = "elsweyrGuildhall",
        })
    end

    WindsGH.userSettings = ZO_SavedVars:NewAccountWide(SAVED_VARS_NAME, SAVED_VARS_VERSION, nil, WindsGH.defaultSettings)

    if WindsGH.userSettings.leftMouseButtonAction == "travelToCrafthall" then
        WindsGH.userSettings.leftMouseButtonAction = WindsGH.ACTIONS.TRAVEL_TO_PRIMARY_RESIDENCE
    end

    if WindsGH.userSettings.rightMouseButtonAction == "travelToCrafthall" then
        WindsGH.userSettings.rightMouseButtonAction = WindsGH.ACTIONS.TRAVEL_TO_PRIMARY_RESIDENCE
    end

    setupTravelFunctions()
    createKeybindingLabels()

    deactivated = shouldBeDeactivated()

    EVENT_MANAGER:RegisterForEvent(WindsGH.NAME, EVENT_GUILD_PLAYER_RANK_CHANGED, refreshActivationState)

    -- We won't be able to refresh keybinding labels on the fly without reloading UI, so no point in invoking that
    WindsGH.callbackManager:RegisterCallback(WindsGH.EVENTS.TRAVEL_POINT_UPDATED, setupTravelFunctions)

    WindsGH.callbackManager:FireCallbacks(WindsGH.EVENTS.INITIALIZED)
end

local function onAddonLoaded(_, addonName)
    if addonName ~= WindsGH.NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(WindsGH.NAME, EVENT_ADD_ON_LOADED)

    initialize()
end

EVENT_MANAGER:RegisterForEvent(WindsGH.NAME, EVENT_ADD_ON_LOADED, onAddonLoaded)
