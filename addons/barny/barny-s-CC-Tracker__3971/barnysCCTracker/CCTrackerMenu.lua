local LAM = LibAddonMenu2
local WM = WINDOW_MANAGER
CCTracker = CCTracker or {}
CCTracker.menu = CCTracker.menu or {}
CCTracker.menu.icons = {}

CCTracker.menu.constants = {
	["CC"] = {},
	["SoundList"] = {
		"Ability_Companion_Ultimate_Ready_Sound",
		"Achievement_Awarded",
		"Antiquities_Digging_Antiquity_Completed",
		"BG_Countdown_Finish",
		"Champion_PointsCommitted",
		"CodeRedemption_Success",
		"CraftedAbilityScript_Unlocked",
		"CraftedAbility_Unlocked",
		"DailyLoginRewards_ClaimFanfare",
		"Duel_Accepted",
		"Endeavor_Complete",
		"EnlightenedState_Gained",
		"General_Alert_Error",
		"GroupElection_Requested",
		"PromotionalEvent_ClaimCapstoneReward",
		"PromotionalEvent_ClaimReward",
		"Quest_Abandon",
		"Quest_StepFailed",
		"Telvar_Gained",
		"Telvar_Lost",
		"Tribute_AgentDamaged",
		"UI_U40_EA_AvatarVision_Acquired",
	},
	["timerAnchors"] = {
		"ICON",
		"TIMER BAR",
	},
	["timerBarOrientation"] = {
		"LEFT",
		"RIGHT",
	},
}

local function PopulateConstants()
	for Id, entry in pairs(CCTracker.CC_VARIABLES) do
		local constants = {
			Name = entry.name,
			Icon = entry.icon,
			Id = Id,
		}
		
		table.insert(CCTracker.menu.constants.CC, constants)
		table.sort(CCTracker.menu.constants.CC, function(a, b)
				return a.Name < b.Name 
			end
		)
	end
end

local function FindEntryPosition(name, searchTable)
	for i, entry in ipairs(searchTable) do
		if entry.name == name then
			return i
		end
	end
	return 0
end

local function Sizes()
	local submenu = FindEntryPosition("UI", CCTracker.menu.options)
	local position = FindEntryPosition("Individual sizes", CCTracker.menu.options[submenu].controls)
	for i = 1, #CCTracker.menu.constants.CC do
		local control = {
			type = "slider",
			name = "|t20:20:"..CCTracker.menu.constants.CC[i].Icon.."|t "..CCTracker.menu.constants.CC[i].Name.." icon size",
			disabled = function() return not CCTracker.SV.settings.tracked[CCTracker.menu.constants.CC[i].Name] end,
			width = "half",
			default = 50,
			min = 20,
			max = 200,
			step = 1,
			getFunc = function() return CCTracker.SV.UI.sizes[CCTracker.menu.constants.CC[i].Name] end,
			setFunc = function(value)
				CCTracker.SV.UI.sizes[CCTracker.menu.constants.CC[i].Name] = value
				CCTracker.UI.ApplySize(CCTracker.menu.constants.CC[i].Name)
			end,
		}
		table.insert(CCTracker.menu.options[submenu].controls[position].controls, control)
	end
end

local function Alpha()
	local submenu = FindEntryPosition("UI", CCTracker.menu.options)
	local position = FindEntryPosition("Individual alpha values", CCTracker.menu.options[submenu].controls)
	for i = 1, #CCTracker.menu.constants.CC do
		local control = {
			type = "slider",
			name = "|t20:20:"..CCTracker.menu.constants.CC[i].Icon.."|t "..CCTracker.menu.constants.CC[i].Name.."icon alpha",
			tooltip = "CC icon is too prominent for your liking? Simply adjust alpha with this slider to make it disappear.",
			disabled = function() return not CCTracker.SV.settings.tracked[CCTracker.menu.constants.CC[i].Name] end,
			width = "half",
			default = 100,
			min = 0,
			max = 100,
			step = 1,
			getFunc = function() return CCTracker.SV.UI.alpha.alpha end,
			setFunc = function(value)
				CCTracker.SV.UI.alpha[CCTracker.menu.constants.CC[i].Name] = value
				CCTracker.UI.indicator[CCTracker.menu.constants.CC[i].Name].controls.icon:SetAlpha(value/100)
				CCTracker.UI.indicator[CCTracker.menu.constants.CC[i].Name].controls.frame:SetAlpha(value/100)
			end,
		}
		table.insert(CCTracker.menu.options[submenu].controls[position].controls, control)
	end
end

