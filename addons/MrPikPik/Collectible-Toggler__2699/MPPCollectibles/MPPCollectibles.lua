MPPCollectibles = {}
local MPPCollectibles = MPPCollectibles
MPPCollectibles.name = "MPPCollectibles"
MPPCollectibles.petID = 5862

MPPCollectibles.defaults = {
    petID = -1,
    dressID = -1,
    mountID = -1,
    hatID = -1,
    skinID = -1,
    personalityID = -1,
    polymorphID = -1,
    custom1 = -1,
    custom2 = -1,
    custom3 = -1,
    custom4 = -1,
    custom5 = -1,
    useEzabi = false,
    useFezez = false,
    companionID = -1
}

local PET = 1
local DRESS = 2
local MOUNT = 3
local HAT = 4
local SKIN = 5
local PERSONALITY = 6
local POLYMORPH = 7
local CUSTOM_1 = 10
local CUSTOM_2 = 11
local CUSTOM_3 = 12
local CUSTOM_4 = 13
local CUSTOM_5 = 14

function MPPCollectibles.MainCommand(type, option)
    if not option or option == "" then
        if type == PET then
            UseCollectible(MPPCollectibles.SV.petID)
        elseif type == DRESS then
            UseCollectible(MPPCollectibles.SV.dressID)
        elseif type == MOUNT then
            UseCollectible(MPPCollectibles.SV.mountID)
        elseif type == HAT then
            UseCollectible(MPPCollectibles.SV.hatID)
        elseif type == SKIN then
            UseCollectible(MPPCollectibles.SV.skinID)
        elseif type == PERSONALITY then
            UseCollectible(MPPCollectibles.SV.personalityID)
        elseif type == POLYMORPH then
            UseCollectible(MPPCollectibles.SV.polymorphID)
        elseif type == CUSTOM_1 then
            UseCollectible(MPPCollectibles.SV.custom1)
        elseif type == CUSTOM_2 then
            UseCollectible(MPPCollectibles.SV.custom2)
        elseif type == CUSTOM_3 then
            UseCollectible(MPPCollectibles.SV.custom3)
        elseif type == CUSTOM_4 then
            UseCollectible(MPPCollectibles.SV.custom4)
        elseif type == CUSTOM_5 then
            UseCollectible(MPPCollectibles.SV.custom5)
        end
    
        return
    else
        -- Parse arguments
        local options = {}
        for substr in option:gmatch("%S+") do table.insert(options, substr) end
    
        
        -- Check
        if options[1] == "set" then
            if options[2] == nil then
                d("No collectible linked. Please use /{cmd} set {link}.")
                return
            end
            
            local id = string.match(options[2], "|H1:collectible:(%d+)|h|h")
            
            if type == PET then
                MPPCollectibles.SV.petID = id
            elseif type == DRESS then
                MPPCollectibles.SV.dressID = id
            elseif type == MOUNT then
                MPPCollectibles.SV.mountID = id
            elseif type == HAT then
                MPPCollectibles.SV.hatID = id
            elseif type == SKIN then
                MPPCollectibles.SV.skinID = id
            elseif type == PERSONALITY then
                MPPCollectibles.SV.personalityID = id
            elseif type == POLYMORPH then
                MPPCollectibles.SV.polymorphID = id
            elseif type == CUSTOM_1 then
                MPPCollectibles.SV.custom1 = id
            elseif type == CUSTOM_2 then
                MPPCollectibles.SV.custom2 = id
            elseif type == CUSTOM_3 then
                MPPCollectibles.SV.custom3 = id
            elseif type == CUSTOM_4 then
                MPPCollectibles.SV.custom4 = id
            elseif type == CUSTOM_5 then
                MPPCollectibles.SV.custom5 = id
            end
        end
    end
end

function MPPCollectibles.Pet(option)
    MPPCollectibles.MainCommand(PET, option)
end
function MPPCollectibles.Dress(option)
    MPPCollectibles.MainCommand(DRESS, option)
end
function MPPCollectibles.Mount(option)
    MPPCollectibles.MainCommand(MOUNT, option)
end
function MPPCollectibles.Hat(option)
    MPPCollectibles.MainCommand(HAT, option)
