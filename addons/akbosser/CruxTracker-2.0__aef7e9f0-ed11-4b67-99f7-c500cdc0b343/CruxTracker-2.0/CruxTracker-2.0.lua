-- CruxTracker-2.0: Minimal working base for stepwise feature restoration
local ADDON_NAME = "CruxTracker-2.0"

CruxTracker = CruxTracker or {}

-- Forward declaration for cross-calling
local CreateMinimalWidget

-- Debug: Set global flags for required globals
_G["CRUXTRACKER_HAS_EVENT_MANAGER"] = EVENT_MANAGER ~= nil
_G["CRUXTRACKER_HAS_WINDOW_MANAGER"] = WINDOW_MANAGER ~= nil
_G["CRUXTRACKER_HAS_GUIROOT"] = (GuiRoot ~= nil)

-- Define safe constants for all platforms

local DT_LOW = 1
local DT_HIGH = 3


-- SavedVars defaults
local SV_NAME = "CruxTracker_SavedVars"
local SV_VERSION = 1
local defaults = {
    left = 40,
    top = 40,
    visible = true,
    showMode = 1, -- 1 = Always, 2 = Never
    showInCombat = false,
    showIfCrux = false,
    displayStyle = 1, -- 1 = icons, 2 = number
    iconSize = 48,
    iconChoice = 1, -- 1 = trianglerune_01, 2 = crux_impact_01, 3 = crux_01, 4 = undaunted_004
    iconColor = 1, -- 1 = Green (default)
    timerFontSize = 24,
    timerX = 0,
    timerY = 0,
    timerFontColor = {1, 1, 1, 1},
    hideTimer = false,
}
local sv = nil


-- Create the widget once and update icons in place
local win = nil
local iconControls = {}
local cruxTimerLabel = nil

-- Helper: Hide widget if menus (inventory, map, settings, etc.) are open
local function IsAnyMenuOpen()
    -- These are common global functions/vars for ESO UI menus
    if SCENE_MANAGER and SCENE_MANAGER.GetCurrentSceneName then
        local scene = SCENE_MANAGER:GetCurrentSceneName()
        if scene and (
            scene:find("inventory") or scene:find("map") or scene:find("mainMenu") or scene:find("gameMenu")
            or scene:find("skills") or scene:find("collections") or scene:find("journal") or scene:find("mail")
            or scene:find("store") or scene:find("bank") or scene:find("guild") or scene:find("group")
            or scene:find("champion") or scene:find("crown") or scene:find("market") or scene:find("settings")
        ) then
            return true
        end
        -- Only check for worldMap scene explicitly (exact match)
        if scene == "worldMap" then
            return true
        end
    end
    -- Explicitly check if world map is open
    if ZO_WorldMap_IsWorldMapShowing and ZO_WorldMap_IsWorldMapShowing() then return true end
    -- Fallback: check if HUD is hidden (e.g., in menus)
    if IsReticleHidden and IsReticleHidden() then return true end
    return false
end

local function IsWidgetVisible()
    -- Always hide if world map is open (for extra reliability)
    if ZO_WorldMap_IsWorldMapShowing and ZO_WorldMap_IsWorldMapShowing() then return false end
    -- Always hide if reticle is hidden (menus open)
    if IsReticleHidden and IsReticleHidden() then return false end
    if not sv then return true end
    if sv.showMode == 2 then return false end -- Never Show
    if sv.showInCombat and not IsUnitInCombat("player") then return false end
    if sv.showIfCrux and (CruxTracker.currentCrux or 0) < 1 then return false end
    if IsAnyMenuOpen() then return false end
    return sv.visible ~= false
end

local iconColorTable = {
    {name = "Green", color = {0, 1, 0, 1}},
    {name = "Teal", color = {0, 1, 1, 1}},
    {name = "Purple", color = {1, 0, 1, 1}},
    {name = "Gold", color = {1, 0.85, 0, 1}},
    {name = "White", color = {1, 1, 1, 1}},
    {name = "Red", color = {1, 0, 0, 1}},
    {name = "Blue", color = {0, 0.5, 1, 1}},
    {name = "Orange", color = {1, 0.5, 0, 1}},
}

