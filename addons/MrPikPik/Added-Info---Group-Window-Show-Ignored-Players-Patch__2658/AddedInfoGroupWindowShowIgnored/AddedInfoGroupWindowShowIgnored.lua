local AIGW = AIGW or {}

-- Update Leader Icon Control Patch
function AIGW.updateLeaderIgnoreIconPatch(control, isLeader, isPlayer)
    local leaderIconControl = control:GetNamedChild("LeaderIcon")  
    
    -- Mark ignored players - This is added by this patch
    if IsIgnored(control.dataEntry.data.displayName) then
        leaderIconControl:SetHidden(false)
        leaderIconControl:SetTexture("/esoui/art/contacts/tabicon_ignored_up.dds")
    end
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= AIGW.name then return end
    EVENT_MANAGER:UnregisterForEvent("AddedInfoGroupWindowShowIgnored", EVENT_ADD_ON_LOADED)
    
    if AIGW.LeaderPatch ~= nil then
        local backup = AIGW.LeaderPatch
        AIGW.LeaderPatch = function(...)
            backup(...)
            AIGW.updateLeaderIgnoreIconPatch(...)
        end
    else
        AIGW.LeaderPatch = AIGW.updateLeaderIgnoreIconPatch
    end
end
EVENT_MANAGER:RegisterForEvent("AddedInfoGroupWindowShowIgnored", EVENT_ADD_ON_LOADED, OnAddonLoaded)