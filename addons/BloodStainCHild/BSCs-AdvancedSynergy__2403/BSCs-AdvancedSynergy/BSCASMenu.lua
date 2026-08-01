local BSCAS = BSCASynergy or {}
BSCASynergy = BSCAS


local WM = GetWindowManager()
local LAM2 = LibAddonMenu2
local tabButtons = {}
local tabPanels = {}
local tabButtonsPanel
local controlPanel
local controlPanelWidth
local ActivePanelID = 1

local apiVersion = GetAPIVersion()

local tabNames = {
    GetString(SI_SYNERGY_MENU_TITLE_BLOCK),--"Blocking",
    GetString(SI_SYNERGY_MENU_TITLE_ALKOSH),--"Alkosh",
    GetString(SI_SYNERGY_MENU_TITLE_SLAYER),--"Slayer",
    GetString(SI_SYNERGY_MENU_TITLE_TRACKING),--"Tracking",
    GetString(SI_SYNERGY_MENU_TITLE_GTRACKING),--"Group Tracking",
    GetString(SI_SYNERGY_MENU_TITLE_TTRACKING),--"Target Tracking",
}
if apiVersion >= 101048 then
    table.insert(tabNames, GetString(SI_SYNERGY_MENU_TITLE_PRIORITY)) -- "Priority" 
end

local headernames = {
	GetString(SI_SYNERGY_NAME_BASE),
	GetString(SI_SYNERGY_NAME_ALKOSH),
	GetString(SI_SYNERGY_NAME_MSLAYER),
	GetString(SI_SYNERGY_UI_TRACK_SETTINGS),
	"Group " .. GetString(SI_SYNERGY_UI_TRACK_SETTINGS),
	"Target " .. GetString(SI_SYNERGY_UI_TRACK_SETTINGS),
	GetString(SI_SYNERGY_UI_PRIO_MENU),
	"Debug",
}

local function CallDonate()
    SCENE_MANAGER:Show('mailSend')
    zo_callLater(function()
		ZO_MailSendToField:SetText(BSCAS.Author)
		ZO_MailSendSubjectField:SetText(BSCAS.Name)
		ZO_MailSendBodyField:TakeFocus()
    end, 250)
end

local function PlaceInFlow(parent, control, width)
    parent._flow = parent._flow or {
        lastBottom = nil,
        pendingLeft = nil,
        hSpacing = 20,
        vSpacing = 15,
    }
    local F = parent._flow

    control:ClearAnchors()
	
	local isInSubmenu = false
    local testParent = parent
    while testParent do
        if testParent.data and testParent.data.type == "submenu" then
            isInSubmenu = true
            break
        end
        testParent = testParent:GetParent()
    end
	
	if parent:GetWidth() <= 0 then parent:SetWidth(controlPanelWidth) end
	
    local totalWidth = (parent.scroll and parent.scroll:GetWidth()) or parent:GetWidth() or 600
	
	if totalWidth <= 0 then totalWidth = 600 end
    local halfWidth = (totalWidth - F.hSpacing) / 2

    if control.data and control.data.type == "header" then
        control:SetWidth(totalWidth)

        local yOffset = F.vSpacing + 5 
        if F.lastBottom then
            control:SetAnchor(TOPLEFT, F.lastBottom, BOTTOMLEFT, 0, yOffset)
        else
            control:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, yOffset)
        end

        F.lastBottom = control
        F.pendingLeft = nil
        return
    end

    if width == "half" then
		control:SetWidth(halfWidth)

        if not F.pendingLeft then
            if F.lastBottom then
                control:SetAnchor(TOPLEFT, F.lastBottom, BOTTOMLEFT, 0, F.vSpacing)
            else
                control:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, F.vSpacing)
            end
            F.pendingLeft = control
        else
            control:SetAnchor(TOPLEFT, F.pendingLeft, TOPRIGHT, F.hSpacing, 0)
            F.lastBottom = F.pendingLeft
            F.pendingLeft = nil
        end
    else
		if isInSubmenu then
            control:SetWidth(math.min(totalWidth, 510))
		else
			control:SetWidth(totalWidth)
        end
		
        if F.pendingLeft then
            F.lastBottom = F.pendingLeft
            F.pendingLeft = nil
        end
        if F.lastBottom then
            control:SetAnchor(TOPLEFT, F.lastBottom, BOTTOMLEFT, 0, F.vSpacing)
        else
            control:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, F.vSpacing)
        end
        F.lastBottom = control
    end
	
	do
		local isCheckbox = control.data and control.data.type == "checkbox"
		if isCheckbox and width == "half" and control.label and control.container then
			local label     = control.label
			local container = control.container
			
			label:ClearAnchors()
			container:ClearAnchors()

			local rowH = 28
			control:SetHeight(rowH)
			container:SetHeight(rowH)

			container:SetDimensions(80, rowH)
			container:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
			
			local textWidth = label:GetTextWidth()
			local maxWidth = (width == "half") and 250 or 510
			label:SetDimensions(math.min(textWidth + 10, maxWidth), 28) 
			label:SetAnchor(RIGHT, container, LEFT, -10, 0) 
			label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
		end
	end
