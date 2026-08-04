local SRC = SupportRotationCallouts
SRC.HowToUseMe = SRC.HowToUseMe or {}
local Guide = SRC.HowToUseMe
local WM = WINDOW_MANAGER

local GUIDE_TEXT = [[
|cFFD447HOW TO USE CONDUCTOR|r

|cFFD4471. CHOOSE YOUR ROLE|r

Open |cFFFFFFGeneral|r and choose Trial Lead, Support, or Damage Dealer. This controls which Timeline events and callouts you receive. It does not change your ESO group role.

|cFFD4472. JOIN THE GROUP|r

Players running Conductor automatically share their class, role, equipped support capabilities, skills, and ultimates. Open |cFFFFFFGroup Coverage|r to review what Conductor can verify for the current group.

|cFFD4473. SET UP YOUR DISPLAYS|r

Open |cFFFFFFControl Center|r. Enable and position the Timeline, Buffs & Debuffs Dashboard, and callouts. Most players can use the default settings.

|cFFD4474. PREPARE A RAID PLAN|r

Open |cFFFFFFRaid Setup|r.

1. Select the trial.
2. Select the difficulty and run objective.
3. Choose Recommended, Assisted, or Custom planning.
4. Select a recommended strategy.
5. Choose Recommended, 4 Teams of 3, 3 Teams of 4, or Custom trash ultimate teams.
6. Select |cFFFFFFPrepare Raid Plan|r.

Conductor scans the current group, places players into the raid roster, detects available responsibilities, builds the trash ultimate teams, and prepares the boss plan.

|cFFD4475. REVIEW THE PLAN|r

Review Team Coverage and the Raid Plan Assignments section. Conductor fills assignments whenever it can verify a provider. Unknown or missing responsibilities remain visible for the Trial Lead to review.

Recommended mode uses the suggested plan automatically. Assisted mode starts with recommendations and allows changes. Custom mode allows the Trial Lead to control the assignments and ultimate groups directly.

|cFFD4476. ADJUST ULTIMATE TEAMS|r

Use the Raid Plan Assignments section when the Trial Lead wants different trash groups or encounter-specific assignments. Choose each player from the current-group list. Conductor uses the selected team order for trash pulls and follows the selected strategy for pre-boss holds and boss rotations.

|cFFD4477. SAVE THE TEAM WHEN USEFUL|r

Saving a team is optional. Enter a Team Name and select |cFFFFFFSave Current Team Settings|r when you want to reuse the roster and role placement later.

|cFFD4478. SHARE THE RAID PLAN|r

Select |cFFFFFFShare Raid Plan|r. Group members running the same Conductor version receive an invitation.

Recipients select Accept. Conductor loads the strategy, assignments, ultimate teams, and boss plan, then creates the correct Personal Session and callouts for that player.

Use |cFFFFFFShow Plan Status|r to review accepted, pending, declined, disconnected, and incompatible players.

|cFFD4479. DURING THE RAID|r

Follow the Timeline and personal callouts. Trash Ultimate Group callouts identify the next assigned group. HOLD ULTIMATES means the selected strategy is saving ultimates for the next boss or burn window. Responsibility callouts are sent to the player assigned to perform them.

|cFFD44710. SIMPLE CONTROLS|r

X selects, opens, saves, shares, or accepts. Circle closes the current window or returns to the previous menu. Use the right joystick to scroll this guide.
]]

local function Notify(message)
    if SRC.Notify then SRC:Notify(message) end
end

function Guide:BuildKeybinds()
    if self.keybinds then return end
    self.keybinds = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        {
            name = "Back",
            keybind = "UI_SHORTCUT_NEGATIVE",
            callback = function() Guide:Hide() end,
            order = 1,
        },
    }
end

