DRCPA = DRCPA or {}
DRCPA.Name = "DRCPA"
DRCPA.Version = "1.0.2"

DRCPA.Color = {
	[1] = "|cA5DB52",
	[2] = "|cA5DB52",
	[3] = "|cA5DB52",
	[4] = "|cA5DB52",
	[5] = "|c5ABAE7",
	[6] = "|c5ABAE7",
	[7] = "|c5ABAE7",
	[8] = "|c5ABAE7",
	[9] = "|cE76931",
	[10] = "|cE76931",
	[11] = "|cE76931",
	[12] = "|cE76931",
}

DRCPA.Cooldown = 0
DRCPA.LoadAfterCooldown = nil
DRCPA.LoadAfterCombat = nil

local cancelAnimation = false

function DRCPA.CompareSelectedStars(setId)
	for slotIndex = 1, 12 do
		local selectedSkilId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_CHAMPION)
		local setSkillId = DressingRoom.ram.page.pages[DressingRoom.sv.page.current].cpSet[setId][slotIndex]
		
		if setSkillId == nil or setSkillId ~= selectedSkilId then
			return false
		end
	end

	return true
end

function DRCPA.GetCPTooltip(setId)
	if not DressingRoom.ram.page.pages[DressingRoom.sv.page.current].cpSet or not DressingRoom.ram.page.pages[DressingRoom.sv.page.current].cpSet[setId] then
		return DRCPA.lang.cpHover
	end
	local cpText = {}
	for slotIndex = 1, 12 do
		local skillId = DressingRoom.ram.page.pages[DressingRoom.sv.page.current].cpSet[setId][slotIndex]
		if skillId then
			local skillName = zo_strformat("<<C:1>>", GetChampionSkillName(skillId))
			if #skillName > 0 then
				local line = string.format("%s%s|r", DRCPA.Color[slotIndex], skillName)
				table.insert(cpText, line)
			end
		end
	end
	table.insert(cpText, "\n" .. DRCPA.lang.cpHover)
	return table.concat(cpText, "\n")
end

