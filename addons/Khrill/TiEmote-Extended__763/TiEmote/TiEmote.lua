------------------------------------------
--           TiEmote Extended           --
--           by Rosie & Khrill          --
--                                      --
--               v 1.8.3               --
------------------------------------------

local TE		= {}
TE.name 		= "Ti|cB70E99Emote|r"
TE.default		= {
	bversion	= "1.83",
	keybindOnly	= false,
	anchor 		= {TOPLEFT, TOPLEFT, 100, 100},
	anchorGroup	= {},
	nbEmote 	= 0,
	nbRow		= 20,
	fav			= {[1]= {}},
	group		= {[1]= "favorite"},
	orientation	= {[1]= 1},
	movable		= true,
	groupMovable= false,
	lineMode	= false,
	opacity		= 1,
	color		= {},
	randomList	= 0,
	openDeploy = true,
}
TE.locale = nil
TE.nbEmote = 0
TE.nbRow = 20
TE.fav = nil
TE.orderFav = {}
TE.group = nil
TE.selGroup = 1
TE.maxGroup = 9
TE.showList = false
TE.movable = true
TE.groupMovable = false
TE.lineMode = false
TE.opacity = 1
TE.color = {}
TE.fontColor = {
			{0.77,0.76,0.62,1},	-- default 
			{0.39,0.75,0.29,1},	-- green
			{0.59,0.47,0.86,1}, -- purple
			{0.83,0.62,0.37,1},	-- orange
			{0.86,0.47,0.70,1}, -- pink
			{0.86,0.47,0.47,1}, -- red
			{0.47,0.68,0.86,1}	-- blue
}
TE.maxColor = table.getn(TE.fontColor)
TE.sliderOffset = 0
TE.alphaList = {}
TE.configPanel = nil
TE.reload = false
TE.byKey = false
TE.tex = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
TE.btnSize = 130
TE.xOffset = {up = 0, down = 0, color = 0, Fav = 0, Panel = 160 }
TE.yOffset = {up = 0, down = 0, color = 0, Fav = -5, Panel = 0 }

local COLOR_KHRILLSELECT = "FF6A00" -- orange ^^
local TEXTURES = {
	["EMOTERANDOM"] = "/esoui/art/icons/gift_box_002.dds",
	["EMOTERANDOMUP"] = "/esoui/art/icons/gift_box_001.dds",
	["EMOTERANDOMFAV"] = "/esoui/art/icons/gift_box_003.dds",
}

local function HexToRGBA( hex )
	if string.len(hex) == 6 then hex = hex.."FF" end
    local rhex, ghex, bhex, ahex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6), string.sub(hex, 7, 8)
    return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end
local function getKeyByValue(t, value)
  for k,v in pairs(t) do
    if v==value then return k end
  end
  return nil
end

string.split = function(str, pattern) 
    pattern = pattern or "[^%s]+" 
 
	if pattern:len() == 0 then 
        pattern = "[^%s]+" 
    end 
    local parts = {__index = table.insert} 
    setmetatable(parts, parts) 
    str:gsub(pattern, parts) 
    setmetatable(parts, nil) 
    parts.__index = nil 
    return parts 
end 

--###  EVENTS  ###--
--------------------
function TE:OnAddOnLoaded( eventCode, addOnName )
	-- Init (on event)
	if ( addOnName ~= "TiEmote") then return end

	-- Localization strings in separate file
	TE.locale = TE_Lang[TE:GetLanguage()]
	TE.default.group[1] = TE.locale.Settings_groupDefault
	ZO_CreateStringId("SI_BINDING_NAME_TE_ACTIVATE", TE.locale.SI_BINDING_NAME_TE_ACTIVATE)
	ZO_CreateStringId("SI_BINDING_NAME_TE_RANDOM", TE.locale.SI_BINDING_NAME_TE_RANDOM)

	TE.vars = ZO_SavedVars:New("TiEmote_Vars",1,"TiEmote",TE.default)
--	TE.vars = TE.default

	-- Need to clear anchors, since SetAnchor() will just keep adding new ones.
	TiEmote:ClearAnchors();
	TiEmote:SetAnchor(TE.vars.anchor[1], TiEmote.parent, TE.vars.anchor[2], TE.vars.anchor[3], TE.vars.anchor[4])
	
	-- sort list
	self:InitAlphaList()
	
	-- setup emote button
	self:UpdateEmote()
		
	TE.nbRow = TE.vars.nbRow
	TE.fav = TE.vars.fav
	TE.group = TE.vars.group
	TE.nbRow = TE.vars.nbRow
	TE.movable = TE.vars.movable
	TE.groupMovable = TE.vars.groupMovable
	TE.lineMode = TE.vars.lineMode
	TE.opacity = TE.vars.opacity
	TE.color = TE.vars.color
	TE.bversion = TE.vars.bversion
	
	-- init fav with index & color for previous version < 1.10
	-- init group for previous version < 1.20
	-- previous version <= 1.40: insert new emote 107 /prov - only for FR & DE client (ESO 1.6.5)
	-- version 1.41 EN ES: restore fav list without inserted emote /prov (not deployed by ESO)
	self:checkFavVersion()
	
	-- update UI
	self:InitUI()
			
	-- mousewheel interaction
	-- sometimes the mouse lose focus on panel and it zoom/dezoom cam, so i ve put it on button
	-- edit 1.10 : change panel dimensions and seems ok for now
	TE_EmotePanel:SetHandler("OnMouseWheel", function(self, delta) TE:OnMouseWheel(delta) end)
			
	-- update button visibility
	self:UpdateButton()
	
	-- list visibility
	self:ShowList()
	
	-- init groups & fav
	self:InitGroup()
	self:TiEmoteToggleGroup(nil)
	self:UpdateRandomButton()
	
	-- fix or movable
	self:UpdateMovable()
	
	-- set opacity
	self:UpdateOpacity(false)
	
	-- update color button
	self:UpdateColor()
	
	-- init config panel
	self:InitConfigPanel()
end

function TE:OnReticleHidden(eventCode, hidden)
	-- on event
--d("--OnReticleHidden "..tostring(hidden)..","..tostring(TE.byKey))
	if TE.byKey or (TE.vars and (TE.vars.keybindOnly)) then return end
	
--	d(ZO_GameMenu_InGame:IsHidden())
		if hidden then --and ZO_GameMenu_InGame:IsHidden() then
			TE:ShowUI(TE.vars.openDeploy or TE.byKey)
			TiEmote:SetHidden(false)
		else
			TiEmote:SetHidden(true)
		end
		TE.byKey = false
	--end
end

EVENT_MANAGER:RegisterForEvent("TiEmote" , EVENT_ADD_ON_LOADED , function(_event, _name) TE:OnAddOnLoaded(_event, _name) end)
EVENT_MANAGER:RegisterForEvent("TiEmote" , EVENT_RETICLE_HIDDEN_UPDATE, function(_event, _hidden) TE:OnReticleHidden(_event, _hidden) end)

function TiEmoteToggleMain()
	-- click on title => show / hide groups
	TE:ShowUI(TE_EmotePanel:IsControlHidden())
end

function TiEmoteToggleActivate()
	-- show/hide by keybinding
--d("--TiEmoteToggleActivate: IsControlHidden="..tostring(TiEmote:IsControlHidden())..",IsHidden="..tostring(TiEmote:IsHidden()))
	TE.byKey = true
    if TiEmote:IsControlHidden() then
		SetGameCameraUIMode(true)
        TiEmote:SetHidden(false)
		TE:ShowUI(true)
	else
		TiEmote:SetHidden(true)
		SetGameCameraUIMode(false)
    end
