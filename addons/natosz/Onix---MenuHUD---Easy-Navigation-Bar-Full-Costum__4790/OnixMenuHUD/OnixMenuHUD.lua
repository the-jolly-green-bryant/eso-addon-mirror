local OnixMenuHUD = {
    name = "OnixMenuHUD", 
    version = "1.1.1",
    savedVarsName = "OnixMenuHUDSavedVars", 
    
    defaultConfig = {
        isHidden = false,
        hideDefaultMenu = false, 
        hideInCombat = true,
        hideInMenus = true,
        showOnlyOnEsc = true,
        hideInGameplay = false,
        scale = 1.8,
        iconSize = 38,
        alpha = 1, 
        padding = 11,
        spacerWidth = 50,
        colorR = 0.9803921580, colorG = 0.9803921580, colorB = 0.9803921580, 
        moveMode = false,
        hudX = 132.3990783691,
        hudY = 29.5732975006,
        enableHoverTint = false,
        hoverTintR = 0.6862745285, hoverTintG = 0.9843137264, hoverTintB = 1,
        hoverEffect = "Smooth Zoom",
        hoverIntensity = 130, 
        enableHoverGlow = true,
        glowStyle = "Custom Painted Texture",
        hoverGlowR = 0, hoverGlowG = 0.8352941275, hoverGlowB = 1, 
        hoverGlowAlpha = 1, 
        hoverGlowSize = 0, 
        showLabels = true,
        applyHoverToText = true,
        fontType = "$(BOLD_FONT)",
        fontSize = 8,
        fontOutline = "none",
        labelPosition = "BOTTOM",
        labelColorR = 1, labelColorG = 1, labelColorB = 1,
        showBg = true,
        bgStyle = "",
        bgWidth = 1500,
        bgHeight = 110,
        bgOffsetX = 0,
        bgOffsetY = -15,
        bgColorR = 0, bgColorG = 0, bgColorB = 0,
        bgAlpha = 0.55,
        slots = {
            "empty", "empty", "group", "friends", "separator", "skills", "champion", "character", "outfits", "separator", 
            "guilds", "battlegrounds", "alliance", "dungeon", "separator", "inventory", "journal", "map", "separator", 
            "tamrieltomes", "crates", "store", "mail", "notifications", "separator", "addons", "reload"
        }
    }
}

local function OpenGroupMenuTab(stringID, fallbackIndex)
    SCENE_MANAGER:Show("groupMenuKeyboard")
    zo_callLater(function()
        local tree = GROUP_MENU_KEYBOARD and GROUP_MENU_KEYBOARD.navigationTree
        if tree and tree.rootNode and tree.rootNode.children then
            local targetName = GetString(stringID)
            for _, node in ipairs(tree.rootNode.children) do
                if node.data and node.data.name == targetName then
                    tree:SelectNode(node)
                    return
                end
            end
            if tree.rootNode.children[fallbackIndex] then 
                tree:SelectNode(tree.rootNode.children[fallbackIndex]) 
            end
        end
    end, 200)
end

