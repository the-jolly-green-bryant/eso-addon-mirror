--TODO:
--UI to be able to set SALE_PERCENTAGE
--Table to store multiple mails.
--Save mail stats between loads
--Button to reset mail stats

--Stores names of all registered people who have sent in mats
local SenderNames = {}
--Stores total value of mats sent in per person
local SenderValues = {}
--Stores the number of senders
local numSenders = 0
--Stores Id of all mails already checked to make sure nothing is counted multiple times
local CheckedMail = {}
local numCheckedMail = 0

local AddonEnabled = true
local FirstDisplayCredits = false
local PrintAfterEveryMail = true
local PrintEachItem = true

--Calculates what percentile price to use
local SALE_PERCENTAGE = 0.50

-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
MatCalc = {}

--Easier way to RegisterForEvent
MatCalc.name = "MatCalc"

function MatCalc.ResetTables()
    resetWarned = false
    d("Reseting Tables!")
    --Set tables back to default
    senderNames = {}
    senderValues = {}
    numSenders = 0
    CheckedMail = {}
    numCheckedMail = 0
    --And set them up in the way that doesnt break everything.
    SenderNames[0] = "SenderNames"
    SenderValues[0] = 0
    CheckedMail[0] = 0
end


function MatCalc.EnableAddon()
    if(AddonEnabled) then
        d("Addon is already enabled")
    else
        d("Enabled MatCalc")
        AddonEnabled = true
    end
end

function MatCalc.DisableAddon()
    if(AddonEnabled) then 
        d("Disabled MatCalc")
        AddonEnabled = false
    else
        d("Addon is already disabled")
    end
end

function MatCalc.Toggle()
    if(AddonEnabled) then
        MatCalc.DisableAddon()
    else
        MatCalc.EnableAddon()
    end
end

function MatCalc.DisplayHelp()
    d("'/matcalc help' to display these messages")
    d("'/matcalc on' to turn on the addon")
    d("'/matcalc off' to turn off the addon")
    d("'/matcalc toggle' to turn on the addon")
    d("'/matcalc print' to print the list of senders and their values")
    d("'/matcalc printtoggle' to toggle printing after every mail checked")
    d("'/matcalc itemtoggle' to toggle printing data about each item")
    d("'/matcalc credits' to display the credits")
    d("'/matcalc reset' to reset addon")
    d("Shortcuts include '/cmc', and '/mc'")
end

function MatCalc.PrintToggle()
    if(PrintAfterEveryMail) then
        PrintAfterEveryMail = false
        d("Addon will not print after each mail now.")
        d("Use '/matcalc print' to print the list, or toggle printing back on")
    else
        PrintAfterEveryMail = true
        d("Addon will now print after each mail.")
        d("Use '/matcalc printtoggle' to turn automatic printing off")
    end
end

function MatCalc.ItemToggle()
    if(PrintEachItem) then
        PrintEachItem = false
        d("Addon will not print info about each item now.")
        d("Use '/matcalc itemtoggle' to show prices for each item")
    else
        PrintEachItem = true
        d("Addon will now print info about each item.")
        d("Use '/matcalc itemtoggle' to stop showing info")
    end
end

function MatCalc.CommandHandler(extra)
    if(FirstDisplayCredits == false) then
        --On first comand run display addon loaded, and credits.
        MatCalc.FirstDisplayCredits()
    end
    --conver string to lower
    extra = string.lower(extra)

    if(extra == "on") then
        MatCalc.EnableAddon()
    elseif(extra == "off") then
        MatCalc.DisableAddon()
    elseif(extra == "toggle") then
        MatCalc.Toggle()
    elseif(extra == "help") then
        MatCalc.DisplayHelp()
    elseif(extra == "credits") then
        MatCalc.DisplayCredits()
    elseif(extra == "print") then
        MatCalc.PrintTable()
    elseif(extra == "printtoggle") then
        MatCalc.PrintToggle()
    elseif(extra == "itemtoggle") then
        MatCalc.ItemToggle()
    elseif(extra == "reset") then
        if(resetWarned) then
            MatCalc.ResetTables()
        else
            resetWarned = true
            d("Warning! this will delete all mails, senders, and their values!")
            d("Do '/matcalc reset' again to confirm!")
        end
    elseif(extra == "hammer") then
        d("U cant touch this!")
    elseif(extra == "") then
        MatCalc.DisplayHelp()
    else
        d("Command not recognized, do '/matcalc help' for list of commands")
    end
end

