local _addon = _G["DailyCraftStatus"]

local C_QUESTORDER = "bcwjaep" --check C_RESEARCHCRAFTS if you change this

local DCS_AddMenuItem = AddMenuItem
local LAM = LibAddonMenu2

local CheckQuestItemMatch = _addon.CheckQuestItemMatch
local FindQuestItemInBank = _addon.FindQuestItemInBank
local FindFromList = _addon.FindFromList
local GetGuiRootRelativeAnchor = _addon.GetGuiRootRelativeAnchor
local AddUniqueItemIdToList = _addon.AddUniqueItemIdToList
local AddUniqueItemIdLinkToList = _addon.AddUniqueItemIdLinkToList
local GetLastDailyReset_EU = _addon.GetLastDailyReset_EU
local GetLastDailyReset_NA = _addon.GetLastDailyReset_NA
local CanTrainRiding = _addon.CanTrainRiding
local _out = _addon._out
local _outd = _addon._outd
local _translate = _addon._translate

------------------------------------------------------------------------------------

function _addon.showStatusBar(forceShow)
	local washiddenf, showf

	washiddenf = _addon.bar:IsHidden()
	if forceShow==true then
		showf = true
	else 
		showf = _addon.alwaysOn or _addon.doingWrits or (_addon.updOnReset and _addon.dailyReset) or _addon.posLocked==false
		if not showf then
			if _addon.rideTrain then
				if CanTrainRiding() then showf = true end
			end	
			if next(_addon.trackResearch) then
				if _addon.canDoResearch() then showf = true end
			end	
		end	
		if not showf then
			if _addon.keepOnWarn then
				showf = _addon.warnings["matstock"] or _addon.warnings["questitems"] or _addon.warnings["invspace"]
				if showf==nil then showf = false end
			end
		end	
	end 
	
--WIP:	
	if _addon.keepIcon then
		DailyCraftStatusStub:SetAnchor(TOPLEFT,_addon.bar,TOPLEFT, 0, 0)
		if showf then
			HUD_UI_SCENE:RemoveFragment(_addon.stubfrag)
		else	
			HUD_UI_SCENE:AddFragment(_addon.stubfrag)
		end	

--[[	
		_addon.label:SetHidden(showf==false)
		_addon.stock:SetHidden((showf and (_addon.showStock or _addon.showRawStock))==false)
		_addon.surveys:SetHidden((showf and _addon.showSurveys)==false)
		if showf==false then
			_addon.bgStyle = 0
		else
			if _addon.shareStyle then
				_addon.bgStyle = _addon.accountSettings.bgStyle
			else
				_addon.bgStyle = _addon.characterSettings.bgStyle
			end
		end
		_addon.updateBackgrounds()
		if showf==false then
			showf = true
		end	
]]--
	end
	
	_addon.bar:SetHidden(not showf)
	_addon.hiddenInScene = false
	if washiddenf and showf then 
		_addon.updateAll()
	end	
end

function _addon.hideStatusBar(fromScene)
	_addon.bar:SetHidden(true)
	if _addon.alts then _addon.alts:SetHidden(true) end
	_addon.hiddenInScene = false
	if fromScene then _addon.hiddenInScene = true end
end

function _addon.unlockStatusBar()
	_addon.posLocked = false
	_addon.bar:SetMovable(true)
	_addon.bar:SetClampedToScreen(true)
	--if _addon.bar:IsHidden() then _addon.updateAll() end	
	_addon.showStatusBar()
end

function _addon.lockStatusBar()
	_addon.posLocked = true
	_addon.bar:SetMovable(false)
	--_addon.label:SetMouseEnabled(true)
	_addon.showStatusBar()
end


local majorFontNames = {"ZoFontGameLargeBold","$(BOLD_FONT)|$(KB_20)|soft-shadow-thick","$(BOLD_FONT)|$(KB_22)|soft-shadow-thick"}
local minorFontNames = {"ZoFontGameSmall","$(MEDIUM_FONT)|16|soft-shadow-thin","ZoFontGameShadow"}

function _addon.setUIScale(v,userAction)
	if v<1 or v>3 then return end
	local f1 = majorFontNames[v]
	local f2 = minorFontNames[v]
	_addon.uiScale = v

	_addon.label:SetFont(f1)
	_addon.stock:SetFont(f2)
	_addon.surveys:SetFont(f2)
	
	local size = _addon.iconSizes[_addon.uiScale]
	_addon.bar:SetDimensions(size,size)
--WIP:
	DailyCraftStatusStub:SetDimensions(size,size)
	
	_addon.updateMainIcon()

	_addon.label:ClearAnchors()
	_addon.label:SetAnchor(TOPLEFT,_addon.icon,TOPRIGHT,4,-_addon.uiScale+1)
	
	if userAction then
		if _addon.shareStyle then
			_addon.accountSettings.uiScale = _addon.uiScale
		else
			_addon.characterSettings.uiScale = _addon.uiScale
		end
		_addon.updateAll()
		_addon.showStatusBar(true)
	end	
end

function _addon.updateMainIcon()
	local size = 18+_addon.uiScale*4
	local img = "inventory_tabicon_craftbag_blacksmithing_up.dds"
	if _addon.doingWrits then img = "inventory_tabicon_craftbag_blacksmithing_down.dds" end
	local ltxt = string.format("|t%d:%d:esoui/art/inventory/%s|t",size,size,img)
	_addon.icon:SetText(ltxt)

--WIP:	
	_addon.stubicon:SetText(string.format("|t%d:%d:esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_down.dds|t",size,size))
end

function _addon.getBarWidth()
	local width = _addon.label:GetRight()-_addon.icon:GetLeft()
	if _addon.singleRow then width = _addon.surveys:GetRight()-_addon.icon:GetLeft() end
	return width
end

function _addon.updatePosition()
	if _addon.alignCenter then
		local barWidth = _addon.getBarWidth()

		local s = _addon.characterSettings
		--central position is character-dependant, so using alignCenter automatically saves the position for character
		if s.anchor==nil then 
			s.anchor, s.barLeft, s.barTop = GetGuiRootRelativeAnchor(_addon.bar)
			s.barCenter = s.barLeft + barWidth / 2
		end
		_addon.bar:ClearAnchors()
		_addon.bar:SetAnchor(TOPLEFT, GuiRoot, s.anchor, s.barCenter - barWidth/2, s.barTop)

	end
end		