local function Timers()
	local submenu = FindEntryPosition("Timers", CCTracker.menu.options)
	local position = FindEntryPosition("Individual setups", CCTracker.menu.options[submenu].controls)
	for i = 1, #CCTracker.menu.constants.CC do
		local name = CCTracker.menu.constants.CC[i].Name
		local sv = CCTracker.SV.UI.timers[name]
		local control = {
			type = "submenu",
			name = "|t20:20:"..CCTracker.menu.constants.CC[i].Icon.."|t "..name,
			disabled = function() return not CCTracker.SV.settings.tracked[name] end,
			controls = {
				{
					type = "checkbox",
					name = "Show timer bar",
					tooltip = "Show status bar for time remaining",
					width = "half",
					getFunc = function() return sv.showTimerBar end,
					setFunc = function(value) sv.showTimerBar = value end,
				},
				{	
					type = "dropdown",
					name = "Timer bar orientation",
					choices = CCTracker.menu.constants.timerBarOrientation,
					disabled = function() return not sv.showTimerBar end,
					getFunc = function() return sv.timerBarOrientation end,
					setFunc = function(value)
						sv.timerBarOrientation = value
						CCTracker.UI.ApplyTimerAnchors(name)
					end,
					width = "half",
				},
				{
					type = "colorpicker",
					name = "Bar color",
					disabled = function() return not sv.showTimerBar end,
					getFunc = function() return unpack(sv.timerBarColor) end,
					setFunc = function(r, g, b, a)
						sv.timerBarColor = {r, g, b, a}
						CCTracker.UI.indicator[name].controls.timerBar:SetColor(r, g, b, a)
					end,
				},
				{
					type = "checkbox",
					name = "Show time remaining",
					width = "half",
					getFunc = function() return sv.showTimer end,
					setFunc = function(value) sv.showTimer = value end,
				},
				{	
					type = "dropdown",
					name = "Show timer on:",
					tooltip = "You can chose to show the timer on either the icon or the timer bar",
					disabled = function() return not (sv.showTimer and sv.showTimerBar) end,
					choices = CCTracker.menu.constants.timerAnchors,	
					getFunc = function() return sv.timerAnchor end,
					setFunc = function(value)
						sv.timerAnchor = value
						CCTracker.UI.ApplyTimerAnchors(name)
					end,
					width = "half",
				},
				{
					type = "colorpicker",
					name = "Timer color",
					disabled = function() return not sv.showTimer end,
					getFunc = function() return unpack(sv.timerColor) end,
					setFunc = function(r, g, b, a)
						sv.timerColor = {r, g, b, a}
						CCTracker.UI.indicator[name].controls.timer:SetColor(r, g, b, a)
					end,
				},
			},
		}
		table.insert(CCTracker.menu.options[submenu].controls[position].controls, control)
	end
end

local function CreateCCCheckboxes()
	local position = FindEntryPosition("CC to track", CCTracker.menu.options)
	for i = 1, #CCTracker.menu.constants.CC do
		local control = {}
		control.type = "checkbox"
		control.name = CCTracker.menu.constants.CC[i].Name
		control.width = "half"
		control.default = false
		control.getFunc = function() return CCTracker.SV.settings.tracked[CCTracker.menu.constants.CC[i].Name] end
		control.setFunc = function(value)
			CCTracker.SV.settings.tracked[CCTracker.menu.constants.CC[i].Name] = value
			CCTracker.ccVariables[CCTracker.menu.constants.CC[i].Id].tracked = value
			if value then
				CCTracker.menu.icons.CC[i]:SetDesaturation(0)
			else
				CCTracker.menu.icons.CC[i]:SetDesaturation(1)
			end
			if value and not CCTracker.registered then
				CCTracker:Register()
			elseif not value and CCTracker.registered and not CCTracker:CheckForCCRegister() then
				CCTracker:Unregister()
			end
			if CCTracker.SV.settings.unlocked then CCTracker.UI.SetUnlocked(true) end
		end
		table.insert(CCTracker.menu.options[position].controls, control)
	end
end

