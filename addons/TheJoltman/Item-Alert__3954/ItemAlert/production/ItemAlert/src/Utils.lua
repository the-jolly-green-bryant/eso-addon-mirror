--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.DisplayAnnouncement(text, iconpath, duration)

	local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT)

	params:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_POI_DISCOVERED)
	params:SetText(text)
	params:SetIconData(iconpath)
	params:SetLifespanMS(duration)
	params:MarkSuppressIconFrame()

	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.GetFriendlyVersion()

	local major = math.floor(ItemAlert.Version / 10000)
    local minor = math.floor((ItemAlert.Version % 10000) / 100)
    local revision = ItemAlert.Version % 100
    
	return string.format("%d.%d.%d", major, minor, revision)

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.DisplayVersionInfo()

	-- Display the current Version of our addon and the Version of the API used to communicate to the game
	ItemAlertChat:SetTagColor("00e0ff"):Print("Version "..ItemAlert.GetFriendlyVersion()..". APIVersion "..GetAPIVersion()..". by @TheJoltman")
	
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.GetShortName(text)

	-- Return the first three letters of the passed text value
	return string.sub(ItemAlert.ProperCase(text), 1, 3)

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.ProperCase(text)

	-- Convert the passed text value to a string where each word starts with a capitolized letter followed be all lowercase
	return text:gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end)

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.ConvertRGBAToHex(r, g, b, a)

	return string.format("%.2x%.2x%.2x", zo_floor(r * 255), zo_floor(g * 255), zo_floor(b * 255)) -- ignore alpha

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.ConvertHexToRGBA(colorString)

	local r = tonumber(string.sub(colorString, 1, 2), 16) or 255
	local g = tonumber(string.sub(colorString, 3, 4), 16) or 255
	local b = tonumber(string.sub(colorString, 5, 6), 16) or 255

	local a = 255

	if string.len(colorString) == 8 then

		a = tonumber(string.sub(colorString, 7, 8), 16) or 255

	end

	return r/255, g/255, b/255, a/255

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.FormatTime(totalMinutes, noColon)

	-- Given any sum of minutes, return a (hr:mn) version as a string
	if(totalMinutes) then

		local hour = math.floor(totalMinutes / 60)
		local minute = totalMinutes % 60

		if noColon then

			return string.format("%02d %02d", hour, minute)

		else

			return string.format("%02d:%02d", hour, minute)

		end

	else

		return "00:00"

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.IsInList(number, list)

	-- Determine if the passed list contains the passed number value
	for _, value in ipairs(list) do

		if value == number then

			return true

		end

	end

	return false

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.CountElements(array)
	local count = 0
	for _ in pairs(array) do
		count = count + 1
	end
	return count
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.OkCreateDialog(Id, DialogTitle, DialogText)

	ZO_Dialogs_RegisterCustomDialog(Id, {
		title = { text = DialogTitle },
		mainText = { text = DialogText },
		buttons = {
			[1] = {
				text = "OK",
				callback = function(dialog)
					return true
				end,
			},
		},
	})

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.ToLowerCaseManual(str)

	local lowerStr = ""

	for i = 1, #str do

		local char = str:sub(i, i)
		local lowerChar = char:lower()

		lowerStr = lowerStr .. lowerChar

	end

	return lowerStr

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.Split(str, delimiter)

	local result = {}

	for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do

		table.insert(result, match)

	end

	return result

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------