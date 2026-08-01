------------------------------------------------
-- Russian localization
------------------------------------------------

local strings = {
	-- need translation
}

for stringId, stringValue in pairs(strings) do
	SafeAddString(stringId, stringValue, 1)
	SafeAddVersion(stringId, 1)
end
