local addonName = "HomeStorageTracker"
local addon = {}
addon.name = addonName
local addonVersion = "14.0"
addon.version = addonVersion

-- Default storage capacities (fallback values)
local DEFAULT_HOME_STORAGE_SLOTS = 360
local DEFAULT_BANK_SLOTS = 240
local DEFAULT_BACKPACK_SLOTS = 60
local DEFAULT_FURNITURE_VAULT_SLOTS = 500

-- Forward declarations for functions
local ToggleGoldDisplay, ToggleFurnitureVaultDisplay, ToggleCoffersDisplay

-- Fallback coffer names
local COFFER_FALLBACK_NAMES = {
    "Coffer 1", "Coffer 2", "Coffer 3", "Coffer 4", "Coffer 5",
    "Coffer 6", "Coffer 7", "Coffer 8", "Coffer 9", "Coffer 10",
}

-- Get the display name for a house bank bag
-- Priority: player-set nickname > collectible default name > fallback "Coffer N"
local function GetCofferDisplayName(bagId)
    local idx = bagId - BAG_HOUSE_BANK_ONE + 1
    local fallback = COFFER_FALLBACK_NAMES[idx] or ("Coffer "..idx)

    if GetCollectibleForHouseBankBag then
        local collectibleId = GetCollectibleForHouseBankBag(bagId)
        if collectibleId and collectibleId > 0 then
            -- Try player-set nickname first
            if GetCollectibleNickname then
                local nickname = GetCollectibleNickname(collectibleId)
                if nickname and nickname ~= "" then
                    return nickname
                end
            end
            -- Fall back to the collectible's default name
            if GetCollectibleName then
                local name = GetCollectibleName(collectibleId)
                if name and name ~= "" then
                    return zo_strformat("<<1>>", name)
                end
            end
        end
    end

    return fallback
end

-- Dynamic storage capacity calculation
local function GetHomeStorageMax()
    local totalSlots = 0
    for i = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
        local bagSize = GetBagSize(i)
        if bagSize and bagSize > 0 then
            totalSlots = totalSlots + bagSize
        end
    end
    return totalSlots > 0 and totalSlots or DEFAULT_HOME_STORAGE_SLOTS
end

local function GetBankStorageMax()
    local bankSize = GetBagSize(BAG_BANK)
    return (bankSize and bankSize > 0) and bankSize or DEFAULT_BANK_SLOTS
end

local function GetBackpackStorageMax()
    local backpackSize = GetBagSize(BAG_BACKPACK)
    return (backpackSize and backpackSize > 0) and backpackSize or DEFAULT_BACKPACK_SLOTS
end

local function GetFurnitureVaultMax()
    if BAG_FURNITURE_VAULT then
        local vaultSize = GetBagSize(BAG_FURNITURE_VAULT)
        if vaultSize and vaultSize > 0 then
            return vaultSize
        end
    end
    return DEFAULT_FURNITURE_VAULT_SLOTS
end

local function IsFurnitureVaultAvailable()
    if BAG_FURNITURE_VAULT then
        local vaultSize = GetBagSize(BAG_FURNITURE_VAULT)
        return vaultSize and vaultSize > 0
    end
    return false
end

-- SavedVariables setup
local savedVarsName = addonName.."SavedVars"
local defaultSavedVars = {
    accountWide = {
        lastHomeUsed = 0,
        lastBankUsed = 0,
        lastBankMax = DEFAULT_BANK_SLOTS,
        lastBackpackUsed = 0,
        lastBackpackMax = DEFAULT_BACKPACK_SLOTS,
        lastCharacterGold = 0,
        lastBankGold = 0,
        lastFurnitureVaultUsed = 0,
        lastFurnitureVaultMax = DEFAULT_FURNITURE_VAULT_SLOTS,
        lastUpdate = 0,
        lastCofferData = {}
    },
    perCharacter = {
        posX = nil,
        posY = nil,
        isVisible = true,
        showBank = true,
        showBackpack = true,
        showGold = true,
        showFurnitureVault = true,
        showCoffers = false,
        lockWindow = false,
        horizontalLayout = true
    }
}

local function GetCharacterSettings()
    local charKey = GetUnitName("player").."@"..GetWorldName()
    if not addon.savedVars.perCharacter[charKey] then
        addon.savedVars.perCharacter[charKey] = ZO_DeepTableCopy(defaultSavedVars.perCharacter)
    end
    return addon.savedVars.perCharacter[charKey]
end

-- Scene Visibility Management
local function UpdateFragmentVisibility()
    local charSettings = GetCharacterSettings()
    local hudScene = SCENE_MANAGER:GetScene("hud")
    local hudUiScene = SCENE_MANAGER:GetScene("hudui")
    
    if not addon.fragment then return end

    if charSettings.isVisible then
        hudScene:AddFragment(addon.fragment)
        hudUiScene:AddFragment(addon.fragment)
    else
        hudScene:RemoveFragment(addon.fragment)
        hudUiScene:RemoveFragment(addon.fragment)
    end
