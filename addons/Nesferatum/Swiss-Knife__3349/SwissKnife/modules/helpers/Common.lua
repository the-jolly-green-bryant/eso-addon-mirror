local SK = SwissKnife
local SKDC = SK.Data.common
local SKH = SK.HelperFunctions

local function Hide(c) c:SetHidden(true); c:SetWidth(0) end

local function Show(c) c:SetHidden(false); c:SetWidth(50) end

local function Colorize(text, color)
	if not color then color = "FFFFFF" end
    text = string.format("|c%s%s|r", color, text)
    return text
end

local function getColor(val, a)
	local r, g = 0, 0
	if val >= 50 then
        r = 100-((val-50)*2);
        g = 100
    else
        r = 100;
        g = val*2
    end
	return r/100, g/100, 0, a
end

local function getQualityByValue(val, a)
    local EQ = {
        [0] = {0.65,0.65,0.65,a},
        [1] = {1,1,1,a},
        [2] = {0.17,0.77,0.05,a},
        [3] = {0.22,0.57,1,a},
        [4] = {0.62,0.18,0.96,a},
        [5] = {0.80,0.66,0.10,a}
    }
	return unpack(EQ[val])
end

local function getQuality(itemLink, a)
	return getQualityByValue(GetItemLinkFunctionalQuality(itemLink), a)
end

local function modifyItemEnchantFormatString(single, multi)
	SafeAddString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED, single, 2)
	SafeAddString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_MULTI_EFFECT, multi, 2)
end

local function getGuilds()
	local Guilds = {
		Choices = {},
		Maps = {}
	}
	for i = 1, GetNumGuilds() do
		local id = GetGuildId(i)
		local guildName = GetGuildName(id)
		Guilds.Maps[guildName] = id
		table.insert(Guilds.Choices, guildName)
    end
	return Guilds
end

local function convertTSToHMS(ts)
	local ms, s, m = 1000, 60, 60
	local tsInSeconds = math.floor(ts / ms)
	local hours = math.floor( tsInSeconds / s / m)
	local minutes = math.fmod(math.floor(tsInSeconds / s), m)
	local seconds = math.fmod(tsInSeconds, m)
	return hours, minutes, seconds
end

local function getFormattedText(text, ...)
    local args = { ... }
    local unpackedString = string.format(text, unpack(args))
    if unpackedString == "" then unpackedString = text end
    return unpackedString
end

local function getFormattedCurrency(currencyAmount, currencyType, noColor)
    currencyType = currencyType or CURT_MONEY
    noColor = noColor or false
    local formatType = ZO_CURRENCY_FORMAT_AMOUNT_ICON
    local extraOptions = {}
    if currencyAmount < 0 then
        if not noColor then formatType = ZO_CURRENCY_FORMAT_ERROR_AMOUNT_ICON end
        currencyAmount = currencyAmount * -1
    else
        if not noColor then extraOptions = { color = SK.COLOR.GREEN } end
    end
    return zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(currencyType, currencyAmount, formatType, extraOptions))
end

local function _sendMessageToChat(prefix, message)
    if LibChatMessage then
        prefix = string.gsub(prefix, ": ", "")
        if not SK.CML then SK.CML = {} end
        if not SK.CML[prefix] then SK.CML[prefix] = LibChatMessage(prefix, prefix) end
        SK.CML[prefix]:Print(message)
    else
        KEYBOARD_CHAT_SYSTEM:AddMessage(table.concat({prefix, message}))
    end
end

local function sendMessageToChat(prefix, text, ...)
    local textKey = GetString(text)
    prefix = prefix or ""
    local message = nil
    if textKey ~= nil and textKey ~= "" then
        message = getFormattedText(textKey, ...)
    else
        message = getFormattedText(text, ...)
    end
    _sendMessageToChat(prefix, message)
end

local function showAnimateText(text, duration)
    if not SKInfoText:IsHidden() then return end
    local animation, timeline = CreateSimpleAnimation(ANIMATION_ALPHA, SKInfoText)
    local width, height = 9 * string.len(text) + 15, 15
    if duration == nil then duration = 3000 end
    SKInfoText:SetDimensions(width, height)
    SKInfoTextLabel:SetWidth(width)
    SKInfoTextLabel:SetHeight(height)
    SKInfoTextLabel:SetText(text)
    SKInfoText:SetHidden(false)
    animation:SetAlphaValues(SKInfoText:GetAlpha(), 1)
    animation:SetDuration(duration)
    timeline:SetHandler("OnStop", function()
        animation, timeline = CreateSimpleAnimation(ANIMATION_ALPHA, SKInfoText)
        animation:SetAlphaValues(SKInfoText:GetAlpha(), 0)
        animation:SetDuration(duration)
        timeline:SetHandler("OnStop", function()
            SKInfoText:SetHidden(true)
        end)
        timeline:PlayFromStart()
    end)
    timeline:PlayFromStart()