SLASH_COMMANDS["/matcalc"] = MatCalc.CommandHandler
SLASH_COMMANDS["/cmc"] = MatCalc.CommandHandler
SLASH_COMMANDS["/mc"] = MatCalc.CommandHandler

function MatCalc.PriceAddGold(price)
    --vars to append the gold symbol to the price
    local currencyType = CURT_MONEY
    local formatType = ZO_CURRENCY_FORMAT_WHITE_AMOUNT_ICON
    local currencyString = zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(currencyType, price, formatType))
    return currencyString
end

function MatCalc.PrintTable()
    --Print loop through the tables and print them
    for i=0,numSenders do
        local goldValue = SenderValues[i]
        if(goldValue ~= 0) then
            goldValue = MatCalc.PriceAddGold(goldValue)
            local text = SenderNames[i] .. ": " .. goldValue
            d(text)
        end
    end
end

function MatCalc.getSenderIndex(senderDisplayName)
    --return the index of the sender in the table
    for i=0,numSenders do
        if(SenderNames[i] == senderDisplayName) then
            return i
        end
    end
    d("If you can see this please tell @Claymourn")
    return 0
end

function MatCalc.isSenderInTable(senderDisplayName)
    --return boolean based on if they can find the user in the table
    for i=0,numSenders do
        if(SenderNames[i] == senderDisplayName) then
            return true
        end
    end
    return false
end

function MatCalc.GetTTCPrices(itemLink)
    local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
    --Check to make sure prices are valid first.
    local foundPrices = true
    if(priceInfo == nil) then
        foundPrices = false
    end
    if(foundPrices) then
        local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
        local SuggestedPrice = priceInfo.SuggestedPrice
        local Avg = priceInfo.Avg
        return SuggestedPrice, Avg
    else
        --Only way the item will not have a SuggestedPrice is if it isnt a mat or something crazy
        --Therefore have no value
        d("No prices found for item!")
        return 0, 0
    end
end

function MatCalc.calculatePrice(itemLink)
    local SuggestedPrice, Avg = MatCalc.GetTTCPrices(itemLink)
    if (SuggestedPrice == nil) then
        --Make sure not to return a nil
        d("No recommendedPrice, returning averagePrice")
        return Avg
    end
    local price = SuggestedPrice * 1.25
    price = price - SuggestedPrice
    price = price * SALE_PERCENTAGE
    price = price + SuggestedPrice
    return price
end

function MatCalc.isItemMat(ItemId)
    --Go through the MatList
    local MatList = CreateMatList:GetMatList()
    local currentCraftType = 0
    while (MatList[currentCraftType] ~= nil) do
        local currentMatType = 0
        while (MatList[currentCraftType][currentMatType] ~= nil) do
            local currentMatIndex = 0
            while (MatList[currentCraftType][currentMatType][currentMatIndex] ~= nil) do
                if(MatList[currentCraftType][currentMatType][currentMatIndex] == ItemId) then
                    --return true if found in MatList
                    return true
                end
                currentMatIndex = currentMatIndex + 1
            end
            currentMatType = currentMatType + 1
        end
        currentCraftType = currentCraftType + 1
    end
    --and false if it is not found.
    return false
end

function IsSenderHireling(senderDisplayName)
    --If there is an @ in the tag, its a player
    local TagIndex = string.find(senderDisplayName, "@")
    if(TagIndex == nil) then
        return true
    else
        return false
    end
end

function MatCalc.LinkToId(itemLink)
    --Changes link string to be just the number for the item.
    local IdStartIndex = string.find(itemLink, "item:", 0)
    local IdEndIndex = string.find(itemLink, ":", IdStartIndex+5)
    local ItemId = string.sub(itemLink,IdStartIndex+5, IdEndIndex-1)
    return ItemId
end

