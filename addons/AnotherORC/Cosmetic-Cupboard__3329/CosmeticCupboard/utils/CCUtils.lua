-- Sends info to the chatbox
function CC:SendToChat(text)
	if text ~= nil then
		d(CC.CONSTS.chatPrefix .. text .. CC.CONSTS.chatSuffix)
	else
		d(CC.CONSTS.chatPrefix .. "nil string" .. CC.CONSTS.chatSuffix)
	end
end

function CC:IconNameFromString(text)
	local iconName
	_, _, iconName = string.find(text, 'icons/(.+)%.dds')
	return iconName
end

function CC:Trim(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function CC_StringMatch(a, b)
	if a == "" or b == "" then return true end -- Empty strings always match
	local i, _ = string.match(string.lower(a), string.lower(b))
	return i ~= nil
end