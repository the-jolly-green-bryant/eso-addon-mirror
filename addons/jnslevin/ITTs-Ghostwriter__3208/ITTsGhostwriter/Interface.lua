local UI = {}
ITTsGhostwriter.UI = UI
local worldName = GetWorldName()
local db
local CM


-----------
--Constants
-----------
local EDITBOX_BACKDROP_WIDTH = 350
local EDITBOX_BACKDROP_HEIGHT = 350
local EDITBOX_WIDTH = EDITBOX_BACKDROP_WIDTH - 30
local EDITBOX_HEIGHT = EDITBOX_BACKDROP_HEIGHT

local PREVIEW_OFFSET_X = 25

local MAIN_WINDOW_LARGE_WIDTH = 1125
local MAIN_WINDOW_HEIGHT = 550
local MAIN_WINDOW_SMALL_WIDTH = 750

local TREE_INDENT = 70
local TREE_CHILD_SPACING = 0

local DIALOG_GLOW_EDGE_SIZE = 32

-----------
--LogLevels
-----------
local logger = GWLogger:New( "Interface" )
-----------
--Helpers--
-----------
-- Helper function for sorting categories
local function sortCategories( categories )
    table.sort( categories, function( a, b )
        local aPriority = a.priority == 0 and -math.huge or a.priority
        local bPriority = b.priority == 0 and -math.huge or b.priority
        if aPriority == bPriority then
            return a.name < b.name
        else
            return aPriority > bPriority
        end
    end )
end
-----------
--UI ------
-----------
function ITTsGhostwriter.TogglePreview()
    local preview = GetControl( "GW_NotePad_Preview" )
    local titlePreview = GetControl( "GW_NotePad_NoteTitle_Preview" )
    local isHidden = preview:IsHidden()

    preview:SetHidden( not isHidden )
    titlePreview:SetHidden( not isHidden )
    db.settings.noteWindow.previewHidden = not isHidden
    UpdateSizes()
end

function UI.UpdateNotePadPosition()
    db.settings.noteWindow.x = GW_NotePad:GetLeft()
    db.settings.noteWindow.y = GW_NotePad:GetTop()
end

function UpdateTitlePreview()
    local titleEditBox = GetControl( "GW_NotePad_NoteTitle_Box" )
    local titleLabel = GetControl( "GW_NotePad_NoteTitle_Preview" )

    if titleEditBox and titleLabel then
        local titleText = titleEditBox:GetText()
        titleLabel:SetText( titleText )
    end
end

-- Create a hidden control for calculating the height of the text
local hiddenControl = WINDOW_MANAGER:CreateControl( nil, GuiRoot, CT_LABEL )
hiddenControl:SetFont( "ZoFontGame" )   -- Set the font to match the previewLabel
hiddenControl:SetWidth( EDITBOX_WIDTH ) -- Set the width to match the previewLabel
hiddenControl:SetHidden( true )         -- Hide the control