end

-- Resize the window width to tightly fit all visible content (horizontal layout only)
local function ResizeWindowToFit()
    if not addon.window then return end
    local charSettings = GetCharacterSettings()

    if charSettings.horizontalLayout then
        local maxRight = 0
        local windowLeft = addon.window:GetLeft()

        -- Collect all possible text controls
        local allTexts = { addon.homeText, addon.bankText, addon.backpackText,
                           addon.goldText, addon.bankGoldText, addon.vaultText }
        if addon.cofferTexts then
            for _, ct in pairs(addon.cofferTexts) do
                allTexts[#allTexts + 1] = ct
            end
        end

        for _, ctrl in ipairs(allTexts) do
            if ctrl and not ctrl:IsHidden() then
                local right = ctrl:GetRight()
                if right and right > maxRight then
                    maxRight = right
                end
            end
        end

        if maxRight > 0 and windowLeft then
            local newWidth = maxRight - windowLeft + 8
            if newWidth > 0 then
                addon.window:SetWidth(newWidth)
            end
        end
    end
end

-- Create or update UI elements
local function CreateUI()
    local charSettings = GetCharacterSettings()
    
    -- Create main window
    if not addon.window then
        addon.window = WINDOW_MANAGER:CreateTopLevelWindow(addonName.."Window")
        addon.window:SetMouseEnabled(not charSettings.lockWindow)
        addon.window:SetMovable(not charSettings.lockWindow)
        addon.window:SetClampedToScreen(true)
        addon.window:SetDrawLayer(DL_OVERLAY)
        
        -- Initialize Scene Fragment
        addon.fragment = ZO_SimpleSceneFragment:New(addon.window)

        -- Background
        addon.backdrop = WINDOW_MANAGER:CreateControl(addonName.."Backdrop", addon.window, CT_BACKDROP)
        addon.backdrop:SetAnchorFill()
        addon.backdrop:SetCenterColor(0.1, 0.1, 0.1, 0.8)
        addon.backdrop:SetEdgeColor(0.4, 0.4, 0.4, 0.5)
        
        if charSettings.posX and charSettings.posY then
            addon.window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, charSettings.posX, charSettings.posY)
        else
            addon.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
        end
        
        addon.window:SetHandler("OnMoveStop", function(self)
            if not charSettings.lockWindow then
                charSettings.posX = self:GetLeft()
                charSettings.posY = self:GetTop()
            end
        end)
    end
    
    -- Hide existing controls
    if addon.homeIcon then addon.homeIcon:SetHidden(true) end
    if addon.homeText then addon.homeText:SetHidden(true) end
    if addon.bankIcon then addon.bankIcon:SetHidden(true) end
    if addon.bankText then addon.bankText:SetHidden(true) end
    if addon.backpackIcon then addon.backpackIcon:SetHidden(true) end
    if addon.backpackText then addon.backpackText:SetHidden(true) end
    if addon.goldIcon then addon.goldIcon:SetHidden(true) end
    if addon.goldText then addon.goldText:SetHidden(true) end
    if addon.bankGoldIcon then addon.bankGoldIcon:SetHidden(true) end
    if addon.bankGoldText then addon.bankGoldText:SetHidden(true) end
    if addon.vaultIcon then addon.vaultIcon:SetHidden(true) end
    if addon.vaultText then addon.vaultText:SetHidden(true) end
    if addon.cofferIcons then
        for i = 1, 10 do
            if addon.cofferIcons[i] then addon.cofferIcons[i]:SetHidden(true) end
            if addon.cofferTexts[i] then addon.cofferTexts[i]:SetHidden(true) end
        end
    end
    
    -- Count active coffers
    local activeCofferCount = 0
    if charSettings.showCoffers then
        for i = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
            local bagSize = GetBagSize(i)
            if (bagSize and bagSize > 0) then
                activeCofferCount = activeCofferCount + 1
            elseif addon.savedVars.accountWide.lastCofferData
               and addon.savedVars.accountWide.lastCofferData[i] then
                activeCofferCount = activeCofferCount + 1
            end
        end
    end
    local cofferMode = charSettings.showCoffers and activeCofferCount > 0

    -- Calculate layout
    local visibleElements = cofferMode and activeCofferCount or 1
    if charSettings.showFurnitureVault then visibleElements = visibleElements + 1 end
    if charSettings.showBank then visibleElements = visibleElements + 1 end
    if charSettings.showBackpack then visibleElements = visibleElements + 1 end
    if charSettings.showGold then visibleElements = visibleElements + 2 end 
    
    local windowWidth, windowHeight
    if charSettings.horizontalLayout then
        -- Start oversized; ResizeWindowToFit() will shrink after text is set
        windowWidth = visibleElements * 200 + 20
        windowHeight = 42 
    else
        windowWidth = cofferMode and 280 or 180
        windowHeight = visibleElements * 32 + (visibleElements - 1) * 5 + 10
    end
    
    addon.window:SetDimensions(windowWidth, windowHeight)
    
    local previousControl = nil
    
    -- 1. House (combined or individual coffers)
    if cofferMode then
        -- Individual coffer display mode
        if not addon.cofferIcons then addon.cofferIcons = {} end
        if not addon.cofferTexts then addon.cofferTexts = {} end

        for i = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
            local bagSize = GetBagSize(i)
            local hasSavedData = addon.savedVars.accountWide.lastCofferData
                and addon.savedVars.accountWide.lastCofferData[i] ~= nil
            if (bagSize and bagSize > 0) or hasSavedData then
                local idx = i - BAG_HOUSE_BANK_ONE + 1

                if not addon.cofferIcons[idx] then
                    addon.cofferIcons[idx] = WINDOW_MANAGER:CreateControl(
                        addonName.."CofferIcon"..idx, addon.window, CT_TEXTURE)
                    addon.cofferIcons[idx]:SetDimensions(32, 30)
                    addon.cofferIcons[idx]:SetTexture("HomeStorageTracker/house.dds")
                end
                if not addon.cofferTexts[idx] then
                    addon.cofferTexts[idx] = WINDOW_MANAGER:CreateControl(
                        addonName.."CofferText"..idx, addon.window, CT_LABEL)
                    addon.cofferTexts[idx]:SetFont("ZoFontGame")
                    addon.cofferTexts[idx]:SetColor(1, 1, 1, 1)
                    addon.cofferTexts[idx]:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
                    addon.cofferTexts[idx]:SetVerticalAlignment(TEXT_ALIGN_CENTER)
                end

                addon.cofferIcons[idx]:ClearAnchors()
                addon.cofferTexts[idx]:ClearAnchors()

                if charSettings.horizontalLayout then
                    if previousControl == nil then
                        addon.cofferIcons[idx]:SetAnchor(TOPLEFT, addon.window, TOPLEFT, 5, 6)
                    else
                        addon.cofferIcons[idx]:SetAnchor(LEFT, previousControl, RIGHT, 10, 0)
                    end
                    -- Width 0 = auto-size to text content (no truncation)
                    addon.cofferTexts[idx]:SetDimensions(0, 30)
                    addon.cofferTexts[idx]:SetAnchor(LEFT, addon.cofferIcons[idx], RIGHT, 3, 0)
                else
                    if previousControl == nil then
                        addon.cofferIcons[idx]:SetAnchor(TOPLEFT, addon.window, TOPLEFT, 5, 5)
                    else
                        addon.cofferIcons[idx]:SetAnchor(TOPLEFT, previousControl, BOTTOMLEFT, 0, 5)
                    end
                    addon.cofferTexts[idx]:SetDimensions(230, 30)
                    addon.cofferTexts[idx]:SetAnchor(LEFT, addon.cofferIcons[idx], RIGHT, 8, 0)
                end

                addon.cofferIcons[idx]:SetHidden(false)
                addon.cofferTexts[idx]:SetText("Loading...")
                addon.cofferTexts[idx]:SetHidden(false)
                previousControl = charSettings.horizontalLayout
                    and addon.cofferTexts[idx] or addon.cofferIcons[idx]
            end
        end

        -- Hide the combined home row
        if addon.homeIcon then addon.homeIcon:SetHidden(true) end
        if addon.homeText then addon.homeText:SetHidden(true) end
    else
        -- Combined home storage display (original behavior)
        if not addon.homeIcon then
            addon.homeIcon = WINDOW_MANAGER:CreateControl(addonName.."HomeIcon", addon.window, CT_TEXTURE)
            addon.homeIcon:SetDimensions(32, 30)
            addon.homeIcon:SetTexture("HomeStorageTracker/house.dds")
        end

        if not addon.homeText then
            addon.homeText = WINDOW_MANAGER:CreateControl(addonName.."HomeText", addon.window, CT_LABEL)
            addon.homeText:SetFont("ZoFontGame")
            addon.homeText:SetColor(1, 1, 1, 1)
            addon.homeText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            addon.homeText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end

        addon.homeIcon:ClearAnchors()
        addon.homeText:ClearAnchors()

        if charSettings.horizontalLayout then
            addon.homeIcon:SetAnchor(TOPLEFT, addon.window, TOPLEFT, 5, 6)
            addon.homeText:SetDimensions(80, 30)
            addon.homeText:SetAnchor(LEFT, addon.homeIcon, RIGHT, 3, 0)
        else
            addon.homeIcon:SetAnchor(TOPLEFT, addon.window, TOPLEFT, 5, 5)
            addon.homeText:SetDimensions(120, 30)
            addon.homeText:SetAnchor(LEFT, addon.homeIcon, RIGHT, 8, 0)
        end

        addon.homeIcon:SetHidden(false)
        addon.homeText:SetText("Loading...")
        addon.homeText:SetHidden(false)
        previousControl = charSettings.horizontalLayout and addon.homeText or addon.homeIcon
    end

    -- 2. Vault
    if charSettings.showFurnitureVault then
        if not addon.vaultIcon then
            addon.vaultIcon = WINDOW_MANAGER:CreateControl(addonName.."VaultIcon", addon.window, CT_TEXTURE)
            addon.vaultIcon:SetDimensions(32, 32)
            addon.vaultIcon:SetTexture("HomeStorageTracker/vault.dds")
        end
        if not addon.vaultText then
            addon.vaultText = WINDOW_MANAGER:CreateControl(addonName.."VaultText", addon.window, CT_LABEL)
            addon.vaultText:SetFont("ZoFontGame")
            addon.vaultText:SetColor(1, 1, 1, 1)
            addon.vaultText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            addon.vaultText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end
        addon.vaultIcon:ClearAnchors()
        addon.vaultText:ClearAnchors()
        
        if charSettings.horizontalLayout then
            addon.vaultIcon:SetAnchor(LEFT, previousControl, RIGHT, 10, 0)
            addon.vaultText:SetDimensions(80, 30)
            addon.vaultText:SetAnchor(LEFT, addon.vaultIcon, RIGHT, 3, 0)
        else
            addon.vaultIcon:SetAnchor(TOPLEFT, previousControl, BOTTOMLEFT, 0, 5)
            addon.vaultText:SetDimensions(120, 30)
            addon.vaultText:SetAnchor(LEFT, addon.vaultIcon, RIGHT, 8, 0)
        end
        addon.vaultIcon:SetHidden(false)
        addon.vaultText:SetText("Loading...")
        addon.vaultText:SetHidden(false)
        previousControl = charSettings.horizontalLayout and addon.vaultText or addon.vaultIcon
    end

    -- 3. Bank
    if charSettings.showBank then
        if not addon.bankIcon then
            addon.bankIcon = WINDOW_MANAGER:CreateControl(addonName.."BankIcon", addon.window, CT_TEXTURE)
            addon.bankIcon:SetDimensions(32, 30)
            addon.bankIcon:SetTexture("HomeStorageTracker/bank.dds")
        end
        if not addon.bankText then
            addon.bankText = WINDOW_MANAGER:CreateControl(addonName.."BankText", addon.window, CT_LABEL)
            addon.bankText:SetFont("ZoFontGame")
            addon.bankText:SetColor(1, 1, 1, 1)
            addon.bankText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            addon.bankText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end
        addon.bankIcon:ClearAnchors()
        addon.bankText:ClearAnchors()
        
        if charSettings.horizontalLayout then
            addon.bankIcon:SetAnchor(LEFT, previousControl, RIGHT, 10, 0)
            addon.bankText:SetDimensions(80, 30)
            addon.bankText:SetAnchor(LEFT, addon.bankIcon, RIGHT, 3, 0)
        else
            addon.bankIcon:SetAnchor(TOPLEFT, previousControl, BOTTOMLEFT, 0, 5)
            addon.bankText:SetDimensions(120, 30)
            addon.bankText:SetAnchor(LEFT, addon.bankIcon, RIGHT, 8, 0)
        end
        addon.bankIcon:SetHidden(false)
        addon.bankText:SetText("Loading...")
        addon.bankText:SetHidden(false)
        previousControl = charSettings.horizontalLayout and addon.bankText or addon.bankIcon
    end

    -- 4. Backpack
    if charSettings.showBackpack then
        if not addon.backpackIcon then
            addon.backpackIcon = WINDOW_MANAGER:CreateControl(addonName.."BackpackIcon", addon.window, CT_TEXTURE)
            addon.backpackIcon:SetDimensions(32, 30)
            addon.backpackIcon:SetTexture("HomeStorageTracker/bag.dds")
        end
        if not addon.backpackText then
            addon.backpackText = WINDOW_MANAGER:CreateControl(addonName.."BackpackText", addon.window, CT_LABEL)
            addon.backpackText:SetFont("ZoFontGame")
            addon.backpackText:SetColor(1, 1, 1, 1)
            addon.backpackText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            addon.backpackText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end
        addon.backpackIcon:ClearAnchors()
        addon.backpackText:ClearAnchors()
        
        if charSettings.horizontalLayout then
            addon.backpackIcon:SetAnchor(LEFT, previousControl, RIGHT, 10, 0)
            addon.backpackText:SetDimensions(80, 30)
            addon.backpackText:SetAnchor(LEFT, addon.backpackIcon, RIGHT, 3, 0)
        else
            addon.backpackIcon:SetAnchor(TOPLEFT, previousControl, BOTTOMLEFT, 0, 5)
            addon.backpackText:SetDimensions(120, 30)
            addon.backpackText:SetAnchor(LEFT, addon.backpackIcon, RIGHT, 8, 0)
        end
        addon.backpackIcon:SetHidden(false)
        addon.backpackText:SetText("Loading...")
        addon.backpackText:SetHidden(false)
        previousControl = charSettings.horizontalLayout and addon.backpackText or addon.backpackIcon
    end

    -- 5 & 6. Gold
    if charSettings.showGold then
        -- Bank Gold
        if not addon.bankGoldIcon then
            addon.bankGoldIcon = WINDOW_MANAGER:CreateControl(addonName.."BankGoldIcon", addon.window, CT_TEXTURE)
            addon.bankGoldIcon:SetDimensions(32, 32)
            addon.bankGoldIcon:SetTexture("HomeStorageTracker/bcoins.dds")
        end
        if not addon.bankGoldText then
            addon.bankGoldText = WINDOW_MANAGER:CreateControl(addonName.."BankGoldText", addon.window, CT_LABEL)
            addon.bankGoldText:SetFont("ZoFontGame")
            addon.bankGoldText:SetColor(1, 1, 1, 1)
            addon.bankGoldText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            addon.bankGoldText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end
        addon.bankGoldIcon:ClearAnchors()
        addon.bankGoldText:ClearAnchors()
        
        if charSettings.horizontalLayout then
            addon.bankGoldIcon:SetAnchor(LEFT, previousControl, RIGHT, 10, 0)
            addon.bankGoldText:SetDimensions(80, 30)
            addon.bankGoldText:SetAnchor(LEFT, addon.bankGoldIcon, RIGHT, 3, 0)
        else
            addon.bankGoldIcon:SetAnchor(TOPLEFT, previousControl, BOTTOMLEFT, 0, 5)
            addon.bankGoldText:SetDimensions(120, 30)
            addon.bankGoldText:SetAnchor(LEFT, addon.bankGoldIcon, RIGHT, 8, 0)
        end
        addon.bankGoldIcon:SetHidden(false)
        addon.bankGoldText:SetText("Loading...")
        addon.bankGoldText:SetHidden(false)
        previousControl = charSettings.horizontalLayout and addon.bankGoldText or addon.bankGoldIcon

        -- Player Gold
        if not addon.goldIcon then
            addon.goldIcon = WINDOW_MANAGER:CreateControl(addonName.."GoldIcon", addon.window, CT_TEXTURE)
            addon.goldIcon:SetDimensions(32, 32)
            addon.goldIcon:SetTexture("HomeStorageTracker/pcoins.dds")
        end
        if not addon.goldText then
            addon.goldText = WINDOW_MANAGER:CreateControl(addonName.."GoldText", addon.window, CT_LABEL)
            addon.goldText:SetFont("ZoFontGame")
            addon.goldText:SetColor(1, 1, 1, 1)
            addon.goldText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            addon.goldText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end
        addon.goldIcon:ClearAnchors()
        addon.goldText:ClearAnchors()
        
        if charSettings.horizontalLayout then
            addon.goldIcon:SetAnchor(LEFT, previousControl, RIGHT, 10, 0)
            addon.goldText:SetDimensions(80, 30)
            addon.goldText:SetAnchor(LEFT, addon.goldIcon, RIGHT, 3, 0)
        else
            addon.goldIcon:SetAnchor(TOPLEFT, previousControl, BOTTOMLEFT, 0, 5)
            addon.goldText:SetDimensions(120, 30)
            addon.goldText:SetAnchor(LEFT, addon.goldIcon, RIGHT, 8, 0)
        end
        addon.goldIcon:SetHidden(false)
        addon.goldText:SetText("Loading...")
        addon.goldText:SetHidden(false)
        previousControl = charSettings.horizontalLayout and addon.goldText or addon.goldIcon
    end

    UpdateFragmentVisibility()
    UpdateDisplay()
