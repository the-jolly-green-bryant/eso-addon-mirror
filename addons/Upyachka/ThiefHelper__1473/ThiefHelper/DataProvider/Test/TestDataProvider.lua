-- For tests only.
TestDataProvider = Up_DataProvider:new()

-- Overriden method Up_DataProvider:getText(addon).
function TestDataProvider:getText(addon)
    local cost = GetRecallCost()
    local goldIcon = zo_iconFormat(ZO_GAMEPAD_CURRENCY_ICON_GOLD_TEXTURE, 32, 32)
    local timeString = ZO_FormatTimeMilliseconds(GetRecallCooldown(), TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
    return string.format("Test: %d %s Time %s", cost, goldIcon, timeString)
end