local function CreateSoundControls()
	CCTracker.menu.constants.sound = CCTracker.menu.constants.CC 							-- Copy constants.CC table
	local position = FindEntryPosition("Sound", CCTracker.menu.options)
	for i = 1, #CCTracker.menu.constants.sound do
		-- Enabled checkbox
		local control1 = {}
		control1.type = "checkbox"
		control1.name = "Play "..CCTracker.menu.constants.sound[i].Name.." sound"
		control1.width = "half"
		control1.disabled = function() return (not CCTracker.ccVariables[CCTracker.menu.constants.sound[i].Id].tracked) or (CCTracker.ccVariables[CCTracker.menu.constants.sound[i].Id].isHardCC and CCTracker.SV.sound.MuteOnHardCC) end
		control1.default = false
		control1.getFunc = function() return CCTracker.SV.sound[CCTracker.menu.constants.sound[i].Name].enabled end
		control1.setFunc = function(value)
			CCTracker.SV.sound[CCTracker.menu.constants.sound[i].Name].enabled = value
			if value then
				CCTracker.menu.icons.sound[i]:SetDesaturation(0)
			else
				CCTracker.menu.icons.sound[i]:SetDesaturation(1)
			end
		end
		CCTracker.menu.constants.sound[i].CheckboxName = control1.name
		table.insert(CCTracker.menu.options[position].controls, control1)
		
		-- Select sound dropdown
		local control2 = {}
		control2.type = "dropdown"
		control2.name = CCTracker.menu.constants.sound[i].Name.." sound"
		control2.width = "half"
		control2.disabled = function() return (not CCTracker.SV.sound[CCTracker.menu.constants.sound[i].Name].enabled) or (CCTracker.ccVariables[CCTracker.menu.constants.sound[i].Id].isHardCC and CCTracker.SV.sound.MuteOnHardCC) end
		control2.choices = CCTracker.menu.constants.SoundList
		control2.getFunc = function() return CCTracker.SV.sound[CCTracker.menu.constants.sound[i].Name].sound end
		control2.setFunc = function(value)
			CCTracker.SV.sound[CCTracker.menu.constants.sound[i].Name].sound = value
			PlaySound(value)
		end
		table.insert(CCTracker.menu.options[position].controls, control2)
	end
end

local function CreateAdditionalMenuEntries()
	Sizes()
	Alpha()
	Timers()
	CreateCCCheckboxes()
	CreateSoundControls()
end

function CCTracker.menu.CreateIcons(panel)					-- Thanks to DakJaniels who came up with this solution
	CCTracker.menu.icons = {["CC"] = {},["sound"] = {}}
	-- self:PrintDebug("enabled", "Panel was created.")
	
	-- if CCTracker.menu.icons[1] then CCTracker.debug:Print("Menu Icons seem to have been initialized before") else CCTracker.debug:Print("Menu Icons have not been initialized yet") end
		
	for i = 1, #CCTracker.menu.constants.CC do
		local number = CCTracker.menu.CreateMenuIconsPath(CCTracker.menu.constants.CC[i].Name)
		CCTracker.menu.icons.CC[i] = WM:CreateControl(CCTracker.name.."MenuCCIcon"..i, panel.controlsToRefresh[number].checkbox, CT_TEXTURE)
		CCTracker.menu.icons.CC[i]:SetAnchor(RIGHT, panel.controlsToRefresh[number].checkbox, LEFT, -25, 0)
		CCTracker.menu.icons.CC[i]:SetTexture(CCTracker.menu.constants.CC[i].Icon)
		CCTracker.menu.icons.CC[i]:SetDimensions(35, 35)
		if CCTracker.ccVariables[CCTracker.menu.constants.CC[i].Id].tracked then
			CCTracker.menu.icons.CC[i]:SetDesaturation(0)
		else
			CCTracker.menu.icons.CC[i]:SetDesaturation(1)
		end
	end
	for i = 1, #CCTracker.menu.constants.sound do
		local number = CCTracker.menu.CreateMenuIconsPath(CCTracker.menu.constants.sound[i].CheckboxName)
		CCTracker.menu.icons.sound[i] = WM:CreateControl(CCTracker.name.."MenuSoundIcon"..i, panel.controlsToRefresh[number].checkbox, CT_TEXTURE)
		CCTracker.menu.icons.sound[i]:SetAnchor(RIGHT, panel.controlsToRefresh[number].checkbox, LEFT, -25, 0)
		CCTracker.menu.icons.sound[i]:SetTexture(CCTracker.menu.constants.sound[i].Icon)
		CCTracker.menu.icons.sound[i]:SetDimensions(35, 35)
		if CCTracker.SV.sound[CCTracker.menu.constants.sound[i].Name].enabled then
			CCTracker.menu.icons.sound[i]:SetDesaturation(0)
		else
			CCTracker.menu.icons.sound[i]:SetDesaturation(1)
		end
	end
	
	CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", CCTracker.menu.CreateIcons)
	-- self:PrintDebug("enabled", "Deleting LAM Callback")
end

