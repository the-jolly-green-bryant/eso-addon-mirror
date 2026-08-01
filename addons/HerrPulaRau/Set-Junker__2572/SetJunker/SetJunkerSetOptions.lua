SetJunker.colors = {
    activeButtonRgb = {
        r = 0.7254,
        g = 0.76078,
        b = 0.619607,
        s = 1
    },
    activeHighlitedButtonRgb = {
        r = 0.97254,
        g = 0.96078,
        b = 0.919607,
        s = 1
    }
}

SetJunker.activeSet = nil

function SetJunker.highlightSpecificButton( label )
    label:SetColor(SetJunker.colors.activeHighlitedButtonRgb.r, SetJunker.colors.activeHighlitedButtonRgb.g, SetJunker.colors.activeHighlitedButtonRgb.b, SetJunker.colors.activeHighlitedButtonRgb.s)
end

function SetJunker.unHighlightSpecificButton( label )
    label:SetColor(SetJunker.colors.activeButtonRgb.r, SetJunker.colors.activeButtonRgb.g, SetJunker.colors.activeButtonRgb.b, SetJunker.colors.activeButtonRgb.s)
end

function SetJunker.toggleJunkSpecificItem( label )
    local currentValue = label:GetText()
    local constName = label:GetNamedChild("value"):GetText():sub(2, -1)
    local type = label:GetNamedChild("type"):GetText()
    if (currentValue == 'ON') then
        if (not SetJunker.config.individualItemsOff[SetJunker.activeSet.id]) then
            SetJunker.config.individualItemsOff[SetJunker.activeSet.id] = {}
            SetJunker.config.individualItemsOff[SetJunker.activeSet.id][type] = {}
        end

        if (not SetJunker.config.individualItemsOff[SetJunker.activeSet.id][type]) then
            SetJunker.config.individualItemsOff[SetJunker.activeSet.id][type] = {}
        end

        SetJunker.config.individualItemsOff[SetJunker.activeSet.id][type][_G[constName]] = 1

        label:SetText('OFF')
    else
        SetJunker.config.individualItemsOff[SetJunker.activeSet.id][type][_G[constName]] = nil
        label:SetText('ON')
    end
end

function SetJunker.activateDetailedOptions( setId, setName )
    SetJunker.activeSet = {id = setId, name = setName }
    local container = SetDetailedOptions:GetNamedChild("DetailedSetOptions")
    container:GetNamedChild("DetailedSetOptions"):SetText("Junk specific items for: " .. setName)
    container:SetHidden(false)

    SetJunker.setIndividualItemsButtonsValues(container:GetNamedChild("JunkArmors"))
    SetJunker.setIndividualItemsButtonsValues(container:GetNamedChild("JunkWeaponsAndRings"))
end

function SetJunker.deactivateDetailedOptions()
    SetJunker.activeSet = nil;
    SetDetailedOptions:GetNamedChild("DetailedSetOptions"):SetHidden(true)
end

function SetJunker.toggleJunkIntricates()
    SetJunker.config.junkIntricatesOff = math.abs(SetJunker.config.junkIntricatesOff - 1)
    SetJunker.setJunkIntricatesOff()
end

function SetJunker.setJunkIntricatesOff()
    local label = SetJunkerJunkIntricatesButton
    if (SetJunker.config.junkIntricatesOff == 0) then
        label:SetText('OFF')
    else
        label:SetText('ON')
    end
end

function SetJunker.toggleJunkSet( label )
    local control = label:GetParent()

    if control.data.junk == 'ON' then
        control.data.junk = 'OFF'
        SetJunker.config['junkSets'][control.data.setId] = nil
        SetJunker.deactivateDetailedOptions(control.data.setId, control.data.name);
    else
        control.data.junk = 'ON'
        SetJunker.config['junkSets'][control.data.setId] = 1
        SetJunker.activateDetailedOptions(control.data.setId, control.data.name);
    end

    ItemBrowser.list:RefreshVisible()
end

