--[[ 
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
You can read the full terms at [url]https://account.elderscrollsonline.com/add-on-terms[/url]
 
 The grids in this application are borrowed from the ScrollListExample from Librairan, and this addon was built with some great help from our ESOUI community.
  ]]
local LAM = LibAddonMenu2
 
CraftingWritAssistant = {}
CraftingWritAssistant.name = "CraftingWritAssistant"
 
CraftingWritAssistant.Default = {
    OffsetX = 0,
    OffsetY = 0,   
    ShowCraftingWritWindowAtStation = true,
    SaveWindowLocation = true,
    ShowCraftingWritWindowAtGuildBank = false,
    ShowCraftingWritWindowAtBank = false,
    ShowIngredientsAtProvisioning = true
}
 
CraftingWritAssistant.CurrentCraftingWritSteps = {}
CraftingWritAssistant.AutoSelectionInProgress = false
CraftingWritAssistant.JournalQuestInformation = {}
CraftingWritAssistant.ManualSelectedWritName = ""
CraftingWritAssistant.ManualSelectedWritType = 0

-- using this to not rebind the window and show if they have closed it 
-- during the session crafting station session
CraftingWritAssistant.ClosedWindowInSession = false
CraftingWritAssistant.HasDisplayedActiveWritMessage = false
CraftingWritAssistant.LastCraftingStationWritName = ""
CraftingWritAssistant.LastCraftingStationWritType = 0

CraftingWritAssistant.INCOMPLETE_TEXT = "#ffffff"
CraftingWritAssistant.COMPLETE_TEXT ="#00ee00"
CraftingWritAssistant.GOLD_TEXT = "#ffd700"
CraftingWritAssistant.NORMAL_TEXT = "#787878"
CraftingWritAssistant.IN_PROGRESS_TEXT = "#CFDCBD"
CraftingWritAssistant.NORMAL_ICON_COLOR = "#3a92ff"
            
        
CraftingWritAssistant.CRAFTING_ICON = {
                                        [CRAFTING_TYPE_WOODWORKING] = "/esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds"
                                    ,   [CRAFTING_TYPE_CLOTHIER] =   "/esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds"  
                                    ,   [CRAFTING_TYPE_BLACKSMITHING] = "/esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds"  
                                    ,   [CRAFTING_TYPE_ENCHANTING] = "/esoui/art/inventory/inventory_tabicon_craftbag_enchanting_up.dds"    
                                    ,   [CRAFTING_TYPE_PROVISIONING] = "/esoui/art/inventory/inventory_tabicon_craftbag_provisioning_up.dds"    
                                    ,   [CRAFTING_TYPE_ALCHEMY] = "/esoui/art/inventory/inventory_tabicon_craftbag_alchemy_up.dds"  
									,	[CRAFTING_TYPE_JEWELRYCRAFTING] = "/esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_up.dds"   
}
 
CraftingWritAssistant.CRAFTING_WRIT_TYPE_NAME = {
                                   [CRAFTING_TYPE_WOODWORKING] = GetString(SI_CWA_WOODWORKING_WRIT_NAME)
                               ,   [CRAFTING_TYPE_CLOTHIER] =  GetString(SI_CWA_CLOTHIER_WRIT_NAME)
                              ,   [CRAFTING_TYPE_BLACKSMITHING] = GetString(SI_CWA_BLACK_SMITH_WRIT_NAME)
                                ,   [CRAFTING_TYPE_ENCHANTING] = GetString(SI_CWA_ENCHANTER_WRIT_NAME)
                                ,   [CRAFTING_TYPE_PROVISIONING] = GetString(SI_CWA_PROVISIONER_WRIT_NAME)
                                ,   [CRAFTING_TYPE_ALCHEMY] = GetString(SI_CWA_ALCHEMIST_WRIT_NAME)
								,	[CRAFTING_TYPE_JEWELRYCRAFTING] = GetString(SI_CWA_JEWERLY_WRIT_NAME)
}
 
CraftingWritAssistant.CRAFTING_WRIT_TEXT_INDICATORS = {                             
                                    [CRAFTING_TYPE_BLACKSMITHING] = {GetString(SI_CWA_BLACK_SMITH)}                             
                                ,   [CRAFTING_TYPE_WOODWORKING] = {GetString(SI_CWA_WOODWORKING)}
                                ,   [CRAFTING_TYPE_CLOTHIER] = {GetString(SI_CWA_CLOTHIER)}
                                ,   [CRAFTING_TYPE_ENCHANTING] = {GetString(SI_CWA_ENCHANTER)}
                                ,   [CRAFTING_TYPE_ALCHEMY] = {GetString(SI_CWA_ALCHEMIST)}
                                ,   [CRAFTING_TYPE_PROVISIONING] = {GetString(SI_CWA_PROVISIONER)}
								,	[CRAFTING_TYPE_JEWELRYCRAFTING] = {GetString(SI_CWA_JEWELRY)}
}
 
--using MASTER_WRIT_WEAPON_TYPE_INDICATORS to find the weapon type.
CraftingWritAssistant.MASTER_WRIT_TEXT_INDICATORS = {           
                                    [CRAFTING_TYPE_WOODWORKING] = {GetString(SI_CWA_WOODWORKING_SHEILD)}
                                ,   [CRAFTING_TYPE_BLACKSMITHING] = {GetString(SI_CWA_MW_BLACK_SMITH_ARMOR)}    
                                ,   [CRAFTING_TYPE_CLOTHIER] = {GetString(SI_CWA_MW_CLOTHIER_LIGHT), GetString(SI_CWA_MW_CLOTHIER_MED)}
                                ,   [CRAFTING_TYPE_ENCHANTING] = {GetString(SI_CWA_MW_ENCHANTER)}
                                ,   [CRAFTING_TYPE_ALCHEMY] = {GetString(SI_CWA_MW_ALCHEMIST)}
								,   [CRAFTING_TYPE_JEWELRYCRAFTING] = {GetString(SI_CWA_MW_JEWELRY)}
                                ,   [CRAFTING_TYPE_PROVISIONING] = {GetString(SI_CWA_MW_PROVISIONER_FEAST)}
}
 
CraftingWritAssistant.MASTER_WRIT_WEAPON_TYPE_INDICATORS = {                                
                                    [CRAFTING_TYPE_BLACKSMITHING] = {GetString(SI_CWA_DAGGER),GetString(SI_CWA_SWORD),
                                                                     GetString(SI_CWA_GREATSWORD),GetString(SI_CWA_MACE),
                                                                     GetString(SI_CWA_AXE),GetString(SI_CWA_MAUL)
                                                                     }                              
                                ,   [CRAFTING_TYPE_WOODWORKING] = {GetString(SI_CWA_STAFF),GetString(SI_CWA_BOW)} -- ,GetString(SI_CWA_SHEILD)
}
 
CraftingWritAssistant.MASTER_WRIT_PHRASES = {                               
                                    GetString(SI_CWA_MASTERFUL)
}
--Journal details seem to contain extra steps with ""Meet Your Contact" in the API
CraftingWritAssistant.MASTER_WRIT_SKIP_STEPS_TEXT = {                               
                                    GetString(SI_CWA_MW_COMPLETE_AD),GetString(SI_CWA_MW_COMPLETE_DC),GetString(SI_CWA_MW_COMPLETE_EP)
}


