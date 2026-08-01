OSA = OSA or {}
OSA.Pretty = OSA.Pretty or {}

local Pretty = OSA.Pretty

-- Character texture
if ZO_StatsPanel and ZO_StatsPanelTitleSection then
    local characterTexture = WINDOW_MANAGER:CreateControl("Character", ZO_StatsPanel, CT_TEXTURE)
    if characterTexture then
        characterTexture:SetDimensions(1700, 100)
        characterTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, -100, -20)
        characterTexture:SetTexture("/OblivionStyleHud/media/details/inv_tab3.dds")
    else
        d("Failed to create characterTexture")
    end
else
    d("ZO_StatsPanel or ZO_StatsPanelTitleSection is nil")
end

-- Inventory texture
if ZO_PlayerInventory and ZO_StatsPanelTitleSection then
    local inventoryTexture = WINDOW_MANAGER:CreateControl("Inventory", ZO_PlayerInventory, CT_TEXTURE)
    if inventoryTexture then
        inventoryTexture:SetDimensions(1330, 75)
        inventoryTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, -15, 30)
        inventoryTexture:SetTexture("/OblivionStyleHud/media/details/inv_tab.dds")
    else
        d("Failed to create inventoryTexture")
    end
else
    d("ZO_PlayerInventory or ZO_StatsPanelTitleSection is nil")
end

-- Inventory2 texture
if ZO_CraftBag and ZO_StatsPanelTitleSection then
    local inventory2Texture = WINDOW_MANAGER:CreateControl("Inventory2", ZO_CraftBag, CT_TEXTURE)
    if inventory2Texture then
        inventory2Texture:SetDimensions(1330, 75)
        inventory2Texture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, -15, 30)
        inventory2Texture:SetTexture("/OblivionStyleHud/media/details/inv_tab3.dds")
    else
        d("Failed to create inventory2Texture")
    end
else
    d("ZO_CraftBag or ZO_StatsPanelTitleSection is nil")
end

-- Inventory3 texture
if ZO_InventoryWallet and ZO_StatsPanelTitleSection then
    local inventory3Texture = WINDOW_MANAGER:CreateControl("Inventory3", ZO_InventoryWallet, CT_TEXTURE)
    if inventory3Texture then
        inventory3Texture:SetDimensions(1330, 75)
        inventory3Texture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, -15, 30)
        inventory3Texture:SetTexture("/OblivionStyleHud/media/details/inv_tab3.dds")
    else
        d("Failed to create inventory3Texture")
    end
else
    d("ZO_InventoryWallet or ZO_StatsPanelTitleSection is nil")
end

-- Inventory4 texture
if ZO_QuickSlot and ZO_StatsPanelTitleSection then
    local inventory4Texture = WINDOW_MANAGER:CreateControl("Inventory4", ZO_QuickSlot, CT_TEXTURE)
    if inventory4Texture then
        inventory4Texture:SetDimensions(1330, 75)
        inventory4Texture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, -15, 30)
        inventory4Texture:SetTexture("/OblivionStyleHud/media/details/inv_tab3.dds")
    else
        d("Failed to create inventory4Texture")
    end
else
    d("ZO_QuickSlot or ZO_StatsPanelTitleSection is nil")
end

-- Skills texture
if ZO_Skills and ZO_StatsPanelTitleSection then
    local skillsTexture = WINDOW_MANAGER:CreateControl("Skills", ZO_Skills, CT_TEXTURE)
    if skillsTexture then
        skillsTexture:SetDimensions(500, 500)
        skillsTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, 150, 335)
        skillsTexture:SetTexture("/OblivionStyleHud/media/details/skills.dds")
    else
        d("Failed to create skillsTexture")
    end
else
    d("ZO_Skills or ZO_StatsPanelTitleSection is nil")
end

-- Map texture
if ZO_WorldMapQuests and ZO_StatsPanelTitleSection then
    local mapTexture = WINDOW_MANAGER:CreateControl("Map", ZO_WorldMapQuests, CT_TEXTURE)
    if mapTexture then
        mapTexture:SetDimensions(550, 550)
        mapTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, 200, 265)
        mapTexture:SetTexture("/OblivionStyleHud/media/details/map.dds")
    else
        d("Failed to create mapTexture")
    end
else
    d("ZO_WorldMapQuests or ZO_StatsPanelTitleSection is nil")
end

-- Map2 texture
if ZO_WorldMapLocations and ZO_StatsPanelTitleSection then
    local map2Texture = WINDOW_MANAGER:CreateControl("Map2", ZO_WorldMapLocations, CT_TEXTURE)
    if map2Texture then
        map2Texture:SetDimensions(550, 550)
        map2Texture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, 200, 265)
        map2Texture:SetTexture("/OblivionStyleHud/media/details/map.dds")
    else
        d("Failed to create map2Texture")
    end
else
    d("ZO_WorldMapLocations or ZO_StatsPanelTitleSection is nil")
end

-- Map3 texture
if ZO_WorldMapKey and ZO_StatsPanelTitleSection then
    local map3Texture = WINDOW_MANAGER:CreateControl("Map3", ZO_WorldMapKey, CT_TEXTURE)
    if map3Texture then
        map3Texture:SetDimensions(550, 550)
        map3Texture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, 200, 265)
        map3Texture:SetTexture("/OblivionStyleHud/media/details/map.dds")
    else
        d("Failed to create map3Texture")
    end
else
    d("ZO_WorldMapKey or ZO_StatsPanelTitleSection is nil")
end

-- Map4 texture
if ZO_WorldMapFilters and ZO_StatsPanelTitleSection then
    local map4Texture = WINDOW_MANAGER:CreateControl("Map4", ZO_WorldMapFilters, CT_TEXTURE)
    if map4Texture then
        map4Texture:SetDimensions(550, 550)
        map4Texture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, 200, 265)
        map4Texture:SetTexture("/OblivionStyleHud/media/details/map.dds")
    else
        d("Failed to create map4Texture")
    end
else
    d("ZO_WorldMapFilters or ZO_StatsPanelTitleSection is nil")
end

-- Journal texture
if ZO_QuestJournal and ZO_StatsPanelTitleSection then
    local journalTexture = WINDOW_MANAGER:CreateControl("Journal", ZO_QuestJournal, CT_TEXTURE)
    if journalTexture then
        journalTexture:SetDimensions(500, 500)
        journalTexture:SetAnchor(TOPLEFT, ZO_StatsPanelTitleSection, TOPLEFT, 150, 345)
        journalTexture:SetTexture("/OblivionStyleHud/media/details/journal.dds")
    else
        d("Failed to create journalTexture")
    end
else
    d("ZO_QuestJournal or ZO_StatsPanelTitleSection is nil")
end

-- Gamepad textures
if ZO_MainMenu_Gamepad then
    local gamepadCharTexture = WINDOW_MANAGER:CreateControl("GamepadChar", ZO_MainMenu_Gamepad, CT_TEXTURE)
    if gamepadCharTexture then
        gamepadCharTexture:SetDimensions(900, 1700)
        gamepadCharTexture:SetAnchor(TOP, ZO_MainMenu_Gamepad, TOP, -200, -65)
        gamepadCharTexture:SetTexture("/OblivionStyleHud/media/interface/ob_main_background_gamepad.dds")
    else
        d("Failed to create gamepadCharTexture")
    end
end

-- Other gamepad textures are similarly handled as needed
-- GamepadInv, GamepadCollections, etc.