function _addon.updateBackgrounds()
	--dual background is actually what remains from my original solution, not really needed now
	_addon.bgfull:SetHidden(true)
	_addon.bgmini:SetHidden(true)

	if _addon.bgStyle==0 then
		return;
	end
	
	if _addon.bgStyle==1 then
		_addon.bgmini:ClearAnchors()
		_addon.bgmini:SetAnchor(TOPLEFT,_addon.icon,TOPLEFT, -2, 0)
		_addon.bgmini:SetHidden(false)
		_addon.bgmini:SetDimensions(_addon.icon:GetRight()-_addon.icon:GetLeft() + 4, 21 + 2*_addon.uiScale)
		return
	end		

	local extras = _addon.stock:GetText()~="" or _addon.surveys:GetText()~=""

	if _addon.bgStyle==2 or extras==false then 
		_addon.bgfull:SetHidden(false)
		_addon.bgfull:SetDimensions(_addon.label:GetRight()-_addon.icon:GetLeft() + 24, 21 + 2*_addon.uiScale)
		return
	end	

	if _addon.bgStyle==3 then 
		if _addon.singleRow then
			_addon.bgmini:ClearAnchors()
			_addon.bgmini:SetAnchor(TOPLEFT,_addon.icon,TOPLEFT, -16, 0)
			_addon.bgmini:SetHidden(false)
			_addon.bgmini:SetDimensions(_addon.surveys:GetRight()-_addon.icon:GetLeft() + 32, 21 + 2*_addon.uiScale)
		else	
			_addon.bgfull:SetHidden(false)
			_addon.bgfull:SetDimensions(
				zo_max(zo_max(_addon.label:GetRight(),_addon.stock:GetRight()),_addon.surveys:GetRight()) -
				zo_min(zo_min(_addon.icon:GetLeft(),_addon.stock:GetLeft()),_addon.surveys:GetLeft()) + 24, 
				zo_max(zo_max(_addon.label:GetBottom(),_addon.stock:GetBottom()),_addon.surveys:GetBottom()) -
				zo_min(zo_min(_addon.icon:GetTop(),_addon.stock:GetTop()),_addon.surveys:GetTop()) + 2 )
		end		
	end
end

function _addon.updateAnchors(v)
	_addon.stock:ClearAnchors()
	_addon.surveys:ClearAnchors()	
	if _addon.singleRow then
		_addon.stock:SetAnchor(TOPLEFT, _addon.label, TOPRIGHT, 4, 2)
		_addon.surveys:SetAnchor(TOPLEFT, _addon.stock, TOPRIGHT, 16, 0)
	else
		_addon.stock:SetAnchor(TOP, _addon.label, BOTTOM, -8, 4)
		_addon.surveys:SetAnchor(TOP, _addon.stock, BOTTOM, 0, 4)
	end
	_addon.updateBackgrounds()
	_addon.updatePosition()
end




local function DCS_hideInThisScene(oldState, newState)   
	if newState==SCENE_SHOWN then
		_addon.hideStatusBar(true)
	elseif newState==SCENE_HIDDEN then
		if _addon.pendingUpdates then
			_addon.updateAll()
		end	
		_addon.showStatusBar()
	end
end

local function DCS_showInThisScene(oldState, newState)   
	if newState==SCENE_SHOWN then
		if _addon.pendingUpdates then
			_addon.updateAll()
		end
		_addon.showStatusBar()
	elseif newState==SCENE_HIDDEN then
		_addon.hideStatusBar(true)
	end
end

local function DCS_hideInThisSceneGroup(oldState, newState)   
	if newState==SCENE_GROUP_SHOWN then
		_addon.hideStatusBar(true)
	elseif newState==SCENE_GROUP_HIDDEN then
		if _addon.pendingUpdates then
			_addon.updateAll()
		end	
		_addon.showStatusBar()
	end  
end

local scenesOn = {"hud","hudui"}
local scenesOff = {"gameMenuInGame","worldMap","groupMenuKeyboard","stats","skills","championPerks","lockpickKeyboard",
					"Scrying","antiquityDigging","interact","stables","tribute",
	} 
local sceneGroupsOff = {"marketSceneGroup","collectionsSceneGroup","contactsSceneGroup","guildsSceneGroup",
					"allianceWarSceneGroup","helpSceneGroup","companionSceneGroup",	--"journalSceneGroup","mailSceneGroup"
	}

function _addon.registerSceneCallbacks()
	--local frag = ZO_HUDFadeSceneFragment:New(_addon.bar, nil, 0)
	--HUD_SCENE:AddFragment(frag)
	--HUD_UI_SCENE:AddFragment(frag)

--WIP:
	--_addon.stubfrag = ZO_HUDFadeSceneFragment:New(DailyCraftStatusStub)
	--HUD_SCENE:AddFragment(frag)
	--HUD_UI_SCENE:AddFragment(frag)

	--SCENE_MANAGER:RegisterCallback("SceneStateChange", function(scene,oldState,newState) end)  

	if _addon.hudOnly then
		for i=1,#scenesOn do
			local s = SCENE_MANAGER:GetScene(scenesOn[i])
			if s then s:RegisterCallback("StateChange", DCS_showInThisScene) end
		end
	else	
		for i=1,#scenesOff do
			local s = SCENE_MANAGER:GetScene(scenesOff[i])
			if s then s:RegisterCallback("StateChange", DCS_hideInThisScene) end
		end
		for i=1,#sceneGroupsOff do
			local sg = SCENE_MANAGER:GetSceneGroup(sceneGroupsOff[i])
			if sg then sg:RegisterCallback("StateChange", DCS_hideInThisSceneGroup) end	
		end
	end	
end

function _addon.unregisterSceneCallbacks()
	if _addon.hudOnly then
		for i=1,#scenesOn do
			local s = SCENE_MANAGER:GetScene(scenesOn[i])
			if s then	s:UnregisterCallback("StateChange", DCS_showInThisScene) end
		end
	else	
		for i=1,#scenesOff do
			local s = SCENE_MANAGER:GetScene(scenesOff[i])
			if s then	s:UnregisterCallback("StateChange", DCS_hideInThisScene) end
		end
		for i=1,#sceneGroupsOff do
			local sg = SCENE_MANAGER:GetSceneGroup(sceneGroupsOff[i])
			if sg then sg:UnregisterCallback("StateChange", DCS_hideInThisSceneGroup) end	
		end
	end	
end

