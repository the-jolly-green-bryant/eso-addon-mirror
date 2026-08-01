--[[
Copyright 2020 Sean McNamara <smcnam@gmail.com>.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]

local cc_name = "CharCount"
local charcount = ""
local wm = WINDOW_MANAGER
local curr = nil

local function cc_updateLabelText()
	charcount:SetText(tostring(string.len(ZO_ChatWindowTextEntryEditBox:GetText())) .. "/350")
end

local function cc_OnAddOnLoaded(event, addonName)
	if addonName == cc_name then
		EVENT_MANAGER:UnregisterForEvent(cc_name, EVENT_ADD_ON_LOADED)
		charcount = wm:CreateControl(nil, ZO_ChatWindow, CT_LABEL)
		charcount:SetFont("ZoFontWinH4")
		charcount:SetHeight(33)
		charcount:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
		charcount:SetAnchor(CENTER, ZO_ChatWindow, TOP, 0, 30)
		cc_updateLabelText()
		curr = ZO_ChatWindowTextEntryEditBox:GetHandler("OnTextChanged")
		ZO_ChatWindowTextEntryEditBox:SetHandler("OnTextChanged", function(self)
			cc_updateLabelText()
			if curr ~= nil then
				curr(self)
			end
		end)
	end
end

EVENT_MANAGER:RegisterForEvent(cc_name, EVENT_ADD_ON_LOADED, cc_OnAddOnLoaded)