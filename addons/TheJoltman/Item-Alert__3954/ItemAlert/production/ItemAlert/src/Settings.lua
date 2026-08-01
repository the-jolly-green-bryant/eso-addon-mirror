--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local AccountData = {
	SpecialItems = {}
}

local AccountSpecialItemDetails = {}

local CharacterData = {
	SpecialItems = {}
}

local CharacterSpecialItemDetails = {}

local ActiveSettings = ""
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function StringToHex(input)
  
	local hex = ""
    
	for i = 1, #input do
    
		hex = hex .. string.format("%02X", string.byte(input, i))
    
	end
    
	return hex

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function HexToString(hex)

	hex = hex:match("^%s*(%x+)%s*$") or ""
	
    -- Check if the input is a valid hexadecimal string
    if #hex % 2 ~= 0 or hex:find("[^0-9A-Fa-f]") then
	
        return nil, "HexToString: Invalid hexadecimal string"
	
    end

    local str = ""
	
    for i = 1, #hex, 2 do
	
        local byte = tonumber(hex:sub(i, i+1), 16)
		
        str = str .. string.char(byte)
		
    end
	
    return str

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Convert table to string
local function TableToString(tbl)

	local function serializeTable(t, result)

		for k, v in pairs(t) do

			if type(v) == "table" then

				table.insert(result, k .. "={" .. serializeTable(v, {}) .. "}")

			else

				local valueType = type(v)
				local typeAbbreviation = valueType == "number" and "n" or valueType == "boolean" and "b" or "s"
				local valueString = valueType == "boolean" and (v and "T" or "F") or tostring(v)

				table.insert(result, k .. "=" .. typeAbbreviation .. ":" .. valueString)

			end

		end

		return table.concat(result, "~")

	end

	return serializeTable(tbl, {})

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Convert string to table
local function StringToTable(str)

	local function parseTableContent(content)
		local subSegments = {}
		local startPos, nestLevel = 1, 0
		local inQuotes = false  -- Flag to track if we're inside quotes

		for i = 1, #content do
			local char = content:sub(i, i)

			if char == '"' then
				inQuotes = not inQuotes  -- Toggle inQuotes flag
			end

			if char == "{" then
				nestLevel = nestLevel + 1
			elseif char == "}" then
				nestLevel = nestLevel - 1
			end

			-- Check for "~" only when not inside quotes and at nestLevel 0
			if nestLevel == 0 and char == "~" and not inQuotes then
				table.insert(subSegments, content:sub(startPos, i - 1))  -- Exclude the "~"
				startPos = i + 1
			end

			-- Handle the last segment
			if i == #content and nestLevel == 0 then
				table.insert(subSegments, content:sub(startPos, i))
			end
		end

		return subSegments
	end

	local function deserializeString(s)

		local result = {}
		local segments = {}

		segments = parseTableContent(s)

		for _, segment in ipairs(segments) do

			local key, value = segment:match("([^=]+)=?(.*)")

			if value and value:find("^{") then

				local subTableContent = value:match("{(.*)}")
				result[key] = deserializeString(subTableContent)

			else

				local i = 1
				local typeAbbreviation = ""

				while i <= #value do
					local char = value:sub(i, i)
					if char == ":" then break end
					typeAbbreviation = typeAbbreviation .. char
					i = i + 1
				end

				if i > #value then
					ItemAlert.Logger:Debug("Error: Invalid data format - missing colon", segment)
					result[key] = value
				else
					local valueStr = value:sub(i + 1)

					if typeAbbreviation == "n" then
						result[key] = tonumber(valueStr)
					elseif typeAbbreviation == "b" then
						result[key] = valueStr == "T"
					else
						result[key] = valueStr:gsub("~$", "")
					end
				end
			end
		end

		return result

	end

	return deserializeString(str)

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function InvalidSettings(message)

	ItemAlertChat:SetTagColor("69EEE1"):Print(message)
	CHAT_SYSTEM:Maximize()
	ItemAlert.SetSettings(ActiveSettings)
	SCENE_MANAGER:HideCurrentScene()

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Add Item to SpecialItems
local function AddAccountSpecialItem(itemName, itemValue)

	if AccountData.SpecialItems[itemName] == nil then

		AccountData.SpecialItems[itemName] = itemValue

		ItemAlert.SaveAccountSettings()

	else

		ItemAlert.Logger:Verbose("AddCharacterSpecialItem: This item already exists in CharacterData.SpecialItems")

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Add Account wide field to AccountData root
local function AddAccountSetting(itemName, itemValue)

	if AccountData[itemName] == nil then

		AccountData[itemName] = itemValue

		ItemAlert.SaveAccountSettings()

	else

		ItemAlert.Logger:Debug("AddAccountSetting: This item already exists in AccountData")

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Add a new detail for an account special item
local function AddAccountSpecialItemDetail(itemName, key, value)

	if AccountSpecialItemDetails[itemName] == nil then

		AccountSpecialItemDetails[itemName] = {}

		ItemAlert.SaveAccountSettings()

	end

	if AccountSpecialItemDetails[itemName][key] == nil then

		AccountSpecialItemDetails[itemName][key] = value

		ItemAlert.Logger:Verbose("AddAccountSpecialItemDetail: Adding item: key '"..key.."' value '"..tostring(value).."'")

	else

		ItemAlert.Logger:Verbose("AddAccountSpecialItemDetail: Key already exists in AccountSpecialItemDetails for this item")

		return false

	end

	return true

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Add per character setting to CharacterData root
local function AddCharacterSetting(itemName, itemValue)

	if CharacterData[itemName] == nil then

		CharacterData[itemName] = itemValue

		ItemAlert.SaveCharacterSettings()

	else

		ItemAlert.Logger:Verbose("AddCharacterSetting: This item already exists in CharacterData")

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Add Item to SpecialItems
local function AddCharacterSpecialItem(itemName, itemValue)

	if CharacterData.SpecialItems[itemName] == nil then

		CharacterData.SpecialItems[itemName] = itemValue

		ItemAlert.SaveCharacterSettings()

	else

		ItemAlert.Logger:Verbose("AddCharacterSpecialItem: This item already exists in CharacterData.SpecialItems")

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Add Item to SpecialItemDetails
local function AddCharacterSpecialItemDetails(itemName, key, value)

	if CharacterSpecialItemDetails[itemName] == nil then

		CharacterSpecialItemDetails[itemName] = {}

		ItemAlert.SaveCharacterSettings()

	end

	if CharacterSpecialItemDetails[itemName][key] == nil then

		CharacterSpecialItemDetails[itemName][key] = value

	else

		ItemAlert.Logger:Verbose("AddCharacterSpecialItemDetails: Key already exists in CharacterSpecialItemDetails for this item")

		return false

	end

	return true

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update a specific detail for a per character item
local function UpdateCharacterSpecialItemDetail(itemName, key, newValue)

	if CharacterSpecialItemDetails[itemName] ~= nil then

		if CharacterSpecialItemDetails[itemName][key] ~= nil then

			CharacterSpecialItemDetails[itemName][key] = newValue

			ItemAlert.SaveCharacterSettings()

		else

			ItemAlert.Logger:Verbose("UpdateCharacterSpecialItemDetail: Key not found in CharacterSpecialItemDetails for this item")

		end

	else

		ItemAlert.Logger:Verbose("UpdateCharacterSpecialItemDetail: Item '"..itemName.."' not found in CharacterSpecialItemDetails")

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function DeepCopy(original)

	local copy = {}

	for k, v in pairs(original) do

		if type(v) == "table" then

			copy[k] = DeepCopy(v)

		else

			copy[k] = v

		end

	end

	return copy
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.InitializeSettings()

	local screenWidth, screenHeight = GuiRoot:GetDimensions()

	ItemAlert.Logger:Debug("Updating Account Settings")

	if ItemAlert.GetAccountSetting("X") == nil then AddAccountSetting("X", (0 - screenWidth / 2)) end
	if ItemAlert.GetAccountSetting("Y") == nil then AddAccountSetting("Y", (0 - screenHeight / 2)) end
	if ItemAlert.GetAccountSetting("Point") == nil then AddAccountSetting("Point", 12) end
	if ItemAlert.GetAccountSetting("RPoint") == nil then AddAccountSetting("RPoint", 12) end
	if ItemAlert.GetAccountSetting("DisplayMinutes") == nil then AddAccountSetting("DisplayMinutes", true) end
	if ItemAlert.GetAccountSetting("TextColor") == nil then AddAccountSetting("TextColor", "8f8f8f") end
	if ItemAlert.GetAccountSetting("TotalsColor") == nil then AddAccountSetting("TotalsColor", "ffffff") end
	if ItemAlert.GetAccountSetting("ForceCenter") == nil then AddAccountSetting("ForceCenter", true) end
	if ItemAlert.GetAccountSetting("FontSize") == nil then AddAccountSetting("FontSize", 20) end
	if ItemAlert.GetAccountSetting("FontSpacing") == nil then AddAccountSetting("FontSpacing", "Normal") end
	if ItemAlert.GetAccountSetting("Punctuation") == nil then AddAccountSetting("Punctuation", true) end
	if ItemAlert.GetAccountSetting("DisplayItemTotal") == nil then AddAccountSetting("DisplayItemTotal", true) end
	if ItemAlert.GetAccountSetting("DisplayText") == nil then AddAccountSetting("DisplayText", true) end
	if ItemAlert.GetAccountSetting("Lock") == nil then AddAccountSetting("Lock", false) end
	if ItemAlert.GetAccountSetting("FontStyle") == nil then AddAccountSetting("FontStyle", "ESO Standard Font") end
	if ItemAlert.GetAccountSetting("ShowDisplayBar") == nil then AddAccountSetting("ShowDisplayBar", true) end
	if ItemAlert.GetAccountSetting("DisplayNodeTotal") == nil then AddAccountSetting("DisplayNodeTotal", true) end
	if ItemAlert.GetAccountSetting("Chat") == nil then AddAccountSetting("Chat", true) end
	if ItemAlert.GetAccountSetting("Sound") == nil then AddAccountSetting("Sound", true) end
	if ItemAlert.GetAccountSetting("AlertDuration") == nil then AddAccountSetting("AlertDuration", 2.5) end
	if ItemAlert.GetAccountSetting("BackgroundColorA") == nil then AddAccountSetting("BackgroundColorA", 0.7) end
	if ItemAlert.GetAccountSetting("BackgroundColorR") == nil then AddAccountSetting("BackgroundColorR", 0) end
	if ItemAlert.GetAccountSetting("BackgroundColorG") == nil then AddAccountSetting("BackgroundColorG", 0) end
	if ItemAlert.GetAccountSetting("BackgroundColorB") == nil then AddAccountSetting("BackgroundColorB", 0) end

	-- Set defaults where we are missing required information for account data when we don't have any items saved
	if ItemAlert.CountElements(ItemAlert.GetAccountSpecialItems()) == 0 or ItemAlert.CountElements(ItemAlert.GetCharacterSpecialItems()) == 0 then

		ItemAlert.Logger:Debug("Adding missing default special items")

		AddAccountSpecialItem("luminous ink", 1)
		AddAccountSpecialItemDetail("luminous ink", "itemname", "luminous ink")
		AddAccountSpecialItemDetail("luminous ink", "displayname", "Lum")
		AddAccountSpecialItemDetail("luminous ink", "animatedisplay", true)
		AddAccountSpecialItemDetail("luminous ink", "displayscreen", true)
		AddAccountSpecialItemDetail("luminous ink", "alertduration", 2.5)
		AddAccountSpecialItemDetail("luminous ink", "soundname", "CODE_REDEMPTION_SUCCESS")
		AddAccountSpecialItemDetail("luminous ink", "volume", 2)
		AddAccountSpecialItemDetail("luminous ink", "display", true)
		AddAccountSpecialItemDetail("luminous ink", "iconpath", "/esoui/art/icons/item_grimoire_ink.dds")

		AddAccountSpecialItem("potent nirncrux", 2)
		AddAccountSpecialItemDetail("potent nirncrux", "itemname", "potent nirncrux")
		AddAccountSpecialItemDetail("potent nirncrux", "displayname", "Pot")
		AddAccountSpecialItemDetail("potent nirncrux", "animatedisplay", true)
		AddAccountSpecialItemDetail("potent nirncrux", "displayscreen", true)
		AddAccountSpecialItemDetail("potent nirncrux", "alertduration", 2.5)
		AddAccountSpecialItemDetail("potent nirncrux", "soundname", "CODE_REDEMPTION_SUCCESS")
		AddAccountSpecialItemDetail("potent nirncrux", "volume", 2)
		AddAccountSpecialItemDetail("potent nirncrux", "display", true)
		AddAccountSpecialItemDetail("potent nirncrux", "iconpath", "/esoui/art/icons/crafting_potent_nirncrux_dust.dds")

		AddAccountSpecialItem("fortified nirncrux", 3)
		AddAccountSpecialItemDetail("fortified nirncrux", "itemname", "fortified nirncrux")
		AddAccountSpecialItemDetail("fortified nirncrux", "displayname", "For")
		AddAccountSpecialItemDetail("fortified nirncrux", "animatedisplay", true)
		AddAccountSpecialItemDetail("fortified nirncrux", "displayscreen", true)
		AddAccountSpecialItemDetail("fortified nirncrux", "alertduration", 2.5)
		AddAccountSpecialItemDetail("fortified nirncrux", "soundname", "CODE_REDEMPTION_SUCCESS")
		AddAccountSpecialItemDetail("fortified nirncrux", "volume", 2)
		AddAccountSpecialItemDetail("fortified nirncrux", "display", true)
		AddAccountSpecialItemDetail("fortified nirncrux", "iconpath", "/esoui/art/icons/crafting_potent_nirncrux_stone.dds")

		AddAccountSpecialItem("aetherial dust", 4)
		AddAccountSpecialItemDetail("aetherial dust", "itemname", "aetherial dust")
		AddAccountSpecialItemDetail("aetherial dust", "displayname", "Aet")
		AddAccountSpecialItemDetail("aetherial dust", "animatedisplay", true)
		AddAccountSpecialItemDetail("aetherial dust", "displayscreen", true)
		AddAccountSpecialItemDetail("aetherial dust", "alertduration", 2.5)
		AddAccountSpecialItemDetail("aetherial dust", "soundname", "CODE_REDEMPTION_SUCCESS")
		AddAccountSpecialItemDetail("aetherial dust", "volume", 2)
		AddAccountSpecialItemDetail("aetherial dust", "display", true)
		AddAccountSpecialItemDetail("aetherial dust", "iconpath", "/esoui/art/icons/crafting_ghost_vital_glow_dust.dds")

		AddAccountSpecialItem("perfect roe", 5)
		AddAccountSpecialItemDetail("perfect roe", "itemname", "perfect roe")
		AddAccountSpecialItemDetail("perfect roe", "displayname", "Per")
		AddAccountSpecialItemDetail("perfect roe", "animatedisplay", true)
		AddAccountSpecialItemDetail("perfect roe", "displayscreen", true)
		AddAccountSpecialItemDetail("perfect roe", "alertduration", 2.5)
		AddAccountSpecialItemDetail("perfect roe", "soundname", "CODE_REDEMPTION_SUCCESS")
		AddAccountSpecialItemDetail("perfect roe", "volume", 2)
		AddAccountSpecialItemDetail("perfect roe", "display", true)
		AddAccountSpecialItemDetail("perfect roe", "iconpath", "/esoui/art/icons/crafting_heavy_armor_vendor_component_002.dds")

		AddAccountSpecialItem("hakeijo", 6)
		AddAccountSpecialItemDetail("hakeijo", "itemname", "hakeijo")
		AddAccountSpecialItemDetail("hakeijo", "displayname", "Hak")
		AddAccountSpecialItemDetail("hakeijo", "animatedisplay", true)
		AddAccountSpecialItemDetail("hakeijo", "displayscreen", true)
		AddAccountSpecialItemDetail("hakeijo", "alertduration", 2.5)
		AddAccountSpecialItemDetail("hakeijo", "soundname", "CODE_REDEMPTION_SUCCESS")
		AddAccountSpecialItemDetail("hakeijo", "volume", 2)
		AddAccountSpecialItemDetail("hakeijo", "display", true)
		AddAccountSpecialItemDetail("hakeijo", "iconpath", "/esoui/art/icons/crafting_components_runestones_058.dds")

		AddAccountSpecialItem("kuta", 7)
		AddAccountSpecialItemDetail("kuta", "itemname", "kuta")
		AddAccountSpecialItemDetail("kuta", "displayname", "Kut")
		AddAccountSpecialItemDetail("kuta", "animatedisplay", true)
		AddAccountSpecialItemDetail("kuta", "displayscreen", true)
		AddAccountSpecialItemDetail("kuta", "alertduration", 2.5)
		AddAccountSpecialItemDetail("kuta", "soundname", "CODE_REDEMPTION_SUCCESS")
		AddAccountSpecialItemDetail("kuta", "volume", 2)
		AddAccountSpecialItemDetail("kuta", "display", true)
		AddAccountSpecialItemDetail("kuta", "iconpath", "/esoui/art/icons/crafting_components_runestones_001.dds")

		ItemAlert.SaveAccountSettings()

		AddCharacterSetting("MinutesTot", 0)
		AddCharacterSetting("ItemTot", 0)
		AddCharacterSetting("NodeTot", 0)

		AddCharacterSpecialItem("luminous ink", 1)
		AddCharacterSpecialItemDetails("luminous ink", "itemname", "luminous ink")
		AddCharacterSpecialItemDetails("luminous ink", "total", 0)

		AddCharacterSpecialItem("potent nirncrux", 2)
		AddCharacterSpecialItemDetails("potent nirncrux", "itemname", "potent nirncrux")
		AddCharacterSpecialItemDetails("potent nirncrux", "total", 0)

		AddCharacterSpecialItem("fortified nirncrux", 3)
		AddCharacterSpecialItemDetails("fortified nirncrux", "itemname", "fortified nirncrux")
		AddCharacterSpecialItemDetails("fortified nirncrux", "total", 0)

		AddCharacterSpecialItem("aetherial dust", 4)
		AddCharacterSpecialItemDetails("aetherial dust", "itemname", "aetherial dust")
		AddCharacterSpecialItemDetails("aetherial dust", "total", 0)

		AddCharacterSpecialItem("perfect roe", 5)
		AddCharacterSpecialItemDetails("perfect roe", "itemname", "perfect roe")
		AddCharacterSpecialItemDetails("perfect roe", "total", 0)

		AddCharacterSpecialItem("hakeijo", 6)
		AddCharacterSpecialItemDetails("hakeijo", "itemname", "hakeijo")
		AddCharacterSpecialItemDetails("hakeijo", "total", 0)

		AddCharacterSpecialItem("kuta", 7)
		AddCharacterSpecialItemDetails("kuta", "itemname", "kuta")
		AddCharacterSpecialItemDetails("kuta", "total", 0)

		ItemAlert.SaveCharacterSettings()

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.AddItem(ItemName, ItemDisplayName, AnimateDisplay, DisplayOnScreen, AlertDuration, AlertName, AlertVolume, Visible, IconPath)

	local added = true

	ItemName = string.lower(ItemName)

	AddAccountSpecialItem(ItemName, ItemAlert.CountElements(ItemAlert.GetAccountSpecialItems()) + 1)
	AddAccountSpecialItemDetail(ItemName, "itemname", ItemName)
	AddAccountSpecialItemDetail(ItemName, "displayname", ItemDisplayName)
	AddAccountSpecialItemDetail(ItemName, "animatedisplay", AnimateDisplay)
	AddAccountSpecialItemDetail(ItemName, "displayscreen", DisplayOnScreen)
	AddAccountSpecialItemDetail(ItemName, "alertduration", AlertDuration)
	AddAccountSpecialItemDetail(ItemName, "soundname", AlertName)
	AddAccountSpecialItemDetail(ItemName, "volume", AlertVolume)
	AddAccountSpecialItemDetail(ItemName, "display", Visible)
	AddAccountSpecialItemDetail(ItemName, "iconpath", IconPath)

	AddCharacterSpecialItem(ItemName, ItemAlert.CountElements(ItemAlert.GetAccountSpecialItems()) + 1)
	AddCharacterSpecialItemDetails(ItemName, "itemname", ItemName)
	AddCharacterSpecialItemDetails(ItemName, "total", 0)

	ItemAlert.SaveAccountSettings()
	ItemAlert.SaveCharacterSettings()

	ItemAlert.UpdateDisplayBar()

	return added

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.AddItemEntries()

	-- Update our orderlistbox with the data in the special items table
	ItemAlert.SortOrderEntries = {}

	local sorted_items = {}

	for key, value in pairs(ItemAlert.GetAccountSpecialItems()) do

		table.insert(sorted_items, {key = key, value = value})

	end

	table.sort(sorted_items, function(a, b)

		return a.value < b.value

	end)

	for _, item in ipairs(sorted_items) do

		table.insert(ItemAlert.SortOrderEntries, {
			value = item.key,
			uniqueKey = item.value,
			text  = ItemAlert.ProperCase(item.key),
			iconpath = ItemAlert.GetAccountSpecialItemDetail(item.key, "iconpath"),
		})

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.LoadAccountSettings()

	-- Load existing account wide settings
	if ItemAlert.AccountData and ItemAlert.AccountData ~= "" then

		if ItemAlert.AccountData.Settings and ItemAlert.AccountData.Settings ~= "" then

			-- Convert existing account wide settings, saved as hexadecimal string, to the original string
			local originalString, err = HexToString(ItemAlert.AccountData.Settings)

			-- Decompress the settings as a table into our global account settings variable
			local str = ItemAlert.DecompressDeflate(originalString)

			local accountDataStr, accountDetailsStr = string.match(str, "AccountData={(.*)%^Details=(.*)}")

			AccountData = StringToTable(accountDataStr)
			AccountSpecialItemDetails = StringToTable(accountDetailsStr)

		end
		
	end
	
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.SaveAccountSettings()

	-- Save existing account wide settings
	if AccountData and AccountData ~= "" then

		local parsedTable = "AccountData={" .. TableToString(AccountData) .. "^Details=" .. TableToString(AccountSpecialItemDetails) .. "}"

		-- Compress the settings as a table into our global account settings variable as a hexadecimal string
		ItemAlert.AccountData.Settings = StringToHex(ItemAlert.CompressDeflate(parsedTable))

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.LoadCharacterSettings()

	-- Load existing account wide settings
	if ItemAlert.CharacterData and ItemAlert.CharacterData ~= "" then

		if ItemAlert.CharacterData.Settings and ItemAlert.CharacterData.Settings ~= "" then

			-- Convert existing per character settings, previously saved as a hexadecimal string
			local originalString, err = HexToString(ItemAlert.CharacterData.Settings)

			-- Decompress the settings as a table into our global account settings variable
			local str = ItemAlert.DecompressDeflate(originalString)

			local characterDataStr, characterDetailsStr = string.match(str, "CharacterData={(.*)%^Details=(.*)}")

			CharacterData = StringToTable(characterDataStr)

			CharacterSpecialItemDetails = StringToTable(characterDetailsStr)

		end
		
	end
	
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.SaveCharacterSettings()

	-- Save existing account wide settings
	if CharacterData and CharacterData ~= "" then

		local parsedTable = "CharacterData={" .. TableToString(CharacterData) .. "^Details=" .. TableToString(CharacterSpecialItemDetails) .. "}"

		-- Decompress the settings as a table into our global account settings variable as a hexadecimal string
		ItemAlert.CharacterData.Settings = StringToHex(ItemAlert.CompressDeflate(parsedTable))

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.GetSettings()

	ItemAlert.SaveAccountSettings()

	ActiveSettings = ItemAlert.AccountData.Settings.."^"..ItemAlert.CharacterData.Settings

	return ActiveSettings

