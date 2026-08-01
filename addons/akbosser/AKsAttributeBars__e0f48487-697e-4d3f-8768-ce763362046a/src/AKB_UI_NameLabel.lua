-- ============================================================================
-- AKsAttributeBars - Name Label Creation Module
-- ============================================================================
-- Handles creation of player name label, champion info, and class icon

local AKB = AKsAttributeBars

-- Create NameLabel namespace
AKB.UI = AKB.UI or {}
AKB.UI.NameLabel = AKB.UI.NameLabel or {}

-- Create player name label above bars
function AKB.UI.NameLabel.CreatePlayerNameLabel(healthXOffset, healthYOffset)
    local settings = AKB.Settings.GetAll()
    local playerName = GetUnitName("player")
    local playerLevel = GetUnitLevel("player")
    
    -- Check if any name display elements are enabled
    if not settings.showPlayerName and not settings.showPlayerLevel and not settings.showClassIcon then
        return nil
    end
    
    if not playerName or playerName == "" then
        return nil
    end
    
    local constants = AKB.Utils.BAR_CONSTANTS
    
    local nameUniqueName = AKB.Utils.GenerateUniqueName("AKB_PlayerName")
    local nameWindow = WINDOW_MANAGER.CreateTopLevelWindow and WINDOW_MANAGER:CreateTopLevelWindow(nameUniqueName)
    
    if not nameWindow then
        return nil
    end
    
    local nameXPos = settings.customBarsXPosition + healthXOffset
    local nameYPos = settings.customBarsYPosition + healthYOffset - 30
    
    nameWindow:SetDimensions(constants.WIDTH, 25)
    nameWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, nameXPos, nameYPos)
    nameWindow:SetClampedToScreen(true)
    nameWindow:SetMouseEnabled(false)
    nameWindow:SetMovable(false)
    nameWindow:SetHidden(false)
    nameWindow:SetDrawLayer(DL_OVERLAY or 6)
    
    -- Create name label only if enabled
    local nameLabel = nil
    if settings.showPlayerName then
        nameLabel = AKB.UI.NameLabel.CreateNameLabel(nameWindow, playerName, playerLevel)
    end
    
    -- Create champion info if level display is enabled
    local championIcon, championLevelLabel = nil, nil
    if settings.showPlayerLevel then
        championIcon, championLevelLabel = AKB.UI.NameLabel.CreateChampionInfo(nameWindow, nameLabel, playerName, playerLevel)
    end
    
    -- Create class icon if enabled
    local classIcon = nil
    if settings.showClassIcon then
        classIcon = AKB.UI.NameLabel.CreateClassIcon(nameWindow)
    end
    
    return {
        window = nameWindow,
        label = nameLabel,
        championIcon = championIcon,
        championLevelLabel = championLevelLabel,
        classIcon = classIcon,
        Show = function(self)
            if self.window and self.window.SetHidden then
                self.window:SetHidden(false)
            end
        end,
        Hide = function(self)
            if self.window and self.window.SetHidden then
                self.window:SetHidden(true)
            end
        end,
        Destroy = function(self)
            local components = {self.label, self.championIcon, self.championLevelLabel, self.classIcon}
            for _, component in ipairs(components) do
                if component then
                    component:SetHidden(true)
                    if component.ClearAnchors then component:ClearAnchors() end
                    if component.SetParent then component:SetParent(nil) end
                end
            end
            
            -- Destroy the main window last and more thoroughly
            if self.window then
                self.window:SetHidden(true)
                if self.window.ClearAnchors then self.window:ClearAnchors() end
                
                -- Try to clear all children from the window
                local numChildren = (self.window.GetNumChildren and self.window:GetNumChildren()) or 0
                for i = 1, numChildren do
                    local child = (self.window.GetChild and self.window:GetChild(i)) or nil
                    if child then
                        child:SetHidden(true)
                        if child.ClearAnchors then child:ClearAnchors() end
                        if child.SetParent then child:SetParent(nil) end
                    end
                end
                
                if self.window.SetParent then self.window:SetParent(nil) end
            end
            
            -- Clear all references
            self.label = nil
            self.championIcon = nil
            self.championLevelLabel = nil
            self.classIcon = nil
            self.window = nil
        end
    }
end

