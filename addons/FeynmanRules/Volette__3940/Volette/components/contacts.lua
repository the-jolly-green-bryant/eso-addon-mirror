function VoletteContactsMenu.Initialize()
    table.sort(Volette.contacts.savedVariables.playerList)
    for i, text in pairs(Volette.contacts.savedVariables.playerList) do
        Volette.contacts.items[i] = {
            id = i,
            text = text,
            item = nil,
            deleted = false,
            pinned = Volette.IsInArray(Volette.contacts.savedVariables.pinned, text),
        }
    end

    Volette.contacts.RestorePosition()
    VoletteContactsMenu.RefreshList()

    local scene = SCENE_MANAGER:GetScene("friendsList")
	scene:RegisterCallback("StateChange", Volette.contacts.friendsStateChange)

end

function Volette.contacts.Enable(value)
	Volette.contacts.savedVariables.enabled = value
	if Volette.contacts.registerState ~= value then
		ZO_Dialogs_ShowDialog("VOLETTE_CONFIRM_RELOAD")
	end
end

function Volette.contacts.RestorePosition()
	if Volette.contacts.savedVariables.pos.top == nil or Volette.contacts.savedVariables.pos.left == nil then
		return
	end
	local left = Volette.contacts.savedVariables.pos.left
	local top = Volette.contacts.savedVariables.pos.top

	local screenWidth, screenHeight = GuiRoot:GetDimensions()

	if left == nil then
		left = (screenWidth / 2) - (VoletteContactsMenu:GetWidth() / 2)
	end

	if top == nil then
		top = (screenHeight / 2) - (VoletteContactsMenu:GetHeight() / 2)
	end

	VoletteContactsMenu:ClearAnchors()
	VoletteContactsMenu:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function Volette.contacts.SaveContactsMenuPosition()
	Volette.contacts.savedVariables.pos = {
		left = VoletteContactsMenu:GetLeft(),
		top = VoletteContactsMenu:GetTop()
	}
end

function Volette.contacts.setPinButtonTooltip(button)
    button:SetHandler("OnMouseEnter", function()
        local tooltipText = button.pinned and GetString(VOLETTE_CONTACTS_UNPIN_BUTTON_TOOLTIP) or GetString(VOLETTE_CONTACTS_PIN_BUTTON_TOOLTIP)
        InitializeTooltip(InformationTooltip, button, TOP, 0, 5)
        SetTooltipText(InformationTooltip, tooltipText)
    end)
end

function Volette.contacts.setPinButtonTexture(button, pinned)
    button.pinned = pinned
    if pinned then
        button:SetNormalTexture("/esoui/art/chatwindow/chat_friendsonline_up.dds")
        button:SetPressedTexture("/esoui/art/chatwindow/chat_friendsonline_down.dds")
        button:SetMouseOverTexture("/esoui/art/chatwindow/chat_friendsonline_over.dds")
    else
        button:SetNormalTexture("/esoui/art/chatwindow/chat_cs_up.dds")
        button:SetPressedTexture("/esoui/art/chatwindow/chat_cs_down.dds")
        button:SetMouseOverTexture("/esoui/art/chatwindow/chat_cs_over.dds")
    end
    button:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
end

