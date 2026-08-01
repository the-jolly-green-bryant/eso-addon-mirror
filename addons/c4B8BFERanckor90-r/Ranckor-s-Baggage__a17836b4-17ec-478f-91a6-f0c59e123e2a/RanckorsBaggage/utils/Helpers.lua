local RB = RanckorsBaggage

function RB:Ucfirst(s)
    return (s or ""):gsub("^%l", string.upper)
end

function RB:IsValidWindow()
    return RanckorsBaggageWindow and RanckorsBaggageWindow.SetHidden ~= nil
end

function RB:ZOComma(n)
    return (ZO_CommaDelimitNumber and ZO_CommaDelimitNumber(n))
        or tostring(n):reverse():gsub("(%d%d%d)", "%1,"):gsub(",(%-?)$", "%1"):reverse()
end

function RB:GetFont(kind)
    local platform = IsInGamepadPreferredMode() and "console" or "pc"
    return (self.fonts[platform] and self.fonts[platform][kind]) or "ZoFontGameSmall"
end

function RB:GetWindowSize()
    if IsInGamepadPreferredMode() then
        return 150, 480 -- Console/GamePad
    else
        return 200, 620 -- PC default
    end
end

function RB:UsageColor(pct)
    if pct >= 95 then
        return self.COLORS.CRITICAL
    elseif pct >= 90 then
        return self.COLORS.WARNING
    else
        return self.COLORS.NORMAL
    end
end