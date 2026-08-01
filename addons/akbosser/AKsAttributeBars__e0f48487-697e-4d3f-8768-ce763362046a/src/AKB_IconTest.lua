-- ============================================================================
-- AKsAttributeBars - Simple Icon Testing Module
-- ============================================================================
-- Simple testing module for console icon compatibility

-- Create or get the global addon namespace
AKsAttributeBars = AKsAttributeBars or {}
local AKB = AKsAttributeBars

-- Create IconTest namespace
AKB.IconTest = AKB.IconTest or {}

-- Test window reference
local testWindow = nil

-- Test icons - Real gamepad icons from actual ESO files (based on allIcons.txt)
local TEST_ICONS = {
    -- Known working Champion icons (confirmed console compatible)
    {path = "EsoUI/Art/Champion/champion_points_stamina_icon.dds", name = "Champion Stamina"},
    {path = "EsoUI/Art/Champion/champion_points_health_icon.dds", name = "Champion Health"},
    
    -- REAL Gamepad Currency Icons (confirmed to exist)
    {path = "EsoUI/Art/Currency/Gamepad/gp_gold.dds", name = "Gamepad Gold"},
    {path = "EsoUI/Art/Currency/Gamepad/gp_crowns.dds", name = "Gamepad Crowns"},
    {path = "EsoUI/Art/Currency/Gamepad/gp_alliancepoints.dds", name = "Gamepad Alliance Points"},
    {path = "EsoUI/Art/Currency/Gamepad/gp_telvar.dds", name = "Gamepad Tel Var"},
    {path = "EsoUI/Art/Currency/Gamepad/gp_inspiration.dds", name = "Gamepad Inspiration"},
    {path = "EsoUI/Art/Currency/Gamepad/gp_crown_gems.dds", name = "Gamepad Crown Gems"},
    {path = "EsoUI/Art/Currency/Gamepad/gp_eventticket.dds", name = "Gamepad Event Ticket"},
    
    -- REAL Gamepad Collectibles Icons (confirmed to exist)
    {path = "EsoUI/Art/Collectibles/gp_dlc-imperial_city.dds", name = "Gamepad Imperial City DLC"},
    {path = "EsoUI/Art/Collectibles/gp_dlc-orsinium.dds", name = "Gamepad Orsinium DLC"},
    
    -- REAL Gamepad Collections Store Icons (confirmed to exist)
    {path = "EsoUI/Art/Store/Gamepad/gp_collections_generichousing.dds", name = "Gamepad Generic Housing"},
    {path = "EsoUI/Art/Store/Gamepad/gp_collections_housing_altmerlarge.dds", name = "Gamepad Altmer Large House"},
    {path = "EsoUI/Art/Store/Gamepad/gp_collections_housing_bretonlarge.dds", name = "Gamepad Breton Large House"},
    {path = "EsoUI/Art/Store/Gamepad/gp_collections_housing_argonianlarge.dds", name = "Gamepad Argonian Large House"},
    
    -- Gamepad Character Creation Icons (confirmed to exist)
    {path = "EsoUI/Art/CharacterCreate/Gamepad/charactercreate_altmericon_up.dds", name = "Gamepad Altmer Race"},
    {path = "EsoUI/Art/CharacterCreate/Gamepad/charactercreate_bretonicon_up.dds", name = "Gamepad Breton Race"},
    {path = "EsoUI/Art/CharacterCreate/Gamepad/charactercreate_argonianicon_up.dds", name = "Gamepad Argonian Race"},
    {path = "EsoUI/Art/CharacterCreate/Gamepad/charactercreate_khajiiticon_up.dds", name = "Gamepad Khajiit Race"},
    
    -- Gamepad Arrow Icons (confirmed to exist - console compatible directional arrows!)
    {path = "EsoUI/Art/Buttons/Gamepad/gp_uparrow.dds", name = "Gamepad Up Arrow"},
    {path = "EsoUI/Art/Buttons/Gamepad/gp_downarrow.dds", name = "Gamepad Down Arrow"},
    {path = "EsoUI/Art/Buttons/Gamepad/gp_menu_rightarrow.dds", name = "Gamepad Right Arrow"},
    {path = "EsoUI/Art/Buttons/large_uparrow_up.dds", name = "Large Up Arrow"},
    {path = "EsoUI/Art/Buttons/large_downarrow_up.dds", name = "Large Down Arrow"},
    {path = "EsoUI/Art/Buttons/large_leftarrow_up.dds", name = "Large Left Arrow"},
    {path = "EsoUI/Art/Buttons/large_rightarrow_up.dds", name = "Large Right Arrow"},
    
    -- FX Arrow Icons (confirmed to exist - visual effect arrows)
    {path = "EsoUI/Art/fx/texture/arrow_01.dds", name = "FX Arrow 1"},
    {path = "EsoUI/Art/fx/texture/directionalarrow.dds", name = "Directional Arrow"},
    {path = "EsoUI/Art/fx/texture/directionalarrowbw.dds", name = "Directional Arrow BW"},
    {path = "EsoUI/Art/fx/texture/white_arrow.dds", name = "White Arrow"},
    {path = "EsoUI/Art/fx/texture/modelfxtextures/arrows_001_d.dds", name = "Model FX Arrows Diffuse"},
    
    -- Tutorial Arrow Icons (confirmed to exist - smithing tutorial arrows)
    {path = "EsoUI/Art/tutorial/smithing_leftarrow_up.dds", name = "Tutorial Left Arrow"},
    {path = "EsoUI/Art/tutorial/smithing_rightarrow_up.dds", name = "Tutorial Right Arrow"},

    -- Known working crafting icons (for comparison)
    {path = "EsoUI/Art/Inventory/inventory_tabIcon_consumables_up.dds", name = "Consumables Tab"},
    {path = "EsoUI/Art/Icons/crafting_bread_001.dds", name = "Crafting Bread"},
    {path = "EsoUI/Art/Icons/crafting_meat_001.dds", name = "Crafting Meat"},
}