local function GetCurrentIconColor()
    local idx = (sv and sv.iconColor) or 1
    return unpack(iconColorTable[idx].color)
end

-- Add timer update to UpdateCruxWidget
local function UpdateCruxWidget()
    if not win then return end
    win:SetHidden(not IsWidgetVisible())
    local cruxCount = CruxTracker.currentCrux or 0
    local r, g, b, a = GetCurrentIconColor()
    -- Timer label update (fallback)
    local cruxBuffTime = nil
    local hideIcons = false
    if cruxTimerLabel then
        if sv and sv.hideTimer then
            cruxTimerLabel:SetText("")
            cruxTimerLabel:SetHidden(true)
        else
            if cruxCount > 0 then
                -- Find the Crux buff and get its endTime
                for i = 1, GetNumBuffs("player") do
                    local _, _, buffEndTime, _, buffStack, _, _, _, _, _, buffAbilityId = GetUnitBuffInfo("player", i)
                    if buffAbilityId == 184220 then
                        cruxBuffTime = buffEndTime
                        break
                    end
                end
                if cruxBuffTime then
                    local timeLeft = cruxBuffTime - GetGameTimeSeconds()
                    if timeLeft < 0 then timeLeft = 0 end
                    cruxTimerLabel:SetText(string.format("%.1fs", timeLeft))
                    cruxTimerLabel:SetHidden(false)
                    -- Clear crux counter and icons if timer hits 0
                    if timeLeft == 0 then
                        CruxTracker.currentCrux = 0
                        hideIcons = true
                    end
                else
                    cruxTimerLabel:SetText("")
                    cruxTimerLabel:SetHidden(true)
                end
            else
                cruxTimerLabel:SetText("")
                cruxTimerLabel:SetHidden(true)
            end
        end
    end
    if sv and sv.displayStyle == 2 then
        -- Number style: hide icons, show a centered number label
        for i = 1, 3 do
            if iconControls[i] then iconControls[i]:SetHidden(true) end
        end
        -- Create or update background first, then label so label is on top
        if win.bgNum == nil then
            local bgNum = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, win, CT_TEXTURE)
            if bgNum and bgNum.SetAnchor and bgNum.SetDimensions and bgNum.SetTexture and bgNum.SetColor and bgNum.SetHidden and bgNum.SetDrawTier then
                bgNum:SetAnchor(CENTER, win, CENTER, 0, 0)
                bgNum:SetDimensions((sv.iconSize or 48) + 16, (sv.iconSize or 48) + 16)
                bgNum:SetTexture("EsoUI/Art/miscellaneous/centerscreen_left.dds")
                bgNum:SetColor(0, 0.2, 0.2, 0.5)
                if bgNum.SetDrawTier then bgNum:SetDrawTier(DT_LOW) end
                win.bgNum = bgNum
            end
        else
            win.bgNum:SetDimensions((sv.iconSize or 48) + 16, (sv.iconSize or 48) + 16)
        end
        if win.bgNum and win.bgNum.SetHidden then
            win.bgNum:SetHidden(cruxCount == 0)
        end
        if not win.numLabel then
            local label = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, win, CT_LABEL)
            if label and label.SetAnchor and label.SetDimensions and label.SetFont and label.SetText and label.SetHidden and label.SetColor and label.SetDrawTier then
                label:SetAnchor(CENTER, win, CENTER, 0, 0)
                label:SetDimensions(sv.iconSize or 48, sv.iconSize or 48)
                label:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", sv.iconSize or 48))
                label:SetText(tostring(cruxCount))
                label:SetColor(r, g, b, a)
                if label.SetDrawTier then label:SetDrawTier(DT_HIGH) end
                label:SetHidden(false)
                win.numLabel = label
            end
        else
            win.numLabel:SetText(tostring(cruxCount))
            win.numLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", sv.iconSize or 48))
            if win.numLabel.SetColor then win.numLabel:SetColor(r, g, b, a) end
            win.numLabel:SetHidden(false)
        end
    else
        -- Icon style: hide number label and number background, show icons
        if win.numLabel and win.numLabel.SetHidden then win.numLabel:SetHidden(true) end
        if win.bgNum and win.bgNum.SetHidden then win.bgNum:SetHidden(true) end
        -- Hide icon backgrounds if no crux
        if win.bg and win.bg.SetHidden then win.bg:SetHidden(cruxCount == 0) end
        if win.bgtex and win.bgtex.SetHidden then win.bgtex:SetHidden(cruxCount == 0) end
        local iconPaths = {
            "/art/fx/texture/arcanist_trianglerune_01.dds",
            "/art/fx/texture/arcanist_crux_impact_01.dds",
            "/art/fx/texture/arcanist_crux_01.dds",
            "EsoUI/Art/Icons/ability_undaunted_004.dds",
        }
        local iconIdx = (sv and sv.iconChoice) or 1
        local iconPath = iconPaths[iconIdx] or iconPaths[1]
        for i = 1, 3 do
            if iconControls[i] then
                iconControls[i]:SetDimensions(sv.iconSize or 48, sv.iconSize or 48)
                iconControls[i]:SetTexture(iconPath)
                if iconControls[i].SetColor then
                    iconControls[i]:SetColor(r, g, b, a)
                end
                iconControls[i]:SetHidden(hideIcons or (i > cruxCount))
            end
        end
    end
