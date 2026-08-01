--[[
  * Wykkyd's [ Achievement Tracker ]
  * Sponsored & Supported by: The Prydonian Elders
  * Author: Ravalox Darkshire (support@ecgroup.us)
  * Embedded: LibStub & libAddonMenu by Seerah.
  * Special credit to Biki, the original author of AchievementTracker from which this was derived
  * Special Thanks To: Zenimax Online Studios & Bethesda for The Elder Scrolls Online
]]--

local _addon = {}
_addon._v = {}
_addon._v.major		= 2
_addon._v.monthly 	= 3
_addon._v.daily 	= 5
_addon._v.minor 	= 5
_addon.Version 	= _addon._v.major
	..".".._addon._v.monthly
	..".".._addon._v.daily
	..".".._addon._v.minor
_addon.Name			= "wykkydsAchievementTracker"
_addon.MAJOR 		= _addon.Name..".".._addon._v.major
_addon.MINOR 		= string.format(".%02d%02d%03d", _addon._v.monthly, _addon._v.daily, _addon._v.minor)
_addon.DisplayName  = "Wykkyd Ach. Tracker"
_addon.SavedVariableVersion = 3
_addon.Player = "" -- will be set on load by LibWykkkydFactory
_addon.Settings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.GlobalSettings = {} -- will be set on load by LibWykkkydFactory, if you pass in the final parameter: your global saved variable as a string
_addon.wykkydPreferred = {
	["hidden"] = true,
	["showBackground"] = false,
	["notify"] = true,
	["bgAlpha"] = 25,
	["autoTrackZoneAchievements"] = false,
	["hideOldZoneAchievements"] = false,
	["notifyType"] = "alert",
}

_addon.LoadSavedVariables = function( self )
	self.lastZone = nil
	self.hiddenShortly = false
	self.checkboxesCreated = false
	self.heightPerLine = 50
	self.bufferTable = {}

	if self.Settings["hidden"] == nil then self.Settings["hidden"] = false end
	if self.Settings["tracked"] == nil then self.Settings["tracked"] = {} end
	if self.Settings["showDetails"] == nil then self.Settings["showDetails"] = {} end
	if self.Settings["sizeX"] == nil then self.Settings["sizeX"] = 100 end
	if self.Settings["sizeY"] == nil then self.Settings["sizeY"] = 200 end
	if self.Settings["offsetX"] == nil then self.Settings["offsetX"] = 100 end
	if self.Settings["offsetY"] == nil then self.Settings["offsetY"] = 100 end
	if self.Settings["bgAlpha"] == nil then self.Settings["bgAlpha"] = 25 end
end

