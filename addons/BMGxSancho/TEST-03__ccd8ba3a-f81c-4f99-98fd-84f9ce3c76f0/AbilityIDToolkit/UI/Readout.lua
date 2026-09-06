AbilityIDToolkit = AbilityIDToolkit or {}
local AIT = AbilityIDToolkit

function AIT:FormatEvent(e)
    if not e then return "" end
    if e.eventType == "GEAR" or e.eventType == "CAPTURE STARTED" or e.eventType == "CAPTURE STOPPED" or e.eventType == "NOTE" then
        if e.abilityId then
            return string.format("|cFFFFFF%d|r  |cE6C34B%s|r  %s", e.abilityId or 0, e.eventType or "", e.text or e.name or "")
        end
        return string.format("|cE6C34B%s|r  %s", e.eventType or "", e.text or "")
    end

    local id = e.abilityId or 0
    local name = e.name or "Unknown"
    local extra = {}
    if e.duration and e.duration > 0 then extra[#extra + 1] = string.format("%.1fs", e.duration) end
    if e.stacks and e.stacks > 0 then extra[#extra + 1] = "x" .. tostring(e.stacks) end
    if e.changeType ~= nil then extra[#extra + 1] = "change=" .. tostring(e.changeType) end
    if e.result ~= nil then extra[#extra + 1] = "result=" .. tostring(e.result) end
    if e.targetName and e.targetName ~= "" then extra[#extra + 1] = "-> " .. e.targetName end

    return string.format("|cFFFFFF%d|r  |cE6C34B%s|r  %s  |cB8B8B8%s|r", id, e.eventType or "", name, table.concat(extra, "  "))
end

function AIT:FormatLookupResult(r)
    if not r then return "" end
    local lines = {
        string.format("|cFFFFFFABILITY ID|r  %d", r.abilityId or 0),
        string.format("|cFFFFFFNAME|r  %s", r.name or "Unknown"),
        string.format("|cFFFFFFCATEGORY|r  %s", r.category or "Unknown"),
        string.format("|cFFFFFFSOURCE|r  %s", r.origin or "Unknown"),
    }
    if r.lastDuration and tonumber(r.lastDuration) and tonumber(r.lastDuration) > 0 then
        lines[#lines + 1] = string.format("|cFFFFFFLAST DURATION|r  %.1fs", tonumber(r.lastDuration))
    end
    if r.lastSource and r.lastSource ~= "" then lines[#lines + 1] = "|cFFFFFFLAST SOURCE|r  " .. tostring(r.lastSource) end
    if r.lastTarget and r.lastTarget ~= "" then lines[#lines + 1] = "|cFFFFFFLAST TARGET|r  " .. tostring(r.lastTarget) end
    if r.notes and r.notes ~= "" then lines[#lines + 1] = "|cFFFFFFNOTES|r  " .. tostring(r.notes) end
    return table.concat(lines, "\n")
end

function AIT:RunLookup(query)
    self.lookupResults = self:SearchKnown(tostring(query or "")) or {}
    self.lookupLastQuery = tostring(query or "")
    if self.RefreshSettingsPanel then
        self:RefreshSettingsPanel(true)
    elseif self.settingsPanel and self.settingsPanel.UpdateControls then
        self.settingsPanel:UpdateControls()
    end
end

function AIT:GetLookupSummary()
    local q = tostring(self.lookupLastQuery or self.sv.lookupQuery or "")
    local count = #(self.lookupResults or {})
    if q == "" and count == 0 then return "Enter an Ability ID or name above, then select SEARCH." end
    if count == 0 then return string.format("No result found for: %s", q ~= "" and q or "(blank)") end
    return string.format("%d result%s for: %s", count, count == 1 and "" or "s", q ~= "" and q or "All Known IDs")
end

function AIT:GetLookupResultText(index)
    local r = self.lookupResults and self.lookupResults[index]
    if not r then return "" end
    return self:FormatLookupResult(r)
end

function AIT:GetCaptureSummary()
    local log = (self.capture and self.capture.log) or {}
    if #log == 0 then return "No capture results yet." end
    local shown = math.min(#log, 80)
    if #log > shown then
        return string.format("Captured %d entries. Showing the first %d here; all %d remain stored in the session database.", #log, shown, #log)
    end
    return string.format("Captured %d entr%s.", #log, #log == 1 and "y" or "ies")
end

function AIT:GetCaptureResultText(index)
    local log = (self.capture and self.capture.log) or {}
    local e = log[index]
    if not e then return "" end
    return self:FormatEvent(e)
end

function AIT:CreateReadout()
    -- v0.0.04 intentionally has no separate popup/scene.
    -- All readout content lives inside LibHarvensAddonSettings so the
    -- native console settings scene owns scrolling, focus, and Circle/Back.
end

function AIT:ShowCaptureResults()
    if self.settingsPanel and self.settingsPanel.UpdateControls then
        self.settingsPanel:UpdateControls()
    end
end

function AIT:ShowLookup(query)
    self:RunLookup(query)
end

function AIT:RefreshReadout()
    if self.settingsPanel and self.settingsPanel.UpdateControls then
        self.settingsPanel:UpdateControls()
    end
end

function AIT:CloseReadout()
    -- Native settings scene owns Back/Close.
end
