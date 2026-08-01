--[[

Dialog to change filter settings

--]]

ASYCFD = {}


ASYCFD.minimumQuality = 1

function ASYCFD:Commit(control)

    local ctrlContent = GetControl(control, "Content")

    local function getCheckState(name)
        local check = GetControl(ctrlContent, name)
        return ZO_CheckButton_IsChecked(check)
    end


	local scryFilter = ASY.scryFilter

    scryFilter.showRequiresLead = getCheckState("ShowBasicLeadsCheck")
    scryFilter.showInProgress = getCheckState("ShowAllZonesCheck")
    scryFilter.minimumQuality = ASYCFD.minimumQuality
	
    ASY.ApplyFilter()
end

function ASYCFD:Setup(control)
    local ctrlContent = GetControl(control, "Content")

    local function setCheckState (name, checked)
        local check = GetControl(ctrlContent, name)
    
        if (checked) then
            ZO_CheckButton_SetChecked(check)
        else
            ZO_CheckButton_SetUnchecked(check)
        end    
    end


	local scryFilter = ASY.scryFilter

    setCheckState ("ShowBasicLeadsCheck",scryFilter.showRequiresLead)
    setCheckState ("ShowAllZonesCheck",scryFilter.showInProgress)

    local comboMinQuality = ZO_ComboBox_ObjectFromContainer(ctrlContent:GetNamedChild("MinQualityDropdown"))
    ASYCFD.SetupMinQualityCombo(comboMinQuality, scryFilter.minimumQuality)
end


function ASYCFD.SetupMinQualityCombo(dropdown, minQuality)
    local QUALITY_NAMES = {
        [0]={"Trash"},
        [1]={"Normal"},
        [2]={"Fine"},
        [3]={"Superior"},
        [4]={"Epic"},
        [5]={"Legendary"},
        [6]={"Mythic"}
    }


    dropdown:ClearItems()
    dropdown:SetSortsItems(false)
    ASYCFD.minimumQuality = minQuality

    local function OnQualityEntrySelected(_, _, entry)
        ASYCFD.minimumQuality = entry.minQuality
    end

    local defaultEntry

    -- Add quality items
    for qualityId = 0, 5 do

        local colorDef = GetAntiquityQualityColor(qualityId)
        local name = colorDef:Colorize(unpack(QUALITY_NAMES[qualityId]))

        local entry = ZO_ComboBox:CreateItemEntry(name, OnQualityEntrySelected)
        entry.minQuality = qualityId
        dropdown:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)

        if minQuality == qualityId then
            defaultEntry = entry
        end
    end

    dropdown:UpdateItems()
    dropdown:SelectItem(defaultEntry)
end




function ASYCFD.Initialize()
	local control = ASYChangeFilterDialog

    ZO_Dialogs_RegisterCustomDialog("ASY_CHANGE_FILTER_DIALOG", {
        customControl = control,
        title = { text = "Scryables Filter Properties" },
		setup = function(self) ASYCFD:Setup(control) end,
        buttons =
        {
            {
                control =   GetControl(control, "Accept"),
                text =      SI_DIALOG_ACCEPT,
                keybind =   "DIALOG_PRIMARY",
                callback =  function(dialog)
                                ASYCFD:Commit(control)
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

ASYCFD.Initialize()