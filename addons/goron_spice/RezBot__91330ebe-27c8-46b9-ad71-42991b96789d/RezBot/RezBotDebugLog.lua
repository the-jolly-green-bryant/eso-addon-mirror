-- RezBot Debug Log Panel (Console-Compatible)
RezBotDebugLog = RezBotDebugLog or {}
RezBotDebugLog.entries = {}
local MAX_ENTRIES = 200

---------------------------------------------------
-- Create the ScrollList (Gamepad-friendly)
---------------------------------------------------
local function CreateScrollList()
    local list = ZO_ScrollList:New(RezBotDebugLogPanel)
    local scrollDataType = 1

    ZO_ScrollList_AddDataType(list, scrollDataType, "RezBotDebugRowTemplate", 24, function(control, data)
        control:SetText(data.text)
    end)

    ZO_ScrollList_EnableSelection(list, "ZO_ThinListHighlight")
    RezBotDebugLog.scrollList = list
end

---------------------------------------------------
-- Update Log Display
---------------------------------------------------
function RezBotDebugLog:Refresh()
    if not self.scrollList then return end

    ZO_ScrollList_Clear(self.scrollList)
    local scrollData = ZO_ScrollList_GetDataList(self.scrollList)

    for _, entry in ipairs(self.entries) do
        table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, { text = entry }))
    end

    ZO_ScrollList_Commit(self.scrollList)
end

---------------------------------------------------
-- Public logging API
---------------------------------------------------
function RezBot.Log(msg)
    if not RezBot.isDev or not RezBot.isDev() then return end
    local timestamp = os.date("%H:%M:%S")
    local line = string.format("[%s] %s", timestamp, tostring(msg))

    -- Chat debug (still visible in dev window)
    d("|c00ff00[RezBot Debug]:|r " .. line)

    -- Insert into log entries
    table.insert(RezBotDebugLog.entries, line)
    if #RezBotDebugLog.entries > MAX_ENTRIES then
        table.remove(RezBotDebugLog.entries, 1)
    end

    -- Update UI
    RezBotDebugLog:Refresh()
end

---------------------------------------------------
-- Panel Toggle
---------------------------------------------------
function RezBotDebugLog.Toggle()
    if not RezBot.isDev or not RezBot.isDev() then return end
    local hidden = RezBotDebugLogPanel:IsHidden()
    RezBotDebugLogPanel:SetHidden(not hidden)
end

---------------------------------------------------
-- Hook into Harven’s panel
---------------------------------------------------
function RezBotDebugLog.RegisterSetting(panel)
    if not panel then return end

    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_BUTTON,
        label = "Open Debug Log Panel",
        tooltip = "Visible only for developers.",
        buttonText = "Open",
        disabled = function() return not RezBot.isDev or not RezBot.isDev() end,
        clickFunction = function()
            RezBotDebugLog.Toggle()
        end,
    })
end

EVENT_MANAGER:RegisterForEvent("RezBotDebugInit", EVENT_ADD_ON_LOADED, function(_, addon)
    if addon ~= RezBot.name then return end

    -- Wait until next frame to ensure all XML is fully loaded
    zo_callLater(function()
        if RezBotDebugLogPanel and RezBotDebugLog and RezBotDebugLog.CreateScrollList then
            RezBotDebugLog.CreateScrollList()
            RezBotDebugLogPanel:SetHidden(true)
        end
    end, 0)

end)