end

-- Listen for Crux buff changes
local function OnEffectChanged(event, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    -- Updated: Use current Crux abilityId (184220) for detection
    if unitTag == "player" and (effectName == "Crux" or abilityId == 184220) then
        CruxTracker.currentCrux = stackCount or 0
        -- Find the Crux buff and get its endTime
        local cruxBuffTime = nil
        local foundCruxBuff = false
        for i = 1, GetNumBuffs("player") do
            local _, _, buffEndTime, _, buffStack, _, _, _, _, _, buffAbilityId = GetUnitBuffInfo("player", i)
            if buffAbilityId == 184220 then
                cruxBuffTime = buffEndTime
                foundCruxBuff = true
                break
            end
        end
        if not foundCruxBuff then
            -- Buff is gone, ensure crux counter is zero
            CruxTracker.currentCrux = 0
        end
        if cruxTimerLabel then
            if CruxTracker.currentCrux > 0 and cruxBuffTime then
                local timeLeft = cruxBuffTime - GetGameTimeSeconds()
                if timeLeft < 0 then timeLeft = 0 end
                cruxTimerLabel:SetText(string.format("%.1fs", timeLeft))
                cruxTimerLabel:SetHidden(false)
            else
                cruxTimerLabel:SetText("")
                cruxTimerLabel:SetHidden(true)
            end
        end
        UpdateCruxWidget()
    end
end

CruxTracker.currentCrux = 0 -- Default to 0; will be updated by event handler
CreateMinimalWidget = function()
    -- Failsafe: clamp widget position to screen bounds
    local screenW, screenH = 1920, 1080 -- fallback if GuiRoot not available
    if GuiRoot and GuiRoot.GetWidth and GuiRoot.GetHeight then
        screenW = GuiRoot:GetWidth()
        screenH = GuiRoot:GetHeight()
    end
    if sv then
        if sv.left < 0 then sv.left = 0 end
        if sv.top < 0 then sv.top = 0 end
        if sv.left > screenW - 48 then sv.left = screenW - 48 end
        if sv.top > screenH - 48 then sv.top = screenH - 48 end
    end
    if not WINDOW_MANAGER or not GuiRoot then
        _G["CRUXTRACKER_FAIL_STAGE"] = "no_window_manager_or_guiroot"
        return
    end
    if not win then
        win = WINDOW_MANAGER.CreateTopLevelWindow and WINDOW_MANAGER:CreateTopLevelWindow("CruxTrackerDisplay")
        if not win then
            _G["CRUXTRACKER_FAIL_STAGE"] = "no_win"
            return
        end
        if not (win.SetDimensions and win.SetAnchor and win.SetMovable and win.SetMouseEnabled and win.SetHidden and win.SetDrawLayer and win.SetClampedToScreen) then
            _G["CRUXTRACKER_FAIL_STAGE"] = "win_methods_missing"
            return
        end
        local size = sv and sv.iconSize or 48
        local left = (sv and sv.left) or defaults.left
        local top = (sv and sv.top) or defaults.top
        win:SetDimensions(size * 3 + 16, size + 24)
        win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
        win:SetMovable(false)
        win:SetMouseEnabled(false)
        win:SetHidden(sv and sv.visible == false)
        win:SetDrawLayer(DL_OVERLAY)
        win:SetClampedToScreen(true)

        -- Clear iconControls and remove any old icons
        for i = 1, #iconControls do
            if iconControls[i] and iconControls[i].SetHidden then
                iconControls[i]:SetHidden(true)
            end
            iconControls[i] = nil
        end

        local bg = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, win, CT_CONTROL)
        if bg and bg.SetAnchor and bg.SetDimensions and bg.SetHidden then
            bg:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
            bg:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, 0, 0)
            bg:SetDimensions(size * 3 + 16, size + 24)
            bg:SetHidden(false)
            win.bg = bg
        end

        local bgtex = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, win, CT_TEXTURE)
        if bgtex and bgtex.SetAnchor and bgtex.SetDimensions and bgtex.SetTexture and bgtex.SetColor and bgtex.SetHidden then
            bgtex:SetAnchor(CENTER, win, CENTER, 0, 0)
            bgtex:SetDimensions(size * 3 + 16, size + 24)
            bgtex:SetTexture("EsoUI/Art/miscellaneous/centerscreen_left.dds")
            bgtex:SetColor(1, 0, 0, 0.7)
            bgtex:SetHidden(false)
            win.bgtex = bgtex
        end

        local spacing = 8
        local totalWidth = (size * 3) + (spacing * 2)
        local startX = math.floor(((size * 3 + 16) - totalWidth) / 2)
        local iconPaths = {
            "/art/fx/texture/arcanist_trianglerune_01.dds",
            "/art/fx/texture/arcanist_crux_impact_01.dds",
            "/art/fx/texture/arcanist_crux_01.dds",
            "EsoUI/Art/Icons/ability_undaunted_004.dds",
        }
        local iconIdx = (sv and sv.iconChoice) or 1
        local iconPath = iconPaths[iconIdx] or iconPaths[1]
        for i = 1, 3 do
            local tex = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, win, CT_TEXTURE)
            if tex and tex.SetAnchor and tex.SetDimensions and tex.SetTexture and tex.SetHidden then
                local x = startX + ((i - 1) * (size + spacing))
                tex:SetAnchor(TOPLEFT, win, TOPLEFT, x, 12)
                tex:SetDimensions(size, size)
                tex:SetTexture(iconPath)
                if tex.SetColor then
                    tex:SetColor(r, g, b, a)
                end
                tex:SetHidden(i > (CruxTracker.currentCrux or 0))
                iconControls[i] = tex
            end
        end

        -- Always (re)create timer label if missing
        local size = sv and sv.iconSize or 48
        if not cruxTimerLabel then
            cruxTimerLabel = WINDOW_MANAGER.CreateControl and WINDOW_MANAGER:CreateControl(nil, win, CT_LABEL)
            if cruxTimerLabel and cruxTimerLabel.SetAnchor and cruxTimerLabel.SetDimensions and cruxTimerLabel.SetFont and cruxTimerLabel.SetText and cruxTimerLabel.SetHidden and cruxTimerLabel.SetColor then
                cruxTimerLabel:SetAnchor(TOP, win, TOP, sv and sv.timerX or 0, sv and sv.timerY or 0)
                cruxTimerLabel:SetDimensions(size * 3, 24)
                cruxTimerLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", sv and sv.timerFontSize or 24))
                cruxTimerLabel:SetText("")
                local r, g, b, a = 1, 1, 1, 1
                if sv and sv.timerFontColor then r, g, b, a = unpack(sv.timerFontColor) end
                cruxTimerLabel:SetColor(r, g, b, a)
                cruxTimerLabel:SetHidden(true)
            end
        else
            -- Update timer label font, anchor, and color if settings changed
            if cruxTimerLabel.SetFont then
                cruxTimerLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", sv and sv.timerFontSize or 24))
            end
            if cruxTimerLabel.SetAnchor then
                cruxTimerLabel:ClearAnchors()
                cruxTimerLabel:SetAnchor(TOP, win, TOP, sv and sv.timerX or 0, sv and sv.timerY or 0)
            end
            if cruxTimerLabel.SetColor then
                local r, g, b, a = 1, 1, 1, 1
                if sv and sv.timerFontColor then r, g, b, a = unpack(sv.timerFontColor) end
                cruxTimerLabel:SetColor(r, g, b, a)
            end
        end
    else
        -- If already created, just update visibility and size
        if win.SetHidden and sv then
            win:SetHidden(not IsWidgetVisible())
            win:SetDimensions((sv.iconSize or 48) * 3 + 16, (sv.iconSize or 48) + 24)
        end
    end
    UpdateCruxWidget()
    _G["CRUXTRACKER_FAIL_STAGE"] = "success"
    _G["CRUXTRACKER_WIDGET_VISIBLE"] = not win:IsHidden()
    _G["CRUXTRACKER_WIDGET_X"] = sv and sv.left or nil
    _G["CRUXTRACKER_WIDGET_Y"] = sv and sv.top or nil