end

-- Update storage display
function UpdateDisplay()
    if not addon.window then return end
    
    local charSettings = GetCharacterSettings()
    local anyCurrent = false
    local cofferMode = charSettings.showCoffers
    
    -- Home: always gather per-coffer data
    local homeUsed = 0
    local homeMax = GetHomeStorageMax()
    for i = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
        local bagUsed = GetNumBagUsedSlots(i)
        local bagMax = GetBagSize(i)
        if bagUsed and bagUsed > 0 then
            homeUsed = homeUsed + bagUsed
        end
        -- Always save per-coffer data for coffer mode
        if bagMax and bagMax > 0 then
            if not addon.savedVars.accountWide.lastCofferData then
                addon.savedVars.accountWide.lastCofferData = {}
            end
            addon.savedVars.accountWide.lastCofferData[i] = {
                used = bagUsed or 0,
                max = bagMax,
                name = GetCofferDisplayName(i),
            }
        end
    end
    if homeUsed > 0 then
        addon.savedVars.accountWide.lastHomeUsed = homeUsed
        anyCurrent = true
    else
        homeUsed = addon.savedVars.accountWide.lastHomeUsed or 0
    end

    if cofferMode then
        -- Individual coffer display
        if addon.cofferTexts then
            for i = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
                local idx = i - BAG_HOUSE_BANK_ONE + 1
                if addon.cofferTexts[idx] and not addon.cofferTexts[idx]:IsHidden() then
                    local cofferUsed = 0
                    local cofferMax = 0
                    local displayName = COFFER_FALLBACK_NAMES[idx]

                    local bagUsed = GetNumBagUsedSlots(i)
                    local bagMax = GetBagSize(i)
                    if bagMax and bagMax > 0 then
                        cofferUsed = bagUsed or 0
                        cofferMax = bagMax
                        displayName = GetCofferDisplayName(i)
                    elseif addon.savedVars.accountWide.lastCofferData
                       and addon.savedVars.accountWide.lastCofferData[i] then
                        local saved = addon.savedVars.accountWide.lastCofferData[i]
                        cofferUsed = saved.used or 0
                        cofferMax = saved.max or 0
                        if saved.name and saved.name ~= "" then
                            displayName = saved.name
                        end
                    end

                    if cofferMax > 0 then
                        local cofferPercent = math.floor((cofferUsed / cofferMax) * 100 + 0.5)
                        local cofferColor = cofferPercent >= 90 and "|cFF0000"
                            or cofferPercent >= 70 and "|cFFFF00" or "|c00FF00"

                        addon.cofferTexts[idx]:SetText(string.format(
                            "|cAABBFF%s|r %s%d|r/%d",
                            displayName, cofferColor, cofferUsed, cofferMax))
                    end
                end
            end
        end
    else
        -- Combined home display (original)
        if addon.homeText then
            local homePercent = math.floor((homeUsed / homeMax) * 100 + 0.5)
            local homeColor = homePercent >= 90 and "|cFF0000"
                or homePercent >= 70 and "|cFFFF00" or "|c00FF00"

            if charSettings.horizontalLayout then
                addon.homeText:SetText(string.format("%s%d|r/%d", homeColor, homeUsed, homeMax))
            else
                addon.homeText:SetText(string.format(
                    "%s%d|r/|cFFFFFF%d|r (%d%%)", homeColor, homeUsed, homeMax, homePercent))
            end
        end
    end

    -- Bank (always update even if controls are hidden by scene)
    if charSettings.showBank then
        local bankUsed = GetNumBagUsedSlots(BAG_BANK) or 0
        local bankMax = GetBankStorageMax()
        addon.savedVars.accountWide.lastBankUsed = bankUsed
        addon.savedVars.accountWide.lastBankMax = bankMax
        anyCurrent = true
        
        local bankPercent = math.floor((bankUsed/bankMax)*100 + 0.5)
        local bankColor = bankPercent >= 90 and "|cFF0000" or bankPercent >= 70 and "|cFFFF00" or "|c00FF00"
        
        if addon.bankText then
            if charSettings.horizontalLayout then
                addon.bankText:SetText(string.format("%s%d|r/%d", bankColor, bankUsed, bankMax))
            else
                addon.bankText:SetText(string.format("%s%d|r/|cFFFFFF%d|r (%d%%)", bankColor, bankUsed, bankMax, bankPercent))
            end
        end
    end

    -- Backpack (always update even if controls are hidden by scene)
    if charSettings.showBackpack then
        local backpackUsed = GetNumBagUsedSlots(BAG_BACKPACK) or 0
        local backpackMax = GetBackpackStorageMax()
        addon.savedVars.accountWide.lastBackpackUsed = backpackUsed
        addon.savedVars.accountWide.lastBackpackMax = backpackMax
        anyCurrent = true
        
        local backpackPercent = math.floor((backpackUsed/backpackMax)*100 + 0.5)
        local backpackColor = backpackPercent >= 90 and "|cFF0000" or backpackPercent >= 70 and "|cFFFF00" or "|c00FF00"
        
        if addon.backpackText then
            if charSettings.horizontalLayout then
                addon.backpackText:SetText(string.format("%s%d|r/%d", backpackColor, backpackUsed, backpackMax))
            else
                addon.backpackText:SetText(string.format("%s%d|r/|cFFFFFF%d|r (%d%%)", backpackColor, backpackUsed, backpackMax, backpackPercent))
            end
        end
    end

    -- Gold (always update data even if controls are hidden)
    if charSettings.showGold then
        local characterGold = GetCurrentMoney()
        local bankGold = GetBankedMoney() or 0
        addon.savedVars.accountWide.lastCharacterGold = characterGold
        addon.savedVars.accountWide.lastBankGold = bankGold
        
        local function FormatGold(amount)
            local formatted = tostring(amount)
            local k = 1
            while k < string.len(formatted) do
                if (string.len(formatted) - k + 1) % 3 == 0 and k ~= 1 then
                    formatted = string.sub(formatted, 1, k - 1) .. "," .. string.sub(formatted, k)
                    k = k + 1
                end
                k = k + 1
            end
            return formatted
        end
        
        local charGoldStr = "|cFFD700"..FormatGold(characterGold).."|r"
        local bankGoldStr = "|cFFD700"..FormatGold(bankGold).."|r"
        
        if addon.goldText then
            addon.goldText:SetText(charGoldStr)
        end
        if addon.bankGoldText then
            addon.bankGoldText:SetText(bankGoldStr)
        end
    end

    -- Vault (always update even if controls are hidden by scene)
    if charSettings.showFurnitureVault then
        local vaultUsed = 0
        local vaultMax = DEFAULT_FURNITURE_VAULT_SLOTS
        
        if IsFurnitureVaultAvailable() then
            vaultUsed = GetNumBagUsedSlots(BAG_FURNITURE_VAULT) or 0
            vaultMax = GetFurnitureVaultMax()
            addon.savedVars.accountWide.lastFurnitureVaultUsed = vaultUsed
            addon.savedVars.accountWide.lastFurnitureVaultMax = vaultMax
        else
            vaultUsed = addon.savedVars.accountWide.lastFurnitureVaultUsed or 0
            vaultMax = addon.savedVars.accountWide.lastFurnitureVaultMax or DEFAULT_FURNITURE_VAULT_SLOTS
        end
        
        local vaultPercent = math.floor((vaultUsed/vaultMax)*100 + 0.5)
        local vaultColor = vaultPercent >= 90 and "|cFF0000" or vaultPercent >= 70 and "|cFFFF00" or "|c00FF00"
        
        if addon.vaultText then
            if charSettings.horizontalLayout then
                addon.vaultText:SetText(string.format("%s%d|r/%d", vaultColor, vaultUsed, vaultMax))
            else
                addon.vaultText:SetText(string.format("%s%d|r/|cFFFFFF%d|r (%d%%)", vaultColor, vaultUsed, vaultMax, vaultPercent))
            end
        end
    end
    
    if anyCurrent then
        addon.savedVars.accountWide.lastUpdate = GetTimeStamp()
    end

    -- Auto-resize window to fit content
    ResizeWindowToFit()