function CCTracker:BuildMenu()
	PopulateConstants()
	
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
		if panel == barnysCCTrackerOptions then self.menu.CreateIcons(panel) end
	end)
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(panel)
		if panel ~= barnysCCTrackerOptions then return end
		self.menu.UpdateLists()
	end)
	
	local websiteString
	if self.beta then
		websiteString = "https://www.esoui.com/downloads/info3988-barnysCCTracker-beta.html"
	else
		websiteString = "https://www.esoui.com/downloads/info3971-barnysCCTracker.html"
	end
	
	self.menu.ccList = {}
	self.menu.ccList.active = {
		["string"] = {},
		["id"] = {},
		["type"] = {},
	}
	self.menu.ccList.ignored = {
		["string"] = {},
		["id"] = {},
	}
	
	self.menu.additionalRootList = self.menu.additionalRootList or {}
	self.menu.actualSnaresList = self.menu.actualSnaresList or {}
	
	self.menu.metadata = {
		type = "panel",
        name = "barnysCCTracker",
        displayName = "|c2a52beb|rarnys|c2a52beCC|rTracker",
        author = "|c2a52beb|rarny",
        version = self.versionString,
		website = websiteString,
		feedback = "https://www.esoui.com/portal.php?&id=386",
		donation = "https://buymeacoffee.com/barnyteso",
        slashCommand = "/bcc",
        registerForRefresh = true,
		registerForDefaults = true,
	}
	self.menu.options = {
		{
            type = "header",
            name = "Settings"
        },
        {
            type = "checkbox",
            name = "Account Wide",
            tooltip = "Check for account wide addon settings",
            getFunc = function() return self.SV.global end,
            setFunc = function(value) 
                if self.SV.global == value then return end

                if value then
                    self.SV.global = true
                    self.SV = ZO_SavedVars:NewAccountWide(self.name.."SV", 1, nil, self.DEFAULT_SAVED_VARS, GetWorldName())
                else
                    self.SV = ZO_SavedVars:NewCharacterIdSettings(self.name.."SV", 1, nil, self.DEFAULT_SAVED_VARS, GetWorldName())
                    self.SV.global = false
                end
                for _, entry in pairs(self.ccVariables) do self.UI.ApplySize(entry.name) end
            end,
        },
		-- {
			-- type = "checkbox",
			-- name = "Use advanced tracking",
			-- tooltip = "Use additional resources to track CC",
			-- warning = "This is an advanced option! It might cause CC to be shown, even though you don't recognize your character being impacted. This is due to how ZOS handles combat events. When using this I strongly advice to use the 'Enable chat links' option under 'CC ignore list' to adjust CC detection individually",
			-- getFunc = function() return self.SV.settings.advancedTracking end,
			-- setFunc = function(value) self.SV.settings.advancedTracking = value end,
		-- },
		{
			type = "submenu",
			name = "UI",
			controls = {
				{	
					type = "checkbox",
					name = "Unlock CCTracker",
					tooltip = "Reposition and resize icons by dragging the edges or the center.",
					disabled = function() return self.SV.settings.sample end,
					-- width = "half",
					getFunc = function() return self.SV.settings.unlocked end,
					setFunc = function(value) self.UI.SetUnlocked(value) end,
				},
				{	
					type = "checkbox",
					name = "Show sample",
					tooltip = "Gives you a sample icon so you can see the changes you're making, when adjusting size or alpha.",
					warning = "Only enabled in locked mode. This also disables unlocked mode.",
					disabled = function() return self.SV.settings.unlocked end,
					-- width = "half",
					getFunc = function() return self.SV.settings.sample end,
					setFunc = function(value)
						self.SV.settings.sample = value
						self.UI.indicator.Stun.controls.tlw:ClearAnchors()
						self.UI.indicator.Stun.controls.tlw:SetHidden(not value)
						self.UI.indicator.Stun.controls.icon:SetHidden(not value)
						self.UI.indicator.Stun.controls.frame:SetHidden(not value)
						if value then
							self.UI.indicator.Stun.controls.tlw:SetAnchor(RIGHT, GuiRoot, RIGHT, -GuiRoot:GetWidth()/8, 0)
							self.UI.FadeScenes("Unlocked")
						else
							self.UI.indicator.Stun.controls.tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.SV.UI.xOffsets.Stun, self.SV.UI.yOffsets.Stun)
							self.UI.FadeScenes("Locked")
						end
					end,
				},
				{
					type = "divider",
				},
				{
					type = "checkbox",
					name = "Use one size for all icons",
					getFunc = function() return self.SV.UI.sizes.oneForAll end,
					setFunc = function(value) self.SV.UI.sizes.oneForAll = value end,
				},
				{
					type = "slider",
					name = "Icon size",
					disabled = function() return not self.SV.UI.sizes.oneForAll end,
					default = 50,
					min = 20,
					max = 200,
					step = 1,
					getFunc = function() return self.SV.UI.sizes.size end,
					setFunc = function(value)
						self.SV.UI.sizes.size = value
						for _, entry in pairs(self.ccVariables) do
							self.UI.ApplySize(entry.name)
						end
					end,
				},
				{
					type = "submenu",
					name = "Individual sizes",
					disabled = function() return self.SV.UI.sizes.oneForAll end,
					controls = {
					},
				},
				{
					type = "divider",
				},
				{
					type = "checkbox",
					name = "Use global alpha",
					getFunc = function() return self.SV.UI.alpha.oneForAll end,
					setFunc = function(value) self.SV.UI.alpha.oneForAll = value end,
				},
				{
					type = "slider",
					name = "Icon alpha",
					tooltip = "CC icons are too prominent for your liking? Simply adjust alpha with this slider to make them disappear.",
					disabled = function() return not self.SV.UI.alpha.oneForAll end,
					default = 100,
					min = 0,
					max = 100,
					step = 1,
					getFunc = function() return self.SV.UI.alpha.alpha end,
					setFunc = function(value)
						self.SV.UI.alpha.alpha = value
						self.UI.ApplyAlpha()
					end,
				},
				{
					type = "submenu",
					name = "Individual alpha values",
					disabled = function() return self.SV.UI.alpha.oneForAll end,
					controls = {
					},
				},
				{
					type = "divider"
				},
			},
		},
		{
			type = "submenu",
			name = "CC to track",
			controls = {},
		},
		{
			type = "submenu",
			name = "Timers",
			tooltip = "Activate timers for CC to know when it ends and if it's worth cleansing",
			controls = {
				{
					type = "checkbox",
					name = "Use general configuration",
					getFunc = function() return self.SV.UI.timers.oneForAll end,
					setFunc = function(value)
						self.SV.UI.timers.oneForAll = value
						if value then
							for _, entry in pairs(self.menu.constants.CC) do
								self.UI.ApplyTimerAnchors(entry.Name)
								self.UI.indicator[entry.name].controls.timerBar:SetColor(unpack(self.SV.UI.timers.timerBarColor))
								self.UI.indicator[entry.name].controls.timer:SetColor(unpack(self.SV.UI.timers.timerColor))
							end
						else
							for _, entry in pairs(self.menu.constants.CC) do
								self.UI.ApplyTimerAnchors(entry.Name)
								self.UI.indicator[entry.name].controls.timerBar:SetColor(unpack(self.SV.UI.timers[entry.name].timerBarColor))
								self.UI.indicator[entry.name].controls.timer:SetColor(unpack(self.SV.UI.timers[entry.name].timerColor))
							end
						end
					end,
				},
				{
					type = "submenu",
					name = "General setup",
					disabled = function() return not self.SV.UI.timers.oneForAll end,
					controls = {
						{
							type = "checkbox",
							name = "Show timer bar",
							tooltip = "Show status bar for time remaining",
							width = "half",
							getFunc = function() return self.SV.UI.timers.showTimerBar end,
							setFunc = function(value)
								self.SV.UI.timers.showTimerBar = value
								if not value and self.SV.UI.timers.timerAnchor == "TIMER BAR" and self.SV.UI.timers.showTimer then
									self.SV.UI.timers.timerAnchor = "ICON"
								end
							end,
						},
						{	
							type = "dropdown",
							name = "Timer bar orientation",
							choices = CCTracker.menu.constants.timerBarOrientation,
							disabled = function() return not self.SV.UI.timers.showTimerBar end,
							getFunc = function() return self.SV.UI.timers.timerBarOrientation end,
							setFunc = function(value)
								self.SV.UI.timers.timerBarOrientation = value
								for _, entry in pairs(self.menu.constants.CC) do
									CCTracker.UI.ApplyTimerAnchors(entry.Name)
								end
							end,
							width = "half",
						},
						{
							type = "colorpicker",
							name = "Bar color",
							disabled = function() return not self.SV.UI.timers.showTimerBar end,
							getFunc = function() return unpack(self.SV.UI.timers.timerBarColor) end,
							setFunc = function(r, g, b, a)
								self.SV.UI.timers.timerBarColor = {r, g, b, a}
								for _, entry in pairs(self.menu.constants.CC) do
									CCTracker.UI.indicator[entry.Name].controls.timerBar:SetColor(r, g, b, a)
								end
							end,
						},
						{
							type = "checkbox",
							name = "Show time remaining",
							width = "half",
							getFunc = function() return self.SV.UI.timers.showTimer end,
							setFunc = function(value)
								self.SV.UI.timers.showTimer = value
								if value and self.SV.UI.timers.timerAnchor == "TIMER BAR" and not self.SV.UI.timers.showTimerBar then
									self.SV.UI.timers.timerAnchor = "ICON"
								end
							end,
						},
						{	
							type = "dropdown",
							name = "Show timer on:",
							tooltip = "You can chose to show the timer on either the icon or the timer bar",
							disabled = function() return not (self.SV.UI.timers.showTimer and self.SV.UI.timers.showTimerBar) end,
							choices = CCTracker.menu.constants.timerAnchors,	
							getFunc = function() return self.SV.UI.timers.timerAnchor end,
							setFunc = function(value)
								self.SV.UI.timers.timerAnchor = value
								for _, entry in pairs(self.menu.constants.CC) do
									CCTracker.UI.ApplyTimerAnchors(entry.Name)
								end
							end,
							width = "half",
						},
						{
							type = "colorpicker",
							name = "Timer color",
							disabled = function() return not self.SV.UI.timers.showTimer end,
							getFunc = function() return unpack(self.SV.UI.timers.timerColor) end,
							setFunc = function(r, g, b, a)
								self.SV.UI.timers.timerColor = {r, g, b, a}
								for _, entry in pairs(self.menu.constants.CC) do
									CCTracker.UI.indicator[entry.Name].controls.timer:SetColor(r, g, b, a)
								end
							end,
						},
					},
				},
				{
					type = "submenu",
					name = "Individual setups",
					disabled = function() return self.SV.UI.timers.oneForAll end,
					controls = {
					},
				},
			},
		},
		{
			type = "submenu",
			name = "Sound",
			tooltip = "You can enable sounds to also get an audio cue when hit by CC",
			controls = {
				{
					type = "checkbox",
					name = "Mute UI sound when under hard CC",
					warning = "This disables sound selection for all hard CC!",
					disabled = function()
						for _, isActive in pairs(CCTracker.SV.settings.tracked) do
							if isActive then return false end
						end
						return true
					end,
					getFunc = function() return self.SV.sound.MuteOnHardCC end,
					setFunc = function(value)
						self.SV.sound.MuteOnHardCC = value
					end,
				},
			},
		},
		{
			type = "submenu",
			name = "CC Ignore List",
			controls = {
				{	
					type = "checkbox",
					name = "Enable chat links",
					tooltip = "This enables clickable links in chat, that let you ignore the linked CC ability",
					warning = "To use this you need to have LibChatMessage installed!",
					disabled = function() return not self.debug end,
					getFunc = function() return self.SV.settings.ccIgnoreLinks end,
					setFunc = function(value)
						self.SV.settings.ccIgnoreLinks = value
						self:HandleLibChatMessage()
					end,
				},
				{	
					type = "dropdown",
					name = "List of current cc abilities",
					tooltip = "You can use this to look for unwanted abilities, for example if your stun icon doesn't disappear, you can look here which ability causes the stun to be recognized",
					choices = self.menu.ccList.active.string,	
					getFunc = function()
						if self.menu.ccList.active.string[1] == "No cc active" then
							return self.menu.ccList.active.string[1]
						else
							for i, entry in ipairs(self.menu.ccList.active.id) do
								if entry == self.menu.ccList.abilityId then return self.menu.ccList.active.string[i] end
							end
						end
					end,
					setFunc = function(value)
						if value ~= "No cc active" then
							for i, entry in ipairs(self.menu.ccList.active.string) do
								if entry == value then
									self.menu.ccList.abilityId = self.menu.ccList.active.id[i]
									self.menu.ccList.abilityType = self.menu.ccList.active.type[i]
								end
							end
							self.menu.ccList.abilityAction = "ignore"
						end
					end,
					width = "half",
				},
				{	
					type = "button",
					name = "Ignore ability",
					tooltip = "This puts the currently selected ability on an ignore list",
					disabled = function() return self.menu.ccList.abilityAction ~= "ignore" end,
					func = function()
						self.SV.ignored[self.menu.ccList.abilityId] = self.menu.ccList.abilityType
						self.menu.ccList.abilityAction = nil
						for i, entry in ipairs(self.ccActive) do
							if entry.id == self.menu.ccList.abilityId then table.remove(self.ccActive, i) end
						end
						self.menu.ccList.abilityId = nil
						self.menu.ccList.abilityType = nil
						self.menu.UpdateLists()
						self.UI.ApplyIcons()
					end,
					width = "half",
				},
				{	
					type = "dropdown",
					name = "List of ignored cc abilities",
					tooltip = "This is the list of your ignored abilities",
					choices = self.menu.ccList.ignored.string,		
					getFunc = function()
						if self.menu.ccList.ignored.string[1] == "No ignored abilities" then
							return self.menu.ccList.ignored.string[1]
						else
							for i, entry in ipairs(self.menu.ccList.ignored.id) do
								if entry == self.menu.ccList.abilityId then return self.menu.ccList.ignored.string[i] end
							end
						end
					end,
					setFunc = function(value)
						if value ~= "No ignored abilities" then
							for i, entry in ipairs(self.menu.ccList.ignored.string) do
								if entry == value then
									self.menu.ccList.abilityId = self.menu.ccList.ignored.id[i]
								end
							end
							self.menu.ccList.abilityAction = "unignore"
						end
					end,
					width = "half",
				},
				{	
					type = "button",
					name = "Reenable ability",
					tooltip = "This unignores the currently selected ability",
					disabled = function() return self.menu.ccList.abilityAction ~= "unignore" end,
					func = function()
						self.SV.ignored[self.menu.ccList.abilityId] = nil
						self.menu.ccList.abilityId = nil
						self.menu.ccList.abilityType = nil
						self.menu.ccList.abilityAction = nil
						self.menu.UpdateLists()
					end,
					width = "half",
				},
				{
					type = "editbox",
					name = "Manually add ability id to ignore list",
					warning = "If you enable chat links, you'll see any CC that is recognized, including its ID",
					isMultiline = false,
					getFunc = function() return self.menu.ccList.abilityId end,
					setFunc = function(value)
						self.menu.ccList.abilityId = value
						self.menu.ccList.abilityAction = "manually"
					end,
					width = "half",
				},
				{
					type = "editbox",
					name = "Ability description",
					tooltip = "If you want, you can add a description to the ability you'd like to ignore",
					warning = "Only enabled, if you add manually!",
					disabled = function() return self.menu.ccList.abilityAction ~= "manually" end,
					isMultiline = false,
					getFunc = function() return self.menu.ccList.abilityType end,
					setFunc = function(value)
						self.menu.ccList.abilityType = value
					end,
					width = "half",
				},
				{	
					type = "button",
					name = "Add ability to ignore list",
					tooltip = "This adds the current manually selected ID to the ability ignore list",
					disabled = function() return self.menu.ccList.abilityAction ~= "manually" end,
					func = function()
						self.SV.ignored[self.menu.ccList.abilityId] = self.menu.ccList.abilityType or "manually added"
						if self:AIdInList(self.menu.ccList.abilityId) then
							local _, i = self:AIdInList(self.menu.ccList.abilityId)
							table.remove(self.ccActive, i)
							self.UI.ApplyIcons()
							self:PrintDebug("ignoreList", "Manually removed currrently active CC ability ID: "..self.menu.ccList.abilityId)
						end
						self.menu.ccList.abilityId = nil
						self.menu.ccList.abilityType = nil
						self.menu.ccList.abilityAction = nil
						self.menu.UpdateLists()
						self.UI.ApplyIcons()
					end,
				},
			},
		},
		{
			type = "header",
			name = "Debug section",
		},
		{	
			type = "checkbox",
			name = "Show live list of active CC",
			getFunc = function() return self.SV.debug.activeCCList end,
			setFunc = function(value)
				self.SV.debug.activeCCList = value
				self.UI.HideLiveCCWindow(value)
				if value then self:CCChanged() end
			end,
		},
        {	
			type = "checkbox",
            name = "Enable debugging",
			disabled = function() if self.debug then return false else return true end end,
            getFunc = function() return self.SV.debug.enabled end,
            setFunc = function(value)
                self.SV.debug.enabled = value
				self:HandleLibChatMessage()
				if not value then
					self:SetAllDebugFalse()
				end
            end
        },
		{ 
			type = "submenu",
			name = "Debug options",
			controls = {
				{	
					type = "checkbox",
					name = "Debug ccActive",
					disabled = function() return not self.SV.debug.enabled end,
					getFunc = function() return self.SV.debug.ccActive end,
					setFunc = function(value)
						self.SV.debug.ccActive = value
					end,
					width = "half",
				},
				{	
					type = "checkbox",
					name = "Debug ccAdded",
					disabled = function() return not self.SV.debug.enabled end,
					getFunc = function() return self.SV.debug.ccAdded end,
					setFunc = function(value)
						self.SV.debug.ccAdded = value
					end,
					width = "half",
				},
				{	
					type = "checkbox",
					name = "Debug ccCache",
					disabled = function() return not self.SV.debug.enabled end,
					getFunc = function() return self.SV.debug.ccCache end,
					setFunc = function(value)
						self.SV.debug.ccCache = value
					end,
					width = "half",
				},
				{	
					type = "checkbox",
					name = "Debug root detection",
					disabled = function() return not self.SV.debug.enabled end,
					getFunc = function() return self.SV.debug.roots end,
					setFunc = function(value)
						self.SV.debug.roots = value
					end,
					width = "half",
				},
				{	
					type = "checkbox",
					name = "Debug ignore list detection",
					disabled = function() return not self.SV.debug.enabled end,
					getFunc = function() return self.SV.debug.ignoreList end,
					setFunc = function(value)
						self.SV.debug.ignoreList = value
					end,
					width = "half",
				},
				{	
					type = "checkbox",
					name = "Debug actual snare list",
					disabled = function() return not self.SV.debug.enabled end,
					getFunc = function() return self.SV.debug.actualSnares end,
					setFunc = function(value)
						self.SV.debug.actualSnares = value
					end,
					width = "half",
				},
				{	
					type = "checkbox",
					name = "Debug additional root list detection",
					disabled = function() return not self.SV.debug.enabled end,
					getFunc = function() return self.SV.debug.additionalRootList end,
					setFunc = function(value)
						self.SV.debug.additionalRootList = value
					end,
					width = "half",
				},
				{	
					type = "checkbox",
					name = "Debug mute audio",
					disabled = function() return not self.SV.debug.enabled end,
					getFunc = function() return self.SV.debug.audioMute end,
					setFunc = function(value)
						self.SV.debug.audioMute = value
					end,
					width = "half",
				},
				{
					type = "submenu",
					name = "Additional CC Lists",
					controls = {
						{
							type = "dropdown",
							name = "Current additional roots",
							disabled = function() return #self.SV.additionalRoots == 0 end,
							choices = self.menu.additionalRootList,
							getFunc = function() if next(self.SV.additionalRoots) then return self.menu.additionalRootList[1] end end,
							setFunc = function(value) 
								for i, id in ipairs(self.SV.additionalRoots) do
									local str = tostring("|t20:20:"..GetAbilityIcon(id).."|t "..id.." - "..CCTracker:CropZOSString(GetAbilityName(id), "ability"))
									if str == value then
										self.menu.rootId = id
										self.menu.rootNum = i
										break
									end
								end
							end,
							width = "half",
						},
						{
							type = "dropdown",
							name = "Current actual snares",
							disabled = function() return #self.SV.actualSnares == 0 end,
							choices = self.menu.actualSnaresList,
							getFunc = function() if next(self.SV.actualSnares) then return self.menu.actualSnaresList[1] end end,
							setFunc = function(value) 
								for i, id in ipairs(self.SV.actualSnares) do
									local str = tostring("|t20:20:"..GetAbilityIcon(id).."|t "..id.." - "..CCTracker:CropZOSString(GetAbilityName(id), "ability"))
									if str == value then
										self.menu.snareId = id
										self.menu.snareNum = i
										break
									end
								end
							end,
							width = "half",
						},
						{
							type = "button",
							name = "Remove ability from roots",
							tooltip = "If an ability was wrongfully declared as root, you can remove it manually",
							disabled = function() return ((#self.SV.additionalRoots == 0) or not self.menu.rootId) end,
							func = function()
								table.remove(self.SV.additionalRoots, self.menu.rootNum)
								CCTracker.menu.CreateAdditionalRootList()
							end,
							width = "half",
						},
						{
							type = "button",
							name = "Remove ability from snares",
							tooltip = "If an ability was wrongfully declared as snare, you can remove it manually",
							disabled = function() return ((#self.SV.actualSnares == 0) or not self.menu.snareId) end,
							func = function()
								table.remove(self.SV.actualSnares, self.menu.snareNum)
								CCTracker.menu.CreateActualSnaresList()
							end,
							width = "half",
						},
					},
				},
			},
		},
	}
	
	CreateAdditionalMenuEntries()
	self.menu.panel = LAM:RegisterAddonPanel(self.name.."Options", self.menu.metadata)
    LAM:RegisterOptionControls(self.name.."Options", self.menu.options)
end