function HasActiveWritsForCraftingStationType(craftingType)
	local hasCraftType = false

	for questName,questDetails in pairs(CraftingWritAssistant.JournalQuestInformation) do                   
		if questDetails.craftingType == craftingType then
			hasCraftType = true
		end                 
	end
	
	return hasCraftType
end
 
function GetTableLength(inputTable)
  local count = 0
  for _ in pairs(inputTable) do count = count + 1 end
  return count
end
 
function trim2(s)
  return s:match "^%s*(.-)%s*$"
end
 
local function SetToolTip(ctrl, text, placement)
    ctrl:SetHandler("OnMouseEnter", function(self)
        ZO_Tooltips_ShowTextTooltip(self, placement, text)
    end)
    ctrl:SetHandler("OnMouseExit", function(self)
        ZO_Tooltips_HideTextTooltip()
    end)
end
 
function trimstring(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end
 
function hex2rgb(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2),16)/255, tonumber("0x"..hex:sub(3,4),16)/255, tonumber("0x"..hex:sub(5,6),16)/255
end
  
function OnCraftingWritAssistSelect(_, selectedWrit, choice)
    CraftingWritAssistant.ClearAdditionalDetails()
    
    if CraftingWritAssistant.AutoSelectionInProgress ~= true then
        local questSelected = CraftingWritAssistant.JournalQuestInformation[selectedWrit]
        --d("OnCraftingWritAssistSelect "..selectedWrit)
		CraftingWritAssistant.ManualSelectedWritName = selectedWrit
		CraftingWritAssistant.ManualSelectedWritType = questSelected.craftingType
        local hasCraftQuests = CraftingWritAssistant.BindWindow(questSelected.craftingType, selectedWrit)
        if hasCraftQuests then      
            CraftingWritAssistant.ShowWindow()  
        end
    end             
end 
function SetSelectedItemWritDropdown(selectedText)
    CraftingWritAssistant.CraftingWritAssistantCharSelect.dropdown:SetSelectedItem(selectedText)    
end
function ClearWritNameDropdown()
    CraftingWritAssistant.CraftingWritAssistantCharSelect.dropdown:ClearItems()        
end
 
--This will refresh the step details
function LoadJournalWritDetails()
    for questName,questDetails in pairs(CraftingWritAssistant.JournalQuestInformation) do
           
            local journalDetails, journalStepsComplete = CraftingWritAssistant.GetJournalDetails(questDetails.journalIndex)
            questDetails.questSteps = journalDetails
            questDetails.questStepsComplete = journalStepsComplete
            
    end
end
 
--Loads Full Journal -- Should only be called when addon is first loaded or player activated
function LoadJournalWritsAndDetails()
 
CraftingWritAssistant.JournalQuestInformation = {}
        
    for i=1, GetNumJournalQuests() do
    
		local questName,_,_,_,_,_,_,_,_,questType = GetJournalQuestInfo(i)
		--local questName = GetJournalQuestName(i)
		--local questType = GetJournalQuestType(i)
      
       -- d("questname:"..questName.." type: "..questType)          
        if questType == QUEST_TYPE_CRAFTING then    
            --d("QUEST_TYPE_CRAFTING")
            
            local questNameValue = questName
            --d(questNameValue)
            local isMasterWritType = false
               
                local journalDetails, journalStepsComplete = CraftingWritAssistant.GetJournalDetails(i)
                local questCraftingType = CraftingWritAssistant.GetCraftingWritTypeFromQuestName(questNameValue)
                --d(questCraftingType)
                if CraftingWritAssistant.GetIsMasterActiveCraftingWritQuest(questNameValue) then
                    local masterWeaponType,matchedType = CraftingWritAssistant.GetMasterWritWeaponType(journalDetails[1])
                    --d(journalDetails[1])
                    --d(matchedType)
                    if(masterWeaponType ~= CRAFTING_TYPE_INVALID) then
                        questNameValue = questNameValue.." - "..matchedType 
                        questCraftingType = masterWeaponType                        
                    end 
                    
                    isMasterWritType = true                 
                end
                
            if(CraftingWritAssistant.JournalQuestInformation[questNameValue] == nil and questNameValue ~= "") then
               
                local questDetails = { journalIndex = i, isMasterWrit = isMasterWritType, 
                craftingType = questCraftingType, questSteps = journalDetails, questName = questNameValue,
                questStepsComplete = journalStepsComplete}
                                            
                CraftingWritAssistant.JournalQuestInformation[questNameValue] = questDetails                        
                --CraftingWritAssistant.DebugWriteLine(questDetails)
            end
        end
    end 
end
 
function BindActiveCraftingWritDropDown(craftingType)
 
    ClearWritNameDropdown()
            
	--d(craftingType)
    --CraftingWritAssistant.DebugWriteLine(craftingType)
    if(CraftingWritAssistant.JournalQuestInformation ~= nil) then
             
			 
        if craftingType == nil then 
            --d("BindActiveCraftingWritDropDown craftingType == nil")
            -- use the keys to retrieve the values in the sorted order
            for questName,questDetails in pairs(CraftingWritAssistant.JournalQuestInformation) do   
                    local dropDownItem = CraftingWritAssistant.CraftingWritAssistantCharSelect.dropdown:CreateItemEntry(questName, OnCraftingWritAssistSelect)
                    CraftingWritAssistant.CraftingWritAssistantCharSelect.dropdown:AddItem(dropDownItem)    
            end
        else
            --d("BindActiveCraftingWritDropDown "..craftingType)
            for questName,questDetails in pairs(CraftingWritAssistant.JournalQuestInformation) do                   
                if questDetails.craftingType == craftingType then
                    --d(questName)
                    --d(questDetails.craftingType)
                    local dropDownItem = CraftingWritAssistant.CraftingWritAssistantCharSelect.dropdown:CreateItemEntry(questName, OnCraftingWritAssistSelect)
                    CraftingWritAssistant.CraftingWritAssistantCharSelect.dropdown:AddItem(dropDownItem)    
                end                 
            end
        end             
        
    end
end
 
function CraftingWritAssistant.ClearStepItems()
        for i = 1, 6 do         
            local label = GetControl("CraftingWritAssistantStepItem"..tostring(i), "Description")                           
            label:SetText("")           
        end
end
 
