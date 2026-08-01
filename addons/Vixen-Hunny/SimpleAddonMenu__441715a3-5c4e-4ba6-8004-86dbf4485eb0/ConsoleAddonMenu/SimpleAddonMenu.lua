local ADDON_NAME = "SimpleAddonMenu"

--------------------------------------------------
-- SimpleAddonMenu : LAM-style, no deps
--------------------------------------------------

local SimpleAddonMenu = SimpleAddonMenu or {}

SimpleAddonMenu.panels        = {}  -- [panelId] = panelData
SimpleAddonMenu.options       = {}  -- [panelId] = { options... }
SimpleAddonMenu.currentPanel  = nil
SimpleAddonMenu.panelControls = {}

SimpleAddonMenu.sceneName = "SimpleAddonMenu_SETTINGS_SCENE"
SimpleAddonMenu.mainMenuLabel = "Addon Settings"
SimpleAddonMenu.mainMenuIcon  = "EsoUI/Art/Journal/journal_tabicon_cadwell_up.dds"

local WM = WINDOW_MANAGER
local CONTROL_GAP   = 10
local CONTENT_WIDTH = 900

--------------------------------------------------
-- Public API – similar to LAM
--------------------------------------------------

function SimpleAddonMenu:RegisterAddonPanel(panelId, panelData)
    self.panels[panelId] = panelData
end

function SimpleAddonMenu:RegisterOptionControls(panelId, optionsTable)
    self.options[panelId] = optionsTable
end

--------------------------------------------------
-- Scene + root UI
--------------------------------------------------

local function CreateRootControl()
    if SimpleAddonMenu.root then return SimpleAddonMenu.root end

    local root = WM:CreateControl("SimpleAddonMenu_RootControl", GuiRoot, CT_CONTROL)
    root:SetAnchorFill(GuiRoot)
    root:SetHidden(true)

    -- main panel in the middle
    local panel = WM:CreateControl(nil, root, CT_CONTROL)
    panel:SetDimensions(1000, 620)
    panel:SetAnchor(CENTER, root, CENTER, 0, 0)

    local bg = WM:CreateControl(nil, panel, CT_BACKDROP)
    bg:SetAnchorFill(panel)
    bg:SetCenterColor(0, 0, 0, 0.8)
    bg:SetEdgeColor(0, 0, 0, 1)
    bg:SetEdgeTexture("", 1, 1, 1, 0)

    -- title
    local title = WM:CreateControl(nil, panel, CT_LABEL)
    title:SetFont("ZoFontWinH1")
    title:SetAnchor(TOPLEFT, panel, TOPLEFT, 40, 30)
    title:SetText("Settings")

    local subtitle = WM:CreateControl(nil, panel, CT_LABEL)
    subtitle:SetFont("ZoFontGame")
    subtitle:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 5)
    subtitle:SetText("")

    -- scroll area for options
    local scroll = WM:CreateControlFromVirtual("SimpleAddonMenu_Scroll", panel, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, subtitle, BOTTOMLEFT, 0, 20)
    scroll:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, -40, -30)
    local content = scroll:GetNamedChild("ScrollChild")

    SimpleAddonMenu.root       = root
    SimpleAddonMenu.panel      = panel
    SimpleAddonMenu.titleLabel = title
    SimpleAddonMenu.subLabel   = subtitle
    SimpleAddonMenu.content    = content

    ----------------------------------------------------------------
    -- Scene
    ----------------------------------------------------------------
    local scene = ZO_Scene:New(SimpleAddonMenu.sceneName, SCENE_MANAGER)

    local rootFragment = ZO_SimpleSceneFragment:New(root)
    scene:AddFragment(rootFragment)

    -- add the normal gamepad background so it feels native
    if GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT then
        scene:AddFragment(GAMEPAD_NAV_QUADRANT_1_BACKGROUND_FRAGMENT)
    end
    if GAMEPAD_NAV_QUADRANT_2_3_4_BACKGROUND_FRAGMENT then
        scene:AddFragment(GAMEPAD_NAV_QUADRANT_2_3_4_BACKGROUND_FRAGMENT)
    end

    SimpleAddonMenu.scene = scene
    return root