local ACTION_DB = {
    ["skills"]        = { name = "Skills", icon = "OnixMenuHUD/textures/skill.dds", glowIcon = "OnixMenuHUD/textures/skillglow.dds", scene = "skills" },
    ["character"]     = { name = "Character", icon = "OnixMenuHUD/textures/character.dds", glowIcon = "OnixMenuHUD/textures/characterglow.dds", scene = "stats" },
    ["inventory"]     = { name = "Inventory", icon = "OnixMenuHUD/textures/backpack2.dds", glowIcon = "OnixMenuHUD/textures/backpack2glow.dds", scene = "inventory" },
    ["journal"]       = { name = "Journal", icon = "OnixMenuHUD/textures/quest.dds", glowIcon = "OnixMenuHUD/textures/questglow.dds", scene = "questJournal" },
    ["map"]           = { name = "Map", icon = "OnixMenuHUD/textures/map.dds", glowIcon = "OnixMenuHUD/textures/mapglow.dds", scene = "worldMap" },
    ["champion"]      = { name = "Champion", icon = "OnixMenuHUD/textures/champion2.dds", glowIcon = "OnixMenuHUD/textures/champion2glow.dds", scene = "championPerks" },
    ["group"]         = { name = "Group Activities", icon = "OnixMenuHUD/textures/GroupA.dds", glowIcon = "OnixMenuHUD/textures/GroupAglow.dds", 
                          func = function() OpenGroupMenuTab(SI_MAIN_MENU_GROUP, 6) end },
    ["guilds"]        = { name = "Guilds", icon = "OnixMenuHUD/textures/guild.dds", glowIcon = "OnixMenuHUD/textures/guildglow.dds", scene = "guildHome" },
    ["alliance"]      = { name = "Alliance War", icon = "OnixMenuHUD/textures/castle.dds", glowIcon = "OnixMenuHUD/textures/castleglow.dds", scene = "campaignBrowser" }, 
    ["friends"]       = { name = "Friends", icon = "OnixMenuHUD/textures/friends.dds", glowIcon = "OnixMenuHUD/textures/friendsglow.dds", scene = "friendsList" },
    ["mail"]          = { name = "Mail", icon = "OnixMenuHUD/textures/mail.dds", glowIcon = "OnixMenuHUD/textures/mailglow.dds", scene = "mailInbox" },
    ["notifications"] = { name = "Notifications", icon = "OnixMenuHUD/textures/notification.dds", glowIcon = "OnixMenuHUD/textures/notificationglow.dds", scene = "notifications" },
    ["outfits"]       = { name = "Collections", icon = "OnixMenuHUD/textures/armor.dds", glowIcon = "OnixMenuHUD/textures/armorglow.dds", scene = "collectionsBook" },
    ["store"]         = { name = "Crown Store", icon = "OnixMenuHUD/textures/crowncoin.dds", glowIcon = "OnixMenuHUD/textures/crowncoinglow.dds", 
                          func = function() 
                              if SYSTEMS and SYSTEMS:GetObject("mainMenu") then 
                                  SYSTEMS:GetObject("mainMenu"):ShowCategory(MENU_CATEGORY_MARKET) 
                              end 
                          end },
    ["crates"]        = { name = "Crown Crates", icon = "OnixMenuHUD/textures/crate.dds", glowIcon = "OnixMenuHUD/textures/crateglow.dds", scene = "crownCrateKeyboard" },
    ["tamrieltomes"]  = { name = "Tamriel Tomes", icon = "OnixMenuHUD/textures/bookcrown.dds", glowIcon = "OnixMenuHUD/textures/bookcrownglow.dds", 
                         func = function() 
                             if ZO_MainMenuCategoryBarButton3 and ZO_MainMenuCategoryBarButton3.m_object and ZO_MainMenuCategoryBarButton3.m_object.m_buttonData then
                                 local categoryId = ZO_MainMenuCategoryBarButton3.m_object.m_buttonData.descriptor
                                 if SYSTEMS and SYSTEMS:GetObject("mainMenu") then
                                     SYSTEMS:GetObject("mainMenu"):ShowCategory(categoryId)
                                 end
                             end
                         end }, 
    ["dungeon"]       = { name = "Dungeon Finder", icon = "OnixMenuHUD/textures/Dungeon.dds", glowIcon = "OnixMenuHUD/textures/Dungeonglow.dds", 
                          func = function() OpenGroupMenuTab(SI_ACTIVITY_FINDER_CATEGORY_DUNGEON_FINDER, 3) end },
    ["battlegrounds"] = { name = "Battlegrounds", icon = "OnixMenuHUD/textures/banner2.dds", glowIcon = "OnixMenuHUD/textures/banner2glow.dds", 
                          func = function() OpenGroupMenuTab(SI_ACTIVITY_FINDER_CATEGORY_BATTLEGROUNDS, 4) end },
    ["addons"]        = { name = "Menu Settings", icon = "OnixMenuHUD/textures/gear.dds", glowIcon = "OnixMenuHUD/textures/gearglow.dds", 
                          func = function() 
                              local targetPanel = OnixMenuHUD.lastOpenedPanel or OnixMenuHUD.settingsPanel
                              if targetPanel then
                                  LibAddonMenu2:OpenToPanel(targetPanel)
                              end
                          end }, 
    ["reload"]        = { name = "Reload UI", icon = "OnixMenuHUD/textures/reloadui.dds", glowIcon = "OnixMenuHUD/textures/reloaduiglow.dds", 
                          func = function() ReloadUI() end },
    ["separator"]     = { name = "Separator", icon = "OnixMenuHUD/textures/separator.dds", isSeparator = true },
    ["spacer"]        = { isSpacer = true },
    ["empty"]         = { isEmpty = true }
}

local CHOICES_NAMES = {"[Empty]", "[Spacer]", "Separator Line", "Alliance War", "Battlegrounds", "Champion", "Character", "Collections", "Crown Crates", "Crown Store", "Dungeon Finder", "Friends", "Group Activities", "Guilds", "Inventory", "Journal", "Mail", "Map", "Menu Settings", "Notifications", "Reload UI", "Skills", "Tamriel Tomes"}
local CHOICES_VALUES = {"empty", "spacer", "separator", "alliance", "battlegrounds", "champion", "character", "outfits", "crates", "store", "dungeon", "friends", "group", "guilds", "inventory", "journal", "mail", "map", "addons", "notifications", "reload", "skills", "tamrieltomes"}

local HOVER_EFFECTS = {"Smooth Zoom", "Pop Up", "Pop Down"}
local GLOW_STYLES = {"Auto Outline", "Custom Painted Texture"}

