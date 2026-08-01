-- CombatSkills Addon: Combined tracker for Hand-to-Hand and Unarmored combat
-- Version 2.0 - ESO-style UI redesign with authentic look

CombatSkills = {}
CombatSkills.name = "CombatSkills"
CombatSkills.SAVED_VARS_VERSION = 1
CombatSkills.activeTab = 1

-- Default saved variables (per-character)
local defaultSettings = {
    windowPosition = {x = 400, y = 300},
    activeTab = 1,
    -- Hand-to-Hand specific
    handToHand = {
        totalKills = 0,
        lastNotifiedLevel = 0
    },
    -- Unarmored specific
    unarmored = {
        totalKills = 0,
        lastNotifiedLevel = 0
    },
    -- Backstabbing specific
    backstabbing = {
        totalStuns = 0,
        lastNotifiedLevel = 0
    }
}

-- Tracking states
local isCurrentlyUnarmed = false
local lastWeaponCheck = 0
local isCurrentlyUnarmored = false
local lastArmorCheck = 0
local debugMode = false

-- Armor slot constants (exclude jewelry)
local ARMOR_SLOTS = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_OFF_HAND  -- Shield counts as armor
}

-- =======================
-- BACKSTABBING MODULE
-- =======================
CombatSkills.Backstabbing = {
    name = "Backstabbing",
    color = {0.7, 0.1, 0.9, 1},
    icon = "CombatSkills/icons/backstab.dds",
    STUNS_PER_LEVEL = 10,
    MAX_LEVEL = 50,
    ABILITY_ID = 26245, -- Sneak Stun abilityId
    RANKS = {
        {level = 0, name = "Cutthroat", color = {0.6, 0.6, 0.6, 1}},
        {level = 25, name = "Assassin", color = {0.8, 0.2, 0.8, 1}},
        {level = 50, name = "Shadow Master", color = {0.9, 0.3, 0.9, 1}}
    }
}

function CombatSkills.Backstabbing:GetCount()
    return CombatSkills.savedVars.backstabbing.totalStuns
end

function CombatSkills.Backstabbing:GetLevel()
    local level = math.floor(self:GetCount() / self.STUNS_PER_LEVEL)
    return math.min(level, self.MAX_LEVEL)
end

function CombatSkills.Backstabbing:GetProgress()
    local count, level = self:GetCount(), self:GetLevel()
    if level >= self.MAX_LEVEL then return self.STUNS_PER_LEVEL, self.STUNS_PER_LEVEL end
    return count % self.STUNS_PER_LEVEL, self.STUNS_PER_LEVEL
end

function CombatSkills.Backstabbing:GetRank()
    local level = self:GetLevel()
    local currentRank = self.RANKS[1]
    for _, rank in ipairs(self.RANKS) do
        if level >= rank.level then
            currentRank = rank
        end
    end
    return currentRank
end

function CombatSkills.Backstabbing:GetDescription()
    return "Perform Sneak Stuns (attack from behind in stealth) to increase your Backstabbing Skill.\nEvery 10 Sneak Stuns increases your level by 1. Maximum level is 50.\n\nEvery 25 levels you will increase in rank."
end

-- =======================
-- DETECTION FUNCTIONS
-- =======================
local function IsPlayerUnarmed()
    local hasMainWeapon = HasItemInSlot(BAG_WORN, EQUIP_SLOT_MAIN_HAND)
    local hasBackupMain = HasItemInSlot(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN)
    local mainWeaponType = GetItemWeaponType(BAG_WORN, EQUIP_SLOT_MAIN_HAND)
    local backupWeaponType = GetItemWeaponType(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN)
    
    return (not hasMainWeapon or mainWeaponType == WEAPONTYPE_NONE) and 
           (not hasBackupMain or backupWeaponType == WEAPONTYPE_NONE)
end

local function IsPlayerUnarmored()
    for _, slotId in ipairs(ARMOR_SLOTS) do
        if slotId == EQUIP_SLOT_OFF_HAND then
            local itemLink = GetItemLink(BAG_WORN, slotId)
            if itemLink and itemLink ~= "" then
                local equipType = GetItemLinkEquipType(itemLink)
                if equipType == EQUIP_TYPE_OFF_HAND then  -- Shield
                    return false
                end
            end
        else
            if HasItemInSlot(BAG_WORN, slotId) then
                return false
            end
        end
    end
    return true
end