function MatCalc.checkMail(mailId, numAttachments, attachedMoney)
    --Initialize value for their mail to the attachedMoney amount
    local totalMailValue = attachedMoney
    --Get who sent it, used for table later.
    local senderDisplayName = GetMailItemInfo(mailId)
    --Loop through all attachments
    for i=1,numAttachments do
        local stackPrice = 0
        local textureName, stack = GetAttachedItemInfo(mailId, i, LINK_STYLE_BRACKETS)
        local itemLink = GetAttachedItemLink(mailId, i)
        if(PrintEachItem) then
            --Create final text string and print
            local text = stack .. "x " .. itemLink
            d(text)
        end
        --Cut link string to be just the item Id
        local ItemId = MatCalc.LinkToId(itemLink)
        local itemPrice = MatCalc.calculatePrice(itemLink)
        if(MatCalc.isItemMat(ItemId) ~= true) then
            --If item is not a mat it has no value
            itemPrice = 0
        end
        local newItemPrice = MatCalc.PriceAddGold(itemPrice)
        stackPrice = stack * itemPrice
        local newStackPrice = MatCalc.PriceAddGold(stackPrice)
        totalMailValue = totalMailValue + stackPrice
        if(PrintEachItem) then
            d("itemPrice: " .. newItemPrice)
            d("stackPrice: " .. newStackPrice)
        end
    end
    local newTotalMailValue = MatCalc.PriceAddGold(totalMailValue)
    if(PrintEachItem) then
        d("sender: " .. senderDisplayName)
        d("totalMailValue: " .. newTotalMailValue)
    end
    return senderDisplayName, totalMailValue
end

function MatCalc.buildTable(mailId, numAttachments, attachedMoney)
    --This function builds tables
    local senderDisplayName, totalMailValue = MatCalc.checkMail(mailId, numAttachments, attachedMoney)
    --Add mailId to its table, and increment the max
    numCheckedMail = numCheckedMail + 1
    CheckedMail[numCheckedMail] = mailId
    --Do not add hirelings to the table, that info is useless
    --Maybe reenable this in the future in a setting if they want to compare how much they get from hirelings?
    local IsHireling = false
    IsHireling = IsSenderHireling(senderDisplayName)
    if(IsHireling) then
        return
    end
    --Get if the sender has already mailed things in
    local test = false
    test = MatCalc.isSenderInTable(senderDisplayName)
    if(test) then
        --If they have, find them in the table
        local senderIndex = MatCalc.getSenderIndex(senderDisplayName)
        --and update their value
        SenderValues[senderIndex] = SenderValues[senderIndex] + totalMailValue
    else
        --add them to the table and increment the max
        numSenders = numSenders + 1
        SenderNames[numSenders] = senderDisplayName
        SenderValues[numSenders] = totalMailValue
    end
end

function MatCalc.OnMailReadable(mailId)
    local hasCheckedMail = false
    for i=0,numCheckedMail do
        if(CheckedMail[i] == mailId) then
            hasCheckedMail = true
        end
    end
    if(hasCheckedMail) then
        d("That mail has already been checked")
    else
        --detect if mail has no CoD and has attachments
        local numAttachments, attachedMoney, codAmount = GetMailAttachmentInfo(mailId)
        --Check if mail passes
        if codAmount ~= 0 then
            d("codAmount is not 0.")
        else
            if numAttachments == 0 then
                d("Mail does not have attachments.")
            else
                --Mail qualifies
                MatCalc.buildTable(mailId, numAttachments, attachedMoney)
                if(PrintAfterEveryMail) then
                    MatCalc.PrintTable()
                end
            end
        end
    end
end

function MatCalc.CheckAddonEnabled(eventCode, mailId)
    if(AddonEnabled) then
        MatCalc.OnMailReadable(mailId)
    end
end

function MatCalc.DisplayCredits()
    d("Addon written by Claymourn (@Claymourn)")
    d("Developed for MerchantHouse")
end

function MatCalc.FirstDisplayCredits(eventCode)
    FirstDisplayCredits = true
    d("MatCalc loaded")
    d("Do '/matcalc help' for list of commands")
    EVENT_MANAGER:UnregisterForEvent(MatCalc.name, EVENT_MAIL_OPEN_MAILBOX)
    MatCalc.DisplayCredits()
end

function MatCalc:Initialize()
    --The addon breaks if these arent here for some reason.
    SenderNames[0] = "SenderNames"
    SenderValues[0] = 0
    CheckedMail[0] = 0
    --Creat the MatList to filter later
    CreateMatList:CreateMatList()
    --Clicking on mail triggers this, and the rest of the addon.
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_READABLE, MatCalc.CheckAddonEnabled)
    --DisplayCredits when they open their mailbox for the first time on load
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_MAIL_OPEN_MAILBOX, MatCalc.FirstDisplayCredits)
end

function MatCalc.OnAddOnLoaded(event, addonName)
    --The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addonName == MatCalc.name then
        MatCalc:Initialize()
        --Prevent lag by doing this.
        EVENT_MANAGER:UnregisterForEvent(MatCalc.name, EVENT_ADD_ON_LOADED)
    end
end

--Run Initialize function on load
EVENT_MANAGER:RegisterForEvent(MatCalc.name, EVENT_ADD_ON_LOADED, MatCalc.OnAddOnLoaded)