function OnixMenuHUD.ManageDefaultMenu()
    if ZO_MainMenuCategoryBar then
        if OnixMenuHUD.savedVars.hideDefaultMenu then
            ZO_MainMenuCategoryBar:SetAlpha(0)
            ZO_MainMenuCategoryBar:SetMouseEnabled(false)
        else
            ZO_MainMenuCategoryBar:SetAlpha(1)
            ZO_MainMenuCategoryBar:SetMouseEnabled(true)
        end
    end
end

function OnixMenuHUD.UpdateVisibility()
    local savedVars = OnixMenuHUD.savedVars
    OnixMenuHUD.ManageDefaultMenu()
    
    if not OnixMenuHUD.fragment then return end
    
    HUD_SCENE:RemoveFragment(OnixMenuHUD.fragment)
    HUD_UI_SCENE:RemoveFragment(OnixMenuHUD.fragment)
    local escScene = SCENE_MANAGER:GetScene("gameMenuInGame")
    if escScene then escScene:RemoveFragment(OnixMenuHUD.fragment) end
    
    for _, data in pairs(ACTION_DB) do
        if data.scene then
            local s = SCENE_MANAGER:GetScene(data.scene)
            if s then s:RemoveFragment(OnixMenuHUD.fragment) end
        end
    end
    
    if savedVars.isHidden then return end
    
    if savedVars.moveMode then
        HUD_SCENE:AddFragment(OnixMenuHUD.fragment)
        HUD_UI_SCENE:AddFragment(OnixMenuHUD.fragment)
        if escScene then escScene:AddFragment(OnixMenuHUD.fragment) end
        return
    end
    
    if savedVars.hideInCombat and IsUnitInCombat("player") then return end
    
    if escScene then escScene:AddFragment(OnixMenuHUD.fragment) end
    
    if savedVars.showOnlyOnEsc then return end
    
    if not savedVars.hideInGameplay then
        HUD_SCENE:AddFragment(OnixMenuHUD.fragment)
        HUD_UI_SCENE:AddFragment(OnixMenuHUD.fragment)
    end
    
    if not savedVars.hideInMenus then
        for _, data in pairs(ACTION_DB) do
            if data.scene then
                local s = SCENE_MANAGER:GetScene(data.scene)
                if s then s:AddFragment(OnixMenuHUD.fragment) end
            end
        end
    end
end

function OnixMenuHUD.BuildUI()
    local savedVars = OnixMenuHUD.savedVars
    
    local hudWindow = WINDOW_MANAGER:CreateTopLevelWindow("OnixMenuHUD_Window")
    hudWindow:SetHidden(true) 
    hudWindow:SetDimensions(500, 50)
    hudWindow:SetScale(savedVars.scale)
    hudWindow:SetClampedToScreen(true)
    
    hudWindow:ClearAnchors()
    hudWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedVars.hudX, savedVars.hudY)
    
    local moveBox = WINDOW_MANAGER:CreateControl("OnixMenuHUD_MoveBox", hudWindow, CT_BACKDROP)
    moveBox:SetDrawLayer(DL_OVERLAY)
    moveBox:SetDrawLevel(10)
    moveBox:SetAnchorFill(hudWindow)
    moveBox:SetCenterColor(0.1, 0.9, 0.2, 0.20)
    moveBox:SetEdgeColor(0.2, 1.0, 0.3, 0.50)
    moveBox:SetEdgeTexture("", 8, 2, 0)
    moveBox:SetMouseEnabled(false)
    
    hudWindow:SetHandler("OnMoveStop", function(self)
        savedVars.hudX = self:GetLeft()
        savedVars.hudY = self:GetTop()
        self:ClearAnchors()
        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedVars.hudX, savedVars.hudY)
    end)
    
    OnixMenuHUD.moveBox = moveBox
    OnixMenuHUD.window = hudWindow
    OnixMenuHUD.buttons = {}
    
    OnixMenuHUD.fragment = ZO_HUDFadeSceneFragment:New(OnixMenuHUD.window, nil, 0)
    
    OnixMenuHUD.RefreshButtons()
    OnixMenuHUD.UpdateMoveMode()
end

function OnixMenuHUD.UpdateMoveMode()
    local isMoving = OnixMenuHUD.savedVars.moveMode
    local window = OnixMenuHUD.window
    local moveBox = OnixMenuHUD.moveBox
    if not window or not moveBox then return end
    
    moveBox:SetHidden(not isMoving)
    window:SetMouseEnabled(isMoving)
    window:SetMovable(isMoving)
    
    if OnixMenuHUD.buttons then
        for _, btn in pairs(OnixMenuHUD.buttons) do
            btn:SetMouseEnabled(not isMoving)
        end
    end
end