function _addon.updateAppearance()
	local s = _addon.characterSettings
	if _addon.shareStyle then	s = _addon.accountSettings end	

	_addon.setAppearanceDefaults()
	
	if s.singleRow~=nil then _addon.singleRow = s.singleRow end
	_addon.setSingleRow(_addon.singleRow)
	if s.alignCenter~=nil then _addon.alignCenter = s.alignCenter end
	_addon.setAlignCenter(_addon.alignCenter)
	if s.uiScale~=nil then _addon.uiScale = s.uiScale end
	_addon.setUIScale(_addon.uiScale)
	
	if s.useIcons~=nil then _addon.useIcons = s.useIcons end	
	if s.bgStyle~=nil then	_addon.bgStyle = s.bgStyle end	
end



function _addon.updatePositionFromVars()
	_addon.bar:ClearAnchors()
	_addon.bar:SetClampedToScreen(true)
	if _addon.characterSettings.anchor then
		_addon.bar:SetAnchor(TOPLEFT, GuiRoot, _addon.characterSettings.anchor, _addon.characterSettings.barLeft, _addon.characterSettings.barTop)
		return
	end
	if _addon.accountSettings.anchor then
		_addon.bar:SetAnchor(TOPLEFT, GuiRoot, _addon.accountSettings.anchor, _addon.accountSettings.barLeft, _addon.accountSettings.barTop)
		return
	end	
	local stockOffset = 0
	if _addon.showStock or _addon.showRawStock then stockOffset = 120 end
	_addon.bar:SetAnchor(TOPLEFT, GuiRoot, BOTTOM, 400, -80 - stockOffset)	
end

local function DCS_lockedCheck()
	if _addon.posLocked then
		_out("not in positioning mode, use ".._addon.slashCmd.." unlock")
	end	
	return _addon.posLocked
end

function _addon.savePosition()
	if DCS_lockedCheck() then return end
	local s = _addon.characterSettings
	s.anchor, s.barLeft, s.barTop = GetGuiRootRelativeAnchor(_addon.bar)
	s.barCenter = s.barLeft + _addon.getBarWidth() / 2

	--_addon.bar:ClearAnchors()
	--_addon.bar:SetAnchor(TOPLEFT, GuiRoot, s.anchor, s.barLeft, s.barTop)

	--_addon.updatePositionFromVars()
end

function _addon.saveDefaultPosition()
	if DCS_lockedCheck() then return end
	local s = _addon.accountSettings
	s.anchor, s.barLeft, s.barTop = GetGuiRootRelativeAnchor(_addon.bar)
	s.barCenter = s.barLeft + _addon.getBarWidth() / 2

	--_addon.bar:ClearAnchors()
	--_addon.bar:SetAnchor(TOPLEFT, GuiRoot, s.anchor, s.barLeft, s.barTop)

	--_addon.updatePositionFromVars()
end

local UTF8_NBSP = "\194\160"

function _addon.itemTableToStockString(mats, lowThres, lowOnly, sepBackpQty, extStock, _iconSize)
	local stocks = ""
	local tooltip = ""
	local warnfound = false
	local iconSize = _iconSize
	if not iconSize then iconSize = 24 end
	--d(extStock)
	for i = 1, #mats do
		local mat,low,high = zo_strsplit(';',mats[i])
		if mat then 
			local itemLink = mat
			local itemId = tonumber(mat)
			if itemId then 
				itemLink = string.format("|H1:item:%d",itemId) 
			else
				itemId = GetItemLinkItemId(itemLink)
			end
			if not itemId or itemId==0 then  --custom text
				local warn = string.find(mats[i],"!") 
				if warn then warnfound = true end
				if lowOnly==false or warn then
					stocks = stocks..mats[i]
				end	
			else	
				local extCount = extStock[itemId]
				if not extCount then extCount = 0 end
				local inventoryCount, bankCount, craftBagCount = GetItemLinkStacks(itemLink)
				local totStock = inventoryCount + bankCount + craftBagCount + extCount
				
				if sepBackpQty then totStock = totStock - inventoryCount end
				
				low = tonumber(low)
				if not low then low = lowThres end

				if lowOnly==false or (low>-1 and totStock<=low) then 
					if high then high = tonumber(high) end
					if not high or totStock<=high then 			
						local q = ""
						local itemName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
						
						if totStock>1000 then 
							q = string.format("%.1f",totStock/1000).."k"
						else
							q = string.format("%d",totStock)  
							--improve visibility of single digit stocks
							--padding with zeros looks bad, and regular spaces are either removed or break "|l" format
							if totStock<10 then q = UTF8_NBSP..q..UTF8_NBSP end 
						end
						if extCount > 0 then q = q.."*" end

						local iconStr = string.format("|t%d:%d:%s|t",iconSize,iconSize,GetItemLinkIcon(itemLink))
						stocks = stocks..iconStr
						if low>-1 and totStock<=low then
							stocks = stocks.."|l0:1:1:3:2:FFD000|l"..q.."|l" 
							if _addon.showAbbrev then
								stocks = stocks .. string.sub(itemName,1,3)
							end
							warnfound = true
						else
							stocks = stocks..q --.." "
						end	
						if sepBackpQty and inventoryCount > 0 then
							stocks = stocks..string.format("|cAFAFAF+|r%d",inventoryCount)
						end	
						stocks = stocks.." "
						
						if tooltip~="" then tooltip = tooltip.."\n" end
						tooltip = tooltip..iconStr.."  ".. itemName .. "  " .. q
					end	
				end	
			end	
		end	
	end
	return stocks,tooltip,warnfound
end


function _addon.updateStock()
	local lowOnly = false
--	local invSpaceTxt = nil

	_addon.warnings["matstock"] = nil

	if _addon.showStock==false and _addon.lowStockWarn then 
		lowOnly = true
	end

	if _addon.showStock==false and _addon.showRawStock==false then 
		if lowOnly==false and lowSpaceTxt==nil then
			_addon.stock:SetText("") 
			_addon.updateBackgrounds()
			_addon.updatePosition()
			return
		end	
	end
	