-- Create simple test window using addon's console-compatible patterns
function AKB.IconTest.CreateTestWindow()
    if testWindow then
        return testWindow
    end
    
    -- Create main window using console-safe method
    testWindow = WINDOW_MANAGER and WINDOW_MANAGER.CreateTopLevelWindow and 
                 WINDOW_MANAGER:CreateTopLevelWindow(AKB.Utils.GenerateUniqueName("AKB_IconTest"))
    
    if not testWindow then
        AKB.Print("Failed to create icon test window")
        return nil
    end
    
    -- Set window properties using console-safe approach
    pcall(function()
        testWindow:SetDimensions(900, 750)  -- Larger window for more icons
        testWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 50, 50)
        testWindow:SetClampedToScreen(true)
        testWindow:SetMouseEnabled(false)
        testWindow:SetMovable(false)
        testWindow:SetHidden(true)
    end)
    
    -- Create simple background using same pattern as other bars
    local background = WINDOW_MANAGER and WINDOW_MANAGER.CreateControl and 
                       WINDOW_MANAGER:CreateControl(nil, testWindow, CT_TEXTURE)
    if background then
        pcall(function()
            background:SetAnchorFill(testWindow)
            background:SetTexture("EsoUI/Art/ChatWindow/chat_BG_opaque.dds")
            background:SetColor(0, 0, 0, 0.8)
            if background.SetDrawTier then 
                background:SetDrawTier(AKB.Utils.DRAW_TIERS.LOW) 
            end
            if background.SetDrawLayer then 
                background:SetDrawLayer(DL_BACKGROUND or 0) 
            end
        end)
    end
    
    -- Create title text using console-compatible method
    local titleText = WINDOW_MANAGER and WINDOW_MANAGER.CreateControl and 
                      WINDOW_MANAGER:CreateControl(nil, testWindow, CT_LABEL)
    if titleText then
        pcall(function()
            titleText:SetAnchor(TOPLEFT, testWindow, TOPLEFT, 10, 10)
            titleText:SetFont("$(BOLD_FONT)|16|thick-outline")  -- Console-compatible font like enemy bars
            titleText:SetText("Icon Test - All " .. #TEST_ICONS .. " Icons")
            titleText:SetColor(1, 1, 1, 1)
        end)
    end
    
    -- Create icon slots in a 8x8 grid to show all icons
    local iconSize = 28  -- Slightly smaller to fit more
    local spacing = 10   -- Tighter spacing
    local startX = 25
    local startY = 50
    local cols = 8
    local rows = math.ceil(#TEST_ICONS / cols)  -- Calculate rows needed
    
    for row = 1, rows do
        for col = 1, cols do
            local index = (row - 1) * cols + col
            if index <= #TEST_ICONS and TEST_ICONS[index] then
                local iconData = TEST_ICONS[index]
                
                -- Create icon
                local iconControl = WINDOW_MANAGER and WINDOW_MANAGER.CreateControl and 
                                   WINDOW_MANAGER:CreateControl(nil, testWindow, CT_TEXTURE)
                if iconControl then
                    pcall(function()
                        local xPos = startX + (col - 1) * (iconSize + spacing)
                        local yPos = startY + (row - 1) * (iconSize + spacing + 22)  -- Adjust for smaller icons
                        
                        iconControl:SetAnchor(TOPLEFT, testWindow, TOPLEFT, xPos, yPos)
                        iconControl:SetDimensions(iconSize, iconSize)
                        iconControl:SetColor(1, 1, 1, 1)
                        
                        -- Set texture with error handling
                        local success = pcall(function()
                            iconControl:SetTexture(iconData.path)
                        end)
                        
                        if not success then
                            -- If texture loading fails, use error texture
                            iconControl:SetTexture("EsoUI/Art/Buttons/decline_up.dds")
                            iconControl:SetColor(1, 0.5, 0.5, 1) -- Red tint for error
                        end
                        
                        if iconControl.SetDrawTier then 
                            iconControl:SetDrawTier(AKB.Utils.DRAW_TIERS.HIGH) 
                        end
                        if iconControl.SetDrawLayer then 
                            iconControl:SetDrawLayer(DL_OVERLAY or 6) 
                        end
                    end)
                    
                    -- Create label for icon name
                    local nameLabel = WINDOW_MANAGER and WINDOW_MANAGER.CreateControl and 
                                     WINDOW_MANAGER:CreateControl(nil, testWindow, CT_LABEL)
                    if nameLabel then
                        pcall(function()
                            nameLabel:SetAnchor(TOP, iconControl, BOTTOM, 0, 2)  -- Tighter spacing
                            nameLabel:SetFont("$(BOLD_FONT)|8|thick-outline")   -- Smaller font for more icons
                            nameLabel:SetText(iconData.name)
                            nameLabel:SetColor(1, 1, 1, 1)
                            nameLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
                            nameLabel:SetDimensionConstraints(0, 0, iconSize + spacing, 18)  -- Smaller text area
                        end)
                    end
                end
            end
        end
    end
    
    return testWindow
end

-- Show the test window
function AKB.IconTest.ShowTest()
    if not testWindow then
        AKB.IconTest.CreateTestWindow()
    end
    
    if testWindow then
        pcall(function()
            testWindow:SetHidden(false)
        end)
    end
end

-- Hide the test window
function AKB.IconTest.HideTest()
    if testWindow then
        pcall(function()
            testWindow:SetHidden(true)
        end)
    end
end

-- Initialize the test module
function AKB.IconTest.Initialize()
    -- Single slash command
    SLASH_COMMANDS["/akbtest"] = function()
        if testWindow and not testWindow:IsHidden() then
            AKB.IconTest.HideTest()
        else
            AKB.IconTest.ShowTest()
        end
    end
end

-- Cleanup
function AKB.IconTest.Cleanup()
    if testWindow then
        pcall(function()
            testWindow:SetHidden(true)
        end)
        testWindow = nil
    end
end