_addon.LoadSettingsMenu = function( self )
	local panelData = self:MakeStandardSettingsPanel( "Exodus Code Group", "|cFF2222" )
	panelData.displayName = "|cFF2222Wykkyd Achievement Tracker|r"
	local optionsTable = {
		[1] = {
			type = "description",
			text = "This addon tracks Achievements in a configurable fashion, similar to Quest Tracker. This addon is based upon Biki's Achievement Tracker and acts as a replacement of that addon since Biki has stepped away from the game.",
		},
		[2]  = self:MakeStandardOption( self.Settings, "Lock in place", "locked", false, "checkbox", { default=false, } ),
		[3]  = self:MakeStandardOption( self.Settings, "Show icons", "showIcons", true, "checkbox", { default=true, } ),
		[4]  = self:MakeStandardOption( self.Settings, "Show description", "showDesc", true, "checkbox", { default=true, } ),
		[5]  = self:MakeStandardOption( self.Settings, "Notify progress", "notify", false, "checkbox", { default=false, } ),
		[6]  = self:MakeStandardOption( self.Settings, "Notify type", "notifyType", "alert", "dropdown", { tooltip = "Notifications will still go to CHAT if you use Full Immersion to hide the ALERT window", choices={"alert", "chat"}, default="alert", } ),
		[7]  = self:MakeStandardOption( self.Settings, "Auto track zone achievements", "autoTrackZoneAchievements", false, "checkbox", { default=false, } ),
		[8]  = self:MakeStandardOption( self.Settings, "Hide old zone achievements", "hideOldZoneAchievements", true, "checkbox", { default=true, } ),
		[9]  = self:MakeStandardOption( self.Settings, "Show tracked achievement count", "showTrackedAchievementCount", true, "checkbox", { default=true, } ),
		[10] = self:MakeStandardOption( self.Settings, "Hide completed", "hideCompleted", true, "checkbox", { default=true, } ),
		[11] = self:MakeStandardOption( self.Settings, "Show background", "showBackground", true, "checkbox", { default=true, } ),
		[12] = self:MakeStandardOption( self.Settings, "Maximum tracked", "maxTracked", 0, "slider", { min=0, max=24, step=1, default=0, } ),
		[13] = self:MakeStandardOption( self.Settings, "Background alpha", "bgAlpha", 25, "slider", { min=0, max=100, step=1, default=25, } ),
		[14] = self:MakeStandardOption( self.Settings, "Name font size", "fontSizename", 14, "slider", { min=8, max=30, step=1, default=22, } ),
		[15] = self:MakeStandardOption( self.Settings, "Description font size", "fontSizedesc", 12, "slider", { min=8, max=30, step=1, default=22, } ),
		[16] = { type="button", name="Clear Tracked", func = function() return self:Reset() end, },
	}
	optionsTable = self:InjectAdvancedSettings( optionsTable, 17 )
	self.LAM:RegisterAddonPanel(_addon.Name.."_LAM", panelData)
	self.LAM:RegisterOptionControls(_addon.Name.."_LAM", optionsTable)
end

_addon.Initialize = function( self )
	ZO_Achievements:SetHandler("OnUpdate", function()
		self:CheckAchievementJournalVisibility()
		if self:GetOrDefault( true, self.Settings[ "showTrackedAchievementCount" ] ) then
			self:AddTrackedAchievementCount()
		end		
	end)
	self:CreateWindow()
	ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function() self:SetHiddenShortly(true) end)
	ZO_PreHookHandler(ZO_InteractWindow, "OnShow", function() self:SetHiddenShortly(true) end)
	ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function() self:SetHiddenShortly(true) end)
	ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function() self:SetHiddenShortly(true) end)
	ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function() self:SetHiddenShortly(false) end)
	ZO_PreHookHandler(ZO_InteractWindow, "OnHide", function() self:SetHiddenShortly(false) end)
	ZO_PreHookHandler(ZO_GameMenu_InGame, "OnHide", function() self:SetHiddenShortly(false) end)
	ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function() self:SetHiddenShortly(false) end)
	self:RegisterEvent(EVENT_ZONE_CHANGED, function() self:LoadTrackedAchievements() end)	
	self:RegisterEvent(EVENT_PLAYER_ACTIVATED, function() self:LoadTrackedAchievements() end)	
	self:RegisterEvent(EVENT_ACHIEVEMENT_UPDATED, function(_, id) self:LoadTrackedAchievements(id) end)	
	self:LoadTrackedAchievements()	
end

if wykkydsAchievementTrackerGlobal == nil then wykkydsAchievementTrackerGlobal = {} end
LWF4.REGISTER_FACTORY(
	_addon, false, true,
	function( self ) _addon:LoadSavedVariables( self ) end,
	function( self ) _addon:LoadSettingsMenu( self ) end,
	function( self ) _addon:Initialize( self ) end,
	"wykkydsAchievementTrackerGlobal", true
)

local fullImmersionBlockedAlerts = function()
	if WYK_FullImmersion then
		if WYK_FullImmersion:GetOrDefault( false, WYK_FullImmersion.Settings[ "enabled" ] ) then
			if WYK_FullImmersion:GetOrDefault( false, WYK_FullImmersion.Settings[ "alerttext" ] ) then
				return true
			else return false; end
		else return false; end
	else return false; end