local function UpdateCombatStates()
    isCurrentlyUnarmed = IsPlayerUnarmed()
    lastWeaponCheck = GetGameTimeMilliseconds()
    isCurrentlyUnarmored = IsPlayerUnarmored()
    lastArmorCheck = GetGameTimeMilliseconds()
    
    if debugMode then
        d("[CombatSkills] States - Unarmed: " .. tostring(isCurrentlyUnarmed) .. ", Unarmored: " .. tostring(isCurrentlyUnarmored))
    end
end

-- =======================
-- HAND-TO-HAND MODULE
-- =======================
CombatSkills.HandToHand = {
    name = "Hand-To-Hand",
    color = {0.8, 0.3, 0.3, 1},
    icon = "CombatSkills/icons/fist.dds",
    KILLS_PER_LEVEL = 10,
    MAX_LEVEL = 50,
    RANKS = {
        {level = 0, name = "Brawler", color = {0.6, 0.6, 0.6, 1}},
        {level = 25, name = "Pugilist", color = {0.8, 0.5, 0.2, 1}},
        {level = 50, name = "Monk", color = {1, 0.84, 0, 1}}
    }
}

function CombatSkills.HandToHand:GetCount()
    return CombatSkills.savedVars.handToHand.totalKills
end

function CombatSkills.HandToHand:GetLevel()
    local level = math.floor(self:GetCount() / self.KILLS_PER_LEVEL)
    return math.min(level, self.MAX_LEVEL)
end

function CombatSkills.HandToHand:GetProgress()
    local count = self:GetCount()
    local level = self:GetLevel()
    if level >= self.MAX_LEVEL then
        return self.KILLS_PER_LEVEL, self.KILLS_PER_LEVEL
    end
    return count % self.KILLS_PER_LEVEL, self.KILLS_PER_LEVEL
end

function CombatSkills.HandToHand:GetRank()
    local level = self:GetLevel()
    local currentRank = self.RANKS[1]
    for _, rank in ipairs(self.RANKS) do
        if level >= rank.level then
            currentRank = rank
        end
    end
    return currentRank
end

function CombatSkills.HandToHand:GetDescription()
    return "Unequip all weapons, skills can be used but finishing blow must be from your fists!\nEvery 10 unarmed kills increases your level by 1. Maximum level is 50.\n\nEvery 25 levels you will increase in rank."
end

function CombatSkills.HandToHand:GetStatusText()
    if IsPlayerUnarmed() then
        return "Weapon Status: |c00FF00Unarmed|r (kills will count)"
    else
        return "Weapon Status: |cFF0000Armed|r (kills won't count)"
    end
end

-- =======================
-- UNARMORED MODULE
-- =======================
CombatSkills.Unarmored = {
    name = "Unarmored",
    color = {0.53, 0.81, 0.98, 1},
    icon = "CombatSkills/icons/unarmored.dds",
    KILLS_PER_LEVEL = 10,
    MAX_LEVEL = 50,
    RANKS = {
        {level = 0, name = "Novice", color = {0.6, 0.6, 0.6, 1}},
        {level = 25, name = "Ascetic", color = {0.8, 0.9, 1, 1}},
        {level = 50, name = "Mystic", color = {0.9, 0.9, 1, 1}}
    }
}

function CombatSkills.Unarmored:GetCount()
    return CombatSkills.savedVars.unarmored.totalKills
end

function CombatSkills.Unarmored:GetLevel()
    local level = math.floor(self:GetCount() / self.KILLS_PER_LEVEL)
    return math.min(level, self.MAX_LEVEL)
end

function CombatSkills.Unarmored:GetProgress()
    local count = self:GetCount()
    local level = self:GetLevel()
    if level >= self.MAX_LEVEL then
        return self.KILLS_PER_LEVEL, self.KILLS_PER_LEVEL
    end
    return count % self.KILLS_PER_LEVEL, self.KILLS_PER_LEVEL
end

function CombatSkills.Unarmored:GetRank()
    local level = self:GetLevel()
    local currentRank = self.RANKS[1]
    for _, rank in ipairs(self.RANKS) do
        if level >= rank.level then
            currentRank = rank
        end
    end
    return currentRank
end

function CombatSkills.Unarmored:GetDescription()
    return "Defeat enemies while wearing no armor pieces to increase your Unarmored Skill.\nEvery 10 kills increases your level by 1. Maximum level is 50.\nJewelry (rings and necklaces) may be worn without penalty.\n\nEvery 25 levels you will increase in rank."
end

function CombatSkills.Unarmored:GetStatusText()
    if IsPlayerUnarmored() then
        return "Armor Status: |c00FF00Unarmored|r (kills will count)"
    else
        return "Armor Status: |cFF0000Armored|r (kills won't count)"
    end
end

