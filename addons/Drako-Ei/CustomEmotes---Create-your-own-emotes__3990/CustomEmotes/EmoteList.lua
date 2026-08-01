local CE = CustomEmotes
local internal = CE.internal
local LAM = LibAddonMenu2
local CONS = internal.constants

local list = {}
internal.list = list

list.listContainerReference = "CustomEmotesListSubMenuContainer"
list.customListControlReference = "CustomEmotesListCustomList"
list.savedControls = {}

function list.exportEmote(emoteName)
    local emote = CE.savedVars.emotes[emoteName]
    if emote == nil then
        return
    end

    local serialized = internal.interpreter.serialize(emote)

    internal.toggleMenu(internal.ui.settings, false)
    internal.toggleMenu(internal.ui.editor, false)
    internal.toggleMenu(internal.ui.emotes, false)
    internal.toggleMenu(internal.ui.import, true)
    internal.import.showImport(emoteName, emote.description, serialized)

end


function list.editEmoteClicked(emoteName)

    internal.toggleMenu(internal.ui.settings, false)
    internal.toggleMenu(internal.ui.editor, true)
    internal.toggleMenu(internal.ui.emotes, false)
    internal.toggleMenu(internal.ui.import, false)
    

    internal.editor.editEmoteByName(emoteName)
end

function list.deleteEmoteClicked(emoteName)

    -- If the emote is duplicated, show a dialog to confirm the action
    ESO_Dialogs["CustomEmotesDeleteDialogConfirmation"] = {
        title = { text = CONS.DELETE_CONFIRMATION_TITLE },
        mainText = { text = zo_strformat(CONS.DELETE_CONFIRMATION_TEXT, emoteName) },
        buttons = {
            [1] = {
                text = SI_DIALOG_ACCEPT,
                callback = function(dialog)
                    internal.unregisterEmoteCommand(emoteName)
                    CE.savedVars.emotes[emoteName] = nil
                    PlaySound(SOUNDS.MAIL_ITEM_DELETED)
                    --list.refreshList(_G[list.customListControlReference])
                    LAM.util.RequestRefreshIfNeeded(_G[list.listContainerReference])
                end,
            },
            [2] = {
                text = SI_DIALOG_CANCEL,
                callback = function(dialog) PlaySound(SOUNDS.GENERAL_ALERT_ERROR) end,
            },
        },
    }
    ZO_Dialogs_ShowDialog("CustomEmotesDeleteDialogConfirmation")


    
end