end

--------------------------------------------------
-- Helpers
--------------------------------------------------

local function CreateLabel(parent, font, text, width)
    local lbl = WM:CreateControl(nil, parent, CT_LABEL)
    lbl:SetFont(font or "ZoFontGame")
    lbl:SetText(text or "")
    lbl:SetColor(1,1,1,1)
    if width then
        lbl:SetWidth(width)
        lbl:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end
    return lbl
end

local function GetValue(opt)
    if opt.getFunc then return opt.getFunc() end
    return opt.default
end

local function SetValue(opt, v, ...)
    if opt.setFunc then opt.setFunc(v, ...) end
end

--------------------------------------------------
-- Create one option control (subset of LAM types)
--------------------------------------------------

function SimpleAddonMenu:CreateOptionControl(opt, parent, last)
    local t = opt.type
    local ctrl

    local function anchorBelow(c, height, extraGap)
        c:SetDimensions(CONTENT_WIDTH - 120, height)
        if last then
            c:SetAnchor(TOPLEFT, last, BOTTOMLEFT, 0, extraGap or CONTROL_GAP)
        else
            c:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
        end
    end

    -- HEADER
    if t == "header" then
        local lbl = CreateLabel(parent, "ZoFontWinH2", opt.name or "", CONTENT_WIDTH - 120)
        if last then
            lbl:SetAnchor(TOPLEFT, last, BOTTOMLEFT, 0, CONTROL_GAP*2)
        else
            lbl:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
        end
        ctrl = lbl

    -- DESCRIPTION
    elseif t == "description" then
        local text = opt.text or opt.name or ""
        local lbl = CreateLabel(parent, "ZoFontGame", text, CONTENT_WIDTH - 120)
        lbl:SetWrapMode(TEXT_WRAP_MODE_WORD)
        if last then
            lbl:SetAnchor(TOPLEFT, last, BOTTOMLEFT, 0, CONTROL_GAP)
        else
            lbl:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
        end
        ctrl = lbl

    -- CHECKBOX
    elseif t == "checkbox" then
        local c = WM:CreateControl(nil, parent, CT_CONTROL)
        anchorBelow(c, 30)

        local box = WM:CreateControl(nil, c, CT_BUTTON)
        box:SetDimensions(24, 24)
        box:SetAnchor(LEFT, c, LEFT, 0, 0)
        box:SetNormalTexture("EsoUI/Art/Buttons/checkbox_unchecked.dds")
        box:SetPressedTexture("EsoUI/Art/Buttons/checkbox_checked.dds")
        box:SetMouseOverTexture("EsoUI/Art/Buttons/checkbox_unchecked_mouseover.dds")

        local lbl = CreateLabel(c, "ZoFontGame", opt.name or "", 250)
        lbl:SetAnchor(LEFT, box, RIGHT, 10, 0)

        local function refresh()
            local v = GetValue(opt)
            if v then
                box:SetNormalTexture("EsoUI/Art/Buttons/checkbox_checked.dds")
            else
                box:SetNormalTexture("EsoUI/Art/Buttons/checkbox_unchecked.dds")
            end
        end

        box:SetHandler("OnClicked", function()
            local cur = GetValue(opt)
            SetValue(opt, not cur)
            refresh()
        end)

        c.Refresh = refresh
        ctrl = c

    -- SLIDER
    elseif t == "slider" then
        local c = WM:CreateControl(nil, parent, CT_CONTROL)
        anchorBelow(c, 50)

        local lbl = CreateLabel(c, "ZoFontGame", opt.name or "", 250)
        lbl:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)

        local slider = WM:CreateControl(nil, c, CT_SLIDER)
        slider:SetAnchor(TOPLEFT, lbl, BOTTOMLEFT, 0, 5)
        slider:SetDimensions(300, 14)
        slider:SetMinMax(opt.min or 0, opt.max or 1)
        slider:SetValueStep(opt.step or 1)
        slider:SetThumbTexture("EsoUI/Art/Chatwindow/chat_slider_thumb.dds", "inherit", 16, 32)
        slider:SetOrientation(ORIENTATION_HORIZONTAL)

        local val = CreateLabel(c, "ZoFontGame", "", 80)
        val:SetAnchor(LEFT, slider, RIGHT, 10, 0)

        local function refresh()
            local v = GetValue(opt) or opt.default or opt.min or 0
            slider:SetValue(v)
            val:SetText(string.format("%.2f", v))
        end

        slider:SetHandler("OnValueChanged", function(self, value, reason)
            if reason == EVENT_REASON_SOFTWARE then return end
            local v = value
            if opt.step then
                v = zo_roundToNearest(value, opt.step)
            end
            SetValue(opt, v)
            val:SetText(string.format("%.2f", v))
        end)

        c.Refresh = refresh
        ctrl = c

    -- DROPDOWN (simple)
    elseif t == "dropdown" then
        local c = WM:CreateControl(nil, parent, CT_CONTROL)
        anchorBelow(c, 50)

        local lbl = CreateLabel(c, "ZoFontGame", opt.name or "", 250)
        lbl:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)

        local comboCtrl = WM:CreateControlFromVirtual(nil, c, "ZO_ComboBox")
        comboCtrl:SetAnchor(TOPLEFT, lbl, BOTTOMLEFT, 0, 5)
        comboCtrl:SetDimensions(300, 26)

        local dropdown = ZO_ComboBox:New(comboCtrl)
        dropdown:SetSortsItems(false)

        local choices = opt.choices or {}
        local values  = opt.choicesValues or choices

        for i, text in ipairs(choices) do
            local val = values[i] or text
            dropdown:AddItem(dropdown:CreateItemEntry(text, function()
                SetValue(opt, val)
            end))
        end

        local function refresh()
            local cur = GetValue(opt)
            local idx = 1
            for i, v in ipairs(values) do
                if v == cur then idx = i break end
            end
            dropdown:SetSelectedItem(choices[idx] or choices[1] or "")
        end

        c.Refresh = refresh
        ctrl = c

    -- EDITBOX (single or multiline)
    elseif t == "editbox" then
        local c = WM:CreateControl(nil, parent, CT_CONTROL)
        anchorBelow(c, opt.isMultiline and 100 or 50)

        local lbl = CreateLabel(c, "ZoFontGame", opt.name or "", 250)
        lbl:SetAnchor(TOPLEFT, c, TOPLEFT, 0, 0)

        local template = opt.isMultiline and "ZO_DefaultEditMultiLineForBackdrop" or "ZO_DefaultEditForBackdrop"
        local edit = WM:CreateControlFromVirtual(nil, c, template)
        edit:SetAnchor(TOPLEFT, lbl, BOTTOMLEFT, 0, 5)
        edit:SetDimensions(300, opt.isMultiline and 80 or 26)

        local function refresh()
            edit:SetText(GetValue(opt) or "")
        end

        edit:SetHandler("OnFocusLost", function(self)
            local txt = self:GetText()
            if opt.isNumeric then
                SetValue(opt, tonumber(txt))
            else
                SetValue(opt, txt)
            end
        end)

        c.Refresh = refresh
        ctrl = c

    -- SUBMENU (collapsible group of more controls)
    elseif t == "submenu" then
        local container = WM:CreateControl(nil, parent, CT_CONTROL)
        container:SetWidth(CONTENT_WIDTH - 120)
        container:SetResizeToFitDescendents(true)
        if last then
            container:SetAnchor(TOPLEFT, last, BOTTOMLEFT, 0, CONTROL_GAP*2)
        else
            container:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
        end

        local header = WM:CreateControl(nil, container, CT_BUTTON)
        header:SetDimensions(CONTENT_WIDTH - 120, 30)
        header:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)

        local hBg = WM:CreateControl(nil, header, CT_BACKDROP)
        hBg:SetAnchorFill(header)
        hBg:SetCenterColor(0.2,0.2,0.2,1)

        local arrow = WM:CreateControl(nil, header, CT_TEXTURE)
        arrow:SetDimensions(24,24)
        arrow:SetAnchor(LEFT, header, LEFT, 4, 0)
        arrow:SetTexture("EsoUI/Art/Miscellaneous/list_sortheader_icon_sortup.dds")

        local hLabel = CreateLabel(header, "ZoFontGame", opt.name or "", 300)
        hLabel:SetAnchor(LEFT, arrow, RIGHT, 5, 0)

        local body = WM:CreateControl(nil, container, CT_CONTROL)
        body:SetWidth(CONTENT_WIDTH - 140)
        body:SetResizeToFitDescendents(true)
        body:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 20, CONTROL_GAP)

        local subLast
        local subControls = {}
        for _, subOpt in ipairs(opt.controls or {}) do
            local subCtrl = SimpleAddonMenu:CreateOptionControl(subOpt, body, subLast)
            if subCtrl then
                subLast = subCtrl
                table.insert(subControls, subCtrl)
            end
        end

        local collapsed = false
        local function updateArrow()
            if collapsed then
                arrow:SetTexture("EsoUI/Art/Miscellaneous/list_sortheader_icon_sortdown.dds")
            else
                arrow:SetTexture("EsoUI/Art/Miscellaneous/list_sortheader_icon_sortup.dds")
            end
        end

        header:SetHandler("OnClicked", function()
            collapsed = not collapsed
            body:SetHidden(collapsed)
            updateArrow()
        end)

        body:SetHidden(false)
        updateArrow()

        container.Refresh = function()
            for _, sc in ipairs(subControls) do
                if sc.Refresh then sc:Refresh() end
            end
        end

        ctrl = container
    end

    return ctrl
