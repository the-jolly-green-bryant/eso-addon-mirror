CPH = {
    name            = "CPHotkey",          
    author          = "Hyperioxes",
    color           = "DDFFEE",            
    menuName        = "CPHotkey",          
}

local colorsByTree = {
	[1] = {0,117/255,16/255,1}, --green
	[2] = {0,186/255,232/255,1}, --blue
	[3] = {219/255,15/255,0,1} --red
}

local CPCooldownEndsAt = 0
local hideUI = false
local dropdown


local function CPH_GetChampionSkillName(id)
	if id then
		return GetChampionSkillName(id)
	end
	return "none"
end



function printCP()
	for disciplineIndex = 1, 3 do
		for skInd=1, GetNumChampionDisciplineSkills(disciplineIndex) do	
			local skId = GetChampionSkillId(disciplineIndex, skInd)
			d(skId.."     "..GetChampionSkillName(skId))
		end
	end


end

function testCP()
	--[[for i=1, 12 do
		if CHAMPION_PERKS:GetChampionBar() :GetSlot(i).championSkillData then
			d("Slot number "..i.."  "..CHAMPION_PERKS:GetChampionBar() :GetSlot(i).championSkillData:GetId())
		end
	end]]


	for disciplineIndex = 1, 3 do
		for skInd=1, GetNumChampionDisciplineSkills(disciplineIndex) do	
			local skId = GetChampionSkillId(disciplineIndex, skInd)
			local skType = GetChampionSkillType(skId)
		end
	end



	PrepareChampionPurchaseRequest(true)
	for i=1, 12 do
		d("attempting to unslot "..i)
		AddHotbarSlotToChampionPurchaseRequest(i, 0) 
	end
	for disciplineIndex = 1, 3 do --clear all non passive points
		for skillIndex=1, GetNumChampionDisciplineSkills(disciplineIndex) do	
			local id = GetChampionSkillId(disciplineIndex, skillIndex)
			if GetChampionSkillType(id) ~= 0 then
				AddSkillToChampionPurchaseRequest(id,0)
			end

		end
	end
	SendChampionPurchaseRequest()
end

-- 0 passive
-- 1 slottable
-- 2 slottable non connected