end

-- Settings menu using LibAddonMenu-2.0
local function CreateSettingsMenu()
    if not LibAddonMenu2 then return end
    local panelData = {
        type = "panel",
        name = "CruxTracker-2.0",
        displayName = "|c00BFFFCruxTracker|r",
        author = "akbosser",
        version = "2.0",
        slashCommand = "/cruxtracker",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local optionsTable = {
        {
            type = "checkbox",
            name = "Hide Timer Label",
            tooltip = "Hide the timer label above the Crux widget.",
            getFunc = function() return sv and sv.hideTimer or false end,
            setFunc = function(val)
                if sv then sv.hideTimer = val end
                if cruxTimerLabel and cruxTimerLabel.SetHidden then
                    cruxTimerLabel:SetHidden(val)
                end
                UpdateCruxWidget()
            end,
            default = false,
        },
        {
            type = "dropdown",
            name = "Crux Icon Style",
            tooltip = "Choose which Arcanist icon to use for the Crux display.",
            choices = {"Triangle Rune"}, --[["Crux Impact","Crux Orb","Undaunted Orb"]]
            getFunc = function() return "Triangle Rune" end,
            setFunc = function(val)
                if sv then
                    if val == "Triangle Rune" then sv.iconChoice = 1 end
                    --[[
                    if val == "Crux Impact" then sv.iconChoice = 2
                    elseif val == "Crux Orb" then sv.iconChoice = 3
                    elseif val == "Undaunted Orb" then sv.iconChoice = 4
                    end
                    ]]
                end
                CreateMinimalWidget()
                UpdateCruxWidget()
            end,
            default = "Triangle Rune",
        },
        {
            type = "dropdown",
            name = "Crux Icon Color",
            tooltip = "Choose the color for the Crux icon or number.",
            choices = (function() local t = {}; for i,v in ipairs(iconColorTable) do t[i] = v.name end; return t end)(),
            getFunc = function() return iconColorTable[(sv and sv.iconColor) or 1].name end,
            setFunc = function(val)
                for i,v in ipairs(iconColorTable) do
                    if v.name == val then
                        sv.iconColor = i
                        break
                    end
                end
                UpdateCruxWidget()
            end,
            default = iconColorTable[1].name,
        },
        {
            type = "dropdown",
            name = "Crux Display",
            tooltip = "Choose when the Crux widget is shown on screen.",
            choices = {"Always Show", "Never Show"},
            getFunc = function() return (sv and sv.showMode == 2) and "Never Show" or "Always Show" end,
            setFunc = function(val) if sv then sv.showMode = (val == "Never Show") and 2 or 1 end; UpdateCruxWidget() end,
            default = "Always Show",
        },
        {
            type = "checkbox",
            name = "Show Only In Combat",
            tooltip = "Widget will only be visible while your character is in combat.",
            getFunc = function() return sv and sv.showInCombat or false end,
            setFunc = function(val) if sv then sv.showInCombat = val end; UpdateCruxWidget() end,
            default = true,
        },
        -- {
        --     type = "checkbox",
        --     name = "Show Only When Crux > 0",
        --     tooltip = "Widget will only appear if you have at least one Crux.",
        --     getFunc = function() return sv and sv.showIfCrux or false end,
        --     setFunc = function(val) if sv then sv.showIfCrux = val end; UpdateCruxWidget() end,
        --     default = false,
        -- },
        {
            type = "dropdown",
            name = "Display Style",
            tooltip = "Select how Crux is displayed: as symbols (icons) or as a number.",
            choices = {"Symbols", "Number"},
            getFunc = function() return (sv and sv.displayStyle == 2) and "Number" or "Symbols" end,
            setFunc = function(val) if sv then sv.displayStyle = (val == "Number") and 2 or 1 end; UpdateCruxWidget() end,
            default = "Symbols",
        },
        {
            type = "slider",
            name = "Icon/Number Size",
            tooltip = "Adjust the size of the Crux icons or number.",
            min = 16,
            max = 96,
            step = 2,
            getFunc = function() return (sv and sv.iconSize) or 48 end,
            setFunc = function(val)
                if sv then sv.iconSize = val end
                CreateMinimalWidget()
                UpdateCruxWidget()
            end,
            default = 48,
        },
        {
            type = "slider",
            name = "Widget X Position",
            tooltip = "Set the horizontal position of the widget.",
            min = 0,
            max = 1920,
            step = 2,
            getFunc = function() return (sv and sv.left) or 40 end,
            setFunc = function(val)
                if sv then sv.left = val end
                if win and win.SetAnchor and sv then win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.left, sv.top or 40) end
                UpdateCruxWidget()
            end,
            default = 40,
        },
        {
            type = "slider",
            name = "Widget Y Position",
            tooltip = "Set the vertical position of the widget.",
            min = 0,
            max = 1080,
            step = 2,
            getFunc = function() return (sv and sv.top) or 40 end,
            setFunc = function(val)
                if sv then sv.top = val end
                if win and win.SetAnchor and sv then win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sv.left or 40, sv.top) end
                UpdateCruxWidget()
            end,
            default = 40,
        },
        -- Timer settings (move these above Reset Position)
        {
            type = "slider",
            name = "Timer Font Size",
            tooltip = "Adjust the font size of the timer label above the widget.",
            min = 10,
            max = 48,
            step = 1,
            getFunc = function() return (sv and sv.timerFontSize) or 24 end,
            setFunc = function(val)
                if sv and not sv.hideTimer then sv.timerFontSize = val end
                if cruxTimerLabel and cruxTimerLabel.SetFont and (not sv or not sv.hideTimer) then
                    cruxTimerLabel:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thin", sv.timerFontSize or 24))
                end
            end,
            default = 24,
            disabled = function() return sv and sv.hideTimer end,
        },
        {
            type = "slider",
            name = "Timer X Position",
            tooltip = "Set the horizontal offset of the timer label above the widget.",
            min = -200,
            max = 200,
            step = 1,
            getFunc = function() return (sv and sv.timerX) or 0 end,
            setFunc = function(val)
                if sv and not sv.hideTimer then sv.timerX = val end
                if cruxTimerLabel and cruxTimerLabel.SetAnchor and (not sv or not sv.hideTimer) then
                    cruxTimerLabel:ClearAnchors()
                    cruxTimerLabel:SetAnchor(TOP, win, TOP, sv.timerX or 0, sv.timerY or 0)
                end
            end,
            default = 0,
            disabled = function() return sv and sv.hideTimer end,
        },
        {
            type = "slider",
            name = "Timer Y Position",
            tooltip = "Set the vertical offset of the timer label above the widget.",
            min = -100,
            max = 100,
            step = 1,
            getFunc = function() return (sv and sv.timerY) or 0 end,
            setFunc = function(val)
                if sv and not sv.hideTimer then sv.timerY = val end
                if cruxTimerLabel and cruxTimerLabel.SetAnchor and (not sv or not sv.hideTimer) then
                    cruxTimerLabel:ClearAnchors()
                    cruxTimerLabel:SetAnchor(TOP, win, TOP, sv.timerX or 0, sv.timerY or 0)
                end
            end,
            default = 0,
            disabled = function() return sv and sv.hideTimer end,
        },
        {
            type = "colorpicker",
            name = "Timer Font Color",
            tooltip = "Set the color of the timer label font.",
            getFunc = function()
                if sv and sv.timerFontColor then return unpack(sv.timerFontColor) end
                return 1, 1, 1, 1
            end,
            setFunc = function(r, g, b, a)
                if sv and not sv.hideTimer then sv.timerFontColor = {r, g, b, a} end
                if cruxTimerLabel and cruxTimerLabel.SetColor and (not sv or not sv.hideTimer) then
                    cruxTimerLabel:SetColor(r, g, b, a)
                end
            end,
            default = {1, 1, 1, 1},
            disabled = function() return sv and sv.hideTimer end,
        },
        {
            type = "button",
            name = "Reset Position",
            tooltip = "Reset the widget to its default position.",
            func = function()
                if sv then sv.left, sv.top = defaults.left, defaults.top end
                if win and win.SetAnchor then
                    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, defaults.left, defaults.top)
                end
            end,
        },
    }
    LibAddonMenu2:RegisterAddonPanel("CruxTracker2Panel", panelData)
    LibAddonMenu2:RegisterOptionControls("CruxTracker2Panel", optionsTable)
