-----------------------------------------------------------
-- Author: SpringPeace2575 | Version: 0.9.0
-- Util library (SpringPeace Framework)
-----------------------------------------------------------

SPFLibUtils = SPFLibUtils or {}

function SPFLibUtils.Safe(value, fallback)
    if value == nil then return fallback end
    return value
end

function SPFLibUtils.SafeText(v)
    if v == nil then return "" end
    return SPFLibUtils.Trim(tostring(v))
end

function SPFLibUtils.Lower(v)
    return zo_strlower(SPFLibUtils.SafeText(v))
end

function SPFLibUtils.Trim(value)
    return value and zo_strtrim(value) or ""
end

function SPFLibUtils.FormatWithThousands(n)
    local s = tostring(math.floor(tonumber(n) or 0))
    local sign = ""
    -- if zo_plainstrfind(s, "-", 1, true) == 1 then
    if zo_plainstrfind(s, "-") == 1 then
        sign = "-"
        s = s:sub(2)
    end
    local parts = {}
    while #s > 3 do
        table.insert(parts, 1, s:sub(-3))
        s = s:sub(1, -4)
    end
    if s ~= "" then
        table.insert(parts, 1, s)
    end
    return sign .. table.concat(parts, ",")
end

function SPFLibUtils.TrimTrailingZeros(text)
    text = tostring(text or "")
    text = text:gsub("(%..-)0+$", "%1")
    text = text:gsub("%.$", "")
    return text
end

function SPFLibUtils.FormatAmount(value)
    local n = tonumber(value) or 0
    local absN = math.abs(n)
    if absN >= 1000000 then
        -- local text = string.format("%.3f", n / 1000000)
        local text = string.format("%.1f", n / 1000000)
        return string.format("%sM", SPFLibUtils.TrimTrailingZeros(text))
    end
    return SPFLibUtils.FormatWithThousands(n)
end

function SPFLibUtils.FormatGoldAmount(value)
    return string.format("%s g", SPFLibUtils.FormatAmount(value))
end

function SPFLibUtils.FormatAbsoluteTimestamp(ts)
    ts = tonumber(ts) or 0
    if ts <= 0 then return "-" end
    if os and os.date then
        local ok, value = pcall(function() return os.date("%Y-%m-%d %H:%M:%S", ts) end)
        if ok and value then return value end
    end
    return tostring(ts)
end

function SPFLibUtils.FormatRelativeAgo(ts)
    ts = tonumber(ts) or 0
    if ts <= 0 then return "-" end
    local now = GetTimeStamp and GetTimeStamp() or ts
    local diff = now - ts
    if diff < 0 then diff = 0 end

    local units = {
        {name = "mo", secs = 30 * 24 * 60 * 60},
        {name = "w", secs = 7 * 24 * 60 * 60},
        {name = "d", secs = 24 * 60 * 60},
        {name = "h", secs = 60 * 60},
        {name = "m", secs = 60},
        {name = "s", secs = 1},
    }

    local parts = {}
    local remaining = diff
    for _, unit in ipairs(units) do
        if remaining >= unit.secs or (#parts > 0 and unit.name == 's') then
            local count = math.floor(remaining / unit.secs)
            if count > 0 or (#parts > 0 and unit.name == 's') then
                parts[#parts + 1] = tostring(count) .. unit.name
                remaining = remaining - (count * unit.secs)
                if #parts >= 2 then break end
            end
        end
    end
    if #parts == 0 then parts[1] = '0s' end
    return table.concat(parts, ' ') .. ' ago'
end

function SPFLibUtils.ConsolePlayBackSound()
	if PlaySound == nil then return end
	if SOUNDS ~= nil then
		if SOUNDS.GAMEPAD_MENU_BACK ~= nil then
			PlaySound(SOUNDS.GAMEPAD_MENU_BACK)
			return
		end
		if SOUNDS.GAMEPAD_PAGE_BACK ~= nil then
			PlaySound(SOUNDS.GAMEPAD_PAGE_BACK)
			return
		end
	end
end

function SPFLibUtils.Spread(intoTable, table)
    if type(intoTable) ~= "table" or type(table) ~= "table" then
        return
    end

    for _, item in ipairs(table) do
        intoTable[#intoTable + 1] = item
    end
end

function SPFLibUtils.Contains(tbl, value)
    if type(tbl) ~= "table" then
        return tbl == value -- fallback (single value)
    end

    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

function SPFLibUtils.GetChoicesMap(choices, choicesValues)
	local map = {}
	for i, val in pairs(choices) do
		local key = val
		local name = val

		if choicesValues ~= nil then
			key = choicesValues[i]
		end

		map[key] = name
	end
	return map
end

function SPFLibUtils.GetChoicesOrder(choices, choicesValues)
	local order = choices
	if choicesValues ~= nil then
		order = choicesValues
	end
	return order
end

function SPFLibUtils.GetChoicesOrderedItems(map, order)
	local items = {}
	for _, k in pairs(order) do
		table.insert(items, { name = map[k], data = k })
	end
    return items
end

function SPFLibUtils.GetDonationSettingsOptions(addonName)
    return {
        {
            type = "description",
            text = "Donate",
            width = "full",
        },
        {
            type = "description",
            text = "",
            width = "full",
        },
        {
            type = "description",
            text = "",
            width = "full",
        },
        {
            type = "image",
            texture = addonName.."/"..string.lower(addonName).."_paypal_qr.dds",
            imageWidth = 96,
            imageHeight = 96,
            width = "full",
            tooltip = "If you enjoy this addon and want to support its development, you can donate via PayPal. Thank you!",
            canSelect = true,
        },
        {
            type = "description",
            text = "",
            width = "full",
        },
        {
            type = "description",
            text = "",
            width = "full",
        },
        {
            type = "description",
            text = "paypal.me/SpringPeace",
            width = "full",
        },
        {
            type = "description",
            text = "",
            width = "full",
        },
        {
            type = "description",
            text = "",
            width = "full",
        },
    }
end

function SPFLibUtils.ConcatArrays(array1, array2)
    local finalArray = {}

    for _, item in ipairs(array1) do
        finalArray[#finalArray + 1] = item
    end

    for _, item in ipairs(array2) do
        finalArray[#finalArray + 1] = item
    end

    return finalArray
end

SPFLibUtils.QualityColors = {
    [1] = ZO_ColorDef:New("FF6F50"), -- Radiant Apex
    [2] = ZO_ColorDef:New("E58B27"), -- Apex
    [3] = GetItemQualityColor(5), -- Legendary, also CCAA1A
    [4] = GetItemQualityColor(4), -- Epic, also A02EF7
    [5] = GetItemQualityColor(3), -- Superior, also 3A92FF
    [6] = GetItemQualityColor(2), -- Fine, also 2DC50E
    [7] = GetItemQualityColor(1), -- Normal / Common, also 888888 or FFFFFF
}

function SPFLibUtils.ColorizeByQuality(text, quality)
    local color = SPFLibUtils.QualityColors[quality]
    if not color then
        return text
    end

    return color:Colorize(text)
end
