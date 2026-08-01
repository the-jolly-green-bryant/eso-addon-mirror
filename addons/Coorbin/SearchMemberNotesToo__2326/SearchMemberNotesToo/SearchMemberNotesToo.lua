--[[
Copyright 2019 Sean McNamara AKA @Coorbin <smcnam@gmail.com>.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]

local smnt_name = "SearchMemberNotesToo"
local smnt_savedVarsName = "SearchMemberNotesTooSettings"
local smnt_ranks = {}

local function smnt_OnAddOnLoaded(event, addonName)
	if addonName == smnt_name then
		EVENT_MANAGER:UnregisterForEvent(smnt_name, EVENT_ADD_ON_LOADED)
		smnt_savedVariables = ZO_SavedVars:NewAccountWide(smnt_savedVarsName, 15, nil, {})
        local grm = GUILD_ROSTER_KEYBOARD
        local og_FilterScrollList = grm.FilterScrollList

        for i=1,5,1 do
            local gid = GetGuildId(i)
            if gid > 0 then
                smnt_ranks[gid] = {}
                for j=1,10,1 do
                    local v = GetGuildRankCustomName(gid, j)
                    if v ~= "" then
                        table.insert(smnt_ranks[gid], string.lower(v))
                    end
                end
            end
        end

        grm.FilterScrollList = function(self)
            local scrollData = ZO_ScrollList_GetDataList(self.list)
            ZO_ClearNumericallyIndexedTable(scrollData)

            local searchTerm = self.searchBox:GetText()
            local hideOffline = GetSetting_Bool(SETTING_TYPE_UI, UI_SETTING_SOCIAL_LIST_HIDE_OFFLINE)
            local guildId = GUILD_ROSTER_MANAGER:GetGuildId()
            local slst = string.lower(searchTerm)
            local rankOnly = false
            local rankPlus = false
            local rankMinus = false
            local rankIndex = -1
            local rankCount = 0

            for ri,rankName in pairs(smnt_ranks[guildId]) do
                if slst == rankName then
                    rankOnly = true
                    rankIndex = ri
                    break
                end
                
                if slst == rankName .. "+" then
                    rankPlus = true
                    rankIndex = ri
                    break
                end
                
                if slst == rankName .. "-" then
                    rankMinus = true
                    rankIndex = ri
                    break
                end
            end

            local masterList = GUILD_ROSTER_MANAGER:GetMasterList()
            for i = 1, #masterList do
                local data = masterList[i]
                -- TODO: Add support for searching for ranks, including "+" to search for that rank or higher
                if rankIndex > -1 then
                    if (rankOnly == true and rankIndex == data.rankIndex) or (rankPlus == true and data.rankIndex <= rankIndex) or (rankMinus == true and data.rankIndex >= rankIndex) then
                        if not hideOffline or data.online then
                            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(GUILD_MEMBER_DATA, data))
                            rankCount = rankCount + 1
                        end
                    end
                else
                    if searchTerm == "" or GUILD_ROSTER_MANAGER:IsMatch(searchTerm, data)
                    or string.find(string.lower(data.note), slst) then
                        if not hideOffline or data.online then
                            table.insert(scrollData, ZO_ScrollList_CreateDataEntry(GUILD_MEMBER_DATA, data))
                        end
                    end
                end
            end
            if rankCount > 0 then
                d("Searched for rank " .. searchTerm .. " and got " .. rankCount .. " results.")
            end
        end
	end
end

EVENT_MANAGER:RegisterForEvent(smnt_name, EVENT_ADD_ON_LOADED, smnt_OnAddOnLoaded)