end

-- Toggles
ToggleGoldDisplay = function()
    local charSettings = GetCharacterSettings()
    charSettings.showGold = not charSettings.showGold
    CreateUI()
    d("Gold display "..(charSettings.showGold and "shown" or "hidden"))
end

ToggleFurnitureVaultDisplay = function()
    local charSettings = GetCharacterSettings()
    charSettings.showFurnitureVault = not charSettings.showFurnitureVault
    CreateUI()
    d("Furniture Vault display "..(charSettings.showFurnitureVault and "shown" or "hidden"))
end

ToggleCoffersDisplay = function()
    local charSettings = GetCharacterSettings()
    charSettings.showCoffers = not charSettings.showCoffers
    CreateUI()
    d("Individual coffers display "..(charSettings.showCoffers and "shown (per-coffer)" or "hidden (combined)"))
end

local function ToggleVisibility()
    local charSettings = GetCharacterSettings()
    charSettings.isVisible = not charSettings.isVisible
    UpdateFragmentVisibility()
    d(addonName.." "..(charSettings.isVisible and "shown" or "hidden"))
end

local function ToggleBankDisplay()
    local charSettings = GetCharacterSettings()
    charSettings.showBank = not charSettings.showBank
    CreateUI()
    d("Bank display "..(charSettings.showBank and "shown" or "hidden"))
