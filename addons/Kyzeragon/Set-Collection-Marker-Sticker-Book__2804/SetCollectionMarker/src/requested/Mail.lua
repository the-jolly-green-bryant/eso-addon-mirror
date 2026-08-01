SetCollectionMarker = SetCollectionMarker or {}
local SCM = SetCollectionMarker
SCM.Mail = SCM.Mail or {}

---------------------------------------------------------------------
--[[
When a player whispers us with item links, store the item links for
some amount of time. When we initiate a trade with the player, either
automatically add the items or show a button that will add those
items to the trade window.
Once the item is traded, remove it from the list, in case they trade
again. We also need to deal with not putting duplicate items, and
checking that player's list for duplicate items.
]]

---------------------------------------------------------------------
-- Mail side "panel" showing players and their wanted items
---------------------------------------------------------------------
local controls = {}

local function UpdateMailUI()
    for _, control in pairs(controls) do
        control:SetHidden(true)
    end

    local wantedItems = SCM.Whisper.GetWantedItems()
    local controlIndex = 0
    local previousControl
    local maximumTextWidth = 0
    for name, _ in pairs(wantedItems) do
        local _, itemsString = SCM.Whisper.GetMatchingItems(name, false)

        -- Only do a control for it if there are actually items
        -- The GetMatchingItems call may have cleaned the data out
        if (itemsString ~= "") then
            controlIndex = controlIndex + 1
            local control = controls[controlIndex]

            -- Create control if nonexistent
            if (not control) then
                control = CreateControlFromVirtual(
                    "$(parent)Player" .. tostring(controlIndex),
                    SCM_Mail,
                    "MailPlayerTemplate",
                    "")
                table.insert(controls, control)
            end
            if (SCM.savedOptions.showMailUI) then
                control:SetHidden(false)
            end

            -- Update the control's text
            local label = control:GetNamedChild("Label")
            label:SetText(string.format("%s wants:%s",
                name,
                itemsString))

            -- Update size
            control:SetDimensions(1000, 1000)
            local textWidth = label:GetTextWidth() + 4
            control:SetHeight(label:GetTextHeight() + 4)
            if (textWidth > maximumTextWidth) then
                maximumTextWidth = textWidth
            end

            -- Update anchor
            control.recipientName = name
            if (not previousControl) then
                control:SetAnchor(TOPRIGHT, ZO_MailSend, TOPLEFT, -40)
            else
                control:SetAnchor(TOPRIGHT, previousControl, BOTTOMRIGHT, 0, 4)
            end
            previousControl = control
        end
    end

    -- Now go through the controls again and set them all to the maximum text width
    for _, control in pairs(controls) do
        control:SetWidth(maximumTextWidth + 24) -- Add a little buffer for the button
    end
end
SCM.Mail.UpdateMailUI = UpdateMailUI

local function AddItemsToMail(button)
    local name = button:GetParent().recipientName
    ClearQueuedMail()
    ZO_MailSendToField:SetText(name)
    local matches, _ = SCM.Whisper.GetMatchingItems(name, false)

    for i = 1, MAIL_MAX_ATTACHED_ITEMS do
        if (#matches > 0) then
            local slotIndex = table.remove(matches, 1) -- TODO: maybe don't remove until it's mailed away
            local itemLink = GetItemLink(BAG_BACKPACK, slotIndex, LINK_STYLE_BRACKETS)
            local itemId = GetItemLinkItemId(itemLink)
            SCM.Whisper.GetWantedItems()[name].items[itemId] = nil -- Also remove it from the original

            d(string.format("Adding %s to slot %d", itemLink, i))
            QueueItemAttachment(BAG_BACKPACK, slotIndex, i)
        end
    end

    UpdateMailUI()
end
SCM.Mail.AddItemsToMail = AddItemsToMail

---------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------
function SCM.Mail.Initialize()
    SCM_Mail:SetParent(ZO_MailSend)

    -- SCM.Whisper.GetWantedItems()["@Kyzeragon"] = {
    --     items = {
    --         [102404] = 1,
    --         [180231] = 1,
    --         [84620] = 1,
    --         [86802] = 1,
    --     },
    --     timeWhispered = GetGameTimeSeconds(),
    -- }

    -- SCM.Whisper.GetWantedItems()["Not Kyzer"] = {
    --     items = {
    --         [174633] = 1,
    --         [155052] = 1,
    --         [102144] = 1,
    --         [15746] = 1,
    --         [102176] = 1,
    --         [125826] = 1,
    --         [180231] = 1,
    --         [102374] = 1,
    --         [133095] = 1,
    --         [155103] = 1,
    --         [84620] = 1,
    --         [86802] = 1,
    --         [97237] = 1,
    --         [123446] = 1,
    --     },
    --     timeWhispered = GetGameTimeSeconds(),
    -- }

    UpdateMailUI()
end