end

local notify = function( msg )
	 if not _addon:GetOrDefault( false, _addon.Settings[ "notify" ] ) then return end
	if _addon:GetOrDefault( "alert", _addon.Settings[ "notifyType" ] ) == "alert" and not fullImmersionBlockedAlerts() then
		ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.DEFAULT_CLICK, msg )
	else _addon:Print( "|c610B0B[AchTracker]"..LWF4_DEFAULT_CHAT_COLOR.." "..msg ) end
end

_addon.SetHiddenShortly = function(self, hidden)
	local oldStatus = self.hiddenShortly
	self.hiddenShortly = hidden
	if self.hiddenShortly ~= oldStatus then self:LoadTrackedAchievements() end
end

_addon.GetLabel = function(self, name, parent, isBold)
	local label = parent:GetNamedChild(name) or WINDOW_MANAGER:CreateControl(parent:GetName() .. name, parent, CT_LABEL)
	label:SetHidden(false)
	label:SetWidth(200)
	label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

	local fontFile = nil
	local fontSize = self:GetOrDefault( 12, self.Settings[ "fontSizedesc" ] )
	local fontDecoration = "soft-shadow-thin"
	if isBold then
		fontSize = self:GetOrDefault( 14, self.Settings[ "fontSizename" ] )
		fontFile = ZoFontGameBold:GetFontInfo()
	else
		fontFile = ZoFontGame:GetFontInfo()
	end

	label:SetFont(string.format("%s|%d|%s", fontFile, fontSize, fontDecoration))
	return label
end

_addon.GetIcon = function(self, name, parent, texture)
	local ico = parent:GetNamedChild(name) or WINDOW_MANAGER:CreateControl(parent:GetName() .. name, parent, CT_TEXTURE)
	ico:SetHidden(false)
	ico:SetDimensions(15, 15)
	ico:SetTexture(texture)
	return ico
end

_addon.AutoTrackZoneAchievements = function(self)
	if self:GetOrDefault( false, self.Settings[ "autoTrackZoneAchievements" ] ) then
		local currentZone = GetUnitZone("player")
		if currentZone ~= self.lastZone or self.lastZone == nil then
			if self.lastZone ~= nil and self:GetOrDefault( true, self.Settings[ "hideOldZoneAchievements"] ) then
				self:FindZoneAchievements(self.lastZone, false)
			end			
			self:FindZoneAchievements(currentZone, true)
			self.lastZone = currentZone
		end
	end
end

_addon.FindZoneAchievements = function(self, zone, track)
	local numCats = GetNumAchievementCategories()
	local FindAndTrack = function(cat, subCat, index)
		local id = GetAchievementId(cat, subCat, index)
		local name, desc = GetAchievementInfo(id)		
		if string.find(name, zone) ~= nil or string.find(desc, zone) ~= nil then
			if track then
				self.Settings["tracked"][id] = true
				self.Settings["showDetails"][id] = false
			else
				self.Settings["tracked"][id] = nil
				self.Settings["showDetails"][id] = nil
			end			
		end
	end
	for iCat = 1, numCats do
		local _, numSubCats, numAchievs, num3, num4, boolResponse = GetAchievementCategoryInfo(iCat)
		if numSubCats > 0 then
			for iSubCat = 1, numSubCats do
				local _, numAchievs = GetAchievementSubCategoryInfo(iCat, iSubCat)
				for iAchiev = 1, numAchievs do FindAndTrack(iCat, iSubCat, iAchiev) end
			end
		else
			for iAchiev = 1, numAchievs do FindAndTrack(iCat, nil, iAchiev) end
		end
	end	
end