end

--------------------------------------------------
-- Build a full panel
--------------------------------------------------

function SimpleAddonMenu:ShowPanel(panelId)
    CreateRootControl()

    local panelData = self.panels[panelId]
    local opts      = self.options[panelId] or {}

    self.currentPanel = panelId
    self.panelControls[panelId] = {}

    -- wipe content
    local content = self.content
    local num = content:GetNumChildren()
    for i = num, 1, -1 do
        local child = content:GetChild(i-1)
    end

    -- title + subtitle
    self.titleLabel:SetText(panelData and (panelData.displayName or panelData.name) or panelId)

    local sub = ""
    if panelData and panelData.author then
        sub = panelData.author
    end
    if panelData and panelData.version then
        if sub ~= "" then sub = sub .. " - " end
        sub = sub .. "v" .. tostring(panelData.version)
    end
    self.subLabel:SetText(sub)

    local last
    for _, opt in ipairs(opts) do
        local c = self:CreateOptionControl(opt, content, last)
        if c then
            table.insert(self.panelControls[panelId], c)
            if c.Refresh then c:Refresh() end
            last = c
        end
    end

    SCENE_MANAGER:Show(self.sceneName)
end

function SimpleAddonMenu:TogglePanel(panelId)
    if SCENE_MANAGER:IsShowing(self.sceneName) and self.currentPanel == panelId then
        SCENE_MANAGER:Hide(self.sceneName)
    else
        self:ShowPanel(panelId)
    end
