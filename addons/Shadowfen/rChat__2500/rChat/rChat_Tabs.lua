rChat = rChat or {}

local SF = LibSFUtils
local L = GetString

--[[ ---------------------------------------------
A lookup table of tab names indexed by tab index
--]]
rChat_TabNames = ZO_Object:Subclass()
local TabNames = rChat_TabNames

function TabNames:New()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.nameList = {}
	return o
end

function TabNames:Refresh()
	local nameList = self.nameList
	SF.safeClearTable(self.nameList)
    local totalTabs = CHAT_SYSTEM.tabPool.m_Active
	rChat.logDebug("[Refresh] total tabs #",#totalTabs)
	if totalTabs ~= nil and #totalTabs >= 1 then
        for idx, tmpTab in pairs(totalTabs) do
            local tabLabel = tmpTab:GetNamedChild("Text")
			rChat.logDebug("[Refresh] idx ",idx," - tab label ",tabLabel:GetText())
			if tabLabel then 
				local tmpTabName = tabLabel:GetText()
				if tmpTabName ~= nil and tmpTabName ~= "" then
					rChat.logDebug("[Refresh] adding ", tmpTabName, " to self.nameList at ",idx)
					self.nameList[idx] = tmpTabName
				end
			end
        end
    end
	return self.nameList
end

function TabNames:GetNames()
	self:Refresh()
    local totalTabs = CHAT_SYSTEM.tabPool.m_Active
	rChat.logDebug("[TabNames:GetNames] got tabs 1 #",#totalTabs)
	rChat.logDebug("[TabNames:GetNames] got names 1 #",#self.nameList)
	return self.nameList
end

function TabNames:GetIndex(tabName)
    local tabIdx = nil
    for i,v in ipairs(self.nameList) do
        if v == tabName then
            tabIdx = i
            break
        end
    end
    return tabIdx
end

--[[ ---------------------------------------------
  rChat functions which manipulate tabs
--]]

local function isValidTabIndex(tabndx)
    if type(tabndx)~="number" then
		return false
	end

    local container=CHAT_SYSTEM.primaryContainer
    if not container then
		return false
	end

    if tabndx<1 or tabndx>#container.windows then
		return false
	end
    if container.windows[tabndx].tab==nil then
		return false
	end
	return true
end

function rChat.ChangeTab(tabToSet)
    if isValidTabIndex(tabToSet) == false then
		return
	end

    local container=CHAT_SYSTEM.primaryContainer
	container.tabGroup:SetClickedButton(container.windows[tabToSet].tab)
    if CHAT_SYSTEM:IsMinimized() then
		CHAT_SYSTEM:Maximize()
	end
end