function DRCPA.HookDressingRoom()
	local oldLoadSet = DressingRoom.LoadSet
	DressingRoom.LoadSet = function(DressingRoom, setId)
		oldLoadSet(DressingRoom, setId)
		DressingRoom:LoadCP(setId)
	end

	DressingRoom.SaveCP = function(DressingRoom, setId)
		if DressingRoom.ram.page.pages[DressingRoom.sv.page.current].cpSet == nil then
			DressingRoom.ram.page.pages[DressingRoom.sv.page.current].cpSet = {}
		end
		
		local hotbar = {}
		for slotIndex = 1, 12 do
			local skilId = GetSlotBoundId(slotIndex, HOTBAR_CATEGORY_CHAMPION)
			local skillPoints = GetNumPointsSpentOnChampionSkill(skilId)
			hotbar[slotIndex] = nil
			if skillPoints > 0 then
				hotbar[slotIndex] = skilId
			end
		end
		
		DressingRoom.ram.page.pages[DressingRoom.sv.page.current].cpSet[setId] = hotbar
		
		DRCPA.Log(DRCPA.lang.cpSetSaved, setId)
	end
		
	DressingRoom.LoadCP = function(DressingRoom, setId)
		if DressingRoom.ram.page.pages[DressingRoom.sv.page.current].cpSet == nil or DressingRoom.ram.page.pages[DressingRoom.sv.page.current].cpSet[setId] == nil then
			DRCPA.Log(DRCPA.lang.noCPSaved, setId)
			return
		end
		
		if DRCPA.CompareSelectedStars(setId) == true then
			DRCPA.Cooldown = 0
			EVENT_MANAGER:UnregisterForUpdate(DRCPA.Name .. "Loop")
			DRCPA.LoadAfterCooldown = nil
			DRCPA.Log(DRCPA.lang.cpSetLoaded, setId)
			return
		end
		
		if DRCPA.Cooldown > 0 then
			DRCPA.LoadAfterCooldown = setId
			DRCPA.Log(DRCPA.lang.loadAfterCooldown, setId, DRCPA.Cooldown)
			return
		end
		
		if IsUnitInCombat("player") then
			DRCPA.LoadAfterCombat = setId
			return
		end
		
		-- fixes animation call with nil values
		if CHAMPION_PERKS_SCENE:GetState() == "shown" then
			CHAMPION_PERKS:PrepareStarConfirmAnimation()
			cancelAnimation = false
		else
			cancelAnimation = true
		end
		
		PrepareChampionPurchaseRequest()
		
		for slotIndex = 1, 12 do
			if DressingRoom.ram.page.pages[DressingRoom.sv.page.current].cpSet[setId][slotIndex] ~= nil then
				AddHotbarSlotToChampionPurchaseRequest(slotIndex, DressingRoom.ram.page.pages[DressingRoom.sv.page.current].cpSet[setId][slotIndex])
			end
		end
		
		SendChampionPurchaseRequest()
		DRCPA.Log(DRCPA.lang.cpSetLoaded, setId)
	end
	
	DressingRoom.DeleteCP = function(DressingRoom, setId)
		if DressingRoom.ram.page.pages[DressingRoom.sv.page.current].cpSet == nil then
			return
		end
		DressingRoom.ram.page.pages[DressingRoom.sv.page.current].cpSet[setId] = nil
	end
		
	local oldResizeWindow = DressingRoom.ResizeWindow
	DressingRoom.ResizeWindow = function(DressingRoom)
		oldResizeWindow(DressingRoom)
		
		local sbtnSize = DressingRoom.options.btnSize
		local sbtnVSpacing = sbtnSize + 5
		local sbtnHSpacing = sbtnSize + 3
		local skillBorderWidth = sbtnHSpacing * 5 + sbtnSize + 2
		local setBtnSize = sbtnVSpacing + sbtnSize + 2
		for setId = 1, DressingRoom:numSets() do
			DressingRoom.cpBtn[setId]:SetDimensions(sbtnSize+2, sbtnSize+2)
			DressingRoom.setLabel[setId].bg:SetDimensions(skillBorderWidth + setBtnSize + 2 - (sbtnSize + 4), sbtnSize + 2)
			local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = DressingRoom.setLabel[setId].bg:GetAnchor()
			DressingRoom.setLabel[setId].bg:SetAnchor(point, relativeTo, relativePoint, offsetX - (sbtnSize + 4), offsetY)
		end
	end
		
	-- Setting up cp button
	DressingRoom.cpBtn = {}
	for setId = 1, DressingRoom:numSets() do
		local sbtnSize = DressingRoom.options.btnSize
		local b = DRCPA.CreateButton("DressingRoom_CPBtn_"..setId)
		b:SetAnchor(BOTTOM, DressingRoom.barBtn[setId][1], TOP, (sbtnSize + 4) * -1, -2)
		b:SetNormalTexture("ESOUI/art/mainmenu/menubar_champion_up.dds")
		b:SetMouseOverTexture("ESOUI/art/mainmenu/menubar_champion_over.dds")
		b:SetPressedTexture("ESOUI/art/mainmenu/menubar_champion_down.dds")
		b.text = DRCPA.lang.cpHover
		b.setId = setId
		b:SetHandler("OnMouseDown", function(self, btn, ctrl, alt, shift)
			if shift == true then DressingRoom:SaveCP(setId)
			elseif ctrl == true then DressingRoom:DeleteCP(setId)
			else DressingRoom:LoadCP(setId) end
		end)
		b:SetHandler("OnMouseEnter", function(self)
			self.bg:SetCenterColor(1, 0.73, 0.35, 0.25)
			self.bg:SetEdgeColor(1, 0.73, 0.35, 1)
			
			local cpText = DRCPA.GetCPTooltip(setId)
			if cpText then
				ZO_Tooltips_ShowTextTooltip(self, RIGHT, cpText)
			end
		end)
		DressingRoom.cpBtn[setId] = b
	end	
		
	-- refresh window
	DressingRoom:RefreshWindowData()
	DressingRoom:ResizeWindow()
end