function Guide:Initialize()
    if self.window then return end
    local c = WM:CreateTopLevelWindow("ConductorHowToUseMe")
    c:SetDimensions(980, 720)
    c:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    c:SetClampedToScreen(true)
    c:SetHidden(true)

    local bg = WM:CreateControl(nil, c, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.03, 0.035, 0.05, 0.96)
    bg:SetEdgeColor(1, 0.83, 0.28, 0.9)
    bg:SetEdgeTexture(nil, 2, 2, 2)

    local title = WM:CreateControl(nil, c, CT_LABEL)
    title:SetAnchor(TOPLEFT, c, TOPLEFT, 30, 22)
    title:SetAnchor(TOPRIGHT, c, TOPRIGHT, -30, 22)
    title:SetFont("$(BOLD_FONT)|30|outline")
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetText("HOW TO USE CONDUCTOR")

    local divider = WM:CreateControl(nil, c, CT_TEXTURE)
    divider:SetAnchor(TOPLEFT, c, TOPLEFT, 42, 66)
    divider:SetAnchor(TOPRIGHT, c, TOPRIGHT, -42, 66)
    divider:SetHeight(2)
    divider:SetColor(1, 0.83, 0.28, 0.9)

    -- Use ESO's actual gamepad scroll-container template. This control owns
    -- right-stick input through DIRECTIONAL_INPUT and handles scroll extents,
    -- speed, direction, indicators, and focus exactly like native gamepad UI.
    local scrollContainer = WM:CreateControlFromVirtual("ConductorHowToUseMeScroll", c, "ZO_ScrollContainer_Gamepad")
    scrollContainer:SetAnchor(TOPLEFT, c, TOPLEFT, 34, 84)
    scrollContainer:SetAnchor(BOTTOMRIGHT, c, BOTTOMRIGHT, -34, -54)

    local scroll = scrollContainer:GetNamedChild("Scroll")
    local child = scroll and scroll:GetNamedChild("Child")
    if not scroll or not child then
        -- Defensive fallback for an unexpected template mismatch. The guide
        -- remains visible rather than producing a UI error.
        scroll = WM:CreateControlFromVirtual("ConductorHowToUseMeFallbackScroll", c, "ZO_ScrollContainer")
        scroll:SetAnchor(TOPLEFT, c, TOPLEFT, 34, 84)
        scroll:SetAnchor(BOTTOMRIGHT, c, BOTTOMRIGHT, -34, -54)
        child = scroll:GetNamedChild("ScrollChild")
    end

    child:SetWidth(890)
    local text = WM:CreateControl(nil, child, CT_LABEL)
    text:SetAnchor(TOPLEFT, child, TOPLEFT, 8, 4)
    text:SetWidth(850)
    text:SetFont("$(CHAT_FONT)|20|soft-shadow-thick")
    text:SetColor(0.95, 0.95, 0.95, 1)
    text:SetText(GUIDE_TEXT)

    local function RefreshContentSize()
        local contentHeight = math.max(900, (tonumber(text:GetTextHeight()) or 0) + 50)
        text:SetHeight(contentHeight)
        child:SetDimensions(890, contentHeight + 20)
        if scrollContainer.RefreshDirectionalInputActivation then
            scrollContainer:RefreshDirectionalInputActivation()
        end
        if scrollContainer.UpdateScrollIndicator then
            scrollContainer:UpdateScrollIndicator()
        end
    end
    RefreshContentSize()
    zo_callLater(RefreshContentSize, 50)
    zo_callLater(RefreshContentSize, 250)

    self.window = c
    self.scrollContainer = scrollContainer
    self.scroll = scroll
    self.text = text
    self:BuildKeybinds()
end

function Guide:Show()
    self:Initialize()
    if SRC.Diagnostics and SRC.Diagnostics.AcquireSettingsPanel then
        SRC.Diagnostics:AcquireSettingsPanel("howToUse")
        self.settingsPanelAcquired = true
    end
    self.scrollAccumulator = 0
    self.window:SetHidden(false)
    if KEYBIND_STRIP and self.keybinds and not self.keybindsAdded then
        KEYBIND_STRIP:AddKeybindButtonGroup(self.keybinds)
        self.keybindsAdded = true
    end
    Notify("How-to-use-me guide opened.")
end

function Guide:Hide()
    if self.window then self.window:SetHidden(true) end
    if KEYBIND_STRIP and self.keybinds and self.keybindsAdded then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybinds)
        self.keybindsAdded = false
    end
    if self.settingsPanelAcquired and SRC.Diagnostics and SRC.Diagnostics.ReleaseSettingsPanel then
        SRC.Diagnostics:ReleaseSettingsPanel("howToUse")
        self.settingsPanelAcquired = false
    end
end

function Guide:Toggle()
    self:Initialize()
    if self.window:IsHidden() then self:Show() else self:Hide() end
end