end

function TiEmoteRandom(group)
	-- play a random emote from choosen list
	if group == nil then group = TE.vars.randomList end
	local n = 0
	if group == 0 then --main list
		n = TE.nbEmote
	else --specific group
		if TE.fav[group] then
			n = table.getn(TE.fav[group])
		end
	end
	if n > 0 then
		local alea = math.random(1,n)
		if group ==0 then
			TE:PlayEmote(alea, 0) --emote from main list
		else
			TE:PlayEmote(TE.fav[group][alea][2], 1) -- emote from fav group
		end
	else
		-- no emote :s
		TE:Msg(TE.locale.Message_noEmote)
	end
end

function TiEmoteUpdate()
	-- on update
--d("--TiEmoteUpdate "..tostring(IsInteracting())..","..tostring(IsInteractionCameraActive())..","..tostring(TE.byKey))
--	if ZO_ActionBar1:IsHidden() or (TE.vars and not(TE.vars.keybindOnly) and not ZO_Loot:IsHidden()) then
	if IsInteractionCameraActive() or not ZO_GameMenu_InGame:IsHidden() or not ZO_TopBar:IsHidden() or (TE.vars and not(TE.vars.keybindOnly) and not ZO_Loot:IsHidden()) then
		TiEmote:SetHidden(true)
		TE.byKey = false
	end
end

function TE:OnSliderMove(value)
	TE.sliderOffset = value
	self:UpdateButton()
	self:UpdateColor()
end

function TE:OnMouseWheel(delta)
--d("--OnMouseWheel:"..delta)
	local offset = TESlider:GetValue()
	offset = offset - delta
	if (offset < 0) then offset = 0 end
	if (offset > TE.nbEmote-TE.nbRow) then offset = TE.nbEmote-TE.nbRow end
	
	TE.sliderOffset = offset
	TESlider:SetValue(offset)
end

 
--###  INIT/SAVE  ###--
-----------------------
function TiEmoteSaveAnchor()
	-- Save the new position of windows
--d("TiEmoteSaveAnchor")
	-- Main window
	local group
	local nbGroup = table.getn(TE.group)
	local panelControl
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY

	isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = TiEmote:GetAnchor()
	if isValidAnchor then
		TE.vars.anchor = { point, relativePoint, offsetX, offsetY }
	else
		d("TiEmote - anchor not valid")
	end
	--Group windows
	for group=1, nbGroup do
		panelControl = GetControl("TE_FavPanel"..tostring(group))
		if panelControl ~= nil then
			offsetX = panelControl:GetLeft()
			offsetY = panelControl:GetTop()
			TE.vars.anchorGroup[group] = { offsetX, offsetY }
		end
	end
end

function TE:InitAlphaList()
	local alpha = {}
	for i=1, GetNumEmotes() do
		table.insert(alpha,{i,TE:GetEmoteSlashName(i, 1)})
	end
	table.sort(alpha, function(a,b) return a[2] < b[2] end)
	for i=1, GetNumEmotes() do
		table.insert(TE.alphaList, {i, alpha[i][1]})
	end
	table.sort(TE.alphaList, function(a,b) return a[1] < b[1] end)
end

function TE:UpdateEmote()
	TE.nbEmote = GetNumEmotes()
	TE.vars.nbEmote = TE.nbEmote
end

function TE:ToggleMovable(state)
	TE.movable = state
	TE.vars.movable = TE.movable
--d("ToggleMovable->"..tostring(TE.movable))
	if not state then
		TE.groupMovable = false
		TE.vars.groupMovable = TE.groupMovable
	end
	TE:UpdateMovable()
	
	return TE.movable
end
function TE:ToggleGroupMovable(state)
	TE.groupMovable = state
	TE.vars.groupMovable = TE.groupMovable
--d("ToggleGroupMovable->"..tostring(TE.groupMovable))
	if not state then
		TE.lineMode = false
		TE.vars.lineMode = TE.lineMode
	end
	TE:UpdateMovable()
	
	return TE.groupMovable
end
function TE:UpdateMovable()
	-- movable or not (settings)
	local nbGroup = table.getn(TE.group)
	local panelControl
	local group
--	d(nbGroup)
	--all groups panel
	for group=1, nbGroup do
		panelControl = GetControl("TE_FavPanel"..tostring(group))
--		d(group,TE.groupMovable)
		if panelControl ~= nil then panelControl:SetMovable(TE.groupMovable) end
	end
	--main window
	TiEmote:SetMovable(TE.movable)
end

function TE:ToggleLineMode(state)
	TE.lineMode = state
	local n = table.getn(TE.group)
	for i=1,n do
		if TE.lineMode then
			TE.vars.orientation[i] = 2
		else
			TE.vars.orientation[i] = 1
		end
	end
	
--d("ToggleLineMode->"..tostring(TE.lineMode))
	--update 
	TE:InitGroup()
	TE:TiEmoteToggleGroup(nil)
	TE.vars.lineMode = TE.lineMode
	
	return TE.lineMode
end

function TE:UpdateOpacity(bMousein)
	if bMousein then
		TiEmote:SetAlpha(1)
	else
		TiEmote:SetAlpha(TE.opacity)
	end
end
function TE:SetOpacity(alpha)
	TE.opacity = alpha
	TE.vars.opacity = alpha
	self:UpdateOpacity(false)
end

local function fixDecal(startFromIndex, decalValue)
	local tmp_array = {}
	local maxgroup = table.getn(TE.fav)
	for group=1,maxgroup do
		local n = #TE.fav[group]
		if TE.fav[group] then n = table.getn(TE.fav[group]) end
		for i=1, n do
			if (TE.fav[group][i][2] >= startFromIndex) then
				TE.fav[group][i][2] = TE.fav[group][i][2] +decalValue
			end
		end
	end
	TE.vars.fav = TE.fav
end
function TE:checkFavVersion()
	-- Update vars structure if needed when new release
--d(TE.bversion)
--d(TE.fav)
	if TE.bversion == "1.09" then
		local tmp_array = {}
		local n = table.getn(TE.fav)
		for i=1,n do
			table.insert(tmp_array,{i,TE.fav[i],0})
		end
		table.sort(tmp_array, function(a,b) return a[1] < b[1] end)
		TE.fav = tmp_array
		TE.vars.fav = TE.fav
		TE.bversion = "1.10"
	end
	if TE.bversion == "1.10" then
		local tmp_array = {}
		local copy = TE.fav
		tmp_array[1] = copy
		TE.fav = tmp_array
		TE.vars.fav = TE.fav
		TE.vars.anchorGroup	= {}
		TE.groupMovable = false
		TE.vars.groupMovable = false
		TE.bversion = "1.22"
	end
	if TE.bversion == "1.22" then
		local tmp_array = {}
		local n = table.getn(TE.group)
		for i=1,n do
			if TE.lineMode then
				tmp_array[i] = 2
			else
				tmp_array[i] = 1
			end
		end
		TE.vars.orientation = tmp_array
		TE.bversion = "1.40"
	end
	if string.sub(TE.bversion,1,3) == "1.3" or TE.bversion == "1.40" then
		-- ESO 1.6: insert new emote 107 /prov - only for FR & DE client
