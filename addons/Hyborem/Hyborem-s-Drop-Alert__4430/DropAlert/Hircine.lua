local DA = DropAlert

local function OnLootHircine(_, _, link, count, _, _, selfLooted)
    if not selfLooted or not link or not DA.vars then return end
    local id = GetItemLinkItemId(link)
    local list = DA.vars.customItems
    if id and list and list[id] then
        DA.HircineAlert(link, count)
        DA.isCurrentlyHunted = true
    else
        DA.isCurrentlyHunted = false
    end
end

EVENT_MANAGER:UnregisterForEvent("HircineModule", EVENT_LOOT_RECEIVED)
EVENT_MANAGER:RegisterForEvent("HircineModule", EVENT_LOOT_RECEIVED, OnLootHircine)

local function RegisterHircineMouse()
    local old = ZO_LinkHandler_OnLinkMouseUp
    ZO_LinkHandler_OnLinkMouseUp = function(link, button, control, ...)
        if button == MOUSE_BUTTON_INDEX_RIGHT and link ~= "" then
            local id = GetItemLinkItemId(link)
            if id and id > 0 then
                zo_callLater(function()
                    local list = DA.vars.customItems
                    if not list then return end
                    AddCustomMenuItem("|cADD8E6Hircine's Great Hunt|r", function() end)
                    local watched = list[id]
                    local label = watched and "|cFF0000Ignore the Prey|r" or "|cADFF2FHunt that item|r"
                    AddCustomMenuItem(label, function()
                        if watched then list[id] = nil else list[id] = true end
                    end)
                    ShowMenu(control)
                end, 50)
            end
        end
        return old(link, button, control, ...)
    end
end
RegisterHircineMouse()