end
function MPPCollectibles.Skin(option)
    MPPCollectibles.MainCommand(SKIN, option)
end
function MPPCollectibles.Personality(option)
    MPPCollectibles.MainCommand(PERSONALITY, option)
end
function MPPCollectibles.Polymorph(option)
    MPPCollectibles.MainCommand(POLYMORPH, option)
end
function MPPCollectibles.Collectible_1(option)
    MPPCollectibles.MainCommand(CUSTOM_1, option)
end
function MPPCollectibles.Collectible_2(option)
    MPPCollectibles.MainCommand(CUSTOM_2, option)
end
function MPPCollectibles.Collectible_3(option)
    MPPCollectibles.MainCommand(CUSTOM_3, option)
end
function MPPCollectibles.Collectible_4(option)
    MPPCollectibles.MainCommand(CUSTOM_4, option)
end
function MPPCollectibles.Collectible_5(option)
    MPPCollectibles.MainCommand(CUSTOM_5, option)
end

function MPPCollectibles.Banker(option)
    if option == "toggle" then
        MPPCollectibles.SV.useEzabi = not MPPCollectibles.SV.useEzabi
        return
    else
        if MPPCollectibles.SV.useEzabi then
            UseCollectible(6376)
        else
            UseCollectible(267)
        end
    end
end

function MPPCollectibles.Merchant(option)
    if option == "toggle" then
        MPPCollectibles.SV.useFezez = not MPPCollectibles.SV.useFezez
        return
    else
        if MPPCollectibles.SV.useFezez then
            UseCollectible(6378)
        else
            UseCollectible(301)
        end
    end
end

function MPPCollectibles.Armorer()
	UseCollectible(9745)
end

function MPPCollectibles.Smuggler()
    UseCollectible(300)
end

function MPPCollectibles.Companion(option)
    if string.lower(option) == "mirri" then
        MPPCollectibles.SV.companionID = 9353
        UseCollectible(MPPCollectibles.SV.companionID)
        return
    elseif string.lower(option) == "bastian" then
        MPPCollectibles.SV.companionID = 9245
        UseCollectible(MPPCollectibles.SV.companionID)
        return
    else
        UseCollectible(MPPCollectibles.SV.companionID)
    end
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= MPPCollectibles.name then return end
    EVENT_MANAGER:UnregisterForEvent(MPPCollectibles.name, EVENT_ADD_ON_LOADED) 
    
    MPPCollectibles.SV = ZO_SavedVars:New("MPPCollectiblesSavedVariables", 1.0, nil, MPPCollectibles.defaults)
    
    SLASH_COMMANDS["/pet"] = MPPCollectibles.Pet
    SLASH_COMMANDS["/dress"] = MPPCollectibles.Dress
    SLASH_COMMANDS["/costume"] = MPPCollectibles.Dress
    SLASH_COMMANDS["/mount"] = MPPCollectibles.Mount
    SLASH_COMMANDS["/hat"] = MPPCollectibles.Hat
    SLASH_COMMANDS["/skin"] = MPPCollectibles.Skin
    SLASH_COMMANDS["/personality"] = MPPCollectibles.Personality
    SLASH_COMMANDS["/polymorph"] = MPPCollectibles.Polymorph
    SLASH_COMMANDS["/collectible1"] = MPPCollectibles.Collectible_1
    SLASH_COMMANDS["/collectible2"] = MPPCollectibles.Collectible_2
    SLASH_COMMANDS["/collectible3"] = MPPCollectibles.Collectible_3
    SLASH_COMMANDS["/collectible4"] = MPPCollectibles.Collectible_4
    SLASH_COMMANDS["/collectible5"] = MPPCollectibles.Collectible_5
    SLASH_COMMANDS["/banker"] = MPPCollectibles.Banker
    SLASH_COMMANDS["/merchant"] = MPPCollectibles.Merchant
	SLASH_COMMANDS["/armorer"] = MPPCollectibles.Armorer
    SLASH_COMMANDS["/smuggler"] = MPPCollectibles.Smuggler
    SLASH_COMMANDS["/companion"] = MPPCollectibles.Companion
end

EVENT_MANAGER:RegisterForEvent(MPPCollectibles.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)