local function DumpCurrencies()
	d("CURT_TRADE_BARS: " .. tostring(CURT_TRADE_BARS))
	d("CURT_TOME_POINTS: " .. tostring(CURT_TOME_POINTS))
end

SLASH_COMMANDS["/curt"] = DumpCurrencies
