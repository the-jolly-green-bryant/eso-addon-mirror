--[[
  * Joviex's Addon Settings Transfer Tool
  * Author: Joviex (amorano@gmail.com)
  * Special Thanks To:
	* 	Wykkyd for the inspirational framework
	* 	Seerah for the awesome LibAddonMenu wrapper
]]--

-- Get the global panel if it exists
local LAM = LibAddonMenu2
local JOV_AST = ZO_Object:Subclass()
--------------------------------------------------------------------------------
-- MODULE METHODS
--------------------------------------------------------------------------------
function ToggleWindow()
	JOV_AST:ToggleWindow()
end

local function Chain(object)
	--Setup the metatable
	local T={}
	setmetatable(T, {__index=function(self, func)
		--Know when to stop chaining
		if func=="__END" then return object end
		--Otherwise, add the method to the parent object
		return function(self, ...)
			assert(object[func], func .. " missing in object")
			object[func](object, ...)
			return self
		end
	end})
	--Return the metatable
	return T
end
--------------------------------------------------------------------------------
-- GLOBALS REGISTRATION
--------------------------------------------------------------------------------
JOV_AST.defaults = {
	Debug = true,
	AutoReload = true,
	AddonScrollSize = 12,
}

JOV_AST.commands = {
	["toggle"] = ToggleWindow,
}
--------------------------------------------------------------------------------
-- REGISTRATION
--------------------------------------------------------------------------------
function JOV_AST.SlashCommandHelp()
	d("Addon Setting Transfer usage:")
	d("  /jovast toggle (toggle the window on/off)")
end

function JOV_AST.SlashCommand(argtext)
	JOV_AST:ToggleWindow()
end