end

--------------------------------------------------
-- Gamepad main menu hook (under Options)
--------------------------------------------------

function SimpleAddonMenu:InsertIntoGamepadMainMenu()
    if not MAIN_MENU_GAMEPAD or not MAIN_MENU_GAMEPAD.categoryList then return end

    local list = MAIN_MENU_GAMEPAD.categoryList
    local dataList = list.dataList

    local optionsText = GetString(SI_GAMEPAD_OPTIONS_MENU)
    local insertIndex = #dataList + 1

    for i, entry in ipairs(dataList) do
        local data = entry.data
        if data and data.text == optionsText then
            insertIndex = i + 1
            break
        end
    end

    local entryData = ZO_GamepadEntryData:New(self.mainMenuLabel, self.mainMenuIcon)
    entryData.callback = function()
        -- open first registered panel by default
        local firstPanel = next(self.panels)
        if firstPanel then
            self:TogglePanel(firstPanel)
        end
    end
    if entryData.SetIconTintOnSelection then
        entryData:SetIconTintOnSelection(true)
    end

    local template = "ZO_GamepadMenuEntryTemplate"
    local newEntry = { template = template, data = entryData }
    table.insert(dataList, insertIndex, newEntry)
    list:Commit()
end

--------------------------------------------------
-- EXAMPLE: your addon using SimpleAddonMenu
--------------------------------------------------

