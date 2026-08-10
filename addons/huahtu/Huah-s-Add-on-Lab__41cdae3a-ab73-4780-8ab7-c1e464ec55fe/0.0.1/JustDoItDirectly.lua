-- Just Do It Directly
-- Author: @HuahTu

-- Create the addon class object
local myScope = {}

-- Constants
myScope.NAME = "JustDoItDirectly"

-- Semi-global variables
myScope.debug = true
myScope.scene = nil

-- Typical crafted item info
-- local name, icon, stack, sellPrice, meetsUsageRequirement, equipType, itemType, itemStyle, displayQuality,
--                                          itemSoundCategory, itemInstanceId = GetLastCraftingResultItemInfo(i)

local function debugLog(message)
    if (not myScope.debug)
    then
        return
    end
    d("|c88FFFF[JustDoItDirectly]|r " .. tostring(message))
end

local function forceLog(message)
    d("|c88FFFF[JustDoItDirectly]|r " .. tostring(message))
end

local function onActivated(eventCode)
    EVENT_MANAGER:UnregisterForEvent(myScope.NAME, EVENT_PLAYER_ACTIVATED)
    debugLog("2026/8/9 23:37 TAIPEI")
end

EVENT_MANAGER:RegisterForEvent(myScope.NAME, EVENT_PLAYER_ACTIVATED, onActivated)

local function onCraftComplete(event, station)
    if((station ~= CRAFTING_TYPE_ENCHANTING) and (station ~= CRAFTING_TYPE_ALCHEMY)) then
        return
    end
    local numItemsGained, penaltyApplied = GetNumLastCraftingResultItemsAndPenalty()
    if(numItemsGained == 0) then
        return
    end

    for i = 1, numItemsGained do
        local name, _, _, _, _, _, itemType = GetLastCraftingResultItemInfo(i)
        debugLog(name .. " crafted");
        if(itemType == ITEMTYPE_POTION_BASE) then
            debugLog("Potion");
        elseif(itemType == ITEMTYPE_POTION_BASE) then
            debugLog("Potion");
        elseif(itemType == ITEMTYPE_GLYPH_WEAPON) then
            debugLog("GLYPH_WEAPON");
        elseif(itemType == ITEMTYPE_GLYPH_ARMOR) then
            debugLog("GLYPH_ARMOR");
        elseif(itemType == ITEMTYPE_GLYPH_JEWELRY) then
            debugLog("GLYPH_JEWELRY");
        else
            debugLog("Other types");
        end
    end

end

local function selectAndMakePotion(tabData)
    debugLog("selectAndMakePotion")
end

local function setupCraftingHooks()
    EVENT_MANAGER:RegisterForEvent(myScope.NAME, EVENT_CRAFT_COMPLETED, onCraftComplete)
end

local function setupAlchemyPanel()
    -- local submenu = WINDOW_MANAGER:CreateControl("JDID", ZO_GamepadAlchemyTopLevel, CT_CONTROL)
    -- submenu:SetAnchorFill(ZO_GamepadAlchemyTopLevel)
    -- -- submenu:SetHidden(true)
    -- local fragment = ZO_FadeSceneFragment:New(submenu)
    -- GAMEPAD_ALCHEMY_ROOT_SCENE:AddFragment(fragment)


    -- local submenu = WINDOW_MANAGER:CreateControl(nil, ZO_GamepadAlchemyTopLevel, CT_LABEL)
    -- submenu:SetFont("ZoFontGamepad25")
    -- submenu:SetText("To ROOT_SCENE")
    -- submenu:SetAnchor(CENTER, ZO_GamepadAlchemyTopLevel, CENTER, 0, 0)
    -- local fragment = ZO_FadeSceneFragment:New(submenu)
    -- GAMEPAD_ALCHEMY_ROOT_SCENE:AddFragment(fragment)

    -- submenu = WINDOW_MANAGER:CreateControl(nil, ZO_GamepadAlchemyTopLevel, CT_LABEL)
    -- submenu:SetFont("ZoFontGamepad25")
    -- submenu:SetText("To CREATION_SCENE")
    -- submenu:SetAnchor(CENTER, ZO_GamepadAlchemyTopLevel, CENTER, 0, 0)
    -- fragment = ZO_FadeSceneFragment:New(submenu)
    -- GAMEPAD_ALCHEMY_CREATION_SCENE:AddFragment(fragment)

    local scene = GAMEPAD_ALCHEMY:CreateInteractScene("just_do_alchemy")
    scene:SetInputPreferredMode(INPUT_PREFERRED_MODE_ALWAYS_GAMEPAD)
    scene:RegisterCallback("StateChange",
        function(oldState, newState)
            if newState == SCENE_SHOWING then
                debugLog("just_do_alchemy show")
                ZO_GamepadCraftingUtils_SetupGenericHeader(self, "Just Do It Directly")
                ZO_GamepadCraftingUtils_RefreshGenericHeader(self)
            elseif newState == SCENE_HIDDEN then
                debugLog("just_do_alchemy hide")
            end
        end)

    local data = ZO_GamepadEntryData:New("Just Do It Directly")
    data.mode = 99
    GAMEPAD_ALCHEMY.modeList:AddEntry("ZO_GamepadItemEntryTemplate", data)
    GAMEPAD_ALCHEMY.modeList:Commit()

    SecurePostHook(GAMEPAD_ALCHEMY, "SelectMode",
        function(self, mode)
            debugLog("OOXX 100")
            if mode == 99 then
                debugLog("Just Do It Directly selected");
            end
        end)
    SecurePostHook(ZO_GamepadAlchemy, "SelectMode",
        function(self, mode)
            debugLog("OOXX 200")
            if mode == 99 then
                debugLog("Just Do It Directly selected");
            end
        end)
end

local function setupAlchemyHooks()
    -- securePostHook(ZO_GamepadAlchemy, "Initialize", setupAlchemyPanel)
    CALLBACK_MANAGER:RegisterCallback("GamepadAlchemyInitialized", setupAlchemyPanel)
end

local function onAddOnLoaded(eventCode, addOnName)
    if(addOnName ~= myScope.NAME) then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(myScope.NAME, EVENT_ADD_ON_LOADED)

    setupCraftingHooks()
    -- setupAlchemyHooks()
    setupAlchemyPanel()
end

EVENT_MANAGER:RegisterForEvent(myScope.NAME, EVENT_ADD_ON_LOADED, onAddOnLoaded)