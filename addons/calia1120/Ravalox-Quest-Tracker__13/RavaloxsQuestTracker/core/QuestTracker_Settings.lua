
local LAM2 = LibAddonMenu2

local colorYellow 		= "|cFFFF00" 	-- yellow 
local colorSoftYellow   = "|cCCCC00"    -- Duller Yellow for Descriptions
local colorRed 			= "|cFF0000" 	-- Red
local colorRavalox		= "|cB60000"    -- Ravalox Red   (B6 = 182  -  82 too dark)
local DEFAULT_COLOR = {r = ZO_NORMAL_TEXT.r, g = ZO_NORMAL_TEXT.g, b = ZO_NORMAL_TEXT.b, a = ZO_NORMAL_TEXT.a}

local tooltipAnchorName = {
	[LEFT] = "Left",
	[RIGHT] = "Right",
}
local function GetAnchorInfo(relativeToName)
	if relativeToName == "Left" then
		return RIGHT, LEFT
	end
	return LEFT, RIGHT
end


--======= Update Functions (because reasons) =======--
local function AutoOpenQTNodes(self)
	if self.svCurrent.autoOpenNodes then 
		self:OpenAllQuestNodes() 
		QUESTTRACKER_OPENSELECTEDCATEGORYQUESTNODES:UpdateValue(false, false)
		self.navigationTree:RefreshVisible()
	end
end

local function OpenQTCategoryOnLogin(self)
	if autoOpenCategoryOnLogin then
		self:OpenSelectedCategoryQuestNodes()
		QUESTTRACKER_AUTOOPENNODES:UpdateValue(false, false)
		self.navigationTree:RefreshVisible()
	end
end

local function UpdateQTAutoClose(self)
	local exclusiveName = self.svCurrent.nodeExclusitivity.currentSetting
	if exclusiveName == "All" or exclusiveName == "Quests Only" then
		QUESTTRACKER_OPENSELECTEDCATEGORYQUESTNODES:UpdateValue(false, false)
	end
	if exclusiveName ~= "None" then
		QUESTTRACKER_AUTOOPENNODES:UpdateValue(false, false)
	end
end
local function TryAutoSizeWidthAndHeight(self)
	-- RefreshVisible must be done in the calling function BEFORE calling this function
	-- we also call RefreshVisible here. It must be done before calling this function
	-- so the font size changes take effect in order to calculate the properly widths & heights
	local autoSizeWidth = self.svCurrent.mainWindow.autoWindowSizeWidth
	local autoSizeHeight = self.svCurrent.mainWindow.autoWindowSizeHeight
	
	if not (autoSizeWidth or autoSizeHeight) then return end
	
	local rootNode = self.navigationTree.rootNode
	self:UpdateChildHeightsToRoot(rootNode)
	
	if autoSizeWidth then
		self:AutoSizeWinWidth()
	end
	if autoSizeHeight then 
		self:AutoSizeWinHeight()
	end
	
	-- RefreshVisible must also be called again after resizing so those changes take effect.
	self.navigationTree:RefreshVisible()
end

local function UpdateAllSettings(self)
    AutoOpenQTNodes(self)
    OpenQTCategoryOnLogin(self)
    UpdateQTAutoClose(self)
	
    local newSetting = self.svCurrent.hideDefaultQuestTracker and "false" or "true" 
	SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_TRACKER, newSetting)

    -- V3.8.2.14 Calamath NOTE: Since update 38, the same settings have been added to Vanilla UI, so they are now linked.
    SetSetting(SETTING_TYPE_UI, UI_SETTING_AUTOMATIC_QUEST_TRACKING, self.svCurrent.questTrackForceAssist and "true" or "false")
    
    self:SetLockState(self.svCurrent.mainWindow.lock)
    self:SetupFragmentForGameScene(self.svCurrent.mainWindow.showInGameScene)
    self:UpdateWindowVisibility(self.svCurrent.mainWindow.hideQuestWindow)
    self:UpdateBackdropColor()
    self:UpdateDragBarColor()
    self:UpdateBackdrop()
    self:SetLockState(self.svCurrent.mainWindow.isItLocked)
	self:SortQuestNodes(sortByLevel)
    self.navigationTree:RefreshVisible()
	
	-- This must be done last so we have a RefreshVisible before & it also calls RefreshVisible after
	TryAutoSizeWidthAndHeight(self)