end
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.SetSettings(value)

	if value ~= ActiveSettings then

		local result = ItemAlert.Split(value, "^")

		if #result < 2 then

			InvalidSettings("Invalid Settings: Wrong number of arguments.")
			return

		end

		if result[1] == nil or result[2] == nil then

			InvalidSettings("Invalid Settings: nil argument(s).")
			return

		end

		-- Convert existing account wide settings, saved as hexadecimal string, to the original string
		local originalString, err = HexToString(result[1])

		if originalString == nil then

			InvalidSettings("Invalid Settings: Compressed account wide setting is nil.")
			return

		end

		-- Decompress the settings as a table into our global account settings variable
		local str = ItemAlert.DecompressDeflate(originalString)

		if str == nil then

			InvalidSettings("Invalid Settings: Decompressed account wide setting is nil.")
			return

		end

		local dataStr, dataDetailsStr = string.match(str, "AccountData={(.*)%^Details=(.*)}")

		AccountData = StringToTable(dataStr)
		AccountSpecialItemDetails = StringToTable(dataDetailsStr)

		-- Convert existing per character settings, saved as hexadecimal string, to the original string
		originalString, err = HexToString(result[2])

		if originalString == nil then

			InvalidSettings("Invalid Settings: Compressed per character setting is nil.")
			return

		end

		-- Decompress the settings as a table into our global account settings variable
		str = ItemAlert.DecompressDeflate(originalString)

		if str == nil then

			InvalidSettings("Invalid Settings: Decompressed per character setting is nil.")
			return

		end

		dataStr, dataDetailsStr = string.match(str, "CharacterData={(.*)%^Details=(.*)}")

		CharacterData = StringToTable(dataStr)
		CharacterSpecialItemDetails = StringToTable(dataDetailsStr)

		ItemAlert.AddItemEntries()

 		ItemAlert.UpdateDisplayBar()

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Returns a setting from the account-wide settings
function ItemAlert.GetAccountSetting(itemName)

	if AccountData then

		return AccountData[itemName]

	else

		ItemAlert.Logger:Debug("GetAccountSetting: AccountData is empty")

		return nil

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update field in account wide settings
function ItemAlert.UpdateAccountSetting(itemName, newValue)

	if AccountData[itemName] ~= nil then

		AccountData[itemName] = newValue

		ItemAlert.SaveAccountSettings()

	else

		ItemAlert.Logger:Debug("UpdateAccountSetting: Item not found")

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Get all of the special items
function ItemAlert.GetAccountSpecialItems()

	if AccountData.SpecialItems then

		return AccountData.SpecialItems

	else

		ItemAlert.Logger:Debug("GetAccountSpecialItems: AccountData.SpecialItems is empty")

		return nil

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Get a specific detail for an account special item
function ItemAlert.GetAccountSpecialItemDetail(itemName, key)

	if AccountSpecialItemDetails[itemName] ~= nil then

		return AccountSpecialItemDetails[itemName][key]

	else

		ItemAlert.Logger:Verbose("GetAccountSpecialItemDetail: Item '"..itemName.."["..key.."]'not found in AccountSpecialItemDetails")

		return nil

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update a specific detail for an account special item
function ItemAlert.UpdateAccountSpecialItemDetail(itemName, key, newValue)

	if AccountSpecialItemDetails[itemName] ~= nil then

		if AccountSpecialItemDetails[itemName][key] ~= nil then

			AccountSpecialItemDetails[itemName][key] = newValue

			ItemAlert.SaveAccountSettings()

		else

			ItemAlert.Logger:Verbose("UpdateAccountSpecialItemDetail: Key '"..key.."' not found in AccountSpecialItemDetails for this item '"..itemName.."'")

		end

	else

		ItemAlert.Logger:Verbose("UpdateAccountSpecialItemDetail: Item not found in AccountSpecialItemDetails")

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Get all of the special items
function ItemAlert.GetCharacterSpecialItems()

	if CharacterData.SpecialItems then

		return CharacterData.SpecialItems

	else

		ItemAlert.Logger:Verbose("GetCharacterSpecialItems: CharacterData.SpecialItems is empty")

		return nil

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.GetCharacterSetting(settingName)

	if CharacterData then

		return CharacterData[settingName]

	else

		ItemAlert.Logger:Verbose("GetCharacterSetting: CharacterData is empty")

		return nil

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Update value in per character settings
function ItemAlert.UpdateCharacterSetting(setting, newValue)

	if CharacterData[setting] ~= nil then

		CharacterData[setting] = newValue

		ItemAlert.SaveCharacterSettings()

	else

		ItemAlert.Logger:Verbose("UpdateCharacterSetting: Item not found '"..setting.."'")

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Get a specific detail for an per character special item
function ItemAlert.GetCharacterSpecialItemDetail(itemName, key)

	if CharacterSpecialItemDetails[itemName] ~= nil then

		return CharacterSpecialItemDetails[itemName][key]

	else

		ItemAlert.Logger:Verbose("GetCharacterSpecialItemDetail: Item '"..itemName.."' not found in CharacterSpecialItemDetails")
		AddCharacterSpecialItemDetails(itemName, "total", 0)
		return CharacterSpecialItemDetails[itemName][key]

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Get a specific value for a per character setting
function ItemAlert.GetCharacterSpecialItem(settingName)

	if CharacterData[settingName] ~= nil then

		return CharacterData[settingName]

	else

		ItemAlert.Logger:Verbose("GetCharacterSpecialItem: Setting not found in CharacterData")

		return nil

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.AddItemQuantity(itemName, quantity)

	for q, r in pairs(CharacterSpecialItemDetails) do

		if string.match(itemName, q) ~= nil then

			UpdateCharacterSpecialItemDetail(itemName, "total", ItemAlert.GetCharacterSpecialItemDetail(itemName, "total") + quantity)

			ItemAlert.SaveCharacterSettings()

			break

		end

	end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.UpdateItemEntries(sortedSortListEntries)

	ItemAlert.Status = "UpdateItemEntries"

	local bFound
	local specialItems = DeepCopy(AccountData.SpecialItems)
	local specialItemTotals = DeepCopy(CharacterData.SpecialItems)
	local accountSpecialItemDetails = DeepCopy(AccountSpecialItemDetails)
	local characterSpecialItemDetails = DeepCopy(CharacterSpecialItemDetails)

	-- Clear out our special item and special item totals. The repopulate them in our orderlistbax control
	for k in pairs (AccountData.SpecialItems) do

		AccountData.SpecialItems[k] = nil

	end

	AccountSpecialItemDetails = {}

	for k in pairs (CharacterData.SpecialItems) do

		CharacterData.SpecialItems[k] = nil

	end

	CharacterSpecialItemDetails = {}

	for _, v in ipairs(sortedSortListEntries) do

		bFound = false

		for k, m in pairs (accountSpecialItemDetails) do

			if ItemAlert.ToLowerCaseManual(k) == ItemAlert.ToLowerCaseManual(v.text) then

				bFound = true
				local total = 0

				for q, r in pairs (characterSpecialItemDetails) do

					if r.itemname == m.itemname then

						total = r.total

						break

					end

				end

				ItemAlert.AddItem(m.itemname, m.displayname, m.animatedisplay, m.displayscreen, m.alertduration, m.soundname, m.volume, m.display, m.iconpath)
				AddCharacterSpecialItemDetails(k, "total", total)

				break

			end

		end

		if not bFound then

			if ItemAlert.AddItem(v.text, ItemAlert.GetShortName(v.text), true, true, 2.5, "CODE_REDEMPTION_SUCCESS", 2, true, "/esoui/art/icons/icon_missing.dds") == true then

				ItemAlertChat:SetTagColor("69EEE1"):Print("Item: "..ItemAlert.ProperCase(text).." Added to Tracked Items")

				ItemAlert.OkCreateDialog("IA_ADD_ITEM_DIALOG", "Item Alert", "You will have to reload UI or restart the game for the item added to show up in Tracked Item Settings.")

				ZO_Dialogs_ShowDialog("IA_ADD_ITEM_DIALOG")

			else

				ItemAlert.OkCreateDialog("IA_DUPLICATE_ITEM_DIALOG", "Item Alert", "This item is already being tracked.")

				ZO_Dialogs_ShowDialog("IA_DUPLICATE_ITEM_DIALOG")

			end

		end

	end

	ItemAlert.UpdateDisplayBar()

	ItemAlert.Status = "Idle"

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.Reset()

	-- This function is called via command line in game. Used to zero out all of the totals
	ItemAlert.StartTime = os.clock()
	CharacterData["MinutesTot"] = 0
	CharacterData["ItemTot"] = 0
	CharacterData["NodeTot"] = 0

	for q, r in pairs(CharacterSpecialItemDetails) do

		UpdateCharacterSpecialItemDetail(q, "total", 0)

	end

	ItemAlert.SaveCharacterSettings()

	if ItemAlert.GetAccountSetting("Chat") then ItemAlertChat:SetTagColor("69EEE1"):Print("----------- Reset Complete -----------") end

	ItemAlert.UpdateDisplayBar()

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------