_addon.CreateWindow = function(self)
	local o = self.Frames.__NewTopLevel("wykkydsAchievementTrackerWindow")
		:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.Settings["offsetX"], self.Settings["offsetY"])
		:SetHidden(false)
		:SetMovable(not self:GetOrDefault( false, self.Settings[ "locked" ] ))
		:SetMouseEnabled(true)
		:SetResizeToFitDescendents(true)
		:SetClampedToScreen( true )
		:SetHandler("OnMouseUp", function()
			self.Settings["offsetX"] = wykkydsAchievementTrackerWindow:GetLeft()
			self.Settings["offsetY"] = wykkydsAchievementTrackerWindow:GetTop()
		end)
		:SetDrawLayer( DL_TEXT )
	.__END

	local bgo = self.Frames.NewTopLevel("wykkydsAchievementTrackerWindow")
	local bg = self.Frames.StandardBackdrop:Create(bgo, "wykkydsAchievementTrackerWindow", {CENTER, o, CENTER, 0, 0}, 200, 200, {0,0,0,.85}, {0,0,0,.95}, {"",8,1,1}, 1, bg)
	wykkydsAchievementTrackerWindow_Backdrop:SetAnchorFill( o )
	wykkydsAchievementTrackerWindow_Backdrop:SetDrawLayer( DL_BACKGROUND )
	wykkydsAchievementTrackerWindow_Backdrop:SetHidden(false)
end

_addon.ToggleBackground = function( self )
	if self:GetOrDefault( true, self.Settings[ "showBackground" ] ) or (self.hiddenShortly or self:GetOrDefault( false, self.Settings[ "hidden" ] )) then
		wykkydsAchievementTrackerWindow_Backdrop:SetHidden(false)
		wykkydsAchievementTrackerWindow_Backdrop:SetAlpha(self.Settings["bgAlpha"] / 100)
	else
		wykkydsAchievementTrackerWindow_Backdrop:SetHidden(true)
	end
end