function UpdatePreview()
    --So apparently all a we need to do to make something scrollable is making it bigger than the parent while in a scrollcontainter
    --Problem is editboxes update their sizes based on how much data is in them, same as labels
    --to fix this we make a control which is hidden and has the same font and width, as the label, then we set its text to be the editbox text
    --this control does now have a size based on the text, which we can then use to set the size of the label and editbox
    --and suddenly the editbox (and label) is scrollable (magic i know)

    --do not ask me how long it took to figure this out

    local composeBox = GetControl( "GW_NotePad_ComposeScrollContainer_Box" )
    local previewLabel = GetControl(
        "GW_NotePad_PreviewScrollContainer_Label" )
    -- Set the text of the hidden control to the text of the composeBox

    if composeBox:GetText() == "" then -- make it scrollable when default text is visible
        hiddenControl:SetText( composeBox:GetDefaultText() )
    else
        hiddenControl:SetText( composeBox:GetText() )
    end

    -- Get the dimensions of the text in the hidden control
    local textWidth, textHeight = hiddenControl:GetTextDimensions()

    -- Set the text and height of the previewLabel and composeBox based on the hidden control
    previewLabel:SetText( composeBox:GetText() )
    if composeBox:GetText() ~= "" then
        previewLabel:SetHeight( textHeight )
    else
        previewLabel:SetHeight( 0 )
    end
    composeBox:SetHeight( math.max( textHeight, EDITBOX_BACKDROP_HEIGHT ) ) -- Set the height to be the maximum of the text height and the backdrop height
    DisableButtonIfNotLua( composeBox:GetText() )
    GetControl( "GW_NotePad_Count" ):SetText( #composeBox:GetText() )
end

function UpdateSizes()
    local edgeSize = 32
    local glowControl = GetControl( "ITTsGhostwriterWindowGlow" )
    local preview = GetControl( "GW_NotePad_Preview" )
    local compose = GetControl( "GW_NotePad_Compose" )
    local hDivider = GetControl( "GW_NotePad_HorizontalDivider" )
    local vDivider = GetControl( "GW_NotePad_VerticalDivider" )
    vDivider:SetTextureRotation( math.rad( 90 ) ) -- We want to use the same divider as the horizontal one, but it doesnt exist as a vertical one, so we rotate it

    local smallSize = {
        width = MAIN_WINDOW_SMALL_WIDTH,
        height = MAIN_WINDOW_HEIGHT
    }
    local largeSize = {
        width = MAIN_WINDOW_LARGE_WIDTH,
        height = MAIN_WINDOW_HEIGHT
    }

    -- Choose the size based on whether the Preview is hidden
    local chosenSize = preview:IsHidden() and smallSize or largeSize
    if preview:IsHidden() then
        logger:Log( 4, "UpdateSizes: preview is hidden" )
    else
        logger:Log( 4, "UpdateSizes: preview is not hidden" )
    end
    local scrollChild = GetControl( "GW_NotePad_Preview_ScrollContainer" )
    local label = GetControl( "GW_NotePad_PreviewScrollContainer_Label" )
    label:SetAnchor( TOPLEFT, scrollChild, TOPLEFT, 0, 0 )
    -- Set the size of the main window, its backdrop, and the glowControl
    GW_NotePad:SetDimensions( chosenSize.width, chosenSize.height )
    GW_NotePad_BG:SetDimensions( chosenSize.width, chosenSize.height )
    glowControl:SetDimensions( chosenSize.width + edgeSize * 2,
                               chosenSize.height + edgeSize * 2 )

    -- Clear the existing anchors of the preview and compose
    preview:ClearAnchors()
    compose:ClearAnchors()

    -- Set the anchor of the preview to the main window
    preview:SetAnchor( LEFT, GW_NotePad_Compose, RIGHT, PREVIEW_OFFSET_X, 0 )

    -- Set the anchor of the compose control based on the chosen size
    if chosenSize == largeSize then
        -- If the size is large, center the compose control
        compose:SetAnchor( BOTTOM, GW_NotePad, BOTTOM, 0, -25 )
        hDivider:SetDimensions( largeSize.width, 5 )
    else
        -- If the size is small, align the compose control to the right with specified offsets
        compose:SetAnchor( BOTTOMRIGHT, GW_NotePad, BOTTOMRIGHT, -25, -25 )
        hDivider:SetDimensions( smallSize.width, 5 )
    end

    UI:UpdateHidePreviewButtonTextures()
end

-----------
---Label---
-----------
local function createLabel()
    local scrollBackdrop = GetControl( "GW_NotePad_Preview" )
    local scrollContainer = WINDOW_MANAGER:CreateControlFromVirtual(
        "GW_NotePad_PreviewScrollContainer", scrollBackdrop,
        "ZO_ScrollContainer" )
    scrollContainer:SetAnchor( TOPLEFT, scrollBackdrop, TOPLEFT )
    scrollContainer:SetAnchor( BOTTOMRIGHT, scrollBackdrop, BOTTOMRIGHT )
    local labelContainer = scrollContainer:GetNamedChild( "ScrollChild" )

    -- Create a new Label control
    local label = WINDOW_MANAGER:CreateControl(
        "GW_NotePad_PreviewScrollContainer_Label", labelContainer, CT_LABEL )

    -- Set the properties of the Label control
    scrollBackdrop:SetDimensions( EDITBOX_BACKDROP_WIDTH,
                                  EDITBOX_BACKDROP_HEIGHT )
    scrollBackdrop:ClearAnchors()
    scrollBackdrop:SetAnchor( LEFT, GW_NotePad_Compose, RIGHT,
                              PREVIEW_OFFSET_X, 0 )

    label:SetFont( "ZoFontGame" )
    label:SetDimensions( EDITBOX_WIDTH, EDITBOX_HEIGHT )
    label:SetAnchor( TOPLEFT, labelContainer, TOPLEFT, 0, 0 )

    --Handle title
    local title = GetControl( "GW_NotePad_NoteTitle" )
    local titlePreview = title:GetNamedChild( "_Preview" )
    title:SetDimensions( EDITBOX_BACKDROP_WIDTH, 30 )
    title:ClearAnchors()
    title:SetAnchor( TOP, GW_NotePad_Compose, TOP, 0, -50 )
    titlePreview:SetDimensions( EDITBOX_WIDTH, 30 )
    titlePreview:ClearAnchors()
    titlePreview:SetAnchor( LEFT, title, RIGHT, PREVIEW_OFFSET_X, 0 )
    return label
end


-----------
-- Editbox-
-----------

local function createEditBox()
    local defaultText =
    "Write: Click here and start typing.\nEdit: Click on a note to edit. Don't forget to save!\nNavigate: Use Tab to move, Shift + Tab to go back.\nSave: Click 'Save' to keep your note for later.\nDelete: Right-click to delete a note. Be careful, it's permanent!\nOrganize: Click 'Add New Category' for more categories!\nYou can click on the eye in the top right to hide or show the preview.\n\nEvery time you save a note with a different title, it will be added to the list.\nHappy note-taking!"
    local scrollBackdrop = GetControl( "GW_NotePad_Compose" )
    local scrollContainer = WINDOW_MANAGER:CreateControlFromVirtual(
        "GW_NotePad_ComposeScrollContainer", scrollBackdrop,
        "ZO_ScrollContainer" )

    scrollContainer:SetAnchor( TOPLEFT, scrollBackdrop, TOPLEFT )
    scrollContainer:SetAnchor( BOTTOMRIGHT, scrollBackdrop, BOTTOMRIGHT )
    local editBoxContainer = scrollContainer:GetNamedChild( "ScrollChild" )
    scrollBackdrop:SetDimensions( EDITBOX_BACKDROP_WIDTH,
                                  EDITBOX_BACKDROP_HEIGHT )
    -- Create the EditBox control
    local editBox = WINDOW_MANAGER:CreateControl(
        "GW_NotePad_ComposeScrollContainer_Box", editBoxContainer,
        CT_EDITBOX )
    editBox:SetMaxInputChars( 3000 )
    editBox:SetMultiLine( true )
    editBox:SetDimensions( EDITBOX_WIDTH, EDITBOX_HEIGHT )
    editBox:SetAnchor( TOPLEFT, editBoxContainer, TOPLEFT, 5, 0 )
    editBox:SetFont( "ZoFontGame" )
    editBox:SetMouseEnabled( true )
    -- Set handlers
    editBox:SetHandler( "OnTab",
                        function()
                            if IsShiftKeyDown() then
                                GW_NotePad_NoteTitle_Box
                                    :TakeFocus()
                            end
                        end )
    editBox:SetHandler( "OnEscape", editBox.LoseFocus )
    editBox:SetHandler( "OnTextChanged", UpdatePreview ) -- Call the UpdatePreview function when the text changes


    editBox:SetHandler( "OnMouseDown", function() editBox:TakeFocus() end )
    editBox:SetDefaultText( defaultText )
    -- Handle title
    local title = GetControl( "GW_NotePad_NoteTitle" )
    local titleBox = title:GetNamedChild( "_Box" )
    title:SetDimensions( EDITBOX_BACKDROP_WIDTH, 30 )
    titleBox:SetDimensions( EDITBOX_BACKDROP_WIDTH - 10, 30 )

    UpdatePreview()
    return editBox
end

---------------------
--Mailbox Additions--
---------------------
----ScrollList
--------------
local noteList = {}
ITTsGhostwriter.noteList = noteList
function noteList.CreateScrollListControl()
    noteList.controlScrollList = WINDOW_MANAGER:CreateControlFromVirtual( "ITTsSendMailExtension_Scroll",
                                                                          ITTsSendMailExtension,
                                                                          "ZO_ScrollList" )
    noteList.controlScrollList:SetDimensions( 200, 375 )
    noteList.controlScrollList:SetAnchor( TOPLEFT, ITTsSendMailExtension_NoteEntries, TOPLEFT, 0, 0 )
end

function noteList.CreateDataType()
    local control = noteList.controlScrollList
    local typeId = 1
    local templateName = "ZO_SelectableLabel"
    local height = 25 -- height of the row, not the window
    local setupFunction = noteList.LayoutRow
    local hideCallback = nil
    local dataTypeSelectSound = nil
    local resetControlCallback = nil
    local selectTemplate = "ZO_ThinListHighlight"
    local selectCallback = noteList.OnRowSelect
    ZO_ScrollList_AddDataType( control, typeId, templateName, height, setupFunction, hideCallback, dataTypeSelectSound,
                               resetControlCallback )
    ZO_ScrollList_EnableSelection( control, selectTemplate, selectCallback )
end

function noteList.Populate( category )
    category = category:match( "|t.-%|t (.*)" )
    local notes = CM:GetCategory( category ):GetAllNotes()
    local data = {}
    for key, note in pairs( notes ) do
        data[ #data + 1 ] = {
            name = note:GetName(),
            content = note:GetContent(),
        }
        logger:Log( 2, "Populate: Adding note %s", note:GetName() )
        logger:Log( 2, "Populate: Note content %s", note:GetContent() )
    end
    return data
end

function noteList.UpdateList( control, data, rowType )
    local dataCopy = ZO_DeepTableCopy( data )
    local dataList = ZO_ScrollList_GetDataList( control )

    ZO_ScrollList_Clear( control )

    for key, value in ipairs( dataCopy ) do
        -- Ensure value is a table with the appropriate fields
        if type( value ) == "string" then
            value = { t = key, name = value, description = "", texture = "" }
        end

        local entry = ZO_ScrollList_CreateDataEntry( rowType, value )
        table.insert( dataList, entry ) -- By using table.insert, we add to whatever data may already be there.
    end

    table.sort( dataList, function( a, b ) return a.data.name < b.data.name end )
    ZO_ScrollList_Commit( control )
end

function noteList.LayoutRow( rowControl, data, scrollList )
    rowControl:SetFont( "ZoFontGame" )
    rowControl:SetMaxLineCount( 1 ) -- Forces the text to only use one row.  If it goes longer, the extra will not display.
    rowControl:SetText( data.name )
    rowControl:SetHandler( "OnMouseUp", function() ZO_ScrollList_MouseClick( scrollList, rowControl ) end )
    rowControl:SetHandler( "OnMouseEnter", function( self )
        rowControl:SetColor( 1, 1, 1, 1 )
        if data.content == "" then return end
        InitializeTooltip( InformationTooltip, self, TOPRIGHT, 0, 0,
                           BOTTOMLEFT )
        SetTooltipText( InformationTooltip, data.content )
    end )
    rowControl:SetHandler( "OnMouseExit", function()
        rowControl:SetColor( GetInterfaceColor( INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_NORMAL ) )
        ClearTooltip( InformationTooltip )
    end )


    --[[    rowControl:SetHandler( "OnMouseEnter",
                           function( rowControl ) ZO_Tooltips_ShowTextTooltip( rowControl, LEFT, tooltip ) end )
    rowControl:SetHandler( "OnMouseExit", function( rowControl ) ZO_Tooltips_HideTextTooltip() end )
 ]]
end

function noteList.OnRowSelect( previouslySelectedData, selectedData, reselectingDuringRebuild )
    local subject = GetControl( "ZO_MailSendSubjectField" )
    local body = GetControl( "ZO_MailSendBodyField" )
    if selectedData then
        subject:SetText( selectedData.name )
        body:SetText( selectedData.content )
    else
        subject:SetText( "" )
        body:SetText( "" )
    end
end

local function onSendMailShown( oldState, newState )
    local bg = GetControl( "ZO_SharedRightBackgroundLeft" )
    local control = GetControl( "ITTsSendMailExtension" )
    local hidden = control:IsHidden()
    if newState == "showing" and not hidden then
        bg:SetWidth( 1400 )
        bg:SetAnchor( TOPLEFT, ZO_SharedRightBackground, TOPLEFT, -275, -75 )
    elseif newState == "hidden" then
        bg:SetWidth( 1024 )
        bg:SetAnchor( TOPLEFT, ZO_SharedRightBackground, TOPLEFT, -35, -75 )
        control:SetHidden( true )
        ITTsMailExtensionButton:SetNormalTexture( "/esoui/art/tradinghouse/tradinghouse_trophy_runebox_fragment_up.dds" )
        ITTsMailExtensionButton:SetPressedTexture( "/esoui/art/tradinghouse/tradinghouse_trophy_runebox_fragment_down.dds" )
    end
    --[[
    local scene = SCENE_MANAGER:GetScene( "mailSend" )
    scene:RegisterCallback( "StateChange", sceneChange ) ]]
end

local scene = SCENE_MANAGER:GetScene( "mailSend" )
scene:RegisterCallback( "StateChange", onSendMailShown )

------
--ComboBox
-------
local function populateEntryControl( category )
    -- Get the notes from the selected category
    local notes = noteList.Populate( category )

    -- Update the scroll list with the notes
    local control = noteList.controlScrollList
    local rowType = 1 -- replace with the actual rowType if it's not 1
    noteList.UpdateList( control, notes, rowType )
end
local function populateComboBox()
    local control = GetControl( "ITTsSendMailExtension_CategoryComboBox" )
    local categories = {}
    for categoryName, categoryData in pairs( CM:GetAllCategories() ) do
        table.insert( categories, {
            name = categoryName,
            priority = categoryData.priority or 0
        } )
    end
    sortCategories( categories ) -- Use the helper function to sort the categories
    local object = ZO_ComboBox_ObjectFromContainer( control )
    object:SetSelectedItemFont( "ZoFontGame" )
    object:SetDropdownFont( "ZoFontGame" )
    object:SetSortsItems( false ) -- Disable automatic sorting
    object:SetSpacing( 4 )

    local function callback()
        local data = object:GetSelectedItemData()
        db.settings.mailComboBoxLastSelectedItemIndex = data.index
        populateEntryControl( data.name ) -- Call populateEntryControl with the selected category
    end

    for i = 1, #categories do
        local iconIndex = CM:GetCategory( categories[ i ].name ):GetIconIndex()
        local icon = ITTsGhostwriter.LookupIcons( iconIndex ).down
        local categoryName = string.format( "|t100%%:100%%:%s|t %s", icon,
                                            categories[ i ].name )
        object:AddItem( {
            index = i,
            name = categoryName,
            callback = callback,
        } )
    end
end

----------
--button--
----------
function UI.OnMailButtonClicked( self )
    local control = GetControl( "ITTsSendMailExtension" )
    local hidden = control:IsHidden()
    local bg = GetControl( "ZO_SharedRightBackgroundLeft" )
    control:SetHidden( not hidden )
    if hidden then
        bg:SetWidth( 1400 )
        bg:SetAnchor( TOPLEFT, ZO_SharedRightBackground, TOPLEFT, -275, -75 )
        ITTsMailExtensionButton:SetNormalTexture( "/esoui/art/tradinghouse/tradinghouse_trophy_runebox_fragment_down.dds" )
        ITTsMailExtensionButton:SetPressedTexture( "/esoui/art/tradinghouse/tradinghouse_trophy_runebox_fragment_up.dds" )
    else
        bg:SetWidth( 1024 )
        bg:SetAnchor( TOPLEFT, ZO_SharedRightBackground, TOPLEFT, -35, -75 )
        ITTsMailExtensionButton:SetNormalTexture( "/esoui/art/tradinghouse/tradinghouse_trophy_runebox_fragment_up.dds" )
        ITTsMailExtensionButton:SetPressedTexture( "/esoui/art/tradinghouse/tradinghouse_trophy_runebox_fragment_down.dds" )
    end
end

--------------
-- CustomMenu
--------------
local function ShowContextMenu( categoryData )
    ClearMenu()
    local data = {
        name = categoryData.name,
        iconIndex = categoryData.iconIndex,
        priority = categoryData.priority,
    }
    if data.name == "Uncategorized" then return end
    local entries = {

        {
            label = "Edit Category",
            callback = function()
                logger:Log( 1, "Edit Category" )
                ZO_Dialogs_ShowDialog( "ITT_GW_ADD_NEW_CATEGORY", data ) -- if you want to edit a category, you need to pass the data, without data it will add a new one
            end,
        },
        {
            label = "Delete Category",
            callback = function()
                ZO_Dialogs_ShowDialog( "ITT_GW_DELETE_CATEGORY_CONFIRM",
                                       data )
            end,
        },
    }


    for i, entry in ipairs( entries ) do
        AddCustomMenuItem( entry.label, entry.callback )
    end
    ShowMenu()
end
function ShowNoteCustomMenu( nodeData )
    local entries = {
        {
            label = "Delete Note",
            callback = function()
                ZO_Dialogs_ShowDialog( "ITT_GW_DELETE_NOTE_CONFIRM",
                                       nodeData )
            end,
        },
        {
            label = "Move Note to Category",
            submenu = (function()
                local submenu = {}
                local categories = CM:GetAllCategoryNames()
                local sourceCategory = CM:GetCategoryByNoteName( nodeData
                    .name )
                local sourceCategoryName = sourceCategory:GetName()
                for key, targetCategoryName in pairs( categories ) do
                    if targetCategoryName ~= sourceCategoryName then
                        table.insert( submenu, {
                            label = targetCategoryName,
                            callback = function()
                                if sourceCategory then
                                    local note = sourceCategory:GetNote(
                                        nodeData.name )
                                    if note then
                                        local noteName = note:GetName()
                                        CM:MoveNoteToCategory( noteName,
                                                               sourceCategoryName,
                                                               targetCategoryName )
                                        local treeNode = note:GetTreeNode()
                                    else
                                        logger:Log( 4, "Note not found" )
                                    end
                                else
                                    logger:Log( 4,
                                                "Source category not found" )
                                end
                            end,
                        } )
                    end
                end
                return submenu
            end)(), -- apparently you can just call a function like this
        }
    }

    ClearMenu()
    for i, entry in ipairs( entries ) do
        if entry.submenu then
            AddCustomSubMenuItem( entry.label, entry.submenu )
        else
            AddCustomMenuItem( entry.label, entry.callback )
        end
    end
    ShowMenu()
end

-----------
-- simple dialogs
-----------
--!So much pain... I will never do this again
function CreateNewControlWithEdgeTexture( dialog )
    local MUNGE_OFFSET = 75
    local oldControl = dialog:GetNamedChild( "BG" )
    oldControl:SetEdgeColor( 0, 0, 0, 1 ) -- remove border which looks horrible with red

    local munge = oldControl:GetNamedChild( "MungeOverlay" )

    munge:ClearAnchors()
    munge:SetAnchor( TOPLEFT, oldControl, TOPLEFT, MUNGE_OFFSET,
                     MUNGE_OFFSET )
    munge:SetAnchor( BOTTOMRIGHT, oldControl, BOTTOMRIGHT, -MUNGE_OFFSET,
                     -MUNGE_OFFSET )

    local x, y = dialog:GetDimensions()

    -- Create a new control

    local newControl = CreateControlFromVirtual( dialog:GetName() .. "Glow",
                                                 dialog,
                                                 "ZO_DefaultBackdrop" )
    -- Munge fix so it doesnt go over the edge
    local newMunge = newControl:GetNamedChild( "MungeOverlay" )
    newMunge:ClearAnchors()
    newMunge:SetAnchor( TOPLEFT, newControl, TOPLEFT, MUNGE_OFFSET,
                        MUNGE_OFFSET )

    newMunge:SetAnchor( BOTTOMRIGHT, newControl, BOTTOMRIGHT, -MUNGE_OFFSET,
                        -MUNGE_OFFSET )
    newControl:SetDimensions( x + 25, y + 25 )
    newControl:ClearAnchors()
    local EDGE_SIZE =
        DIALOG_GLOW_EDGE_SIZE
    local OFFSET = EDGE_SIZE / 2

    newControl:SetAnchor( TOPLEFT, oldControl, TOPLEFT, -OFFSET, -OFFSET )
    newControl:SetAnchor( BOTTOMRIGHT, oldControl, BOTTOMRIGHT, OFFSET,
                          OFFSET )

    -- Set other properties of the new control
    newControl:SetDrawLayer( DL_OVERLAY )
    newControl:SetDrawLevel( 28 )
    newControl:SetCenterColor( 0, 0, 0, 0 )
    newControl:SetEdgeTexture( "/esoui/art/crafting/crafting_tooltip_glow_edge_red64.dds", 64, 8,
                               DIALOG_GLOW_EDGE_SIZE )
end

function ITT_GW_DeleteCategoryDialog_OnInitialized( self )
    local info = {
        customControl = self,
        title = {
            text = "Confirm Delete",
        },
        mainText = {
            text = "Are you sure you want to delete this category?",
        },
        setup = function( dialog, data )
            -- Get the checkbox
            local checkbox = dialog:GetNamedChild( "Checkbox" )

            -- Check if the checkbox exists
            if checkbox then
                -- Set the checkbox label
                ZO_CheckButton_SetLabelText( checkbox, "Delete entries in the category" )

                -- Initialize the checkbox as unchecked
                ZO_CheckButton_SetUnchecked( checkbox )

                -- Store the checkbox in the dialog data for later access
                dialog.data.checkbox = checkbox
                dialog.data = data
                --?works but looks ugly
                --dialog:GetNamedChild( "Text" ):SetText( "Are you sure you want to delete the category |cffffff" ..
                --data.name .. "|r?" )
                -- dialog.text:SetText( "Are you sure you want to delete the category " .. data.name .. "?" )
            else

            end
        end,
        buttons = {
            [ 1 ] = {
                control = GetControl( self, "Save" ),
                text = "Yes",
                callback = function( dialog )
                    local checkbox = dialog.data.checkbox
                    local isChecked = ZO_CheckButton_IsChecked( checkbox )
                    if checkbox then
                        logger:Log(
                            "Delete category dialog: Checkbox exists" )
                    else
                        logger:Log(
                            "Delete category dialog: Checkbox does not exist" )
                    end
                    if isChecked then
                        logger:Log(
                            "Delete category dialog: Checkbox is checked" )
                    else
                        logger:Log(
                            "Delete category dialog: Checkbox is not checked" )
                    end

                    local categoryName = dialog.data.name
                    if categoryName ~= "Uncategorized" then
                        CM:RemoveCategory( categoryName, not isChecked )
                    else
                        logger:Log( 4,
                                    "Delete category dialog: Cannot move entries from 'Uncategorized' to itself" )
                    end
                end,
            },
            [ 2 ] = {
                control = GetControl( self, "Cancel" ),
                text = "No",
                callback = function( dialog )
                    -- Handle the "No" button click here
                end,
            },
        },
    }
    CreateNewControlWithEdgeTexture( self )
    ZO_Dialogs_RegisterCustomDialog( "ITT_GW_DELETE_CATEGORY_CONFIRM", info )
end

function ITT_GW_DeleteNoteDialog_OnInitialized( self )
    local info = {
        customControl = self,
        title = {
            text = "Confirm Delete",
        },
        mainText = {
            text = "Are you sure you want to delete this note?",
        },
        setup = function( dialog, data )
            --? works but looks ugly
            --TODO: make it look better
            -- dialog:GetNamedChild( "Text" ):SetText( "Are you sure you want to delete the note |cffffff" .. data.name .. "|r?" )
            -- dialog.text:SetText( "Are you sure you want to delete the note " .. data.name .. "?" )
        end,
        buttons = {
            [ 1 ] = {
                control = GetControl( self, "Save" ),
                text = "Yes",
                callback = function( dialog )
                    local data = dialog.data
                    for k, v in pairs( data ) do
                        logger:Log( "DeleteNoteDialog: data %s type = ", k, type( v ) )
                    end
                    local categoryName = data.category.name
                    logger:Log( "DeleteNoteDialog: categoryName %s",
                                categoryName )
                    local noteName = data.name
                    logger:Log( "DeleteNoteDialog: noteName %s", noteName )
                    local category = CM:GetCategory( categoryName )
                    -- Delete note from category
                    category:DeleteNote( noteName )
                end,
            },
            [ 2 ] = {
                control = GetControl( self, "Cancel" ),
                text = "No",

            },
        },
    }

    CreateNewControlWithEdgeTexture( self )
    ZO_Dialogs_RegisterCustomDialog( "ITT_GW_DELETE_NOTE_CONFIRM", info )
end

-----------
-- Buttons
-----------
function SaveNoteInCategory()
    local categoryName = db.settings.lastOpenedCategory
    local noteTitle = GW_NotePad_NoteTitle_Box:GetText()
    local noteText = GW_NotePad_ComposeScrollContainer_Box:GetText()

    -- Get the category or create a new one if it doesn't exist
    local category = CM:GetCategory( categoryName )
    if not category then
        logger:Log( 4, "SaveNote: Category %s not found, returning",
                    categoryName )
        return false
    end
    local note = category:GetNote( noteTitle )
    local noteData = {
        name = noteTitle,
        content = noteText,
        category = category,
    }
    if not note then
        logger:Log( 4, "SaveNote: Note %s not found, creating", noteTitle )
        note = category:AddNote( noteData )
    end
    logger:Log( "SaveNote: Saving note %s in category %s", noteTitle, categoryName )
    UI:RefreshTree( UI.tree )
end

function DisableButtonIfNotLua( notepadText )
    local func, err = zo_loadstring( notepadText )
    local button = GetControl( "GW_NotePad_Buttons_Button1" )
    if func == nil or notepadText == "" then
        button:SetEnabled( false )
    else
        button:SetEnabled( true )
    end
end

function RunAsScript()
    local code = GW_NotePad_ComposeScrollContainer_Box:GetText()
    local func, err = zo_loadstring( code )
    if func then
        local success, result = pcall( func )
        if success then
            return result
        else
            logger:Log( 4, "Error running code: " .. result )
        end
    else
        logger:Log( 4, "Error loading code: " .. err )
    end
end

function UI.HideNotePad()
    GW_NotePad:SetHidden( true )
end

function UI.ShowNotePad()
    GW_NotePad:SetHidden( false )
end

function UI:UpdateHidePreviewButtonTextures()
    local isPreviewHidden = GW_NotePad_Preview:IsHidden()
    local button = GetControl( "GW_NotePad_HidePreview" )
    if button then
        if isPreviewHidden then
            button:SetNormalTexture( "/esoui/art/miscellaneous/keyboard/hidden_up.dds" )
            button:SetPressedTexture( "/esoui/art/miscellaneous/keyboard/hidden_down.dds" )
            button:SetMouseOverTexture( "/esoui/art/miscellaneous/keyboard/hidden_over.dds" )
        else
            button:SetNormalTexture( "/esoui/art/miscellaneous/keyboard/visible_up.dds" )
            button:SetPressedTexture( "/esoui/art/miscellaneous/keyboard/visible_down.dds" )
            button:SetMouseOverTexture( "/esoui/art/miscellaneous/keyboard/visible_over.dds" )
        end
    end
end

-----------
-- Tree ---
-----------

function TreeNewCategorySetup( node, control, data, open )
    control.text:SetText( "Add new category" )
    control.icon:GetNamedChild( "Highlight" ):SetTexture(
        "/esoui/art/buttons/pointsplus_highlight.dds" )
    control.button = control:GetNamedChild( "Button" )
    control.icon:SetTexture( "/esoui/art/buttons/pointsplus_up.dds" )
    control.icon:SetAlpha( 0 )
    control.text:SetHandler( "OnMouseDown",
                             function(
                                 button,
                                 ctrl,
                                 alt,
                                 shift )
                                 TreeNewCategoryOnSelected( control, data,
                                                            true, node )
                             end )
    control.button:SetHandler( "OnMouseDown",
                               function(
                                   button,
                                   ctrl,
                                   alt,
                                   shift )
                                   TreeNewCategoryOnSelected( control, data,
                                                              true, node )
                               end )
    control.button:ClearAnchors()
    control.button:SetAnchor( LEFT, control.text, LEFT, -40, 0 )
    control.text:ClearAnchors()
    control.text:SetAnchor( LEFT, control, LEFT, 60, 0 )
    ZO_IconHeader_Setup( control, false, true, false )
end

function ShowAddCategoryDialog( node )
    ZO_Dialogs_ShowDialog( "ITT_GW_ADD_NEW_CATEGORY" )
end

function ShowEditCategorydialog( node )
    ZO_Dialogs_ShowDialog( "ITT_GW_ADD_NEW_CATEGORY", { data = node.data } )
end

function TreeNewCategoryOnSelected( control, data, selected, node )
    if selected then
        ShowAddCategoryDialog()
    end
end

local function TreeEntrySetup( node, control, data, open )
    control:SetText( data.name )
    if data.content ~= "" then
        control:SetHandler( "OnMouseEnter", function( self )
            InitializeTooltip( InformationTooltip, self, TOPLEFT, 0, 0,
                               BOTTOMRIGHT )
            SetTooltipText( InformationTooltip, data.content )
        end )
        control:SetHandler( "OnMouseExit", function()
            ClearTooltip( InformationTooltip )
        end )
    end
    local deselectFlag = false

    control:SetHandler( "OnMouseDown",
                        function(
                            self,
                            button,
                            ctrl,
                            alt,
                            shift,
                            command )
                            if button == MOUSE_BUTTON_INDEX_RIGHT then
                                ShowNoteCustomMenu( data )
                            end
                            if shift then
                                node.tree:ClearSelectedNode()
                                deselectFlag = true
                            end
                        end )

    local oldHandler = control:GetHandler( "OnMouseUp" )
    control:SetHandler( "OnMouseUp",
                        function(
                            self,
                            button,
                            ctrl,
                            alt,
                            shift,
                            command,
                            upInside )
                            if deselectFlag then
                                deselectFlag = false
                            else
                                oldHandler( self, button, ctrl, alt, shift,
                                            command,
                                            upInside )
                            end
                        end )
end

local function TreeEntryOnSelected(
    control,
    data,
    selected,
    reselectingDuringRebuild )
    if not control.highlight then
        local highlightControl = WINDOW_MANAGER:CreateControlFromVirtual(
            control:GetName() .. "Highlight", control,
            "ZO_ThinListHighlight" )
        highlightControl:SetAnchorFill()
        control.highlight = highlightControl
    end
    control.highlight:SetTexture(
        "/esoui/art/buttons/selection_highlight.dds" )
    control.highlight:SetHidden( not selected )
    control.highlight:SetAlpha( 1 )
    control.highlight:SetColor( 1, 0.84, 0 )

    if selected then
        if data.name == "New Note" then
            GW_NotePad_NoteTitle_Box:SetText( "" )
        else
            GW_NotePad_NoteTitle_Box:SetText( data.name )
            GW_NotePad_ComposeScrollContainer_Box:SetText( data.content )
        end
    end
end
function CategoryIconHeader_OnInitialized( self )
    ZO_IconHeader_OnInitialized( self )
    self.icon = self:GetNamedChild( "Icon" )
    self.iconHighlight = self.icon:GetNamedChild( "Highlight" )
    self.text = self:GetNamedChild( "Text" )

    self.OnMouseEnter = ZO_IconHeader_OnMouseEnter
    self.OnMouseExit = ZO_IconHeader_OnMouseExit
    self.OnMouseUp = ZO_IconHeader_OnMouseUp

    self.animationTemplate = "IconHeaderAnimation"
end

local function OnCategoryOpened( control, data, node, button )
    local categoryName = data.name
    db.settings.lastOpenedCategory = categoryName
    local iconIndex = db.settings.notes[ data.name ].iconIndex
    local iconTable = ITTsGhostwriter.LookupIcons( iconIndex )

    if UI.lastOpenedNode then
        local lastData = UI.lastOpenedNode and UI.lastOpenedNode.data
        local lastIconIndex
        local lastIconTable

        local lastControl = UI.lastOpenedNode:GetControl()
        if db.settings.notes[ lastData.name ] then
            lastIconIndex = db.settings.notes[ lastData.name ].iconIndex
            lastIconTable = ITTsGhostwriter.LookupIcons( lastIconIndex )
        end
        if UI.lastOpenedNode == node then
            node:SetOpen( not node:IsOpen(), false )
            lastControl.icon:SetTexture( node:IsOpen() and iconTable.down or
                lastIconTable.up )
            lastControl.text:SetSelected( node:IsOpen() )
            lastControl.iconHighlight:SetHidden( not node:IsOpen() )
        else
            if db.settings.notes[ lastData.name ] then
                UI.lastOpenedNode:SetOpen( false, false )
                lastControl.iconHighlight:SetHidden( true )
                lastControl.icon:SetTexture( lastIconTable.up )
                lastControl.text:SetSelected( false )
            end
            UI.lastOpenedNode = nil
        end
    end

    if node:IsLeaf() then
        if db.settings.lastOpenedCategory == categoryName then
            node.selected = true
            control.icon:SetTexture( iconTable.down )
            control.text:SetSelected( true )
            control.iconHighlight:SetHidden( false )
        else
            control.icon:SetTexture( iconTable.up )
            control.text:SetSelected( false )
            control.iconHighlight:SetHidden( true )
        end
    end

    if node:IsOpen() then
        UI.lastOpenedNode = node
    else
        UI.lastOpenedNode = nil
    end
end
function CloseAllNodes( tree )
    logger:Log( "Closing all nodes" )
    local rootNodes = tree.rootNode:GetChildren()
    if rootNodes then
        for _, node in pairs( rootNodes ) do
            node:SetOpen( false, false )
        end
    end
    zo_callLater( function() tree:SelectAnything() end, 2000 )
end

local function TreeHeaderSetup( node, control, data, open )
    if not control then return end
    if not db.settings.notes[ data.name ] then
        logger:Log( "No category found for %s", data.name )
        return
    end
    if not control:GetNamedChild( "Icon" ) then
        local iconControl = WINDOW_MANAGER:CreateControl(
            control:GetName() .. "Icon", control, CT_TEXTURE )
        iconControl:SetAnchor( LEFT, control, LEFT )
        control.icon = iconControl
    end
    logger:Log( "TreeHeaderSetup: %s", data.name )

    local iconIndex = db.settings.notes[ data.name ].iconIndex
    local iconTable = ITTsGhostwriter.LookupIcons( iconIndex )


    if open then
        control.icon:SetTexture( iconTable.down )
    else
        control.icon:SetTexture( iconTable.up )
    end
    control.icon:GetNamedChild( "Highlight" ):SetTexture( iconTable.over )

    -- Adjust the position of the arrow icon and the header name

    local ENABLED = true
    local DISABLE_SCALING = true
    --ITTsGW_IconHeader_Setup( control, open, ENABLED, DISABLE_SCALING )
    ZO_IconHeader_Setup( control, open, ENABLED, DISABLE_SCALING )


    control.text:SetHandler( "OnMouseUp", function(
        self,
        button,
        ctrl,
        alt,
        shift,
        command )
        if button == MOUSE_BUTTON_INDEX_LEFT then
            --node:SetOpen( true, false )
            ZO_TreeHeader_OnMouseUp( control, true )
            OnCategoryOpened( control, data, node,
                              button )
            --UI.tree:ToggleNode( node )
        end
        -- Add new handler code here
        if button == MOUSE_BUTTON_INDEX_RIGHT then
            ShowContextMenu( node.data )
        end
    end )
end

function TestCategoriesAndNotes()
    -- Add a category
    local category = CM:GetCategory( "aaaa" )
    local note = category:GetNote( "test" )

    logger:Log( "Note: %s", note )
end

local nodeLogger = GWLogger:New( "AddNodes" )

local function AddNodes( tree, index )
    local categoryTable = db.settings.notes[ index ]

    if categoryTable then
        local data = {
            name = index,
            entries = categoryTable.entries,
            priority = categoryTable.priority,
            iconIndex = categoryTable.iconIndex
        }
        nodeLogger:Log( 3, "AddNodes: Adding header node %s", index )
        local headerNode = tree:AddNode( "GW_Category", data )
        data.treeNode = headerNode
        local DO_NOT_REFRESH_TREE = false
        local category = nil
        local c = CM:GetCategory( index )
        if c then
            if CM:DoesCategoryExist( index ) then
                nodeLogger:Log( 1, "AddNodes: Category %s exists", index )
                category = c
                CM:UpdateCategoryIfDifferent( index, data )
            else
                nodeLogger:Log( 2, "AddNodes: Category %s does not exist",
                                index )
                category = CM:AddCategory( data, DO_NOT_REFRESH_TREE )
            end
        else
            nodeLogger:Log( 2,
                            "AddNodes: Category %s does not exist (couldnt retrieve)",
                            index )
            category = CM:AddCategory( data, DO_NOT_REFRESH_TREE )
        end
        local headerControl = headerNode:GetControl()

        headerControl.count = headerControl:GetNamedChild( "Count" )
        headerControl.icon = headerControl:GetNamedChild( "Icon" )
        headerControl.text = headerControl:GetNamedChild( "Text" )

        headerControl.text:SetText( index )
        headerControl.icon:ClearAnchors()
        headerControl.icon:SetAnchor( LEFT, headerControl.text, LEFT, -40, 0 )
        headerControl.text:ClearAnchors()
        headerControl.text:SetAnchor( LEFT, headerControl, LEFT, 60, 0 )


        if not categoryTable.entries then
            categoryTable.entries = {}
        end

        local categoryInstance = CM:GetCategory( index )
        for title, content in pairs( categoryTable.entries ) do
            local noteData = {
                name = title,
                content = content,
                category = category
            }
            local childNode = tree:AddNode( "GW_Entry", noteData, headerNode )
            noteData.treeNode = childNode

            categoryInstance:AddNote( noteData )
            childNode:RefreshControl()
        end
        local count = CM:GetNumberOfNotesInCategory( index )
        headerControl.count:SetText( count )
        if count > 0 then
            headerControl.count:SetText( count )
            if headerControl.count:IsHidden() then
                headerControl.count:SetHidden( false )
            end
        else
            headerControl.count:SetHidden( true )
        end
        local open = false
        if not db.settings.lastOpenedCategory then
            db.settings.lastOpenedCategory =
            ""
        end
        if index == db.settings.lastOpenedCategory then
            open = true
        end
        headerNode:SetOpen( open, true )
    end
end

local function AddCategoriesToTree( tree )
    logger:Log( "AddCategoriesToTree: Adding categories to tree" )
    -- Sort the categories by priority and name
    local sortedCategories = {}
    for categoryName, categoryData in pairs( db.settings.notes ) do
        table.insert( sortedCategories, {
            name = categoryName,
            priority = categoryData.priority or 0
        } )
    end

    -- Use the helper function to sort the categories
    sortCategories( sortedCategories )

    -- Add the categories and nodes to the tree in sorted order
    for _, category in ipairs( sortedCategories ) do
        if category.name ~= "Uncategorized" then
            AddNodes( tree, category.name )
        end
    end

    -- Add "Uncategorized" category at the end
    if db.settings.notes[ "Uncategorized" ] then
        AddNodes( tree, "Uncategorized" )
    end

    tree:AddNode( "GW_NewCategory", { name = "New Category" } )
end
function UI:ClearEnabledNode( tree )
    if not tree then
        logger:Log( 4, "Error: tree is nil in UI:ClearEnabledNode" )
        return
    end

    -- Iterate over all nodes in the tree
    for _, node in ipairs( tree:GetNodes() ) do
        -- If the node is enabled, toggle it
        if node:IsEnabled() then
            node:ToggleNode()
        end
    end
end

function UI:RefreshTree( tree )
    if not tree then
        logger:Log( 4, "Error: tree is nil in UI:RefreshTree" )
        return
    end
    -- Remove all nodes
    tree:Reset()
    -- Add nodes back
    AddCategoriesToTree( tree )
    tree:RefreshVisible()
    tree:SetSuspendAnimations( false )
    logger:Log( 1, "RefreshTree: Refreshed" )
end

local function createTree()
    local scrollBackdrop = GetControl( "GW_NotePad_ScrollBackdrop" )
    local scrollContainer = WINDOW_MANAGER:CreateControlFromVirtual(
        "GW_NotePadTreeScrollContainer", scrollBackdrop,
        "ZO_ScrollContainer" )
    local padWidth = GW_NotePad:GetWidth()
    local padHeight = GW_NotePad:GetHeight()
    scrollContainer:SetAnchorFill( scrollBackdrop )
    scrollContainer:SetAnchor( TOPLEFT, scrollBackdrop, TOPLEFT )
    scrollContainer:SetAnchor( BOTTOMRIGHT, scrollBackdrop, BOTTOMRIGHT )
    local scrollContainerWidth = scrollContainer:GetWidth()
    local treeContainer = scrollContainer:GetNamedChild( "ScrollChild" )
    UI.tree = ZO_Tree:New( treeContainer, TREE_INDENT, TREE_CHILD_SPACING,
                           scrollContainerWidth )
    local tree = UI.tree
    tree:AddTemplate( "GW_Entry", TreeEntrySetup, TreeEntryOnSelected )
    tree:AddTemplate( "GW_Category", TreeHeaderSetup, OnCategoryOpened )
    tree:AddTemplate( "GW_NewCategory", TreeNewCategorySetup,
                      TreeNewCategoryOnSelected )
    AddCategoriesToTree( tree )
    tree:SetOpenAnimation( "ZO_TreeOpenAnimation" )
    tree:Commit()
    tree:SetExclusive( true )
end


----Overrides


function ITTsGW_IconHeader_OnInitialized( self )
    logger:Log( "ITTsGW_IconHeader_OnInitialized" )
    self.icon = self:GetNamedChild( "Icon" )
    self.iconHighlight = self.icon:GetNamedChild( "Highlight" )
    self.text = self:GetNamedChild( "Text" )

    self.OnMouseEnter = ZO_IconHeader_OnMouseEnter
    self.OnMouseExit = ZO_IconHeader_OnMouseExit


    self.animationTemplate = "IconHeaderAnimation"
end

function ITTsGW_IconHeader_Setup(
    control,
    open,
    enabled,
    disableScaling,
    updateSizeFunction )
    ZO_IconHeader_Setup( control, open, enabled, disableScaling,
                         updateSizeFunction )
end

function UI.UpdateShowUIButton()
    local button = GetControl( "ITTsGW_ShowNoteBookButton" )
    local offsetX = db.settings.generalSettings.chatWindowButtonOffsetX or -40
    button:ClearAnchors()
    button:SetAnchor( TOPRIGHT, ZO_ChatWindow, TOPRIGHT, offsetX, 7 )
end

local function createShowUIButton()
    local button = WINDOW_MANAGER:CreateControl( "ITTsGW_ShowNoteBookButton",
                                                 ZO_ChatWindow, CT_BUTTON )
    local offsetX = db.settings.generalSettings.chatWindowButtonOffsetX or -40
    button:SetDimensions( 32, 32 )
    button:SetAnchor( TOPRIGHT, ZO_ChatWindow, TOPRIGHT, offsetX, 7 )

    --[[  button:SetNormalTexture( "/esoui/art/tradinghouse/tradinghouse_racial_style_motif_book_up.dds" )
    button:SetPressedTexture( "/esoui/art/tradinghouse/tradinghouse_racial_style_motif_book_down.dds" )
    button:SetMouseOverTexture( "/esoui/art/tradinghouse/tradinghouse_racial_style_motif_book_over.dds" )
 ]]
    button:SetNormalTexture( "/esoui/art/treeicons/achievements_indexicon_prologue_up.dds" )
    button:SetPressedTexture( "/esoui/art/treeicons/achievements_indexicon_prologue_down.dds" )
    button:SetMouseOverTexture( "/esoui/art/treeicons/achievements_indexicon_prologue_over.dds" )
    button:SetHandler( "OnClicked", function()
        UI.ToggleUI()
    end )
end
function UI.ToggleUI()
    GW_NotePad:ToggleHidden()
end

local function createGlow()
    local glow = "/esoui/art/crafting/crafting_tooltip_glow_edge_gold64.dds"
    local edgeSize = 32
    local inset = 1
    local tileSize = 64

    local padWidth = GW_NotePad:GetWidth()
    local padHeight = GW_NotePad:GetHeight()

    local glowControl = WINDOW_MANAGER:CreateControl(
        "ITTsGhostwriterWindowGlow", GW_NotePad_BG, CT_BACKDROP )
    glowControl:SetDimensions( padWidth + edgeSize * 2,
                               padHeight + edgeSize * 2 )
    glowControl:SetAnchor( CENTER, GW_NotePad_BG, CENTER, 0, 0 )

    glowControl:SetEdgeTexture( glow, edgeSize, inset, tileSize )
    glowControl:SetCenterColor( 0, 0, 0, 0 )

    GW_NotePad_BG:SetDrawLevel( 1 )
    glowControl:SetDrawLevel( 0 )
end
-------------
--Initiallize
-------------
function UI:Initialize()
    worldName = GetWorldName()
    if not GWData[ worldName ] then GWData[ worldName ] = {} end

    db = {
        settings = ITTsGhostwriter.Vars,
        data = GWData[ worldName ]
    }
    CM = ITTsGhostwriter.CM
    createTree()
    createLabel()
    createEditBox()
    createGlow()
    createShowUIButton()
    GW_NotePad:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, db.settings.noteWindow.x, db.settings.noteWindow.y )
    GW_NotePad_Preview:SetHidden( db.settings.noteWindow.previewHidden )
    GW_NotePad_NoteTitle_Preview:SetHidden( db.settings.noteWindow
        .previewHidden )
    UpdateSizes()
    GW_NotePad:SetHidden( true )
    populateComboBox()
    noteList.CreateScrollListControl()
    noteList.CreateDataType()
    local control = GetControl( "ITTsSendMailExtension_CategoryComboBox" )
    local object = ZO_ComboBox_ObjectFromContainer( control )
    object:SelectItemByIndex( db.settings.mailComboBoxLastSelectedItemIndex or 1 )
end
