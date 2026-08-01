-------------------------------------------------------------------------------------------------
--  This file is used to create the settings menu panel --
-------------------------------------------------------------------------------------------------
local LAM2 = LibStub("LibAddonMenu-2.0")


-------------------------------------------------------------------------------------------------
--  Colors  --
-------------------------------------------------------------------------------------------------
local colorYellow 	= "|cFFFF00" 	-- Yellow
local colorRed 		= "|cFF0000" 	-- Red
local colorGreen 	= "|c00FF00" 	-- green
local colorWhite 	= "|cFFFFFF" 	-- white
local colorMagenta	= "|cFF00FF"	-- Magenta

--------------------------------------------------------------------
--  Available Fonts  --
--------------------------------------------------------------------
--<String name="MEDIUM_FONT" value="EsoUi/Common/Fonts/Univers57.otf" />

--------------------------------------------------------------------
--  Register Texture Packs  --
--------------------------------------------------------------------
local function GetTexturePackNames()
	local tPackNames = {}
	for k,v in pairs(LootIt.tTexturePacks) do
		table.insert(tPackNames, v.DisplayName)
	end
	return tPackNames
end

function LootIt.RegisterTexturePack(_TexturePackTable)
	if not _TexturePackTable then return false end
	local AddonName = _TexturePackTable.AddonName
	local DisplayName = _TexturePackTable.DisplayName
	
	if not (_TexturePackTable.AddonName and _TexturePackTable.DisplayName) then return false, "Texture Pack table is missing AddonName or DisplayName." end
	
	if LootIt.tTexturePacks[DisplayName] then return false, "Texture DisplayName already exists, belongs to addon "..LootIt.tTexturePacks[DisplayName].AddonName end

	LootIt.tTexturePacks[DisplayName] = _TexturePackTable
	
	-- This is for on load when packs should be registered
	-- If the registering pack is the last custom texture pack selected
	-- Set the new pack (the default pack is always loaded by default)
	if LootIt.SavedVariables["LASTCUSTOMTEXTUREPACK"] == DisplayName then
		LootIt.SetTexturePack(DisplayName)
	end
	-- if the dropdown control already exists, update its choices
	if LOOTIT_TEXTUREPACK_DROPDOWN then
		LOOTIT_TEXTUREPACK_DROPDOWN:UpdateChoices(GetTexturePackNames())
	end
	return true
end
function LootIt.UnRegisterTexturePack(_AddonName, _DisplayName)
	
	if not (_AddonName and _DisplayName) then return false, "AddonName or DisplayName Missing." end
	if not LootIt.tTexturePacks[_DisplayName] then return false, "Texture DisplayName does not exist." end
	if not LootIt.tTexturePacks[_DisplayName].AddonName == _AddonName then return false, "Texture DisplayName does not belong to AddonName." end
	
	LootIt.tTexturePacks[_DisplayName] = nil
	
	-- If were removing the current custom texture pack
	if LootIt.SavedVariables["LASTCUSTOMTEXTUREPACK"] == _DisplayName then
		-- Set the current texture pack to the "Default" texture pack
		LootIt.SetTexturePack("Default")
		LootIt.SavedVariables["LASTCUSTOMTEXTUREPACK"] = "Default"
		-- If the dropdown exists, update its selected value, else it will get updated
		-- automatically next time the panel is opened by getFunc
		if LOOTIT_TEXTUREPACK_DROPDOWN then
			LOOTIT_TEXTUREPACK_DROPDOWN:UpdateValue(false, "Default")
		end
	end
	if LOOTIT_TEXTUREPACK_DROPDOWN then
		LOOTIT_TEXTUREPACK_DROPDOWN:UpdateChoices(GetTexturePackNames())
	end
	return true