end

local function ToggleBackpackDisplay()
    local charSettings = GetCharacterSettings()
    charSettings.showBackpack = not charSettings.showBackpack
    CreateUI()
    d("Backpack display "..(charSettings.showBackpack and "shown" or "hidden"))
end

local function ToggleWindowLock()
    local charSettings = GetCharacterSettings()
    charSettings.lockWindow = not charSettings.lockWindow
    if addon.window then
        addon.window:SetMouseEnabled(not charSettings.lockWindow)
        addon.window:SetMovable(not charSettings.lockWindow)
    end
    d("Window position "..(charSettings.lockWindow and "locked" or "unlocked"))
end

local function ToggleLayout()
    local charSettings = GetCharacterSettings()
    charSettings.horizontalLayout = not charSettings.horizontalLayout
    CreateUI()
    d("Layout switched to "..(charSettings.horizontalLayout and "horizontal bar" or "vertical list"))
end

local function ResetPosition()
    local charSettings = GetCharacterSettings()
    charSettings.posX = nil
    charSettings.posY = nil
    if addon.window then
        addon.window:ClearAnchors()
        addon.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    d("Position reset to center")
end

local function ShowHelp()
    d("HomeStorageTracker v"..addonVersion.." Commands:")
    d("/hst - Update display")
    d("/hst toggle - Show/hide window")
    d("/hst bank - Toggle bank display")
    d("/hst backpack (or bp) - Toggle backpack display")
    d("/hst gold - Toggle gold display")
    d("/hst vault - Toggle furniture vault display")
    d("/hst coffers - Toggle individual coffer display")
    d("/hst layout - Toggle horizontal/vertical layout")
    d("/hst lock - Lock/unlock window position")
    d("/hst reset - Reset window position")
    d("/hst debug - Show debug information")
    d("/hst help - Show this help")
