
local LAM2 = LibStub("LibAddonMenu-2.0")
local libFonts = LibStub:GetLibrary("LibFonts")

local colorYellow 		= "|cFFFF00" 	-- yellow 
local colorRed 			= "|cFF0000" 	-- Red

--[[ These should really be changed to 
TYPE_BUFF, TYPE_DEBUFF, TYPE_ALERT_BUFF, TYPE_ALERT_PROC
I should assign those to self: self.types = { ...} then use self.types.... here
--]]
local BARTYPE_BUFFS			= 1
local BARTYPE_DEBUFFS		= 2
local BARTYPE_ALERT_BUFFS	= 3
local BARTYPE_ALERT_PROCS	= 4

local alertSounds = {
	"None",
	SOUNDS.DEATH_RECAP_KILLING_BLOW_SHOWN,
	SOUNDS.DEATH_RECAP_ATTACK_SHOWN,
	SOUNDS.BOOK_COLLECTION_COMPLETED,
	SOUNDS.INVENTORY_ITEM_APPLY_CHARGE,
	SOUNDS.RAID_TRIAL_COMPLETED,
	SOUNDS.SKILL_GAINED,
	SOUNDS.SKILL_LINE_ADDED,
	SOUNDS.SKILL_LINE_LEVELED_UP,
	SOUNDS.JUSTICE_NOW_KOS,
	SOUNDS.ACHIEVEMENT_AWARDED,
	SOUNDS.ABILITY_ULTIMATE_READY,
}
	
local function GetAlignLeftChoices(growthDirection)
	local choices = {"Left", "Right"} 
	local default	= "Left"
	
	if growthDirection == "Left" then
		return "Right", "Right"
	elseif growthDirection == "Right" then
		return "Left", "Left"
	end
	
	return choices, default
end
local function DisableAlignLeftSetting(direction)
	if direction == "Left" or direction == "Right" then
		return true
	end
	return false
end



local function SetAlignmentSide(layoutData, sAlignment)
	if sAlignment == "Right" then
		layoutData.horizontalAlignment = RIGHT

	else
		layoutData.horizontalAlignment = LEFT
	end
end


local function SetGrowthDirection(layoutData, direction)
	if direction == "Up" then
		layoutData.verticalAlignment 	= BOTTOM
		layoutData.vertical 			= true

	elseif direction == "Down" then
		layoutData.verticalAlignment 	= TOP
		layoutData.vertical				= true
		
	elseif direction == "Left" then
		layoutData.verticalAlignment 	= TOP
		layoutData.vertical 			= false
		SetAlignmentSide(layoutData, "Right")
		
	else	--if sValue == "Right" then
		layoutData.verticalAlignment 	= TOP
		layoutData.vertical 			= false
		SetAlignmentSide(layoutData, "Left")
	end
end

