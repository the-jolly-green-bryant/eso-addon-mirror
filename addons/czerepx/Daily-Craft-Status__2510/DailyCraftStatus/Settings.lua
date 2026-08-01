local _addon = _G["DailyCraftStatus"]

local C_MAXITEMS = 6  --max number of custom materials
local C_DEFMINSTOCK = 50

local _out = _addon._out
local _outd = _addon._outd
local _translate = _addon._translate
local LAM = LibAddonMenu2

_addon.accountSettings = {}  -- initialized on load
_addon.characterSettings = {}  -- initialized on load
_addon.itemSearch = {}


function _addon.setLowThres(v)
	_addon.lowThres = v
	_addon.accountSettings.lowQtyThreshold = _addon.lowThres
	_addon.updateDailyCraftStates()
	_addon.showStatusBar()
end	

function _addon.setLowMatThres(v,accf)
	if accf then
		_addon.accountSettings.lowMatQtyThreshold = v
		if _addon.characterSettings.lowMatQtyThreshold==nil then
			_addon.lowMatThres = v
		end
	else	
		_addon.lowMatThres = v
		_addon.characterSettings.lowMatQtyThreshold = _addon.lowMatThres
	end	
	_addon.updateStock()
	_addon.showStatusBar(true)
end	

function _addon.setCharLowMat(v)
	_addon.lowMatThres = C_DEFMINSTOCK
	if _addon.accountSettings.lowMatQtyThreshold~=nil then
		_addon.lowMatThres = _addon.accountSettings.lowMatQtyThreshold
	end	
	if v then
		_addon.characterSettings.lowMatQtyThreshold = _addon.lowMatThres 
	else	
		_addon.characterSettings.lowMatQtyThreshold = nil
	end
	_addon.updateStock()
	_addon.showStatusBar(true)
end	

function _addon.setShowStock(v)
	_addon.showStock = v
	_addon.characterSettings.showStock = _addon.showStock
--	if _addon.showStock then _addon.stock:SetHidden(false) end
	_addon.updateStock()
	_addon.showStatusBar(true)
end

function _addon.setShowRawStock(v)
	_addon.showRawStock = v
	_addon.characterSettings.showRawStock = _addon.showRawStock
--	if _addon.showRawStock then _addon.stock:SetHidden(false) end
	_addon.updateStock()
	_addon.showStatusBar(true)
end

function _addon.setShowInvSpace(v)
	_addon.showInvSpace = v
	_addon.characterSettings.showInvSpace = _addon.showInvSpace
	_addon.updateDailyCraftStates()
	_addon.showStatusBar(true)
end

function _addon.setShowSurveys(v)
	_addon.showSurveys = v
	_addon.characterSettings.showSurveys = _addon.showSurveys
	_addon.updateSurveys()
	_addon.showStatusBar(true)
end

function _addon.setSurveyFigures(v)
	_addon.surveyFigures = string.sub(v,1,6)
	_addon.characterSettings.surveyFigures = _addon.surveyFigures
	_addon.updateSurveys()
	_addon.showStatusBar(true)
end	

function _addon.setQuestOrder(_v)
	local v = string.sub(_v,1,7)

	for  j=1,string.len(v) do
		local questIdx = string.find(C_QUESTORDER,string.lower(string.sub(v,j,j)))
		if not questIdx then
			_out("Invalid quest: "..string.sub(v,j,j).. ", use these letters: "..C_QUESTORDER)
			return
		end	
	end	

	_addon.questOrder = v
	_addon.accountSettings.questOrder = _addon.questOrder
	_addon.updateDailyCraftStates()
	_addon.showStatusBar(true)
end	


function _addon.setAlwaysOn(v)
	_addon.alwaysOn = v
	_addon.characterSettings.alwaysOn = _addon.alwaysOn
	--_addon.updateAll()
	_addon.showStatusBar()
end

function _addon.setAutoSavePos(v)
	_addon.autoSavePos = v
	_addon.accountSettings.autoSavePos = _addon.autoSavePos
end

function _addon.setHudOnly(v)
	_addon.unregisterSceneCallbacks()
	_addon.hudOnly = v
	_addon.accountSettings.hudOnly = _addon.hudOnly
	_addon.registerSceneCallbacks()
end

function _addon.setLowStockWarn(v)
	_addon.lowStockWarn = v
	_addon.accountSettings.lowStockWarn = _addon.lowStockWarn
	_addon.updateStock()
	_addon.showStatusBar(true)
end

function _addon.setInclConsum(v)
	_addon.inclConsum = v
	_addon.accountSettings.inclConsum = _addon.inclConsum
	_addon.updateStock()
	_addon.showStatusBar(true)
end

function _addon.setSepBackpQty(v)
	_addon.sepBackpQty = v
	_addon.accountSettings.sepBackpQty = _addon.sepBackpQty
	_addon.updateStock()
	_addon.showStatusBar(true)
end