end

local function HandleSlashCommand(args)
    args = args and string.lower(string.match(args, "^%s*(.-)%s*$")) or ""
    
    if args == "toggle" then
        ToggleVisibility()
    elseif args == "bank" then
        ToggleBankDisplay()
    elseif args == "backpack" or args == "bp" then
        ToggleBackpackDisplay()
    elseif args == "gold" then
        ToggleGoldDisplay()
    elseif args == "vault" then
        ToggleFurnitureVaultDisplay()
    elseif args == "coffers" or args == "coffer" then
        ToggleCoffersDisplay()
    elseif args == "layout" then
        ToggleLayout()
    elseif args == "lock" then
        ToggleWindowLock()
    elseif args == "reset" then
        ResetPosition()
    elseif args == "help" then
        ShowHelp()
    elseif args == "debug" then
        local charSettings = GetCharacterSettings()
        d(string.format("Debug Info (v%s):", addonVersion))
        d(string.format("Home: %d/%d", addon.savedVars.accountWide.lastHomeUsed or 0, GetHomeStorageMax()))
        d(string.format("Coffers: %s", charSettings.showCoffers and "Individual" or "Combined"))
        if charSettings.showCoffers and addon.savedVars.accountWide.lastCofferData then
            for i = BAG_HOUSE_BANK_ONE, BAG_HOUSE_BANK_TEN do
                local data = addon.savedVars.accountWide.lastCofferData[i]
                if data then
                    local displayName = GetCofferDisplayName(i)
                    if (not displayName or displayName == COFFER_FALLBACK_NAMES[i - BAG_HOUSE_BANK_ONE + 1])
                       and data.name and data.name ~= "" then
                        displayName = data.name
                    end
                    d(string.format("  %s: %d/%d", displayName, data.used or 0, data.max or 0))
                end
            end
        end
        d(string.format("Settings: Visible=%s, Locked=%s, Layout=%s", 
            tostring(charSettings.isVisible), 
            tostring(charSettings.lockWindow),
            charSettings.horizontalLayout and "Horizontal" or "Vertical"))
        d(string.format("Furniture Vault: Available=%s, Used=%d, Max=%d",
            tostring(IsFurnitureVaultAvailable()),
            addon.savedVars.accountWide.lastFurnitureVaultUsed or 0,
            addon.savedVars.accountWide.lastFurnitureVaultMax or DEFAULT_FURNITURE_VAULT_SLOTS))
    else
        if args ~= "" then
            d("Unknown command: "..args)
        end
        UpdateDisplay()
        d("Storage updated")
    end