function OnixMenuHUD.RefreshButtons()
    local savedVars = OnixMenuHUD.savedVars
    local window = OnixMenuHUD.window
    if not window then return end
    
    local currentX = 0
    local buttonSize = savedVars.iconSize or 40
    local spacerSize = savedVars.spacerWidth or 20
    
    if OnixMenuHUD.buttons then
        for _, btn in pairs(OnixMenuHUD.buttons) do 
            btn:SetHidden(true) 
            btn:ClearAnchors()
            
            local label = WINDOW_MANAGER:GetControlByName(btn:GetName() .. "_Label")
            if label then label:SetHidden(true) end
            
            local glow = WINDOW_MANAGER:GetControlByName(btn:GetName() .. "_Glow")
            if glow then glow:SetHidden(true) end
        end
    end
    
    for i, slotKey in ipairs(savedVars.slots) do
        local slotData = ACTION_DB[slotKey]
        
        if slotData and not slotData.isEmpty then
            if slotData.isSpacer then
                currentX = currentX + spacerSize
            else
                local btnName = "OnixMenuHUD_Btn_" .. i
                local btn = WINDOW_MANAGER:GetControlByName(btnName)
                
                if not btn then
                    btn = WINDOW_MANAGER:CreateControl(btnName, window, CT_TEXTURE)
                end
                
                btn:SetDrawLayer(DL_CONTROLS)
                btn:SetDrawLevel(2)
                btn:SetDimensions(buttonSize, buttonSize)
                btn:SetAnchor(CENTER, window, LEFT, currentX + (buttonSize / 2), 0)
                btn:SetTexture(slotData.icon)
                btn:SetColor(savedVars.colorR, savedVars.colorG, savedVars.colorB, savedVars.alpha)
                btn:SetMouseEnabled(not slotData.isSeparator and not savedVars.moveMode)
                btn:SetHidden(false)
                
                local glowName = btnName .. "_Glow"
                local glow = WINDOW_MANAGER:GetControlByName(glowName)
                if not glow then
                    glow = WINDOW_MANAGER:CreateControl(glowName, window, CT_TEXTURE)
                end
                
                glow:SetDrawLayer(DL_CONTROLS)
                glow:SetDrawLevel(1)
                glow:ClearAnchors()
                glow:SetAnchor(CENTER, btn, CENTER, 0, 0)
                glow:SetHidden(true)
                
                local labelName = btnName .. "_Label"
                local label = WINDOW_MANAGER:GetControlByName(labelName)
                if not label then
                    label = WINDOW_MANAGER:CreateControl(labelName, btn, CT_LABEL)
                end
                
                label:SetDrawLayer(DL_CONTROLS)
                label:SetDrawLevel(3)
                label:ClearAnchors()
                
                if savedVars.labelPosition == "TOP" then
                    label:SetAnchor(BOTTOM, btn, TOP, 0, -2)
                    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
                elseif savedVars.labelPosition == "BOTTOM" then
                    label:SetAnchor(TOP, btn, BOTTOM, 0, 2)
                    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
                elseif savedVars.labelPosition == "LEFT" then
                    label:SetAnchor(RIGHT, btn, LEFT, -5, 0)
                    label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
                elseif savedVars.labelPosition == "RIGHT" then
                    label:SetAnchor(LEFT, btn, RIGHT, 5, 0)
                    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
                end
                
                label:SetText(slotData.name or "")
                label:SetColor(savedVars.labelColorR, savedVars.labelColorG, savedVars.labelColorB, 1)
                
                local outlineStr = savedVars.fontOutline == "none" and "" or savedVars.fontOutline
                local fontString = string.format("%s|%d|%s", savedVars.fontType, savedVars.fontSize, outlineStr)
                label:SetFont(fontString)
                label:SetHidden(not savedVars.showLabels or slotData.isSeparator)
                
                local origX = currentX + (buttonSize / 2)
                
                if not slotData.isSeparator then
                    btn:SetHandler("OnMouseEnter", function(self) 
                        if savedVars.moveMode then return end
                        
                        if savedVars.enableHoverTint then
                            self:SetColor(savedVars.hoverTintR, savedVars.hoverTintG, savedVars.hoverTintB, 1) 
                        end
                        
                        local effect = savedVars.hoverEffect
                        local intensity = savedVars.hoverIntensity
                        local currentButtonSize = buttonSize
                        
                        if effect == "Smooth Zoom" then
                            currentButtonSize = buttonSize * (intensity / 100)
                            self:SetDimensions(currentButtonSize, currentButtonSize)
                        elseif effect == "Pop Up" then
                            local offset = -((intensity - 100) / 2) 
                            self:ClearAnchors()
                            self:SetAnchor(CENTER, window, LEFT, origX, offset)
                        elseif effect == "Pop Down" then
                            local offset = ((intensity - 100) / 2)
                            self:ClearAnchors()
                            self:SetAnchor(CENTER, window, LEFT, origX, offset)
                        end
                        
                        if savedVars.enableHoverGlow then
                            local finalGlowSize = currentButtonSize + (savedVars.hoverGlowSize or 8)
                            glow:SetDimensions(finalGlowSize, finalGlowSize)
                            
                            if savedVars.glowStyle == "Custom Painted Texture" and slotData.glowIcon then
                                glow:SetTexture(slotData.glowIcon)
                                glow:SetBlendMode(TEX_BLEND_MODE_ALPHA)
                                glow:SetColor(savedVars.hoverGlowR, savedVars.hoverGlowG, savedVars.hoverGlowB, savedVars.hoverGlowAlpha)
                            else
                                glow:SetTexture(slotData.icon)
                                glow:SetBlendMode(TEX_BLEND_MODE_ADD)
                                glow:SetColor(savedVars.hoverGlowR, savedVars.hoverGlowG, savedVars.hoverGlowB, savedVars.hoverGlowAlpha)
                            end
                            
                            glow:SetHidden(false)
                        end
                        
                        if savedVars.showLabels and savedVars.applyHoverToText then
                            label:SetColor(savedVars.hoverTintR, savedVars.hoverTintG, savedVars.hoverTintB, 1)
                        elseif not savedVars.showLabels then
                            InitializeTooltip(InformationTooltip, self, BOTTOM, 0, 5, TOP)
                            SetTooltipText(InformationTooltip, slotData.name)
                        end
                    end)
                    
                    btn:SetHandler("OnMouseExit", function(self) 
                        if savedVars.moveMode then return end
                        
                        self:SetColor(savedVars.colorR, savedVars.colorG, savedVars.colorB, savedVars.alpha) 
                        self:SetDimensions(buttonSize, buttonSize)
                        self:ClearAnchors()
                        self:SetAnchor(CENTER, window, LEFT, origX, 0)
                        
                        glow:SetHidden(true)
                        
                        if savedVars.showLabels and savedVars.applyHoverToText then
                            label:SetColor(savedVars.labelColorR, savedVars.labelColorG, savedVars.labelColorB, 1)
                        end
                        
                        ClearTooltip(InformationTooltip)
                    end)
                    
                    btn:SetHandler("OnMouseUp", function(self, button)
                        if savedVars.moveMode then return end
                        if button == 1 then
                            if slotData.scene then
                                SCENE_MANAGER:Show(slotData.scene)
                            elseif slotData.func then
                                slotData.func()
                            end
                        end
                    end)
                end
                
                OnixMenuHUD.buttons[i] = btn
                currentX = currentX + buttonSize + savedVars.padding
            end
        end
    end
    
    local totalWidth = math.max(currentX, buttonSize)
    window:SetDimensions(totalWidth, buttonSize + 10)
    
    if not OnixMenuHUD.bg then
        OnixMenuHUD.bg = WINDOW_MANAGER:CreateControl("OnixMenuHUD_BG", window, CT_TEXTURE)
        OnixMenuHUD.bg:SetDrawLayer(DL_BACKGROUND)
        OnixMenuHUD.bg:SetDrawLevel(0) 
    end
    
    OnixMenuHUD.bg:ClearAnchors()
    OnixMenuHUD.bg:SetAnchor(CENTER, window, CENTER, savedVars.bgOffsetX, savedVars.bgOffsetY)
    OnixMenuHUD.bg:SetDimensions(savedVars.bgWidth, savedVars.bgHeight)
    
    if savedVars.bgStyle == "" or savedVars.bgStyle == nil then
        OnixMenuHUD.bg:SetTexture(nil)
    else
        OnixMenuHUD.bg:SetTexture(savedVars.bgStyle)
    end
    
    OnixMenuHUD.bg:SetColor(savedVars.bgColorR, savedVars.bgColorG, savedVars.bgColorB, savedVars.bgAlpha)
    OnixMenuHUD.bg:SetHidden(not savedVars.showBg)
    OnixMenuHUD.bg:SetMouseEnabled(false)
