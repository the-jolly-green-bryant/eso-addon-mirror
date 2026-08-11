if not GildedUI then return end

local Addon = GildedUI

Addon.GOLD_TEXT_COLOR = { 1, 215 / 255, 0 } -- #ffd700

Addon.goldFormatItems = {
    { name = "123456789",     value = "raw" },
    { name = "123,456,789",   value = "grouped" },
    { name = "123,456,789g",  value = "groupedG" },
    { name = "123.5M",        value = "compact" },
}

local function GroupDigits(amount)
    amount = zo_floor(amount or 0)
    if FormatIntegerWithDigitGrouping then
        return FormatIntegerWithDigitGrouping(amount, ",", 3)
    end

    local text = tostring(amount)
    local sign = ""
    if text:sub(1, 1) == "-" then
        sign = "-"
        text = text:sub(2)
    end

    local grouped = text:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if grouped:sub(1, 1) == "," then
        grouped = grouped:sub(2)
    end
    return sign .. grouped
end

local function FormatCompactScaled(value, suffix)
    if value >= 100 then
        return string.format("%d%s", zo_floor(value + 0.5), suffix)
    end

    local text = string.format("%.1f", value)
    text = text:gsub("%.0$", "")
    return text .. suffix
end

local function FormatCompactGold(amount)
    amount = zo_floor(amount or 0)
    if amount < 1000 then
        return tostring(amount) .. "g"
    end
    if amount < 1000000 then
        return FormatCompactScaled(amount / 1000, "K")
    end
    if amount < 1000000000 then
        return FormatCompactScaled(amount / 1000000, "M")
    end
    return FormatCompactScaled(amount / 1000000000, "B")
end

function Addon:FormatCurrencyAmount(amount)
    return GroupDigits(zo_floor(amount or 0))
end

function Addon:IsValidGoldFormat(format)
    for _, item in ipairs(self.goldFormatItems) do
        if item.value == format then
            return true
        end
    end
    return false
end

function Addon:FormatGoldAmount(amount)
    local format = self.state.sv and self.state.sv.goldFormat or self.defaults.goldFormat
    amount = zo_floor(amount or 0)

    if format == "raw" then
        return tostring(amount)
    end
    if format == "grouped" then
        return GroupDigits(amount)
    end
    if format == "compact" then
        return FormatCompactGold(amount)
    end

    return GroupDigits(amount) .. "g"
end