end

-------------------------------------------------------------------------------------------------
--  Settings Menu --
-------------------------------------------------------------------------------------------------
function QuestTracker_CreateSettingsMenu(self)
	--local svCurrent 				= self.svCurrent
	--local svMainWindow			= svCurrent.mainWindow
	--local svMainWindowBackdrop 	= svMainWindow.backdrop
	--local fontSettings 			= svCurrent.fontSettings
	--local categoryFontSettings 	= fontSettings.categories
	--local questFontSettings 		= fontSettings.quests
	--local conditionFontSettings 	= fontSettings.conditions
	--local nodeExclusitivity		= svCurrent.nodeExclusitivity
	
	local panelData = {
		type = "panel",
		name = "Ravalox' QuestTracker",
		displayName = "|cB60000 Ravalox' |cFFFFFF QuestTracker",
		author = "Ravalox Darkshire, Calia1120",
		version = self.codeVersion,
		slashCommand = "/questtracker",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("QuestTracker_Options", panelData)
	self.addonPanel = cntrlOptionsPanel
	
	local optionsData = {
		[1] = {
			type = "description",
			text = colorSoftYellow.."A Quest Tracker UI improved over the in game Tracker. QustTracker is a re-write and continuation from Wykkyd's QuestTracker, please rebort bugs and post feature requests on esoui.com in the comments section for this addon. \n \nMany thanks to Circonian for doing the 3.0 re-write! \r"
		},
		[2] = {
			type = "submenu",
			name = "|cAAAAAAGeneral Options",
			controls = {
				[1] = {
					type = "checkbox",
					name = "Use Account Wide Settings",
					tooltip = "When the Account Wide Setting is "..colorRed.."off|r, then each character can have different configuration options set.",
					default = true,
					getFunc = function() return self.svAccount.accountWide end,
					setFunc = function(bValue)
						self.svAccount.accountWide = bValue
						if not bValue then
							local sDisplayName = GetDisplayName()
							local sUnitName = GetUnitName("player")
							-- Option to copy settings from Accountwide to character
							--ZO_DeepTableCopy(_G["QuestTrackerSavedVars"]["Default"][sDisplayName]["$AccountWide"], _G["QuestTrackerSavedVars"]["Default"][sDisplayName][sUnitName])
							--self.svCharacter.accountWide = bValue   -- change bValue to nil to destroy invalid data when coying to character from account.  If reversing the copy bValue needs to be updated as written here.
						end
						self:SwapSavedVars(bValue)
						UpdateAllSettings(self)
					end,
				},
			}, -- Added to bypass nested menus
		},-- Added to bypass nested menus
				[3] = {
					type = "submenu",
					name = "|cAAAAAAInterface Behaviour Options",
					controls = {    -- Interface Behaviour Options
						[1] = {
							type = "checkbox",
							name = "Hide Default Quest Tracker",
							tooltip = "Toggle the visibility of the GAMES DEFAULT quest tracker. This is for the default ESO quest tracker that is built into the game.",
							default = true,
							getFunc = function() return self.svCurrent.hideDefaultQuestTracker   end,
							setFunc = function(hideDefaultQuestTracker) 
								self.svCurrent.hideDefaultQuestTracker  = hideDefaultQuestTracker
								local newSetting = hideDefaultQuestTracker and "false" or "true"
								SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_TRACKER, newSetting)
							end,
-- V3.8.2.3 Calamath NOTE : Following unnecessary code was the cause of the malfunction for the issue where the hide off/on setting did not work.
--[[
                            getFunc = function() return self.svCurrent.hideFocusedQuestTracker   end,
                            SetFunc = function(hideFocusedQuestTracker) 
								self.svCurrent.hideFocusedQuestTracker  = hideFocusedQuestTracker
								local newSetting = hideFocusedQuestTracker and "false" or "true"
								SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_QUEST_TRACKER, newSetting)
							end,
]]
							reference = "QUESTTRACKER_HIDEDEFAULTQUESTTRACKERWINDOW",
						},					
						[2] = {
							type = "checkbox",
							name = "Hide this Quest Tracker",
							tooltip = "Toggle the visibility of the quest tracker window.\n(For this addon's quest tracker window)",
							default = false,
							getFunc = function() return self.svCurrent.mainWindow.hideQuestWindow end,
							setFunc = function(hideQuestWindow) 
								self.svCurrent.mainWindow.hideQuestWindow = hideQuestWindow
								self:UpdateWindowVisibility(hideQuestWindow)
							end,
						},
						[3] = {
							type = "checkbox",
							name = "Hide this Quest Tracker when in combat",
							tooltip = "Toggle the visibility of the quest tracker window when in combat.\n(For this addon's quest tracker window)",
							default = true,
							getFunc = function() return self.svCurrent.hideInCombat end,
							setFunc = function(bValue)
								self.svCurrent.hideInCombat = bValue
							end,
						},						
						[4] = {
							type = "checkbox",
							name = "Show QuestTracker while in settings menu",
							tooltip = "Show/Hide the QuestTracker window when in the game settings menu.",
							default = false,
							getFunc = function() return self.svCurrent.mainWindow.showInGameScene end,
							setFunc = function(showInGameScene) 
								self.svCurrent.mainWindow.showInGameScene = showInGameScene
								self:SetupFragmentForGameScene(showInGameScene)
								end,
						},
						[5] = {
							type = "checkbox",
							name = "Lock QuestTracker UI in place",
							tooltip = "When ON QuestTracker will be locked to the position on screen.  When OFF, the UI can be moved.",
							default = false,
							getFunc = function() return self.svCurrent.mainWindow.lock end,
							setFunc = function(lock) 
								self.svCurrent.mainWindow.lock = lock
									self:SetLockState(lock)
									self.navigationTree:RefreshVisible()
							end,
						},	
						[6] = {					
							type = "checkbox",
							name = "Automatically re-size QuestTracker height",
							tooltip = "Option to allow QuestTracker to automatically or manaully resize the window.",
							default = true,
							getFunc = function() return self.svCurrent.mainWindow.autoWindowSizeHeight end,
							setFunc = function(autoWindowSizeHeight) 
								self.svCurrent.mainWindow.autoWindowSizeHeight = autoWindowSizeHeight
								if not autoWindowSizeHeight then return end
								self:AutoSizeWinHeight()
							end,
						},
						[7] = {					
							type = "checkbox",
							name = "Automatically re-size QuestTracker width",
							tooltip = "Option to allow QuestTracker to automatically or manaully resize the window.",
							default = true,
							getFunc = function() return self.svCurrent.mainWindow.autoWindowSizeWidth end,
							setFunc = function(autoWindowSizeWidth) 
								self.svCurrent.mainWindow.autoWindowSizeWidth = autoWindowSizeWidth
								if not autoWindowSizeWidth then return end
								self:AutoSizeWinWidth()
							end,
						},
						[8] = {
							type = "dropdown",
							name = "Auto Close",
							tooltip = "Automatically close quests and/or categories when not selected.",
							choices = {"None", "All", "Categories Only", "Quests Only"},
							default = "All",
							getFunc = function() return self.svCurrent.nodeExclusitivity.currentSetting end,
							setFunc = function(exclusiveName) 
								-- SV is set in Main Exclusivity due to complexity of the conditional code required.
								self:SetTreeExclusitivity(exclusiveName)
								self.navigationTree:RefreshVisible()
								UpdateQTAutoClose(self)
							end,
						},
						[9] = {
							type = "checkbox",
							name = "Open ALL Quest Nodes By Default",
							tooltip = "Opens next step for every Quest in every category. \n\n|cff0000NOTE:|r \nAutoClose options must be set to |c00ff00NONE|r.  This option is disabled when Expand active Category on login is on.",
							default = false,
							disabled = function() return self.svCurrent.nodeExclusitivity.currentSetting ~= "None" or self.svCurrent.autoOpenCategoryOnLogin end,
							getFunc = function() return self.svCurrent.autoOpenNodes end,
							setFunc = function(autoOpenNodes) self.svCurrent.autoOpenNodes = autoOpenNodes 
								AutoOpenQTNodes(self)
							end,
							reference = "QUESTTRACKER_AUTOOPENNODES",
						},
						[10] = {
							type = "checkbox",
							name = "Auto Expand quests in active Category on Login",
							tooltip = "Opens selected Category and Quests within on login. Intended to give you an overview of the gathered quests in the same category as the selected quests when you login.  \n\n|cff0000NOTE:|r AutoClose must be set to |c00ff00NONE|r or |c00ff00Categories|r to use this feature.  This feature is disabled when Open ALL Quests is on.",
							default = false,
							disabled = function()
								local exclusiveName = self.svCurrent.nodeExclusitivity.currentSetting
								return exclusiveName == "All" or exclusiveName == "Quests Only" or self.svCurrent.autoOpenNodes
							end,                    
							getFunc = function() return self.svCurrent.autoOpenCategoryOnLogin end,
							setFunc = function(autoOpenCategoryOnLogin) self.svCurrent.autoOpenCategoryOnLogin = autoOpenCategoryOnLogin
								OpenQTCategoryOnLogin(self)
							end,
							reference = "QUESTTRACKER_OPENSELECTEDCATEGORYQUESTNODES",
						},
					},
				},
				[4] = {
					type = "submenu",
					name = "|cAAAAAAInterface Background Options",
					controls = {	-- Interface background options
						[1] = {
							type = "dropdown",
							name = "Background",
							tooltip = "Choose a background type to display.",
							choices = self:GetBackdropChoices(),
							default = "Colored",
							getFunc = function() return self.svCurrent.mainWindow.backdrop.backdropName end,
							setFunc = function(backdropName) 
								self.svCurrent.mainWindow.backdrop.backdropName = backdropName
								self:UpdateBackdrop(backdropName)
							end,
						},
						[2] = {
							type = "colorpicker",
							name = "Background Color",
							tooltip = "Change the color of the backdrop, background type must be set to Colored.",
							default = {r=0, g=0, b=0, a=1},
							disabled = function() return self.svCurrent.mainWindow.backdrop.backdropName ~= "Colored" end,
							getFunc = function() return unpack(self.svCurrent.mainWindow.backdrop.backdropColor) end,
							setFunc = function(r,g,b,a) self.svCurrent.mainWindow.backdrop.backdropColor = {r, g, b, a}
								self:UpdateBackdropColor()
							end,
						},
						[3] = {
							type = "colorpicker",
							name = "Dragbar Color",
							tooltip = "Change the color of the Drag Bar at the top of the QuestTracker window.",
							default = {r=1, g=1, b=1, a=.5},
							getFunc = function() return unpack(self.svCurrent.mainWindow.backdrop.dragBarColor) end,
							setFunc = function(r,g,b,a) self.svCurrent.mainWindow.backdrop.dragBarColor = {r, g, b, a}
								self:UpdateDragBarColor()
							end,
						},				
						[4] = {
							type = "checkbox",
							name = "Hide Background marble texture",
							tooltip = "When ON the background marble texture effect will be hidden (dots/splotches of dark color).",
							default = false,
							getFunc = function() return self.svCurrent.mainWindow.backdrop.hideMungeOverlay end,
							setFunc = function(hideMungeOverlay) 
								self.svCurrent.mainWindow.backdrop.hideMungeOverlay = hideMungeOverlay
								self:UpdateBackdrop(backdropName)								
							end,
						},
						[5] = {
							type = "slider",
							name = "Background Opacity",
							tooltip = "Change the transparency of the background.",
							min = 0,
							max = 100,
							step = 1,
							default = 50,  --self.svCurrent.mainWindow.backdropAlpha,
							getFunc = function() 
								local r,g,b,alpha = unpack(self.svCurrent.mainWindow.backdrop.backdropColor)
								return zo_round(alpha*100)
							end,
							setFunc = function(backgroundAlpha)
								backgroundAlpha = backgroundAlpha/100
								local r,g,b 	= unpack(self.svCurrent.mainWindow.backdrop.backdropColor)
								self.svCurrent.mainWindow.backdrop.backdropColor = {r,g,b,backgroundAlpha}
								self:UpdateBackdropColor()
								self.navigationTree:RefreshVisible()
							end,
						},			
						[6] = {
							type = "checkbox",
							name = "Hide Background On Lock",
							tooltip = "When ON the background will be hidden when you lock the window.",
							default = false,
							getFunc = function() return self.svCurrent.mainWindow.backdrop.backdropHideOnLock end,
							setFunc = function(backdropHideOnLock) 
								self.svCurrent.mainWindow.backdrop.backdropHideOnLock = backdropHideOnLock
								self.navigationTree:RefreshVisible()
							end,
						},
						[7] = {
							type = "dropdown",
							name = "Hide Lock Icon",
							tooltip = "Option to hide the lock icon shown by defualt on the dragbar indicating the locked state of the QuestTracker window.  \n\n|cff0000NOTE:|r  You will need to use /slash commands or the settings menu to lock/unlock is hiding the Icon.",
							choices = {"Never", "Locked", "Always"},
							default = "Never",
							getFunc = function() return self.svCurrent.mainWindow.hideLockIcon end,
							setFunc = function(hideLockIcon) self.svCurrent.mainWindow.hideLockIcon = hideLockIcon
									--checks lock SV and sets UI as indicated
									self:SetLockState(QUESTTRACKER.svCurrent.mainWindow.isItLocked)
									self.navigationTree:RefreshVisible()
							end,
						},
					},					
				},
			--},  -- Commented for removal of nested menus
		--},   -- Commented for removal of nested menus
		[5] = {
			type = "submenu",
			name = "|c00AA00Tooltip Options",
			controls = {
				[1] = {
					type = "checkbox",
					name = "Show Quest Tooltips",
					tooltip = "Display quest tootlips when mousing over a quest?",
					default = false,
					getFunc = function() return self.svCurrent.tooltips.show end,
					setFunc = function(showTooltips) self.svCurrent.tooltips.show = showTooltips 
						self.navigationTree:RefreshVisible()
					end,
				},
				[2] = {
					type = "checkbox",
					name = "Automatic Quest Tooltips",
					tooltip = "Automatically display quest tootlips when a new quest is selected?",
					default = false,
					getFunc = function() return self.svCurrent.tooltips.autoTooltip end,
					setFunc = function(autoTooltip) self.svCurrent.tooltips.autoTooltip = autoTooltip
						self.navigationTree:RefreshVisible()
					end,
				},
				[3] = {
					type = "slider",
					name = "Automatic Quest Tooltip Fade Time",
					tooltip = "Choose the desired amount of time before automatic quest tooltips are removed.",
					min = 1,
					max = 15,
					step = 1,
					default = 5,
					getFunc = function() return self.svCurrent.tooltips.fadeTime end,
					setFunc = function(tooltTipFadeTime) self.svCurrent.tooltips.fadeTime  = tooltTipFadeTime 
						self.navigationTree:RefreshVisible()
					end,
				},
				[4] = {
					type = "dropdown",
					name = "Anchor Tooltip Side",
					tooltip = "Choose which side of the window you want the tooltips to be displayed on.",
					choices = {"Left", "Right"},
					default = "Left",
					getFunc = function() return tooltipAnchorName[self.svCurrent.tooltips.relativeTo] end,
					setFunc = function(relativeToName) 
						local anchorPoint, relativeTo = GetAnchorInfo(relativeToName)
						QUESTTRACKER.svCurrent.tooltips.anchorPoint = anchorPoint
						QUESTTRACKER.svCurrent.tooltips.relativeTo 	= relativeTo
						self.navigationTree:RefreshVisible()
					end,
				},
			},
		},
		[6] = {
			type = "submenu",
			name = "|c0044F0Category Options",
			controls = {
				[1] = {
					type = "checkbox",
					name = "Show Number of Quests",
					tooltip = "Display number of quests before the category name?",
					default = false,
					getFunc = function() return self.svCurrent.showNumCategoryQuests end,
					setFunc = function(showNumCategoryQuests) self.svCurrent.showNumCategoryQuests = showNumCategoryQuests 
						self.navigationTree:RefreshVisible()
					end,
				},
				[2] = {
					type = "dropdown",
					name = "Category Font",
					tooltip = "Choose a font for quest category names.",
					choices = self:GetFontChoices(),
					default = self.svCurrent.default.fontSettings.categories.font,
					getFunc = function() return self.svCurrent.fontSettings.categories.font end,
					setFunc = function(categoryFontName) self.svCurrent.fontSettings.categories.font = categoryFontName
						self.navigationTree:RefreshVisible() -- must be called first
						TryAutoSizeWidthAndHeight(self)
					end,
				},
				[3] = {
					type = "dropdown",
					name = "Category Font Effects",
					tooltip = "Choose a font outline effect for category names.",
					choices = self:GetOutlineChoices(),
					default = self.svCurrent.default.fontSettings.categories.outline,
					getFunc = function() return self.svCurrent.fontSettings.categories.outline end,
					setFunc = function(categoryFontOutlineName) self.svCurrent.fontSettings.categories.outline = categoryFontOutlineName
						self.navigationTree:RefreshVisible()
					end,
				},
				[4] = {
					type = "slider",
					name = "Category Size",
					tooltip = "Choose a font size for category names.",
					min = 10,
					max = 24,
					step = 1,
					default = self.svCurrent.default.fontSettings.categories.size,
					getFunc = function() return self.svCurrent.fontSettings.categories.size end,
					setFunc = function(categoryFontSize) self.svCurrent.fontSettings.categories.size  = categoryFontSize 
						self.navigationTree:RefreshVisible() -- must be called first
						TryAutoSizeWidthAndHeight(self)
					end,
				},
				[5] = {
					type = "colorpicker",
					name = "Category Font Color",
					tooltip = "Change the color of category names.",
					default = DEFAULT_COLOR,
					getFunc = function() return unpack(self.svCurrent.fontSettings.categories.color) end,
					setFunc = function(r,g,b,a) self.svCurrent.fontSettings.categories.color = {r, g, b, a}						
						self.navigationTree:RefreshVisible()
					end,
				},
			},
		},
		[7] = {
			type = "submenu",
			name = "|c0066F0Quest Options",
			controls = {
				[1] = {
					type = "checkbox",
					name = "Show Quest Level",
					tooltip = "Display quest level before quest name?",
					default = false,
					getFunc = function() return self.svCurrent.showQuestLevel end,
					setFunc = function(showQuestLevel) self.svCurrent.showQuestLevel = showQuestLevel 
						self.navigationTree:RefreshVisible()
					end,
				},
				[2] = {
					type = "checkbox",
					name = "Sort Quests by Level",
					tooltip = "Sorts quests (per category) by level low to high.  If disabled, then the quests are sorted by the game's method.",
					default = true,
					getFunc = function() return self.svCurrent.sortByLevel end,
					setFunc = function(sortByLevel)
						self.svCurrent.sortByLevel = sortByLevel
						self:SortQuestNodes(sortByLevel)
					end,
				},				
				[3] = {
					type = "dropdown",
					name = "Chat Alerts",
					tooltip = "Puts a notification into the chat window when accepting quests.",
					choices = {"Off", "Short", "Detailed"},
					default = "Detailed",
					getFunc = function() return self.svCurrent.chatAlertType end,
					setFunc = function(chatAlertType) self.svCurrent.chatAlertType = chatAlertType						
					end,
				},
				[4] = {
                    type = "checkbox",
                    name = "Auto Track Added Quest",
                    tooltip = "When a quest is picked up that quest will be automatically selected.",
                    default = true,
                    getFunc = function() return self.svCurrent.questTrackForceAssist  end,
                    setFunc = function(bValue)
                        self.svCurrent.questTrackForceAssist = bValue
                        SetSetting(SETTING_TYPE_UI, UI_SETTING_AUTOMATIC_QUEST_TRACKING, bValue and "true" or "false")    -- V3.8.2.14 Calamath NOTE: Since update 38, the same settings have been added to Vanilla UI, so they are now linked.
                    end,
                    reference = "QUESTTRACKER_AUTOMATICTRACKADDEDQUEST",    -- V3.8.2.14 added
                },
				[5] = {
					type = "dropdown",
					name = "Quest Font",
					tooltip = "Choose a font for quest names.",
					choices = self:GetFontChoices(),
					default = self.svCurrent.default.fontSettings.quests.font,
					getFunc = function() return self.svCurrent.fontSettings.quests.font end,
					setFunc = function(questFontName) self.svCurrent.fontSettings.quests.font = questFontName
						self.navigationTree:RefreshVisible() -- must be called first
						TryAutoSizeWidthAndHeight(self)
					end,
				},
				[6] = {
					type = "dropdown",
					name = "Quest Font Effects",
					tooltip = "Choose a font outline effect for quest names",
					choices = self:GetOutlineChoices(),
					default = self.svCurrent.default.fontSettings.quests.outline,
					getFunc = function() return self.svCurrent.fontSettings.quests.outline end,
					setFunc = function(questFontOutlineName) self.svCurrent.fontSettings.quests.outline = questFontOutlineName
						self.navigationTree:RefreshVisible()
					end,
				},
				[7] = {
					type = "slider",
					name = "Quest Size",
					tooltip = "Choose a font size for Quest names.",
					min = 10,
					max = 24,
					step = 1,
					default = self.svCurrent.default.fontSettings.quests.size,
					getFunc = function() return self.svCurrent.fontSettings.quests.size end,
					setFunc = function(questFontSize) self.svCurrent.fontSettings.quests.size = questFontSize 
						self.navigationTree:RefreshVisible() -- must be called first
						TryAutoSizeWidthAndHeight(self)
					end,
				},
				[8] = {
					type = "checkbox",
					name = "Override Quest Con Colors",
					tooltip = "When OFF quest names will be assigned colors by quest difficulty. When ON you can override the con colors with your own preference.",
					default = false,
					getFunc = function() return self.svCurrent.overrideConColors end,
					setFunc = function(overrideConColors) self.svCurrent.overrideConColors = overrideConColors 
						self.navigationTree:RefreshVisible()
					end,
				},
				[9] = {
					type = "colorpicker",
					name = "Quest Font Color",
					tooltip = "Change the color of quest names.",
					default = DEFAULT_COLOR,
					disabled = function() return not self.svCurrent.overrideConColors end,
					getFunc = function() return unpack(self.svCurrent.fontSettings.quests.color) end,
					setFunc = function(r,g,b,a) self.svCurrent.fontSettings.quests.color  = {r,g,b,a} 
						self.navigationTree:RefreshVisible()
					end,
				},
			},
		},
		[8] = {
			type = "submenu",
			name = "|c0088F0Condition/Objective Options",
			controls = {
				[1] = {
					type = "dropdown",
					name = "Condition Font",
					tooltip = "Choose a font for quest conditions (steps).",
					choices = self:GetFontChoices(),
					default = self.svCurrent.default.fontSettings.conditions.font,
					getFunc = function() return self.svCurrent.fontSettings.conditions.font end,
					setFunc = function(conditionFontName) self.svCurrent.fontSettings.conditions.font = conditionFontName
						self.navigationTree:RefreshVisible() -- must be called first
						TryAutoSizeWidthAndHeight(self)
					end,
				},
				[2] = {
					type = "dropdown",
					name = "Condition Font Effects",
					tooltip = "Choose a font outline effect for condition names",
					choices = self:GetOutlineChoices(),
					default = self.svCurrent.default.fontSettings.conditions.outline,
					getFunc = function() return self.svCurrent.fontSettings.conditions.outline end,
					setFunc = function(conditionFontOutlineName) self.svCurrent.fontSettings.conditions.outline = conditionFontOutlineName
						self.navigationTree:RefreshVisible()
					end,
				},
				[3] = {
					type = "slider",
					name = "Condition Size",
					tooltip = "Choose a font size for Condition names.",
					min = 10,
					max = 24,
					step = 1,					
					default = self.svCurrent.default.fontSettings.conditions.size,
					getFunc = function() return self.svCurrent.fontSettings.conditions.size end,
					setFunc = function(conditionFontSize) self.svCurrent.fontSettings.conditions.size = conditionFontSize 
						self.navigationTree:RefreshVisible() -- must be called first
						TryAutoSizeWidthAndHeight(self)
					end,
				},
				[4] = {
					type = "colorpicker",
					name = "Condition Font Color",
					tooltip = "Change the color of condition names.",
					default = DEFAULT_COLOR,
					getFunc = function() return unpack(self.svCurrent.fontSettings.conditions.color) end,
					setFunc = function(r,g,b,a) self.svCurrent.fontSettings.conditions.color = {r,g,b,a} 
						self.navigationTree:RefreshVisible()
					end,
				},
			},
		},
	}
	LAM2:RegisterOptionControls("QuestTracker_Options", optionsData)
end