--		if TE:GetLanguage() == "fr" or TE:GetLanguage() == "de" then
			fixDecal(107, 1)
			TE.bversion = "1.50"
--		end
	end
	if TE.bversion == "1.41" or TE.bversion == "1.43" then
		-- version 1.41/43 EN ES: restore fav list without inserted emote /prov (not deployed by ESO)
		if TE:GetLanguage() == "en" or TE:GetLanguage() == "es" then
			fixDecal(108, -1)
			TE.bversion = "1.50"
		end
	end
	if TE.bversion == "1.42" then -- bad decal
		-- ESOTU 2.0.8(or 2.0.7): insert new emote 107 but empty (???) - only for EN client
		-- if TE:GetLanguage() == "en" or TE:GetLanguage() == "es" then
			-- fixDecal(107, 1)
			-- TE.bversion = "1.44"
		-- end
	end
	if TE.bversion == "1.44" then
		-- ESOTU 2.1.4 (or 2.1.x): insert new emote 107  - only for EN & ES client
		if TE:GetLanguage() == "en" or TE:GetLanguage() == "es" then
			fixDecal(107, 1)
			TE.bversion = "1.50"
		end
	end
	--update version
	TE.bversion = TE.default.bversion
	TE.vars.bversion = TE.bversion

--d("-----")
--d(TE.bversion.." ("..TE.default.bversion..")")
--d(TE.fav)
--d("-----end-----")
end


--###  EMOTES  ###--
--------------------
function TiEmoteToggleList()
	-- click Show list button
	TE.showList = not TE.showList
	TE:ShowList()
end
function TE:ShowList()
	if (TE.showList) then
		TE_EmotePanel:SetHidden(false)
		WINDOW_MANAGER:GetControlByName("TE_ShowListButton"):SetText("|cB70E99"..TE.locale.UI_list.."|r")
	else
		TE_EmotePanel:SetHidden(true)
		WINDOW_MANAGER:GetControlByName("TE_ShowListButton"):SetText(TE.locale.UI_list)
	end
end

function TE:UpdateButton()
--d("--UpdateButton")
	-- init emote button of list
	for i= 1, TE.nbRow do
		local button = GetControl("TE_EmoteButton"..tostring(i-1))
				
		button:SetText(TE:GetEmoteSlashName(i,0))
		-- if button:GetHandler("OnClicked") == nil then button:SetHandler("OnClicked", function(self,button)
					-- if button==1 then
						-- TE:PlayEmote(i,0) 
					-- else
						-- TE:ToggleFav(i,0)
					-- end
				-- end)
		-- end
		--button:SetHandler("OnMouseWheel", function(self, delta) TE:OnMouseWheel(delta) end)
		-- if button:GetHandler("OnMouseDoubleClick") == nil then button:SetHandler("OnMouseDoubleClick", function(self) TE:NextColor(i -1) end) end
	end	
end

function TE:GetEmIndexFromEmListIndex(emListId)
	local emIndex = TE.sliderOffset + emListId
	return self.alphaList[emIndex][2]
end
function TE:GetEmListIndexFromEmIndex(emId)
	local bFound = false
	local emAlphaIndex = 0
	for i=1,self.nbEmote do
		if (self.alphaList[i][2] == emId) then
			emAlphaIndex = self.alphaList[i][1]
			bFound = true
			break
		end
	end
	
	if not bFound then
		d("TiEmote - error: emote not found")
		return 1
	end
	
	local emListIndex = emAlphaIndex - TE.sliderOffset
	return emListIndex
end

function TE:PlayEmote(emListId, list)
	local emId = 0
	if list == 0 then
		emId = TE:GetEmIndexFromEmListIndex(emListId)
	else
		emId = emListId
	end
	PlayEmoteByIndex(emId)
end

function TE:GetEmoteSlashName(emListId, list)
	local emId = 0
	if list == 0 then -- from emote list
		emId = self:GetEmIndexFromEmListIndex(emListId)
	else	-- from fav list
		emId = emListId
	end
	
	if emId ~= nil and TE.locale.EmoteTable[emId] then
		return TE.locale.EmoteTable[emId]
	else
		return "|cFF0000*"..tostring(emId).."|r "..GetEmoteSlashNameByIndex(emId) --non translated emote => mark red *
	end
end


--###  FAV  ###--
-----------------
function TiEmoteToggleOrderFav(button)
	-- Click on setting button
	local group = tonumber(string.sub(button:GetName(), 12, 12))
	if TE.orderFav[group] == nil then TE.orderFav[group] = false end
	
	TE.orderFav[group] = not TE.orderFav[group]
	TE:UpdateOrderFav(group)
end

function TE:UpdateOrderFav(group)
	-- Display/hide Up&Down buttons+color btn for each fav
--d("UpdateOrderFav:"..tostring(group))
--d(TE.orderFav[group])

	local button_up, button_down, button_color
	local n = 0
	if TE.fav[group] then n = table.getn(TE.fav[group]) end
	if n>0 then
		if TE.orderFav[group] then
			-- show
			local favListControl = GetControl("TE_FavPanel"..tostring(group).."FavList")
			local favBtnControl
			local isValidAnchor, point, relativeTo, relativePoint
			--local offsetXup, offsetYup, offsetXdown, offsetYdown, offsetXcolor, offsetYcolor

			for i=1,n do
				favBtnControl = GetControl("TE_FavPanel"..tostring(group).."FavList"..tostring(i))
				button_down = GetControl("TE_FavPanel"..tostring(group).."FavList"..tostring(i).."down")
				if button_down == nil then
					button_down = CreateControlFromVirtual("TE_FavPanel"..tostring(group).."FavList", favListControl, "TE_DownButton", tostring(i).."down")
					button_down:SetDrawLayer(DL_OVERLAY)
					button_down:SetDrawTier(DT_HIGH)
					button_down:SetDrawLevel(1)
					if button_down:GetHandler("OnClicked") == nil then button_down:SetHandler("OnClicked", function(self) TE:FavDown(i, group) end) end
					if i ==1 then --keep original offsets
						_, _, _, _, TE.xOffset.down, TE.yOffset.down = button_down:GetAnchor()
					end
				end
				button_down:ClearAnchors()
				if TE.lineMode or TE.vars.orientation[group] == 2 then
					button_down:SetNormalTexture("TiEmote/img/right_d.dds")
					button_down:SetPressedTexture("TiEmote/img/right.dds")					
					button_down:SetAnchor(BOTTOM, favBtnControl, TOP, 20, 2)
				else
					button_down:SetNormalTexture("TiEmote/img/down_d.dds")
					button_down:SetPressedTexture("TiEmote/img/down.dds")					
					button_down:SetAnchor(LEFT, favBtnControl, RIGHT, -10, 1)
				end
				button_down:SetHidden(i == n)

				button_up = GetControl("TE_FavPanel"..tostring(group).."FavList"..tostring(i).."up")
				if button_up == nil then
					button_up = CreateControlFromVirtual("TE_FavPanel"..tostring(group).."FavList", favListControl, "TE_UpButton", tostring(i).."up")
					button_up:SetDrawLayer(DL_OVERLAY)
					button_up:SetDrawTier(DT_HIGH)
					button_up:SetDrawLevel(1)
					if button_up:GetHandler("OnClicked") == nil then button_up:SetHandler("OnClicked", function(self) TE:FavUp(i, group) end) end
					if i ==1 then --keep original offsets
						_, _, _, _, TE.xOffset.up, TE.yOffset.up = button_up:GetAnchor()
					end
				end
				button_up:ClearAnchors()
				if TE.lineMode or TE.vars.orientation[group] == 2 then
					button_up:SetNormalTexture("TiEmote/img/left_d.dds")
					button_up:SetPressedTexture("TiEmote/img/left.dds")					
					button_up:SetAnchor(BOTTOM, favBtnControl, TOP, 0, 1)
				else
					button_up:SetNormalTexture("TiEmote/img/up_d.dds")
					button_up:SetPressedTexture("TiEmote/img/up.dds")					
					button_up:SetAnchor(LEFT, favBtnControl, RIGHT, 7, 0)
				end
				button_up:SetHidden(i == 1)

				button_color = GetControl("TE_FavPanel"..tostring(group).."FavList"..tostring(i).."color")
				if button_color == nil then
					button_color = CreateControlFromVirtual("TE_FavPanel"..tostring(group).."FavList", favListControl, "TE_ColorButton", tostring(i).."color")
					button_color:SetDrawLayer(DL_OVERLAY)
					button_color:SetDrawTier(DT_HIGH)
					button_color:SetDrawLevel(1)
					button_color:SetTextureCoords(.1,.9,.1,.9)
					if button_color:GetHandler("OnClicked") == nil then button_color:SetHandler("OnClicked", function(self,button) 
												if button==1 then
													TE:NextFavColor(TE.fav[group][i][1], group)
												else
													TE:PrevFavColor(TE.fav[group][i][1], group)												
												end
											end)
					end
					if i ==1 then --keep original offsets 
						_, _, _, _, TE.xOffset.color, TE.yOffset.color = button_color:GetAnchor()
					end
				else
					button_color:SetHidden(false)
				end
				button_color:ClearAnchors()
				if TE.lineMode or TE.vars.orientation[group] == 2 then
					button_color:SetAnchor(BOTTOM, favBtnControl, TOP, -20, 2)
				else
					button_color:SetAnchor(LEFT, favBtnControl, RIGHT, -30, 1)
				end
			end
		else
			-- hide
			for i=1,n do
				button_up = GetControl("TE_FavPanel"..tostring(group).."FavList"..tostring(i).."up")
				if button_up ~= nil then
					button_up:SetHidden(true)
				end
				button_down = GetControl("TE_FavPanel"..tostring(group).."FavList"..tostring(i).."down")
				if button_down ~= nil then
					button_down:SetHidden(true)
				end
				button_color = GetControl("TE_FavPanel"..tostring(group).."FavList"..tostring(i).."color")
				if button_color ~= nil then
					button_color:SetHidden(true)
				end
			end
		end
	end