_addon.LoadTrackedAchievements = function(self, updatedId)
	self:ToggleBackground()

	if self:GetOrDefault( false, self.Settings[ "locked" ] ) then
		wykkydsAchievementTrackerWindow:SetMovable(false)
	else
		wykkydsAchievementTrackerWindow:SetMovable(true)
	end

	if self:GetOrDefault( false, self.Settings[ "autoTrackZoneAchievements" ] ) then
		self:AutoTrackZoneAchievements(GetUnitZone("player"))
	end

	if self.hiddenShortly or self:GetOrDefault( false, self.Settings[ "hidden" ] ) then
		wykkydsAchievementTrackerWindow:SetHidden(true)
	else
		wykkydsAchievementTrackerWindow:SetHidden(false)
	end

	if updatedId ~= nil and updatedId > 0 and self:GetOrDefault( false, self.Settings[ "notify" ] ) then
		local name, desc, _, icon, done = GetAchievementInfo(updatedId)
		if name ~= "" and name ~= nil then
			local numCriteria = GetAchievementNumCriteria(updatedId)
			local totalCompleted = 0
			local totalRequired = 0
			for criteria = 1, numCriteria do
				local _, critCompleted, critRequired = GetAchievementCriterion(updatedId, criteria)
				totalCompleted = totalCompleted + critCompleted
				totalRequired = totalRequired + critRequired
			end
			local quarterNeeded = totalRequired * 0.25
			local halfNeeded = totalRequired * 0.5
			local threeQuartersNeeded = totalRequired * 0.75
			local showUpdate = false
			if (totalCompleted == quarterNeeded or totalCompleted == halfNeeded or totalCompleted == threeQuartersNeeded) or totalRequired <= 100 then
				showUpdate = true
			end
			local finished = false
			if totalRequired == totalCompleted then
				showUpdate = true
				finished = true
			end
			totalCompleted = self:comma_number(totalCompleted)
			totalRequired = self:comma_number(totalRequired)
			if showUpdate then
				if finished then
					notify("Achievement |cFF4136" .. name ..LWF4_DEFAULT_CHAT_COLOR.. " completed.")
				else
					notify("Achievement |cFF4136" .. name ..LWF4_DEFAULT_CHAT_COLOR.. " advanced. (" .. totalCompleted .. "/" .. totalRequired .. ")")
				end
			end
		end
	end

	local numChildren = wykkydsAchievementTrackerWindow:GetNumChildren()
	for i = 1, numChildren do
		local child = wykkydsAchievementTrackerWindow:GetChild(i)
		if child then
			local height = child:GetHeight()
			child:SetHidden(true)
			child:SetDimensions(0, 0)
			wykkydsAchievementTrackerWindow:SetHeight(wykkydsAchievementTrackerWindow:GetHeight() - height)
		end
	end

	if wykkydsAchievementTrackerWindow:IsHidden() then return end

	local i = 1
	local lastTotalHeight = 0;

	for id, isTracked in pairs(self.Settings["tracked"]) do
		local name, desc, _, icon, done = GetAchievementInfo(id)
		local continue = true
		if done and self:GetOrDefault( true, self.Settings[ "hideCompleted" ] ) then
			continue = false
			self.Settings["tracked"][id] = nil
			self.Settings["showDetails"][id] = nil
		end

		local max = self:GetOrDefault( 0, self.Settings[ "maxTracked" ] )
		if self:GetOrDefault( 0, self.Settings[ "maxTracked" ] ) == 0 then max = 9999 end

		if i > max then return end

		if isTracked and continue then
			local offsetY = 0
			if lastTotalHeight > 0 then offsetY = lastTotalHeight end

			local achievIcon = self:GetIcon("Icon" .. i, wykkydsAchievementTrackerWindow, icon)
			achievIcon:SetAnchor(TOPLEFT, wykkydsAchievementTrackerWindow, TOPLEFT, 5, offsetY)
			achievIcon:SetHidden(not self:GetOrDefault( true, self.Settings[ "showIcons" ] ))
			local achievName = self:GetLabel("Label" .. i, wykkydsAchievementTrackerWindow, true)
			local xPos = 5

			if achievIcon:IsHidden() then xPos = -15 end
			achievName:SetAnchor(TOPLEFT, achievIcon, TOPRIGHT, xPos, 0)
			achievName:SetText(name)
			achievName:SetMouseEnabled(true)
			if done then achievName:SetColor(0, 1, 0, 1)
			else achievName:SetColor(1, 1, 1, 1) end

			achievName:SetHandler("OnMouseEnter", function(self) achievName:SetColor(1, 0.86, 0, 1) end)
			achievName:SetHandler("OnMouseExit", function(self)
				if done then achievName:SetColor(0, 1, 0, 1)
				else achievName:SetColor(1, 1, 1, 1) end
			end)
			achievName:SetHandler("OnMouseUp", function(_, button)
				if button == 1 then
					local catId, subCatId, achievIndex = GetCategoryInfoFromAchievementId(id)
					SCENE_MANAGER:Show("achievements")
				elseif button == 3 then
					self.Settings["tracked"][id] = nil
					self.Settings["showDetails"][id] = nil
					return self:LoadTrackedAchievements()
				elseif button == 2 then
					self.Settings["showDetails"][id] = not self.Settings["showDetails"][id]
					return self:LoadTrackedAchievements()
				end
			end)

			local achievDesc = self:GetLabel("Desc" .. i, wykkydsAchievementTrackerWindow)
			achievDesc:SetWidth(190)
			achievDesc:SetAnchor(TOPLEFT, achievName, TOPLEFT, 10, achievName:GetTextHeight())
			if done then achievDesc:SetColor(0, 1, 0, 1)
			else achievDesc:SetColor(0.8, 0.8, 0.8, 1) end

			if self:GetOrDefault( true, self.Settings[ "showDesc" ] ) then achievDesc:SetText(desc)
			else achievDesc:SetText("") end

			local achievCriteria = self:GetLabel("Criteria" .. i, wykkydsAchievementTrackerWindow)
			achievCriteria:SetAnchor(TOPLEFT, achievDesc, TOPLEFT, 0, achievDesc:GetTextHeight())
			achievCriteria:SetWidth(190)
			if done then achievCriteria:SetColor(0, 1, 0, 1)
			else achievCriteria:SetColor(0.8, 0.8, 0.8, 1) end

			local numCriteria = GetAchievementNumCriteria(id)
			local totalCompleted = 0
			local totalRequired = 0

			if self.Settings["showDetails"][id] then
				local text = ""
				local critDisplayed = 0
				for criteria = 1, numCriteria do
					local critDesc, critCompleted, critRequired = GetAchievementCriterion(id, criteria)
					if (critCompleted ~= critRequired) or (critCompleted == critRequired and not self:GetOrDefault( true, self.Settings[ "hideCompleted" ] )) then
						critDisplayed = critDisplayed + 1
						if critDisplayed > 1 then text = text .. "\n" end
						if critCompleted ~= critRequired then
							if critRequired == 1 then text = text .. " - " .. critDesc
							else text = text .. " - " .. critDesc .. " : " .. critCompleted .. "/" .. critRequired end
						else
							text = text .. "|c2ECC40 - " .. critDesc .. "|r"
						end
					end
				end
				achievCriteria:SetText(text)
				achievCriteria:SetHeight(achievCriteria:GetTextHeight() * numCriteria)
			else
				for criteria = 1, numCriteria do
					local critDesc, critCompleted, critRequired = GetAchievementCriterion(id, criteria)
					totalCompleted = totalCompleted + critCompleted
					totalRequired = totalRequired + critRequired
				end
				if totalCompleted > 1 then totalCompleted = self:comma_number(totalCompleted) end
				if totalRequired > 1 then
					totalRequired = self:comma_number(totalRequired)
					achievCriteria:SetText(" - " .. totalCompleted .. "/" .. totalRequired)
				else achievCriteria:SetText("") end
			end
			lastTotalHeight = lastTotalHeight + achievName:GetTextHeight() + achievDesc:GetTextHeight() + achievCriteria:GetTextHeight() + 10
			i = i + 1
		end
	end
