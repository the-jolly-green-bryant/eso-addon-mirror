local BAIT = {
    --lureID
    LAKE = {
        REG = 2, --guts
        ALT = 8  --minnow
    },
    FOUL = {
        REG = 3, --crawlers
        ALT = 9  --roe
    },
    RIVR = {
        REG = 4, --insects
        ALT = 6  --shad
    },
    SALT = {
        REG = 5, --worms
        ALT = 7  --chub
    },
    SIMPLE = 1 --simple bait
}

FishermansFriend = {
    name = "FishermansFriend",
    settingsName = "Fisherman's Friend",
    delay = false,
    defaults = {
        filtered = true,
        msg      = false
    }
}

--local logger = LibDebugLogger(FishermansFriend.name)
local LAM = LibAddonMenu2


local function FishermansFriend_GetItemQuantity(lureID)
    local _, _, stack = GetFishingLureInfo(lureID)
    return stack
end


local function FishermansFriend_EquipBait(baittype)
    if FishermansFriend_GetItemQuantity(baittype.ALT) > 0 and FishermansFriend.SavedVariables.filtered == true then
        SetFishingLure(baittype.ALT)
    elseif FishermansFriend_GetItemQuantity(baittype.REG) > 0 then
        SetFishingLure(baittype.REG)
    elseif FishermansFriend_GetItemQuantity(BAIT.SIMPLE) > 0 then
        SetFishingLure(BAIT.SIMPLE)
    else
        if FishermansFriend.SavedVariables.msg then
            ZO_CreateStringId("SI_HOLD_TO_SELECT_BAIT", GetString(FISHERMANSFRIEND_NO_BAIT))
        else
            ZO_CreateStringId("SI_HOLD_TO_SELECT_BAIT", GetString(FISHERMANSFRIEND_NO_BAIT_RST))
        end
    end
end


local function FishermansFriend_OnAction()
    if FishermansFriend.delay then return end
    EVENT_MANAGER:RegisterForUpdate(FishermansFriend.name .. "Delay", 300, function()
        FishermansFriend.delay = false
        EVENT_MANAGER:UnregisterForUpdate(FishermansFriend.name .. "Delay")
    end)
    FishermansFriend.delay = true

    local _, interactableName, _, _, additionalInteractInfo, _, _, _ = GetGameCameraInteractableActionInfo()
    if additionalInteractInfo ~= ADDITIONAL_INTERACT_INFO_FISHING_NODE then return end

    --Lake Bait
    if interactableName == GetString(FISHERMANSFRIEND_LAKE_FISHING_HOLE) then
        FishermansFriend_EquipBait(BAIT.LAKE)
    --Salt or Mystic Bait
    elseif interactableName == GetString(FISHERMANSFRIEND_SALT_FISHING_HOLE) or interactableName == GetString(FISHERMANSFRIEND_MYST_FISHING_HOLE) then
        FishermansFriend_EquipBait(BAIT.SALT)
    --Foul or Oily Bait
    elseif interactableName == GetString(FISHERMANSFRIEND_FOUL_FISHING_HOLE) or interactableName == GetString(FISHERMANSFRIEND_OILY_FISHING_HOLE) then
        FishermansFriend_EquipBait(BAIT.FOUL)
    --River Bait
    elseif interactableName == GetString(FISHERMANSFRIEND_RIVR_FISHING_HOLE) then
        FishermansFriend_EquipBait(BAIT.RIVR)
    end
end


function FishermansFriend.CreateSettings()
    local panelName = "FishermansFriendSettingsPanel"

    local panelData = {
        type = "panel",
        name = FishermansFriend.settingsName,
        displayName = FishermansFriend.settingsName,
        author = "Sem, GameDude",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local panel = LAM:RegisterAddonPanel(panelName, panelData)
    local optionsData = {}
        optionsData[#optionsData + 1] = {
            type = "description",
            text = GetString(FISHERMANSFRIEND_CNF_DESCRIPTION)
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            name = GetString(FISHERMANSFRIEND_CNF_SET),
            default = FishermansFriend.defaults.filtered,
            disabled = false,
            getFunc = function() return FishermansFriend.SavedVariables.filtered end,
            setFunc = function(value) FishermansFriend.SavedVariables.filtered = value end
        }
        optionsData[#optionsData + 1] = {
            type = "checkbox",
            name = GetString(FISHERMANSFRIEND_CNF_MSG),
            default = FishermansFriend.defaults.msg,
            disabled = false,
            getFunc = function() return FishermansFriend.SavedVariables.msg end,
            setFunc = function(value) FishermansFriend.SavedVariables.msg = value end
        }

    LAM:RegisterOptionControls(panelName, optionsData)
end


function FishermansFriend.OnAddOnLoaded(event, addonName)
    if addonName ~= FishermansFriend.name then return end

    EVENT_MANAGER:UnregisterForEvent(FishermansFriend.name, EVENT_ADD_ON_LOADED)
    FishermansFriend.SavedVariables = ZO_SavedVars:New("FishermansFriendSavedVariables", 1, nil, FishermansFriend.defaults)
    FishermansFriend.CreateSettings()
    ZO_PreHookHandler(RETICLE.interact, "OnEffectivelyShown", FishermansFriend_OnAction)
end

EVENT_MANAGER:RegisterForEvent(FishermansFriend.name, EVENT_ADD_ON_LOADED, FishermansFriend.OnAddOnLoaded)