end

function TE:FavUp(idfav, group)
	local old = TE.fav[group][idfav][1]
	TE.fav[group][idfav][1] = old - 1
	TE.fav[group][idfav-1][1] = old
	table.sort(TE.fav[group], function(a,b) return a[1] < b[1] end)
	TE.vars.fav = TE.fav
	
	self:UpdateFav(group)
end
function TE:FavDown(idfav, group)
	local old = TE.fav[group][idfav][1]
	TE.fav[group][idfav][1] = old + 1
	TE.fav[group][idfav+1][1] = old
	table.sort(TE.fav[group], function(a,b) return a[1] < b[1] end)
	TE.vars.fav = TE.fav
	
	self:UpdateFav(group)
end

function TE:ToggleFav(fav, list)
	-- click on emote btn to add/remove fav
-- fav = emListIndex or favIndex
-- list = 0 for emote list; 1-n for group
--d("--ToggleFav: "..fav..", "..list)
	local bFav = false
	local idFav = 0
	local emIndex = 0
	local group
	
	if list == 0 then -- from emote list
		emIndex = self:GetEmIndexFromEmListIndex(fav)
		if TE.selGroup == nil then
			-- no selected group = cannot add item
			TE:Msg(TE.locale.Message_notSelGroup)
			return
		end
		group = TE.selGroup
	else -- from fav group
		emIndex = fav
		group = list
	end
	
	local n = 0
	if TE.fav[group] then n = table.getn(TE.fav[group]) end
	for i=1, n do
		if (TE.fav[group][i][2] == emIndex) then
			bFav = true
			idFav = i
			break
		end
	end

	if bFav then
		--d("already fav -> remove")
--		self:ShowGroup(group, false)
		table.remove(TE.fav[group],idFav)
		self:UpdateFavIndex(group)
		self:UpdateFav(group)
		self:RemoveFavButton(n, group)
	else
		--d("not in fav -> add")
		if TE.fav[group] == nil then TE.fav[group] = {} end
		--same color as original
		local color = 0
		for j=1, table.getn(TE.color) do
			if (TE.color[j][1] == emIndex) then
				color = TE.color[j][2]
				break
			end
		end
		table.insert(TE.fav[group],{n+1,emIndex,color})
		--table.sort(TE.fav[group], function(a,b) return a[1] < b[1] end)
--		d(TE.fav[group])
		self:UpdateFav(group)
	end
	
	TE.vars.fav = TE.fav
	if TE.orderFav[group] then
		self:UpdateOrderFav(group)
	end
end

function TE:UpdateFavIndex(group)
	if not(group) then group = TE.selGroup end
	
	for i=1, table.getn(TE.fav[group]) do
		TE.fav[group][i][1] = i
	end
end

function TE:UpdateFav(group)
--d("UpdateFav:"..group)

	if group == nil then group = TE.selGroup end
	
	-- fill fav list for group
	local n = 0
	if TE.fav[group] then n = table.getn(TE.fav[group]) end
	if n>0 then
		local favListControl = GetControl("TE_FavPanel"..tostring(group).."FavList")
		local buttonControl, color, isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY
		for i=1,n do
			-- place each fav button
			buttonControl = GetControl("TE_FavPanel"..tostring(group).."FavList"..tostring(i))
			if buttonControl == nil then
				buttonControl = CreateControlFromVirtual("TE_FavPanel"..tostring(group).."FavList", favListControl, "TE_FavButton", tostring(i))
				buttonControl:SetDrawLayer(DL_BACKGROUND)
				buttonControl:SetDrawTier(DT_LOW)
				buttonControl:SetDrawLevel(0)
				buttonControl:SetHandler("OnClicked", function(self,button)
														if (button==1) then
															TE:PlayEmote(TE.fav[group][i][2],1) 
														else	
															TE:ToggleFav(TE.fav[group][i][2],group)
														end
													end)
				buttonControl:SetHandler("OnMouseDoubleClick", function(self) TE:NextFavColor(TE.fav[group][i][1], group) end)
			else
				buttonControl:SetHidden(false)
			end
			buttonControl:SetText(TE:GetEmoteSlashName(TE.fav[group][i][2],1))
			color = TE:GetColor(TE.fav[group][i][3])
			buttonControl:SetNormalFontColor(color[1], color[2], color[3], color[4])
			buttonControl:SetMouseOverFontColor(color[1], color[2], color[3], color[4])
			buttonControl:SetPressedFontColor(color[1], color[2], color[3], color[4])
			isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = buttonControl:GetAnchor()
			buttonControl:ClearAnchors()
			if TE.lineMode or TE.vars.orientation[group] == 2 then
				buttonControl:SetAnchor(point, relativeTo, relativePoint, TE.xOffset.Fav+(i-1)*TE.btnSize-10, 0)
			else
				buttonControl:SetAnchor(point, relativeTo, relativePoint, TE.xOffset.Fav, (TE.yOffset.Fav+(i-1)*DEFAULT_BUTTON_HEIGHT))
			end
		end
	end