end
--*********************************************************************************************--
-------------------------------------------------------------------------------------------------
--  Create Menu --
-------------------------------------------------------------------------------------------------
--*********************************************************************************************--
function LootIt.CreateSettingsMenu()
	local panelData = {
		type = "panel",
		name = LootIt.name,
		displayName = "|cFF0000 Circonians |c00FFFF LootIt",
		author = "Circonian",
		version = LootIt.RealVersion,
		slashCommand = "/lootit",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Circonians_LootIt_Options", panelData)
	
	local optionsData = {
-- Display looted items	
		[1] = {
			type = "submenu",
			name = "General Settings",
			controls = {
				[1] = {
					type = "description",
					text = colorYellow.."These options allow you to adjust various settings for the addon.",
				},	
				[2] = {
					type = "checkbox",
					name = "Unlock Loot Window (Make It Moveable)",
					tooltip = "Makes the loot window moveable and displays a background image to help with positioning.",
					default = false,
					getFunc = function() return LootIt.SavedVariables["SHOWLOOTWINDOW"] end,
					setFunc = function(bValue) LootIt.SavedVariables["SHOWLOOTWINDOW"] = bValue
						LootIt.ShowLootWindow(bValue) end,
				},
				[3] = {
					type = "dropdown",
					name = "Loot Direction",
					tooltip = "Select if you want the loot to translate UP, DOWN, LEFT, or RIGHT on the screen.",
					choices = {"Up", "Down", "Left", "Right"},
					default = "Down",
					getFunc = function() return LootIt.SavedVariables["LOOTDIRECTION"] end,
					setFunc = function(sValue) LootIt.SavedVariables["LOOTDIRECTION"] = sValue end,
				},
				[4] = {
					type = "description",
					text = colorYellow.."If you make the font size larger you can increase the width of the window to make all of the text visible or you can increase the window height and the text will wrap down to the next line.",
				},	
				[5] = {
					type = "description",
					text = colorYellow.."If you choose to lower the window width you may need to decrease the font size or increase the window height to get all of the text to fit in the window.",
				},	
				[6] = {
					type = "description",
					text = colorRed.."Do be aware the larger you make the windows less windows will fit on the screen & some windows could potentially scroll off the screen out of view if you loot a lot of items fast enough or get a lot of xp gains quickly.",
				},	
				[7] = {
					type = "slider",
					name = "Width",
					tooltip = "Changes the width of the loot window.",
					min = 100,
					max = 300,
					step = 1,
					default = 200,
					getFunc = function() return LootIt.SavedVariables["LOOTWINDOWWIDTH"] end,
					setFunc = function(iValue) LootIt.SavedVariables["LOOTWINDOWWIDTH"] = iValue 
						local winWidth = LootIt.SavedVariables["LOOTWINDOWWIDTH"]
						local winHeight = LootIt.SavedVariables["LOOTWINDOWHEIGHT"]
						LootIt.LootWindow:SetDimensions(winWidth, winHeight)
						end,
				},
				[8] = {
					type = "slider",
					name = "Height",
					tooltip = "Changes the Height of the loot window.",
					min = 32,
					max = 64,
					step = 1,
					default = 32,
					getFunc = function() return LootIt.SavedVariables["LOOTWINDOWHEIGHT"] end,
					setFunc = function(iValue) LootIt.SavedVariables["LOOTWINDOWHEIGHT"] = iValue 
						local winWidth = LootIt.SavedVariables["LOOTWINDOWWIDTH"]
						local winHeight = LootIt.SavedVariables["LOOTWINDOWHEIGHT"]
						LootIt.LootWindow:SetDimensions(winWidth, winHeight)
						end,
				},
				[9] = {
					type = "slider",
					name = "Font Size",
					tooltip = "Changes the Font Size of the text.",
					min = 12,
					max = 24,
					step = 1,
					default = 16,
					getFunc = function() return LootIt.SavedVariables["FONTSIZE"] end,
					setFunc = function(iValue) LootIt.SavedVariables["FONTSIZE"] = iValue end,
				},
				[10] = {
					type = "dropdown",
					name = "Text Font",
					tooltip = "Allows you to change the font for the text displayed in the loot window.",
					choices = {"Antique", "Bold", "Chat", "Handwritten", "Stone Tablet"},
					default = "Down",
					getFunc = function() return LootIt.SavedVariables["FONT"] end,
					setFunc = function(sValue) LootIt.SavedVariables["FONT"] = sValue end,
				},
			},
		},
-- Display looted items	
		[2] = {
			type = "submenu",
			name = "Display Options",
			controls = {
				[1] = {
					type = "description",
					text = colorYellow.."These options allow you to choose what events you would like to see displayed in the loot window.",
				},
				[2] = {
					type = "checkbox",
					name = "Show Items Looted",
					tooltip = "Show items you loot in the display window.",
					default = true,
					getFunc = function() return LootIt.SavedVariables["SHOWITEMSLOOTED"] end,
					setFunc = function(sValue) LootIt.SavedVariables["SHOWITEMSLOOTED"] = sValue end,
				},
				[3] = {
					type = "checkbox",
					name = "Show Item Quantities",
					tooltip = "Show the number of each item you pick up (if there is more than one).",
					default = false,
					getFunc = function() return LootIt.SavedVariables["SHOWITEMQUANITY"] end,
					setFunc = function(sValue) LootIt.SavedVariables["SHOWITEMQUANITY"] = sValue end,
				},
				[4] = {
					type = "checkbox",
					name = "Show Gold Gained/Lost",
					tooltip = "Show gold gained and lost in the display window.",
					default = false,
					getFunc = function() return LootIt.SavedVariables["SHOWGOLDGAINLOSS"] end,
					setFunc = function(sValue) LootIt.SavedVariables["SHOWGOLDGAINLOSS"] = sValue end,
				},
				[5] = {
					type = "checkbox",
					name = "Show Character XP Gains",
					tooltip = "Show xp gains towards your next character level in the display window.",
					default = false,
					getFunc = function() return LootIt.SavedVariables["SHOWCHARXPGAINS"] end,
					setFunc = function(sValue) LootIt.SavedVariables["SHOWCHARXPGAINS"] = sValue end,
				},
				[6] = {
					type = "checkbox",
					name = "Show Skill XP Gains",
					tooltip = "Show xp gained in skill lines in the display window.",
					default = false,
					getFunc = function() return LootIt.SavedVariables["SHOWSKILLXPGAINS"] end,
					setFunc = function(sValue) LootIt.SavedVariables["SHOWSKILLXPGAINS"] = sValue end,
				},
				[7] = {
					type = "checkbox",
					name = "Show Ability XP Gains",
					tooltip = "Show xp gained in abilities in the display window.",
					default = false,
					getFunc = function() return LootIt.SavedVariables["SHOWABILITYXPGAINS"] end,
					setFunc = function(sValue) LootIt.SavedVariables["SHOWABILITYXPGAINS"] = sValue end,
				},
				[8] = {
					type = "checkbox",
					name = "Show Ability/Skill Names",
					tooltip = "Show Ability & Skill names in window with XP gains. The corresponding skill or ability XP Gains must be turned on.",
					default = false,
					getFunc = function() return LootIt.SavedVariables["SHOWABILITYSKILLNAMES"] end,
					setFunc = function(sValue) LootIt.SavedVariables["SHOWABILITYSKILLNAMES"] = sValue end,
				},
			},
		},
		
		[3] = {
			type = "submenu",
			name = "Animation Settings",
			controls = {
				[1] = {
					type = "description",
					text = colorYellow.."These options allow you to adjust the animation settings for how items appear on your screen allowing you to choose if you want them to pop up & disappear quickly or slowly.",
				},
				[2] = {
					type = "slider",
					name = "Fade In",
					tooltip = "Changes the amount of time it takes for items to fade in (to become visible on the screen).",
					min = 1,
					max = 20,
					step = 1,
					default = 5,
					getFunc = function() return LootIt.SavedVariables["ITEMFADEINTIME"]/10 end,
					setFunc = function(iValue) LootIt.SavedVariables["ITEMFADEINTIME"] = iValue*10 end,
				},
				[3] = {
					type = "slider",
					name = "Visibility Time",
					tooltip = "Changes the amount of time items are displayed on the screen before starting to fade out.",
					min = 1,
					max = 20,
					step = 1,
					default = 7,
					getFunc = function() return LootIt.SavedVariables["ITEMVISIBLETIME"]/1000 end,
					setFunc = function(iValue) LootIt.SavedVariables["ITEMVISIBLETIME"] = iValue*1000 end,
				},
				[4] = {
					type = "slider",
					name = "Translation Time",
					tooltip = "Changes the amount of time it takes items to translate (move left, right, up down) to get to their correct position on the screen.",
					min = 1,
					max = 20,
					step = 1,
					default = 7,
					getFunc = function() return LootIt.SavedVariables["ITEMTRANSLATETIME"]/100 end,
					setFunc = function(iValue) LootIt.SavedVariables["ITEMTRANSLATETIME"] = iValue*100 end,
				},
				[5] = {
					type = "slider",
					name = "Fade Duration",
					tooltip = "Changes the amount of time it takes for items to fade out after they start to fade.",
					min = 1,
					max = 20,
					step = 1,
					default = 3,
					getFunc = function() return LootIt.SavedVariables["ITEMFADEDURATION"]/100 end,
					setFunc = function(iValue) LootIt.SavedVariables["ITEMFADEDURATION"] = iValue*100 end,
				},
			},
		},
		[4] = {
			type = "submenu",
			name = "Textures Packs",
			controls = {
				[1] = {
					type = "description",
					text = colorYellow.."Other addons can register texture packs with this addon allowing custom textures in the loot window. If you do not have an addon that is registering a custom texture pack there will only be one option.",
				},
				[2] = {
				type = "dropdown",
					name = "Select a Texture Pack",
					tooltip = "Select the texture pack you wish to use.",
					choices = GetTexturePackNames(),
					default = "Default",
					getFunc = function()
						LOOTIT_TEXTUREPACK_DROPDOWN:UpdateChoices(GetTexturePackNames())
						return LootIt.SavedVariables["LASTCUSTOMTEXTUREPACK"]
						end,
					setFunc = function(sValue) LootIt.SavedVariables["LASTCUSTOMTEXTUREPACK"] = sValue 
						LootIt.SetTexturePack(sValue)
						end,
					reference = "LOOTIT_TEXTUREPACK_DROPDOWN",
				},
			},
		},
	}

	LAM2:RegisterOptionControls("Circonians_LootIt_Options", optionsData)
end