--build primary window
function CraftingWritAssistant.CreatePrimaryWindow()    
        
    CraftingWritAssistantWindowWoodworking:SetMouseEnabled(true)
    CraftingWritAssistantWindowClothing:SetMouseEnabled(true)
    CraftingWritAssistantWindowBlacksmithing:SetMouseEnabled(true)
    CraftingWritAssistantWindowProvisioning:SetMouseEnabled(true)
    CraftingWritAssistantWindowAlchemy:SetMouseEnabled(true)
    CraftingWritAssistantWindowEnchanting:SetMouseEnabled(true)
	CraftingWritAssistantWindowJewelryCrafting:SetMouseEnabled(true)
        
    CraftingWritAssistantWindowTitle:SetText(GetString(SI_CWA_TITLE))
    
    CraftingWritAssistantWindowCloseButton:SetHandler("OnClicked", function()       
          CraftingWritAssistant.ClosedWindowInSession = true
          CraftingWritAssistantWindow:SetHidden(true)       
    end)    
                
    local ySpacingSteps = 25
    
    --create controls
    for i = 1, 6 do
          local stepInfoControl = CreateControlFromVirtual("CraftingWritAssistantStepItem", CraftingWritStepList, "CraftingWritAssistantStepItem", i)
          
          stepInfoControl:ClearAnchors()
          stepInfoControl:SetAnchor(TOPLEFT, CraftingWritStepList, TOPLEFT, 0, ySpacingSteps)  
          
          local addInfoControl = CreateControlFromVirtual("CraftingWritAssistantAddInfoItem", CraftingWritStepList, "CraftingWritAssistantAddInfoItem", i)
          
          addInfoControl:ClearAnchors()
          addInfoControl:SetAnchor(TOPLEFT, CraftingWritStepList, TOPLEFT, 370, ySpacingSteps)  
          
          ySpacingSteps = ySpacingSteps + 20
    end
    
    CraftingWritAssistant.CraftingWritAssistantCharSelect = WINDOW_MANAGER:CreateControlFromVirtual("CraftingWritAssistantCharSelect", CraftingWritAssistantWindow, "ZO_StatsDropdownRow")
    CraftingWritAssistant.CraftingWritAssistantCharSelect:SetAnchor(TOPRIGHT, CraftingWritAssistantWindow, TOPRIGHT, -40, 14)
    
    local craftingWritAssitDropdown = CraftingWritAssistant.CraftingWritAssistantCharSelect:GetNamedChild("Dropdown")
    craftingWritAssitDropdown:SetWidth(250) 
    
    LoadJournalWritsAndDetails()
    BindActiveCraftingWritDropDown()
    CraftingWritAssistant.BindWindow()
    
    CraftingWritAssistantWindow:ClearAnchors()
    
    -- Some might like to set the default position to 0,0 so let them if the "remember position" option is on. ;) -Phinix
    
    if CraftingWritAssistant.savedVariables.SaveWindowLocation == true then
        CraftingWritAssistantWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CraftingWritAssistant.savedVariables.OffsetX, CraftingWritAssistant.savedVariables.OffsetY)        
    else
        CraftingWritAssistantWindow:SetAnchor(TOP, GuiRoot, TOP, 0, 50)         
    end 
    
end
 
function CraftingWritAssistant.SaveWindowLocation()
    if CraftingWritAssistant.savedVariables.SaveWindowLocation == true then
        CraftingWritAssistant.savedVariables.OffsetX = CraftingWritAssistantWindow:GetLeft()
        CraftingWritAssistant.savedVariables.OffsetY = CraftingWritAssistantWindow:GetTop() 
    end
end
 
function CraftingWritAssistant.CreateOptionsWindow()
 
   local panel = {
        type = "panel",
        name = "Crafting Writ Assistant",
        author = "@dovah-argus",
        version = ".34b",
        slashCommand = "/cwasettings",
        registerForRefresh = true,
        website = "http://www.esoui.com/downloads/info1121-CraftingWritAssistant.html"
    }
    
    local optionsData = {
        [1] = {
        type = "checkbox",
        name = GetString(SI_CWA_DISPLAY_AT_STATION_NAME),
        tooltip = GetString(SI_CWA_DISPLAY_AT_STATION_DESC),
        getFunc = function() return CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtStation end,
        setFunc = function(value) CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtStation = value end
        },
        [2] = {
        type = "checkbox",
        name = GetString(SI_CWA_SAVE_WINDOW_LOC_NAME),
        tooltip = GetString(SI_CWA_SAVE_WINDOW_LOC_DESC),
        getFunc = function() return CraftingWritAssistant.savedVariables.SaveWindowLocation end,
        setFunc = function(value) CraftingWritAssistant.savedVariables.SaveWindowLocation = value end
        },
        [3] = {
        type = "checkbox",
        name = GetString(SI_CWA_DISPLAY_AT_GB_NAME),
        tooltip = GetString(SI_CWA_DISPLAY_AT_GB_DESC),
        getFunc = function() return CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtGuildBank end,
        setFunc = function(value) CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtGuildBank = value end
        },
        [4] = {
        type = "checkbox",
        name = GetString(SI_CWA_DISPLAY_AT_BANK_NAME),
        tooltip = GetString(SI_CWA_DISPLAY_AT_BANK_DESC),
        getFunc = function() return CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtBank end,
        setFunc = function(value) CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtBank = value end
        },
        [5] = {
        type = "checkbox",
        name = GetString(SI_CWA_DISPLAY_AT_GSTORE_NAME),
        tooltip = GetString(SI_CWA_DISPLAY_AT_GSTORE_DESC),
        getFunc = function() return CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtGuildStore end,
        setFunc = function(value) CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtGuildStore = value end
        },
        [6] = {
        type = "checkbox",
        name = GetString(SI_CWA_LEAVE_WINDOW_OPEN_ON_EXIT_NAME),
        tooltip = GetString(SI_CWA_LEAVE_WINDOW_OPEN_ON_EXIT),
        getFunc = function() return CraftingWritAssistant.savedVariables.LeaveCraftingWritWindowOpenOnExit end,
        setFunc = function(value) CraftingWritAssistant.savedVariables.LeaveCraftingWritWindowOpenOnExit = value end
        }
        }
                
    LAM:RegisterAddonPanel("CraftingWritAssistantPanel", panel)
    LAM:RegisterOptionControls("CraftingWritAssistantPanel", optionsData)
 
end
 
function CraftingWritAssistant.GetCraftingWritTypeFromQuestName(questName)
--d("GetCraftingWritTypeFromQuestName "..questName)
 
if CraftingWritAssistant.GetIsMasterActiveCraftingWritQuest(questName) then  
    --d("master writ")
    --d(questName)
 
    --Weapon(blacksmith and woodworking) Parsing Requires more logic to find
    if PlainStringFind(questName, GetString(SI_CWA_WEAPON)) then
        local journalIndex = CraftingWritAssistant.JournalQuestInformation[questName]
    
        local craftQuestSteps = CraftingWritAssistant.GetJournalDetails(journalIndex)
        
        --pass the first step of the quest.
        local questStep = craftQuestSteps[1]    
        
        return CraftingWritAssistant.GetMasterWritWeaponType(questStep)     
    else
        return CraftingWritAssistant.GetMasterCraftingWritType(questName)   
    end 
else    
    local writType = CraftingWritAssistant.GetCraftingWritType(questName)   
   	
    return  writType
end
 
return CRAFTING_TYPE_INVALID
end
 
function CraftingWritAssistant.GetMasterCraftingWritType(questName)
--FUTURE?:
--local crafting_type_list = LibCraftText.MasterQuestNameToCraftingTypeList(quest_name)

   -- d(questName)