end

function TE:RemoveFavButton(fav, group)
--d("--RemoveFavButton:"..tostring(fav))
	local buttonControl = GetControl("TE_FavPanel"..tostring(group).."FavList"..tostring(fav))
	if buttonControl ~= nil then buttonControl:SetHidden(true) end
	buttonControl = GetControl("TE_FavPanel"..tostring(group).."FavList"..tostring(fav).."down")
	if buttonControl ~= nil then buttonControl:SetHidden(true) end
	buttonControl = GetControl("TE_FavPanel"..tostring(group).."FavList"..tostring(fav).."up")
	if buttonControl ~= nil then buttonControl:SetHidden(true) end
	buttonControl = GetControl("TE_FavPanel"..tostring(group).."FavList"..tostring(fav).."color")
	if buttonControl ~= nil then buttonControl:SetHidden(true) end
end


--###  GROUPS  ###--
--------------------
function TE:InitGroup()
	-- Initialize all groups (panel with buttons + fav list)
	local nbGroup = table.getn(TE.group)
	local panelControl, settingControl, buttonControl, favListControl
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY
	local group, i, n

	for group=1, nbGroup do --TE.maxGroup do
		panelControl = GetControl("TE_FavPanel"..tostring(group))
		if panelControl == nil then
			panelControl = CreateControlFromVirtual("TE_FavPanel", TiEmote, "TE_FavPanel", tostring(group))
			panelControl:SetDrawLayer(DL_BACKGROUND)
			panelControl:SetDrawTier(DT_LOW)
			panelControl:SetDrawLevel(0)
		end
		if TE.groupMovable and TE.vars.anchorGroup[group] then
			panelControl:SetAnchor( TOPLEFT, GetControl("GuiRoot"), TOPLEFT, TE.vars.anchorGroup[group][1], TE.vars.anchorGroup[group][2])
		else
			isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = panelControl:GetAnchor()
			panelControl:ClearAnchors()
			if TE.lineMode then
				panelControl:SetAnchor(point, relativeTo, relativePoint, TE.xOffset.Panel, TE.yOffset.Panel+(group-1)*(DEFAULT_BUTTON_HEIGHT+20))
			else
				panelControl:SetAnchor(point, relativeTo, relativePoint, TE.xOffset.Panel+(group-1)*(TE.btnSize+30), TE.yOffset.Panel)
			end
		end

		settingControl = GetControl("TE_FavPanel"..tostring(group).."SettingsButton")
		isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = settingControl:GetAnchor()
		settingControl:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
		if settingControl:GetHandler("OnClicked") == nil then settingControl:SetHandler("OnClicked", TiEmoteToggleOrderFav) end

		buttonControl = GetControl("TE_FavPanel"..tostring(group).."GroupButton")
		isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = buttonControl:GetAnchor()
		buttonControl:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
		if buttonControl:GetHandler("OnClicked") == nil then buttonControl:SetHandler("OnClicked", function(self,button) 
												if button==1 then
													TiEmoteToggleGroup(self, 1)
												else
													TiEmoteToggleGroup(self, 2)											
												end
											end)
		end
		if GetControl("TE_FavPanel"..tostring(group).."RandomButton"):GetHandler("OnClicked") == nil then GetControl("TE_FavPanel"..tostring(group).."RandomButton"):SetHandler("OnClicked", function(self,button) TiEmoteRandom(group) end) end


		if TE.group[group] ~= nil then
			buttonControl:SetText(TE.group[group])
			panelControl:SetHidden(false)
			TE:UpdateFav(group)
			TE:ShowGroup(group, false)
		else
			panelControl:SetHidden(true)
		end
	end
end

function TiEmoteToggleGroup(button, value)
	-- onclick function for group buttons
	TE:TiEmoteToggleGroup(button,value)
end
function TE:TiEmoteToggleGroup(button,value)
	-- click group button (left=open/close; right=Select)
	local group
	if button~=nil then
		group = tonumber(string.sub(button:GetName(), 12, 12))
	else
		group = button
	end
--	d("TiEmoteToggleGroup:"..tostring(group))
--	d(value)

	if value == 1 then
		-- open/close group
		if GetControl("TE_FavPanel"..tostring(group).."FavList"):IsControlHidden() then
			TE:ShowGroup(group, true)
		else
			TE.orderFav[group] = false
			TE:UpdateOrderFav(group)
			TE:ShowGroup(group, false)
		end
	else
		-- select group
		if group == TE.selGroup then
			-- same -> deselect
			WINDOW_MANAGER:GetControlByName("TE_FavPanel"..group.."GroupButton"):SetText(TE.group[group])
			TE.selGroup = nil
		else
			--deselect old one and select new groupe
			if group == nil then group = TE.selGroup end
			if TE.selGroup ~= nil then
				WINDOW_MANAGER:GetControlByName("TE_FavPanel"..TE.selGroup.."GroupButton"):SetText(TE.group[TE.selGroup])
			end
			WINDOW_MANAGER:GetControlByName("TE_FavPanel"..group.."GroupButton"):SetText("|c"..COLOR_KHRILLSELECT..TE.group[group].."|r")
			TE.selGroup = group
			TE:ShowGroup(group, true)
		end	
	end
end

function TE:ShowGroup(group, state)
	if group == nil then group = TE.selGroup end
--d("ShowGroup:"..group..", "..tostring(state))

	-- show/hide Fav list panel
	local panelControl = GetControl("TE_FavPanel"..tostring(group))
	if panelControl ~= nil then
		--resize group panel
		if state then
			local n = 0
			if TE.fav[group] then n = table.getn(TE.fav[group]) end
			if TE.lineMode or TE.vars.orientation[group] == 2 then
				panelControl:SetHeight(2*DEFAULT_BUTTON_HEIGHT +TE.yOffset.Fav)
				panelControl:SetWidth((n)*(TE.btnSize+30) +TE.xOffset.Fav)
			else
				panelControl:SetHeight((n+2)*DEFAULT_BUTTON_HEIGHT +TE.yOffset.Fav)
				panelControl:SetWidth((TE.btnSize+30) +TE.xOffset.Fav)
			end
		else
			panelControl:SetHeight(2*DEFAULT_BUTTON_HEIGHT +TE.yOffset.Fav)
			panelControl:SetWidth((TE.btnSize+30) +TE.xOffset.Fav)
		end
		
		local listControl = GetControl("TE_FavPanel"..tostring(group).."FavList")
		if listControl ~= nil then
			listControl:SetHidden(not state)
			-- adapt position & height for Fav's panel
			local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = listControl:GetAnchor()
			local buttonControl = GetControl("TE_FavPanel"..tostring(group).."GroupButton")
			if TE.lineMode or TE.vars.orientation[group] == 2 then
				listControl:SetAnchor(LEFT, buttonControl, RIGHT, -20, -2)
--				listControl:SetAnchor(point, relativeTo, relativePoint, TE.xOffset.Fav+TE.btnSize+20, TE.yOffset.Fav+2)
			else
				listControl:SetAnchor(TOP, buttonControl, BOTTOM, 0, 5)