end

_addon.AddTrackedAchievementCount = function(self)
	if not self:BufferPause("AddTrackedAchievementCount", .5) then return end

	local parent = ZO_AchievementsContentsCategoriesScrollChildContainer1
	local numChildren = parent:GetNumChildren()
	local AppendTrackedCount = function(control, trackCount)
		local nm = control:GetName().."trackercount"
		local lbl = _G[nm] or _addon.Frames.NewLabel( nm, control )
		lbl:SetText(tostring("|cAAAAAA".. trackCount .. "|r "))
		lbl:SetWrapMode( TEXT_WRAP_MODE_ELLIPSIS )
		lbl:SetAnchor( RIGHT, control, LEFT, -4, 0 )
		lbl:SetHorizontalAlignment(_addon.GLOBAL.TextAlign["h"]["right"])
		lbl:SetVerticalAlignment(_addon.GLOBAL.TextAlign["v"]["center"])
		lbl:SetFont(string.format( "%s|%d|%s", "EsoUI/Common/Fonts/univers57.otf", 14, "soft-shadow-thick"))
	end
	local FindTrackedForSubcat = function(subcatControl, catIndex, subcatIndex)
		subcatControl.tracked = 0
		if subcatControl.orgText == nil then subcatControl.orgText = subcatControl:GetText() end
		for id, isTracked in pairs(self.Settings["tracked"]) do
			if isTracked then
				local _catIndex, _subcatIndex, _ = GetCategoryInfoFromAchievementId(id)
				if catIndex == _catIndex and subcatIndex == _subcatIndex then subcatControl.tracked = subcatControl.tracked + 1 end
			end
		end
	end
	for i = 2, numChildren do
		local child = parent:GetChild(i)
		local txtChild = child:GetNamedChild("Text") or nil

		if txtChild ~= nil then
			if txtChild.orgText == nil then txtChild.orgText = txtChild:GetText() end
			local tracked = 0
			for id, isTracked in pairs(self.Settings["tracked"]) do
				if isTracked then
					local catIndex, subCatIndex, achievementIndex = GetCategoryInfoFromAchievementId(id)
					if child.node.data.categoryIndex == catIndex then tracked = tracked + 1 end
				end
			end
			AppendTrackedCount(txtChild, tracked)
		else
			local numSubcats = child:GetNumChildren()
			for j = 1, numSubcats do
				local subcat = child:GetChild(j)
				if j == 1 then
					FindTrackedForSubcat(subcat, subcat.node.data.parentData.categoryIndex, nil)
				else
					FindTrackedForSubcat(subcat, subcat.node.data.parentData.categoryIndex, j - 1)
				end
				AppendTrackedCount(subcat, subcat.tracked)
			end
		end
	end
