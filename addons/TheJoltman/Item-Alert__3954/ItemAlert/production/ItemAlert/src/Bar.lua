--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function DisplayBarMouseEnter()

    local _, _, icon = GetCollectibleInfo(11529)

    ItemAlert.UpdateDisplayBar()

    -- Initialize a tooltip to display at the bottom of the ItemAlert.InfoText element with a slight vertical offset
    InitializeTooltip(InformationTooltip, ItemAlert.InfoText, BOTTOM, 0, -5)

    -- Create the tooltip content
    local TooltipText = "|t32:32:"..icon.."|t "..ItemAlert.FancyName.."|r"..
            "\n\n|c".."009cff".." Items:|r |c".."00e0ff"..ItemAlert.GetCharacterSetting("ItemTot")..
            "\n|c".."009cff".." Nodes:|r |c".."00e0ff"..ItemAlert.GetCharacterSetting("NodeTot")

    local sorted_items = {}

    for key, value in pairs(ItemAlert.GetCharacterSpecialItems()) do

        table.insert(sorted_items, {key = key, value = value})

    end

    table.sort(sorted_items, function(a, b)

        return a.value < b.value

    end)

    for _, item in ipairs(sorted_items) do

        TooltipText = TooltipText.."\n|c".."009cff".." "..ItemAlert.ProperCase(item.key)..":|r |c".."00e0ff"..ItemAlert.GetCharacterSpecialItemDetail(item.key, "total")

    end

    TooltipText = TooltipText.."\n\n|c".."009cff".." Time Elapsed (h:m):|r |c".."00e0ff"..ItemAlert.FormatTime(ItemAlert.GetCharacterSetting("MinutesTot")).."|r"

    -- Bind the text to the InformationTooltip object
    SetTooltipText(InformationTooltip, TooltipText)

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function DisplayBarMouseExit()

    -- Remove the tooltip box
    ClearTooltip(InformationTooltip)

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.InitializeDisplayBar()

    if not ItemAlert.GetAccountSetting("ShowDisplayBar") == true then return end

    -- Create Display Bar Text
    ItemAlert.InfoText:ClearAnchors()
    ItemAlert.InfoText:SetDimensions(0, 0)
    ItemAlert.InfoText:SetAnchor(ItemAlert.GetAccountSetting("Point"), GuiRoot, nil, ItemAlert.GetAccountSetting("X"), ItemAlert.GetAccountSetting("Y"))
    ItemAlert.InfoText.Text = ItemAlert.Window:CreateControl("ItemAlert.InfoText", ItemAlert.InfoText, CT_LABEL)
    ItemAlert.InfoText.Text:SetAnchor(CENTER,ItemAlert.InfoText, CENTER, 0, 0)
    ItemAlert.InfoText.Text:SetFont(ItemAlertLf.GetFontByFriendlyName(ItemAlert.GetAccountSetting("FontStyle")).."|"..ItemAlert.GetAccountSetting("FontSize").."|shadow")

    -- Add semi-transparent background
    ItemAlert.InfoText.background = WINDOW_MANAGER:CreateControl(nil, ItemAlert.InfoText, CT_BACKDROP)
    ItemAlert.InfoText.background:SetAnchorFill(ItemAlert.InfoText)
    ItemAlert.InfoText.background:SetEdgeColor(0, 0, 0, 0)
    ItemAlert.InfoText.background:SetCenterColor(tonumber(ItemAlert.GetAccountSetting("BackgroundColorR")), tonumber(ItemAlert.GetAccountSetting("BackgroundColorG")), tonumber(ItemAlert.GetAccountSetting("BackgroundColorB")), tonumber(ItemAlert.GetAccountSetting("BackgroundColorA")))

    -- Clamp Main Frame To Screen
    ItemAlert.InfoText:SetClampedToScreen(true)

    -- Create mouse event handlers
    ItemAlert.InfoText:SetHandler("OnMouseEnter", DisplayBarMouseEnter)
    ItemAlert.InfoText:SetHandler("OnMouseExit", DisplayBarMouseExit)

    -- Prevent interaction with the control at this time
    ItemAlert.Lock()
    ItemAlert.HideDisplayBar()

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.ShowDisplayBar()

    if not ItemAlert.GetAccountSetting("ShowDisplayBar") then return end

    ItemAlert.InfoText:SetHidden(false)

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.HideDisplayBar()

    ItemAlert.InfoText:SetHidden(true)

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.UpdateDisplayBar()

    if not ItemAlert.GetAccountSetting("ShowDisplayBar") == true then return end

    -- Set our background color for the display bar
    ItemAlert.InfoText.background:SetCenterColor(tonumber(ItemAlert.GetAccountSetting("BackgroundColorR")), tonumber(ItemAlert.GetAccountSetting("BackgroundColorG")), tonumber(ItemAlert.GetAccountSetting("BackgroundColorB")), tonumber(ItemAlert.GetAccountSetting("BackgroundColorA")))

    -- Create the text to be displayed in the display bar
    local text = ""
    local fontSizeW = tonumber(ItemAlert.GetAccountSetting("FontSize")) + 4
    local fontSizeH = tonumber(ItemAlert.GetAccountSetting("FontSize")) + 4

    if ItemAlert.GetAccountSetting("DisplayItemTotal") == true then text = text.."|t"..fontSizeW..":"..fontSizeH..":/esoui/art/icons/housing_gen_con_housingchest004.dds|t"

        if ItemAlert.GetAccountSetting("FontSpacing") == "Normal" then

            if ItemAlert.GetAccountSetting("DisplayText") == true then

                if ItemAlert.GetAccountSetting("Punctuation") == true then

                    text = text.."|c"..ItemAlert.GetAccountSetting("TextColor").." Items:"

                else

                    text = text.."|c"..ItemAlert.GetAccountSetting("TextColor").." Items "

                end

            end

            text = text.."|r |c"..ItemAlert.GetAccountSetting("TotalsColor")..ItemAlert.GetCharacterSetting("ItemTot").."  "

        else

            if ItemAlert.GetAccountSetting("DisplayText") == true then

                if ItemAlert.GetAccountSetting("Punctuation") == true then

                    text = text.."|c"..ItemAlert.GetAccountSetting("TextColor").."Items:"

                else

                    text = text.."|c"..ItemAlert.GetAccountSetting("TextColor").."Items "

                end

            end

            text = text.."|r|c"..ItemAlert.GetAccountSetting("TotalsColor")..ItemAlert.GetCharacterSetting("ItemTot").." "

        end

    end

    if ItemAlert.GetAccountSetting("DisplayNodeTotal") == true then text = text.."|r|t"..fontSizeW..":"..fontSizeH..":/esoui/art/icons/justice_stolen_tool_001.dds|t"

        if ItemAlert.GetAccountSetting("FontSpacing") == "Normal" then

            if ItemAlert.GetAccountSetting("DisplayText") == true then

                if ItemAlert.GetAccountSetting("Punctuation") == true then

                    text = text.."|c"..ItemAlert.GetAccountSetting("TextColor").." Nodes:"

                else

                    text = text.."|c"..ItemAlert.GetAccountSetting("TextColor").." Nodes "

                end

            end

            text = text.."|r |c"..ItemAlert.GetAccountSetting("TotalsColor")..ItemAlert.GetCharacterSetting("NodeTot").."  "

        else

            if ItemAlert.GetAccountSetting("DisplayText") == true then

                if ItemAlert.GetAccountSetting("Punctuation") == true then

                    text = text.."|c"..ItemAlert.GetAccountSetting("TextColor").."Nodes:"

                else

                    text = text.."|c"..ItemAlert.GetAccountSetting("TextColor").."Nodes "

                end

            end

            text = text.."|r|c"..ItemAlert.GetAccountSetting("TotalsColor")..ItemAlert.GetCharacterSetting("NodeTot").." "

        end

    end

    local sorted_items = {}

    for key, value in pairs(ItemAlert.GetAccountSpecialItems()) do

        table.insert(sorted_items, {key = key, value = value})

    end

    table.sort(sorted_items, function(a, b)

        return a.value < b.value

    end)

    for _, item in ipairs(sorted_items) do

        if ItemAlert.GetAccountSpecialItemDetail(item.key, "display") == true then

            local iconPath

            if ItemAlert.GetAccountSpecialItemDetail(item.key, "iconpath") then

                iconPath = ItemAlert.GetAccountSpecialItemDetail(item.key, "iconpath")

            else

                iconPath = GetItemLinkIcon(ItemAlert.GetAccountSpecialItemDetail(item.key, "itemname"))

            end

            if ItemAlert.GetAccountSetting("FontSpacing") == "Normal" then

                text = text.."|r|t"..fontSizeW..":"..fontSizeH..":"..iconPath.."|t"

                if ItemAlert.GetAccountSetting("DisplayText") == true then

                    if ItemAlert.GetAccountSetting("Punctuation") == true then

                        text = text.." |c"..ItemAlert.GetAccountSetting("TextColor")..ItemAlert.GetAccountSpecialItemDetail(item.key, "displayname")..":"

                    else

                        text = text.." |c"..ItemAlert.GetAccountSetting("TextColor")..ItemAlert.GetAccountSpecialItemDetail(item.key, "displayname").." "

                    end

                end

                text = text.." |r|c"..ItemAlert.GetAccountSetting("TotalsColor")..ItemAlert.GetCharacterSpecialItemDetail(item.key, "total")

                text = text.."   "

            else

                text = text.."|r|t"..fontSizeW..":"..fontSizeH..":"..iconPath.."|t"

                if ItemAlert.GetAccountSetting("DisplayText") == true then

                    if ItemAlert.GetAccountSetting("Punctuation") == true then

                        text = text.."|c"..ItemAlert.GetAccountSetting("TextColor")..ItemAlert.GetAccountSpecialItemDetail(item.key, "displayname")..":"

                    else

                        text = text.."|c"..ItemAlert.GetAccountSetting("TextColor")..ItemAlert.GetAccountSpecialItemDetail(item.key, "displayname").." "

                    end

                end

                text = text.."|r|c"..ItemAlert.GetAccountSetting("TotalsColor")..ItemAlert.GetCharacterSpecialItemDetail(item.key, "total")

                text = text.." "

            end

        end

    end

    local minTotal = ItemAlert.GetCharacterSetting("MinutesTot")
    minTotal = minTotal + (os.clock() - ItemAlert.StartTime) / 60
    ItemAlert.UpdateCharacterSetting("MinutesTot", minTotal)
    ItemAlert.StartTime = os.clock()

    if ItemAlert.GetAccountSetting("DisplayMinutes") == true then text = text.."|r|t"..fontSizeW..":"..fontSizeH..":/esoui/art/icons/housing_els_duc_sealkoshhourglasshalfsize001.dds|t"

        if ItemAlert.GetAccountSetting("FontSpacing") == "Normal" then

            if ItemAlert.GetAccountSetting("Punctuation") == true then

                if ItemAlert.GetAccountSetting("DisplayText") == true then

                    text = text.."|c"..ItemAlert.GetAccountSetting("TextColor").." ET(h:m): "

                end

                text = text.."|r|c"..ItemAlert.GetAccountSetting("TotalsColor")..ItemAlert.FormatTime(minTotal)

            else

                if ItemAlert.GetAccountSetting("DisplayText") == true then

                    text = text.."|c"..ItemAlert.GetAccountSetting("TextColor").." ET hm "

                end

                text = text.."|r|c"..ItemAlert.GetAccountSetting("TotalsColor")..ItemAlert.FormatTime(minTotal, true)

            end

        else

            if ItemAlert.GetAccountSetting("Punctuation") == true then

                if ItemAlert.GetAccountSetting("DisplayText") == true then

                    text = text.."|c"..ItemAlert.GetAccountSetting("TextColor").."ET(h:m):"

                end

                text = text.."|r|c"..ItemAlert.GetAccountSetting("TotalsColor")..ItemAlert.FormatTime(minTotal)

            else

                if ItemAlert.GetAccountSetting("DisplayText") == true then

                    text = text.."|c"..ItemAlert.GetAccountSetting("TextColor").."ET "

                end

                text = text.."|r|c"..ItemAlert.GetAccountSetting("TotalsColor")..ItemAlert.FormatTime(minTotal, true)

            end

        end

    end

    text = text.."|r"

    -- Populate our display bar
    ItemAlert.InfoText.Text:SetFont(ItemAlertLf.GetFontByFriendlyName(ItemAlert.GetAccountSetting("FontStyle")).."|"..ItemAlert.GetAccountSetting("FontSize").."|shadow")
    ItemAlert.InfoText.Text:SetText(text)

    -- Set the display bar width and height to be slightly larger than the text within it
    local width, height = ItemAlert.InfoText.Text:GetTextDimensions()
    ItemAlert.InfoText:SetDimensions(width + 8, height + 8)

    ItemAlert.UpdatePosition()

    ItemAlert.SaveAccountSettings()

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.UpdatePosition()

    if(ItemAlert.GetAccountSetting("ShowDisplayBar")) == true then

        -- Check if the display bar has moved and update the position information
        local validAnchor, point, relativeTo, relativePoint, offSetX, offSetY = ItemAlert.InfoText:GetAnchor()

        if(offSetX ~= ItemAlert.GetAccountSetting("X") or offSetY ~= ItemAlert.GetAccountSetting("Y")) then

            ItemAlert.UpdateAccountSetting("X", offSetX)
            ItemAlert.UpdateAccountSetting("Y", offSetY)
            ItemAlert.UpdateAccountSetting("Point", point)

            if(relativePoint ~= nil) then

                ItemAlert.UpdateAccountSetting("RPoint", relativePoint)

            end

        end

        if ItemAlert.GetAccountSetting("ForceCenter") == true then

            local screenWidth, screenHeight = GuiRoot:GetDimensions()


            ItemAlert.InfoText:ClearAnchors()

            if offSetX < 0 then

                ItemAlert.InfoText:SetAnchor(point, GuiRoot, relativePoint, -(screenWidth / 2) + (ItemAlert.InfoText.Text:GetWidth() /  2), offSetY)

            else

                ItemAlert.InfoText:SetAnchor(point, GuiRoot, relativePoint, (screenWidth / 2) - (ItemAlert.InfoText.Text:GetWidth() /  2), offSetY)

            end

        end

    end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.CheckScreenSizeChanged(prevWidth)

    local screenWidth, screenHeight = GuiRoot:GetDimensions()

    if screenWidth ~= prevWidth then

        -- Recenter the control horizontally
        ItemAlert.UpdatePosition()

    else

        zo_callLater(function() ItemAlert.CheckScreenSizeChanged(screenWidth) end, 100)

    end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.Lock()

    -- Lock the display bar at its current position
    if ItemAlert.GetAccountSetting("Lock") then

        ItemAlert.InfoText:SetMovable(false)
        ItemAlert.InfoText:SetMouseEnabled(true)

    else

        ItemAlert.InfoText:SetMovable(true)
        ItemAlert.InfoText:SetMouseEnabled(true)

    end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------