--				listControl:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
			end
			if state then
				local n = 0
				if TE.fav[group] then n = table.getn(TE.fav[group]) end
				if TE.lineMode or TE.vars.orientation[group] == 2 then
					listControl:SetHeight(DEFAULT_BUTTON_HEIGHT +TE.yOffset.Fav)
					listControl:SetWidth(n*(TE.btnSize+30) +TE.xOffset.Fav)
				else
					listControl:SetHeight(n*DEFAULT_BUTTON_HEIGHT +TE.yOffset.Fav)
					listControl:SetWidth((TE.btnSize+30) +TE.xOffset.Fav)
				end
			else
				listControl:SetHeight(DEFAULT_BUTTON_HEIGHT +TE.yOffset.Fav)
				listControl:SetWidth((TE.btnSize+30) +TE.xOffset.Fav)
			end
		end
		-- show/hide setting button
		local settingControl = GetControl("TE_FavPanel"..tostring(group).."SettingsButton")
		if settingControl ~= nil then
			settingControl:SetHidden(not state)
		end
	end
end

function TE:AddGroup(group)
	-- New group
--d("--AddGroup:"..tostring(group))
	TE.group[group] = TE.locale.Settings_groupNoname
	TE.vars.group = TE.group
	TE:InitGroup()
end
function TE:RemoveGroup(group)
	-- remove group
	TE.group[group] = nil
	TE.vars.group = TE.group
	-- verif random group
	if group == TE.vars.randomList then TE.vars.randomList = 0 end
	
	local panelControl = GetControl("TE_FavPanel"..tostring(group))
	if panelControl ~= nil then
		panelControl:SetHidden(true)
	else
		TE:UpdateGroup(group)
	end
end

function TE:UpdateGroup(group)
	-- Update group buttons text
	if group ~= nil then
		local buttonControl = GetControl("TE_FavPanel"..tostring(group).."GroupButton")
		if TE.group[group] ~= nil and buttonControl ~= nil then
			buttonControl:SetText(TE.group[group])
			buttonControl:SetHidden(false)
		else
			if buttonControl ~= nil then buttonControl:SetHidden(true) end
		end
	else
		for i=1, TE.maxGroup do
			TE:UpdateGroup(i)
		end
	end
end


--###  COLOR  ###--
--------------------
function TE:GetColor(idcolor)
	return TE.fontColor[idcolor+1]
end

function TE:NextColor(idbutton)
	local button = GetControl("TE_EmoteButton"..tostring(idbutton))
	local emId = self:GetEmIndexFromEmListIndex(idbutton+1)
--d(idbutton..","..emId)
	local bColor = false
	local idColor = 0
	
	for i=1,table.getn(TE.color) do
		if (TE.color[i][1] == emId) then
			bColor = true
			idColor = i
			break
		end
	end
	
	local color = self:GetColor(0)
	if bColor then
		local numColor = TE.color[idColor][2]
		
		if numColor < TE.maxColor - 1 then
			TE.color[idColor][2] = numColor + 1
			color = self:GetColor(numColor+1)
		else
			color = self:GetColor(0)
			table.remove(TE.color,idColor)
		end
	else
		color = self:GetColor(1)
		table.insert(TE.color,{emId,1})
	end
	button:SetNormalFontColor(color[1], color[2], color[3], color[4])
	button:SetMouseOverFontColor(color[1], color[2], color[3], color[4])
	button:SetPressedFontColor(color[1], color[2], color[3], color[4])
	
	TE.vars.color = TE.color
end

function TE:PrevFavColor(idfav, group)
	if group == nil then group = TE.selGroup end

	local button = GetControl("TE_FavPanel"..tostring(group).."FavList"..tostring(idfav))
	local idColor = TE.fav[group][idfav][3]

	if idColor == 0 then
		idColor = TE.maxColor - 1
	else
		idColor = idColor - 1
	end
	TE.fav[group][idfav][3] = idColor
	color = TE:GetColor(idColor)
	
	button:SetNormalFontColor(color[1], color[2], color[3], color[4])
	button:SetMouseOverFontColor(color[1], color[2], color[3], color[4])
	button:SetPressedFontColor(color[1], color[2], color[3], color[4])
	
	TE.vars.fav = TE.fav
end
function TE:NextFavColor(idfav, group)
	if group == nil then group = TE.selGroup end
	
	local button = GetControl("TE_FavPanel"..tostring(group).."FavList"..tostring(idfav))
	local idColor = TE.fav[group][idfav][3]
	
	if idColor == TE.maxColor - 1 then
		idColor = 0
	else
		idColor = idColor + 1
	end
	TE.fav[group][idfav][3] = idColor
	color = self:GetColor(idColor)
	
	button:SetNormalFontColor(color[1], color[2], color[3], color[4])
	button:SetMouseOverFontColor(color[1], color[2], color[3], color[4])
	button:SetPressedFontColor(color[1], color[2], color[3], color[4])
	
	TE.vars.fav = TE.fav
end

function TE:UpdateColor()
	for i=1, TE.nbRow do
		local emId = self:GetEmIndexFromEmListIndex(i)
		local button = GetControl("TE_EmoteButton"..tostring(i-1))
		if (button ~= nil) then
			local bFound = false
			local idFound = 0
			local color
			for j=1, table.getn(TE.color) do
				if (TE.color[j][1] == emId) then
					bFound = true
					idFound = TE.color[j][2]
					break
				end
			end
			
			if bFound then
				color = self:GetColor(idFound)
			else
				color = self:GetColor(0)
			end
			button:SetNormalFontColor(color[1], color[2], color[3], color[4])
			button:SetMouseOverFontColor(color[1], color[2], color[3], color[4])
			button:SetPressedFontColor(color[1], color[2], color[3], color[4])
		end
	end
end


--###  UI/SETTINGS  ###--
-------------------------
function TE:GetLanguage()
	local lang = GetCVar("language.2")
--lang = "en" --for testing
	--check for supported languages
	if (lang == "fr") then return lang end
	if (lang == "de") then return lang end
	if (lang == "es") then return lang end

	--return english if not supported
	return "en"
end

function TE:UpdateRandomButton()
	-- Change random button texture
	-- main list
	local button = GetControl("TE_EmoteRandomButton")
	if button ~= nil then
		if TE.vars.randomList == 0 then --selected
			button:SetNormalTexture(TEXTURES["EMOTERANDOMFAV"])
		else -- others
			button:SetNormalTexture(TEXTURES["EMOTERANDOM"])
		end
	end
	-- groups
	local nbGroup = table.getn(TE.group)
	for group=1,nbGroup do
		button = GetControl("TE_FavPanel"..tostring(group).."RandomButton")
		if TE.vars.randomList == group then --selected
			button:SetNormalTexture(TEXTURES["EMOTERANDOMFAV"])
		else -- others
			button:SetNormalTexture(TEXTURES["EMOTERANDOM"])
		end
	end
end

function TE:ShowUI(state)
	-- show all groups buttons or only title
	for i=1,TiEmote:GetNumChildren() do
		local name = TiEmote:GetChild(i):GetName()
		if name ~= "TiEmoteLabel" and name ~= "TE_ShowListButton" and name ~= "TE_EmoteRandomButton" then 
			TiEmote:GetChild(i):SetHidden(not state)
		end
	end
	TE.showList = state
	TE:ShowList()
end

-- PROFILE FUNCTIONS --
local function CopyTable(src, dest)
	if type(dest) ~= 'table' then dest = {} end
	if type(src) == 'table' then
		for k, v in pairs(src) do
			if type(v) == 'table' then
				CopyTable(v, dest[k])
			end
			dest[k] = v
		end
	end