end
local function CreateTabPanel(tabID)
    local scroll = controlPanel and controlPanel.scroll or controlPanel
    if not scroll then
        d("[BSCAS] Kein gültiger Scroll-Container gefunden.")
        return
    end

    local panel = WM:CreateControl(nil, scroll, CT_CONTROL)
    panel.panel = controlPanel
    panel:SetWidth(controlPanelWidth)	
    panel:SetResizeToFitDescendents(true)
    panel:SetAnchor(TOPLEFT, tabButtonsPanel, BOTTOMLEFT, 0, 10)
    if tabID ~= 1 then panel:SetHidden(true) end
    tabPanels[tabID] = panel

    local content = WM:CreateControl(nil, panel, CT_CONTROL)
	content.panel = controlPanel 
    content:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, 0)
    content:SetResizeToFitDescendents(true)
    panel.content = content

    local header = LAMCreateControl.header(content, { type = "header", name = headernames[tabID] })
    header:SetAnchor(TOPLEFT, content, TOPLEFT, 0, 0)
    content.header = header

    local spacer = WM:CreateControl(nil, content, CT_CONTROL)
	spacer:SetHeight(10)
	spacer:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 0)
	content._flow = {
		lastBottom = spacer,
		leftPending = nil,
		hSpacing = 20,
		vSpacing = 15,
	}
end
local function HideAllUI()
	BSCASUIAlert:SetHidden(true) 
	BSCASUIAlert:SetMovable(false)			
	BSCAS.ClearDummyList() 
	BSCASAlkoshUI:SetHidden(true)			
	BSCASMSlayerUI:SetHidden(true)			
	BSCASTackingUI:SetHidden(true)			
	BSCASynergyPUI:SetHidden(true)
	BSCAS:GTrackSetHidden(true)
	BSCAS:TTrackSetHidden(true)
end
local function ShowUIForCurrentTab()
	HideAllUI()
	if ActivePanelID == 1 then
		BSCASUIAlert:SetHidden(false) 
		BSCASUIAlert:SetMovable(true) 
	elseif ActivePanelID == 2 then
		BSCAS.AlkoshDummyList() 
		BSCASAlkoshUI:SetHidden(false)
	elseif ActivePanelID == 3 then
		BSCASMSlayerUI:SetHidden(false)
	elseif ActivePanelID == 4 then
		BSCASTackingUI:SetHidden(false)
	elseif ActivePanelID == 5 then -- G tracking
		BSCAS:GTrackSetHidden(false)
	elseif ActivePanelID == 6 then -- T tracking 
		BSCAS:TTrackSetHidden(false)
	elseif ActivePanelID == 7 then
		BSCASynergyPUI:SetHidden(false)
	end
end
local function TabButtonOnClick(tabID)
	for i, btn in ipairs(tabButtons) do
		btn.button:SetState(0)
	end
	tabButtons[tabID].button:SetState(1, true)
	for id, panel in pairs(tabPanels) do
		panel:SetHidden(id ~= tabID)
	end
	if not tabPanels[tabID] then
		CreateTabPanel(tabID)
	end
	ActivePanelID = tabID
	ShowUIForCurrentTab()
end