end

_addon.CreateCheckboxes = function(self)
	local list = ZO_AchievementsContentsContentListScrollChild
	local numOfAchievements = list:GetNumChildren()
	for i = 1, numOfAchievements do
		local achievement = list:GetChild(i)
		if achievement ~= nil then
			local title = achievement:GetNamedChild("Title")
			if title ~= nil then
				title:SetAnchor(3, achievement, 3, 110, 10)
				local id = achievement["achievement"]["achievementId"]
				local controlName = tostring(title:GetName() .. "TrackerCheckbox")
				local cb = title:GetNamedChild("TrackerCheckbox") or WINDOW_MANAGER:CreateControlFromVirtual(controlName, title, "ZO_CheckButton")
				cb:SetAnchor(LEFT, title, LEFT, -20, 0)
				cb:SetDimensions(15, 15)
				cb:SetHidden(false)
				cb:SetHandler("OnMouseUp", function() self:ToggleTracked() end)
				if self.Settings["tracked"][id] == true then state = BSTATE_PRESSED
				else state = BSTATE_NORMAL end
				cb:SetState(state, false)
			end
		end
	end
end

_addon.ToggleNotifications = function()
	local text = ""
	_addon.Settings[ "notify" ] = not _addon:GetOrDefault( false, _addon.Settings[ "notify" ] )
	if _addon:GetOrDefault( false, _addon.Settings[ "notify" ] ) then text = "ON" else text = "OFF" end
	notify("Achievement notifications are now " .. text)
end

_addon.ToggleWindow = function()
	_addon.Settings[ "hidden" ] = not _addon:GetOrDefault( false, _addon.Settings[ "hidden" ] )
	_addon:LoadTrackedAchievements()
end

_addon.ToggleTracked = function(self)
	local control = WINDOW_MANAGER:GetMouseOverControl()
	local firer = control:GetParent():GetParent()
	local id = firer["achievement"]["achievementId"]

	if self.Settings["tracked"][id] then
		self.Settings["tracked"][id] = nil
		self.Settings["showDetails"][id] = nil
	else
		self.Settings["tracked"][id] = true
	end

	self:LoadTrackedAchievements()
	self:AddTrackedAchievementCount()
end

_addon.CheckAchievementJournalVisibility = function(self)
	if not self:BufferPause("CheckAchievementJournalVisibility", .5) then return end

	if ZO_AchievementsContentsContentListScrollChild:IsHidden() == false then
		self:CreateCheckboxes()
	end
end

_addon.Reset = function(self)
	for id, isTracked in pairs(self.Settings["tracked"]) do
		self.Settings["tracked"][id] = nil
		self.Settings["showDetails"][id] = nil
	end

	self:LoadTrackedAchievements()
end

WYK_AchievementTracker = _addon
