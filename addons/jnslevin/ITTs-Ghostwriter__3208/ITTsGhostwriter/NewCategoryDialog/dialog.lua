ITT_GW_AddNewCategoryDialog = ZO_InitializingObject:Subclass()
local logger = GWLogger:New( "AddOrEditCategory" )
function ITT_GW_AddNewCategoryDialog:Initialize( control )
    logger:Log( "ITT_GW_AddNewCategoryDialog:Initialize" )
    self.control = control

    self.containerControl = control:GetNamedChild( "ContentContainer" )
    self.categoryNameEditBox = self.containerControl:GetNamedChild(
        "EditBox" )
    self.iconPickerGridListControl = self.containerControl:GetNamedChild(
        "CategoryIconPicker" )
    self.iconPicker = IconPicker:New( self.iconPickerGridListControl )
    self.slider = self.containerControl:GetNamedChild( "Slider" )
    control.requiredTextFields = ZO_RequiredTextFields:New()
    control.requiredTextFields:AddTextField( self.categoryNameEditBox )
end

function ITT_GW_AddNewCategoryDialog:SetFocusedCategoryData( categoryData )
    self.selectedCategoryData = categoryData
    self.categoryNameEditBox:SetText( categoryData.name )
    self.iconPicker:SetupIconPickerForCategory( categoryData )

    self.slider:SetValue( categoryData.priority )
    logger:Log( "SetFocusedCategoryData: %s", categoryData )
end

function ITT_GW_AddNewCategoryDialog:ResetDialog()
    local dialog = ZO_Dialogs_FindDialog( "ITT_GW_ADD_NEW_CATEGORY" )
    if dialog then
        local editBox = dialog:GetNamedChild( "ContentContainerEditBox" )
        if editBox then
            editBox:SetText( "" )
        else
            logger:Log( 4, "editBox is nil in ResetDialog" )
        end
    else
        logger:Log( 4, "dialog is nil in ResetDialog" )
    end
end

--[[ function ITT_GW_AddNewCategoryDialog:SavePendingChanges(
    selectedIconIndex,
    pendingCategoryName,
    originalCategoryName,
    newPriority )
    logger:Log( 5,
                "prob doesnt even get called so just erroring here to i dont miss it" )
    local db = ITTsGhostwriter.Vars
    if not db then return false end
    if not db.notes then db.notes = {} end
    if db.notes and pendingCategoryName and pendingCategoryName ~= "" and selectedIconIndex then
        logger:Log(
            "SavePendingChanges: pendingCategoryName: %s, selectedIconIndex: %d",
            pendingCategoryName,
            selectedIconIndex )
        if originalCategoryName then
            -- Update existing category
            if originalCategoryName ~= "Uncategorized" then
                logger:Log( "Updating existing category" )
                UpdateCategory( originalCategoryName, pendingCategoryName,
                                selectedIconIndex )
            else
                logger:Log(
                    "SavePendingChanges: Cannot update a category named 'Uncategorized'" )
            end
        else
            -- Add new category
            if pendingCategoryName ~= "Uncategorized" then
                logger:Log( "Adding new category" )
                CreateCategory( pendingCategoryName, selectedIconIndex,
                                newPriority )
            else
                logger:Log( 4,
                            "SavePendingChanges: Cannot add a category named 'Uncategorized'" )
            end
        end

        self:ResetDialog()
        ZO_Dialogs_ReleaseDialog( "ITT_GW_ADD_NEW_CATEGORY" )
        return true
    end
    return false
end ]]

function ITT_GW_AddNewCategoryDialog_OnInitialized( self )
    self.object = ITT_GW_AddNewCategoryDialog:New( self )
    local function dialogSetup( dialog, data )
        local editControl = dialog:GetNamedChild( "ContentContainerEditBox" )
        editControl:SetTextType( TEXT_TYPE_ALL )
        editControl:SetMaxInputChars( 35 )
        local sliderControl = dialog:GetNamedChild( "ContentContainerSlider" )
        local sliderEdit = dialog:GetNamedChild(
            "ContentContainerSliderEditBox" )
        dialog.slider = sliderControl
        sliderEdit:SetMaxInputChars( 4 )
        if data then
            logger:Log( 2, "dialogSetup: data is %s", data )
            -- Set up the dialog for editing the given category
            self.object:SetFocusedCategoryData( data )
            self.object.iconPicker:SetArmoryBuildIconPicked( data.iconIndex )
            dialog:GetNamedChild( "Title" ):SetText(
                "Edit existing Category" )
        else
            sliderEdit:SetText( 1 )
            -- Set up the dialog for creating a new category
            self.object.iconPicker:SetArmoryBuildIconPicked( 1 )
            editControl:SetText( "" )
            self.object.iconPicker:RefreshGridList()
            dialog:GetNamedChild( "Title" ):SetText( "Add New Category" )
            self.object.selectedCategoryData = nil -- Clear selectedCategoryData
        end
    end
    local function acceptCallback( dialog )
        -- Get the selected icon
        local selectedIconIndex, selectedIcon = self.object.iconPicker
            :GetSelectedIcon()

        local text = dialog:GetNamedChild( "ContentContainerEditBox" )
            :GetText()
        local priority = dialog:GetNamedChild( "ContentContainerSlider" )
            :GetValue()
        logger:Log( "acceptCallback: priority is %d", priority )
        -- Get the old name of the category if it exists
        local oldName
        if self.object.selectedCategoryData then
            oldName = self.object.selectedCategoryData.name
        end
        local categoryData = {
            name = text,
            iconIndex = selectedIconIndex,
            priority = priority,
        }
        -- Call UpdateCategory or CreateCategory based on whether oldName exists
        local success


        if oldName then
            logger:Log(
                "acceptCallback: Updating existing category oldName = %s",
                oldName )
            success = ITTsGhostwriter.CM:UpdateCategoryData( oldName,
                                                             categoryData )
        else
            logger:Log( "acceptCallback: Adding new category" )
            local REFRESH_TREE = true
            logger:Log( "acceptCallback: 1 iconindex is type %s",
                        type( selectedIconIndex ) )
            logger:Log( "acceptCallback: 2 name is type %s",
                        type( categoryData.name ) )
            logger:Log( "acceptCallback: 3 priority is type %s",
                        type( categoryData.priority ) )
            success = ITTsGhostwriter.CM:AddCategory( categoryData,
                                                      REFRESH_TREE )
        end

        -- Check the result of UpdateCategory or CreateCategory
        --TODO: Only save data if success. we already have savependingchanges but alas
        if not success then
            logger:Log( 4, "Failed to update or create category" )
            return
        end
    end
    local info = {
        title =
        {
            text = "Add new category",
        },
        mainText =
        {
            text = "",
        },
        setup = dialogSetup,
        customControl = self,
        buttons = {
            [ 1 ] = {
                control = GetControl( self, "Save" ),
                text = SI_SAVE,
                callback = acceptCallback
            },
            [ 2 ] = {
                control = GetControl( self, "Cancel" ),
                text = SI_DIALOG_CANCEL,
            }
        }
    }

    ZO_Dialogs_RegisterCustomDialog( "ITT_GW_ADD_NEW_CATEGORY", info )
end