local function CreateTabs(parent)
    tabButtonsPanel = parent
    tabButtons = {}
    controlPanelWidth = controlPanel:GetWidth() - 60

    local StartOffset   = 25           -- linker/rechter Innenabstand
    local MaxRowButton  = 4
    local padding       = 4
    local maxRowHeight  = 30

    -- 1) Button-Defs mit Breite vorbereiten (2-Pass-Layout)
    local defs = {}
    for i, name in ipairs(tabNames) do
        local w = math.max(100, #name * 8) -- deine Breitenheuristik
        defs[#defs+1] = { index=i, name=name, width=w }
    end

    -- 2) In Zeilen umbrechen
    local available = controlPanelWidth - StartOffset * 2
    local rows = {}
    local row = { items={}, width=0, count=0 }
    for _, d in ipairs(defs) do
        local wouldWidth = (row.count==0) and d.width or (row.width + padding + d.width)
        local needNew = (row.count >= MaxRowButton) or (wouldWidth > available)
        if needNew then
            if row.count > 0 then rows[#rows+1] = row end
            row = { items={}, width=0, count=0 }
        end
        if row.count > 0 then row.width = row.width + padding end
        row.items[#row.items+1] = d
        row.width = row.width + d.width
        row.count = row.count + 1
    end
    if row.count > 0 then rows[#rows+1] = row end

    -- 3) Zeilen zentriert platzieren
    local yOffset = 0
    for _, r in ipairs(rows) do
        local xOffset = StartOffset + math.max(0, math.floor((available - r.width) / 2))
        for j, d in ipairs(r.items) do
            local btn = LAMCreateControl.button(tabButtonsPanel, {
                type = "button",
                name = d.name,
                func = function() TabButtonOnClick(d.index) end
            })
            btn:SetHeight(maxRowHeight)
            btn:SetWidth(d.width)
            btn.button:SetWidth(d.width)

            btn:SetAnchor(TOPLEFT, tabButtonsPanel, TOPLEFT, xOffset, yOffset)
            tabButtons[d.index] = btn

            xOffset = xOffset + d.width + (j < r.count and padding or 0)
        end
        yOffset = yOffset + maxRowHeight + padding
    end

    -- erstes Tab aktivieren
    if tabButtons[1] then
        tabButtons[1].button:SetState(1, true)
        CreateTabPanel(1)
    end
end

function BSCAS:AddControlToTab(tabID, data)
    if not tabPanels[tabID] then CreateTabPanel(tabID) end
    local panel  = tabPanels[tabID]
    local parent = panel.content or panel
    if not parent then return end

    local t = data.type
    if t == "submenu" then
        local submenu = LAMCreateControl.submenu(parent, data)
        if not submenu then return end

        submenu.panel = controlPanel
        if submenu.scroll then submenu.scroll.panel = controlPanel end
        submenu:ClearAnchors()
        PlaceInFlow(parent, submenu, "full")
		
		local desiredWidth = 600 
		submenu:SetWidth(desiredWidth)
		if submenu.scroll then
			submenu.scroll:SetWidth(desiredWidth - 20)
		end

        if type(data.controls) == "table" then
            submenu.scroll._flow = nil
            for _, subData in ipairs(data.controls) do
                BSCAS:AddControlToSubmenu(submenu.scroll, subData)
            end
        end
        return
    end

    local factory = LAMCreateControl[t]
    if not factory then
        d(zo_strformat("[BSCAS] Unbekannter Control-Typ '<<1>>' für Tab <<2>>", tostring(t), tabID))
        return
    end

    local ctrl = factory(parent, data)
    if not ctrl then return end
    ctrl.panel = controlPanel
    if ctrl.scroll then ctrl.scroll.panel = controlPanel end

    local width = (data.width == "half") and "half" or "full"
    PlaceInFlow(parent, ctrl, width)
end
function BSCAS:AddControlToSubmenu(parentScroll, data)
    local t = data.type
    if t == "submenu" then
        local sub = LAMCreateControl.submenu(parentScroll, data)
        if not sub then return end

        sub.panel = controlPanel
        if sub.scroll then sub.scroll.panel = controlPanel end
        sub:ClearAnchors()
        PlaceInFlow(parentScroll, sub, "full")

        if type(data.controls) == "table" then
            sub.scroll._flow = nil
            for _, sd in ipairs(data.controls) do
                BSCAS:AddControlToSubmenu(sub.scroll, sd)
            end
        end
        return
    end

    local factory = LAMCreateControl[t]
    if not factory then
        d(zo_strformat("[BSCAS] Unbekannter Submenu-Control-Typ '<<1>>'", tostring(t)))
        return
    end

    local ctrl = factory(parentScroll, data)
    if not ctrl then return end
    ctrl.panel = controlPanel
    if ctrl.scroll then ctrl.scroll.panel = controlPanel end

    local width = (data.width == "half") and "half" or "full"
    PlaceInFlow(parentScroll, ctrl, width)
end


function BSCAS:InitMenu()
	local panelData = {
		type = "panel",
		name = GetString(SI_SYNERGY_MENU_NAME),
		displayName = GetString(SI_SYNERGY_MENU_NAME),
		author = BSCAS.Author,
		version = BSCAS.VersionDisplay,
		registerForRefresh = true,
		slashCommand = "/bscas",
		website = "https://www.esoui.com/downloads/info2403-BSCs-AdvancedSynergy.html",
		donation = CallDonate,
	}
	controlPanel = LAM2:RegisterAddonPanel("BSCAS_Panel", panelData)
	local optionsData = {
		{
			type = "custom",
			reference = "BSCAS_TabButtonsPanelUnique",
			width = "full",
			minHeight = 50,
		},
	}
	LAM2:RegisterOptionControls("BSCAS_Panel", optionsData)	
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
		if panel and panel:GetName() == "BSCAS_Panel" then
			if BSCAS._menuTabsBuilt then return end
			BSCAS._menuTabsBuilt = true

			local customControl = _G["BSCAS_TabButtonsPanelUnique"]
			if not customControl then
				d("[BSCAS] Tab-Panel fehlt!")
				return
			end
			CreateTabs(customControl)
		end
	end)
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
		if panel and panel:GetName() == "BSCAS_Panel" then
			ShowUIForCurrentTab()
			if BSCAS._menuBuilt then return end
			BSCAS._menuBuilt = true

			zo_callLater(function()
				BSCAS:InitBlockMenu()
				BSCAS:AddAlkoshSetting()
				BSCAS:AddMSlayerSetting()
				BSCAS:InitTrackingMenu()
				BSCAS:InitGroupTrackingMenu()
				BSCAS:InitTargetTrackingMenu()
				if GetAPIVersion() >= 101048 then
					BSCAS:InitPriorityMenu()
				end
			end, 100)
		end
	end)
		
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function(panel)
		if panel and panel:GetName() == "BSCAS_Panel" then
			HideAllUI()
		end
	end)	
end