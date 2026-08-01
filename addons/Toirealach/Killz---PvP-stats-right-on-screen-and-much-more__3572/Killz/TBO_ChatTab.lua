-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- TBO_ChatTab: API for chat window tabs in the ESO chat window 
--
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Version 1.0.2 by Teebow Ganx
-- Copyright (c) 2023 Trailing Zee Productions, LLC.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

local tboChatWindowTab = ZO_CallbackObject:Subclass()
TBO_ChatTab = tboChatWindowTab

local TBO_ChatTabInfo = { container = nil, wIndx = -1, window = nil  }

function TBO_ChatTab.Find(inTabName)

	for k, cc in ipairs(CHAT_SYSTEM.containers) do
		for i = 1, #cc.windows do
			if cc:GetTabName(i) == inTabName then
				return cc, cc.windows[i] 
			end
		end
	end

    return nil, nil
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- TBO_ChatTab:New()
--
-- Will return the info for an existing chat tab or else create the tab if necessary.
-- You will still need to turn on & off things like interactivity, lock, filters, etc.
-- as you see fit once it is created.
--
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function TBO_ChatTab:New(inTabName, inInteractivity, inLocked, inTimeStampsEnabled)

	assert(inTabName ~= nil, "Tab Name cannot be nil!")

	-- If chat system hasn't been initialised yet then return nil
	if CHAT_SYSTEM == nil then 
		d("Killz: CHAT_SYSTEM == nil in call to TBO_ChatTab:New()")
		return nil 
	end

	if CHAT_SYSTEM.primaryContainer == nil then 
		d("Killz: CHAT_SYSTEM.primaryContainer == nil in call to TBO_ChatTab:New()")
		return nil 
	end

	local obj = ZO_Object.New(self)

    obj.container = nil
	obj.window = nil

	obj.container, obj.window = TBO_ChatTab.Find(inTabName, true)

	if obj.container == nil then
		
		local cc = CHAT_SYSTEM.primaryContainer
		local window, key = cc.windowPool:AcquireObject()
		window.key = key
		cc:AddRawWindow(window, inTabName)
	
		local tabIndex = window.tab.index
	
		cc:SetInteractivity(tabIndex, true)
		cc:SetLocked(tabIndex, true)
	
		local interactive = inInteractivity or true
		local locked = inLocked or true
		local timeStamp = inTimeStampsEnabled or false
	
		cc:SetInteractivity(tabIndex, interactive)
		cc:SetLocked(tabIndex, locked)
		cc:SetTimestampsEnabled(tabIndex, timeStamp)
	
		-- Start off with no filters enabled
		for category = 1, GetNumChatCategories() do
			cc:SetWindowFilterEnabled(tabIndex, category, false)
		end

		obj.container = cc
		obj.window = window
	end

    return obj
end

function TBO_ChatTab:Remove()
	self.container:RemoveWindow(self.window.key)
end

function TBO_ChatTab:AddMsg(inMessage)
	self.container:AddMessageToWindow(self.window, inMessage)
end

function TBO_ChatTab:SetFontSize(inFontSize)
	self.container:SetFontSize(self.window.tab.index, inFontSize)
end

function TBO_ChatTab:Interactivity(inShouldBeInteractive)	-- boolean
	self.container:SetInteractivity(self.window.tab.index, inShouldBeInteractive)
end

function TBO_ChatTab:IsInteractive()
	return self.container:IsInteractive(self.window.tab.index)
end

function TBO_ChatTab:Lock()
	self.container:SetLocked(self.window.tab.index, true)
end

function TBO_ChatTab:Unlock()
	self.container:SetLocked(self.window.tab.index, false)
end

function TBO_ChatTab:IsLocked()
	return self.container:IsLocked(self.window.tab.index)
end

function TBO_ChatTab:Timestamp() -- Boolean
	self.container:SetTimestampsEnabled(self.window.tab.index, true)
end

function TBO_ChatTab:NoTimestamps() -- Boolean
	self.container:SetTimestampsEnabled(self.window.tab.index, false)
end

function TBO_ChatTab:UsesTimestamps()
	return self.container:AreTimestampsEnabled(self.window.tab.index)
end

function TBO_ChatTab:Filter(inCategory) -- Boolean
	self.container:SetWindowFilterEnabled(self.window.tab.index, inCategory, true)
end

function TBO_ChatTab:Unfilter(inCategory) -- Boolean
	self.container:SetWindowFilterEnabled(self.window.tab.index, inCategory, false)
end

function TBO_ChatTab:IsFiltering(inCategory) -- Boolean
	return self.container:GetWindowFilterEnabled(self.window.tab.index, inCategory)
end