-- =======================
-- ESO-STYLE UI CREATION
-- =======================
function CombatSkills.CreateWindow()
    -- Initialize skills list
    CombatSkills.skills = {
        CombatSkills.HandToHand,
        CombatSkills.Unarmored,
        CombatSkills.Backstabbing
    }
    
    -- Main window with ESO dimensions and style
    local window = WINDOW_MANAGER:CreateTopLevelWindow("CombatSkillsWindow")
    window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CombatSkills.savedVars.windowPosition.x, CombatSkills.savedVars.windowPosition.y)
    window:SetDimensions(800, 600)  -- Larger, more ESO-like dimensions
    window:SetHidden(true)
    window:SetMovable(true)
    window:SetMouseEnabled(true)
    window:SetClampedToScreen(true)

    window:SetHandler("OnMoveStop", function()
        local left, top = window:GetLeft(), window:GetTop()
        CombatSkills.savedVars.windowPosition.x = left
        CombatSkills.savedVars.windowPosition.y = top
    end)

    -- Main background with ESO styling
    local bg = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.05, 0.05, 0.05, 0.95)
    bg:SetEdgeColor(0.4, 0.35, 0.25, 1)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/tooltip_border.dds", 128, 16)

    -- Left panel for skill categories (ESO style)
    local leftPanel = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    leftPanel:SetAnchor(TOPLEFT, window, TOPLEFT, 10, 50)
    leftPanel:SetDimensions(220, 540)
    leftPanel:SetCenterColor(0.08, 0.08, 0.08, 0.9)
    leftPanel:SetEdgeColor(0.3, 0.25, 0.18, 0.8)
    leftPanel:SetEdgeTexture("EsoUI/Art/Miscellaneous/scrollbox_edge.dds", 32, 4)

    -- Left panel header
    local leftHeader = WINDOW_MANAGER:CreateControl(nil, leftPanel, CT_LABEL)
    leftHeader:SetAnchor(TOP, leftPanel, TOP, 0, 15)
    leftHeader:SetFont("ZoFontWinH4")
    leftHeader:SetText("COMBAT SKILLS")
    leftHeader:SetColor(0.9, 0.8, 0.6, 1)

    -- Right panel for skill details
    local rightPanel = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    rightPanel:SetAnchor(TOPRIGHT, window, TOPRIGHT, -10, 50)
    rightPanel:SetDimensions(550, 540)
    rightPanel:SetCenterColor(0.06, 0.06, 0.06, 0.9)
    rightPanel:SetEdgeColor(0.25, 0.22, 0.16, 0.8)
    rightPanel:SetEdgeTexture("EsoUI/Art/Miscellaneous/scrollbox_edge.dds", 32, 4)

    -- Main title bar
    local titleBar = WINDOW_MANAGER:CreateControl(nil, window, CT_BACKDROP)
    titleBar:SetAnchor(TOPLEFT, window, TOPLEFT, 0, 0)
    titleBar:SetDimensions(800, 45)
    titleBar:SetCenterColor(0.15, 0.12, 0.08, 0.95)
    titleBar:SetEdgeColor(0.4, 0.35, 0.25, 1)

    local title = WINDOW_MANAGER:CreateControl(nil, titleBar, CT_LABEL)
    title:SetAnchor(CENTER, titleBar, CENTER, 0, 0)
    title:SetFont("ZoFontWinH2")
    title:SetText("COMBAT SKILLS")
    title:SetColor(0.9, 0.8, 0.6, 1)

    -- Create skill category buttons (ESO style)
    CombatSkills.skillButtons = {}
    local buttonHeight = 60
    local buttonSpacing = 5
    
    for i, skill in ipairs(CombatSkills.skills) do
        local button = WINDOW_MANAGER:CreateControl(nil, leftPanel, CT_BUTTON)
        button:SetDimensions(200, buttonHeight)
        button:SetAnchor(TOPLEFT, leftPanel, TOPLEFT, 10, 50 + (i-1) * (buttonHeight + buttonSpacing))
        
        -- Button background
        local buttonBg = WINDOW_MANAGER:CreateControl(nil, button, CT_BACKDROP)
        buttonBg:SetAnchorFill()
        buttonBg:SetCenterColor(0.12, 0.12, 0.12, 0.8)
        buttonBg:SetEdgeColor(0.25, 0.22, 0.16, 0.6)
        button.bg = buttonBg
        
        -- Button icon
        local icon = WINDOW_MANAGER:CreateControl(nil, button, CT_TEXTURE)
        icon:SetDimensions(32, 32)
        icon:SetAnchor(LEFT, button, LEFT, 10, 0)
        icon:SetTexture(skill.icon)
        
        -- Button text
        local text = WINDOW_MANAGER:CreateControl(nil, button, CT_LABEL)
        text:SetAnchor(LEFT, icon, RIGHT, 10, -5)
        text:SetFont("ZoFontGame")
        text:SetText(skill.name)
        text:SetColor(0.85, 0.85, 0.85, 1)
        
        -- Level indicator
        local levelText = WINDOW_MANAGER:CreateControl(nil, button, CT_LABEL)
        levelText:SetAnchor(LEFT, icon, RIGHT, 10, 10)
        levelText:SetFont("ZoFontGameSmall")
        levelText:SetText("Level 0")
        levelText:SetColor(0.7, 0.7, 0.7, 1)
        
        button.text = text
        button.levelText = levelText
        
        button:SetHandler("OnClicked", function()
            CombatSkills.SelectTab(i)
        end)
        
        button:SetHandler("OnMouseEnter", function()
            if CombatSkills.activeTab ~= i then
                buttonBg:SetCenterColor(0.18, 0.18, 0.18, 0.9)
            end
        end)
        
        button:SetHandler("OnMouseExit", function()
            if CombatSkills.activeTab ~= i then
                buttonBg:SetCenterColor(0.12, 0.12, 0.12, 0.8)
            end
        end)
        
        CombatSkills.skillButtons[i] = button
    end

    -- Right panel content
    -- Skill name and level header (ESO style)
    local skillNameLabel = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_LABEL)
    skillNameLabel:SetAnchor(TOPLEFT, rightPanel, TOPLEFT, 20, 20)
    skillNameLabel:SetFont("ZoFontWinH1")
    skillNameLabel:SetText("Select a Skill")
    skillNameLabel:SetColor(0.9, 0.8, 0.6, 1)

    -- Skill level display (top right)
    local skillLevelLabel = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_LABEL)
    skillLevelLabel:SetAnchor(TOPRIGHT, rightPanel, TOPRIGHT, -20, 20)
    skillLevelLabel:SetFont("ZoFontWinH1")
    skillLevelLabel:SetText("")
    skillLevelLabel:SetColor(1, 0.84, 0, 1)

    -- Large skill icon
    local largeIcon = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_TEXTURE)
    largeIcon:SetDimensions(64, 64)
    largeIcon:SetAnchor(TOPLEFT, skillNameLabel, BOTTOMLEFT, 0, 15)

    -- XP Bar container (ESO style)
    local xpContainer = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_CONTROL)
    xpContainer:SetAnchor(TOPLEFT, largeIcon, BOTTOMLEFT, 0, 20)
    xpContainer:SetDimensions(500, 30)

    -- XP Bar background
    local xpBg = WINDOW_MANAGER:CreateControl(nil, xpContainer, CT_BACKDROP)
    xpBg:SetAnchorFill()
    xpBg:SetCenterColor(0.1, 0.1, 0.1, 0.8)
    xpBg:SetEdgeColor(0.3, 0.25, 0.18, 0.8)

    -- XP Bar
    local xpBar = WINDOW_MANAGER:CreateControl(nil, xpBg, CT_STATUSBAR)
    xpBar:SetAnchor(TOPLEFT, xpBg, TOPLEFT, 2, 2)
    xpBar:SetAnchor(BOTTOMRIGHT, xpBg, BOTTOMRIGHT, -2, -2)
    xpBar:SetMinMax(0, 100)
    xpBar:SetValue(0)

    -- XP Bar text
    local xpText = WINDOW_MANAGER:CreateControl(nil, xpContainer, CT_LABEL)
    xpText:SetFont("ZoFontGameBold")
    xpText:SetColor(1, 1, 1, 1)
    xpText:SetAnchor(CENTER, xpContainer, CENTER, 0, 0)
    xpText:SetText("0 / 10")

    -- Status section
    local statusLabel = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_LABEL)
    statusLabel:SetAnchor(TOPLEFT, xpContainer, BOTTOMLEFT, 0, 25)
    statusLabel:SetFont("ZoFontGame")
    statusLabel:SetText("")
    statusLabel:SetDimensions(500, 20)

    -- Total counter
    local totalLabel = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_LABEL)
    totalLabel:SetAnchor(TOPLEFT, statusLabel, BOTTOMLEFT, 0, 5)
    totalLabel:SetFont("ZoFontGame")
    totalLabel:SetColor(0.8, 0.8, 0.8, 1)
    totalLabel:SetText("")

    -- Rank display (for all skills with ranks)
    local rankLabel = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_LABEL)
    rankLabel:SetAnchor(TOPLEFT, totalLabel, BOTTOMLEFT, 0, 10)
    rankLabel:SetFont("ZoFontWinH4")
    rankLabel:SetText("")

    -- Description section
    local descHeader = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_LABEL)
    descHeader:SetAnchor(TOPLEFT, rankLabel, BOTTOMLEFT, 0, 25)
    descHeader:SetFont("ZoFontWinH4")
    descHeader:SetColor(0.9, 0.8, 0.6, 1)
    descHeader:SetText("How to Level")

    local descText = WINDOW_MANAGER:CreateControl(nil, rightPanel, CT_LABEL)
    descText:SetAnchor(TOPLEFT, descHeader, BOTTOMLEFT, 0, 10)
    descText:SetFont("ZoFontGame")
    descText:SetColor(0.8, 0.8, 0.8, 1)
    descText:SetDimensions(500, 120)
    descText:SetText("")

    -- Store references
    CombatSkills.window = window
    CombatSkills.skillNameLabel = skillNameLabel
    CombatSkills.skillLevelLabel = skillLevelLabel
    CombatSkills.largeIcon = largeIcon
    CombatSkills.xpBar = xpBar
    CombatSkills.xpText = xpText
    CombatSkills.statusLabel = statusLabel
    CombatSkills.totalLabel = totalLabel
    CombatSkills.rankLabel = rankLabel
    CombatSkills.descText = descText

    -- Hook into skills scene
    local skillsScene = SCENE_MANAGER:GetScene("skills")
    if skillsScene then
        skillsScene:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWING then
                UpdateCombatStates()
                CombatSkills.UpdateWindow()
                CombatSkills.window:SetHidden(false)
            elseif newState == SCENE_HIDDEN then
                CombatSkills.window:SetHidden(true)
            end
        end)
    end