-- Refresh the list
function list.refreshList(parent)
    -- Clear the saved controls
    for _, control in pairs(list.savedControls) do
        control:SetHidden(true)
    end

    -- Iterate over the emotes
    local index = 1
    for emoteName, emote in pairs(CE.savedVars.emotes) do
        local yOffset = (index - 1) * 30

        -- Create the delete button
        local deleteButtonName = "$(parent)listedEmoteDeleteButton" .. emoteName
        local deleteButton = list.savedControls[deleteButtonName]
        if deleteButton == nil then
            deleteButton = WINDOW_MANAGER:CreateControlFromVirtual(deleteButtonName, parent, "ZO_DefaultButton")
            list.savedControls[deleteButtonName] = deleteButton
        end
        deleteButton:SetHeight(28)
        deleteButton:SetWidth(28)
        deleteButton:SetHidden(false)
        deleteButton:SetNormalTexture("EsoUI/Art/Buttons/decline_up.dds")
        deleteButton:SetPressedTexture("EsoUI/Art/Buttons/decline_down.dds")
        deleteButton:SetMouseOverTexture("EsoUI/Art/Buttons/decline_over.dds")
        deleteButton:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, yOffset)
        deleteButton:SetHandler("OnClicked", function()
            list.deleteEmoteClicked(emoteName)
        end)
        deleteButton:SetHandler("OnMouseEnter", function()
            InitializeTooltip(InformationTooltip, deleteButton, TOPLEFT, 0, 0)
            SetTooltipText(InformationTooltip, CONS.EMOTE_LIST_DELETE_TOOLTIP)
        end)
        deleteButton:SetHandler("OnMouseExit", function()
            ClearTooltip(InformationTooltip)
        end)

        -- Create the edit button
        local editButtonName = "$(parent)listedEmoteEditButton" .. emoteName
        local editButton = list.savedControls[editButtonName]
        if editButton == nil then
            editButton = WINDOW_MANAGER:CreateControlFromVirtual(editButtonName, parent, "ZO_DefaultButton")
            list.savedControls[editButtonName] = editButton
        end
        editButton:SetHeight(28)
        editButton:SetWidth(28)
        editButton:SetHidden(false)
        editButton:SetNormalTexture("EsoUI/Art/Buttons/edit_up.dds")
        editButton:SetPressedTexture("EsoUI/Art/Buttons/edit_down.dds")
        editButton:SetMouseOverTexture("EsoUI/Art/Buttons/edit_over.dds")
        editButton:SetAnchor(TOPLEFT, deleteButton, TOPRIGHT, 10, 0)
        editButton:SetHandler("OnClicked", function()
            list.editEmoteClicked(emoteName)
        end)
        editButton:SetHandler("OnMouseEnter", function()
            InitializeTooltip(InformationTooltip, editButton, TOPLEFT, 0, 0)
            SetTooltipText(InformationTooltip, CONS.EMOTE_LIST_EDIT_TOOLTIP)
        end)
        editButton:SetHandler("OnMouseExit", function()
            ClearTooltip(InformationTooltip)
        end)

        -- Create the label
        local labelName = "$(parent)listedEmoteLabel" .. emoteName
        local label = list.savedControls[labelName]
        if label == nil then
            label = WINDOW_MANAGER:CreateControl(labelName, parent, CT_LABEL)
            list.savedControls[labelName] = label
        end
        label:SetHeight(28)
        label:SetHidden(false)
        label:SetMouseEnabled(true)
        label:SetFont("ZoFontGame")
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetText(emoteName)
        label:SetAnchor(TOPLEFT, editButton, TOPRIGHT, 10, 0)
        label:SetHandler("OnMouseEnter", function()
            InitializeTooltip(InformationTooltip, label, TOPLEFT, 0, 0)
            SetTooltipText(InformationTooltip, emote.description)
        end)
        label:SetHandler("OnMouseExit", function()
            ClearTooltip(InformationTooltip)
        end)

        -- Create the new button with a book icon
        local bookButtonName = "$(parent)listedEmoteBookButton" .. emoteName
        local bookButton = list.savedControls[bookButtonName]
        if bookButton == nil then
            bookButton = WINDOW_MANAGER:CreateControlFromVirtual(bookButtonName, parent, "ZO_DefaultButton")
            list.savedControls[bookButtonName] = bookButton
        end
        bookButton:SetHeight(28)
        bookButton:SetWidth(28)
        bookButton:SetHidden(false)
        bookButton:SetNormalTexture("EsoUI/Art/Icons/scroll_001.dds")
        bookButton:SetPressedTexture("EsoUI/Art/Icons/scroll_002.dds")
        bookButton:SetMouseOverTexture("EsoUI/Art/Icons/scroll_001.dds")
        bookButton:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -10, yOffset)
        bookButton:SetHandler("OnClicked", function()
            list.exportEmote(emoteName)
        end)
        bookButton:SetHandler("OnMouseEnter", function()
            InitializeTooltip(InformationTooltip, bookButton, TOPLEFT, 0, 0)
            SetTooltipText(InformationTooltip, CONS.EMOTE_LIST_EXPORT_TOOLTIP)
        end)
        bookButton:SetHandler("OnMouseExit", function()
            ClearTooltip(InformationTooltip)
        end)

        index = index + 1
    end
end

-- List initialization
function list.initializeUI()
    local controls = {}

    -- Description
    table.insert(controls, {
        type = "description",
        text = CONS.EMOTE_LIST_DESCRIPTION
    })
    -- Custom control
    table.insert(controls, {
        type = "custom",
        reference = list.customListControlReference,
        createFunc = list.refreshList,
        refreshFunc = list.refreshList,
    })



    return controls
end