for craftingTypeKey, craftingTypeDescriptions in pairs(CraftingWritAssistant.MASTER_WRIT_TEXT_INDICATORS) do
    for i = 1, #craftingTypeDescriptions do 
        --CraftingWritAssistant.DebugWriteLine(craftingTypeDescriptions[i])
        if PlainStringFind(questName, craftingTypeDescriptions[i]) then return craftingTypeKey end  
    end
end
 
return CRAFTING_TYPE_INVALID

 
end
 
function CraftingWritAssistant.GetCraftingWritType(questName)
    
for craftingTypeKey, craftingTypeDescriptions in pairs(CraftingWritAssistant.CRAFTING_WRIT_TEXT_INDICATORS) do
    for i = 1, #craftingTypeDescriptions do 
        --CraftingWritAssistant.DebugWriteLine(craftingTypeDescriptions[i])
        if PlainStringFind(questName, craftingTypeDescriptions[i]) then return craftingTypeKey end  
    end
end
 
 return CRAFTING_TYPE_INVALID
 
--  local writType = LibCraftText.DailyQuestNameToCraftingType(questName)
--  return writType
end

-- Master Quests always saw "weapon" in the title, so we need to determine what it is based on the first craft step
function CraftingWritAssistant.GetMasterWritWeaponType(questStepText)
 
for craftingTypeKey, craftingTypeDescriptions in pairs(CraftingWritAssistant.MASTER_WRIT_WEAPON_TYPE_INDICATORS) do
    for i = 1, #craftingTypeDescriptions do 
        --CraftingWritAssistant.DebugWriteLine(craftingTypeKey)
        --CraftingWritAssistant.DebugWriteLine(craftingTypeDescriptions[i])
        if PlainStringFind(questStepText, craftingTypeDescriptions[i]) then return craftingTypeKey, craftingTypeDescriptions[i] end 
    end
end
 
 return CRAFTING_TYPE_INVALID, ""   
 
end

function BindEnchantingDetails(craftingType, journalStepText)
      
	--d(craftingType)
	-- d(journalStepText) 
	CraftingWritAssistant.ClearAdditionalDetails()
	
	for y = 1, 2 do			
		local currentAdditionalInfo = GetControl("CraftingWritAssistantAddInfoItem"..tostring(y), "Description")
		currentAdditionalInfo:SetText("")
	end
		    
    local conditionDetails = LibCraftText.ParseDailyCondition(craftingType, journalStepText)
	
	--d(pairs(conditionDetails))
	local listofDetails = ""
	local listOfRunes = {}
	for _, conDetails in pairs(conditionDetails) do
	    --d(conDetails.name)
		table.insert(listOfRunes, conDetails.name)		
	end	
	
	local sort_func = function( a,b ) return a < b end
	
	table.sort( listOfRunes, sort_func )

	for i, ingred in ipairs( listOfRunes ) do
		listofDetails = listofDetails .. ingred .. ","	
	end
	
	-- remove last ","
	listofDetails = string.sub(listofDetails, 1, -2)
	
	for y=1,1 do	
		local currentStepInfo = GetControl("CraftingWritAssistantStepItem"..tostring(y), "Description")
				
		local currentAdditionalInfo = GetControl("CraftingWritAssistantAddInfoItem"..tostring(y), "Description")
			currentAdditionalInfo:ClearAnchors()
			currentAdditionalInfo:SetAnchor(TOPLEFT, currentStepInfo, TOPRIGHT, 0, 0)	
			currentAdditionalInfo:SetText(listofDetails)
			currentAdditionalInfo:SetColor(0.2, 1, 0.2, 1)   -- Green															
	end   
 
end --end function
 
function BindProvisioningDetails(journalIndex)
                 
	for y = 1, 2 do			
		local currentAdditionalInfo = GetControl("CraftingWritAssistantAddInfoItem"..tostring(y), "Description")
		currentAdditionalInfo:SetText(GetString(SI_CWA_UNKNOWN_RECIPE))
		currentAdditionalInfo:SetColor(1, 0.2, 0.2, 1)   -- Red 
	end
		  		  
    for i = 1, GetNumRecipeLists() do
        
        local listName, numRecipes = GetRecipeListInfo(i)
        
        for x = 1, numRecipes do
        
        local known, recipeName, numIngredients = GetRecipeInfo(i,x)
        
        if known == true then   
            
            for questName, questDetails in pairs(CraftingWritAssistant.JournalQuestInformation) do
                
                if journalIndex == questDetails.journalIndex then                                       
                        for y=1,#questDetails.questSteps do
                        
                            --this contains the recipe name in the quest --  step one
                            local recipeNameStep = questDetails.questSteps[y]
                            --d(recipeNameStep)
							local ingredList = {}
							local nameClean = zo_strformat("<<C:1>>", recipeName)
                            if PlainStringFind(recipeNameStep, nameClean) then 
                                            
                                    local listOfIngred = ""
                                    for z = 1, numIngredients do
                                        local ingredName = GetRecipeIngredientItemInfo(i,x,z)
                                        table.insert(ingredList, ingredName)                                       
                                    end          
								
								local sort_func = function( a,b ) return a < b end
								table.sort( ingredList, sort_func )

								for i, ingred in ipairs( ingredList ) do
									 listOfIngred = listOfIngred .. ingred .. ","
								end
									
                                --trim last ","
                                listOfIngred = string.sub(listOfIngred, 1, -2)
                                
								local currentStepInfo = GetControl("CraftingWritAssistantStepItem"..tostring(y), "Description")
										
                                local currentAdditionalInfo = GetControl("CraftingWritAssistantAddInfoItem"..tostring(y), "Description")
                                currentAdditionalInfo:ClearAnchors()
								currentAdditionalInfo:SetAnchor(TOPLEFT, currentStepInfo, TOPRIGHT, 0, 0)	
                                currentAdditionalInfo:SetText(listOfIngred)
                                currentAdditionalInfo:SetColor(0.2, 1, 0.2, 1)   -- Green
                                   
                            end                     
                        end             
                end 
            end     
        end
                
        end 
        
    end
 
end --end function
 
function CraftingWritAssistant.GetJournalDetails(journalIndex)
 
local craftingQuestSteps = {}
--[[Modification by DonRomano
    New line: local craftingStepState = {}
]]
local craftingStepState = {}
local questName = GetJournalQuestName(journalIndex)
--d(questName)
--d(journalIndex)
 