end

function CombatSkills.SelectTab(tabIndex)
    CombatSkills.activeTab = tabIndex
    CombatSkills.savedVars.activeTab = tabIndex
    
    -- Update button appearance
    for i, button in ipairs(CombatSkills.skillButtons) do
        if i == tabIndex then
            button.bg:SetCenterColor(0.2, 0.18, 0.12, 0.95)
            button.bg:SetEdgeColor(0.4, 0.35, 0.25, 0.9)
            button.text:SetColor(1, 0.9, 0.7, 1)
        else
            button.bg:SetCenterColor(0.12, 0.12, 0.12, 0.8)
            button.bg:SetEdgeColor(0.25, 0.22, 0.16, 0.6)
            button.text:SetColor(0.85, 0.85, 0.85, 1)
        end
    end
    
    CombatSkills.UpdateWindow()
end

function CombatSkills.UpdateWindow()
    if not CombatSkills.window then return end
    if not CombatSkills.skills then return end
    
    local skill = CombatSkills.skills[CombatSkills.activeTab]
    if not skill then return end
    
    -- Update button level displays
    for i, button in ipairs(CombatSkills.skillButtons) do
        local s = CombatSkills.skills[i]
        local level = s:GetLevel()
        button.levelText:SetText("Level " .. level)
        if level >= s.MAX_LEVEL then
            button.levelText:SetColor(1, 0.84, 0, 1)
        else
            button.levelText:SetColor(0.7, 0.7, 0.7, 1)
        end
    end
    
    -- Update main panel
    CombatSkills.skillNameLabel:SetText(skill.name)
    CombatSkills.skillNameLabel:SetColor(unpack(skill.color))
    
    -- Update large icon
    CombatSkills.largeIcon:SetTexture(skill.icon)
    
    -- Update level display
    local level = skill:GetLevel()
    if level >= skill.MAX_LEVEL then
        CombatSkills.skillLevelLabel:SetText(string.format("%d", level))
        CombatSkills.skillLevelLabel:SetColor(1, 0.84, 0, 1)
    else
        CombatSkills.skillLevelLabel:SetText(string.format("%d", level))
        CombatSkills.skillLevelLabel:SetColor(unpack(skill.color))
    end
    
    -- Update XP bar
    local current, max = skill:GetProgress()
    local percent = (current / max) * 100
    CombatSkills.xpBar:SetValue(percent)
    CombatSkills.xpBar:SetColor(unpack(skill.color))
    
    if level >= skill.MAX_LEVEL then
        CombatSkills.xpText:SetText("MAXED")
    else
        CombatSkills.xpText:SetText(string.format("%d / %d", current, max))
    end
    
    -- Update status
    if skill.GetStatusText then
        CombatSkills.statusLabel:SetText(skill:GetStatusText())
    else
        CombatSkills.statusLabel:SetText("")
    end
    
    -- Update total counter
    local countText = ""
    if skill == CombatSkills.HandToHand then
        countText = "Total Unarmed Kills: " .. skill:GetCount()
    elseif skill == CombatSkills.Unarmored then
        countText = "Total Unarmored Kills: " .. skill:GetCount()
    elseif skill == CombatSkills.Backstabbing then
        countText = "Total Sneak Stuns: " .. skill:GetCount()
    end
    CombatSkills.totalLabel:SetText(countText)
    
    -- Update rank display (for all skills with ranks)
    if skill.GetRank then
        local rank = skill:GetRank()
        CombatSkills.rankLabel:SetText(string.format("Rank: %s", rank.name))
        CombatSkills.rankLabel:SetColor(unpack(rank.color))
    else
        CombatSkills.rankLabel:SetText("")
    end
    
    -- Update description
    CombatSkills.descText:SetText(skill:GetDescription())