-- Create name label
function AKB.UI.NameLabel.CreateNameLabel(nameWindow, playerName, playerLevel)
    local nameLabel = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, nameWindow, CT_LABEL)
    if not nameLabel then
        return nil
    end
    
    local settings = AKB.Settings.GetAll()
    local constants = AKB.Utils.BAR_CONSTANTS
    nameLabel:SetAnchor(TOPLEFT, nameWindow, TOPLEFT, 10, 0)
    nameLabel:SetDimensions(constants.WIDTH - 20, 25)
    nameLabel:SetFont("$(BOLD_FONT)|20|thick-outline")
    
    -- Show level info based on settings
    local nameWithLevel
    if settings.showPlayerLevel and playerLevel < 50 then
        nameWithLevel = playerName .. " (Level " .. tostring(playerLevel) .. ")"
    else
        nameWithLevel = playerName
    end
    
    nameLabel:SetText(nameWithLevel)
    local settings = AKB.Settings.GetAll()
    local textColor = settings.textColor
    nameLabel:SetColor(textColor.r, textColor.g, textColor.b, 1)
    nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT or 0)
    nameLabel:SetHidden(false)
    nameLabel:SetMouseEnabled(false)
    
    return nameLabel
end

-- Create champion information display
function AKB.UI.NameLabel.CreateChampionInfo(nameWindow, nameLabel, playerName, playerLevel)
    local settings = AKB.Settings.GetAll()
    
    -- Only show champion info if level display is enabled and player is 50+
    if not settings.showPlayerLevel or playerLevel < 50 then
        return nil, nil
    end
    
    local championPoints = GetPlayerChampionPointsEarned()
    if not championPoints or championPoints <= 0 then
        return nil, nil
    end
    
    -- Create champion icon
    local championIcon = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, nameWindow, CT_TEXTURE)
    if not championIcon then
        return nil, nil
    end
    
    local iconSize = 24
    local xOffset = 10  -- Default left position
    
    -- If nameLabel exists, position after it; otherwise use default position
    if nameLabel then
        local nameWidth = nameLabel:GetStringWidth(playerName) or (string.len(playerName) * 12)
        xOffset = nameWidth + 20  -- Position after name with spacing
        championIcon:SetAnchor(TOPLEFT, nameLabel, TOPLEFT, nameWidth + 10, 0)
    else
        championIcon:SetAnchor(TOPLEFT, nameWindow, TOPLEFT, xOffset, 0)
    end
    championIcon:SetDimensions(iconSize, iconSize)
    championIcon:SetTexture("EsoUI/Art/Champion/champion_icon.dds")
    championIcon:SetColor(1, 1, 1, 1)
    if championIcon.SetDrawTier then championIcon:SetDrawTier(AKB.Utils.DRAW_TIERS.HIGH) end
    championIcon:SetHidden(false)
    championIcon:SetMouseEnabled(false)
    
    -- Create champion level label
    local championLevelLabel = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, nameWindow, CT_LABEL)
    if not championLevelLabel then
        return championIcon, nil
    end
    
    championLevelLabel:SetAnchor(TOPLEFT, championIcon, TOPRIGHT, 5, 0)
    championLevelLabel:SetDimensions(100, 25)
    championLevelLabel:SetFont("$(BOLD_FONT)|20|thick-outline")
    championLevelLabel:SetText(tostring(championPoints))
    local settings = AKB.Settings.GetAll()
    local textColor = settings.textColor
    championLevelLabel:SetColor(textColor.r, textColor.g, textColor.b, 1)
    championLevelLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT or 0)
    championLevelLabel:SetHidden(false)
    championLevelLabel:SetMouseEnabled(false)
    
    return championIcon, championLevelLabel
end

-- Create class icon
function AKB.UI.NameLabel.CreateClassIcon(nameWindow)
    local settings = AKB.Settings.GetAll()
    
    -- Only show class icon if enabled
    if not settings.showClassIcon then
        return nil
    end
    
    local classId = GetUnitClassId("player")
    local classIconTexture = AKB.Utils.CLASS_ICONS[classId]
    
    if not classIconTexture then
        return nil
    end
    
    local classIcon = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, nameWindow, CT_TEXTURE)
    if not classIcon then
        return nil
    end
    
    local iconSize = 32
    classIcon:SetAnchor(TOPRIGHT, nameWindow, TOPRIGHT, -5, -5)
    classIcon:SetDimensions(iconSize, iconSize)
    classIcon:SetTexture(classIconTexture)
    classIcon:SetColor(1, 1, 1, 1)
    if classIcon.SetDrawTier then classIcon:SetDrawTier(AKB.Utils.DRAW_TIERS.HIGH) end
    if classIcon.SetDrawLayer then classIcon:SetDrawLayer(DL_OVERLAY or 6) end
    classIcon:SetHidden(false)
    classIcon:SetMouseEnabled(false)
    
    return classIcon
end