function CPHLoadSetup(setupNumber)
	if GetGameTimeSeconds() > CPCooldownEndsAt then
		local requiredPoints = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		}
		local needRespec = false













		local tableOfRequiredCP = {}
		
		for i=1, 12 do --unslot all bars
			AddHotbarSlotToChampionPurchaseRequest(i, 0) 
		end
		for i=1,3 do
			for n=1,4 do
				local id = CPHsavedVars.profiles[CPHsavedVars.selectedProfile][setupNumber][((i-1)*4)+n]
				if id then
					if GetChampionSkillType ~= 2 then
						local pathTable = CPHGetPath(id)  
						for _,pathPoint in pairs(pathTable) do
							local _,minimum = GetChampionSkillJumpPoints(pathPoint)
							if GetNumPointsSpentOnChampionSkill(pathPoint)<minimum and not tableOfRequiredCP[pathPoint] then
								requiredPoints[i] = requiredPoints[i] + minimum - GetNumPointsSpentOnChampionSkill(pathPoint)
							end
							tableOfRequiredCP[pathPoint] = true
						end
					end
					requiredPoints[i] = requiredPoints[i] + GetChampionSkillMaxPoints(id) - GetNumPointsSpentOnChampionSkill(id)
					tableOfRequiredCP[id] = true
				end
			end
		end

		for k,v in pairs(requiredPoints) do
			if GetNumUnspentChampionPoints(k) < v then
				needRespec = true
			end
		end

		if not needRespec then
			PrepareChampionPurchaseRequest(needRespec)
			for i=1, 12 do
				local id = CPHsavedVars.profiles[CPHsavedVars.selectedProfile][setupNumber][i]
				--d(id)
				--if GetNumPointsSpentOnChampionSkill(id) < GetChampionSkillMaxPoints(id) then -- if not fully maxed
				if id then
					if GetChampionSkillType ~= 2 then -- if not standalone node
						local pathTable = CPHGetPath(id)   
						for _,pathPoint in pairs(pathTable) do
							local _,minimum = GetChampionSkillJumpPoints(pathPoint)
							if GetChampionSkillType(pathPoint) == 1 then --if slottable
								--d("attempting to put "..minimum.."points into "..GetChampionSkillName(pathPoint))
								if minimum > GetNumPointsSpentOnChampionSkill(pathPoint) then
									AddSkillToChampionPurchaseRequest(pathPoint,minimum)
								end
							elseif GetNumPointsSpentOnChampionSkill(pathPoint) < minimum then -- if less than minimum
								--d("attempting to put "..minimum.."points into "..GetChampionSkillName(pathPoint))
								AddSkillToChampionPurchaseRequest(pathPoint,minimum)
							end
						end
					end
					--d("attempting to put "..GetChampionSkillMaxPoints(id).."points into "..GetChampionSkillName(id))
					AddSkillToChampionPurchaseRequest(id,GetChampionSkillMaxPoints(id))
				end
				--end
				--d("attempting to slot "..GetChampionSkillName(id).." which has "..GetNumPointsSpentOnChampionSkill(id).." points out of maximum "..GetChampionSkillMaxPoints(id))
				AddHotbarSlotToChampionPurchaseRequest(i, id) 
			end
			SendChampionPurchaseRequest()
			CPCooldownEndsAt = GetGameTimeSeconds() + 30
			d("Setup number "..setupNumber.." loaded without respec")


		elseif needRespec and CPHsavedVars.allowRespec then
			PrepareChampionPurchaseRequest(needRespec)
			if needRespec then
				for disciplineIndex = 1, 3 do --clear all non passive points
					for skillIndex=1, GetNumChampionDisciplineSkills(disciplineIndex) do	
						local id = GetChampionSkillId(disciplineIndex, skillIndex)
						if GetChampionSkillType(id) ~= 0 and not tableOfRequiredCP[id] then
							--d("wiping "..GetChampionSkillName(id))
							AddSkillToChampionPurchaseRequest(id,0)
						end

					end
				end
			end
			for i=1, 12 do
				local id = CPHsavedVars.profiles[CPHsavedVars.selectedProfile][setupNumber][i]
				--d(id)
				--if GetNumPointsSpentOnChampionSkill(id) < GetChampionSkillMaxPoints(id) then -- if not fully maxed
				if id then
					if GetChampionSkillType ~= 2 then -- if not standalone node
						local pathTable = CPHGetPath(id)   
						for _,pathPoint in pairs(pathTable) do
							local _,minimum = GetChampionSkillJumpPoints(pathPoint)
							if GetChampionSkillType(pathPoint) == 1 then --if slottable
								--d("attempting to put "..minimum.."points into "..GetChampionSkillName(pathPoint))
								AddSkillToChampionPurchaseRequest(pathPoint,minimum)
							elseif GetNumPointsSpentOnChampionSkill(pathPoint) < minimum then -- if less than minimum
								--d("attempting to put "..minimum.."points into "..GetChampionSkillName(pathPoint))
								AddSkillToChampionPurchaseRequest(pathPoint,minimum)
							end
						end
					end
					--d("attempting to put "..GetChampionSkillMaxPoints(id).."points into "..GetChampionSkillName(id))
					AddSkillToChampionPurchaseRequest(id,GetChampionSkillMaxPoints(id))
				end
				--end
				--d("attempting to slot "..GetChampionSkillName(id).." which has "..GetNumPointsSpentOnChampionSkill(id).." points out of maximum "..GetChampionSkillMaxPoints(id))
				AddHotbarSlotToChampionPurchaseRequest(i, id) 
			end
		
		
			SendChampionPurchaseRequest()
			CPCooldownEndsAt = GetGameTimeSeconds() + 30
			d("Setup number "..setupNumber.." loaded with respec")

		else
			d("Setup number "..setupNumber.." couldn't be loaded because it would require a respec")
		end
	else
		d("CP Change is still on cooldown")
	end
end




local function checkIfTableContains(element,table)
	for k,v in pairs(table) do
		if v==element then 
			return true
		end
	end
	return false
end

local function tableMerge(table1,table2)
	if table2 then
		for _,v in pairs(table2) do
			table.insert(table1,v)
		end
	end
end
--/script d(findCheapestPathToRoot(84))


local function printOutTable(table)
	local holder = ""
	for k,v in pairs(table) do
		holder = holder.." - "..v
	end
	return holder
end

