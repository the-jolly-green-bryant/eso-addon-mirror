local addon = BureauOfPrivateDispatches
local private = addon.private
local CONFIG = addon.config

local GetString = GetString
local d = d
local select = select
local type = type
local tostring = tostring
local unpack = unpack
local stringformat = string.format
local stringbyte = string.byte
local stringsub = string.sub
local stringupper = string.upper
local mathfloor = math.floor

local CHAT_PREFIX = "|c6FCB9F[Bureau Of Private Dispatches]|r: "

local function FormatLocalizedText(stringId, ...)
	local localizedText = GetString(stringId)
	if select("#", ...) > 0 then
		return stringformat(localizedText, ...)
	end
	return localizedText
end

local function ChatInfo(stringId, ...)
	d(CHAT_PREFIX .. FormatLocalizedText(stringId, ...))
end

local function BuildFont(face, size)
	return stringformat("%s|%d|%s", face, size, CONFIG.FONT_STYLE)
end

-- Convert rich chat markup into a safe one-line preview.
local function CleanMessageText(text)
	local cleaned = tostring(text or "")
	cleaned = zo_strgsub(cleaned, "|H.-|h(.-)|h", "%1")
	cleaned = zo_strgsub(cleaned, "|t.-|t", "")
	cleaned = zo_strgsub(cleaned, "|c%x%x%x%x%x%x", "")
	cleaned = zo_strgsub(cleaned, "|r", "")
	cleaned = zo_strgsub(cleaned, "|", "")
	cleaned = zo_strgsub(cleaned, "[\r\n\t]+", " ")
	cleaned = zo_strgsub(cleaned, "%s%s+", " ")
	return zo_strtrim(cleaned)
end

local ELLIPSIS = "..."
local ELLIPSIS_CHARACTERS = 3

-- Return at most maxCharacters UTF-8 code points without cutting a multibyte
-- sequence. Malformed input stops at the last valid boundary.
local function Utf8Prefix(text, maxCharacters, withoutEllipsis)
	if type(text) ~= "string" then
		text = tostring(text or "")
	end

	if type(maxCharacters) ~= "number" or maxCharacters ~= maxCharacters or maxCharacters < 1 then
		return ""
	end
	maxCharacters = mathfloor(maxCharacters)

	local byteLength = #text
	if byteLength == 0 then
		return text
	end

	local clipCharacters = maxCharacters
	if not withoutEllipsis and maxCharacters > ELLIPSIS_CHARACTERS then
		clipCharacters = maxCharacters - ELLIPSIS_CHARACTERS
	end

	local byteIndex = 1
	local characterCount = 0
	local clipByteIndex = nil

	while byteIndex <= byteLength and characterCount < maxCharacters do
		local leadingByte = stringbyte(text, byteIndex)
		local characterBytes = 1

		if leadingByte >= 240 then
			characterBytes = 4
		elseif leadingByte >= 224 then
			characterBytes = 3
		elseif leadingByte >= 192 then
			characterBytes = 2
		elseif leadingByte >= 128 then
			break
		end

		if byteIndex + characterBytes - 1 > byteLength then
			break
		end

		local isWellFormed = true
		for offset = 1, characterBytes - 1 do
			local continuationByte = stringbyte(text, byteIndex + offset)
			if not continuationByte or continuationByte < 128 or continuationByte > 191 then
				isWellFormed = false
				break
			end
		end

		if not isWellFormed then
			break
		end

		byteIndex = byteIndex + characterBytes
		characterCount = characterCount + 1

		if characterCount == clipCharacters then
			clipByteIndex = byteIndex
		end
	end

	if byteIndex <= byteLength then
		if withoutEllipsis then
			return stringsub(text, 1, byteIndex - 1)
		end

		local cutByteIndex = clipByteIndex or byteIndex
		return stringsub(text, 1, cutByteIndex - 1) .. ELLIPSIS
	end

	return stringsub(text, 1, byteIndex - 1)
end

local function ResolveSenderHue(senderId)
	local hues = CONFIG.SENDER_HUES
	local hueCount = #hues
	if hueCount == 0 then
		return CONFIG.ACCENT_COLOR
	end

	local hash = 0
	for byteIndex = 1, #senderId do
		hash = (hash + stringbyte(senderId, byteIndex) * byteIndex) % 65536
	end

	return hues[(hash % hueCount) + 1]
end

local function ResolveSenderInitial(senderId)
	local trimmed = zo_strgsub(senderId, "^@+", "")
	if trimmed == "" then
		trimmed = senderId
	end

	local initial = Utf8Prefix(trimmed, 1, true)
	if initial == "" then
		return "?"
	end

	if #initial == 1 then
		local byte = stringbyte(initial)
		if byte ~= nil and byte < 128 then
			return stringupper(initial)
		end
	end

	return initial
end

local function FormatElapsed(elapsedMilliseconds)
	if type(elapsedMilliseconds) ~= "number" or elapsedMilliseconds ~= elapsedMilliseconds then
		return ""
	end

	if elapsedMilliseconds < 0 then
		elapsedMilliseconds = 0
	end

	local seconds = mathfloor(elapsedMilliseconds / 1000)
	if seconds < 5 then
		return GetString(SI_BPD_TIME_NOW)
	end

	if seconds < 60 then
		return FormatLocalizedText(SI_BPD_TIME_SECONDS, seconds)
	end

	local minutes = mathfloor(seconds / 60)
	if minutes < 60 then
		return FormatLocalizedText(SI_BPD_TIME_MINUTES, minutes)
	end

	local hours = mathfloor(minutes / 60)
	return FormatLocalizedText(SI_BPD_TIME_HOURS, hours)
end

local function SetControlColor(control, color)
	control:SetColor(unpack(color))
end

private.FormatLocalizedText = FormatLocalizedText
private.ChatInfo = ChatInfo
private.BuildFont = BuildFont
private.CleanMessageText = CleanMessageText
private.Utf8Prefix = Utf8Prefix
private.ResolveSenderHue = ResolveSenderHue
private.ResolveSenderInitial = ResolveSenderInitial
private.FormatElapsed = FormatElapsed
private.SetControlColor = SetControlColor