end


local function OnCombatState(_, inCombat)
    UpdateCruxWidget()
end

-- Listen for scene changes to update widget visibility when menus open/close
local function OnSceneStateChanged(_, scene, oldState, newState)
    -- Only update if widget exists
    if win then UpdateCruxWidget() end
end


local function StartCruxTimerUpdate()
    if EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForUpdate("CruxTracker_TimerUpdate")
        EVENT_MANAGER:RegisterForUpdate("CruxTracker_TimerUpdate", 100, UpdateCruxWidget)
    end
end

local function StopCruxTimerUpdate()
    if EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForUpdate("CruxTracker_TimerUpdate")
    end
end

local function OnAddOnLoaded(event, addonName)
    if addonName == ADDON_NAME then
        -- Load or create saved vars
        if ZO_SavedVars then
            sv = ZO_SavedVars:NewAccountWide(SV_NAME, SV_VERSION, nil, defaults)
        else
            sv = defaults
        end
        CreateMinimalWidget()
        CreateSettingsMenu()
        StartCruxTimerUpdate()
        -- Listen for Crux buff changes (replace with correct buff name/ID as needed)
        if EVENT_MANAGER then
            EVENT_MANAGER:RegisterForEvent("CruxTracker_Effect", EVENT_EFFECT_CHANGED, OnEffectChanged)
            EVENT_MANAGER:RegisterForEvent("CruxTracker_Combat", EVENT_PLAYER_COMBAT_STATE, OnCombatState)
            -- Listen for scene changes (menus opening/closing)
            if SCENE_MANAGER and SCENE_MANAGER.GetScene then
                -- Listen for all scene state changes
                local function RegisterSceneCallbacks()
                    for _, sceneName in ipairs({
                        "hud", "hudui", "inventory", "map", "mainMenu", "gameMenu", "skills", "collections", "journal", "mail", "store", "bank", "guild", "group", "champion", "crown", "market", "settings"
                    }) do
                        local scene = SCENE_MANAGER:GetScene(sceneName)
                        if scene and scene.RegisterCallback then
                            scene:RegisterCallback("StateChange", OnSceneStateChanged)
                        end
                    end
                end
                RegisterSceneCallbacks()
            end
        end
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    end
end

if EVENT_MANAGER then
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end