function JOV_AST:WindowInit()

	if self.frame ~= nil then return end
	self:Refresh()

	local wm = WINDOW_MANAGER
	local win = "JOV_ASTWindow"
	local frame = Chain(wm:CreateTopLevelWindow(win))
		:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
		:SetHidden(true)
		:SetMovable(true)
		:SetMouseEnabled(true)
		:SetClampedToScreen(true)
		:SetResizeToFitDescendents(true)
	.__END

	local fontFile = ZoFontGameBold:GetFontInfo()
	local headerFontSize = 24
	local headerFont = string.format("%s|%d|%s", fontFile, headerFontSize, "soft-shadow-thin")
	local headerText = "|cAD66D5Joviex's|r |cEEDDEEAddon Settings Transfer|r Tool"
	local headerTextRaw = "Joviex's Addon Settings Transfer Tool"
	local headerWidth = headerTextRaw:len() * headerFontSize * 0.45

	self.fmtLabel = {}
	self.fmtLabel.Size = 19
	self.fmtLabel.Font = string.format("%s|%d|%s", fontFile, self.fmtLabel.Size, "soft-shadow-thin")
	local labelWidth = 0
	for i=1, #self.charsSort do
		labelWidth = math.max(labelWidth, tostring(self.charsSort[i]):len())
	end
	labelWidth = labelWidth * self.fmtLabel.Size * 0.6
	if labelWidth > headerWidth * 0.5 then
		headerWidth = labelWidth * 2
	else
		labelWidth = headerWidth * 0.5
	end

	self.fmtButton = {}
	self.fmtButton.Size = 17
	self.fmtButton.Font = string.format("%s|%d|%s", fontFile, self.fmtButton.Size, "soft-shadow-thin")

	----------------------------------------------------------------------------
	-- BACKGROUND
	----------------------------------------------------------------------------
	local ii = 1
	local bg = Chain(wm:CreateControl(win.."_"..ii, frame, CT_BACKDROP))
		:SetAnchorFill(frame)
		:SetCenterColor(.15, .15, .2, .55)
		:SetEdgeColor(.3, .3, .4, 1)
		:SetEdgeTexture(nil, 2, 2, 2, 2)
		:SetDrawLayer(DL_BACKGROUND)
		:SetResizeToFitDescendents(true)
	.__END

	ii = ii + 1
	local aa = Chain(wm:CreateControl(win.."_"..ii, bg, CT_LABEL))
		:SetAnchor(TOPLEFT, bg, TOPLEFT, 0, 0)
		:SetDimensions(headerWidth, headerFontSize+4)
		:SetFont(headerFont)
		:SetColor(1, 1, 1, 1)
		:SetText(headerText)
		:SetHorizontalAlignment(1)
	.__END

	ii = ii + 1
	local cont = Chain(wm:CreateControl(win.."_"..ii, bg, CT_BACKDROP))
		:SetAnchorFill(bg)
		:SetAnchor(TOPLEFT, bg, TOPLEFT, 0, headerFontSize+4)
		:SetResizeToFitDescendents(true)
		:SetCenterColor(.15, .15, .2, .55)
		:SetEdgeColor(.3, .3, .4, 1)
		:SetEdgeTexture(nil, 2, 2, 2, 2)
		:SetDrawLayer(DL_BACKGROUND)
	.__END

	----------------------------------------------------------------------------
	-- TOP LABELS
	----------------------------------------------------------------------------
	ii = ii + 1
	aa = Chain(wm:CreateControl(win.."_"..ii, cont, CT_LABEL))
		:SetAnchor(TOPLEFT, aa, BOTTOMLEFT, 0, 5)
		:SetDimensions(labelWidth, self.fmtLabel.Size)
		:SetFont(self.fmtLabel.Font)
		:SetColor(1, 0.64, 0.1, 1)
		:SetText("TRANSFER FROM")
		:SetHorizontalAlignment(1)
	.__END

	ii = ii + 1
	local bb = Chain(wm:CreateControl(win.."_"..ii, cont, CT_LABEL))
		:SetAnchor(TOPLEFT, aa, TOPRIGHT, 0, 0)
		:SetDimensions(labelWidth, self.fmtLabel.Size)
		:SetFont(self.fmtLabel.Font)
		:SetColor(1, 0.64, 0.1, 1)
		:SetText("TRANSFER TO")
		:SetHorizontalAlignment(1)
	.__END

	----------------------------------------------------------------------------
	-- CHARACTERS
	----------------------------------------------------------------------------
	self.masterCtrls = {}
	self.targetCtrls = {}
	self.nameID = {}
	local player = GetUnitName("player")

	for i = 1, GetNumCharacters() do
		local cname, _, _, _, _, _, cid = GetCharacterInfo(i)
		self.nameID[cname:sub(1, cname:len()-3)] = cid
	end

	for ch=1, #self.charsSort do
		name = self.charsSort[ch]
		if name ~= "_" and tonumber(name) == nil then
			local alpha = 0.6
			if player == name then alpha = 1 end

			ii = ii + 1
			aa = Chain(wm:CreateControl(win.."_"..ii, cont, CT_BUTTON))
				:SetAnchor(TOPLEFT, aa, BOTTOMLEFT, 0, 0)
				:SetDimensions(labelWidth, self.fmtButton.Size)
				:SetFont(self.fmtButton.Font)
				:SetText(name)
				:EnableMouseButton(1, true)
				:SetAlpha(alpha)
				:SetMouseOverFontColor(0.95, 0.8, 0.1, 1)
				:SetPressedFontColor(0.95, 0.8, 0.1, 1)
				:SetHandler("OnClicked", function(self) JOV_AST:MasterClick(self) end)
			.__END
			if player == name then
				aa:SetNormalFontColor(0.3, 0.9, 0.2, 1)
			else
				aa:SetNormalFontColor(0.9, 0.9, 0.9, 1)
			end
			aa.jName = name
			self.masterCtrls[#self.masterCtrls+1] = aa

			ii = ii + 1
			bb = Chain(wm:CreateControl(win.."_"..ii, cont, CT_BUTTON))
				:SetAnchor(TOPLEFT, aa, TOPRIGHT, 0, 0)
				:SetDimensions(labelWidth, self.fmtButton.Size)
				:SetFont(self.fmtButton.Font)
				:SetText(name)
				:EnableMouseButton(1, true)
				:EnableMouseButton(2, true)
				:SetAlpha(1)
				:SetNormalFontColor(0.3, 0.9, 0.2, 1)
				:SetMouseOverFontColor(0.95, 0.8, 0.1, 1)
				:SetPressedFontColor(0.95, 0.8, 0.1, 1)
				:SetHandler("OnClicked", function(self, index) JOV_AST:TargetClick(self, index) end)
			.__END
			bb.jName = name
			self.targetCtrls[#self.targetCtrls+1] = bb
		end
	end

	----------------------------------------------------------------------------
	-- ADDONS
	----------------------------------------------------------------------------
	ii = ii + 1
	aa = Chain(wm:CreateControl(win.."_"..ii, cont, CT_LABEL))
		:SetAnchor(TOPLEFT, aa, BOTTOMLEFT, 0, self.fmtLabel.Size / 2)
		:SetDimensions(headerWidth, self.fmtLabel.Size * 1.25)
		:SetFont(self.fmtLabel.Font)
		:SetColor(1, 0.64, 0.1, 1)
		:SetText("TRANSFER SELECTED ADD-ON SETTINGS")
		:SetHorizontalAlignment(1)
	.__END

	----------------------------------------------------------------------------
	-- SCROLL FRAME
	----------------------------------------------------------------------------
	self.addonCtrls = {}

	self.AddonScrollArea = Chain(wm:CreateControl(win.."_AddonScoll", cont, CT_CONTROL))
		:SetAnchor(TOPLEFT, aa, BOTTOMLEFT, 0, 0)
		:SetResizeToFitDescendents(true)
		:SetMouseEnabled(true)
		:SetHandler("OnMouseWheel",function(self, delta)
			local value = self.offset - delta
			if value < 0 then
				value = 0
			elseif value > #JOV_AST.addonsSort - self.max then
				value = #JOV_AST.addonsSort - self.max
			end
			self.offset = value
			JOV_AST.AddonScrollBar:SetValue(value)
			JOV_AST:AddonScrollUpdate()
		end)
		.__END
	self.AddonScrollArea.offset = 0
	self.AddonScrollArea.max = self.config.AddonScrollSize

	-- This is what turns a simple slider into a scrollbar
	local tex = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
	local back = "/esoui/art/chatwindow/chat_scrollbar_track.dds"
	self.AddonScrollBar = Chain(wm:CreateControl(win.."_AddonScollBar", self.AddonScrollArea, CT_SLIDER))
		:SetAnchor(TOPLEFT, aa, TOPRIGHT, -15, 0)
		:SetDimensions(13, self.fmtLabel.Size * self.AddonScrollArea.max)
		:SetMouseEnabled(true)
		:SetThumbTexture(tex, tex, tex, 18, 50, 0, 0, 1, 1)
		:SetBackgroundMiddleTexture(back, 0, 0, 1, 1)
		:SetValue(0)
		:SetValueStep(1)
		:SetHandler("OnValueChanged", function(self, value, eventReason)
			JOV_AST.AddonScrollArea.offset = math.min(value, #JOV_AST.addonCtrls - JOV_AST.AddonScrollArea.max)
			JOV_AST:AddonScrollUpdate()
		end)
	.__END

	local aIndex = 0
	for k=1, #self.addonsSort do
		aIndex = aIndex + 1
		name = self.addonsSort[k]
		local visible = k > self.AddonScrollArea.max
		aa = Chain(wm:CreateControl("AddonScoll"..aIndex, self.AddonScrollArea, CT_BUTTON))
			:SetAnchor(TOPLEFT, self.AddonScrollArea, TOPLEFT, 0, (k-1)*self.fmtButton.Size+2)
			:SetDimensions(headerWidth-15, self.fmtButton.Size)
			:SetFont(self.fmtButton.Font)
			:SetText(name)
			:EnableMouseButton(1, true)
			:EnableMouseButton(2, true)
			:SetAlpha(1)
			:SetNormalFontColor(0.3, 0.9, 0.2, 1)
			:SetMouseOverFontColor(0.95, 0.8, 0.1, 1)
			:SetPressedFontColor(0.95, 0.8, 0.1, 1)
			:SetHandler("OnClicked", function(self, index) JOV_AST:AddonClick(self, index) end)
			:SetHidden(visible)
		.__END
		aa.jName = name
		self.addonCtrls[#self.addonCtrls+1] = aa
	end

	----------------------------------------------------------------------------
	-- TRANSFER BUTTON
	----------------------------------------------------------------------------
	-- SPACER
	ii = ii + 1
	aa = Chain(wm:CreateControl(win.."_"..ii, cont, CT_LABEL))
		:SetAnchor(TOPLEFT, self.AddonScrollArea, BOTTOMLEFT, 0, 0)
		:SetDimensions(headerWidth, 10)
		:SetFont(self.fmtLabel.Font)
		:SetText(" ")
	.__END

	-- TRANSFER BUTTON
	ii = ii + 1
	aa = Chain(wm:CreateControl(win.."_"..ii, cont, CT_BUTTON))
		:SetAnchor(TOPLEFT, aa, BOTTOMLEFT, 0, 0)
		:SetDimensions(headerWidth, self.fmtLabel.Size)
		:SetFont(self.fmtLabel.Font)
		:SetText("TRANSFER SETTINGS")
		:EnableMouseButton(1, true)
		:SetAlpha(1)
		:SetNormalFontColor(1, 1, 1, 1)
		:SetMouseOverFontColor(0.95, 0.25, 0.35, 1)
		:SetPressedFontColor(0.95, 0.25, 0.35, 1)
		:SetHandler("OnClicked", function(self) JOV_AST:Transfer(self) end)
	.__END

	-- SPACER
	ii = ii + 1
	aa = Chain(wm:CreateControl(win.."_"..ii, cont, CT_LABEL))
		:SetAnchor(TOPLEFT, aa, BOTTOMLEFT, 0, 0)
		:SetDimensions(headerWidth, 10)
		:SetFont(self.fmtLabel.Font)
		:SetText(" ")
	.__END

	self.frame = frame

	----------------------------------------------------------------------------
	-- DIALOG BOX
	----------------------------------------------------------------------------

	ii = 1
	win = "JOV_ASTPrompt"
	prompt = Chain(wm:CreateTopLevelWindow(win))
		:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
		:SetHidden(true)
		:SetMovable(false)
		:SetMouseEnabled(true)
		:SetClampedToScreen(true)
		:SetDimensions(500, 500)
		:SetResizeToFitDescendents(false)
	.__END

	headerFont = string.format("%s|%d|%s", fontFile, 24, "soft-shadow-thin")

	ii = ii + 1
	aa = Chain(wm:CreateControl(win.."_"..ii, prompt, CT_BACKDROP))
		:SetAnchorFill(prompt)
		:SetCenterColor(.3, .2, .4, .95)
		:SetEdgeColor(.6, .6, .8, 1)
		:SetEdgeTexture(nil, 1, 1, 1, 1)
		:SetDrawLayer(DL_BACKGROUND)
	.__END

	ii = ii + 1
	aa = Chain(wm:CreateControl(win.."_"..ii, prompt, CT_LABEL))
		:SetAnchor(TOPLEFT, aa, TOPLEFT, 0, 90)
		:SetDimensions(500, headerFontSize+90)
		:SetVerticalAlignment(2)
		:SetFont(headerFont)
		:SetColor(1, 1, 1, 1)
		:SetText("This |cEE4332removes ALL|r settings for")
		:SetHorizontalAlignment(1)
	.__END

	headerFont2 = string.format("%s|%d|%s", fontFile, headerFontSize+25, "soft-shadow-thin")
	aa = Chain(wm:CreateControl(win.."_MSG", prompt, CT_LABEL))
		:SetAnchor(TOPLEFT, aa, BOTTOMLEFT, 0, 0)
		:SetDimensions(500, headerFontSize+90)
		:SetVerticalAlignment(2)
		:SetFont(headerFont2)
		:SetColor(1, 1, 1, 1)
		:SetText("")
		:SetHorizontalAlignment(1)
	.__END

	ii = ii + 1
	aa = Chain(wm:CreateControl(win.."_"..ii, prompt, CT_LABEL))
		:SetAnchor(TOPLEFT, aa, BOTTOMLEFT, 0, 0)
		:SetDimensions(500, headerFontSize+90)
		:SetVerticalAlignment(2)
		:SetFont(headerFont)
		:SetColor(1, 1, 1, 1)
		:SetText("using all the |c43EE32selected|r addons")
		:SetHorizontalAlignment(1)
	.__END
	----------------------------------------------------------------------------

	ii = ii + 1
	aa = Chain(wm:CreateControl(win.."_"..ii, prompt, CT_BUTTON))
		:SetAnchor(TOPLEFT, aa, BOTTOMLEFT, 0, 0)
		:SetDimensions(250, self.fmtLabel.Size)
		:SetFont(self.fmtLabel.Font)
		:SetText("CANCEL")
		:EnableMouseButton(1, true)
		:SetAlpha(1)
		:SetNormalFontColor(0.9, 0.3, 0, 1)
		:SetMouseOverFontColor(0.9, 0.8, 0.1, 1)
		:SetPressedFontColor(0.9, 0.8, 0.1, 1)
		:SetHandler("OnClicked", function(self, index) JOV_AST.prompt:SetHidden(true) end)
	.__END

	ii = ii + 1
	aa = Chain(wm:CreateControl(win.."_CONFIRM", prompt, CT_BUTTON))
		:SetAnchor(TOPLEFT, aa, TOPRIGHT, 0, 0)
		:SetDimensions(250, self.fmtLabel.Size)
		:SetFont(self.fmtLabel.Font)
		:SetText("CONFIRM")
		:EnableMouseButton(1, true)
		:SetAlpha(1)
		:SetNormalFontColor(0.3, 0.9, 0, 1)
		:SetMouseOverFontColor(0.9, 0.8, 0.1, 1)
		:SetPressedFontColor(0.9, 0.8, 0.1, 1)
	.__END

	ii = ii + 1
	self.FrameBottom = Chain(wm:CreateControl(win.."_"..ii, prompt, CT_LABEL))
		:SetAnchor(TOPLEFT, aa, TOPLEFT, 0, 0)
		:SetDimensions(500, self.fmtLabel.Size)
		:SetFont(self.fmtLabel.Font)
		:SetColor(1, 1, 1, 1)
		:SetText(" ")
		:SetHorizontalAlignment(1)
	.__END
	self.prompt = prompt
end

function JOV_AST:SettingsPanelInit() -- Updated to LibAddonMenu-2.0 - Phinix
	local desc = ""
	-------------------------------------- WIDTH LIMIT IN SETTINGS PANEL --------------------------------------
	desc = desc.."There is a toggle command that can be |CEE3300bound to a key|r\n"
	desc = desc.."Check under |CEE3300Control->Settings|r tab to set a keybind for toggling\n"
	desc = desc.."Use the commandline |CEE3300/jovast|r to toggle the window on/off\n"
	desc = desc.."Right-click characters in the Transfer To section to remove from list."
	local panel = {
		type					= "panel",
		name					= "Joviex's Settings",
		displayName				= "|cAD66D5Joviex's|r Settings",
		author					= "Joviex",
		version					= "14.07.03.1h",
		registerForRefresh		= true,
		registerForDefaults		= true
	}

	local optionsData = {
	{
		type			= "header",
		name			= "Add-On Settings Transfer",
		reference		= "Add-On Settings Transfer"
	},
	{
		type			= "description",
		title			= "Usage Help",
		text			= desc,
		reference		= "Help"
	},
	{
		type			= "checkbox",
		name			= "Auto-Reload",
		tooltip			= "Automatically reload when settings are transferred",
		getFunc			= function() return self.config.AutoReload end,
		setFunc			= function(val) self.config.AutoReload = val end,
		default			= JOV_AST.defaults.AutoReload,
		reference		= "AutoReload"
	},
	{
		type			= "checkbox",
		name			= "Show All Output",
		tooltip			= "Show all output/debug messages",
		getFunc			= function() return self.config.Debug end,
		setFunc			= function(val) self.config.Debug = val end,
		default			= JOV_AST.defaults.Debug,
		reference		= "Debug"
	},
	{
		type			= "slider",
		name			= "Addon List Size",
		tooltip			= "Adjust the number of addons in the addon area list",
		min				= 5,
		max				= 20,
		step			= 1,
		getFunc			= function() return self.config.AddonScrollSize end,
		setFunc			= function(val)
							self.config.AddonScrollSize = val
							-- refresh the scroll list?
							if self.AddonScrollArea then
								self.AddonScrollArea.max = val
								self.AddonScrollArea.offset = 0
								self.AddonScrollBar:SetDimensions(13, self.fmtLabel.Size * val)
								self.AddonScrollBar:SetValue(0)
								self:AddonScrollUpdate()
								self.frame:SetHeight(0)
								self.frame:SetResizeToFitDescendents(false)
								self.frame:SetResizeToFitDescendents(true)
								-- move the window size
								--local b = self.FrameBottom:GetBottom()
							end
						end,
		default			= JOV_AST.defaults.ScrollSize,
		reference		= "ScrollSize"
	}
	}

	LAM:RegisterAddonPanel("_jovAST", panel)
	LAM:RegisterOptionControls("_jovAST", optionsData)
end

function JOV_AST:Init(eventCode, addOnName)
	if(addOnName ~= "jovAST") then return end

	-- No need for any more checking about my addon being loaded!
	EVENT_MANAGER:UnregisterForEvent("jovAST", EVENT_ADD_ON_LOADED)

	self.config = ZO_SavedVars:NewAccountWide("jovAST", 1, nil, self.defaults)

	-- keybind strings
	ZO_CreateStringId("SI_BINDING_NAME_JOV_TOGGLE_AST_WINDOW", "Toggle Settings Transfer Window")

	-- ingame saved variable table def. addr/zgoo
	--ZIIGSV = tostring(_G["ZO_Ingame_SavedVariables"]):match(": ([%u%d]+)")
	--zo_callLater(function() d(ZIIGSV) end, 300)

	self.frame = nil
	self.chars = {}
	self.charsSort = {}
	self.addons = {}
	self.addonsSort = {}

	self:SettingsPanelInit()
	
	if self.config.Debug == true then -- Only show login message if debug mode is on. -Phinix
		zo_callLater(function() d(" |cFFD300Loaded|r |cAD66D5Joviex's|r |cEEDDEEAddon Settings Manager|r. |cEE4332/jovast|r |cEEDDEEto toggle|r") end, 300)
	end

end


--------------------------------------------------------------------------------
-- CLASS METHODS
--------------------------------------------------------------------------------
function JOV_AST:IsHidden()
	local ret = true
	if self.frame then
		ret = self.frame:IsHidden()
	end
	return ret
end

function JOV_AST:ToggleWindow()
	local i = self:IsHidden()
	if i == true then
		self:WindowInit()
	end
	SetGameCameraUIMode(self.frame:IsHidden())
	self.frame:SetHidden(not i)

	if self.frame:IsHidden() then
		self.prompt:SetHidden(true)
	else
		self.AddonScrollBar:SetValue(0)
		self:AddonScrollUpdate()
	end
end

function JOV_AST:MasterClick(but)
	for i=1, #self.masterCtrls do
		m = self.masterCtrls[i]
		if m:GetHeight() > 0 then
			if but == m then
				m:SetNormalFontColor(0.3, 0.9, 0.2, 1)
				m:SetAlpha(1)
				self.masterCtrlsSelected = m
			else
				m:SetNormalFontColor(0.9, 0.9, 0.9, 1)
				m:SetAlpha(0.6)
			end
		end
	end
end

function JOV_AST:TargetClick(but, index)
	if (index == 2) then
		ClearMenu()
		AddMenuItem("Remove Settings",
			function() JOV_AST:Wipe(but) end
		)
		ShowMenu(but)
		return
	end

	s = but:GetAlpha()
	if s == 1 then
		but:SetNormalFontColor(0.9, 0.9, 0.9, 1)
		but:SetAlpha(0.6)
	else
		but:SetNormalFontColor(0.3, 0.9, 0.2, 1)
		but:SetAlpha(1)
	end
end

function JOV_AST:AddonClick(but, index)
	if (index == 2) then
		ClearMenu()
		AddMenuItem("Toggle Only Me",
			function()
				-- turn everything off....
				for i=1, #self.addonCtrls do
					m = self.addonCtrls[i]
					m:SetNormalFontColor(0.9, 0.9, 0.9, 1)
					m:SetAlpha(0.6)
				end
				JOV_AST:AddonClick(but, 1)
			end
		)
		ShowMenu(but)
		return
	end

	for i=1, #self.addonCtrls do
		m = self.addonCtrls[i]
		if but == m then
			s = m:GetAlpha()
			if s == 1 then
				m:SetNormalFontColor(0.9, 0.9, 0.9, 1)
				m:SetAlpha(0.6)
			else
				m:SetNormalFontColor(0.3, 0.9, 0.2, 1)
				m:SetAlpha(1)
			end
			break
		end
	end
end


function JOV_AST:AddonScrollUpdate(...)
	local sb = self.AddonScrollArea
	sb.offset = sb.offset or 0

	if #self.addonsSort == 0 then return end
	if sb.offset < 0 then sb.offset = 0 end

	self.AddonScrollBar:SetMinMax(0, #self.addonsSort - sb.max)

	for k, ctrl in pairs(self.addonCtrls) do
		ctrl:ClearAnchors()
		ctrl:SetHidden(true)
	end
	local hgh = sb.offset + sb.max
	if hgh > #self.addonCtrls then hgh = #self.addonCtrls end

	local low = sb.offset + 1

	local k = 0
	for i = low, hgh do
		local ctrl = self.addonCtrls[i]
		ctrl:SetAnchor(TOPLEFT, self.AddonScrollArea, TOPLEFT, 0, k * self.fmtButton.Size)
		ctrl:SetHidden(false)
		k = k + 1
	end
end
function JOV_AST:WipeValid(who, but)
	local account = self.chars["_"]

	for a, b in pairs(self.addonCtrls) do
		if b:GetAlpha() == 1 then
			for default, entry in pairs(_G[b.jName]) do
				if entry ~= nil and entry[account] ~= nil then
					entry[account][who] = nil
					if self.config.Debug then
						d("|c33FF66"..who.."|r settings |c99BBFF["..b.jName.."]|r |cEE4332REMOVED|r")
					end
				end
			end
		end
	end

	-- find same player on master control side
	for k, v in pairs(self.masterCtrls) do
		if who == v.jName then
			-- do we need to change the current selected char?
			if v:GetAlpha(1) then
				local n = -1
				for k2, v2 in pairs(self.masterCtrls) do
					if k2 ~= k then
						if v2:GetAlpha() ~= 0 then
							n = k2
							break
						end
					end
				end
				if n ~= -1 then
					JOV_AST:MasterClick(self.masterCtrls[n])
				end
			end
			v:SetAlpha(0)
			v:SetHeight(0)
			break
		end
	end

	-- hide the current labels? Is there a way to remove UI elements?
	but:SetAlpha(0)
	but:SetHeight(0)

	d("|cFFEEDDSettings Transfer|r |c33FF66Complete")
	if self.config.AutoReload then ReloadUI() end
end

function JOV_AST:Wipe(but)

	local who = but:GetLabelControl():GetText()
	local player = GetUnitName("player")
	if who == player then
		d("Removing settings from the logged in character is |cEE4332denied|r")
		return
	end

	----------------------------------------------------------------------------
	-- DIALOG CONFIRM
	----------------------------------------------------------------------------

	self.prompt:SetHidden(false)

	-- update the prompt!
	local msg = "|cEE4332"..who.."|r"
	local ctrl = self.prompt:GetNamedChild("_MSG")
	ctrl:SetText(msg)

	ctrl = self.prompt:GetNamedChild("_CONFIRM")
	ctrl:SetHandler("OnClicked", function(self, index) JOV_AST:WipeValid(who, but); JOV_AST.prompt:SetHidden(true) end)

	self.prompt:BringWindowToTop()
end

function JOV_AST:Transfer()
	local master = nil
	for k, v in pairs(self.masterCtrls) do
		if v:GetAlpha() == 1 then
			master = v.jName
			if self.chars[v.jName] == nil then
				-- sanity check for characters with zero addon settings
				d("failure to find character to transfer from")
				return
			end
			break
		end
	end

	local account = self.chars["_"]

	for a, b in pairs(self.addonCtrls) do
		if b:GetAlpha() == 1 then
			for default, entry in pairs(_G[b.jName]) do
				if entry ~= nil and type(entry) == "table" then
					if entry[account] ~= nil then
						if entry[account][master] ~= nil then
							for k, v in pairs(self.targetCtrls) do
								if v:GetAlpha() == 1 then
									entry[account][v.jName] = entry[account][master]
									if self.config.Debug then
										d("|c33FF66"..master.."|r settings |c99BBFF["..b.jName.."]|r ==> |c33FF66"..v.jName.."|r")
									end
								end
							end
						elseif entry[account][self.nameID[master]] ~= nil then
							for k, v in pairs(self.targetCtrls) do
								if v:GetAlpha() == 1 then
									entry[account][self.nameID[v.jName]] = entry[account][self.nameID[master]]
									if self.config.Debug then
										d("|c33FF66"..master.."|r settings |c99BBFF["..b.jName.."]|r ==> |c33FF66"..v.jName.."|r")
									end
								end
							end
						else
							if self.config.Debug then
								d("|cFF5522"..master.."|r has no |c99BBFF["..b.jName.."]|r settings to transfer")
							end
						end
					else
						-- will copy all "version" entries
						found = false
						for version, data in pairs(entry) do
							if type(data) == "table" then
								for char, _ in pairs(data) do
									if master == char then
										found = true
										for k, v in pairs(self.targetCtrls) do
											if v:GetAlpha() == 1 then
												entry[version][v.jName] = entry[version][master]
												if self.config.Debug then
													d("|c33FF66"..master.."|r settings |c99BBFF["..b.jName.."]|r ==> |c33FF66"..v.jName.."|r")
												end
											end
										end
										break
									end
								end
							end
						end

						if found == false then
							for char, _ in pairs(entry) do
								if master == char then
									found = true
									for k, v in pairs(self.targetCtrls) do
										if v:GetAlpha() == 1 then
											entry[v.jName] = entry[master]
											if self.config.Debug then
												d("|c33FF66"..master.."|r settings |c99BBFF["..b.jName.."]|r ==> |c33FF66"..v.jName.."|r")
											end
										end
									end
									break
								end
							end
						end

						if not found and self.config.Debug then
							d("|cFF5522"..master.."|r has no |c99BBFF["..b.jName.."]|r default settings")
						end
					end
				end
			end
		end
	end

	d("|cFFEEDDSettings Transfer|r |c33FF66Complete")
	if self.config.AutoReload then ReloadUI() end
end

function JOV_AST:Refresh()
	-- gather the characters and addons per character
	self.addons = {}
	self.chars = {}

	-- Normal way
	for k, v in zo_insecurePairs(_G) do
		if type(v) == "table" and k ~= "_G" then
			for kk, vv in pairs(v) do
				if type(vv) == "table" then
					for k3, v3 in pairs(vv) do
						if type(v3) == "table" and type(k3) == "string" and k3:sub(1,1) == "@" then
							self.chars["_"] = k3
							for char, data in pairs(v3) do
								if char ~= "$AccountWide" then
									-- stash the addon data per character
									if self.chars[char] == nil then self.chars[char] = {} end
									self.chars[char][k] = k

									-- running list of characters with saved data per addon
									if self.addons[k] == nil then self.addons[k] = {} end
									self.addons[k][char] = true
								end
							end
							break
						end
					end
				end
			end
		end
	end

	-- Wykkyd's way; requires gathering characters first
	for k, v in zo_insecurePairs(_G) do
		if type(v) == "table" and k ~= "_G" then
			for kk, vv in pairs(v) do
				if type(vv) == "table" then
					for k3, v3 in pairs(vv) do
						if type(v3) == "table" and type(k3) == "string" then
							for char, _ in pairs(self.chars) do
								if k3 == char then
									-- stash the addon data per character
									self.chars[char][k] = k

									-- running list of characters with saved data per addon
									if self.addons[k] == nil then self.addons[k] = {} end
									self.addons[k][char] = true
									break
								end
							end
						end
					end
				end
			end
		end
	end

	-- Anyone else using a single level of "character name" for global entries
	for k, v in zo_insecurePairs(_G) do
		if type(v) == "table" and k ~= "_G" then
			for kk, vv in pairs(v) do
				if type(vv) == "table" and type(kk) == "string" then
					for char, _ in pairs(self.chars) do
						if kk == char then
							-- stash the addon data per character
							self.chars[char][k] = k

							-- running list of characters with saved data per addon
							if self.addons[k] == nil then self.addons[k] = {} end
							self.addons[k][char] = true
							break
						end
					end
				end
			end
		end
	end

	-- sort by name for easier presentation later
	self.charsSort = {}
	for k, v in pairs(self.chars) do
		self.charsSort[#self.charsSort+1] = k
	end
	table.sort(self.charsSort)

	self.addonsSort = {}
	for k, v in pairs(self.addons) do
		self.addonsSort[#self.addonsSort+1] = k
	end
	table.sort(self.addonsSort)
end

--------------------------------------------------------------------------------
-- INITIALIZATION
--------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent("jovAST", EVENT_ADD_ON_LOADED, function(...) JOV_AST:Init(...) end)

if WF_SlashCommand ~= nil then
	-- Register with Wykkyd's framework for macros
	WF_SlashCommand("jovast", JOV_AST.SlashCommand)
else
	-- Default with no framework
	SLASH_COMMANDS["/jovast"] = JOV_AST.SlashCommand
end