function SetJunker.unHighlightTheRow( label )
    local control = label:GetParent()
    ItemBrowser.list:Row_OnMouseExit(control)
end

function SetJunker.setJunkDuplicates()
    local label = SetDetailedOptions:GetNamedChild("JunkDuplicates"):GetNamedChild("JunkDuplicatesButton")
    if (SetJunker.config.junkDuplicates == 0) then
        label:SetText('OFF')
    else
        label:SetText('ON')
    end
end

function SetJunker.toggleJunkDuplicates()
    SetJunker.config.junkDuplicates = math.abs(SetJunker.config.junkDuplicates - 1)
    SetJunker.setJunkDuplicates()
end

function SetJunker.setIndividualItemsButtonsValues( container )
    for index = 1, container:GetNumChildren() do
        local label = container:GetChild(index)

        if label:GetNamedChild("value") then
            local type = label:GetNamedChild("type"):GetText()
            local constName = label:GetNamedChild("value"):GetText():sub(2, -1)
            if (
                SetJunker.config.individualItemsOff[SetJunker.activeSet.id] and
                SetJunker.config.individualItemsOff[SetJunker.activeSet.id][type] and
                SetJunker.config.individualItemsOff[SetJunker.activeSet.id][type][_G[constName]]
            ) then
                label:SetText('OFF')
            else
                label:SetText('ON')
            end
        end
    end
end

function SetJunker:InitializeComboBox( control, prefix, max, container )
    control:SetSortsItems(false)
    control:ClearItems()

    local type = container:GetParent():GetNamedChild("type")
    local callback = function( comboBox, entryText, entry, selectionChanged )
        SetJunker.config.raritySettings[type:GetText()] = entry.id
    end

    for i = 0, max do
        local entry = ZO_ComboBox:CreateItemEntry(GetString(prefix, i), callback)
        entry.id = i
        control:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
    end

    control:SelectItemByIndex(SetJunker.config.raritySettings[type:GetText()] + 1, true)
end

function SetJunker.GenerateComboEntry( id, control, callback )
    local entry = ZO_ComboBox:CreateItemEntry(GetString("SI_ITEMTRAITTYPE", id), callback)
    entry.id = id
    control:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)
    control.choices[id] = entry
end

function SetJunker:InitializeArmorTraitsComboBox( control )
    control:SetSortsItems(false)
    control:ClearItems()
    control.choices = {}

    local callback = function( comboBox, entryText, entry, selectionChanged )
        SetJunker.config.preferredArmorTrait = entry.id
    end

    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_ARMOR_DIVINES, control, callback)
    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_ARMOR_INFUSED, control, callback)
    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_ARMOR_NIRNHONED, control, callback)
    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE, control, callback)
    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED, control, callback)
    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS, control, callback)
    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_ARMOR_INTRICATE, control, callback)
    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_ARMOR_STURDY, control, callback)
    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_ARMOR_TRAINING, control, callback)

    control:SelectItem(control.choices[SetJunker.config.preferredArmorTrait], true)
end

function SetJunker:InitializeWeaponTraitsComboBox( control )
    control:SetSortsItems(false)
    control:ClearItems()
    control.choices = {}

    local callback = function( comboBox, entryText, entry, selectionChanged )
        SetJunker.config.preferredWeaponTrait = entry.id
    end

    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_WEAPON_PRECISE, control, callback)
    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_WEAPON_INFUSED, control, callback)
    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_WEAPON_NIRNHONED, control, callback)
    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_WEAPON_SHARPENED, control, callback)
    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_WEAPON_DECISIVE, control, callback)
    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_WEAPON_WEIGHTED, control, callback)
    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_WEAPON_DEFENDING, control, callback)
    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_WEAPON_TRAINING, control, callback)
    SetJunker.GenerateComboEntry(ITEM_TRAIT_TYPE_WEAPON_POWERED, control, callback)

    control:SelectItem(control.choices[SetJunker.config.preferredWeaponTrait], true)
end