function _addon.setUpdOnReset(v)
	_addon.updOnReset = v
	_addon.accountSettings.updOnReset = _addon.updOnReset
	_addon.updateDailyReset()
	_addon.updateDailyCraftStates()
	_addon.showStatusBar(true)
end

function _addon.setShowRideTrain(v)
	_addon.rideTrain = v
	_addon.accountSettings.rideTrain = _addon.rideTrain
	_addon.updateDailyCraftStates()
	_addon.showStatusBar(true)
end

function _addon.getTrackResearch(craft)
	return false or _addon.trackResearch[craft] 
end

function _addon.setTrackResearch(craft,v)
	if (v) then 
		_addon.trackResearch[craft] = v
	else
		_addon.trackResearch[craft] = nil
	end
	_addon.characterSettings.trackResearch = _addon.trackResearch
	_addon.updateDailyCraftStates()
	_addon.showStatusBar(true)
end

function _addon.setKeepOnWarn(v)
	_addon.keepOnWarn = v
	_addon.accountSettings.keepOnWarn = _addon.keepOnWarn
	_addon.updateDailyCraftStates()
	_addon.showStatusBar(true)
end

function _addon.setKeepIcon(v)
	_addon.keepIcon = v
	_addon.accountSettings.keepIcon = _addon.keepIcon
end

function _addon.setTrackAlts(v)
	_addon.trackAlts = v
	_addon.accountSettings.trackAlts = _addon.trackAlts
	if _addon.trackAlts and _addon.altsModule then 
		_addon.altsModule.initialize()
	end		
end

function _addon.setSingleRow(v,userAction)
	if _addon.singleRow==v then return end
	_addon.singleRow = v
	_addon.updateAnchors()
	if userAction then
		if _addon.shareStyle then
			_addon.accountSettings.singleRow = _addon.singleRow
		else
			_addon.characterSettings.singleRow = _addon.singleRow
		end
		_addon.updateAll()
		_addon.showStatusBar(true)
	end	
end

function _addon.setAlignCenter(v,userAction)
	if _addon.alignCenter==v then return end
	_addon.alignCenter = v
	_addon.updateAnchors()
	if userAction then
		if _addon.shareStyle then
			--_addon.accountSettings.barCenter = nil
			_addon.accountSettings.alignCenter = _addon.alignCenter
		else
			--_addon.characterSettings.barCenter = nil
			_addon.characterSettings.alignCenter = _addon.alignCenter
		end
		_addon.updateAll()
		_addon.showStatusBar(true)
	end	
end

function _addon.setUseIcons(v,userAction)
	if _addon.useIcons==v then return end
	_addon.useIcons = v
	if userAction then
		if _addon.shareStyle then
			_addon.accountSettings.useIcons = _addon.useIcons
		else	
			_addon.characterSettings.useIcons = _addon.useIcons
		end	
		_addon.updateAll()
	end	
end

function _addon.setBgStyle(v)
	if v<0 or v>3 then return end
	_addon.bgStyle = v
	if _addon.shareStyle then
		_addon.accountSettings.bgStyle = _addon.bgStyle
	else
		_addon.characterSettings.bgStyle = _addon.bgStyle
	end
	_addon.updateBackgrounds()
	_addon.updatePosition()
	_addon.showStatusBar(true)
end

function _addon.setShareStyle(v)
	_addon.shareStyle = v
	_addon.accountSettings.shareStyle = _addon.shareStyle
	
	if _addon.shareStyle then
		local as = _addon.accountSettings
		as.uiScale  = _addon.uiScale 
		as.singleRow = _addon.singleRow
		as.useIcons = _addon.useIcons
		as.bgStyle = _addon.bgStyle
	end	

	_addon.updateAppearance()
	_addon.updateAll()
	_addon.showStatusBar(true)
end