end

-- Initialize
local function Initialize(event, name)
    if name ~= addonName then return end
    EVENT_MANAGER:UnregisterForEvent(addonName, EVENT_ADD_ON_LOADED)

    -- Init vars - ADDED GetWorldName() as the 3rd argument for server-specific saving
    addon.savedVars = ZO_SavedVars:NewAccountWide(savedVarsName, 1, GetWorldName(), defaultSavedVars)

    if not addon.savedVars.accountWide then
        addon.savedVars.accountWide = ZO_DeepTableCopy(defaultSavedVars.accountWide)
    end
    if not addon.savedVars.accountWide.lastCofferData then
        addon.savedVars.accountWide.lastCofferData = {}
    end
    if not addon.savedVars.perCharacter then
        addon.savedVars.perCharacter = {}
    end
    
    -- Register commands and events
    SLASH_COMMANDS["/hst"] = HandleSlashCommand

    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(_, bagId)
        if (bagId >= BAG_HOUSE_BANK_ONE and bagId <= BAG_HOUSE_BANK_TEN) or 
           (bagId == BAG_BANK) or 
           (bagId == BAG_BACKPACK) or
           (BAG_FURNITURE_VAULT and bagId == BAG_FURNITURE_VAULT) then
            zo_callLater(UpdateDisplay, 100)
        end
    end)

    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_OPEN_BANK, function() zo_callLater(UpdateDisplay, 100) end)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_CLOSE_BANK, function() zo_callLater(UpdateDisplay, 100) end)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_MONEY_UPDATE, function() zo_callLater(UpdateDisplay, 100) end)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_BANKED_MONEY_UPDATE, function() zo_callLater(UpdateDisplay, 100) end)
    
    -- Update on zone change (entering/leaving a house affects vault availability)
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, function()
        zo_callLater(UpdateDisplay, 500)
    end)
    
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_HOUSING_EDITOR_MODE_CHANGED, function(_, oldMode, newMode)
        if newMode then zo_callLater(UpdateDisplay, 500) end
    end)
    
    EVENT_MANAGER:RegisterForEvent(addonName, EVENT_COLLECTIBLE_USE_RESULT, function(_, result, collectibleId)
        zo_callLater(UpdateDisplay, 500)
    end)

    -- Create UI
    zo_callLater(function()
        if not pcall(function() 
            CreateUI() 
            UpdateDisplay() 
        end) then
            d(addonName.." failed to create UI.")
        end
    end, 1000)
    
    d(addonName.." v"..addonVersion.." loaded.")
end

EVENT_MANAGER:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, Initialize)
