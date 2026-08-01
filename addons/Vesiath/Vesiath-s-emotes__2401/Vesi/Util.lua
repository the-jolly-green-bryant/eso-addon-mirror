V.Util = {
    extension = ".dds",

    FixNames = function(from, fromDisplayName)
        if not IsDecoratedDisplayName(from) and from ~= "" then
			from = ZO_ShouldPreferUserId() and fromDisplayName or from
		end
		return from
    end,

    Case_Insensitive_Pattern = function(pattern)
		local p = pattern:gsub("(%%?)(.)", function(percent, letter)
			if percent ~= "" or not letter:match("%a") then
			  return percent .. letter
			else
			  return string.format("[%s%s]", letter:lower(), letter:upper())
			end
		end)
		return p
    end,
    
    Sort_By_Name = function(a, b)
		return a.name < b.name
	end,
	
	Ends_With = function(self, str, ending)
		return ending == "" or str:sub(-#ending) == ending
    end,
    
    TextEntry = function(self, str)
		local text = CHAT_SYSTEM.textEntry:GetText()
		if text == "" then
			CHAT_SYSTEM:StartTextEntry(str.." ")
		else
			if self:Ends_With(text, " ") then
				CHAT_SYSTEM:StartTextEntry(text ..  str)
			else
				CHAT_SYSTEM:StartTextEntry(text .. " " .. str)
			end
		end
	end,
}