local function DCS_findItemLinksFromText(_findText)
	if not _findText or _findText=="" then return {} end
	--searching for 1 kanji char actually makes sense...
	--if string.len(_findText)<3 then return {"min. 3 letters"} end
	local res = {}
	local findText = string.lower(_findText)
	local banks = { BAG_VIRTUAL, BAG_BACKPACK, BAG_BANK, BAG_SUBSCRIBER_BANK }
	local foundVec = {}
	for i=1,#banks do
		local slotId = ZO_GetNextBagSlotIndex(banks[i], nil)
		while slotId do
			local itemId = GetItemLinkItemId(GetItemLink(banks[i],slotId))
			if not foundVec[itemId] then
				local itemName = string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemName(banks[i],slotId)))
				--if (string.find(itemName,findText)==1) then 
				if string.find(itemName,findText) then 
					res[#res+1] = GetItemLink(banks[i],slotId,LINK_STYLE_BRACKETS)
					if #res>=20 then return res end
					--return GetItemLink(banks[i],slotId) 
				end
				foundVec[itemId] = true
			end	
			slotId = ZO_GetNextBagSlotIndex(banks[i], slotId)
		end	
	end
	for _,mats in pairs(_addon.DCS_TIERED_MATS) do
		for j=1,#mats do
			local itemId = mats[j]
			if not foundVec[itemId] then
				local itemLink = string.format("|H1:item:%d%s|h|h",itemId,string.rep(":0",20)) 
				local itemName = string.lower(zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink)))
				if string.find(itemName,findText) then 
					--if (string.find(itemName,findText)==1) then 
					res[#res+1] = itemLink
					if #res>=20 then return res end
					--return itemLink 
				end
				foundVec[itemId] = true
			end	
		end	
	end
	return res
end

function _addon.addItemFromSearch(accf)
	if not _addon.itemSearch.selected or _addon.itemSearch.selected=="" then return end
	local cmats = _addon.characterSettings.customMats
	if (accf) then cmats = _addon.accountSettings.customMats end
	
	function _firstfree()
		if cmats then
			for i=1,#cmats do
				if cmats[i]=="" then return i end
			end	
			if #cmats<C_MAXITEMS then return #cmats+1 end
			return nil
		end
		return 1
	end	
	local id = _firstfree()
	if id then
		local s = _addon.itemSearch.selected
		local n = "-"
		if _addon.itemSearch.low then 
			s = s..string.format(";%d",_addon.itemSearch.low)
			n = ""
		end
		if _addon.itemSearch.high then 
			s = s..n..string.format(";%d",_addon.itemSearch.high)
		end
		_addon.setCustomMat(id,s,accf)
	else
		_out("no free slots")
	end
end

--/script DailyCraftStatus.setCustomMats({"$   ","","",""})

function _addon.setCustomMats(mats,accf)
	if accf then
		_addon.accountSettings.customMats = mats
	else	
		_addon.characterSettings.customMats = mats
	end	
	_addon.updateStock()
	_addon.showStatusBar(true)
end

function _addon.setCustomMat(index,itemLink,accf)
	local s = _addon.characterSettings
	if accf then s = _addon.accountSettings end
	if not s.customMats then s.customMats = {} end	
--	while #cs.customMats < C_MAXITEMS do cs.customMats[#cs.customMats+1] = "" end	
	s.customMats[index] = (itemLink or "")
	_addon.updateStock()
	_addon.showStatusBar(true)
end

function _addon.getCustomMat(index,accf)
	local s = _addon.characterSettings
	if accf then s = _addon.accountSettings end
	local itemLink
	if s.customMats then itemLink = s.customMats[index] end
	return (itemLink or "")
end


--character profiles are disabled for now...

function _addon.saveCharacterProfile()
	local cs = _addon.characterSettings
	_addon.accountSettings.charProfile = {}
	local def = _addon.accountSettings.charProfile
	def.alwaysOn = cs.alwaysOn
	def.showStock = cs.showStock
	def.showRawStock = cs.showRawStock
	def.showSurveys = cs.showSurveys
	def.surveyFigures = cs.surveyFigures
	def.lowMatQtyThreshold = cs.lowMatQtyThreshold
	def.customMats = {}
	if cs.customMats then 
		def.customMats = { unpack(cs.customMats) } 
		--for i=1,#cs.customMats do def.customMats[i] = cs.customMats[i] end
	end

	def.uiScale  = cs.uiScale 
	def.singleRow = cs.singleRow
	def.useIcons = cs.useIcons
	def.bgStyle = cs.bgStyle
end

function _addon.loadCharacterProfile()
	local cs = _addon.characterSettings
	local def = _addon.accountSettings.charProfile

	if not def then
		_out("no profile to load")
		return
	end
	
	cs.alwaysOn = def.alwaysOn
	cs.showStock = def.showStock
	cs.showRawStock = def.showRawStock
	cs.showSurveys = def.showSurveys
	cs.surveyFigures = def.surveyFigures
	cs.lowMatQtyThreshold = def.lowMatQtyThreshold
	cs.customMats = {}
	if def.customMats then 
		cs.customMats = { unpack(def.customMats) } 
		--for i=1,#def.customMats do cs.customMats[i] = def.customMats[i] end
	end

	cs.uiScale  = def.uiScale 
	cs.singleRow = def.singleRow
	cs.useIcons = def.useIcons
	cs.bgStyle = def.bgStyle
  
	_addon.initializeFromSettings()
	_addon.updatePositionFromVars()
	_addon.updateAll()
end

function _addon.initializeFromSettings()
	_addon.lowMatThres = C_DEFMINSTOCK
	if _addon.accountSettings.lowStockWarn then
		_addon.lowStockWarn = _addon.accountSettings.lowStockWarn
	end	
	if _addon.accountSettings.lowQtyThreshold then
		_addon.lowThres = _addon.accountSettings.lowQtyThreshold
	end	
	if _addon.accountSettings.lowMatQtyThreshold then
		_addon.lowMatThres = _addon.accountSettings.lowMatQtyThreshold
	end	
	if _addon.accountSettings.sepBackpQty then
		_addon.sepBackpQty = _addon.accountSettings.sepBackpQty
	end	
	if _addon.accountSettings.autoSavePos then
		_addon.autoSavePos = _addon.accountSettings.autoSavePos
	end	
	if _addon.accountSettings.shareStyle then
		_addon.shareStyle = _addon.accountSettings.shareStyle
	end	
	if _addon.accountSettings.hudOnly then
		_addon.hudOnly = _addon.accountSettings.hudOnly
	end	
	if _addon.accountSettings.updOnReset then
		_addon.updOnReset = _addon.accountSettings.updOnReset
	end	
	if _addon.accountSettings.keepOnWarn then
		_addon.keepOnWarn = _addon.accountSettings.keepOnWarn
	end	
	if _addon.accountSettings.rideTrain then
		_addon.rideTrain = _addon.accountSettings.rideTrain
	end	
	if _addon.accountSettings.questOrder then
		_addon.questOrder = _addon.accountSettings.questOrder
	end
	if _addon.accountSettings.trackAlts then
		_addon.trackAlts = _addon.accountSettings.trackAlts
	end
	if _addon.accountSettings.keepIcon then
		_addon.keepIcon = _addon.accountSettings.keepIcon
	end
	if _addon.accountSettings.inclConsum then
		_addon.inclConsum = _addon.accountSettings.inclConsum
	end
	if _addon.accountSettings.lowStockHist then
		_addon.lowStockHist = _addon.accountSettings.lowStockHist
		if #_addon.lowStockHist > 12 then
			for i=#_addon.lowStockHist-12,1,-1 do table.remove(_addon.lowStockHist,i) end	
		end	
	else
		_addon.accountSettings.lowStockHist = {}
		_addon.lowStockHist = _addon.accountSettings.lowStockHist
	end	


	if _addon.characterSettings.showStock then
		_addon.showStock = true
--		_addon.stock:SetHidden(false)
	end
	if _addon.characterSettings.showRawStock then
		_addon.showRawStock = true
--		_addon.stock:SetHidden(false)
	end
	if _addon.characterSettings.showInvSpace then
		_addon.showInvSpace = true
--		_addon.stock:SetHidden(false)
	end
	if _addon.characterSettings.showSurveys then
		_addon.showSurveys = true
		_addon.surveys:SetHidden(false)
	end
	if _addon.characterSettings.surveyFigures then
		_addon.surveyFigures = _addon.characterSettings.surveyFigures
	end
	if _addon.characterSettings.lowMatQtyThreshold then
		_addon.lowMatThres = _addon.characterSettings.lowMatQtyThreshold
	end	
	if _addon.characterSettings.alwaysOn then 
		_addon.alwaysOn = true
	end
	if _addon.characterSettings.trackResearch then
		_addon.trackResearch = _addon.characterSettings.trackResearch
	end	
	_addon.updateAppearance()	
end

function _addon.loadSavedVariables()
	local defaults = {}
	local serverName = GetWorldName()
	local charId = GetCurrentCharacterId()
	_addon.accountSettings = ZO_SavedVars:NewAccountWide(_addon.savedVariablesName,_addon.savedVariablesVersion,serverName,defaults)
	_addon.accountSettings[charId] = _addon.accountSettings[charId] or {}   
	_addon.characterSettings = _addon.accountSettings[charId]
	_addon.initializeFromSettings()	
end

function _addon.saveCharStatus()
	local cs = _addon.characterSettings
	local rs = {}
	rs.s1, rs.max1, rs.s2, rs.max2, rs.s3, rs.max3 = GetRidingStats()
	if GetTimeUntilCanBeTrained()<=0 then 
		rs.timeToTrain = 0
	else	
		rs.timeToTrain = GetTimeStamp() + (GetTimeUntilCanBeTrained() / 1000)
	end	
	cs.ridingStats = rs	
	
	if _addon.trackAlts and _addon.altsModule then 
		_addon.altsModule.saveStatus()
	end	
end

function _addon.runCommand(args)
	local as, cs = _addon.accountSettings, _addon.characterSettings
	local options = { zo_strsplit(" ",args) }
 	local maxis = string.format("%d",C_MAXITEMS)
	
	local actions = {
		["unlock"] = { function () 
					_addon.unlockStatusBar()
					zo_callLater(function() SetGameCameraUIMode(true) end, 100)
				end, " - unhides and unlocks the bar for movement"}, 
		["save"] = { function ()
				_addon.savePosition()
			end, " - saves the position just for current character"},
		["saveall"] = { function ()
				_addon.saveDefaultPosition()
			end, " - saves the position as default for your account"},	
		["reset"] = { function ()
				cs.anchor, cs.barLeft, cs.barTop = nil, nil, nil
				_addon.updatePositionFromVars()
			end, " - resets the position for current character (to addon default or account default, if any)"},
		["resetall"] = { function ()
				as.anchor, as.barLeft, as.barTop = nil, nil, nil
				_addon.updatePositionFromVars()
			end, " - resets the position for this account (to addon default)"},
		["lock"] = { function ()
				_addon.lockStatusBar()
			end, " - exits the positioning mode"},
		["autosave"] = { function ()
				_addon.setAutoSavePos(not _addon.autoSavePos)
			end, " - toggles auto-save of position for each character"},
		["setlow"] = { function ()
				if tonumber(options[2]) then 
				 _addon.setLowThres(tonumber(options[2]))
					return (string.format("low quantity threshold set to: %d",_addon.lowThres))
				else	
					return ("invalid threshold (use 0 if you need to turn off)")
				end	
			end, " N - sets the low quantity threshold to N, per account"},
		["stock"] = { function ()
				_addon.setShowStock(not _addon.showStock)
			end, " - toggles processed materials display, per character"},
		["rawstock"] = { function ()
				_addon.setShowRawStock(not _addon.showRawStock)
			end, " - toggles raw materials display, per character"},
		["invspace"] = { function ()
				_addon.setShowInvSpace(not _addon.showInvSpace)
			end, " - toggles free inventory space display, per character"},
		["surveys"] = { function ()
				_addon.setShowSurveys(not _addon.showSurveys)
			end, " - toggles surveys display, per character"},
		["surveyfig"] = { function ()
				if not options[2] or options[2]=="" then
					_out(_translate("Survey Statistics Help"))
				else
					_addon.setSurveyFigures(options[2])
				end	
			end, " pattern - sets survey figures pattern, per character; run with no pattern to get more help"},
		["quests"] = { function ()
				if not options[2] then 
					_addon.setQuestOrder("")
				else	
					_addon.setQuestOrder(options[2])
				end	
			end, " pattern - arrange BCWJAEP letters in any order to form your quest pattern; run with no pattern to reset"},
		["alts"] = { function ()
				_addon.showAltStatus()	
			end, " - shows status for other characters"},
		["trackalts"] = { function ()
				_addon.setTrackAlts(not _addon.trackAlts)	
				if _addon.trackAlts then
					return ("Tracking is now ON")
				else	
					return ("Tracking is now OFF")
				end	
			end, " - toggles tracking of extra data for alts, per account"},
		["keepicon"] = { function ()
				_addon.setKeepIcon(not _addon.keepIcon)	
			end, " - toggles display of UI icon, per account"},
		["inclconsum"] = { function ()
				_addon.setInclConsum(not _addon.keepIcon)	
			end, " - toggles consumables mats, per account"},
		["sharestyle"] = { function ()
				_addon.setShareStyle(not _addon.shareStyle)
			end, " - toggles appearance sharing for all characters"},
		["singlerow"] = { function ()
				_addon.setSingleRow(not _addon.singleRow,true)
			end, " - toggles single row display"},
		["aligncenter"] = { function ()
				_addon.setAlignCenter(not _addon.alignCenter,true)
			end, " - toggles align from bar center"},
		["useicons"] = { function ()
				_addon.setUseIcons(not _addon.useIcons,true)
			end, " - toggles icons display"},
		["bgstyle"] = { function ()
				if tonumber(options[2]) then 
				 _addon.setBgStyle(tonumber(options[2]))
				else	
					return ("invalid argument")
				end	
			end, " N - changes background style, N can be 0 to 3"},
		["fontsize"] = { function ()
				if tonumber(options[2]) then 
				 _addon.setUIScale(tonumber(options[2]),true)
				else	
					return ("invalid argument")
				end	
			end, " N - changes font size, N can be 1,2 or 3"},
		["setlowmat"] = { function ()
				if tonumber(options[2]) then 
					_addon.setLowMatThres(tonumber(options[2]))
					return (string.format("low material quantity threshold set to: %d",_addon.lowMatThres))
				else	
					return ("invalid threshold (use 0 if you need to turn off)")
				end	
			end, " N - sets the low material quantity threshold to N, per character, default is 50; material shortages will be underlined"},		
		["setlowmat.a"] = { function ()
				if tonumber(options[2]) then 
					_addon.setLowMatThres(tonumber(options[2]),true)
					return (string.format("low material quantity threshold set to: %d",_addon.lowMatThres))
				else	
					return ("invalid threshold (use 0 if you need to turn off)")
				end	
			end, " N - sets the low material quantity threshold to N, per account, default is 50; material shortages will be underlined"},		
		["setwarn"] = { function ()
				_addon.setLowStockWarn(not _addon.lowStockWarn)
			end, " - toggles low stock warning, per account"},
		["updonreset"] = { function ()
				_addon.setUpdOnReset(not _addon.updOnReset)
			end, " - toggles update on daily reset, per account"},
		["ridetrain"] = { function ()
				_addon.setShowRideTrain(not _addon.rideTrain)
			end, " - toggles riding training marker, per account"},
		["keepwarn"] = { function ()
				_addon.setKeepOnWarn(not _addon.keepOnWarn)
			end, " - toggles keep visible on warnings, per account"},
		["markdone"] = { function ()
				_addon.characterSettings.lastCraftAdded = GetTimeStamp()
				_addon.updateDailyCraftStates()
			end, " - marks the daily quests as done for this character"},
		["sepbqty"] = { function ()
				_addon.setSepBackpQty(not _addon.sepBackpQty)
			end, " - toggles separate materials in backpack, per account"},

		["showcustmat"] = { function ()
				_out("Account Materials:")
				d(_addon.accountSettings.customMats or "{}")
				_out("Character Materials:")
				d(_addon.characterSettings.customMats or "{}")
			end, " shows custom materials"},		
		["setcustmat"] = { function ()
				local index = tonumber(options[2]) 
				if index and index>=1 and index<=C_MAXITEMS then
					_addon.setCustomMat(index,options[3] or "")
				else	
					return ("invalid index (use 1 to "..maxis..")")
				end	
			end, " N item-link;low;high - adds a material to character quick stock/warning; N can be 1 to "..maxis.."; low and high stock are optional"},
		["setcustmat.a"] = { function ()
				local index = tonumber(options[2]) 
				if index and index>=1 and index<=C_MAXITEMS then
					_addon.setCustomMat(index,options[3] or "",true)
				else	
					return ("invalid index (use 1 to "..maxis..")")
				end	
			end, " N item-link;low;high - adds a material to account quick stock/warning; N can be 1 to "..maxis.."; low and high stock are optional"},
		["mailstock"] = { function ()
				_addon.countMatsInMail()
			end, " - temporarily adds materials from mail to quick stock display"},
		["lootmail"] = { function ()
				_addon.lootHirelingMail(true)
			end, " - extracts materials from hirelings only mail"},
		["alwayson"] = { function ()
				_addon.setAlwaysOn(not _addon.alwaysOn)
			end, " - toggles permanent visibility of the status bar, per character"},
		
--		["setrem"] = {	function ()
--				DailyCraftStatusVars.globalReminder = options[2]
--				_addon.updateAll()
--			end, ""},
		["debug"] = { function ()
				_addon.debugFlag = not _addon.debugFlag
			end, ""},	
	}

	local subcmd = options[1] 
	local cmdFunc = actions[subcmd]
	if cmdFunc then
		local res = cmdFunc[1]()
		if res then	_out(res)	else _out(subcmd.." - command OK") end	
	else 	
		local cmdlist = ""
		local t = {}
		for k,_ in pairs(actions) do t[#t+1] = k end
		table.sort(t)
		for i=1,#t do 
			local desc = actions[t[i]][2]
			if desc~="" then cmdlist = cmdlist.."|c40FF40"..t[i].."|cFFFFFF"..desc.."\n" end
		end
		if subcmd=="help" or subcmd=="?" then
			_out(cmdlist)
		else	
			_out("unknown command, try one of these:\n"..cmdlist)
		end	
	end	

end


function _addon.createOptionsMenu()

	if _addon.accountSettings.noLibs then return end
	if not LAM then return end

	local panelData = {
		type = "panel",
		name = "Daily Craft Status",
		displayName = "Daily Craft Status",
		author = _addon.author,
		version = _addon.version,
		slashCommand = "/dcsbarmenu",	
		registerForRefresh = true,	
--		registerForDefaults = true	
	}

	LAM:RegisterAddonPanel("DCS_OptionsPanel", panelData)
	
	function _itembox(i,a)
		if i > C_MAXITEMS then return nil end
		return 
			{
				type = "editbox",
				name = _translate("Item")..string.format(" %d",i),
				getFunc = function() return _addon.getCustomMat(i,a) end,
				setFunc = function(v) _addon.setCustomMat(i,v,a) end,
			}, _itembox(i+1,a)
	end

	function _craftbox(i)
		if not i then i = 1 end
		if i > #_addon.C_RESEARCHCRAFTS then return nil end
		return 
			{
				type = "checkbox",
				name = GetCraftingSkillName(_addon.C_RESEARCHCRAFTS[i]),
				getFunc = function() return _addon.getTrackResearch(_addon.C_RESEARCHCRAFTS[i]) end,
				setFunc = function(v) _addon.setTrackResearch(_addon.C_RESEARCHCRAFTS[i],v) end,
			} , _craftbox(i+1)
	end
	
	local trackResearchSubMenu = {
					type = "submenu",
					name = _translate("Research Tracking"),
					controls = {
						_craftbox(1)
					}	
				}
	function _mattools(a)
		local cid = 2;
		if a then cid = 1 end
		return {	
			{
				type = "description",
				text = _translate("Custom Materials Help"),
			},
			{
				type = "editbox",
				name = _translate("Find Item"),
				--isExtraWide = true,
				getFunc = function() return (_addon.itemSearch.text or "") end, 
				setFunc = function(v) 
						_addon.itemSearch.text = v
						if v~="" then 
							_addon.itemSearch.results = DCS_findItemLinksFromText(v) 
							--d(_addon.itemSearch.results)
							if #_addon.itemSearch.results>0 then
								_addon.itemSearch.selected = _addon.itemSearch.results[1]
							end	
							if a then
								DCS_itemSearchResultsDropdown1:UpdateChoices(_addon.itemSearch.results)
							else
								DCS_itemSearchResultsDropdown2:UpdateChoices(_addon.itemSearch.results)
							end
						end 
					end,
			},
			{
				type = "dropdown",
				name = _translate("Search Results"),
				choices = (_addon.itemSearch.results or {}),
				getFunc = function() return (_addon.itemSearch.selected or "") end,
				setFunc = function(v) _addon.itemSearch.selected = v	end,
				reference = "DCS_itemSearchResultsDropdown"..cid,
			},
			{
				type = "editbox",
				name = _translate("Low Stock"),
				getFunc = function() return (_addon.itemSearch.low or "") end, 
				setFunc = function(v) _addon.itemSearch.low = tonumber(v) end,
			},
			{
				type = "editbox",
				name = _translate("High Stock"),
				getFunc = function() return (_addon.itemSearch.high or "") end, 
				setFunc = function(v) _addon.itemSearch.high = tonumber(v) end,
			},
			{
				type = "button",
				name = _translate("Add Item"), 
				func = function() _addon.addItemFromSearch(a) end,
			},
			_itembox(1,a)
		}	
	end
	
	local customMatSubMenu1 = {
					type = "submenu",
					name = _translate("Custom Materials (All Characters)"),
					controls = {
						unpack(_mattools(true))
					}	
				}

	local customMatSubMenu2 = {
					type = "submenu",
					name = _translate("Custom Materials"),
					controls = {
						unpack(_mattools())
					}	
				}


	local optionsData =
		{
			{
				type = "description",
				name = _translate("Missing translations"),
			},
			{
				type = "header",
				name = _translate("Account Settings"),
			},
			{
				type = "slider",
				name = _translate("Low Threshold"),
				min = 0,
				max = 500,
				step = 5,	
				getFunc = function() return _addon.lowThres end,
				setFunc = function(v) _addon.setLowThres(v) end,
				clampInput = false,
				--default = 3,	
			},
			{
				type = "slider",
				name = _translate("Low Mat Threshold"),
				min = 0,
				max = 2000,
				step = 10,	
				getFunc = function() return (_addon.accountSettings.lowMatQtyThreshold or C_DEFMINSTOCK) end,
				setFunc = function(v) _addon.setLowMatThres(v,true) end,
				clampInput = false,
				warning = "This is overriden by item or character low stock thresholds, if any.",
				--default = 50,	
			},
			{
				type = "checkbox",
				name = "|cFFD000" .. _translate("Low Stock Warn"),
				getFunc = function() return _addon.lowStockWarn end,
				setFunc = function(v)	_addon.setLowStockWarn(v) end,
				--default = false,	
			},
			{
				type = "checkbox",
				name = "    " .. _translate("Include Consumables"),
				getFunc = function() return _addon.inclConsum end,
				setFunc = function(v)	_addon.setInclConsum(v) end,
				disabled = function()	return not _addon.lowStockWarn end,
				--default = false,	
			},
			{
				type = "checkbox",
				name = _translate("Show Marker After Daily Reset"),
				getFunc = function() return _addon.updOnReset end,
				setFunc = function(v)	_addon.setUpdOnReset(v) end,
				--default = false,	
			},
			{
				type = "checkbox",
				name = _translate("Show Marker For Riding Training"),
				getFunc = function() return _addon.rideTrain end,
				setFunc = function(v)	_addon.setShowRideTrain(v) end,
				--default = false,	
			},
			{
				type = "checkbox",
				name = _translate("Keep Visible On Warnings"),
				getFunc = function() return _addon.keepOnWarn end,
				setFunc = function(v)	_addon.setKeepOnWarn(v) end,
				warning = "Low stock, low backpack space or any text with '!' entered as custom material is considered a 'warning'",
				--default = false,	
			},
			{
				type = "checkbox",
				name = _translate("Separate Backpack Quantity"),
				getFunc = function() return _addon.sepBackpQty end,
				setFunc = function(v)	_addon.setSepBackpQty(v) end,
				--default = false,	
			},

			customMatSubMenu1,

			{
				type = "checkbox",
				name = _translate("Auto-save position"),
				getFunc = function() return _addon.autoSavePos end,
				setFunc = function(v)	_addon.setAutoSavePos(v) end,
				--default = false,	
			},
			{
				type = "checkbox",
				name = _translate("Show in HUD Only"),
				getFunc = function() return _addon.hudOnly end,
				setFunc = function(v)	_addon.setHudOnly(v) end,
				--default = false,	
			},
			{
				type = "checkbox",
				name = _translate("Track Alts Data"),
				getFunc = function() return _addon.trackAlts  end,
				setFunc = function(v) _addon.setTrackAlts(v) end,
				--default = false,	
			},
			{
				type = "checkbox",
				name = _translate("Preserve Icon in UI mode"),
				getFunc = function() return _addon.keepIcon  end,
				setFunc = function(v) _addon.setKeepIcon(v) end,
				--default = false,	
			},
			{
				type = "header",
				name = _translate("Appearance"),
			},
			{
				type = "checkbox",
				name = _translate("Share Appearance"),
				getFunc = function() return _addon.shareStyle end,
				setFunc = function(v)	_addon.setShareStyle(v) end,
				--default = false,	
			},
			{
				type = "checkbox",
				name = _translate("Use Icons"),
				getFunc = function() return _addon.useIcons end,
				setFunc = function(v)	_addon.setUseIcons(v,true) end,
				--default = false,	
			},
			{
				type = "checkbox",
				name = _translate("Single Row Display"),
				getFunc = function() return _addon.singleRow end,
				setFunc = function(v)	_addon.setSingleRow(v,true) end,
				--default = false,	
			},
			{
				type = "checkbox",
				name = _translate("Align To Bar Center"),
				getFunc = function() return _addon.alignCenter end,
				setFunc = function(v)	_addon.setAlignCenter(v,true) end,
				--default = false,	
			},
			{
				type = "slider",
				name = _translate("UI Scale"),
				min = 1,
				max = 3,
				step = 1,	
				getFunc = function() return _addon.uiScale end,
				setFunc = function(v) _addon.setUIScale(v,true) end,
				--default = 3,	
			},
			{
				type = "slider",
				name = _translate("Background Style"),
				min = 0,
				max = 3,
				step = 1,	
				getFunc = function() return _addon.bgStyle end,
				setFunc = function(v) _addon.setBgStyle(v) end,
				--default = 1,	
			},
			{
				type = "header",
				name = _translate("Character Settings"),
			},
			{
				type = "checkbox",
				name = _translate("Show Stock"),
				getFunc = function() return _addon.showStock end,
				setFunc = function(v)	_addon.setShowStock(v) end,
				--default = false,	
			},
			{
				type = "checkbox",
				name = _translate("Show Raw Stock"),
				getFunc = function() return _addon.showRawStock end,
				setFunc = function(v)	_addon.setShowRawStock(v) end,
				--default = false,	
			},
			{
				type = "checkbox",
				name = _translate("Show Surveys"),
				getFunc = function() return _addon.showSurveys end,
				setFunc = function(v)	_addon.setShowSurveys(v) end,
				--default = false,	
			},
			{
				type = "checkbox",
				name = _translate("Show Inventory Space"),
				getFunc = function() return _addon.showInvSpace end,
				setFunc = function(v)	_addon.setShowInvSpace(v) end,
				--default = false,	
			},
			{
				type = "checkbox",
				name = _translate("Always Visible"),
				getFunc = function() return _addon.alwaysOn end,
				setFunc = function(v)	_addon.setAlwaysOn(v) end,
				--default = false,	
			},
			{
				type = "checkbox",
				name = _translate("Own Low Stock"),
				getFunc = function() return _addon.characterSettings.lowMatQtyThreshold~=nil end,
				setFunc = function(v)	_addon.setCharLowMat(v) end,	
				--default = false,	
			},
			{
				type = "slider",
				name = _translate("Low Mat Threshold"),
				min = 0,
				max = 2000,
				step = 10,	
				getFunc = function() return (_addon.characterSettings.lowMatQtyThreshold or C_DEFMINSTOCK) end,
				setFunc = function(v) _addon.setLowMatThres(v) end,
				disabled = function() return _addon.characterSettings.lowMatQtyThreshold==nil end,
				clampInput = false,
--				reference = "DCS_optSlider5",
				--default = 50,	
			},

			customMatSubMenu2,

			{
				type = "submenu",
				name = _translate("Survey Statistics"),
				controls = {
					{
						type = "description",
						text = _translate("Survey Statistics Help"),
					},
					{
						type = "editbox",
						name = _translate("Display Pattern"),
						getFunc = function() return _addon.surveyFigures end,
						setFunc = function(v) _addon.setSurveyFigures(v) end,
					},
				},
			},	

			trackResearchSubMenu,
			
--[[
			{
				type = "button",
				name = _translate("Save Character Profile"), 
				func = function() _addon.saveCharacterProfile() end,
				width = "half",
			},	
			{
				type = "button",
				name = _translate("Load Character Profile"), 
				func = function() _addon.loadCharacterProfile() end,
				width = "half",
			},	
]]--

			--scrolling the options panel with the mouse wheel "randomly" changes settings that use sliders
			--sliders in base game settings do not respond to mouse wheel at all, and I like that
			--so this fake control turns the mouse wheel off for sliders upon first display of the options panel
			--not elegant, but works...
			--todo: ask LAM creators to add "onControlsCreated" event, would be neat for all post-creation tweaks
			{
				type = "description",
				name = "",
				disabled = function () 
						function mouseWheelOff(control)
							if control.slider then control.slider:SetHandler("OnMouseWheel", nil) end
						end	
						local ctrls = DCS_OptionsPanel.controlsToRefresh
						for i=1,#ctrls do mouseWheelOff(ctrls[i]) end
						DCS_lastOptionsControl.data.disabled = nil
					end,
				reference = "DCS_lastOptionsControl",	
			},
		}
		
		
	LAM:RegisterOptionControls("DCS_OptionsPanel", optionsData)
	
end