end

-- =======================
-- COMBAT EVENT HANDLING
-- =======================
local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic,
    abilityActionSlotType, sourceName, sourceType, targetName,
    targetType, hitValue, powerType, damageType, log,
    sourceUnitId, targetUnitId, abilityId)

    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then return end

    -- Backstabbing detection: Sneak Stun abilityId
    if abilityId == CombatSkills.Backstabbing.ABILITY_ID and result == ACTION_RESULT_EFFECT_GAINED then
        CombatSkills.savedVars.backstabbing.totalStuns = CombatSkills.savedVars.backstabbing.totalStuns + 1

        local skill = CombatSkills.Backstabbing
        local currentLevel = skill:GetLevel()
        if currentLevel > CombatSkills.savedVars.backstabbing.lastNotifiedLevel then
            PlaySound(SOUNDS.SKILL_LINE_LEVELED_UP)
            local msg = string.format("|cB366FFBackstabbing Skill|r increased to |cFFFFFF%d|r", currentLevel)
            CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_SKILL_RANK_UPDATE, CSA_CATEGORY_LARGE_TEXT,
                SOUNDS.SKILL_LINE_LEVELED_UP, msg)
            
            -- Check for rank up
            if currentLevel == 25 then
                zo_callLater(function()
                    PlaySound(SOUNDS.SKILL_LINE_LEVELED_UP)
                    CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_SKILL_RANK_UPDATE, CSA_CATEGORY_LARGE_TEXT, 
                        SOUNDS.SKILL_LINE_LEVELED_UP, 
                        "|cB366FFYou have achieved the rank of|r |cCC33EEASSASSIN|r")
                end, 2000)
            elseif currentLevel == 50 then
                zo_callLater(function()
                    PlaySound(SOUNDS.SKILL_LINE_LEVELED_UP)
                    CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_SKILL_RANK_UPDATE, CSA_CATEGORY_LARGE_TEXT, 
                        SOUNDS.SKILL_LINE_LEVELED_UP, 
                        "|cB366FFYou have achieved the rank of|r |cE644EESHADOW MASTER|r")
                end, 2000)
            end
            
            CombatSkills.savedVars.backstabbing.lastNotifiedLevel = currentLevel
        end

        if debugMode then
            d(string.format("[Backstabbing] Sneak Stun detected! Total: %d", CombatSkills.savedVars.backstabbing.totalStuns))
        end

        CombatSkills.UpdateWindow()
        return
    end
    
    -- Check for kills
    if result == ACTION_RESULT_KILLING_BLOW or result == ACTION_RESULT_DIED or 
       result == ACTION_RESULT_DIED_XP then
        
        -- Update states if not checked recently
        if GetGameTimeMilliseconds() - lastWeaponCheck > 100 or 
           GetGameTimeMilliseconds() - lastArmorCheck > 100 then
            UpdateCombatStates()
        end
        
        local killCounted = false
        
        -- Check for unarmed kill (Hand-to-Hand)
        local isLightOrHeavy = (abilityActionSlotType == ACTION_SLOT_TYPE_LIGHT_ATTACK or 
                               abilityActionSlotType == ACTION_SLOT_TYPE_HEAVY_ATTACK)
        
        if isLightOrHeavy and isCurrentlyUnarmed then
            CombatSkills.savedVars.handToHand.totalKills = CombatSkills.savedVars.handToHand.totalKills + 1
            killCounted = true
            
            -- Check for level up
            local skill = CombatSkills.HandToHand
            local currentLevel = skill:GetLevel()
            if currentLevel > CombatSkills.savedVars.handToHand.lastNotifiedLevel then
                PlaySound(SOUNDS.SKILL_LINE_LEVELED_UP)
                local message = string.format("|cFF6B6BHand-To-Hand Skill|r increased to |cFFFFFF%d|r", currentLevel)
                CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_SKILL_RANK_UPDATE, CSA_CATEGORY_LARGE_TEXT, 
                                                 SOUNDS.SKILL_LINE_LEVELED_UP, message)
                
                -- Check for rank up
                if currentLevel == 25 then
                    zo_callLater(function()
                        PlaySound(SOUNDS.SKILL_LINE_LEVELED_UP)
                        CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_SKILL_RANK_UPDATE, CSA_CATEGORY_LARGE_TEXT, 
                            SOUNDS.SKILL_LINE_LEVELED_UP, 
                            "|cFFAA00You have achieved the rank of|r |cFFD700PUGILIST|r")
                    end, 2000)
                elseif currentLevel == 50 then
                    zo_callLater(function()
                        PlaySound(SOUNDS.SKILL_LINE_LEVELED_UP)
                        CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_SKILL_RANK_UPDATE, CSA_CATEGORY_LARGE_TEXT, 
                            SOUNDS.SKILL_LINE_LEVELED_UP, 
                            "|cFFAA00You have achieved the rank of|r |cFFD700MONK|r")
                    end, 2000)
                end
                
                CombatSkills.savedVars.handToHand.lastNotifiedLevel = currentLevel
            end
            
            if debugMode then
                d("[Hand-To-Hand] Unarmed kill! Total: " .. CombatSkills.savedVars.handToHand.totalKills)
            end
        end
        
        -- Check for unarmored kill
        if isCurrentlyUnarmored then
            CombatSkills.savedVars.unarmored.totalKills = CombatSkills.savedVars.unarmored.totalKills + 1
            
            -- Check for level up
            local skill = CombatSkills.Unarmored
            local currentLevel = skill:GetLevel()
            if currentLevel > CombatSkills.savedVars.unarmored.lastNotifiedLevel then
                PlaySound(SOUNDS.SKILL_LINE_LEVELED_UP)
                local message = string.format("|c87CEFAUnarmored Skill|r increased to |cFFFFFF%d|r", currentLevel)
                CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_SKILL_RANK_UPDATE, CSA_CATEGORY_LARGE_TEXT, 
                                                 SOUNDS.SKILL_LINE_LEVELED_UP, message)
                
                -- Check for rank up
                if currentLevel == 25 then
                    zo_callLater(function()
                        PlaySound(SOUNDS.SKILL_LINE_LEVELED_UP)
                        CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_SKILL_RANK_UPDATE, CSA_CATEGORY_LARGE_TEXT, 
                            SOUNDS.SKILL_LINE_LEVELED_UP, 
                            "|cCCE5FAYou have achieved the rank of|r |cE6F3FFASCETIC|r")
                    end, 2000)
                elseif currentLevel == 50 then
                    zo_callLater(function()
                        PlaySound(SOUNDS.SKILL_LINE_LEVELED_UP)
                        CENTER_SCREEN_ANNOUNCE:AddMessage(EVENT_SKILL_RANK_UPDATE, CSA_CATEGORY_LARGE_TEXT, 
                            SOUNDS.SKILL_LINE_LEVELED_UP, 
                            "|cCCE5FAYou have achieved the rank of|r |cF0F8FFMYSTIC|r")
                    end, 2000)
                end
                
                CombatSkills.savedVars.unarmored.lastNotifiedLevel = currentLevel
            end
            
            if debugMode then
                d("[Unarmored] Kill while unarmored! Total: " .. CombatSkills.savedVars.unarmored.totalKills)
            end
        end
        
        if killCounted or isCurrentlyUnarmored then
            CombatSkills.UpdateWindow()
        end
    end
