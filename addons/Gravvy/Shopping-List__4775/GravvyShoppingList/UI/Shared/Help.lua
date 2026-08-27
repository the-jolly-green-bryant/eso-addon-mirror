ShoppingListHelp = {}

local Help = ShoppingListHelp
local WINDOW_WIDTH = 650
local WINDOW_HEIGHT = 560

local function makeLabel(parent, font)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    ShoppingListAccessibility:SetFont(label, font or "ZoFontGame")
    label:SetColor(0.9, 0.9, 0.9, 1)
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    return label
end

local function makeButton(parent, text, width)
    local button = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)
    button:SetDimensions(width, 30)
    ShoppingListAccessibility:SetFont(button, "ZoFontGame")
    button:SetText(text)
    button:SetNormalFontColor(0.85, 0.78, 0.62, 1)
    button:SetMouseOverFontColor(1, 1, 1, 1)
    button:SetPressedFontColor(0.65, 0.55, 0.35, 1)
    return button
end

function Help:New(owner)
    return setmetatable({ owner = owner }, { __index = self })
end

function Help:Initialize()
    local window = WINDOW_MANAGER:CreateTopLevelWindow("ShoppingListHelpWindow")
    window:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
    window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    window:SetClampedToScreen(true)
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetHidden(true)
    window:SetDrawTier(DT_HIGH)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawLevel(6)
    self.window = window

    local backdrop = ShoppingListControls:CreateBackdrop(window)
    backdrop:SetAnchorFill(window)
    backdrop:SetCenterColor(0.035, 0.035, 0.045, 0.99)
    backdrop:SetEdgeColor(0.5, 0.42, 0.28, 0.95)
    ShoppingListAccessibility:RegisterBackdrop(backdrop, { 0.035, 0.035, 0.045, 0.99 })

    local title = makeLabel(window, "ZoFontWinH2")
    title:SetText(GetString(SI_SHOPPING_LIST_HELP_TITLE))
    title:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 10)
    title:SetDimensions(WINDOW_WIDTH - 36, 32)
    title:SetMouseEnabled(true)
    title:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StartMoving()
        end
    end)
    title:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            window:StopMovingOrResizing()
        end
    end)

    self.sectionTitle = makeLabel(window, "ZoFontWinH3")
    self.sectionTitle:SetColor(0.86, 0.78, 0.58, 1)
    self.sectionTitle:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 48)
    self.sectionTitle:SetDimensions(WINDOW_WIDTH - 36, 28)

    self.content = makeLabel(window, "ZoFontGame")
    self.content:SetAnchor(TOPLEFT, window, TOPLEFT, 18, 84)
    self.content:SetDimensions(WINDOW_WIDTH - 36, 410)
    self.content:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)

    self.gettingStarted = makeButton(
        window,
        GetString(SI_SHOPPING_LIST_HELP_GETTING_STARTED),
        130
    )
    self.gettingStarted:SetAnchor(BOTTOMLEFT, window, BOTTOMLEFT, 18, -16)
    self.gettingStarted:SetHandler("OnClicked", function()
        self:ShowSection("help")
    end)

    self.releaseNotes = makeButton(
        window,
        GetString(SI_SHOPPING_LIST_HELP_RELEASE_NOTES),
        120
    )
    self.releaseNotes:SetAnchor(LEFT, self.gettingStarted, RIGHT, 10, 0)
    self.releaseNotes:SetHandler("OnClicked", function()
        self:ShowSection("releases")
    end)

    local close = makeButton(window, GetString(SI_SHOPPING_LIST_BUTTON_CLOSE), 80)
    close:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -18, -16)
    close:SetHandler("OnClicked", function() self:Hide() end)

    self:ShowSection("help")
end

function Help:ShowSection(section)
    local showingHelp = section ~= "releases"
    self.sectionTitle:SetText(GetString(showingHelp
        and SI_SHOPPING_LIST_HELP_GETTING_STARTED
        or SI_SHOPPING_LIST_HELP_RELEASE_NOTES))
    local content = GetString(showingHelp
        and SI_SHOPPING_LIST_HELP_CONTENT
        or SI_SHOPPING_LIST_RELEASE_NOTES_CONTENT)
    if showingHelp then
        content = GetString(SI_SHOPPING_LIST_HELP_LIST_VIEWS)
            .. "\n\n"
            .. GetString(SI_SHOPPING_LIST_HELP_DUPLICATES)
            .. "\n\n"
            .. content
    end
    self.content:SetText(content)
    self.gettingStarted:SetEnabled(not showingHelp)
    self.releaseNotes:SetEnabled(showingHelp)
end

function Help:AcquireMouse()
    if IsGameCameraUIModeActive and not IsGameCameraUIModeActive() then
        self.ownsUIMode = true
        SetGameCameraUIMode(true)
    end
end

function Help:ReleaseMouse()
    if not self.ownsUIMode then
        return
    end
    if self.owner.ui and not self.owner.ui.window:IsHidden() then
        self.ownsUIMode = false
        self.owner.ui.ownsUIMode = true
        return
    end
    self.ownsUIMode = false
    if IsGameCameraUIModeActive and IsGameCameraUIModeActive() then
        SetGameCameraUIMode(false)
    end
end

function Help:Open(section)
    self:ShowSection(section or "help")
    if self.owner.ui and not self.owner.ui.window:IsHidden() then
        self.owner.ui.window:SetMouseEnabled(false)
        self.disabledMainWindow = true
    end
    self.window:SetHidden(false)
    self:AcquireMouse()
end

function Help:Hide()
    self.window:SetHidden(true)
    if self.disabledMainWindow and self.owner.ui then
        self.owner.ui.window:SetMouseEnabled(true)
    end
    self.disabledMainWindow = false
    self:ReleaseMouse()
end