function CPHGetPath(GlobalId)
	local saveBestResult
	local saveBestCost

	local stepsTaken = {}
	local step = 1

	local function findCheapestPathToRoot(id,alreadyCheckedBefore)
		local alreadyChecked = alreadyCheckedBefore or {[id] = true}
		local cost = 0

		if IsChampionSkillRootNode(id) then
			--d("Found root:"..id.." "..GetChampionSkillName(id))
			if DoesChampionSkillHaveJumpPoints(id) then
				local _,minimum = GetChampionSkillJumpPoints(id)
				cost = cost+minimum
			else
				cost = cost+GetChampionSkillMaxPoints(id)
			end
			return true,0,{}
		end


		local didFindRoot = false


		local tableOfLinks = {GetChampionSkillLinkIds(id)}


		if type(tableOfLinks) == "table" then
			for _,v in pairs(tableOfLinks) do

				if not alreadyChecked[v] and not stepsTaken[v] then
					alreadyChecked[v] = true
					--d("Starting checking"..v.." "..GetChampionSkillName(v))
					step = step+1
					didFindRoot,addedCost,addedPath = findCheapestPathToRoot(v,alreadyChecked)
					step = step-1

					--d("Exiting"..v.." "..GetChampionSkillName(v))
					if didFindRoot then
						if DoesChampionSkillHaveJumpPoints(v) then
							local _,minimum = GetChampionSkillJumpPoints(v)
							cost = cost+minimum
						else
							cost = cost+GetChampionSkillMaxPoints(v)
						end
						table.insert(addedPath,v)
						--d(addedPath)
						--d(cost+addedCost)
						if step == 2 then
							stepsTaken[v] = true
						end
						return true,cost+addedCost,addedPath
					end
				end
			end
		end
		
		


		--if didFindRoot then
			--d(printOutTable(globalResult))
		--end
	end
	

	_,saveBestCost,saveBestResult = findCheapestPathToRoot(GlobalId)
	for i=1, 15 do
		local _,cost,result = findCheapestPathToRoot(GlobalId)
		if (cost or 1000) < saveBestCost then
			saveBestCost = cost
			saveBestResult = result
		end
	end

	return saveBestResult,saveBestCost
end

local function pickAnyValueFromTable(table)
	for _,v in pairs(table) do
		return v
	end
end

local function pickAnyKeyFromTable(table)
	for k,_ in pairs(table) do
		return k
	end
end


local function updateCPHolders()
	for k=1,6 do
		for n=1,3 do
			for i=1,4 do
				local CPHHolderText = CPHotkeyUI:GetNamedChild("CPHHolderText"..i+((n-1)*4)..k)
				CPHHolderText:SetText(CPH_GetChampionSkillName(CPHsavedVars.profiles[CPHsavedVars.selectedProfile][k][i+((n-1)*4)]))
			end
		end
	end
end

local function dropdownCallback(_,choice)
	CPHsavedVars.selectedProfile = choice
	updateCPHolders()
end





local function updateDropdown()
	dropdown:ClearItems()
	for profileName,profile in pairs(CPHsavedVars.profiles) do
		local entry = dropdown:CreateItemEntry(profileName,dropdownCallback)
		dropdown:AddItem(entry)
		if profileName == CPHsavedVars.selectedProfile then
			dropdown:SelectItem(entry)
		end
	end
end



local function getBindingName(keyStr)
	local layIdx, catIdx, actIdx = GetActionIndicesFromName(keyStr)
	local keyCode, mod1, mod2, mod3, mod4 = GetActionBindingInfo(layIdx, catIdx, actIdx, 1)
	if layIdx and keyCode > 0 then 
		return ZO_Keybindings_GetBindingStringFromKeys(keyCode, mod1, mod2, mod3, mod4)
	else 
		return '' 
	end
end






local function deleteProfile()
	CPHsavedVars.profiles[CPHsavedVars.selectedProfile] = nil
	CPHsavedVars.selectedProfile = pickAnyKeyFromTable(CPHsavedVars.profiles)
	updateDropdown()
	updateCPHolders()
end

local function createProfile(profileName)
	CPHsavedVars.profiles[profileName] = {
				[1] = {},
				[2] = {},
				[3] = {},
				[4] = {},
				[5] = {},
				[6] = {},
	}
	CPHsavedVars.selectedProfile = profileName
	updateDropdown()
	updateCPHolders()