for x=1,GetJournalQuestNumSteps(journalIndex) do    
    --local stepText, visibility, stepType, trackerOverrideText, numConditions = GetJournalQuestStepInfo(i,x)                                           
       for y=1,GetJournalQuestNumConditions(journalIndex,x) do                                     
       -- string conditionText, integer current, integer max, boolean isFailCondition, boolean isComplete, boolean isCreditShared
            
           local conditionText, curCount, maxCount = GetJournalQuestConditionInfo(journalIndex,x,y)
                            
              --Skip blank conditions for normal crafting quests and
              if conditionText ~= "" then
                                                
                 if CraftingWritAssistant.GetIsMasterActiveCraftingWritQuest(questName) then 
                        --Master Writs quest step content seem to be returned as a "blob" instead of individual steps, so lets create steps based on Newline
                        local masterWritSteps = { SplitString('\n', conditionText) }
                        --d(masterWritSteps)
                        for stepItem=1,#masterWritSteps do
                            local masterWritCondition = masterWritSteps[stepItem]
                            local isValidWritStep = true
                            --Skipping Conditions that have "Meet Your Contact" -- Seems to be an error by the API
                            for index=1,#CraftingWritAssistant.MASTER_WRIT_SKIP_STEPS_TEXT do
                                if PlainStringFind(masterWritCondition, CraftingWritAssistant.MASTER_WRIT_SKIP_STEPS_TEXT[index]) then 
                                --d(masterWritCondition)
                                --d(CraftingWritAssistant.MASTER_WRIT_SKIP_STEPS_TEXT[index])                   
                                isValidWritStep = false
                                end
                            end
                            if isValidWritStep then
                                table.insert(craftingQuestSteps, masterWritCondition)
                                
                                table.insert(craftingStepState, false) 
                            end
                            
                        end     
                 else 
                        table.insert(craftingQuestSteps,conditionText)                      
                        
                        table.insert(craftingStepState, curCount==maxCount) 
                 end
              end
       end
end

return craftingQuestSteps, craftingStepState
 
end
 
function CraftingWritAssistant.DebugWriteLine(outputText)
    d(outputText)
end
 
function CraftingWritAssistant.GetIsMasterActiveCraftingWritQuest(questName)    
    for index=1,#CraftingWritAssistant.MASTER_WRIT_PHRASES do
        if PlainStringFind(questName, CraftingWritAssistant.MASTER_WRIT_PHRASES[index]) then return true end
    end
    return false
end
 
 
-- do all this when the addon is loaded
function CraftingWritAssistant.OnAddOnLoaded(eventCode, addOnName)
 
    if addOnName ~= CraftingWritAssistant.name then return end
 
 
        CraftingWritAssistant.savedVariables = ZO_SavedVars:NewAccountWide("CraftingWritAssistantVars", 1, nil, CraftingWritAssistant.Default)
        
		if CraftingWritAssistant.savedVariables.LeaveCraftingWritWindowOpenOnExit == nil then
             CraftingWritAssistant.savedVariables.LeaveCraftingWritWindowOpenOnExit = false
        end
		
        if CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtGuildBank == nil then
             CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtGuildBank = false
        end
        
        if CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtBank == nil then
             CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtBank = false
        end
                      
        if CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtGuildStore == nil then
             CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtGuildStore = false
        end
                                
        -- Register Keybinding
        ZO_CreateStringId("SI_BINDING_NAME_SHOWWINDOW_CraftingWritAssistant", GetString(SI_CWA_KEY_BINDING))
 
        CraftingWritAssistant.CreatePrimaryWindow()
        CraftingWritAssistant.CreateOptionsWindow()     
end
 
function CraftingWritAssistant.SetToolTip(ctrl, text, placement)
    ctrl:SetHandler("OnMouseEnter", function(self)
        ZO_Tooltips_ShowTextTooltip(self, placement, text)
    end)
    ctrl:SetHandler("OnMouseExit", function(self)
        ZO_Tooltips_HideTextTooltip()
    end)
end
 
function CraftingWritAssistant.ResetWritIcons()
 
CraftingWritAssistantWindowWoodworking:SetColor(hex2rgb(CraftingWritAssistant.NORMAL_TEXT))
CraftingWritAssistantWindowClothing:SetColor(hex2rgb(CraftingWritAssistant.NORMAL_TEXT))
CraftingWritAssistantWindowBlacksmithing:SetColor(hex2rgb(CraftingWritAssistant.NORMAL_TEXT))
CraftingWritAssistantWindowProvisioning:SetColor(hex2rgb(CraftingWritAssistant.NORMAL_TEXT))
CraftingWritAssistantWindowAlchemy:SetColor(hex2rgb(CraftingWritAssistant.NORMAL_TEXT))
CraftingWritAssistantWindowEnchanting:SetColor(hex2rgb(CraftingWritAssistant.NORMAL_TEXT))
CraftingWritAssistantWindowJewelryCrafting:SetColor(hex2rgb(CraftingWritAssistant.NORMAL_TEXT))


CraftingWritAssistant.SetToolTip(CraftingWritAssistantWindowWoodworking, GetString(SI_CWA_NO_WRITS), TOP) 
CraftingWritAssistant.SetToolTip(CraftingWritAssistantWindowClothing, GetString(SI_CWA_NO_WRITS), TOP) 
CraftingWritAssistant.SetToolTip(CraftingWritAssistantWindowBlacksmithing, GetString(SI_CWA_NO_WRITS), TOP) 
CraftingWritAssistant.SetToolTip(CraftingWritAssistantWindowProvisioning, GetString(SI_CWA_NO_WRITS), TOP) 
CraftingWritAssistant.SetToolTip(CraftingWritAssistantWindowAlchemy, GetString(SI_CWA_NO_WRITS), TOP) 
CraftingWritAssistant.SetToolTip(CraftingWritAssistantWindowEnchanting, GetString(SI_CWA_NO_WRITS), TOP) 
CraftingWritAssistant.SetToolTip(CraftingWritAssistantWindowJewelryCrafting, GetString(SI_CWA_NO_WRITS), TOP) 
 
end
 
function CraftingWritAssistant.ShowWindow()
    CraftingWritAssistantWindow:SetHidden(false) 
 