end
local function CopySettingsFrom(src)
	local srcData, destData
	local dest = GetUnitName('player')

	for account, accountData in pairs(TiEmote_Vars.Default) do
		for character, data in pairs(accountData) do
			if character == src then -- source character data
				srcData = data
			end

			if character == dest then -- dest character data (current character)
				destData = data
			end
		end
	end

	if (not srcData or not destData) then
		d(TE.name .. ': Unable to find character settings to copy!')
		return
	end

	CopyTable(srcData, destData) -- copy settings

	ReloadUI() -- reloadui to re-initialize
end

local function GenerateCharacterList()
	local playerSettingsList = {}
	local current = GetUnitName('player')
	for account, accountData in pairs(TiEmote_Vars.Default) do
		if account == ZO_DisplayNameDisplayName:GetText() then
			for player, data in pairs (accountData) do
				if player ~= current then
					table.insert(playerSettingsList, player)
				end
			end
		end
	end
	table.sort(playerSettingsList)

	return playerSettingsList
end

-- INIT --
function TE:InitUI()
	local i, ButtonControl
	--List of all emotes
	for i=0, TE.nbRow-1 do
		ButtonControl = CreateControlFromVirtual("TE_EmoteButton", TE_EmotePanel, "TE_EmoteButton", i)
		isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = ButtonControl:GetAnchor()
		ButtonControl:SetAnchor(point, relativeTo, relativePoint, offsetX, TE.yOffset.Fav+i*DEFAULT_BUTTON_HEIGHT)
		ButtonControl:SetText(TE:GetEmoteSlashName(i+1,0))
		ButtonControl:SetHandler("OnClicked", function(self,button)
					if button==1 then
						TE:PlayEmote((i+1),0) 
					else
						TE:ToggleFav((i+1),0)
					end
				end)
		ButtonControl:SetHandler("OnMouseWheel", function(self, delta) TE:OnMouseWheel(delta) end)
		ButtonControl:SetHandler("OnMouseDoubleClick", function(self) TE:NextColor(i) end)
		ButtonControl:SetMouseOverFontColor(HexToRGBA("FF6A0000"))
		ButtonControl:SetPressedFontColor(HexToRGBA("FF6A0000"))
	end
	
	-- slider
	TE.slider = CreateControl("TESlider",TE_EmotePanel,CT_SLIDER)
	TE.slider:SetDimensions(30,TE.nbRow*DEFAULT_BUTTON_HEIGHT)
	TE.slider:SetMouseEnabled(true)
	TE.slider:SetThumbTexture(TE.tex,TE.tex,TE.tex,20,50,0,0,1,1)
	TE.slider:SetMinMax(0,TE.nbEmote-TE.nbRow)
	TE.slider:SetValueStep(1)
	TE.slider:SetAnchor(TOPLEFT,TE_EmotePanel,TOPLEFT,140,TE.yOffset.Fav)
	TE.slider:SetHandler("OnValueChanged",function(self,value,eventReason) TE:OnSliderMove(value) end)

	-- update UI with localization
    WINDOW_MANAGER:GetControlByName("TiEmoteLabel"):SetText(TE.name)
    WINDOW_MANAGER:GetControlByName("TE_ShowListButton"):SetText(TE.locale.UI_list)
	
	-- init TE.orderFav = false for all group
	for i=1, #TE.fav do
		TE.orderFav[i] = false
	end
	TiEmote:SetHidden(true)
end