function VoletteContactsMenu.RefreshList()

    local listContainer = VoletteContactsMenuListContainerScrollChild
    local lastNonDeletedItemIndex = nil

    table.sort(Volette.contacts.items, function (left, right)
        if left.pinned and not right.pinned then
            return true
        elseif not left.pinned and right.pinned then
            return false
        else
            return left.text < right.text
        end
    end)

    for i, itemData in pairs(Volette.contacts.items) do
        local itemText = itemData.text
        if itemData.item == nil then
            itemData.item = CreateControlFromVirtual(
                "VoletteListItemTemplate" .. itemData.id, listContainer, "VoletteListItemTemplate"
            )
            Volette.contacts.items[i].item = itemData.item
        end

        Volette.contacts.items[i].item:ClearAnchors()
        
        if not Volette.contacts.items[i].deleted then
            local itemTextLabel = itemData.item:GetNamedChild("ItemText")
            itemTextLabel:SetText(itemText)

            -- Position the item correctly in the list
            if lastNonDeletedItemIndex == nil then
                Volette.contacts.items[i].item:SetAnchor(TOPLEFT, listContainer, TOPLEFT, 0, 0)
            else
                Volette.contacts.items[i].item:SetAnchor(
                    TOPLEFT, Volette.contacts.items[lastNonDeletedItemIndex].item, BOTTOMLEFT, 0, 5
                )
            end
            lastNonDeletedItemIndex = i

            local pinButton = Volette.contacts.items[i].item:GetNamedChild("PinButton")

            if pinButton.pinned == nil then
                Volette.contacts.setPinButtonTexture(pinButton, Volette.contacts.items[i].pinned)
                Volette.contacts.setPinButtonTooltip(pinButton)
            end

            pinButton:SetHandler(
                "OnClicked",
                function()
                    Volette.contacts.items[i].pinned = not Volette.contacts.items[i].pinned
                    if Volette.contacts.items[i].pinned then
                        table.insert(Volette.contacts.savedVariables.pinned, Volette.contacts.items[i].text)
                    else
                        for j, value in ipairs(Volette.contacts.savedVariables.pinned) do
                            if value == Volette.contacts.items[i].text then
                                table.remove(Volette.contacts.savedVariables.pinned, j)
                                break
                            end
                        end
                    end
                    Volette.contacts.setPinButtonTexture(pinButton, Volette.contacts.items[i].pinned)
                    VoletteContactsMenu.RefreshList()
                end
            )

            local whisperButton = Volette.contacts.items[i].item:GetNamedChild("WhisperButton")
            whisperButton:SetHandler(
                "OnClicked",
                function()
                    StartChatInput("", CHAT_CHANNEL_WHISPER, itemText)
                end
            )

            local inviteButton = Volette.contacts.items[i].item:GetNamedChild("InviteButton")
            inviteButton:SetHandler(
                "OnClicked",
                function()
                    GroupInviteByName(itemText)
                    d(Volette.GetText(VOLETTE_CONTACTS_WAS_INVITED, itemText))
                end
            )

            local removeButton = Volette.contacts.items[i].item:GetNamedChild("RemoveButton")
            removeButton:SetHandler(
                "OnClicked",
                function()
                    Volette.contacts.RemoveItemFromList(removeButton)
                end
            )
        end
    end
end

function Volette.contacts.AddItemToList()
    local inputBox = VoletteContactsMenuInputBackdropBox
    local itemText = inputBox:GetText()
    if itemText ~= "" then
        local itemExists = false
        for i, itemData in pairs(Volette.contacts.items) do
            if itemText == itemData.text then
                if not itemData.deleted then
                    d(Volette.GetText(VOLETTE_CONTACTS_EXISTS, itemText))
                else
                    Volette.contacts.items[i].deleted = false
                    Volette.contacts.items[i].item:SetHidden(false)
                    table.insert(Volette.contacts.savedVariables.playerList, itemText)
                    table.sort(Volette.contacts.savedVariables.playerList)
                    VoletteContactsMenu.RefreshList()
                    d(Volette.GetText(VOLETTE_CONTACTS_ADDED, itemText))
                end
                itemExists = true
                break
            end
        end
        if not itemExists then
            local newId = #Volette.contacts.items + 1
            Volette.contacts.items[newId] = {
                id = newId,
                text = itemText,
                item = nil,
                deleted = false,
                pinned = false,
            }
            table.insert(Volette.contacts.savedVariables.playerList, itemText)
            table.sort(Volette.contacts.savedVariables.playerList)
            VoletteContactsMenu.RefreshList()
            d(Volette.GetText(VOLETTE_CONTACTS_ADDED, itemText))
        end
        inputBox:SetText("") -- Clear the input box after adding
    end
end

function Volette.contacts.RemoveItemFromList(button)
    local listItem = button:GetParent()
    local itemText = listItem:GetNamedChild("ItemText"):GetText()
    for i, text in ipairs(Volette.contacts.savedVariables.playerList) do
        if text == itemText then
            table.remove(Volette.contacts.savedVariables.playerList, i)
            break
        end
    end
    for i, itemData in ipairs(Volette.contacts.items) do
        if itemData.text == itemText then
            Volette.contacts.items[i].deleted = true
            Volette.contacts.items[i].item:SetHidden(true)
            break
        end
    end
    d(Volette.GetText(VOLETTE_CONTACTS_REMOVED, itemText))

    VoletteContactsMenu.RefreshList()
end

function Volette.contacts.friendsStateChange(oldState, newState)
    if newState == "shown" then
        VoletteContactsMenu:SetHidden(false)
    else
        VoletteContactsMenu:SetHidden(true)
    end
end