end

local function changeProfileName(changeTo)
	CPHsavedVars.profiles[changeTo] = CPHsavedVars.profiles[CPHsavedVars.selectedProfile]
	CPHsavedVars.profiles[CPHsavedVars.selectedProfile] = nil
	CPHsavedVars.selectedProfile = changeTo
	updateDropdown()
	updateCPHolders()
end

local function ToggleUI() 
	hideUI = not hideUI
	if hideUI then
		CPHotkeyUI:SetHidden(true)
	else
		CPHotkeyUI:SetHidden(false)
	end
end

local function CPHUpdateFunction()
	local counter = CPHotkeyCounter:GetNamedChild("CPHCounter")
	if GetGameTimeSeconds() < CPCooldownEndsAt then
		counter:SetText(math.floor(CPCooldownEndsAt-GetGameTimeSeconds()))
		counter:SetHidden(false)
	else
		counter:SetHidden(true)
	end
end





local function InitializeUI()

	ESO_Dialogs["CPHDeletePageConfirm"] = {
    canQueue = true,
    uniqueIdentifier = "CPHDeletePageConfirm",
    title = {text = "Dressing Room"},
    mainText = {text = "Are you sure you want to delete this profile?"},
    buttons = {
      [1] = {
        text = SI_DIALOG_CONFIRM,
        callback = function() 
			deleteProfile()
		end,
      },
      [2] = {
        text = SI_DIALOG_CANCEL,
        callback = function() end,
      },
    },
    setup = function() end,
  }
  ESO_Dialogs["CPHChangeName"] = {
    canQueue = true,
    uniqueIdentifier = "CPHChangeName",
    title = {text = "Dressing Room"},
    mainText = {text = "Enter new name:"},
    editBox = {},
    buttons = {
      [1] = {
        text = SI_DIALOG_CONFIRM,
        callback = function(dialog)
            local txt = ZO_Dialogs_GetEditBoxText(dialog)
            if txt == "" then return end
            changeProfileName(txt)
          end,
      },
      [2] = {
        text = SI_DIALOG_CANCEL,
        callback = function() end,
      },
    },
    setup = function() end,
  }
    ESO_Dialogs["CPHCreateProfile"] = {
    canQueue = true,
    uniqueIdentifier = "CPHCreateProfile",
    title = {text = "Dressing Room"},
    mainText = {text = "Enter name:"},
    editBox = {},
    buttons = {
      [1] = {
        text = SI_DIALOG_CONFIRM,
        callback = function(dialog)
            local txt = ZO_Dialogs_GetEditBoxText(dialog)
            if txt == "" then return end
            createProfile(txt)
          end,
      },
      [2] = {
        text = SI_DIALOG_CANCEL,
        callback = function() end,
      },
    },
    setup = function() end,
  }











	local WM = GetWindowManager()
	
	local CPHotkeyUI = WM:CreateTopLevelWindow("CPHotkeyUI")
	CPHotkeyUI:SetResizeToFitDescendents(true)
    CPHotkeyUI:SetMovable(true)
    CPHotkeyUI:SetMouseEnabled(true)
	CPHotkeyUI:SetHidden(true)
	local CPHotkeyCounter = WM:CreateTopLevelWindow("CPHotkeyCounter")
	CPHotkeyCounter:SetResizeToFitDescendents(true)
    CPHotkeyCounter:SetMovable(true)
    CPHotkeyCounter:SetMouseEnabled(true)
	CPHotkeyCounter:SetHidden(false)
	local CPHotkeyToggle = WM:CreateTopLevelWindow("CPHotkeyToggle")
	CPHotkeyToggle:SetResizeToFitDescendents(true)
    CPHotkeyToggle:SetMovable(true)
    CPHotkeyToggle:SetMouseEnabled(true)
	CPHotkeyToggle:SetHidden(true)
	local Rwidth, Rheight = GuiRoot:GetDimensions()

	--[[CPHotkeyUI:SetHandler("OnMoveStop", function(control)
        CPHsavedVars.xOffset = CPHotkeyUI:GetLeft()
	    CPHsavedVars.yOffset  = CPHotkeyUI:GeCPHop()
    end)]]


	local CPHToggleButton = WM:CreateControl("$(parent)CPHToggleButton", CPHotkeyToggle, CT_BUTTON)
	CPHToggleButton:SetMouseEnabled(true)
	CPHToggleButton:SetState(BSTATE_NORMAL)
	CPHToggleButton:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	CPHToggleButton:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	CPHToggleButton:SetFont("ZoFontGameSmall")
	CPHToggleButton:SetHandler("OnMouseDown", function(self, btn, ctrl, alt, shift)
		ToggleUI()
	end)
	CPHToggleButton:SetNormalTexture("/esoui/art/buttons/eso_buttonlarge_normal.dds")
	CPHToggleButton:SetMouseOverTexture("/esoui/art/buttons/eso_buttonlarge_mouseover.dds")
	CPHToggleButton:SetPressedTexture("/esoui/art/buttons/eso_buttonllarge_mousedown.dds")
	CPHToggleButton:SetAnchor(TOPRIGHT, CPHotkeyToggle,TOPRIGHT,0,0)
	CPHToggleButton:SetDimensions(128,46)
	CPHToggleButton:SetText("Toggle CPHotkey UI")


	local CPHBackground = WM:CreateControl("$(parent)CPHBackground",CPHotkeyUI,  CT_BACKDROP, 4)
	CPHBackground:SetDimensions(800,825)
	CPHBackground:SetAnchor(TOPLEFT,CPHotkeyUI,TOPLEFT,0,0)
	CPHBackground:SetHidden(false)
	CPHBackground:SetDrawLayer(0)
	CPHBackground:SetEdgeTexture("", 1, 1, 1)
	CPHBackground:SetCenterColor(0,0,0, 0.75)
	CPHBackground:SetEdgeColor(0.7, 0.7, 0.6, 1)


	local profilePicker = WM:CreateControlFromVirtual("$(parent)profilePicker", CPHotkeyUI, "ZO_ComboBox")
	profilePicker:SetDimensions(250,35)
	profilePicker:SetAnchor(TOPLEFT,CPHBackground,TOPLEFT,15,15)
	profilePicker:SetHidden(false)
	dropdown = ZO_ComboBox_ObjectFromContainer(profilePicker)
	

	local addButton = WM:CreateControl("$(parent)addButton", CPHotkeyUI, CT_BUTTON)
	addButton:SetDimensions(32, 32)
    addButton:SetAnchor(LEFT, profilePicker, RIGHT, 0, 0)
    addButton:SetState(BSTATE_NORMAL)
    addButton:SetHandler("OnClicked", function()
		ZO_Dialogs_ShowDialog("CPHCreateProfile")
    end)
    addButton:SetNormalTexture("ESOUI/art/buttons/plus_up.dds")
    addButton:SetMouseOverTexture("ESOUI/art/buttons/plus_over.dds")
    addButton:SetPressedTexture("ESOUI/art/buttons/plus_down.dds")

	local deleteButton = WM:CreateControl("$(parent)deleteButton", CPHotkeyUI, CT_BUTTON)
    deleteButton:SetDimensions(32, 32)
    deleteButton:SetAnchor(LEFT, addButton, RIGHT, 0, 0)
    deleteButton:SetState(BSTATE_NORMAL)
    deleteButton:SetHandler("OnClicked", function()
		ZO_Dialogs_ShowDialog("CPHDeletePageConfirm")
    end)
    deleteButton:SetNormalTexture("ESOUI/art/buttons/minus_up.dds")
    deleteButton:SetMouseOverTexture("ESOUI/art/buttons/minus_over.dds")
    deleteButton:SetPressedTexture("ESOUI/art/buttons/minus_down.dds")

	local editButton = WM:CreateControl("$(parent)editButton", CPHotkeyUI, CT_BUTTON)
	editButton:SetDimensions(32, 32)
    editButton:SetAnchor(LEFT, deleteButton, RIGHT, 0, 0)
    editButton:SetState(BSTATE_NORMAL)
    editButton:SetHandler("OnClicked", function()
		ZO_Dialogs_ShowDialog("CPHChangeName")
    end)
    editButton:SetNormalTexture("ESOUI/art/buttons/edit_up.dds")
    editButton:SetMouseOverTexture("ESOUI/art/buttons/edit_over.dds")
    editButton:SetPressedTexture("ESOUI/art/buttons/edit_down.dds")


	for k=1,6 do


		local saveButton = WM:CreateControl("$(parent)saveButton"..k, CPHotkeyUI, CT_BUTTON)
		saveButton:SetMouseEnabled(true)
		saveButton:SetState(BSTATE_NORMAL)
		saveButton:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
		saveButton:SetVerticalAlignment(TEXT_ALIGN_CENTER)
		saveButton:SetFont("ZoFontGameSmall")
		saveButton:SetHandler("OnMouseDown", function(self, btn, ctrl, alt, shift)
			for i=1, 12 do
				if CHAMPION_PERKS:GetChampionBar() :GetSlot(i).championSkillData then -- If anything is slotted into that index
					CPHsavedVars.profiles[CPHsavedVars.selectedProfile][k][i] = CHAMPION_PERKS:GetChampionBar() :GetSlot(i).championSkillData:GetId()
				else
					CPHsavedVars.profiles[CPHsavedVars.selectedProfile][k][i] = nil
				end
				local control = CPHotkeyUI:GetNamedChild("CPHHolderText"..i..k)
				control:SetText(CPH_GetChampionSkillName(CPHsavedVars.profiles[CPHsavedVars.selectedProfile][k][i]))
			end
		end)
		saveButton:SetNormalTexture("/esoui/art/buttons/eso_buttonlarge_normal.dds")
		saveButton:SetMouseOverTexture("/esoui/art/buttons/eso_buttonlarge_mouseover.dds")
		saveButton:SetPressedTexture("/esoui/art/buttons/eso_buttonllarge_mousedown.dds")
		saveButton:SetAnchor(TOPLEFT, CPHBackground,TOPLEFT,16,100+((k-1)*120))
		saveButton:SetDimensions(96,32)
		saveButton:SetText("Save")

		local equipButton = WM:CreateControl("$(parent)equipButton"..k, CPHotkeyUI, CT_BUTTON)
		equipButton:SetMouseEnabled(true)
		equipButton:SetState(BSTATE_NORMAL)
		equipButton:SetHorizontalAlignment(1)
		equipButton:SetVerticalAlignment(1)
		equipButton:SetFont("ZoFontGameSmall")
		equipButton:SetHandler("OnMouseDown", function(self, btn, ctrl, alt, shift)
			CPHLoadSetup(k)
		end)
		equipButton:SetNormalTexture("/esoui/art/buttons/eso_buttonlarge_normal.dds")
		equipButton:SetMouseOverTexture("/esoui/art/buttons/eso_buttonlarge_mouseover.dds")
		equipButton:SetPressedTexture("/esoui/art/buttons/eso_buttonllarge_mousedown.dds")
		equipButton:SetAnchor(TOPLEFT, CPHBackground,TOPLEFT,16,150+((k-1)*120))
		equipButton:SetDimensions(96,32)
		equipButton:SetText("Equip")

		for n=1,3 do
			for i=1,4 do
				local CPHHolder = WM:CreateControl("$(parent)CPHHolder"..i+((n-1)*4)..k,CPHotkeyUI,  CT_BACKDROP, 4)
				CPHHolder:SetDimensions(128,32)
				CPHHolder:SetAnchor(TOPLEFT,CPHBackground,TOPLEFT,128*(i-1)+128,33*(n-1)+96+((k-1)*120))
				CPHHolder:SetHidden(false)
				CPHHolder:SetDrawLayer(1)
				--CPHHolder:SetColor(1,1,1,1)
				CPHHolder:SetEdgeTexture("", 1, 1, 1)
				CPHHolder:SetCenterColor(0,0,0, 0.75)
				CPHHolder:SetEdgeColor(0.7, 0.7, 0.6, 1)
				--CPHHolder:SetTexture("/art/fx/texture/blacksquare.dds")
				local CPHHolderText = WM:CreateControl("$(parent)CPHHolderText"..i+((n-1)*4)..k,CPHotkeyUI,  CT_LABEL, 4)
				CPHHolderText:SetHorizontalAlignment(1)
				CPHHolderText:SetVerticalAlignment(1)
				CPHHolderText:SetAnchor(TOPLEFT,CPHHolder,TOPLEFT,0,0)
				CPHHolderText:SetDimensions(128,32)
				CPHHolderText:SetFont("ZoFontGameSmall")
				CPHHolderText:SetText(CPH_GetChampionSkillName(CPHsavedVars.profiles[CPHsavedVars.selectedProfile][k][i+((n-1)*4)]))
				CPHHolderText:SetColor(unpack(colorsByTree[n]))
			end
		end

		local CPHDescription = WM:CreateControl("$(parent)CPHDescription"..k,CPHotkeyUI,  CT_BACKDROP, 4)
		CPHDescription:SetDimensions(100,75)
		CPHDescription:SetAnchor(TOPLEFT,CPHotkeyUI,TOPLEFT,675,87.5+((k-1)*120))
		CPHDescription:SetHidden(false)
		CPHDescription:SetDrawLayer(0)
		CPHDescription:SetEdgeTexture("", 1, 1, 1)
		CPHDescription:SetCenterColor(0,0,0, 0.75)
		CPHDescription:SetEdgeColor(0.7, 0.7, 0.6, 1)

		local CPHDescriptionText = WM:CreateControl("$(parent)CPHDescriptionText"..k,CPHotkeyUI,  CT_LABEL, 4)
		CPHDescriptionText:SetHorizontalAlignment(1)
		CPHDescriptionText:SetVerticalAlignment(1)
		CPHDescriptionText:SetAnchor(TOPLEFT,CPHDescription,TOPLEFT,0,0)
		CPHDescriptionText:SetDimensions(100,75)
		CPHDescriptionText:SetFont("ZoFontGameSmall")
		CPHDescriptionText:SetText("Setup "..k.."\n"..getBindingName('SETUP_'..k))


	end
	updateDropdown()
	
	local CPHCounter = WM:CreateControl("$(parent)CPHCounter",CPHotkeyCounter,  CT_LABEL, 4)
	CPHCounter:SetHorizontalAlignment(1)
	CPHCounter:SetVerticalAlignment(1)
	CPHCounter:SetAnchor(TOPLEFT,CPHotkeyCounter,TOPLEFT,0,0)
	CPHCounter:SetDimensions(64,64)
	CPHCounter:SetFont("ZoFontWindowTitle")
	CPHCounter:SetText("30")





	CPHotkeyUI:ClearAnchors()
	CPHotkeyUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,(Rwidth/2)-161,Rheight/5.24)
	CPHotkeyCounter:ClearAnchors()
	CPHotkeyCounter:SetAnchor(BOTTOMLEFT, GuiRoot, BOTTOMLEFT,(Rwidth/4)-161,0)
	CPHotkeyToggle:ClearAnchors()
	CPHotkeyToggle:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT,0,0)