end
 
 
function CraftingWritAssistant.BindWindow(craftingType, selectedWrit)   
 
    local journalIndex = 0
    --d(craftingType)
 
    --Reset Icons to Default state
    CraftingWritAssistant.ResetWritIcons()
 
    for questName, details in pairs(CraftingWritAssistant.JournalQuestInformation) do                                             
        
        local questCraftingType = details.craftingType  
        local isReadyforDelivery = false
        local questStepDetail = ""
        
        if PlainStringFind(details.questSteps[1], GetString(SI_CWA_DELIVER)) then
            isReadyforDelivery = true       
        end
            
        for i = 1, #details.questSteps do
            questStepDetail = questStepDetail..details.questSteps[i]
            if i < #details.questSteps then
                questStepDetail = questStepDetail.."\n"
            end     
        end
        
        --d(questCraftingType)
                
        if questCraftingType == CRAFTING_TYPE_WOODWORKING then  
            if isReadyforDelivery then
                CraftingWritAssistantWindowWoodworking:SetColor(hex2rgb(CraftingWritAssistant.COMPLETE_TEXT))           
            else
                CraftingWritAssistantWindowWoodworking:SetColor(hex2rgb(CraftingWritAssistant.INCOMPLETE_TEXT))
                
            end
            CraftingWritAssistant.SetToolTip(CraftingWritAssistantWindowWoodworking, questStepDetail, BOTTOM) 
        elseif questCraftingType == CRAFTING_TYPE_CLOTHIER then 
            if isReadyforDelivery then
                CraftingWritAssistantWindowClothing:SetColor(hex2rgb(CraftingWritAssistant.COMPLETE_TEXT))          
            else
                CraftingWritAssistantWindowClothing:SetColor(hex2rgb(CraftingWritAssistant.INCOMPLETE_TEXT))            
            end
            CraftingWritAssistant.SetToolTip(CraftingWritAssistantWindowClothing, questStepDetail, BOTTOM) 
        elseif questCraftingType == CRAFTING_TYPE_BLACKSMITHING then 
            if isReadyforDelivery then
                CraftingWritAssistantWindowBlacksmithing:SetColor(hex2rgb(CraftingWritAssistant.COMPLETE_TEXT))                 
            else
                CraftingWritAssistantWindowBlacksmithing:SetColor(hex2rgb(CraftingWritAssistant.INCOMPLETE_TEXT))           
            end
            CraftingWritAssistant.SetToolTip(CraftingWritAssistantWindowBlacksmithing, questStepDetail, BOTTOM)     
        elseif questCraftingType == CRAFTING_TYPE_PROVISIONING then 
            if isReadyforDelivery then
                CraftingWritAssistantWindowProvisioning:SetColor(hex2rgb(CraftingWritAssistant.COMPLETE_TEXT))          
            else
                CraftingWritAssistantWindowProvisioning:SetColor(hex2rgb(CraftingWritAssistant.INCOMPLETE_TEXT))            
            end
            CraftingWritAssistant.SetToolTip(CraftingWritAssistantWindowProvisioning, questStepDetail, BOTTOM) 
        elseif questCraftingType == CRAFTING_TYPE_ALCHEMY then  
            if isReadyforDelivery then
                CraftingWritAssistantWindowAlchemy:SetColor(hex2rgb(CraftingWritAssistant.COMPLETE_TEXT))           
            else
                CraftingWritAssistantWindowAlchemy:SetColor(hex2rgb(CraftingWritAssistant.INCOMPLETE_TEXT)) 
            end
            CraftingWritAssistant.SetToolTip(CraftingWritAssistantWindowAlchemy, questStepDetail, BOTTOM) 
        elseif questCraftingType == CRAFTING_TYPE_JEWELRYCRAFTING then           
            if isReadyforDelivery then
                CraftingWritAssistantWindowJewelryCrafting:SetColor(hex2rgb(CraftingWritAssistant.COMPLETE_TEXT))            
            else
                CraftingWritAssistantWindowJewelryCrafting:SetColor(hex2rgb(CraftingWritAssistant.INCOMPLETE_TEXT)) 
            end
            CraftingWritAssistant.SetToolTip(CraftingWritAssistantWindowJewelryCrafting, questStepDetail, BOTTOM)
		elseif questCraftingType == CRAFTING_TYPE_ENCHANTING then           
            if isReadyforDelivery then
                CraftingWritAssistantWindowEnchanting:SetColor(hex2rgb(CraftingWritAssistant.COMPLETE_TEXT))            
            else
                CraftingWritAssistantWindowEnchanting:SetColor(hex2rgb(CraftingWritAssistant.INCOMPLETE_TEXT)) 
            end
            CraftingWritAssistant.SetToolTip(CraftingWritAssistantWindowEnchanting, questStepDetail, BOTTOM)         
        else            
			--d(questCraftingType)
        end
    end
 
    local numberOfWritQuests = GetTableLength(CraftingWritAssistant.JournalQuestInformation)
 
    if numberOfWritQuests == 0 then
                               
            CraftingWritAssistant.ClearStepItems()      
            CraftingWritAssistant.ClearAdditionalDetails()
            
            CraftingWritAssistantWindow:SetHidden(true) 
            CraftingWritAssistant.ToggleSlotUpdateEvent(false) 
            CraftingWritAssistant.HasDisplayedActiveWritMessage = true
 
            return false
    else
        local isMasterQuest = false
        if craftingType == nil or craftingType == "" then
        --d(numberOfWritQuests)
                CraftingWritAssistant.AutoSelectionInProgress = true
                CraftingWritAssistant.CraftingWritAssistantCharSelect.dropdown:SelectItemByIndex(1)
                selectedWrit = CraftingWritAssistant.CraftingWritAssistantCharSelect.dropdown:GetSelectedItem()
                        
                local questDetails = CraftingWritAssistant.JournalQuestInformation[selectedWrit]
                craftingType = questDetails.craftingType
                journalIndex = questDetails.journalIndex
                
                CraftingWritAssistant.AutoSelectionInProgress = false   
                isMasterQuest = CraftingWritAssistant.GetIsMasterActiveCraftingWritQuest(selectedWrit)
        end
 
        local isCraftingWritTypeValid = CraftingWritAssistant.IsCraftingWritTypeValid(craftingType)
        local hasCraftingTypeActiveWrit = false
        local isFoundWritNameSearch = false
 
        if isCraftingWritTypeValid then
        --clear crafting writ steps to ensure rebind
            CraftingWritAssistant.CurrentCraftingWritSteps[craftingType]= {}
 
            --clear previous recipes
            if craftingType == CRAFTING_TYPE_PROVISIONING then  
                    CraftingWritAssistant.ClearStepItems()
            end
                
            if(selectedWrit ~= nil) then            
                --d("search by name")
                --check for quest name match first
                for questName, details in pairs(CraftingWritAssistant.JournalQuestInformation) do                                             
                    if(selectedWrit == questName) then
                           
                            local craftingWritDetails = { name = questName, steps = details.questSteps, stepComplete = details.questStepsComplete}                              
                            --d(craftQuestSteps)                                
                            CraftingWritAssistant.CurrentCraftingWritSteps[craftingType] = craftingWritDetails  
                            
                            journalIndex = details.journalIndex
                            isMasterQuest = CraftingWritAssistant.GetIsMasterActiveCraftingWritQuest(questName)
                            isFoundWritNameSearch = true
                            break                       
                    end 
                end
            end
        
            --if not quest matched by name search by craft type
            if isFoundWritNameSearch == false then
                --d("search by craft type")
                for questName, details in pairs(CraftingWritAssistant.JournalQuestInformation) do
                --d(details.craftingType)
					--todo: CHECK CraftingWritAssistant.ManualSelectedWritName			
				
                    if craftingType == details.craftingType then   
						local questToSelect = questName
						local detailsToSelect = details
						
						if CraftingWritAssistant.ManualSelectedWritName ~= "" and CraftingWritAssistant.ManualSelectedWritType == craftingType then
							--auto select last manual selected quest
							questToSelect = CraftingWritAssistant.ManualSelectedWritName
							--search for manual selected quest details
							for innerQuestName, innerQuestDetails in pairs(CraftingWritAssistant.JournalQuestInformation) do
								if CraftingWritAssistant.ManualSelectedWritName == innerQuestName then
									detailsToSelect = innerQuestDetails
									break
								end
							end 
						end
						--d("questToSelect "..questToSelect)
							
                        local craftingWritDetails = { name = questToSelect, steps = detailsToSelect.questSteps, stepComplete = detailsToSelect.questStepsComplete}                              
                        CraftingWritAssistant.CurrentCraftingWritSteps[craftingType] = craftingWritDetails  
                        --d("match on type")    
                        journalIndex = detailsToSelect.journalIndex
                        
                        SetSelectedItemWritDropdown(questToSelect)
                        isMasterQuest = CraftingWritAssistant.GetIsMasterActiveCraftingWritQuest(questToSelect)
                        hasCraftingTypeActiveWrit = true
                        break
                    end 
                end     
            end 
    
    
            if hasCraftingTypeActiveWrit or isFoundWritNameSearch then
			
				--SetSelectedItemWritDropdown(selectedWrit)
			
                --d("CraftingWritAssistant.CurrentCraftingWritSteps[craftingType] ~= nil")      
                local writName = CraftingWritAssistant.CurrentCraftingWritSteps[craftingType].name
                ActiveWritLabel:SetText(writName)       
                
                local writIcon = CraftingWritAssistant.CRAFTING_ICON[craftingType]
                CraftingWritAssistantActiveWritIcon:SetTexture(writIcon)        
                    
                if isMasterQuest then
                    ActiveWritLabel:SetColor(hex2rgb(CraftingWritAssistant.GOLD_TEXT))
                    CraftingWritAssistantActiveWritIcon:SetColor(hex2rgb(CraftingWritAssistant.GOLD_TEXT))
                else
                    ActiveWritLabel:SetColor(hex2rgb(CraftingWritAssistant.NORMAL_ICON_COLOR))
                    CraftingWritAssistantActiveWritIcon:SetColor(hex2rgb(CraftingWritAssistant.NORMAL_ICON_COLOR))
                end
                    
				--FUTURE:: Refactor using this method on this page to make the "condition steps generic" https://github.com/ziggr/ESO-LibCraftText/blob/master/LibCraftText_Example1.lua
                --bind steps    
                for i = 1, 5 do
                    local currentStepInfo = CraftingWritAssistant.CurrentCraftingWritSteps[craftingType].steps[i]       
                    local label = GetControl("CraftingWritAssistantStepItem"..tostring(i), "Description")
                    --d(currentStepInfo)        
                    if currentStepInfo ~= nil then  
                        label:SetText(currentStepInfo)
                       
                        if (CraftingWritAssistant.CurrentCraftingWritSteps[craftingType].stepComplete[i]) then
                            label:SetColor(hex2rgb(CraftingWritAssistant.COMPLETE_TEXT))
                        else
                            label:SetColor(hex2rgb(CraftingWritAssistant.IN_PROGRESS_TEXT))
                        end
                    else
                         label:SetText("")
                    end
                end
                               
                    if craftingType == CRAFTING_TYPE_PROVISIONING or craftingType == CRAFTING_TYPE_ENCHANTING then  
                        local currentStepInfo = CraftingWritAssistant.CurrentCraftingWritSteps[craftingType].steps[1]
                        --CraftingWritAssistant.DebugWriteLine("Binding details")
                        --no need to rebind if we are in the "deliver" stage of the quest
                        if PlainStringFind(currentStepInfo, GetString(SI_CWA_DELIVER)) then                            
                            CraftingWritAssistant.ClearAdditionalDetails()
                        else
							
						    if craftingType == CRAFTING_TYPE_PROVISIONING then
								BindProvisioningDetails(journalIndex)   
							elseif  craftingType == CRAFTING_TYPE_ENCHANTING then
								BindEnchantingDetails(craftingType, currentStepInfo)
							end                            
                        end
                    else
                        CraftingWritAssistant.ClearAdditionalDetails()
                    end
                                    
                return true
            end
        end
    end