-------------------------------------------------------------------------------------------------
--  Settings Menu --
-------------------------------------------------------------------------------------------------
function BuffTracker_CreateSettingsMenu(self)
	local panelData = {
		type = "panel",
		name = "BuffTracker",
		displayName = "|cFF0000 Circonians |c00FFFF BuffTracker",
		author = "Circonian",
		version = self.codeVersion,
		slashCommand = "/bufftracker",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("Circonians_BuffTracker_Options", panelData)
	
	local buffBar 		= self.bars[BARTYPE_BUFFS]
	local debuffBar 	= self.bars[BARTYPE_DEBUFFS]
	local buffAlertBar 	= self.bars[BARTYPE_ALERT_BUFFS]
	local buffProcBar 	= self.bars[BARTYPE_ALERT_PROCS]
	
	local buffBarLayout 		= self.sv.layout[BARTYPE_BUFFS]
	local debuffBarLayout 		= self.sv.layout[BARTYPE_DEBUFFS]
	local buffAlertBarLayout 	= self.sv.layout[BARTYPE_ALERT_BUFFS]
	local buffProcBarLayout 	= self.sv.layout[BARTYPE_ALERT_PROCS]
	
	local timerSettings 		= self.sv.timerSettings
	local alertSoundSettings 	= self.sv.alertSoundSettings
	local radialCooldownSettings= self.sv.radialCooldown
	
	local optionsData = {
		[1] = {
			type = "submenu",
			name = "General",
			controls = {
				{
					type = "checkbox",
					name = "Hide Blocking Buff Icon",
					tooltip = "Hides the blocking buff icon that is displayed when you block.",
					default = true,
					getFunc = function() return self.sv.hideBlockingBuff end,
					setFunc = function(shouldHide) self.sv.hideBlockingBuff = shouldHide
					end,
				},
				{
					type = "checkbox",
					name = "Hide Text Timers",
					tooltip = "Show/Hide the text timers that display on the icons showing you how much time you have left on a buff/debuff.",
					default = true,
					getFunc = function() return timerSettings.hideTextTimer end,
					setFunc = function(shouldHide) timerSettings.hideTextTimer = shouldHide
						self:HideTextTimers(shouldHide)
					end,
				},
				{
					type = "dropdown",
					name = "Text Timer Font",
					tooltip = "Choose a font for the Text Timer.",
					choices = libFonts:GetFontChoices(),
					default = self.DEFAULT_FONT_NAME,
					disabled = function() return timerSettings.hideTextTimer end,
					getFunc = function() return timerSettings.fontName end,
					setFunc = function(timerFontName) timerSettings.fontName = timerFontName
						local fontSize		= timerSettings.fontSize
						local font			= libFonts:GetFontByName(timerFontName)
						local outline		= libFonts:GetFontOutlineByName(timerSettings.fontOutline)
						local fontString 	= libFonts:BuildFontString(font, fontSize, outline)
						timerSettings.fontString = fontString
						self:ResetTimerFonts(fontString)
					end,
				},
				{
					type = "dropdown",
					name = "Text Timer Font Outline",
					tooltip = "Choose a font outline for the Text Timer.",
					choices = libFonts:GetFontOutlineChoices(),
					default = "None",
					disabled = function() return timerSettings.hideTextTimer end,
					getFunc = function() return timerSettings.fontOutline end,
					setFunc = function(fontOutline) timerSettings.fontOutline = fontOutline
						local fontSize		= timerSettings.fontSize
						local font			= libFonts:GetFontByName(timerSettings.fontName)
						local outline		= libFonts:GetFontOutlineByName(fontOutline)
						local fontString 	= libFonts:BuildFontString(font, fontSize, outline)
						timerSettings.fontString = fontString
						self:ResetTimerFonts(fontString)
					end,
				},
				{
					type = "slider",
					name = "Text Timer Font Size",
					tooltip = "Choose a font size for the Text Timer.",
					min = 10,
					max = 45,
					step = 1,
					default = self.DEFAULT_FONT_SIZE,
					disabled = function() return timerSettings.hideTextTimer end,
					getFunc = function() return timerSettings.fontSize end,
					setFunc = function(timerFontSize) timerSettings.fontSize  = timerFontSize 
						local font			= libFonts:GetFontByName(timerSettings.fontName)
						local outline		= libFonts:GetFontOutlineByName(timerSettings.fontOutline)
						local fontString 	= libFonts:BuildFontString(font, timerFontSize, outline)
						timerSettings.fontString = fontString
						self:ResetTimerFonts(fontString)
					end,
				},
				{
					type = "colorpicker",
					name = "Text Timer Font Color",
					tooltip = "Change the color of the Text Timer.",
					default = self.DEFAULT_FONT_COLOR_RESET,
					disabled = function() return timerSettings.hideTextTimer end,
					getFunc = function() return unpack(timerSettings.fontColor) end,
					setFunc = function(r,g,b,a) timerSettings.fontColor = {r, g, b, a} 
						self:ResetTimerColors(r,g,b)
					end,
				},
				{
					type = "dropdown",
					name = "Proc Alert Sound",
					tooltip = "This sound will be played when a proc alert occurs.",
					choices = alertSounds,
					default = "None",
					getFunc = function() return alertSoundSettings.procAlertSound end,
					setFunc = function(sValue) alertSoundSettings.procAlertSound = sValue
						PlaySound(sValue)
					end,
				},
				{
					type = "dropdown",
					name = "Buff Alert Sound",
					tooltip = "This sound will be played when a buff alert occurs.",
					choices = alertSounds,
					default = "None",
					getFunc = function() return alertSoundSettings.buffAlertSound end,
					setFunc = function(sValue) alertSoundSettings.buffAlertSound = sValue
						PlaySound(sValue)
					end,
				},
				{
					type = "slider",
					name = "Buff Alert Sound Time Offset",
					tooltip = "Allows the buff alert sound to be played before the buff actually removed to give you time to rebuff. When set to 0 the sound will not play until after the buff is removed. If set to 5 the sound will play 5 seconds before the buff wears off.\n\nThis only applies to buffs with a duration. For any other buff alert the sound will play when the buff is removed.",
					min = 0,
					max = 5,
					step = 1,
					default = 0,
					getFunc = function() return alertSoundSettings.buffAlertSoundOffset end,
					setFunc = function(iValue) alertSoundSettings.buffAlertSoundOffset = iValue 
					end,
				},
				{
					type = "colorpicker",
					name = "Cooldown Radial Color/Alpha",
					tooltip = "Change the color of the radial cooldown timer.",
					default = {r=0, g=1, b=0, a=0.75},
					getFunc = function() return unpack(radialCooldownSettings.color) end,
					setFunc = function(r,g,b,a) radialCooldownSettings.color = {r, g, b, a} 
						self:SetCooldownRadialColor(r,g,b,a)
					end,
				},
				{
					type = "checkbox",
					name = "Cooldown Radial/Border",
					tooltip = "When ON it shows the radial cooldown on top of icons shading them in a circular pattern. When OFF it will fill in the border around the icon.",
					default = false,
					getFunc = function() return radialCooldownSettings.overlayIcon end,
					setFunc = function(overlayOnTop) radialCooldownSettings.overlayIcon = overlayOnTop
						-- can't just change the tier, must reanchor the buffs also due to size changes
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_BUFFS)
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_DEBUFFS)
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_BUFFS)
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_PROCS)
					end,
				},
				{
					type = "slider",
					name = "Cooldown Border Thickness",
					tooltip = "The Cooldown Radial/Border setting must be OFF. Adjusts the thickness of the cooldown border that fills in around the icon.",
					min = 4,
					max = 10,
					step = 1,
					default = 6,
					disabled = function() return radialCooldownSettings.overlayIcon end,
					getFunc = function() return radialCooldownSettings.lineWidth end,
					setFunc = function(iValue) radialCooldownSettings.lineWidth = iValue 
						-- must reanchor the buffs also due to size changes, lineWidth is included in the icon size
						-- so increasing the lineWidth actually shrinks the icons.
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_BUFFS)
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_DEBUFFS)
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_BUFFS)
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_PROCS)
					end,
				},
			},
		},
		[2] = {
			type = "submenu",
			name = "Buff Bar",
			controls = {
				{
					type = "description",
					text = colorYellow.."The buff bar displays all buffs you currently have on you.",
				},
				{
					type = "checkbox",
					name = "Enable Bar",
					tooltip = "Turns the bar ON/OFF.",
					default = true,
					getFunc = function() return buffBarLayout.enabled end,
					setFunc = function(bValue) buffBarLayout.enabled = bValue
						local buffBarFragment = self.barFragments[BARTYPE_BUFFS]
						buffBarFragment:SetHiddenForReason("UserDisabled", not bValue)
					end,
				},
				{
					type = "checkbox",
					name = "Hide Bar Title",
					tooltip = "Show/Hide the bar titles.",
					default = false,
					getFunc = function() return buffBarLayout.hideTitle end,
					setFunc = function(bValue) buffBarLayout.hideTitle = bValue
						-- Due to resizeToFitDescendents & the anchor OffsetY for icons
						-- hiding this throws the last icon half-way outside of the window making click-dragging
						-- a bit troubling. I'm cheating with an easy fix, instead of hiding, just set alpha to 0
						-- that doesn't effect the window size so everything works fine and the title backdrop is 
						-- so small, its not going to hurt anything.
						--buffBar.backdrop:SetHidden(bValue)
						local alpha = bValue and 0 or 1
						buffBar.backdrop:SetAlpha(alpha)
					end,
				},
				{
					type = "checkbox",
					name = "Unlock Bar",
					tooltip = "Unlock the bar so you can move it around the screen.",
					default = true,
					getFunc = function() return buffBarLayout.unlocked end,
					setFunc = function(bValue) buffBarLayout.unlocked = bValue
						buffBar:SetMouseEnabled(bValue)
					end,
				},
				{
					type = "slider",
					name = "Icon Size",
					tooltip = "Adjust size of the icons.",
					min = 32,
					max = 64,
					step = 1,
					default = 64,
					getFunc = function() return buffBarLayout.iconSize end,
					setFunc = function(iValue) buffBarLayout.iconSize = iValue 
						-- no longer used, its anchored to resizewhen the template changes sizes
						--buffBarLayout.textureSize = iValue - self.DEFAULT_TEXTURE_PADDING
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_BUFFS)
					end,
				},
				{
					type = "dropdown",
					name = "Growth Direction",
					tooltip = "New Icons will be added to the bar in this direction.",
					choices = {"Up", "Down", "Left", "Right"},
					default = "Down",
					getFunc = function() return buffBarLayout.direction end,
					setFunc = function(sValue) buffBarLayout.direction = sValue
						if sValue == "Left" or sValue == "Right" then
							local choices, default = GetAlignLeftChoices(sValue)
							BUFFTRACKER_BUFFBAR_ALIGNLEFT:UpdateChoices(choices)
							BUFFTRACKER_BUFFBAR_ALIGNLEFT:UpdateValue(false, default)
						end
						
						SetGrowthDirection(buffBarLayout, sValue)
						self:SaveBarPosition(buffBar)
						
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_BUFFS)
					end,
				},
				{
					type = "dropdown",
					name = "Horizontal Alignment",
					tooltip = "When growth direction is Up or Down this can be adjusted for placement on the left or right side of the screen. Left will align the left side of the icons & ability names will appear on the right. Right will align the right side of the icons & ability names will appear on the left.",
					choices = GetAlignLeftChoices(buffBarLayout.direction),
					default = "Left",
					disabled = function() return DisableAlignLeftSetting(buffBarLayout.direction) end,
					getFunc = function() 
						if buffBarLayout.horizontalAlignment == LEFT then return "Left" else return "Right" end
					end,
					setFunc = function(sValue)
						SetAlignmentSide(buffBarLayout, sValue)
						self:SaveBarPosition(buffBar)
						
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_BUFFS)
					end,
					reference = "BUFFTRACKER_BUFFBAR_ALIGNLEFT",
				},
				{
					type = "checkbox",
					name = "Display Ability Names buff",
					tooltip = "Growth direction must be Up or Down to display ability names.",
					default = true,
					disabled = function() return not buffBarLayout.vertical end,
					--disabled = function() return true end,
					getFunc = function() return buffBarLayout.showNames end,
					setFunc = function(bValue) 
						buffBarLayout.showNames = bValue 
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_BUFFS)
					end,
				},
				{
					type = "dropdown",
					name = "Ability Name Font",
					tooltip = "Choose a font for ability names.",
					choices = libFonts:GetFontChoices(),
					default = self.DEFAULT_FONT_NAME,
					disabled = function() return not buffBarLayout.vertical end,
					getFunc = function() return buffBarLayout.fontName end,
					setFunc = function(buffFontName) buffBarLayout.fontName = buffFontName
						local fontSize		= buffBarLayout.fontSize
						local font			= libFonts:GetFontByName(buffFontName)
						local outline		= libFonts:GetFontOutlineByName(buffBarLayout.fontOutline)
						local fontString 	= libFonts:BuildFontString(font, fontSize, outline)
						buffBarLayout.fontString = fontString
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_BUFFS)
					end,
				},
				{
					type = "dropdown",
					name = "Ability Name Font Outline",
					tooltip = "Choose a font outline for the Ability Names.",
					choices = libFonts:GetFontOutlineChoices(),
					default = "None",
					disabled = function() return not buffBarLayout.vertical end,
					getFunc = function() return buffBarLayout.fontOutline end,
					setFunc = function(fontOutline) buffBarLayout.fontOutline = fontOutline
						local fontSize		= buffBarLayout.fontSize
						local font			= libFonts:GetFontByName(buffBarLayout.fontName)
						local outline		= libFonts:GetFontOutlineByName(fontOutline)
						local fontString 	= libFonts:BuildFontString(font, fontSize, outline)
						buffBarLayout.fontString = fontString
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_BUFFS)
					end,
				},
				{
					type = "slider",
					name = "Ability Name Font Size",
					tooltip = "Choose a font size for ability names.",
					min = 10,
					max = 32,
					step = 1,
					default = self.DEFAULT_FONT_SIZE,
					disabled = function() return not buffBarLayout.vertical end,
					getFunc = function() return buffBarLayout.fontSize end,
					setFunc = function(buffFontSize) buffBarLayout.fontSize  = buffFontSize 
						local font			= libFonts:GetFontByName(buffBarLayout.fontName)
						local outline		= libFonts:GetFontOutlineByName(buffBarLayout.fontOutline)
						local fontString 	= libFonts:BuildFontString(font, buffFontSize, outline)
						buffBarLayout.fontString = fontString
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_BUFFS)
					end,
				},
				{
					type = "colorpicker",
					name = "Ability Name Font Color",
					tooltip = "Change the color of ability names.",
					default = self.DEFAULT_FONT_COLOR_RESET,
					disabled = function() return not buffBarLayout.vertical end,
					getFunc = function() return unpack(buffBarLayout.fontColor) end,
					setFunc = function(r,g,b,a) buffBarLayout.fontColor = {r, g, b, a} 
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_BUFFS)
					end,
				},
			},
		},
		[3] = {
			type = "submenu",
			name = "Debuff Bar",
			controls = {
				[1] = {
					type = "description",
					text = colorYellow.."The debuff bar displays all debuffs you currently have on you."
				},
				[2] = {
					type = "checkbox",
					name = "Enable Bar",
					tooltip = "Turns the bar ON/OFF.",
					default = true,
					getFunc = function() return debuffBarLayout.enabled end,
					setFunc = function(bValue) debuffBarLayout.enabled = bValue
						local debuffBarFragment = self.barFragments[BARTYPE_DEBUFFS]
						debuffBarFragment:SetHiddenForReason("UserDisabled", not bValue)
					end,
				},
				[3] = {
					type = "checkbox",
					name = "Hide Bar Title",
					tooltip = "Show/Hide the bar title.",
					default = false,
					getFunc = function() return debuffBarLayout.hideTitle end,
					setFunc = function(bValue) debuffBarLayout.hideTitle = bValue
						-- See note in first buff bar setting for why:
						--buffBar.backdrop:SetHidden(bValue)
						local alpha = bValue and 0 or 1
						debuffBar.backdrop:SetAlpha(alpha)
					end,
				},
				[4] = {
					type = "checkbox",
					name = "Unlock Bar",
					tooltip = "Unlock the bar so you can move it around the screen.",
					default = true,
					getFunc = function() return debuffBarLayout.unlocked end,
					setFunc = function(bValue) debuffBarLayout.unlocked = bValue
						debuffBar:SetMouseEnabled(bValue)
					end,
				},
				[5] = {
					type = "slider",
					name = "Icon Size",
					tooltip = "Adjust size of the icons.",
					min = 32,
					max = 64,
					step = 1,
					default = 64,
					getFunc = function() return debuffBarLayout.iconSize end,
					setFunc = function(iValue) debuffBarLayout.iconSize = iValue 
						-- no longer used, its anchored to resizewhen the template changes sizes
						--debuffBarLayout.textureSize = iValue - self.DEFAULT_TEXTURE_PADDING
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_DEBUFFS)
					end,
				},
				[6] = {
					type = "dropdown",
					name = "Growth Direction",
					tooltip = "New Icons will be added to the bar in this direction.",
					choices = {"Up", "Down", "Left", "Right"},
					default = "Down",
					getFunc = function() return debuffBarLayout.direction end,
					setFunc = function(sValue) debuffBarLayout.direction = sValue
						if sValue == "Left" or sValue == "Right" then
							local choices, default = GetAlignLeftChoices(sValue)
							BUFFTRACKER_DEBUFFBAR_ALIGNLEFT:UpdateChoices(choices)
							BUFFTRACKER_DEBUFFBAR_ALIGNLEFT:UpdateValue(false, default)
						end
						
						SetGrowthDirection(debuffBarLayout, sValue)
						self:SaveBarPosition(debuffBar)
						
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_DEBUFFS)
					end,
				},
				[7] = {
					type = "dropdown",
					name = "Horizontal Alignment",
					tooltip = "When growth direction is Up or Down this can be adjusted for placement on the left or right side of the screen. Left will align the left side of the icons & ability names will appear on the right. Right will align the right side of the icons & ability names will appear on the left.",
					choices = GetAlignLeftChoices(debuffBarLayout.direction),
					default = "Left",
					disabled = function() return DisableAlignLeftSetting(debuffBarLayout.direction) end,
					getFunc = function() 
						if debuffBarLayout.horizontalAlignment == LEFT then return "Left" else return "Right" end
					end,
					setFunc = function(sValue)
						SetAlignmentSide(debuffBarLayout, sValue)
						self:SaveBarPosition(debuffBar)
						
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_DEBUFFS)
					end,
					reference = "BUFFTRACKER_DEBUFFBAR_ALIGNLEFT",
				},
				[8] = {
					type = "checkbox",
					name = "Display Ability Names",
					tooltip = "Growth direction must be Up or Down to display ability names.",
					default = true,
					disabled = function() return not debuffBarLayout.vertical end,
					getFunc = function() return debuffBarLayout.showNames end,
					setFunc = function(bValue) debuffBarLayout.showNames = bValue 
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_DEBUFFS) end,
				},
				[9] = {
					type = "dropdown",
					name = "Ability Name Font",
					tooltip = "Choose a font for ability names.",
					choices = libFonts:GetFontChoices(),
					default = self.DEFAULT_FONT_NAME,
					disabled = function() return not debuffBarLayout.vertical end,
					getFunc = function() return debuffBarLayout.fontName end,
					setFunc = function(debuffFontName) debuffBarLayout.fontName = debuffFontName
						local fontSize		= debuffBarLayout.fontSize
						local font			= libFonts:GetFontByName(debuffFontName)
						local outline		= libFonts:GetFontOutlineByName(debuffBarLayout.fontOutline)
						local fontString 	= libFonts:BuildFontString(font, fontSize, outline)
						debuffBarLayout.fontString = fontString
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_DEBUFFS)
					end,
				},
				[10] = {
					type = "dropdown",
					name = "Ability Name Font Outline",
					tooltip = "Choose a font outline for the Ability Names.",
					choices = libFonts:GetFontOutlineChoices(),
					default = "None",
					disabled = function() return not debuffBarLayout.vertical end,
					getFunc = function() return debuffBarLayout.fontOutline end,
					setFunc = function(fontOutline) debuffBarLayout.fontOutline = fontOutline
						local fontSize		= debuffBarLayout.fontSize
						local font			= libFonts:GetFontByName(debuffBarLayout.fontName)
						local outline		= libFonts:GetFontOutlineByName(fontOutline)
						local fontString 	= libFonts:BuildFontString(font, fontSize, outline)
						debuffBarLayout.fontString = fontString
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_DEBUFFS)
					end,
				},
				[11] = {
					type = "slider",
					name = "Ability Name Font Size",
					tooltip = "Choose a font size for ability names.",
					min = 10,
					max = 32,
					step = 1,
					default = self.DEFAULT_FONT_SIZE,
					disabled = function() return not debuffBarLayout.vertical end,
					getFunc = function() return debuffBarLayout.fontSize end,
					setFunc = function(buffFontSize) debuffBarLayout.fontSize  = buffFontSize 
						local font			= libFonts:GetFontByName(debuffBarLayout.fontName)
						local outline		= libFonts:GetFontOutlineByName(debuffBarLayout.fontOutline)
						local fontString 	= libFonts:BuildFontString(font, buffFontSize, outline)
						debuffBarLayout.fontString = fontString
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_DEBUFFS)
					end,
				},
				[12] = {
					type = "colorpicker",
					name = "Ability Name Font Color",
					tooltip = "Change the color of ability names.",
					default = self.DEFAULT_FONT_COLOR_RESET,
					disabled = function() return not debuffBarLayout.vertical end,
					getFunc = function() return unpack(debuffBarLayout.fontColor) end,
					setFunc = function(r,g,b,a) debuffBarLayout.fontColor = {r, g, b, a} 
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_DEBUFFS)
					end,
				},
			},
		},
		[4] = {
			type = "submenu",
			name = "Buff Alert Bar",
			controls = {
				[1] = {
					type = "description",
					text = colorYellow.."The buff alert bar will display all effects, that you have set a buff alert for, that you do NOT currently have on you. This is used to remind you to buff."
				},
				[2] = {
					type = "checkbox",
					name = "Enable Bar",
					tooltip = "Turns the bar ON/OFF.",
					default = true,
					getFunc = function() return buffAlertBarLayout.enabled end,
					setFunc = function(bValue) buffAlertBarLayout.enabled = bValue
						local buffAlertBarFragment = self.barFragments[BARTYPE_ALERT_BUFFS]
						buffAlertBarFragment:SetHiddenForReason("UserDisabled", not bValue)
					end,
				},
				[3] = {
					type = "checkbox",
					name = "Hide Bar Title",
					tooltip = "Show/Hide the bar title.",
					default = false,
					getFunc = function() return buffAlertBarLayout.hideTitle end,
					setFunc = function(bValue) buffAlertBarLayout.hideTitle = bValue
						-- See note in first buff bar setting for why:
						--buffBar.backdrop:SetHidden(bValue)
						local alpha = bValue and 0 or 1
						buffAlertBar.backdrop:SetAlpha(alpha)
					end,
				},
				[4] = {
					type = "checkbox",
					name = "Unlock Bar",
					tooltip = "Unlock the bar so you can move it around the screen.",
					default = true,
					getFunc = function() return buffAlertBarLayout.unlocked end,
					setFunc = function(bValue) buffAlertBarLayout.unlocked = bValue
						buffAlertBar:SetMouseEnabled(bValue)
					end,
				},
				[5] = {
					type = "slider",
					name = "Icon Size",
					tooltip = "Adjust size of the icons.",
					min = 32,
					max = 64,
					step = 1,
					default = 64,
					getFunc = function() return buffAlertBarLayout.iconSize end,
					setFunc = function(iValue) buffAlertBarLayout.iconSize = iValue 
						-- no longer used, its anchored to resizewhen the template changes sizes
						--buffAlertBarLayout.textureSize = iValue - self.DEFAULT_TEXTURE_PADDING
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_BUFFS)
					end,
				},
				[6] = {
					type = "dropdown",
					name = "Growth Direction",
					tooltip = "New Icons will be added to the bar in this direction.",
					choices = {"Up", "Down", "Left", "Right"},
					default = "Down",
					getFunc = function() return buffAlertBarLayout.direction end,
					setFunc = function(sValue) buffAlertBarLayout.direction = sValue
						if sValue == "Left" or sValue == "Right" then
							local choices, default = GetAlignLeftChoices(sValue)
							BUFFTRACKER_BUFFALERTBAR_ALIGNLEFT:UpdateChoices(choices)
							BUFFTRACKER_BUFFALERTBAR_ALIGNLEFT:UpdateValue(false, default)
						end
						
						SetGrowthDirection(buffAlertBarLayout, sValue)
						self:SaveBarPosition(buffAlertBar)
						
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_BUFFS)
					end,
				},
				[7] = {
					type = "dropdown",
					name = "Horizontal Alignment",
					tooltip = "When growth direction is Up or Down this can be adjusted for placement on the left or right side of the screen. Left will align the left side of the icons & ability names will appear on the right. Right will align the right side of the icons & ability names will appear on the left.",
					choices = GetAlignLeftChoices(buffAlertBarLayout.direction),
					default = "Left",
					disabled = function() return DisableAlignLeftSetting(buffAlertBarLayout.direction) end,
					getFunc = function() 
						if buffAlertBarLayout.horizontalAlignment == LEFT then return "Left" else return "Right" end
					end,
					setFunc = function(sValue)
						SetAlignmentSide(buffAlertBarLayout, sValue)
						self:SaveBarPosition(buffAlertBar)
						
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_BUFFS)
					end,
					reference = "BUFFTRACKER_BUFFALERTBAR_ALIGNLEFT",
				},
				[8] = {
					type = "checkbox",
					name = "Display Ability Names",
					tooltip = "Growth direction must be Up or Down to display ability names.",
					default = true,
					disabled = function() return not buffAlertBarLayout.vertical end,
					getFunc = function() return buffAlertBarLayout.showNames end,
					setFunc = function(bValue) buffAlertBarLayout.showNames = bValue 
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_BUFFS) end,
				},
				[9] = {
					type = "dropdown",
					name = "Ability Name Font",
					tooltip = "Choose a font for ability names.",
					choices = libFonts:GetFontChoices(),
					default = self.DEFAULT_FONT_NAME,
					disabled = function() return not buffAlertBarLayout.vertical end,
					getFunc = function() return buffAlertBarLayout.fontName end,
					setFunc = function(buffAlertFontName) buffAlertBarLayout.fontName = buffAlertFontName
						local fontSize		= buffAlertBarLayout.fontSize
						local font			= libFonts:GetFontByName(buffAlertFontName)
						local outline		= libFonts:GetFontOutlineByName(buffAlertBarLayout.fontOutline)
						local fontString 	= libFonts:BuildFontString(font, fontSize, outline)
						buffAlertBarLayout.fontString = fontString
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_BUFFS)
					end,
				},
				[10] = {
					type = "dropdown",
					name = "Ability Name Font Outline",
					tooltip = "Choose a font outline for the Ability Names.",
					choices = libFonts:GetFontOutlineChoices(),
					default = "None",
					disabled = function() return not buffAlertBarLayout.vertical end,
					getFunc = function() return buffAlertBarLayout.fontOutline end,
					setFunc = function(fontOutline) buffAlertBarLayout.fontOutline = fontOutline
						local fontSize		= buffAlertBarLayout.fontSize
						local font			= libFonts:GetFontByName(buffAlertBarLayout.fontName)
						local outline		= libFonts:GetFontOutlineByName(fontOutline)
						local fontString 	= libFonts:BuildFontString(font, fontSize, outline)
						buffAlertBarLayout.fontString = fontString
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_BUFFS)
					end,
				},
				[11] = {
					type = "slider",
					name = "Ability Name Font Size",
					tooltip = "Choose a font size for ability names.",
					min = 10,
					max = 32,
					step = 1,
					default = self.DEFAULT_FONT_SIZE,
					disabled = function() return not buffAlertBarLayout.vertical end,
					getFunc = function() return buffAlertBarLayout.fontSize end,
					setFunc = function(buffAlertFontSize) buffAlertBarLayout.fontSize  = buffAlertFontSize 
						local font			= libFonts:GetFontByName(buffAlertBarLayout.fontName)
						local outline		= libFonts:GetFontOutlineByName(buffAlertBarLayout.fontOutline)
						local fontString 	= libFonts:BuildFontString(font, buffAlertFontSize, outline)
						buffAlertBarLayout.fontString = fontString
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_BUFFS)
					end,
				},
				[12] = {
					type = "colorpicker",
					name = "Ability Name Font Color",
					tooltip = "Change the color of ability names.",
					default = self.DEFAULT_FONT_COLOR_RESET,
					disabled = function() return not buffAlertBarLayout.vertical end,
					getFunc = function() return unpack(buffAlertBarLayout.fontColor) end,
					setFunc = function(r,g,b,a) buffAlertBarLayout.fontColor = {r, g, b, a} 
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_BUFFS)
					end,
				},
			},
		},
		
		[5] = {
			type = "submenu",
			name = "Proc Alert Bar",
			controls = {
				[1] = {
					type = "description",
					text = colorYellow.."The buff proc bar will display all effects, that you have set a proc alert for, whenever you receive the buff. This can be used to let you know when you receive special buffs like the Crystal Fragments proc that enables your next cast to be instant."
				},
				[2] = {
					type = "checkbox",
					name = "Enable Bar",
					tooltip = "Turns the bar ON/OFF.",
					default = true,
					getFunc = function() return buffProcBarLayout.enabled end,
					setFunc = function(bValue) buffProcBarLayout.enabled = bValue
						local procAlertBarFragment = self.barFragments[BARTYPE_ALERT_PROCS]
						procAlertBarFragment:SetHiddenForReason("UserDisabled", not bValue)
					end,
				},
				[3] = {
					type = "checkbox",
					name = "Hide Bar Title",
					tooltip = "Show/Hide the bar title.",
					default = false,
					getFunc = function() return buffProcBarLayout.hideTitle end,
					setFunc = function(bValue) buffProcBarLayout.hideTitle = bValue
						-- See note in first buff bar setting for why:
						--buffBar.backdrop:SetHidden(bValue)
						local alpha = bValue and 0 or 1
						buffProcBar.backdrop:SetAlpha(alpha)
					end,
				},
				[4] = {
					type = "checkbox",
					name = "Unlock Bar",
					tooltip = "Unlock the bar so you can move it around the screen.",
					default = true,
					getFunc = function() return buffProcBarLayout.unlocked end,
					setFunc = function(bValue) buffProcBarLayout.unlocked = bValue
						buffProcBar:SetMouseEnabled(bValue)
					end,
				},
				[5] = {
					type = "slider",
					name = "Icon Size",
					tooltip = "Adjust size of the icons.",
					min = 32,
					max = 64,
					step = 1,
					default = 64,
					getFunc = function() return buffProcBarLayout.iconSize end,
					setFunc = function(iValue) buffProcBarLayout.iconSize = iValue 
						-- no longer used, its anchored to resizewhen the template changes sizes
						--buffProcBarLayout.textureSize = iValue - self.DEFAULT_TEXTURE_PADDING
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_PROCS)
					end,
				},
				[6] = {
					type = "dropdown",
					name = "Growth Direction",
					tooltip = "New Icons will be added to the bar in this direction.",
					choices = {"Up", "Down", "Left", "Right"},
					default = "Down",
					getFunc = function() return buffProcBarLayout.direction end,
					setFunc = function(sValue) buffProcBarLayout.direction = sValue
						if sValue == "Left" or sValue == "Right" then
							local choices, default = GetAlignLeftChoices(sValue)
							BUFFTRACKER_BUFFALERTBAR_ALIGNLEFT:UpdateChoices(choices)
							BUFFTRACKER_BUFFALERTBAR_ALIGNLEFT:UpdateValue(false, default)
						end
						
						SetGrowthDirection(buffProcBarLayout, sValue)
						self:SaveBarPosition(buffProcBar)
						
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_PROCS)
					end,
				},
				[7] = {
					type = "dropdown",
					name = "Horizontal Alignment",
					tooltip = "When growth direction is Up or Down this can be adjusted for placement on the left or right side of the screen. Left will align the left side of the icons & ability names will appear on the right. Right will align the right side of the icons & ability names will appear on the left.",
					choices = GetAlignLeftChoices(buffProcBarLayout.direction),
					default = "Left",
					disabled = function() return DisableAlignLeftSetting(buffProcBarLayout.direction) end,
					getFunc = function() 
						if buffProcBarLayout.horizontalAlignment == LEFT then return "Left" else return "Right" end
					end,
					setFunc = function(sValue)
						SetAlignmentSide(buffProcBarLayout, sValue)
						self:SaveBarPosition(buffProcBar)
						
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_PROCS)
					end,
					reference = "BUFFTRACKER_PROCALERTBAR_ALIGNLEFT",
				},
				[8] = {
					type = "checkbox",
					name = "Display Ability Names",
					tooltip = "Growth direction must be Up or Down to display ability names.",
					default = true,
					disabled = function() return not buffProcBarLayout.vertical end,
					getFunc = function() return buffProcBarLayout.showNames end,
					setFunc = function(bValue) buffProcBarLayout.showNames = bValue 
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_PROCS) end,
				},
				[9] = {
					type = "dropdown",
					name = "Ability Name Font",
					tooltip = "Choose a font for ability names.",
					choices = libFonts:GetFontChoices(),
					default = self.DEFAULT_FONT_NAME,
					disabled = function() return not buffProcBarLayout.vertical end,
					getFunc = function() return buffProcBarLayout.fontName end,
					setFunc = function(buffProcFontName) buffProcBarLayout.fontName = buffProcFontName
						local fontSize		= buffProcBarLayout.fontSize
						local font			= libFonts:GetFontByName(buffProcFontName)
						local outline		= libFonts:GetFontOutlineByName(buffProcBarLayout.fontOutline)
						local fontString 	= libFonts:BuildFontString(font, fontSize, outline)
						buffProcBarLayout.fontString = fontString
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_PROCS)
					end,
				},
				[10] = {
					type = "dropdown",
					name = "Ability Name Font Outline",
					tooltip = "Choose a font outline for the Ability Names.",
					choices = libFonts:GetFontOutlineChoices(),
					default = "None",
					disabled = function() return not buffProcBarLayout.vertical end,
					getFunc = function() return buffProcBarLayout.fontOutline end,
					setFunc = function(fontOutline) buffProcBarLayout.fontOutline = fontOutline
						local fontSize		= buffProcBarLayout.fontSize
						local font			= libFonts:GetFontByName(buffProcBarLayout.fontName)
						local outline		= libFonts:GetFontOutlineByName(fontOutline)
						local fontString 	= libFonts:BuildFontString(font, fontSize, outline)
						buffProcBarLayout.fontString = fontString
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_PROCS)
					end,
				},
				[11] = {
					type = "slider",
					name = "Ability Name Font Size",
					tooltip = "Choose a font size for ability names.",
					min = 10,
					max = 32,
					step = 1,
					default = self.DEFAULT_FONT_SIZE,
					disabled = function() return not buffProcBarLayout.vertical end,
					getFunc = function() return buffProcBarLayout.fontSize end,
					setFunc = function(buffProcFontSize) buffProcBarLayout.fontSize  = buffProcFontSize 
						local font			= libFonts:GetFontByName(buffProcBarLayout.fontName)
						local outline		= libFonts:GetFontOutlineByName(buffProcBarLayout.fontOutline)
						local fontString 	= libFonts:BuildFontString(font, buffProcFontSize, outline)
						buffProcBarLayout.fontString = fontString
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_PROCS)
					end,
				},
				[12] = {
					type = "colorpicker",
					name = "Ability Name Font Color",
					tooltip = "Change the color of ability names.",
					default = self.DEFAULT_FONT_COLOR_RESET,
					disabled = function() return not buffProcBarLayout.vertical end,
					getFunc = function() return unpack(buffProcBarLayout.fontColor) end,
					setFunc = function(r,g,b,a) buffProcBarLayout.fontColor = {r, g, b, a} 
						self:ReanchorBarOnNameAlignmentChange(BARTYPE_ALERT_PROCS)
					end,
				},
			},
		},
	}
	LAM2:RegisterOptionControls("Circonians_BuffTracker_Options", optionsData)
end