end





CHAMPION_PERKS_CONSTELLATIONS_FRAGMENT:RegisterCallback("StateChange", function(_, newState)
	if newState == SCENE_SHOWN then
		CPHotkeyUI:SetHidden(false)
		CPHotkeyToggle:SetHidden(false)
	else
		CPHotkeyUI:SetHidden(true)
		CPHotkeyToggle:SetHidden(true)
	end
end)

	

function OnAddOnLoaded(event, addonName)
    if addonName ~= CPH.name then return end
    EVENT_MANAGER:UnregisterForEvent(CPH.name, EVENT_ADD_ON_LOADED)

	















	local default = {
		championSlotIds = {
			[1] = {},
			[2] = {},
			[3] = {},
			[4] = {}
		},

		allowRespec = false,

		profiles = {
			["Default"] = {
				[1] = {},
				[2] = {},
				[3] = {},
				[4] = {},
				[5] = {},
				[6] = {},
			},
		},
		selectedProfile = "Default",
		



	}

	CPHsavedVars = ZO_SavedVars:NewAccountWide("CPHotkeySV",3, nil, default)
	
	if CPHsavedVars.championSlotIds[1][1] then --transfer from 0.2
		for i=1,4 do
			for j=1,12 do
				CPHsavedVars.profiles["Default"][i][j] = CPHsavedVars.championSlotIds[i][j]
			end
		end
		championSlotIds = nil
	end


	InitializeUI()

	ZO_PreHook(CHAMPION_PERKS, "OnUpdate", function() --from Jack of All Trades
		CHAMPION_PERKS.firstStarConfirm = false
		return false
	end)

	EVENT_MANAGER:RegisterForUpdate("CPHUpdate", 1000,CPHUpdateFunction)
	CPH_LoadSettings()
end


EVENT_MANAGER:RegisterForEvent(CPH.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