end

function CraftingWritAssistant.IsCraftingWritTypeValid(craftingType)
	--Updated on 6-1-2019 to use LibCraftText
	--return (LibCraftText.DailyQuestNameToCraftingType(quest_name) ~= CRAFTING_TYPE_INVALID)
    return (CraftingWritAssistant.CRAFTING_WRIT_TYPE_NAME[craftingType] ~= nil)
end
 
function CraftingWritAssistant.ClearAdditionalDetails()   
    --clear controls
    for i = 1, 5 do     
        local additionalInfoText = GetControl("CraftingWritAssistantAddInfoItem"..tostring(i), "Description")
        additionalInfoText:SetText("")  
    end             
end
 
function CraftingWritAssistant.CraftingStationEnter(eventCode, craftingType, sameStation)
    CraftingWritAssistant.ClosedWindowInSession = false
    CraftingWritAssistant.HasDisplayedActiveWritMessage = false
		
    if CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtStation == true then        
        
        BindActiveCraftingWritDropDown(craftingType)
        
        LoadJournalWritDetails()
				        
		local hasThisCraftQuestType = HasActiveWritsForCraftingStationType(craftingType)
		
        if hasThisCraftQuestType then
			local hasCraftQuests = CraftingWritAssistant.BindWindow(craftingType)
			
			if hasCraftQuests then      
				CraftingWritAssistant.ShowWindow()  
				--NEW
				CraftingWritAssistant.LastCraftingStationWritName = CraftingWritAssistant.CraftingWritAssistantCharSelect.dropdown:GetSelectedItem()
				CraftingWritAssistant.LastCraftingStationWritType = craftingType
			end
		else
			CraftingWritAssistantWindow:SetHidden(true)    			
		end
		
    end 
    --d("CraftingStationInteract -- sameStation "..tostring(sameStation))
end
 
function CraftingWritAssistant.CraftingStationLeft(eventCode,craftingType)

	CraftingWritAssistant.HasDisplayedActiveWritMessage = true
	CraftingWritAssistant.ClosedWindowInSession = false
		
	if CraftingWritAssistant.savedVariables.LeaveCraftingWritWindowOpenOnExit == false then --or hasCraftQuests == false
		CraftingWritAssistantWindow:SetHidden(true)     
		--d("CraftingStationLeft -- craftingType "..tostring(craftingType))	
	else
		local hasCraftQuests = CraftingWritAssistant.BindWindow(CraftingWritAssistant.LastCraftingStationWritType)
		
		if(hasCraftQuests) then
			LoadJournalWritDetails()
			BindActiveCraftingWritDropDown()
							
			--CraftingWritAssistant.BindWindow()
			
			--d(CraftingWritAssistant.LastCraftingStationWritName)
			--d(CraftingWritAssistant.LastCraftingStationWritType)			
			
			--NEW
			OnCraftingWritAssistSelect(nil,CraftingWritAssistant.LastCraftingStationWritName, nil)
			SetSelectedItemWritDropdown(CraftingWritAssistant.LastCraftingStationWritName)
											
		end		 
	end
end
 
function CraftingWritAssistant.CraftingCompleted(eventCode, craftingType)   
    --d("CraftingCompleted -- craftingType "..tostring(craftingType))
    if CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtStation == true and CraftingWritAssistant.ClosedWindowInSession == false then
        
        LoadJournalWritDetails()
        local hasCraftQuests = CraftingWritAssistant.BindWindow(craftingType)
        if hasCraftQuests then      
            CraftingWritAssistant.ShowWindow()  
        end
    end 
end
 