end

function OnixMenuHUD.CreateSettings()
    local LAM = LibAddonMenu2
    
    local panelData = {
        type = "panel",
        name = "0nix MenuHUD",
        displayName = "|cFFFFFF0NIX|r |cFFFABBMENUHUD|r - |c55FF55EASY NAVIGATION|r",
        author = "|c00E5FFNatosz|r",
        version = "|c00FF00" .. OnixMenuHUD.version .. "|r",
        registerForRefresh = true,
        registerForDefaults = true
    }
    
    OnixMenuHUD.settingsPanel = LAM:RegisterAddonPanel("OnixMenuHUD_Settings", panelData)
    
    local optionsData = {
        {
            type = "button",
            name = "Reset Default Settings",
            tooltip = "Restore all settings to their original state and reload the interface.",
            isDangerous = true,
            warning = "Are you sure you want to reset and go back to default settings? This will reload the UI.",
            func = function()
                for k, v in pairs(OnixMenuHUD.defaultConfig) do
                    if type(v) == "table" then
                        OnixMenuHUD.savedVars[k] = ZO_DeepTableCopy(v)
                    else
                        OnixMenuHUD.savedVars[k] = v
                    end
                end
                ReloadUI()
            end
        },
        {
            type = "header",
            name = "Global Settings"
        },
        {
            type = "checkbox",
            name = "Move Mode (Unlock & Drag)",
            tooltip = "Shows a soft green box to drag and position the HUD anywhere on your screen.",
            getFunc = function() return OnixMenuHUD.savedVars.moveMode end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.moveMode = value
                OnixMenuHUD.UpdateMoveMode()
                OnixMenuHUD.UpdateVisibility()
            end
        },
        {
            type = "checkbox",
            name = "Turn Off HUD",
            tooltip = "Hides the bar completely.",
            getFunc = function() return OnixMenuHUD.savedVars.isHidden end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.isHidden = value
                OnixMenuHUD.UpdateVisibility()
            end
        },
        {
            type = "checkbox",
            name = "Hide Default Menu",
            tooltip = "Hides the standard ESO top menu bar to prevent overlapping.",
            getFunc = function() return OnixMenuHUD.savedVars.hideDefaultMenu end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.hideDefaultMenu = value
                OnixMenuHUD.ManageDefaultMenu()
            end
        },
        {
            type = "slider",
            name = "Overall Scale",
            tooltip = "Scales the entire HUD window.",
            min = 50, max = 200, step = 5,
            getFunc = function() return OnixMenuHUD.savedVars.scale * 100 end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.scale = value / 100
                OnixMenuHUD.window:SetScale(OnixMenuHUD.savedVars.scale)
            end
        },
        {
            type = "slider",
            name = "Icon Size",
            tooltip = "Controls the width and height of each icon in pixels.",
            min = 20, max = 100, step = 2,
            getFunc = function() return OnixMenuHUD.savedVars.iconSize end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.iconSize = value
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "slider",
            name = "Icon Opacity",
            tooltip = "Controls the transparency of the icons only.",
            min = 10, max = 100, step = 10,
            getFunc = function() return OnixMenuHUD.savedVars.alpha * 100 end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.alpha = value / 100
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "slider",
            name = "Icon Spacing",
            tooltip = "Distance between adjacent icons.",
            min = -30, max = 100, step = 1,
            getFunc = function() return OnixMenuHUD.savedVars.padding end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.padding = value
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "slider",
            name = "Spacer Width",
            tooltip = "Adjusts horizontal distance created by [Spacer] slots.",
            min = 0, max = 100, step = 2,
            getFunc = function() return OnixMenuHUD.savedVars.spacerWidth end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.spacerWidth = value
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "colorpicker",
            name = "Base Icon Color",
            getFunc = function() return OnixMenuHUD.savedVars.colorR, OnixMenuHUD.savedVars.colorG, OnixMenuHUD.savedVars.colorB, 1 end,
            setFunc = function(r, g, b, a)
                OnixMenuHUD.savedVars.colorR = r
                OnixMenuHUD.savedVars.colorG = g
                OnixMenuHUD.savedVars.colorB = b
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "header",
            name = "Hide When Settings"
        },
        {
            type = "checkbox",
            name = "Hide in Combat",
            tooltip = "Automatically hides the HUD when you enter combat.",
            getFunc = function() return OnixMenuHUD.savedVars.hideInCombat end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.hideInCombat = value
                OnixMenuHUD.UpdateVisibility()
            end
        },
        {
            type = "checkbox",
            name = "Hide in Other Menus",
            tooltip = "Hides the HUD when other fullscreen menus are open.",
            getFunc = function() return OnixMenuHUD.savedVars.hideInMenus end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.hideInMenus = value
                OnixMenuHUD.UpdateVisibility()
            end
        },
        {
            type = "checkbox",
            name = "Show Only on Esc Menu",
            tooltip = "Hides the HUD during normal gameplay and only shows it when you press ESC.",
            getFunc = function() return OnixMenuHUD.savedVars.showOnlyOnEsc end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.showOnlyOnEsc = value
                OnixMenuHUD.UpdateVisibility()
            end
        },
        {
            type = "checkbox",
            name = "Hide on Normal Gameplay",
            tooltip = "Hides the HUD while exploring the world, but displays it on other menus.",
            getFunc = function() return OnixMenuHUD.savedVars.hideInGameplay end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.hideInGameplay = value
                OnixMenuHUD.UpdateVisibility()
            end
        },
        {
            type = "header",
            name = "Cursor Hover"
        },
        {
            type = "checkbox",
            name = "Enable Icon Highlight",
            tooltip = "Changes the base icon color when the cursor is over it.",
            getFunc = function() return OnixMenuHUD.savedVars.enableHoverTint end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.enableHoverTint = value
            end
        },
        {
            type = "colorpicker",
            name = "Highlight Color",
            getFunc = function() return OnixMenuHUD.savedVars.hoverTintR, OnixMenuHUD.savedVars.hoverTintG, OnixMenuHUD.savedVars.hoverTintB, 1 end,
            setFunc = function(r, g, b, a)
                OnixMenuHUD.savedVars.hoverTintR = r
                OnixMenuHUD.savedVars.hoverTintG = g
                OnixMenuHUD.savedVars.hoverTintB = b
            end
        },
        {
            type = "dropdown",
            name = "Hover Animation Effect",
            tooltip = "Choose the visual motion effect triggered on hover.",
            choices = HOVER_EFFECTS,
            getFunc = function() return OnixMenuHUD.savedVars.hoverEffect end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.hoverEffect = value
            end
        },
        {
            type = "slider",
            name = "Animation Intensity (%)",
            tooltip = "Controls the size of the zoom and the distance of the pop up/down.",
            min = 100, max = 150, step = 5,
            getFunc = function() return OnixMenuHUD.savedVars.hoverIntensity end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.hoverIntensity = value
            end
        },
        {
            type = "checkbox",
            name = "Enable Outline Glow",
            tooltip = "Activates the glow effect behind the icon.",
            getFunc = function() return OnixMenuHUD.savedVars.enableHoverGlow end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.enableHoverGlow = value
            end
        },
        {
            type = "dropdown",
            name = "Glow Style",
            tooltip = "Choose between the auto-generated color outline or your custom painted glow textures.",
            choices = GLOW_STYLES,
            getFunc = function() return OnixMenuHUD.savedVars.glowStyle end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.glowStyle = value
            end
        },
        {
            type = "colorpicker",
            name = "Glow Color",
            tooltip = "Changes the color of the glow effect.",
            getFunc = function() return OnixMenuHUD.savedVars.hoverGlowR, OnixMenuHUD.savedVars.hoverGlowG, OnixMenuHUD.savedVars.hoverGlowB, 1 end,
            setFunc = function(r, g, b, a)
                OnixMenuHUD.savedVars.hoverGlowR = r
                OnixMenuHUD.savedVars.hoverGlowG = g
                OnixMenuHUD.savedVars.hoverGlowB = b
            end
        },
        {
            type = "slider",
            name = "Glow Opacity",
            min = 0, max = 100, step = 5,
            getFunc = function() return OnixMenuHUD.savedVars.hoverGlowAlpha * 100 end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.hoverGlowAlpha = value / 100
            end
        },
        {
            type = "slider",
            name = "Glow Spread Thickness",
            tooltip = "How thick the glow outline extends past the icon.",
            min = 0, max = 30, step = 2,
            getFunc = function() return OnixMenuHUD.savedVars.hoverGlowSize end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.hoverGlowSize = value
            end
        },
        {
            type = "header",
            name = "Background Settings"
        },
        {
            type = "checkbox",
            name = "Show Background",
            tooltip = "Displays a background behind the icons.",
            getFunc = function() return OnixMenuHUD.savedVars.showBg end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.showBg = value
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "dropdown",
            name = "Background Style",
            choices = {"Solid", "Custom 1", "Custom 2", "Custom 3", "Custom 4", "Custom 5"},
            choicesValues = {
                "", 
                "OnixMenuHUD/textures/bg_custom1.dds", 
                "OnixMenuHUD/textures/bg_custom2.dds", 
                "OnixMenuHUD/textures/bg_custom3.dds", 
                "OnixMenuHUD/textures/bg_custom4.dds", 
                "OnixMenuHUD/textures/bg_custom5.dds"
            },
            getFunc = function() return OnixMenuHUD.savedVars.bgStyle end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.bgStyle = value
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "slider",
            name = "Background Width",
            min = 50, max = 1500, step = 10,
            getFunc = function() return OnixMenuHUD.savedVars.bgWidth end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.bgWidth = value
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "slider",
            name = "Background Height",
            min = 10, max = 300, step = 5,
            getFunc = function() return OnixMenuHUD.savedVars.bgHeight end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.bgHeight = value
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "slider",
            name = "Offset X (Left / Right)",
            min = -500, max = 500, step = 5,
            getFunc = function() return OnixMenuHUD.savedVars.bgOffsetX end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.bgOffsetX = value
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "slider",
            name = "Offset Y (Up / Down)",
            min = -500, max = 500, step = 5,
            getFunc = function() return OnixMenuHUD.savedVars.bgOffsetY end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.bgOffsetY = value
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "colorpicker",
            name = "Background Color",
            getFunc = function() return OnixMenuHUD.savedVars.bgColorR, OnixMenuHUD.savedVars.bgColorG, OnixMenuHUD.savedVars.bgColorB, 1 end,
            setFunc = function(r, g, b, a)
                OnixMenuHUD.savedVars.bgColorR = r
                OnixMenuHUD.savedVars.bgColorG = g
                OnixMenuHUD.savedVars.bgColorB = b
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "slider",
            name = "Background Opacity",
            min = 0, max = 100, step = 5,
            getFunc = function() return OnixMenuHUD.savedVars.bgAlpha * 100 end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.bgAlpha = value / 100
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "header",
            name = "Text Settings"
        },
        {
            type = "checkbox",
            name = "Show Icon Names",
            tooltip = "Displays the name of the menu around the icon.",
            getFunc = function() return OnixMenuHUD.savedVars.showLabels end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.showLabels = value
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "checkbox",
            name = "Apply Cursor Hover Effects",
            tooltip = "Highlights the text with the cursor hover color when hovering the icon.",
            getFunc = function() return OnixMenuHUD.savedVars.applyHoverToText end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.applyHoverToText = value
            end
        },
        {
            type = "dropdown",
            name = "Font Type",
            choices = {"Standard", "Bold", "Chat", "Antique"},
            choicesValues = {"$(MEDIUM_FONT)", "$(BOLD_FONT)", "$(CHAT_FONT)", "$(ANTIQUE_FONT)"},
            getFunc = function() return OnixMenuHUD.savedVars.fontType end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.fontType = value
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "slider",
            name = "Font Size",
            min = 8, max = 32, step = 1,
            getFunc = function() return OnixMenuHUD.savedVars.fontSize end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.fontSize = value
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "dropdown",
            name = "Font Outline",
            choices = {"None", "Shadow", "Outline", "Thick Outline"},
            choicesValues = {"none", "shadow", "outline", "thick-outline"},
            getFunc = function() return OnixMenuHUD.savedVars.fontOutline end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.fontOutline = value
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "dropdown",
            name = "Text Position",
            choices = {"Top", "Bottom", "Left", "Right"},
            choicesValues = {"TOP", "BOTTOM", "LEFT", "RIGHT"},
            getFunc = function() return OnixMenuHUD.savedVars.labelPosition end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.labelPosition = value
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "colorpicker",
            name = "Text Color",
            getFunc = function() return OnixMenuHUD.savedVars.labelColorR, OnixMenuHUD.savedVars.labelColorG, OnixMenuHUD.savedVars.labelColorB, 1 end,
            setFunc = function(r, g, b, a)
                OnixMenuHUD.savedVars.labelColorR = r
                OnixMenuHUD.savedVars.labelColorG = g
                OnixMenuHUD.savedVars.labelColorB = b
                OnixMenuHUD.RefreshButtons()
            end
        },
        {
            type = "header",
            name = "Icon Layout"
        }
    }
    
    for i = 1, 27 do
        table.insert(optionsData, {
            type = "dropdown",
            name = "Slot " .. i,
            choices = CHOICES_NAMES,
            choicesValues = CHOICES_VALUES,
            getFunc = function() return OnixMenuHUD.savedVars.slots[i] or "empty" end,
            setFunc = function(value)
                OnixMenuHUD.savedVars.slots[i] = value
                OnixMenuHUD.RefreshButtons()
            end
        })
    end
    
    LAM:RegisterOptionControls("OnixMenuHUD_Settings", optionsData)
    
    SLASH_COMMANDS["/onix"] = function() LAM:OpenToPanel(OnixMenuHUD.settingsPanel) end
    SLASH_COMMANDS["/0nix"] = function() LAM:OpenToPanel(OnixMenuHUD.settingsPanel) end
end

local function OnAddOnLoaded(event, addonName)
    if addonName ~= OnixMenuHUD.name then return end
    EVENT_MANAGER:UnregisterForEvent(OnixMenuHUD.name, EVENT_ADD_ON_LOADED)
    
    OnixMenuHUD.savedVars = ZO_SavedVars:NewAccountWide(OnixMenuHUD.savedVarsName, 1, GetWorldName(), OnixMenuHUD.defaultConfig)
    
    OnixMenuHUD.BuildUI()
    OnixMenuHUD.CreateSettings()
    
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
        OnixMenuHUD.lastOpenedPanel = panel
    end)
    
    EVENT_MANAGER:RegisterForEvent(OnixMenuHUD.name, EVENT_PLAYER_COMBAT_STATE, function() 
        OnixMenuHUD.UpdateVisibility() 
    end)
    
    EVENT_MANAGER:RegisterForEvent(OnixMenuHUD.name, EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(OnixMenuHUD.name, EVENT_PLAYER_ACTIVATED)
        OnixMenuHUD.UpdateVisibility()
    end)
end

EVENT_MANAGER:RegisterForEvent(OnixMenuHUD.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)