local defaults = {
    enabled   = true,
    scale     = 1.0,
    note      = "",
    mode      = "default",
}

local SV

local panelData = {
    type        = "panel",
    name        = "My Addon",
    displayName = "|cFFFF00My Addon|r",
    author      = "You",
    version     = "1.0",
}

local optionsTable = {
    {
        type = "header",
        name = "General",
    },
    {
        type = "description",
        text = "LAM-style options, gamepad-friendly, no dependencies.",
    },
    {
        type = "checkbox",
        name = "Enable addon",
        getFunc = function() return SV.enabled end,
        setFunc = function(v) SV.enabled = v end,
        default = defaults.enabled,
    },
    {
        type = "slider",
        name = "Scale",
        min  = 0.5,
        max  = 2.0,
        step = 0.1,
        getFunc = function() return SV.scale end,
        setFunc = function(v) SV.scale = v end,
        default = defaults.scale,
    },
    {
        type = "dropdown",
        name = "Mode",
        choices       = { "default", "advanced" },
        choicesValues = { "default", "advanced" },
        getFunc = function() return SV.mode end,
        setFunc = function(v) SV.mode = v end,
        default = defaults.mode,
    },
    {
        type = "editbox",
        name = "Note",
        isMultiline = true,
        getFunc = function() return SV.note end,
        setFunc = function(text) SV.note = text end,
        default = defaults.note,
    },
    {
        type = "submenu",
        name = "Advanced",
        controls = {
            {
                type = "description",
                text = "Put more settings here.",
            },
            {
                type = "checkbox",
                name = "Example flag",
                getFunc = function() return SV.extraFlag end,
                setFunc = function(v) SV.extraFlag = v end,
                default = false,
            },
        },
    },
}

--------------------------------------------------
-- Addon init
--------------------------------------------------

local function OnLoaded(event, name)
    if name ~= "SimpleAddonMenu" then return end

    SV = ZO_SavedVars:NewAccountWide("SAMVARS", 1, nil, defaults)

    -- register LAM-style panel + options
    SimpleAddonMenu:RegisterAddonPanel("SimpleAddonMenu", panelData)
    SimpleAddonMenu:RegisterOptionControls("SimpleAddonMenu", optionsTable)

    -- slash command
    SLASH_COMMANDS["/sam"] = function()
        SimpleAddonMenu:TogglePanel(ADDON_NAME)
    end

    -- build scene root now
    CreateRootControl()

    -- once player activated, inject into gamepad main menu
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_MainMenu", EVENT_PLAYER_ACTIVATED, function()
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_MainMenu", EVENT_PLAYER_ACTIVATED)
        SimpleAddonMenu:InsertIntoGamepadMainMenu()
    end)

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoaded)