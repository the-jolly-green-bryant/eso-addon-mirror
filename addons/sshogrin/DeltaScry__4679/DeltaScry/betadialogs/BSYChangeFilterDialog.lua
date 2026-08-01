--[[

Dialog to change filter settings

--]]

-- These are needed for the type filter - there is no existing type enum
local ADM = ANTIQUITY_DATA_MANAGER 
local RM = REWARDS_MANAGER

-- namespace
BSYCFD = {}

BSYCFD.minimumQuality = 1
BSYCFD.maximumQuality = 4
BSYCFD.no_type = "--"
BSYCFD.atype = nil

function BSYCFD:Commit(control)

    local ctrlContent = GetControl(control, "Content")

    local function getCheckState(name)
        local check = GetControl(ctrlContent, name)
        return ZO_CheckButton_IsChecked(check)
    end


	local scryFilter = BSY.scryFilter

    scryFilter.showRequiresLead = getCheckState("ShowBasicLeadsCheck")
    scryFilter.showInProgress = getCheckState("ShowAllZonesCheck")
    scryFilter.minimumQuality = BSYCFD.minimumQuality
    scryFilter.maximumQuality = BSYCFD.maximumQuality
    scryFilter.atype = BSYCFD.atype
    	
    BSY.ApplyFilter()
end

function BSYCFD:Setup(control)
    local ctrlContent = GetControl(control, "Content")

    local function setCheckState (name, checked)
        local check = GetControl(ctrlContent, name)
    
        if (checked) then
            ZO_CheckButton_SetChecked(check)
        else
            ZO_CheckButton_SetUnchecked(check)
        end    
    end


	local scryFilter = BSY.scryFilter

    setCheckState ("ShowBasicLeadsCheck",scryFilter.showRequiresLead)
    setCheckState ("ShowAllZonesCheck",scryFilter.showInProgress)

    local comboMinQuality = ZO_ComboBox_ObjectFromContainer(ctrlContent:GetNamedChild("MinQualityDropdown"))
    BSYCFD.SetupMinQualityCombo(comboMinQuality, scryFilter.minimumQuality, false)

    local comboMaxQuality = ZO_ComboBox_ObjectFromContainer(ctrlContent:GetNamedChild("MaxQualityDropdown"))
    BSYCFD.SetupMinQualityCombo(comboMaxQuality, scryFilter.maximumQuality, true)

    local comboType = ZO_ComboBox_ObjectFromContainer(ctrlContent:GetNamedChild("TypeDropdown"))
    BSYCFD.SetupTypeCombo(comboType, scryFilter.atype)
end


function BSYCFD.SetupMinQualityCombo(dropdown, value, switchMinMax)
    local QUALITY_NAMES = {
        [0]={"Trash/Grey"},
        [1]={"Normal/Green"},
        [2]={"Fine/Blue"},
        [3]={"Superior/Purple"},
        [4]={"Epic/Gold"},
        [5]={"Legendary/Orange"},
        [6]={"Mythic"}
    }


    dropdown:ClearItems()
    dropdown:SetSortsItems(false)

    if not switchMinMax then 
        BSYCFD.minimumQuality = value
    else 
        BSYCFD.maximumQuality = value
    end

    local function OnMinQualityEntrySelected(_, _, entry)
        BSYCFD.minimumQuality = entry.minQuality
    end

    local function OnMaxQualityEntrySelected(_, _, entry)
        BSYCFD.maximumQuality = entry.maxQuality
    end


    local defaultEntry

    -- Add quality items
    for qualityId = 0, 5 do

        local colorDef = GetAntiquityQualityColor(qualityId)
        local name = colorDef:Colorize(unpack(QUALITY_NAMES[qualityId]))

        local entry

        if not switchMinMax then
            entry = ZO_ComboBox:CreateItemEntry(name, OnMinQualityEntrySelected)
            entry.minQuality = qualityId
        else 
            entry = ZO_ComboBox:CreateItemEntry(name, OnMaxQualityEntrySelected)
            entry.maxQuality = qualityId
        end

        dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)

        if value == qualityId then
            defaultEntry = entry
        end
    end

    dropdown:UpdateItems()
    dropdown:SelectItem(defaultEntry)
end

-- This method collects all the types from the leads, and loads it into the treasure type dropdown. For leads without type it uses 'Part' - this is problematic with localisation
-- "Part" *must* match with the one in the addon lua file.
-- added by Latetide
function BSYCFD.SetupTypeCombo(dropdown, typeValue)
    dropdown:ClearItems()
    dropdown:SetSortsItems(true)

    local types = {}

    local function OnTypeEntrySelected(_, _, entry)
        BSYCFD.atype = entry.atype
    end

    local function addOrIncrease(type_array, ant_type) 
        if type_array[ant_type] == nil then
            type_array[ant_type] = 0
        end
    
        type_array[ant_type] = type_array[ant_type] + 1
    
        return type_array
    end

    local entry = ZO_ComboBox:CreateItemEntry(BSYCFD.no_type, OnTypeEntrySelected)
    entry.atype = nil
    local defaultEntry = entry
    
    dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)

    for _, antiquityData in pairs (ADM.antiquities) do
        rewardContextualTypeString = RM:GetRewardContextualTypeString(antiquityData.rewardId) or "Part" -- unsure how to localise this
        types = addOrIncrease(types, rewardContextualTypeString)
    end

    for name, _ in pairs(types) do
        entry = ZO_ComboBox:CreateItemEntry(name, OnTypeEntrySelected)
        entry.atype = name
        
        if name == typeValue then
            defaultEntry = entry
        end
        dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
    end

    dropdown:UpdateItems()
    dropdown:SelectItem(defaultEntry)
end


function BSYCFD.Initialize()
	local control = BSYChangeFilterDialog

    ZO_Dialogs_RegisterCustomDialog("BSY_CHANGE_FILTER_DIALOG", {
        customControl = control,
        title = { text = "Scryables Filter Properties" },
		setup = function(self) BSYCFD:Setup(control) end,
        buttons =
        {
            {
                control =   GetControl(control, "Accept"),
                text =      SI_DIALOG_ACCEPT,
                keybind =   "DIALOG_PRIMARY",
                callback =  function(dialog)
                                BSYCFD:Commit(control)
                            end,
            },  
            {
                control =   GetControl(control, "Cancel"),
                text =      SI_DIALOG_CANCEL,
                keybind =   "DIALOG_NEGATIVE",
                callback =  function(dialog)
                            end,
            },
		
        },
    })
end

BSYCFD.Initialize()