function TE:InitConfigPanel()
	-- LAM2 Settings
	local LAM2 = LibStub("LibAddonMenu-2.0")
	if ( not LAM2 ) then return end

	local cPanelId="TiEmoteConfigPanel"
	local ADDON_NAME= TE.name .." |c"..COLOR_KHRILLSELECT.."Extended|r"
	local ADDON_VERSION="v"..TE.bversion
	local i
	local characterList = GenerateCharacterList()
	local sourceCharacter = nil
	local groupListe= {}
	groupListe[1]=TE.locale.UI_all
	for i=1,#TE.group do
		groupListe[i+1]=TE.group[i]
	end

	if TE.configPanel == nil then
		local panelData = {
			type = "panel",
			name = ADDON_NAME,
			displayName = ADDON_NAME .. " (" .. TE.locale.LOCALE .. ")",
			author = "|cB70E99Rosie|r (Original) - |c"..COLOR_KHRILLSELECT.."Khrill|r (Extended)",
			version = ADDON_VERSION,
			slashCommand = "/tiemote",
			registerForRefresh = true,
			registerForDefaults = true,
			resetFunc = function()
--					TE.vars	= TE.default
					TE.vars.group = TE.default.group
--					TE.vars.fav = TE.default.fav
					TE.vars.anchor = TE.default.anchor
					TE.vars.anchorGroup = TE.default.anchorGroup
					ReloadUI()
			end,	--(optional) custom function to run after settings are reset to defaults
		}
		TE.configPanel = LAM2:RegisterAddonPanel(cPanelId, panelData)
	end 
	
	local optionsTable = {
		{
			type = "header",
			name = "|c"..COLOR_KHRILLSELECT..TE.locale.Settings_control.."|r",
			width = "full",
		},
		------------GENERAL--------------
		{	-- movable
			type = "checkbox",
			name = TE.locale.Settings_title1,
			tooltip = TE.locale.Settings_description1,
			getFunc = function() return (TE.vars.movable) end,
			setFunc = function(newValue) TE:ToggleMovable(newValue) end,
			width = "full",
			default = TE.default.movable,
		},
		{	-- group movable
			type = "checkbox",
			name = TE.locale.Settings_title2,
			tooltip = TE.locale.Settings_description2,
			getFunc = function() return (TE.vars.groupMovable) end,
			setFunc = function(newValue) TE:ToggleGroupMovable(newValue) end,
			width = "full",
			disabled = function() return not(TE.vars.movable) end,
			default = TE.default.groupMovable,
		},
		{	-- display fav in line
			type = "checkbox",
			name = TE.locale.Settings_title4,
			tooltip = TE.locale.Settings_description4,
			getFunc = function() return (TE.vars.lineMode) end,
			setFunc = function(newValue) TE:ToggleLineMode(newValue) end,
			width = "full",
			disabled = function() return TE.vars.groupMovable end,
			default = TE.default.lineMode,
		},
		{	-- opacity
			type = "slider",
			name = TE.locale.Settings_title3,
			tooltip = TE.locale.Settings_description3,
			min = 0,
			max = 1,
			step = 0.1,
			getFunc = function() return TE.opacity end,
			setFunc = function(newValue) TE:SetOpacity(newValue) end,
			width = "full",
			default = TE.default.opacity,
		},
		{	-- deploy groups when opening
			type = "checkbox",
			name = TE.locale.Settings_openDeploy,
			tooltip = TE.locale.Settings_openDeployTip,
			getFunc = function() return (TE.vars.openDeploy) end,
			setFunc = function(newValue) TE.vars.openDeploy = newValue end,
			width = "full",
			default = TE.default.openDeploy,
		},
		------------ACTIVATION--------------
		{
			type = "header",
			name = "|c"..COLOR_KHRILLSELECT..TE.locale.Settings_activate.."|r",
			width = "full",
		},
		{
			type = "description",
--			title = "|cFF6A00"..TE.locale.Settings_activate.."|r",
			text = TE.locale.Settings_keybind,
			width = "full",
		},
		{	-- keybind only
			type = "checkbox",
			name = TE.locale.Settings_title0,
			tooltip = TE.locale.Settings_description0,
			getFunc = function() return (TE.vars.keybindOnly) end,
			setFunc = function(newValue) TE.vars.keybindOnly = newValue end,
			width = "full",
			default = TE.default.keybindOnly,
		},
		{ -- group for random emote
			type = "description",
			text = TE.locale.Settings_randomDescription,
			width = "full",
		},
		{	
			type = "dropdown",
			name = TE.locale.Settings_randomLabel,
			choices = groupListe,
			getFunc = function() return groupListe[tonumber(TE.vars.randomList)+1] end,
			setFunc = function(newValue)
			d(newValue)
					TE.vars.randomList = tonumber(getKeyByValue(groupListe, newValue))-1
					TE:UpdateRandomButton()
			end,
			width = "full",
			default = groupListe[tonumber(TE.default.randomList)+1],
		},
		------------IMPORT--------------
		{
			type = "header",
			name = "|c"..COLOR_KHRILLSELECT..TE.locale.Settings_import.."|r",
			width = "full",
		},
		{
			type = "description",
			text = TE.locale.Settings_title5,
			width = "full",
		},
		{
			type = "dropdown",
			name = TE.locale.Settings_description5,
--			tooltip = TE.locale.Settings_choose,
			choices = characterList,
			getFunc = function() 
					if (#characterList >= 1) then
						sourceCharacter = characterList[1]
						return characterList[1]
					end
				end,
			setFunc = function(value) sourceCharacter = value end,
			width = "half",
--			disabled = function() return (#characterList == 0) end,
		},
		{
			type = "button",
			name = TE.locale.Settings_importBtn,
			tooltip = TE.locale.Settings_importBtnTip,
			func = function() CopySettingsFrom(sourceCharacter) end,
			width = "half",
			disabled = function() return (#characterList == 0) end,
			warning = TE.locale.Settings_warning,
		}
	}
	
	------------GROUPS--------------
	local index = #optionsTable +1
	optionsTable[index] = {
			type = "header",
			name = "|c"..COLOR_KHRILLSELECT..TE.locale.Settings_group.."|r",
			width = "full",
		}
	for i=1, #TE.group do
		-- index = index + 1
		-- optionsTable[index] = { -- title
			-- type = "description",
			-- title = "|c"..COLOR_KHRILLSELECT..TE.locale.Settings_groupItem.." "..tostring(i).."|r",
			-- text = "",
			-- width = "half",
		-- }
		index = index + 1
		optionsTable[index] = { -- name
			type = "editbox",
--			name = TE.locale.Settings_groupItemTip.." "..tostring(i),
			name = "|c"..COLOR_KHRILLSELECT..TE.locale.Settings_groupItem.." "..tostring(i).."|r",
			tooltip = TE.locale.Settings_groupItemTip.." "..tostring(i),
			getFunc = function() return (TE.group[i]) end,
			setFunc = function(newValue)
				TE.group[i] = newValue
				if not(TE.reload) then
					TE:UpdateGroup(i)
				end
			end,
			warning = TE.locale.Settings_warning,
			width = "full",
		}
		index = index + 1
		optionsTable[index] = { -- enable
			type = "checkbox",
			name = TE.locale.Settings_enable,
			tooltip = TE.locale.Settings_enable,
			getFunc = function() return (TE.group[i] ~= nil) end,
			setFunc = function(newValue)
				if newValue then
					TE:AddGroup(i)
				else
					TE:RemoveGroup(i)
				end
			end,
			width = "half",
			default = function()
					if TE.default.group[i] then
						return true
					else 
						return false
					end
			end
		}
		index = index + 1
		optionsTable[index] = { -- orientation
			type = "dropdown",
			name = TE.locale.Settings_groupDisplay,
			tooltip = TE.locale.Settings_groupDisplayTip,
			choices = TE.locale.OrientationList,
			getFunc = function() return (TE.locale.OrientationList[TE.vars.orientation[i]]) end,
			setFunc = function(newValue)
				TE.vars.orientation[i] = getKeyByValue(TE.locale.OrientationList, newValue)
				if not(TE.reload) then
					TE:UpdateFav(i)
					TE:ShowGroup(i, false)
				end
			end,
			width = "half",
			disabled = function() return (not(TE.group[i] ~= nil) or not(TE.groupMovable)) end,
			default = TE.default.orientation[1]
		}
		index = index + 1
		optionsTable[index] = {
			type = "header",
			name = "",
			width = "full",
		}
	end
	if #TE.group < TE.maxGroup then
		index = index + 1
		optionsTable[index] = {
			type = "button",
			name = TE.locale.Settings_groupNewBtn,
			tooltip = TE.locale.Settings_groupNewBtnTip,
			func = function()
						TE:AddGroup(#TE.group+1)
						ReloadUI()
					end,
			width = "full",
			warning = TE.locale.Settings_warning,
		}
	end
	LAM2:RegisterOptionControls(cPanelId, optionsTable)	
end

function TE:Msg(msg)
	CHAT_SYSTEM:AddMessage(TE.name.." : "..msg)
end

SLASH_COMMANDS["/emotelist"] = function()
	local EmoteList = {}
	for i=1,GetNumEmotes() do
		local slashName = GetEmoteSlashNameByIndex(i) 
		EmoteList[i] = slashName
	end
	d("[Ti|cB70E99Emote|r] ESO All emotes:")
	d(EmoteList)
	d("--total="..GetNumEmotes())
end

SLASH_COMMANDS["/tefix"] = function(stringArgs)
	d("-- Ti|cB70E99Emote|r Fix Emotes index --")
	args = string.split(stringArgs)
	if #args ~= 2 then
		d("*usage*: /tefix <startFromIndex> <decalValue>")
	elseif tonumber(args[1])==nil or tonumber(args[2])==nil then
		d("*error*: args must be numbers")		
	else
		--apply fix
		fixDecal(tonumber(args[1]), tonumber(args[2]))
		d("--fix |c00FF00OK|r")
		d("--your modified fav emotes list:")
		local maxgroup = table.getn(TE.fav)
		for group=1,maxgroup do
			local n = #TE.fav[group]
			if TE.fav[group] then n = table.getn(TE.fav[group]) end
			for i=1, n do
				d(TE.fav[group][i][1]..": "..TE.fav[group][i][2].."="..GetEmoteSlashNameByIndex(TE.fav[group][i][2]))
			end
		end
		d("**|c"..COLOR_KHRILLSELECT.."(type /emotelist to view ESO emotes list)|r**")
	end
end

-- SLASH_COMMANDS["/telist"] = function()
--	d(GenerateCharacterList())
--	d(TiEmote:GetNumChildren() )
	-- for i=1,TiEmote:GetNumChildren() do
		-- d(TiEmote:GetChild(i):GetName()) 
		-- d(TiEmote:GetChild(i):GetNumChildren()) 
		-- if TiEmoteGetChild(i):GetNumChildren() > 0 then
			-- for j=1,TiEmote:GetChild(i):GetNumChildren() do
				-- d("->"..TiEmote:GetChild(i):GetChild(j):GetName()) 
				-- d("->"..TiEmote:GetChild(i):GetChild(j):GetNumChildren()) 
			-- end
		-- end
	-- end
-- end