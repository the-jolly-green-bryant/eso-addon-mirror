-- Simple Combat Alerts Revived - By Baertram (Original idea by Dio: http://www.esoui.com/downloads/author-1518.html)
--
local SCAR = {
	name = "SimpleCombatAlertsRevived",
	version = "1.2",
	author = "Baertram (original idea: Dio)",
	website = "https://www.esoui.com/downloads/info82-SimpleCombatAlerts.html",
	dbVersion = 1,
	alerts = {
		--The table key is the tipId
		-- Priority: BLOCK -> OFF BALANCE -> INTERRUPT -> DODGE
		[1] = {key = "block", tipId = 1, label = "BLOCK"},
		[2] = {key = "offBalance", tipId = 2, label = "OFF BALANCE"},
		[3] = {key = "interrupt", tipId = 3, label = "INTERRUPT"},
		[4] = {key = "dodge", tipId = 4, label = "DODGE"}
	},
	previewAlert = false,
}
SimpleCombatAlertsRevived = SCAR

SCAR.LMP = LibMediaProvider
SCAR.LAM = LibAddonMenu2

function SCAR.GetFontString(font)
	local format = "%s|%d"

	if font.style ~= "none" then
		format = format .. "|%s"
	end
	local LMP = SCAR.LMP
	return format:format(LMP:Fetch(LMP.MediaType.FONT, font.face), font.size, font.style)
end

function SCAR.UpdateLabel(label, dbTab, hide)
	if not label or not dbTab then return end
	local fontString = SCAR.GetFontString(dbTab)
	label:SetFont(fontString)
	label:SetColor(unpack(dbTab.color))
	label:SetText(hide and "" or dbTab.label)
end

function SCAR.UpdateAlert(alert, hide)
	SCAR.UpdateLabel(SCAR.controls.alert, SCAR.db.alerts[alert], hide)
end

function SCAR.BuildAddonMenu()
	if not SCAR.LAM then return end
	local LAM = SCAR.LAM
	local LMP = SCAR.LMP
	local fontsList = LMP:List(LMP.MediaType.FONT)

	local defaults = SCAR.dbDefaults
	local settings = SCAR.db

    local panelData = {
        type 				= 'panel',
        name 				= SCAR.name,
        displayName 		= SCAR.name,
        author 				= SCAR.author,
        version 			= tostring(SCAR.version),
        registerForRefresh 	= true,
        registerForDefaults = true,
        slashCommand        = "/SCARrs",
    }
	SCAR.SettingsPanel = LAM:RegisterAddonPanel(SCAR.name .. "_LAM", panelData)

	local optionsTable =
	{	-- BEGIN OF OPTIONS TABLE
        {
            type = 'header',
            name = 'Options',
        },
        {
            type = "button",
            name = 'Preview & move',
            tooltip = 'Toggle the ability to move the alert.\nCan be used to preview the current changes done in the settings.',
            func = function()
				SCAR.previewAlert = not SCAR.previewAlert
                SCAR.PreviewAlertControl(SCAR.previewAlert)
            end,
        },
        {
            type = "button",
            name = 'Reset position',
            tooltip = 'Reset the frame back to its default position. The default has the added bonus of enforcing its position regardless of UI SCARle or resolution changes.',
            func = function()
                SCAR.AnchorTLW(true)
            end,
        },


	}   -- END OF OPTIONS TABLE
	for _, alert in ipairs(SCAR.alerts) do
		local db = settings.alerts[alert.key]
		local dbDef = defaults.alerts[alert.key]
		local ref = SCAR.name .. "_OPTIONS_ALERT_HEADER_" .. alert.label
		local header = {
			type = "header",
			name = alert.label,
			reference = ref
		}
		optionsTable[#optionsTable+1] = header

		local updateLabel = function()
			SCAR.UpdateLabel(SCAR.controls.alert, db)
		end

		local checkbox = {
            type = "checkbox",
            name = "Alert:  " .. alert.label,
			tooltip = "",
            getFunc = function() return db.show end,
            setFunc = function(value) db.show = value
            end,
            default = dbDef.show,
            width="full",
        }
		optionsTable[#optionsTable+1] = checkbox

		local editbox = {
            type = "editbox",
            name = "Label",
            tooltip = "",
            isMultiline = false,
            getFunc = function()
                return db.label or alert.label
            end,
            setFunc = function(value)
                db.label = value == "" and alert.label or value
				updateLabel()
            end,
            default = dbDef.label or alert.label
        }
		optionsTable[#optionsTable+1] = editbox

		local slider = {
            type = "slider",
            name = "Size",
            tooltip = "",
            min = 10,
            max = 200,
			step = 1,
            decimals = 0,
            autoSelect = true,
            getFunc = function() return db.size end,
            setFunc = function(size)
                db.size = size
				updateLabel()
            end,
            default = dbDef.size,
            width="full",
        }
		optionsTable[#optionsTable+1] = slider

		local dropdown1 = {
            type = 'dropdown',
            name = 'Font Face',
            tooltip = '',
            choices = fontsList,
            getFunc = function() return db.face end,
            setFunc = function(face)
                db.face = face
				updateLabel()
            end,
			default = dbDef.face
        }
		optionsTable[#optionsTable+1] = dropdown1

		local dropdown2 = {
            type = 'dropdown',
            name = 'Style',
            tooltip = '',
            choices = {"none", "soft-shadow-thin", "soft-shadow-thick", "shadow"},
            getFunc = function() return db.style end,
            setFunc = function(style)
                db.style = style
				updateLabel()
            end,
			default = dbDef.style
		}
		optionsTable[#optionsTable+1] = dropdown2

		local colorpicker = 		{
			type = "colorpicker",
			name = Color,
			tooltip = "",
			getFunc = function() return unpack(db.color) end,
            setFunc = function(r,g,b,a)
            	db.color = {r, g, b, a}
				updateLabel()
			end,
            width="full",
            default = unpack(dbDef.color),
		}
		optionsTable[#optionsTable+1] = colorpicker
	end
	SCAR.LAM:RegisterOptionControls(SCAR.name .. "_LAM", optionsTable)
end

function SCAR.ToggleAlert(tipId, show)
	local alertsData = SCAR.alerts[tipId]
	if alertsData ~= nil then
		local key = alertsData.key
		if SCAR.db.alerts[key].show == true then
			if SCAR.currentTip and SCAR.currentTip < tipId then
				-- Skip this tip; a higher priority tip is showing.
				return
			end

			SCAR.UpdateAlert(key, not show)
			SCAR.currentTip = show and tipId or nil
		end
	end
end

function SCAR.ToggleAlertLock()
	local tlw = SCAR.controls.tlw
	local isMovable = tlw.isMovable
	tlw.isMovable = not isMovable
	tlw:SetMovable(not isMovable)
	tlw:SetHidden(not isMovable)
	SCAR.UpdateAlert("block", not isMovable)
end

function SCAR.PreviewAlertControl(doShow)
	doShow = doShow or false
	local tlw = SCAR.controls.tlw
	tlw.isMovable = doShow
	tlw:SetMovable(doShow)
	tlw:SetHidden(not doShow)
	if doShow == true then
		tlw:BringWindowToTop()
	end
	SCAR.UpdateAlert("block", not doShow)
end

function SCAR.AnchorTLW(reset)
	reset = reset or false
	local a, b, x, y

	if reset == true then
		SCAR.db.tlwPos = nil
		a, b, x, y = CENTER, TOP, 0, GuiRoot:GetHeight() / 4
	elseif SCAR.db.tlwPos then
		a, b, x, y = unpack(SCAR.db.tlwPos)
	else
		a, b, x, y = CENTER, TOP, 0, GuiRoot:GetHeight() / 4
	end

	SCAR.controls.tlw:ClearAnchors()
	SCAR.controls.tlw:SetAnchor(a, GuiRoot, b, x, y)
end

--[[
function SCAR.StopMovingOrResizing(control)
	if not control then end
end
]]

function SCAR.MakeControls()
	local wm = GetWindowManager()
	SCAR.controls = {}

	SCAR.controls.tlw = wm:CreateTopLevelWindow(SCAR.name .. "_TLC")
	local tlw = SCAR.controls.tlw
	tlw:SetClampedToScreen(true)
	tlw:SetDrawLayer(DL_BACKGROUND)
	tlw:SetDrawTier(DT_LOW)
	tlw:SetDrawLevel(1)
	tlw:SetResizeToFitDescendents(true)
	tlw:SetMouseEnabled(true)
	tlw.isMovable = false

	SCAR.controls.tlw:SetHandler("OnMouseUp", function(self)
		local _, a, _, b, x, y = SCAR.controls.tlw:GetAnchor()
		SCAR.db.tlwPos = {a, b, x, y}
	end)

	SCAR.AnchorTLW()

	SCAR.controls.alert = wm:CreateControl(SCAR.name .. "_ALERT", SCAR.controls.tlw, CT_LABEL)
	SCAR.controls.alert:SetAnchor(CENTER, SCAR.controls.tlw)
end

function SCAR.Init(eventId, addonName)
	if addonName ~= SCAR.name then return end
	EVENT_MANAGER:UnregisterForEvent(SCAR.name .. "_ADDON_LOADED", EVENT_ADD_ON_LOADED)

	local defaults = {alerts = {}}

	--Libraries
	SCAR.LMP = LibMediaProvider
	SCAR.LAM = LibAddonMenu2

	--Alerts
	for _, alert in ipairs(SCAR.alerts) do
		defaults.alerts[alert.key] = {
			show = true,
			label = alert.label,
			color = {1, 0, 0, 1},
			size = 64,
			face = "Univers 67",
			style = "soft-shadow-thin"
		}
	end
	SCAR.dbDefaults = defaults

	--ZO_SavedVars:NewCharacterIdSettings(savedVariableTable, version, namespace, defaults, profile)
	SCAR.db = ZO_SavedVars:NewCharacterIdSettings("SimpleCombatAlertsRevived_SV", SCAR.dbVersion, nil, defaults, GetWorldName())

	--Build the LAM2 addon settings menu
	SCAR.BuildAddonMenu()
	SCAR.MakeControls()

	--EVENTS
	EVENT_MANAGER:RegisterForEvent(SCAR.name, EVENT_DISPLAY_ACTIVE_COMBAT_TIP, function(_, tipId)
		ZO_ActiveCombatTips:SetHidden(true)
		SCAR.controls.tlw:BringWindowToTop()
		SCAR.ToggleAlert(tipId, true)
	end)

	EVENT_MANAGER:RegisterForEvent(SCAR.name, EVENT_REMOVE_ACTIVE_COMBAT_TIP, function(_, tipId)
		SCAR.ToggleAlert(tipId, false)
	end)

	EVENT_MANAGER:RegisterForEvent(SCAR.name, EVENT_SCREEN_RESIZED, function()
		SCAR.AnchorTLW()
	end)

	local isActiveCombatTipsEnabled = GetSetting(SETTING_TYPE_ACTIVE_COMBAT_TIP, 0)
	if SCAR.db then
		SCAR.db.activeCombatTipsStateBefore = tostring(isActiveCombatTipsEnabled)
	end
	EVENT_MANAGER:RegisterForEvent(SCAR.name .. "_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, function()
		--Activate combat tips. Set them to "Always show"
		SetSetting(SETTING_TYPE_ACTIVE_COMBAT_TIP, 0, ACT_SETTING_ALWAYS)
		--Is the addon AccountSettings enabled?
		if AccountSettings then
			--AccountSettings will switch the settings to other account settings, but starting after 5seconds.
			--So we wait another +2 after that and change this setting again then
			local delay = 7000
			zo_callLater(function()
				--Activate combat tips. Set them to "Always show"
				SetSetting(SETTING_TYPE_ACTIVE_COMBAT_TIP, 0, ACT_SETTING_ALWAYS)
			end, delay)
		end
	end)

end
EVENT_MANAGER:RegisterForEvent(SCAR.name .. "_ADDON_LOADED", EVENT_ADD_ON_LOADED, SCAR.Init)