end

local function objectsDeepCopy(source, destination, doNotOverwrite)
    if source ~= nil then
        for key, value in pairs(source) do
            -- Copy nested tables
            if type(value) == "table" then
                if type(destination[key]) ~= "table" then
                    destination[key] = {}
                end
                objectsDeepCopy(value, destination[key], doNotOverwrite)
            elseif key ~= "version" and type(value) ~= "function" then
                if not doNotOverwrite or destination[key] == nil then
                    destination[key] = value
                end
            end
        end
    end
end

local function isValueInList(list, value, isPartly)
    if list ~= nil and value ~= nil then
        for _, v in ipairs(list) do
            if (v == value) or (isPartly ~= nil and (value:find(v) or v:find(value))) then return true end
        end
    end
    return false
end

local function getBagName(bagId)
    if isValueInList(SKDC.BAG_HOUSE_BANKS, bagId) then
        return GetString(SI_SK_INFO_LOCATION_HOUSE_BANK)
    elseif isValueInList(SKDC.BAG_BANKS, bagId) then
        if bagId == BAG_GUILDBANK then
            return GetString(SI_SK_INFO_LOCATION_GUILD_BANK)
        else
            return GetString(SI_SK_INFO_LOCATION_BANK)
        end
    elseif bagId == BAG_WORN or bagId == BAG_COMPANION_WORN then
        return GetString(SI_SK_INFO_LOCATION_EQUIPPED)
    elseif bagId == BAG_BACKPACK then
        return GetString(SI_SK_INFO_LOCATION_INVENTORY)
    else
        return GetString(SI_SK_MESSAGE_UNKNOWN)
    end
end

local function getOwnerName(ownerId, bagId)
    if ownerId == SK.storageName then
        return getBagName(bagId)
    elseif string.find(ownerId, SK.companionOwnerNamePrefix) then
        local companionId, _ = string.gsub(ownerId, SK.companionOwnerNamePrefix, "", 1)
        return SKH.getCompanionNameById(tonumber(companionId)), GetString(SI_SK_COMPANION_TEXT)
    end
    return ownerId, GetString(SI_SK_CHARACTER_TEXT)
end

local function getMailIdString(mailId)
    local mailIdType = type(mailId)
    if mailIdType == "string" then
        return mailId
    elseif mailIdType == "number" then
        return zo_getSafeId64Key(mailId)
    else
        return tostring(mailId)
    end
end

local function hideSwapWeapon(flag)
    ZO_ActionBar1:GetNamedChild("KeybindBG"):SetHidden(flag)
    ZO_WeaponSwap_SetPermanentlyHidden(ZO_ActionBar1:GetNamedChild("WeaponSwap"), flag)
end

local function showWarningDialogue(text, title)
    if title == nil then title = '' end
    ZO_Dialogs_ShowDialog("SK_INFO_DIALOGUE", nil, {
        mainTextParams = {text},
        titleParams = {title}
    })
end

local function sortByQuantity(left, right)
    return left.quantity < right.quantity
end

-- Export helper functions
SK.HelperFunctions.Hide = Hide
SK.HelperFunctions.Show = Show
SK.HelperFunctions.Colorize = Colorize
SK.HelperFunctions.convertTSToHMS = convertTSToHMS
SK.HelperFunctions.getColor = getColor
SK.HelperFunctions.getQuality = getQuality
SK.HelperFunctions.getQualityByValue = getQualityByValue
SK.HelperFunctions.getGuilds = getGuilds
SK.HelperFunctions.showAnimateText = showAnimateText
SK.HelperFunctions.objectsDeepCopy = objectsDeepCopy
SK.HelperFunctions.modifyItemEnchantFormatString = modifyItemEnchantFormatString
SK.HelperFunctions.getFormattedText = getFormattedText
SK.HelperFunctions.getFormattedCurrency = getFormattedCurrency
SK.HelperFunctions.sendMessageToChat = sendMessageToChat
SK.HelperFunctions.isValueInList = isValueInList
SK.HelperFunctions.getMailIdString = getMailIdString
SK.HelperFunctions.getBagName = getBagName
SK.HelperFunctions.getOwnerName = getOwnerName
SK.HelperFunctions.hideSwapWeapon = hideSwapWeapon
SK.HelperFunctions.showWarningDialogue = showWarningDialogue
SK.HelperFunctions.sortByQuantity = sortByQuantity