--	_addon.stock:SetHidden(_addon.showStock==false and _addon.showRawStock==false)
--	if _addon.showStock==false and _addon.showRawStock==false then return end;
	
	local skillIds = {}
	local abilityData = {
		--these are texture IDs for first crafting ability in the skill line
		--it's a bit weird that as of now there are no constants for skill lines...
		--todo: convert to new NonCombatBonus functions
		["/esoui/art/icons/ability_smith_001.dds"] = CRAFTING_TYPE_BLACKSMITHING, 
		["/esoui/art/icons/ability_tradecraft_002.dds"] = CRAFTING_TYPE_CLOTHIER, 
		["/esoui/art/icons/ability_tradecraft_003.dds"] = CRAFTING_TYPE_WOODWORKING,
		["/esoui/art/icons/passive_jewelerengraver.dds"] = CRAFTING_TYPE_JEWELRYCRAFTING 
	}
	
	
	for i=1, GetNumSkillLines(SKILL_TYPE_TRADESKILL) do
		local _, texId = GetSkillAbilityInfo(SKILL_TYPE_TRADESKILL, i, 1)
		if abilityData[texId] then
			skillIds[abilityData[texId]] = i --todo: this is character/account dependant, you can populate it once on OnPlayerActivated event
		end	
	end

	function getEquipMatTable(rawoffset)
		local mats = {}

		function addFromEquipSkill(craftType)
			if not skillIds[craftType] then return end
			local skillLevel = GetSkillAbilityUpgradeInfo(SKILL_TYPE_TRADESKILL, skillIds[craftType], 1)
			if skillLevel and _addon.DCS_TIERED_MATS[craftType] then
				if craftType==CRAFTING_TYPE_CLOTHIER then 
					local matOffset = rawoffset+4*(skillLevel-1) 
					mats[#mats+1] = _addon.DCS_TIERED_MATS[craftType][matOffset]   --cloth
					mats[#mats+1] = _addon.DCS_TIERED_MATS[craftType][matOffset+2] --leather
				else	
					local matOffset = rawoffset+2*(skillLevel-1)
					mats[#mats+1] = _addon.DCS_TIERED_MATS[craftType][matOffset]
				end	
			end	
		end	
		
		addFromEquipSkill(CRAFTING_TYPE_BLACKSMITHING)
		addFromEquipSkill(CRAFTING_TYPE_CLOTHIER)
		addFromEquipSkill(CRAFTING_TYPE_WOODWORKING)
		addFromEquipSkill(CRAFTING_TYPE_JEWELRYCRAFTING)
		
		return mats
	end	

	function getConsumMatTable()
		local mats = {}

		function addFromConsumSkill(craftType,skillId)
			local skillLevel = GetNonCombatBonus(skillId)
			if skillLevel and skillLevel > 0 then
				local t = _addon.DCS_WRIT_MATS[craftType][0] --common items
				if t then
				  for _,id in pairs(t) do mats[#mats+1] = id end
				end
				t = _addon.DCS_WRIT_MATS[craftType][skillLevel]
				if t then
				 for _,id in pairs(t) do mats[#mats+1] = id end
				end
			end	
		end	
	
		addFromConsumSkill(CRAFTING_TYPE_ALCHEMY,NON_COMBAT_BONUS_ALCHEMY_LEVEL)
		addFromConsumSkill(CRAFTING_TYPE_ENCHANTING,NON_COMBAT_BONUS_ENCHANTING_LEVEL)
		
		return mats
	end	

	local ltxt = ""	

--	if invSpaceTxt then
--		ltxt = invSpaceTxt .. "  "
--	end

	_addon.toolTipTextStock = ""
	
	if _addon.showStock or lowOnly then 
	
		local mats = getEquipMatTable(2)
	
		if _addon.accountSettings.customMats then
			for _,id in pairs(_addon.accountSettings.customMats) do 
				if id and id~="" then	table.insert(mats,id) end
			end
		end	
		if _addon.characterSettings.customMats then
			for _,id in pairs(_addon.characterSettings.customMats) do 
				if id and id~="" then	table.insert(mats,id) end
			end
		end	
		
--		if _addon.singleRow then ltxt = ltxt.."|t24:24:esoui/art/icons/mapkey/mapkey_crafting.dds|t"	end	
		local stocks, tooltip, warnfound = _addon.itemTableToStockString(mats,_addon.lowMatThres,lowOnly,_addon.sepBackpQty,_addon.mailStock, _addon.iconSizes[_addon.uiScale])
		ltxt = ltxt..stocks
		_addon.toolTipTextStock = _addon.toolTipTextStock..tooltip

		if _addon.inclConsum and lowOnly then
			local mats = getConsumMatTable()
			local stocks, tooltip, warnfound2 = _addon.itemTableToStockString(mats,_addon.lowThres,lowOnly,_addon.sepBackpQty,_addon.mailStock, _addon.iconSizes[_addon.uiScale])
			ltxt = ltxt..stocks
			if _addon.toolTipTextStock~="" then _addon.toolTipTextStock = _addon.toolTipTextStock .. "\n" end
			_addon.toolTipTextStock = _addon.toolTipTextStock..tooltip
			warnfound = warnfound or warnfound2
		end
		
		
		if _addon.characterSettings.statusText then
			local charText = _addon.characterSettings.statusText["CustomText"]
			if charText then
				if string.find(charText,"!") then
					ltxt = ltxt.." "..charText
					warnfound = true
				end	
			end
		end
		if warnfound then _addon.warnings["matstock"] = true end
		
		if ltxt~="" then
			if _addon.showRawStock then 
				if _addon.singleRow then ltxt = ltxt.."    " else ltxt = ltxt.."\n" end
			end	
		end	
	end
	if _addon.showRawStock then 
		if _addon.singleRow and ltxt~="" then ltxt = ltxt.."|t24:24:esoui/art/inventory/inventory_tabicon_crafting_down.dds|t"	end	--esoui/art/icons/mapkey/mapkey_mine.dds
		local mats = getEquipMatTable(1)
		local stocks, tooltip = _addon.itemTableToStockString(mats,-1,false,false,_addon.mailStock,_addon.iconSizes[_addon.uiScale]) 	
		ltxt = ltxt..stocks
		if _addon.toolTipTextStock~="" then _addon.toolTipTextStock = _addon.toolTipTextStock .. "\n" end
		_addon.toolTipTextStock = _addon.toolTipTextStock..tooltip
	end

--test:
--	if DailyCraftStatusVars.globalReminder then
--		ltxt = ltxt.. "  " .. DailyCraftStatusVars.globalReminder
--	end	

	_addon.stock:SetText(ltxt)
	_addon.updateBackgrounds()
	_addon.updatePosition()

end


--esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds
--esoui/art/icons/servicetooltipicons/servicetooltipicon_weaponsmith.dds
--esoui/art/icons/housing_gen_lsb_bannercrafting001.dds
--esoui/art/icons/crafting_smith_logo.dds

local statusIcons = {
	"esoui/art/icons/mapkey/mapkey_smithy.dds",
	"esoui/art/icons/mapkey/mapkey_clothier.dds",
	"esoui/art/icons/mapkey/mapkey_woodworker.dds",
	"esoui/art/icons/mapkey/mapkey_jewelrycrafting.dds",
	"esoui/art/icons/mapkey/mapkey_alchemist.dds",
	"esoui/art/icons/mapkey/mapkey_enchanter.dds", 
	"esoui/art/icons/mapkey/mapkey_inn.dds",
	"",
}		 

function _addon.updateDailyReset()
	_addon.dailyReset = false
	local lastCraftAdded = _addon.characterSettings.lastCraftAdded
	if lastCraftAdded==nil then lastCraftAdded = 0 end
	if lastCraftAdded < _addon.lastDailyReset() then
		_addon.dailyReset = true	
	end	
end

------------------------------------------
--
--	CORE FUNCTION
--
------------------------------------------

function _addon.updateDailyCraftStates()
	local anyDailyCraftFound = false
	local clrs = {}
	local ulin = {}
  
	local langStrings = _addon.langQuestInfo
	local ltxt = ""
	local questInfo = {}
	if langStrings==nil then 
	  	ltxt = "? (no language data)"
	else	
		local t = langStrings["questnames"]
		if t==nil then return end

		if string.len(_addon.questOrder)==0 then 
			questInfo = t
		else	
			for  j=1,string.len(_addon.questOrder) do
				local questIdx = string.find(C_QUESTORDER,string.lower(string.sub(_addon.questOrder,j,j)))
				if questIdx then
					questInfo[j] = t[questIdx]
					questInfo[j][3] = questIdx
				else
					questInfo = t
					break
				end
			end	
		end	
	end	

	local defColor = "4F4F4F"

	_addon.warnings["questitems"] = nil
	_addon.warnings["invspace"] = nil
	_addon.toolTipText = ""
	
	if _addon.updOnReset then
		_addon.updateDailyReset()
		if _addon.dailyReset then
			--defColor = "FFFFFF"
			local isz = _addon.iconSizes[_addon.uiScale] 
			ltxt = ltxt .. string.format("|t%d:%d:%s|t",isz,isz,"esoui/art/compass/repeatablequest_icon_assisted.dds")
		end	
	end	

	if _addon.rideTrain then
		if CanTrainRiding() then
			local isz = _addon.iconSizes[_addon.uiScale] - 2
			ltxt = ltxt .. string.format("|t%d:%d:%s|t",isz,isz,"esoui/art/icons/mapkey/mapkey_stables.dds")
		end
	end	

	for j = 1, #questInfo do
		clrs[j] = defColor
	end	
	
--	_addon.lowStockItems = {}
	for i = 1, MAX_JOURNAL_QUESTS do
		if GetJournalQuestType(i)==QUEST_TYPE_CRAFTING then
			if GetJournalQuestRepeatType(i)==QUEST_REPEAT_DAILY then
				local questName = GetJournalQuestName(i)
				
				-- this is for backward compatibility, remove it 
				if string.len(_addon.questOrder)==0 then anyDailyCraftFound = true end
				
				for j = 1, #questInfo do
					if string.find(string.lower(questName),questInfo[j][1]) then
						anyDailyCraftFound = true
						
						--d(questInfo[j][1].." found") 
						local questSteps = ""
						local allCraftStepsComplete = true
						local allItemsInBank = true
						local questToolTip = ""
						for condition = 1, GetJournalQuestNumConditions(i,1) do
							local q, current, max, _, isComplete = GetJournalQuestConditionInfo(i,1,condition)
							if q~=nil and q~="" then 
								questSteps = questSteps..q 
								isComplete = isComplete or (current==max)
								if FindFromList(q,langStrings["craft"]) then
									allCraftStepsComplete = allCraftStepsComplete and isComplete
								end
								if isComplete then 
--								questToolTip = questToolTip.."|c808080"..q.."\n"
								else
									local foundInBank, qtyInBank, itemLink = FindQuestItemInBank(BAG_BANK,i,condition)
									if foundInBank==false then 
										foundInBank, qtyInBank, itemLink = FindQuestItemInBank(BAG_SUBSCRIBER_BANK,i,condition)
									end	
									if foundInBank then
										if qtyInBank <= _addon.lowThres then 
											ulin[j] = true 
											--WIP: I'm not getting the itemLink of items that are already depleted
											--WIP: it's hard to tell whether these are stored in bank once they are gone though
											--todo: carry lowStockItems over to next characters? save it with account?
											AddUniqueItemIdLinkToList(_addon.lowStockItems,itemLink)
											AddUniqueItemIdLinkToList(_addon.lowStockHist,itemLink)
										end									
									end		
									
									allItemsInBank = allItemsInBank and foundInBank
									if string.find(questSteps,langStrings["deliver"])==nil then
										questToolTip = questToolTip.."|cFFFFFF"..q
										if foundInBank then questToolTip = questToolTip.."  |cFFD000"..zo_strformat("Bank: <<1>>",qtyInBank) end
										questToolTip = questToolTip.."\n"
									end	
								end
							end
						end	
												
						if string.find(questSteps,langStrings["deliver"]) then
							clrs[j] = "00A000" --green
						else	
							if allCraftStepsComplete then
								if allItemsInBank then
									clrs[j] = "FFD000" --yellow
								else
									clrs[j] = "FF8000" --orange
								end
							else	
								if allItemsInBank then
									clrs[j] = "FFD000" --yellow
								else
									clrs[j] = "A00000" --red
								end	
							end	
						end	
						if questToolTip~="" then
							_addon.toolTipText = _addon.toolTipText.."|c"..clrs[j]..questInfo[j][2].."  "..questName.."\n"..questToolTip.."\n"
						end	
						j = #questInfo
					end	
				end	
			end	
		end
	end

	local researchInfo = ""
	
	if next(_addon.trackResearch) then	
		local avail, craftsToResearch, itemsToResearch, timeLeft, progressDetails = _addon.canDoResearch()
		if avail then
			for j = 1, #questInfo do
				if clrs[j]==defColor then
					local craftIdx = j
					if questInfo[j][3] then craftIdx = questInfo[j][3] end
					if craftsToResearch[_addon.C_RESEARCHCRAFTS[craftIdx]] then
						clrs[j] = "00AFAF" 
						if itemsToResearch[_addon.C_RESEARCHCRAFTS[craftIdx]] then
							ulin[j] = true
						end
					end
				end
			end	
		else
			if timeLeft > 0 then
				local days = math.floor(timeLeft/86400)
				local hours = math.floor(timeLeft/3600) % 24
				local mins = math.floor(timeLeft/60) % 60
				local isz = _addon.iconSizes[_addon.uiScale] + 2
				local clr = "4F4F4F" --grey
				
				local ts = "";
				if days > 0 then  
					ts = string.format("+%dd",days) 
				else
					if hours > 0 then  
						ts = string.format("+%dh",hours) 
					else
						ts = string.format("+%dm",mins) --os.date("%H:%M",GetTimeStamp()+timeLeft)
						clr = "FFFFFF"
						if timeLeft < 600 then clr = "00AFAF" end --10min
					end
				end
				
				researchInfo = string.format("|t%d:%d:%s|t|c%s%s",isz,isz,"esoui/art/crafting/smithing_tabicon_research_up.dds",clr,ts)
			end
			
		end 
		
		local toolTip = ""
		for _,lineProgress in pairs(progressDetails) do
			local s = string.format("%s %s\n",lineProgress[1],os.date("%c",GetTimeStamp()+lineProgress[2]))
			if lineProgress[2]==timeLeft then
				s = "|cFFFFFF"..s.."|r"
			end
			toolTip = toolTip .. s
		end
		if toolTip~="" then toolTip = "|c00AFAF" .. GetString(SI_SMITHING_RESEARCH_IN_PROGRESS) .. "|r\n" ..  toolTip .. "\n" end
		_addon.toolTipText = _addon.toolTipText..toolTip
	end	

	if _addon.useIcons then
		for j = 1, #questInfo do
			local colorObj = ZO_ColorDef:New(clrs[j])
			local size = _addon.iconSizes[_addon.uiScale]
			--if j==1 then size = size + 4 end
			local iconIdx = j
			if questInfo[j][3] then iconIdx = questInfo[j][3] end
			local iconStr = string.format("|t%d:%d:%s:inheritColor|t",size,size,statusIcons[iconIdx])
			if ulin[j] then iconStr = iconStr.."!" end
			iconStr = colorObj:Colorize(iconStr)
			ltxt = ltxt..iconStr
		end		
	else
		for j = 1, #questInfo do
			ltxt = ltxt.."|c"..clrs[j]
			if ulin[j] then ltxt = ltxt.."|l0:1:1:3:2:"..clrs[j].."|l" end
			ltxt = ltxt..questInfo[j][2]
			if ulin[j] then ltxt = ltxt.."|l" end
		end	
	end	

--	if not anyDailyCraftFound and _addon.singleRow then ltxt = "   " end
	if #_addon.lowStockItems>0 then 
		local itemStr, _, warnfound = _addon.itemTableToStockString(_addon.lowStockItems,_addon.lowThres,false,true,_addon.mailStock,24)
		if warnfound then _addon.warnings["questitems"] = true end
		ltxt = ltxt.."   |cFFFFFF"..itemStr
	end

	if _addon.showInvSpace then 
		local freeSlots,bagSize = GetNumBagFreeSlots(BAG_BACKPACK), GetBagSize(BAG_BACKPACK)
		local isz = _addon.iconSizes[_addon.uiScale] - 8
		local clr = "4F4F4F" --grey
		if not freeSlots or freeSlots==0 then 
			clr = "A00000" 
			_addon.warnings["invspace"] = true
		elseif freeSlots < 15 then 
			clr = "FF8000"
			_addon.warnings["invspace"] = true
		elseif freeSlots < 30 then 
			clr = "FFD000" 
		elseif freeSlots < 45 then 
			clr = "FFFFFF" 
		end  
		ltxt = ltxt.."   " .. 
--		  string.format("|t%d:%d:/esoui/art/tooltips/icon_bag.dds|t |c%s%d|r/%d",isz,isz,clr,freeSlots,bagSize)
		  string.format("|t%d:%d:/esoui/art/tooltips/icon_bag.dds|t|c%s%d|r",isz,isz,clr,freeSlots) .. " "
	end

	if researchInfo~="" then	
		ltxt = ltxt .. researchInfo 
	end	
	
	if _addon.barExtension then
		ltxt = ltxt .. _addon.barExtension.getText()	
	end
	
	_addon.doingWrits = anyDailyCraftFound
	_addon.label:SetText(ltxt)

	--_addon.updateStock() 
	_addon.updateMainIcon()
	--_addon.showStatusBar()
end

function _addon.showTooltip(control)
	if control.data then
		if control.data.tooltipText and control.data.tooltipText~="" then
			InitializeTooltip(InformationTooltip, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
			SetTooltipText(InformationTooltip, control.data.tooltipText)
			InformationTooltipTopLevel:BringWindowToTop()
		end
	end
end

function _addon.showAltStatus()
	if _addon.trackAlts and _addon.altsModule then
		_addon.altsModule.showStatus()
		return
	end	

	local txt = ""
	local charSettings
	
	for i = 1, GetNumCharacters() do
		local charName, _, _, _, _, _, characterId = GetCharacterInfo(i)
		--strip the grammar markup
		charName = zo_strformat("<<1>>", charName)
		
		local charStatus = ""
		charSettings = _addon.accountSettings[characterId]
		if charSettings then
			local lastCraft = charSettings.lastCraftAdded
			if lastCraft==nil then lastCraft = 0 end
			local isz = 24 
			if lastCraft < _addon.lastDailyReset() then
				charStatus = string.format("|t%d:%d:%s|t",isz,isz,"esoui/art/compass/repeatablequest_icon_assisted.dds")
			else
				charStatus = string.format("|c282828|t%d:%d:%s:inheritcolor|t|r",isz,isz,"esoui/art/compass/repeatablequest_icon_assisted.dds")
			end 	
		end	
		if txt~="" then txt = txt .. "\n" end
		txt = txt .. charName .. charStatus
	end

	InitializeTooltip(InformationTooltip, _addon.label, BOTTOM, 0, 0)
	SetTooltipText(InformationTooltip, txt)
	InformationTooltipTopLevel:BringWindowToTop()
end

function _addon.showMainMenu(stubOnly)
	ClearMenu()
	if not stubOnly then
		if _addon.posLocked then 
			DCS_AddMenuItem(_translate("Unlock"), function() _addon.unlockStatusBar() end)
		else		
			DCS_AddMenuItem(_translate("Save").." ("..GetDisplayName()..")", function() _addon.saveDefaultPosition() end)
			if not _addon.autoSavePos then
				local charName = zo_strformat(GetUnitName('player'))
				DCS_AddMenuItem(_translate("Save").." ("..charName..")", function() _addon.savePosition() end)
			end	
			--DCS_AddMenuItem(_translate("Lock"), function() _addon.lockStatusBar() end)
		end	
		DCS_AddMenuItem(_translate("Toggle Stock"), function() _addon.setShowStock(not _addon.showStock) end)
		DCS_AddMenuItem(_translate("Toggle Raw Stock"), function() _addon.setShowRawStock(not _addon.showRawStock) end)
		DCS_AddMenuItem(_translate("Toggle Surveys"), function() _addon.setShowSurveys(not _addon.showSurveys) end)
	end	
	if _addon.alwaysOn then
		DCS_AddMenuItem(_translate("Auto-hide"), function() _addon.setAlwaysOn(not _addon.alwaysOn) end)
	else
		DCS_AddMenuItem(_translate("Always On"), function()_addon.setAlwaysOn(not _addon.alwaysOn) end)
	end	
	DCS_AddMenuItem(_translate("Loot Mail"), function() _addon.lootHirelingMail(true)	end)
	DCS_AddMenuItem(_translate("Alts Status"), function() _addon.showAltStatus() end)
	if SLASH_COMMANDS["/dcsbarmenu"] then
		DCS_AddMenuItem(_translate("Settings").."...", function() SLASH_COMMANDS["/dcsbarmenu"]() end)
	end	

	ShowMenu()
end	

----------------------------------------------------------------------


function _addon.showMainTooltip()
	local s = _addon.toolTipText 
	local _, s2 = _addon.itemTableToStockString(_addon.lowStockHist,_addon.lowThres,true,true,{},24)

	--if s=="" and s2=="" then return end
	if s~="" and s2~="" then s = s .. "|r\n" end
	if s2=="" then s2 = "(" .. GetString(SI_INVENTORY_ERROR_FILTER_EMPTY) .. ")" end
	--GetString(SI_GAMEPAD_INVENTORY_QUEST_ITEMS)
	s2 = "|t32:32:esoui/art/guild/tabicon_history_up.dds|t|cFFD000" .. _translate("Low Quantity") .. ":|r\n" .. s2 
	InitializeTooltip(InformationTooltip, _addon.label, BOTTOM, 0, 0)
	SetTooltipText(InformationTooltip, s .. s2)
	InformationTooltipTopLevel:BringWindowToTop()
end

function _addon.iconOnMouseUp(control,button)
	if button==MOUSE_BUTTON_INDEX_RIGHT then
		_addon.showMainMenu()
	else		
		if _addon.posLocked==false then
			if _addon.accountSettings.autoSavePos then
			  _addon.savePosition()
			end 
		else	
			_addon.showMainTooltip()
		end	

	end 
end

function _addon.icon2OnMouseUp(control,button)
	if button==MOUSE_BUTTON_INDEX_RIGHT then
		_addon.showMainMenu(true)
	else	
		_addon.showMainTooltip()
	end 
end

function _addon.labelOnMouseUp(control,button)
	if button==MOUSE_BUTTON_INDEX_RIGHT then
		_addon.showMainMenu()
	else		
		_addon.showMainTooltip()
	end	
end

function _addon.hideTooltip()
	ClearTooltip(InformationTooltip)
end

function _addon.stockOnMouseUp(control,button)
	if button==MOUSE_BUTTON_INDEX_RIGHT then
		ClearMenu()
		DCS_AddMenuItem(_translate("Toggle Stock"), function() _addon.setShowStock(not _addon.showStock) end)
		DCS_AddMenuItem(_translate("Toggle Raw Stock"), function() _addon.setShowRawStock(not _addon.showRawStock) end)
		DCS_AddMenuItem(_translate("Mail Stock"), function() _addon.countMatsInMail() end)
		DCS_AddMenuItem(_translate("Loot Mail"), function() _addon.lootHirelingMail(true) end)
		ShowMenu()
	else
		if _addon.toolTipTextStock=="" then return end
		InitializeTooltip(InformationTooltip, _addon.stock, BOTTOM, 0, 0)
		SetTooltipText(InformationTooltip, _addon.toolTipTextStock)
		InformationTooltipTopLevel:BringWindowToTop()
	end
end

function _addon.surveysOnMouseUp(control,button)
	if button==MOUSE_BUTTON_INDEX_RIGHT then
		--todo: use IsMenuVisible once the misspelling is corrected (IsMenuVisisble)
		if not ZO_Menu.items or #ZO_Menu.items==0 then --link menu possibly on
			ClearMenu()
			DCS_AddMenuItem(_translate("Toggle Surveys"), function() _addon.setShowSurveys(not _addon.showSurveys) end)
			if #_addon.surveysPickList>0 then 	
				DCS_AddMenuItem(_translate("Clear Survey Pick List"), function() 
						_addon.surveysPickList = {}
						_out("survey pick list cleared")
						_addon.updateSurveys()
					end)
			end  		
			ShowMenu()
		end	
	end
end

function _addon.updateAll()
--d("UPDATEALLSTART " .. GetGameTimeMilliseconds())
	_addon.updateDailyCraftStates()
	_addon.updateStock()
	_addon.updateSurveys()
	_addon.updateAnchors() --this one also updates position
	_addon.pendingUpdates = false
--d("UPDATEALLEND " .. GetGameTimeMilliseconds())
end	


------------------------------------------------------------------------
-- local addon-specific functions
------------------------------------------------------------------------

local function DCS_questAdded(eventCode,journalIndex)

	--GetJournalQuestInfo(journalIndex)
	--if quest is fullfilled with items from backpack/craft bag, it is already automatically marked as Complete before this event triggers
	--sadly, conditions and steps are already gone and quest info contains no useful info for potential material shortages
	--parse quest background info? nah...

	if GetJournalQuestType(journalIndex)==QUEST_TYPE_CRAFTING then
		if GetJournalQuestRepeatType(journalIndex)==QUEST_REPEAT_DAILY then
			_addon.characterSettings.lastCraftAdded = GetTimeStamp()
			_addon.dailyReset = false
		end
	end	
	
	if _addon.hiddenInScene then 
		_addon.pendingUpdates = true
		return 
	end
	_addon.updateDailyCraftStates()
	_addon.updatePosition()
	_addon.showStatusBar()
end

local function DCS_questUpdate(eventCode)
	if _addon.hiddenInScene then 
		_addon.pendingUpdates = true
		return 
	end
	_addon.updateDailyCraftStates()
	_addon.showStatusBar()
end

local function DCS_ridingSkillChanged(eventCode)
	_addon.saveCharStatus()
	if _addon.hiddenInScene then 
		_addon.pendingUpdates = true
		return
	end
	_addon.updateDailyCraftStates()
	_addon.updatePosition()
end

local function DCS_researchUpdated(eventCode)
	if _addon.hiddenInScene then 
		_addon.pendingUpdates = true
		return
	end
	_addon.updateDailyCraftStates()
	_addon.updatePosition()
end

local function DCS_playerActivated()
	_addon.lastSurveyUsed = nil --switching zones

	_addon.saveCharStatus()

	_addon.updateAll()
	_addon.showStatusBar()
end

-- sadly this is NOT triggered when you QUIT instead of LOGOUT
local function DCS_playerDeactivated()
	_addon.saveCharStatus()
end

local function DCS_hideInCombat(eventCode, inCombat)
	if inCombat then
		_addon.hideStatusBar(true)
	else  
		_addon.showStatusBar()
	end  
end

local function _anyIDsInTable(t)
	if t then
		for i=1,#t do
			if t[i]~="" then return true end
		end	
	end
	return false
end

local function DCS_inventoryUpdated(eventCode,bagId,slotId,isNewItem,_, _,stackChange)
	if _addon.hiddenInScene then 
		_addon.pendingUpdates = true
		return 
	end

	if _addon.showInvSpace then
		_addon.updateDailyCraftStates()
		_addon.showStatusBar()
	end

	--if _addon.bar:IsHidden() then return end
	
	local updsurveyf = false
	local updstockf = false

	local stackSize = GetSlotStackSize(bagId,slotId)
	if not stackSize or stackSize==0 then	
		--what exactly is gone and where to? 
		updstockf = true
		updsurveyf = true
		_addon.lastSurveyUsed = nil
	else	
		local itemType, specializedItemType = GetItemType(bagId,slotId)
		if specializedItemType==SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT then
			updsurveyf = true
			--this is not perfect but will do
			if bagId==BAG_BACKPACK and stackChange==-1 then _addon.lastSurveyUsed = GetItemLink(bagId,slotId) end
		else	
			if (itemType == ITEMTYPE_BLACKSMITHING_MATERIAL or itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL) or 
					(itemType == ITEMTYPE_CLOTHIER_MATERIAL or itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL) or 
					(itemType == ITEMTYPE_WOODWORKING_MATERIAL or itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL) or
					(itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL or itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL) then

				if isNewItem then	
					_addon.mailStock = {}	
				end	
				updstockf = true
			else
				if updstockf==false then
					if _anyIDsInTable(_addon.accountSettings.customMats) then updstockf = true end
				end	
				if updstockf==false then
					if _anyIDsInTable(_addon.characterSettings.customMats) then updstockf = true end
				end	
			end
		end
	end
	if updstockf then _addon.updateStock() end
	if updsurveyf then _addon.updateSurveys() end
	
end

local function DCS_bankOpened(eventCode,bagId)
	if #_addon.surveysPickList>0 then
		_addon.moveSurveys(bagId)
	end
end

------------------------------------------------------------------------
-- INITIALIZATION
------------------------------------------------------------------------

local function DCS_loadAddon(eventName, addonName)
	if addonName ~= _addon.name then return end
	
	SLASH_COMMANDS[_addon.slashCmd] = _addon.runCommand

	if (GetWorldName() == "EU Megaserver") then
		_addon.lastDailyReset = GetLastDailyReset_EU
	else
		_addon.lastDailyReset = GetLastDailyReset_NA
	end


	_addon.bar = DailyCraftStatusMainWindow
	_addon.icon = DailyCraftStatusMainWindowIcon
	_addon.label = DailyCraftStatusMainWindowLabel
	_addon.stock = DailyCraftStatusMainWindowStock
	_addon.surveys = DailyCraftStatusMainWindowSurveys
	_addon.bgmini = DailyCraftStatusMainWindowBgMini
	_addon.bgfull = DailyCraftStatusMainWindowBgFull
	_addon.alts = DailyCraftStatusAltsWindow

--WIP:
	_addon.stubicon = DailyCraftStatusStubIcon
	_addon.stubfrag = ZO_HUDFadeSceneFragment:New(DailyCraftStatusStub)


	_addon.loadSavedVariables()
	_addon.updatePositionFromVars()
	_addon.registerSceneCallbacks()
	
	_addon.createOptionsMenu()
	
	if LibCustomMenu then
		if not _addon.accountSettings.noLibs then
			DCS_AddMenuItem = AddCustomMenuItem
		end
	end	
	_addon.AddMenuItem = DCS_AddMenuItem


	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_QUEST_ADDED, DCS_questAdded, false )
	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_QUEST_ADVANCED, DCS_questUpdate, false )
	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_QUEST_COMPLETE, DCS_questUpdate, false )
	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_QUEST_CONDITION_COUNTER_CHANGED, DCS_questUpdate, false )
	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_QUEST_REMOVED  , DCS_questUpdate, false )
	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_PLAYER_ACTIVATED , DCS_playerActivated, false )
	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_PLAYER_DEACTIVATED , DCS_playerDeactivated, false )
	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_PLAYER_COMBAT_STATE , DCS_hideInCombat, false )
	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE , DCS_inventoryUpdated)
	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_INVENTORY_BAG_CAPACITY_CHANGED, DCS_inventoryUpdated)
	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_RIDING_SKILL_IMPROVEMENT,DCS_ridingSkillChanged)
	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_SMITHING_TRAIT_RESEARCH_COMPLETED,DCS_researchUpdated)
	  --research cancelled and research level upgraded do not really require any attention
	  --the status bar is updated anyway after returning from their respective UI fragment
	  --this is not the case for eg. riding skills as these can be upgraded from inventory
	EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_OPEN_BANK, DCS_bankOpened)

	if _addon.trackAlts and _addon.altsModule then 
		_addon.altsModule.initialize()
	end	

	EVENT_MANAGER:UnregisterForEvent(_addon.name, EVENT_ADD_ON_LOADED)
end
 
EVENT_MANAGER:RegisterForEvent(_addon.name, EVENT_ADD_ON_LOADED, DCS_loadAddon)


