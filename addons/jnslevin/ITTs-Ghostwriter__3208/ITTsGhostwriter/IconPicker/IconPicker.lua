IconPicker = ZO_ArmoryBuildIconPicker_Shared:Subclass()

function IconPicker:Initialize( control )
    local templateData =
    {
        gridListClass = ZO_GridScrollList_Keyboard,
        entryTemplate = "GW_Dialog_IconPickerControl",
        entryWidth = ZO_ARMORY_BUILD_ICON_PICKER_PICK_KEYBOARD_SIZE,
        entryHeight = ZO_ARMORY_BUILD_ICON_PICKER_PICK_KEYBOARD_SIZE,
        entryPaddingX = ZO_ARMORY_BUILD_ICON_PICKER_PICK_KEYBOARD_PADDING,
        entryPaddingY = ZO_ARMORY_BUILD_ICON_PICKER_PICK_KEYBOARD_PADDING,
    }

    ZO_ArmoryBuildIconPicker_Shared.Initialize( self, control, templateData )

    self:InitializeArmoryBuildIconPickerGridList()
end

function IconPicker:SetupIconPickerForCategory( categoryData )
    -- Clear the current selection
    self.selectedIconIndex = nil

    -- If categoryData is provided, set the selectedIconIndex to the category's icon index
    if categoryData then
        self.selectedIconIndex = categoryData.iconIndex
    end

    -- Refresh the icon grid to reflect the new selection
    self:RefreshGridList()
end

function IconPicker:OnArmoryBuildIconPickerEntrySetup( control, data )
    local iconContainer = control:GetNamedChild( "IconContainer" )
    local checkButton = iconContainer:GetNamedChild( "Frame" )

    local isCurrent = data.isCurrent
    if type( isCurrent ) == "function" then
        isCurrent = isCurrent()
    end

    local function OnClick()
        self:OnArmoryBuildIconPickerGridListEntryClicked( data.iconIndex )
    end

    iconContainer:GetNamedChild( "Icon" ):SetTexture( self:GetCustomIcon( data.iconIndex ) )
    ZO_CheckButton_SetCheckState( checkButton, isCurrent )
    ZO_CheckButton_SetToggleFunction( checkButton, OnClick )
end

function IconPicker:SetArmoryBuildIconPicked( iconIndex )
    ZO_ArmoryBuildIconPicker_Shared.SetArmoryBuildIconPicked( self, iconIndex )

    self:RefreshGridList()
    PlaySound( SOUNDS.GUILD_RANK_LOGO_SELECTED )
end

function IconPicker:OnArmoryBuildIconPickerGridListEntryClicked( newIconIndex )
    self:SetArmoryBuildIconPicked( newIconIndex )
end

function IconPicker:GetCustomIcon( index )
    local iconTable = ITTsGhostwriter.LookupIcons( index )
    return iconTable and iconTable.up
end

function IconPicker:GetSelectedIcon()
    -- Return the selected icon index and the corresponding icon
    return self:GetSelectedArmoryBuildIconIndex(), self:GetCustomIcon( self:GetSelectedArmoryBuildIconIndex() )
end
