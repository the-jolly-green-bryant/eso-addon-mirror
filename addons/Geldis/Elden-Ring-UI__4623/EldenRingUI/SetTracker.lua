local ADDON_NAME = "EldenRingUI"
local UI_Container = nil
local IconPool = {}
local TextPool = {}

local SLOT_OFFSETS = {
    [1] = {x = 187, y = -225}, -- Top
    [2] = {x = 187, y = -115}, -- Bottom
    [3] = {x = 281, y = -171}, -- Right
    [4] = {x = 92, y = -171},  -- Left
}

local function CreateUI()
    if UI_Container then return end
    local wm = GetWindowManager()
    UI_Container = wm:CreateTopLevelWindow("ERUI_SetTrackerControl")
    UI_Container:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT, 0, 0)
    UI_Container:SetDimensions(75, 75)
    UI_Container:SetDrawLayer(DL_OVERLAY)

    local fragment = ZO_HUDFadeSceneFragment:New(UI_Container)
    HUD_SCENE:AddFragment(fragment)           
    HUD_UI_SCENE:AddFragment(fragment)        
    SIEGE_BAR_SCENE:AddFragment(fragment)    
    LOOT_SCENE:AddFragment(fragment)          
end

local function GetIconControl(index)
    local wm = GetWindowManager()
    if not IconPool[index] then
        local icon = wm:CreateControl("ERUI_SetTrackerIcon" .. index, UI_Container, CT_TEXTURE)
        icon:SetDimensions(75, 75)
        local offset = SLOT_OFFSETS[index]
        icon:SetAnchor(CENTER, UI_Container, BOTTOMLEFT, offset.x, offset.y)
        IconPool[index] = icon
    end
    return IconPool[index]
end

local function GetTextControl(index)
    if index ~= 1 and index ~= 2 then return nil end
    local wm = GetWindowManager()
    if not TextPool[index] then
        local icon = GetIconControl(index)
        local label = wm:CreateControl("ERUI_SetTrackerText" .. index, UI_Container, CT_LABEL)
        label:SetFont("EldenRingUI/Fonts/EBGaramond-Medium.slug|22|soft-shadow-thick")
        label:SetColor(0.9, 0.9, 0.9, 0.9)
        label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

        if index == 1 then
            -- Текст сверху иконки для слота 1
            label:SetAnchor(BOTTOMLEFT, icon, TOPLEFT, -2, -18)
        else
            -- Текст снизу иконки для слота 2
            label:SetAnchor(TOPLEFT, icon, BOTTOMLEFT, -2, 18)
        end

        TextPool[index] = label
    end
    return TextPool[index]
end

local SetNameCache = {}

local function ScanGear()
    local setCounts = {}
    if not EldenRingUI.TRACKED_SETS then return setCounts end

    for slotIndex = EQUIP_SLOT_ITERATION_BEGIN, EQUIP_SLOT_ITERATION_END do
        local itemLink = GetItemLink(BAG_WORN, slotIndex)
        if itemLink ~= "" then
            local hasSet, setName = GetItemLinkSetInfo(itemLink, false)
            
            if hasSet then
                local matchedConfig = SetNameCache[setName]

                if matchedConfig == nil then
                    matchedConfig = false 
                    
                    for configName, _ in pairs(EldenRingUI.TRACKED_SETS) do
                        if string.find(setName, configName, 1, true) then
                            matchedConfig = configName
                            break
                        end
                    end
                    SetNameCache[setName] = matchedConfig
                end

                if matchedConfig then
                    local count = 1
                    if slotIndex == EQUIP_SLOT_MAIN_HAND or slotIndex == EQUIP_SLOT_BACKUP_MAIN then
                        local weaponType = GetItemLinkWeaponType(itemLink)
                        if weaponType == WEAPONTYPE_TWO_HANDED_SWORD or weaponType == WEAPONTYPE_TWO_HANDED_AXE or 
                           weaponType == WEAPONTYPE_TWO_HANDED_HAMMER or weaponType == WEAPONTYPE_BOW or 
                           weaponType == WEAPONTYPE_FIRE_STAFF or weaponType == WEAPONTYPE_FROST_STAFF or 
                           weaponType == WEAPONTYPE_LIGHTNING_STAFF or weaponType == WEAPONTYPE_HEALING_STAFF then
                            count = 2
                        end
                    end
                    
                    setCounts[matchedConfig] = (setCounts[matchedConfig] or 0) + count
                end
            end
        end
    end
    return setCounts
end

local function UpdateUI()
    local counts = ScanGear()
    local displaySlots = {nil, nil, nil, nil}
    local displayNames = {nil, nil, nil, nil}
    local overflow = {}

    for configName, count in pairs(counts) do
        local data = EldenRingUI.TRACKED_SETS[configName]
        if data and data.icon and count >= (data.pieces or 5) then
            local pref = data.preferredSlot
            if pref and pref >= 1 and pref <= 4 and not displaySlots[pref] then
                displaySlots[pref] = data.icon
                displayNames[pref] = configName
            else
                table.insert(overflow, { icon = data.icon, name = configName })
            end
        end
    end

    for _, item in ipairs(overflow) do
        for i = 1, 4 do
            if not displaySlots[i] then
                displaySlots[i] = item.icon
                displayNames[i] = item.name
                break
            end
        end
    end

    for i = 1, 4 do
        local ctrl = GetIconControl(i)
        if displaySlots[i] then
            ctrl:SetTexture(displaySlots[i])
            ctrl:SetHidden(false)
        else
            ctrl:SetHidden(true)
        end

        if i == 1 or i == 2 then
            local textCtrl = GetTextControl(i)
            if displaySlots[i] and displayNames[i] then
                textCtrl:SetText(displayNames[i])
                textCtrl:SetHidden(false)
            else
                textCtrl:SetHidden(true)
            end
        end
    end
end

local function OnInitialize(event, addonName)
    if event == EVENT_ADD_ON_LOADED and addonName ~= ADDON_NAME then return end
    
    if UI_Container then return end

    CreateUI()
    UpdateUI()

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function() UpdateUI() end)
    EVENT_MANAGER:AddFilterForEvent(ADDON_NAME, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, UpdateUI)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADDON_LOADED, OnInitialize)
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_PLAYER_ACTIVATED, OnInitialize)