function CraftingWritAssistant.ShowPrimaryWindow()  
        
    if (CraftingWritAssistantWindow:IsHidden()) then 
        
         LoadJournalWritDetails()
         BindActiveCraftingWritDropDown()
         
        local hasCraftQuests = CraftingWritAssistant.BindWindow()
        if hasCraftQuests then      
            CraftingWritAssistant.ShowWindow()  
        end
        
     else
         CraftingWritAssistantWindow:SetHidden(true) 
     end
end
 
 
function CraftingWritAssistant.CloseWindowIfNeeded()    
    CraftingWritAssistantWindow:SetHidden(true)     
    CraftingWritAssistant.ToggleSlotUpdateEvent(false)  
end
 
 
function CraftingWritAssistant.DisplayWindowAtBank()    
    CraftingWritAssistant.DisplayWindow(CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtBank)  
end
 
function CraftingWritAssistant.DisplayWindowAtGuildBank()   
    CraftingWritAssistant.DisplayWindow(CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtGuildBank) 
end
 
function CraftingWritAssistant.DisplayWindowAtGuildStore()  
    CraftingWritAssistant.DisplayWindow(CraftingWritAssistant.savedVariables.ShowCraftingWritWindowAtGuildStore)    
end
 
function CraftingWritAssistant.DisplayWindow(visible)   
    if visible == true then
        if (CraftingWritAssistantWindow:IsHidden()) then 
             CraftingWritAssistant.ToggleSlotUpdateEvent(true) 
             
             LoadJournalWritDetails()
             BindActiveCraftingWritDropDown()
             
            local hasCraftQuests = CraftingWritAssistant.BindWindow()
            if hasCraftQuests then      
                CraftingWritAssistant.ShowWindow()  
            end                 
         end
    end 
end
 
function CraftingWritAssistant.InventorySlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
 
 if updateReason ~= INVENTORY_UPDATE_REASON_DEFAULT then return end
 
   if bagId == BAG_BACKPACK then     
      local itemType = GetItemType(bagId, slotId)    
      
      --creating a table to look up to see if we need to refresh writ panel
      local itemTypesToCheck = {ITEMTYPE_DRINK, ITEMTYPE_FOOD, ITEMTYPE_GLYPH_ARMOR, ITEMTYPE_GLYPH_JEWELRY, ITEMTYPE_GLYPH_WEAPON, ITEMTYPE_ENCHANTING_RUNE_ASPECT, 
      ITEMTYPE_ENCHANTING_RUNE_ESSENCE, ITEMTYPE_ENCHANTING_RUNE_POTENCY, ITEMTYPE_ALCHEMY_BASE,ITEMTYPE_REAGENT }
             
     -- CraftingWritAssistant.DebugWriteLine("item update")
     -- CraftingWritAssistant.DebugWriteLine(itemType)      
    for key, value in pairs(itemTypesToCheck) do
        if value == itemType then 
            --d("Item Type watched Found")
             
             LoadJournalWritDetails()
             
            local hasCraftQuests = CraftingWritAssistant.BindWindow()
            if hasCraftQuests then      
                CraftingWritAssistant.ShowWindow()  
            end
             return         
        end             
    end 
end
end
 
function CraftingWritAssistant.ToggleSlotUpdateEvent(enabled) 
    if enabled == true then
        --CraftingWritAssistant.DebugWriteLine("Binding: enabled")
        EVENT_MANAGER:RegisterForEvent(CraftingWritAssistant.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, CraftingWritAssistant.InventorySlotUpdate)
    else
        --CraftingWritAssistant.DebugWriteLine("Binding: DISabled")
        EVENT_MANAGER:UnregisterForEvent(CraftingWritAssistant.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    end
end
 
--(number eventCode, boolean isCompleted, number journalIndex, string questName, number zoneIndex, number poiIndex, number questID)
function CraftingWritAssistant.QuestRemoved(eventCode, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questID)  
                LoadJournalWritsAndDetails()
                BindActiveCraftingWritDropDown()
				CraftingWritAssistant.BindWindow()         		  
end
 
--(number eventCode, number journalIndex, string questName, string objectiveName)
function CraftingWritAssistant.QuestAdded(eventCode, journalIndex, questName,  objectiveName)
        --CraftingWritAssistant.DebugWriteLine(questName)
       local craftingType = CraftingWritAssistant.GetCraftingWritTypeFromQuestName(questName)
        
       --only load data when crafting quests are added
       if CraftingWritAssistant.IsCraftingWritTypeValid(craftingType) then
            LoadJournalWritsAndDetails()    
            BindActiveCraftingWritDropDown()            
       end  
end
 
SLASH_COMMANDS["/cwa"] = CraftingWritAssistant.ShowPrimaryWindow
SLASH_COMMANDS["/writ"] = CraftingWritAssistant.ShowPrimaryWindow
 
EVENT_MANAGER:RegisterForEvent(CraftingWritAssistant.name, EVENT_OPEN_TRADING_HOUSE, CraftingWritAssistant.DisplayWindowAtGuildStore)
EVENT_MANAGER:RegisterForEvent(CraftingWritAssistant.name, EVENT_CLOSE_TRADING_HOUSE, CraftingWritAssistant.CloseWindowIfNeeded)
EVENT_MANAGER:RegisterForEvent(CraftingWritAssistant.name, EVENT_OPEN_BANK, CraftingWritAssistant.DisplayWindowAtBank)
EVENT_MANAGER:RegisterForEvent(CraftingWritAssistant.name, EVENT_CLOSE_BANK, CraftingWritAssistant.CloseWindowIfNeeded)
EVENT_MANAGER:RegisterForEvent(CraftingWritAssistant.name, EVENT_OPEN_GUILD_BANK, CraftingWritAssistant.DisplayWindowAtGuildBank)
EVENT_MANAGER:RegisterForEvent(CraftingWritAssistant.name, EVENT_CLOSE_GUILD_BANK, CraftingWritAssistant.CloseWindowIfNeeded)
EVENT_MANAGER:RegisterForEvent(CraftingWritAssistant.name, EVENT_CRAFT_COMPLETED, CraftingWritAssistant.CraftingCompleted)
EVENT_MANAGER:RegisterForEvent(CraftingWritAssistant.name, EVENT_CRAFTING_STATION_INTERACT, CraftingWritAssistant.CraftingStationEnter)
EVENT_MANAGER:RegisterForEvent(CraftingWritAssistant.name, EVENT_QUEST_REMOVED, CraftingWritAssistant.QuestRemoved)
EVENT_MANAGER:RegisterForEvent(CraftingWritAssistant.name, EVENT_QUEST_ADDED, CraftingWritAssistant.QuestAdded)
EVENT_MANAGER:RegisterForEvent(CraftingWritAssistant.name, EVENT_END_CRAFTING_STATION_INTERACT, CraftingWritAssistant.CraftingStationLeft)
EVENT_MANAGER:RegisterForEvent(CraftingWritAssistant.name, EVENT_PLAYER_ACTIVATED, LoadJournalWritsAndDetails)
 
-- register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(CraftingWritAssistant.name, EVENT_ADD_ON_LOADED, CraftingWritAssistant.OnAddOnLoaded)