function DRCPA.UpdateCooldown()
	if DRCPA.Cooldown > 0 then
		DRCPA.Cooldown = DRCPA.Cooldown - 1
		return
	end
	
	DRCPA.Cooldown = 0
	EVENT_MANAGER:UnregisterForUpdate(DRCPA.Name .. "Loop")
	
	if DRCPA.LoadAfterCooldown ~= nil then
		DressingRoom:LoadCP(DRCPA.LoadAfterCooldown)
		DRCPA.LoadAfterCooldown = nil
	end
end

function DRCPA.Log(str, ...)
	if DressingRoom.options.showChatMessages then
		d("[DressingRoom] " .. string.format(str, ...))
		if(str == DRCPA.lang.cpSetLoaded) then
			--CHAMPION_POINTS_COMMITTED
			PlaySound(SOUNDS.CHAMPION_RESPEC_ACCEPT)
		end
	end
end

function DRCPA.Initialize()
	ZO_PreHook(CHAMPION_PERKS, "StartStarConfirmAnimation", function()
		if cancelAnimation then
			cancelAnimation = false
			return true 
		end
	end)
	
	EVENT_MANAGER:RegisterForEvent(DRCPA.name, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
		if inCombat == false then
			if DRCPA.LoadAfterCombat ~= nil then
				DressingRoom:LoadCP(DRCPA.LoadAfterCombat)
				DRCPA.LoadAfterCombat = nil
			end
		end
	end)
	
	EVENT_MANAGER:RegisterForEvent(DRCPA.name, EVENT_CHAMPION_PURCHASE_RESULT, function(_, result)
		if result == CHAMPION_PURCHASE_SUCCESS then
			DRCPA.Cooldown = 31
			EVENT_MANAGER:RegisterForUpdate(DRCPA.Name .. "Loop", 1000, DRCPA.UpdateCooldown)
		end
	end)
end

function DRCPA.OnAddOnLoaded(_, addonName)
	if addonName ~= DRCPA.Name then return end
	
	zo_callLater(function()
		if DressingRoom then
			DRCPA.Initialize()
			DRCPA.HookDressingRoom()
		else
			d("No DressingRoom detected.")
			return
		end
	end, 1000)
end

-- Stolen to get the same style :X
-- https://www.esoui.com/downloads/info2138-DressingRoomforStonethorn.html
function DRCPA.CreateButton(name)
	local c = WINDOW_MANAGER:CreateControl(name, DressingRoomWin, CT_BUTTON)
	local b = WINDOW_MANAGER:CreateControl(name.."_BG", c, CT_BACKDROP)
	
	c:SetMouseEnabled(true)
	c:SetState(BSTATE_NORMAL)
	c:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	c:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	c:SetFont("$(MEDIUM_FONT)|"..DressingRoom.options.fontSize)
	c:SetHandler("OnMouseEnter", function(self)
		if self.text then ZO_Tooltips_ShowTextTooltip(self, RIGHT, self.text) end
		b:SetCenterColor(1, 0.73, 0.35, 0.25)
		b:SetEdgeColor(1, 0.73, 0.35, 1)
	end)
	c:SetHandler("OnMouseExit",function(self)
		ZO_Tooltips_HideTextTooltip()
		b:SetCenterColor(1, 0.73, 0.35, 0.05)
		b:SetEdgeColor(0.7, 0.7, 0.6, 1)
	end)
	c:SetNormalTexture("ESOUI/art/mainmenu/menubar_skills_up.dds")
	c:SetMouseOverTexture("ESOUI/art/mainmenu/menubar_skills_over.dds")
	c:SetPressedTexture("ESOUI/art/mainmenu/menubar_skills_down.dds")
	
	b:SetAnchorFill()
	b:SetEdgeTexture("", 1, 1, 1)
	b:SetCenterColor(1, 0.73, 0.35, 0.05)
	b:SetEdgeColor(0.7, 0.7, 0.6, 1)
	
	c.bg = b
	
	return c
end

EVENT_MANAGER:RegisterForEvent(DRCPA.Name, EVENT_ADD_ON_LOADED, DRCPA.OnAddOnLoaded)