end

local function OnEquipmentChanged(eventCode, bagId, slotId)
    if bagId == BAG_WORN then
        -- Check for weapon changes
        if slotId == EQUIP_SLOT_MAIN_HAND or slotId == EQUIP_SLOT_BACKUP_MAIN then
            UpdateCombatStates()
        end
        -- Check for armor changes
        for _, armorSlot in ipairs(ARMOR_SLOTS) do
            if slotId == armorSlot then
                UpdateCombatStates()
                break
            end
        end
    end
end

-- =======================
-- INITIALIZATION
-- =======================
function CombatSkills.OnAddOnLoaded(event, addonName)
    if addonName ~= CombatSkills.name then return end

    CombatSkills.savedVars = ZO_SavedVars:NewCharacterIdSettings("CombatSkillsSavedVars",
        CombatSkills.SAVED_VARS_VERSION, nil, defaultSettings)

    CombatSkills.CreateWindow()
    CombatSkills.SelectTab(CombatSkills.savedVars.activeTab or 1)

    EVENT_MANAGER:RegisterForEvent(CombatSkills.name, EVENT_COMBAT_EVENT, OnCombatEvent)
    EVENT_MANAGER:AddFilterForEvent(CombatSkills.name, EVENT_COMBAT_EVENT,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    EVENT_MANAGER:RegisterForEvent(CombatSkills.name .. "_EQUIP", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnEquipmentChanged)
    EVENT_MANAGER:RegisterForEvent(CombatSkills.name .. "_SWAP", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function() zo_callLater(UpdateCombatStates, 100) end)

    EVENT_MANAGER:UnregisterForEvent(CombatSkills.name, EVENT_ADD_ON_LOADED)
    d("[Combat Skills] Loaded successfully. Open Skills menu (K) to view Combat Skills.")
end

-- =======================
-- SLASH COMMANDS
-- =======================
SLASH_COMMANDS["/combatskills"] = function(cmd)
    if cmd == "" then
        d("[Combat Skills] Available commands:")
        d("  /combatskills show - Toggle window visibility")
        d("  /combatskills reset <skill> - Reset a specific skill (handtohand/unarmored/backstabbing)")
        d("  /combatskills test <skill> - Test increment a skill")
        d("  /combatskills debug - Toggle debug mode")
    elseif cmd == "show" then
        if CombatSkills.window then
            local isHidden = CombatSkills.window:IsHidden()
            CombatSkills.window:SetHidden(not isHidden)
            d("[Combat Skills] Window " .. (isHidden and "shown" or "hidden"))
        else
            d("[Combat Skills] Window not created yet. Open Skills menu first.")
        end
    elseif string.find(cmd, "reset") then
        local skill = string.match(cmd, "reset%s+(%w+)")
        if skill == "handtohand" then
            CombatSkills.savedVars.handToHand.totalKills = 0
            CombatSkills.savedVars.handToHand.lastNotifiedLevel = 0
            d("[Combat Skills] Hand-to-Hand skill reset")
        elseif skill == "unarmored" then
            CombatSkills.savedVars.unarmored.totalKills = 0
            CombatSkills.savedVars.unarmored.lastNotifiedLevel = 0
            d("[Combat Skills] Unarmored skill reset")
        elseif skill == "backstabbing" then
            CombatSkills.savedVars.backstabbing.totalStuns = 0
            CombatSkills.savedVars.backstabbing.lastNotifiedLevel = 0
            d("[Combat Skills] Backstabbing skill reset")
        else
            d("[Combat Skills] Unknown skill. Use: handtohand, unarmored, or backstabbing")
        end
        CombatSkills.UpdateWindow()
    elseif string.find(cmd, "test") then
        local skill = string.match(cmd, "test%s+(%w+)")
        if skill == "handtohand" then
            CombatSkills.savedVars.handToHand.totalKills = CombatSkills.savedVars.handToHand.totalKills + 1
            d("[Combat Skills] Hand-to-Hand kills: " .. CombatSkills.savedVars.handToHand.totalKills)
        elseif skill == "unarmored" then
            CombatSkills.savedVars.unarmored.totalKills = CombatSkills.savedVars.unarmored.totalKills + 1
            d("[Combat Skills] Unarmored kills: " .. CombatSkills.savedVars.unarmored.totalKills)
        elseif skill == "backstabbing" then
            CombatSkills.savedVars.backstabbing.totalStuns = CombatSkills.savedVars.backstabbing.totalStuns + 1
            d("[Combat Skills] Backstabbing stuns: " .. CombatSkills.savedVars.backstabbing.totalStuns)
        else
            d("[Combat Skills] Unknown skill. Use: handtohand, unarmored, or backstabbing")
        end
        CombatSkills.UpdateWindow()
    elseif cmd == "debug" then
        debugMode = not debugMode
        d("[Combat Skills] Debug mode " .. (debugMode and "enabled" or "disabled"))
        d("Current states:")
        d("  Unarmed: " .. tostring(IsPlayerUnarmed()))
        d("  Unarmored: " .. tostring(IsPlayerUnarmored()))
        d("  Hand-to-Hand kills: " .. CombatSkills.savedVars.handToHand.totalKills)
        d("  Unarmored kills: " .. CombatSkills.savedVars.unarmored.totalKills)
        d("  Backstabbing stuns: " .. CombatSkills.savedVars.backstabbing.totalStuns)
    end
end

-- Register addon
EVENT_MANAGER:RegisterForEvent(CombatSkills.name, EVENT_ADD_ON_LOADED, CombatSkills.OnAddOnLoaded)