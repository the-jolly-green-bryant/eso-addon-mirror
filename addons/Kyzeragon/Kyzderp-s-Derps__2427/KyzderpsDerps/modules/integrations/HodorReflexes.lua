KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.Hodor = KyzderpsDerps.Hodor or {}
local Hodor = KyzderpsDerps.Hodor


---------------------------------------------------------------------
-- Update player data to get them off the horn list
---------------------------------------------------------------------
local function Unhorn(atName)
    if (not atName or atName == "") then
        KyzderpsDerps:msg("Usage: /unhorn <@name>")
        return
    end

    local lowerName = string.gsub(string.lower(atName), "@", "")
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if (string.gsub(string.lower(GetUnitDisplayName(unitTag)), "@", "") == lowerName) then
            KyzderpsDerps:msg("Updating player data for " .. unitTag .. " to maybe reset horn")

            if (HodorReflexes.modules.share and HodorReflexes.modules.share.UpdatePlayerData) then
                KyzderpsDerps:msg("Clearing horn data using UpdatePlayerData")
                HodorReflexes.modules.share.UpdatePlayerData(unitTag, 0, 1, 0, 0, 0)
            elseif (HodorReflexes.modules.share and HodorReflexes.modules.share.playersData) then
                -- Hodor 2025.05.07 opened playersData back up properly
                KyzderpsDerps:msg("Clearing horn data using playersData")
                local data = HodorReflexes.modules.share.playersData[GetUnitDisplayName(unitTag)]
                if (data.ult) then
                    data.ult = 0
                end
                if (data.ultValue) then
                    data.ultValue = 0
                end
            elseif (HodorReflexes.modules.share and HodorReflexes.modules.share.GroupChanged) then
                -- This is really hacky, but Hodor 2.0 has many things local
                -- Pretend the target is "offline" so that the CleanGroupData is forced
                -- Not sure if this can cause issues...
                KyzderpsDerps:msg("Clearing horn data using GroupChanged (hacky!)")
                local orig = IsUnitOnline
                IsUnitOnline = function(tag) if (tag == unitTag) then return false end return orig(tag) end
                HodorReflexes.modules.share.GroupChanged()
                IsUnitOnline = orig
            elseif (HodorReflexes.playersData) then
                -- Hodor rewrite saves by character name
                KyzderpsDerps:msg("Clearing horn data using HodorReflexes.playersData")
                local charName = GetUnitName(unitTag)
                HodorReflexes.playersData[charName] = nil
                -- TODO: might have to do it in LGCS actually
            else
                KyzderpsDerps:msg("Doesn't support current Hodor version. TODO!!")
            end
            return
        end
    end

    KyzderpsDerps:msg("Couldn't find player " .. atName .. " in group!")
end


---------------------------------------------------------------------
-- When horn updates, also add/update icon for horn in range
---------------------------------------------------------------------
local function UpdateInRange()
    for atName, data in pairs(HodorReflexes.modules.share.playersData) do
        if (data.ultRow) then
            local name = string.gsub(atName, "^@", "")
            local texture = WINDOW_MANAGER:GetControlByName("KDDHodor" .. name)
            local label = WINDOW_MANAGER:GetControlByName("KDDHodor" .. name .. "Label")
            if (not texture) then
                texture = WINDOW_MANAGER:CreateControl("KDDHodor" .. name, data.ultRow, CT_TEXTURE)
                texture:SetDimensions(18, 18)
                texture:SetAnchor(RIGHT, data.ultRow, LEFT, -4)
                texture:SetTexture("esoui/art/unitattributevisualizer/attributebar_arrow.dds")
                texture:SetDrawTier(2)

                local outline = WINDOW_MANAGER:CreateControl("KDDHodor" .. name .. "Outline", texture, CT_TEXTURE)
                outline:SetTexture("esoui/art/unitattributevisualizer/attributebar_arrow.dds")
                outline:SetColor(0, 0, 0)
                outline:SetDimensions(18, 18)
                outline:SetAnchor(TOPLEFT, texture, TOPLEFT, 3, 3)
                outline:SetDrawTier(1)

                label = WINDOW_MANAGER:CreateControl("KDDHodor" .. name .. "Label", texture, CT_LABEL)
                label:SetFont("ZoFontGameSmall")
                label:SetColor(0.6, 0.6, 0.6)
                label:SetAnchor(RIGHT, texture, LEFT, -4)
            end
            texture:SetParent(data.ultRow)
            texture:SetAnchor(RIGHT, data.ultRow, LEFT, -4)

            if ((data.ult and data.ult >= 90) -- Old Hodor, probably incorrect too
                or (data.ult1ID == 40223 and data.ultValue / data.ult1Cost >= 0.9)
                or (data.ult2ID == 40223 and data.ultValue / data.ult2Cost >= 0.9)) then
                if (IsUnitInGroupSupportRange(data.tag)) then
                    local distance = HodorReflexes.player.GetDistanceToPlayerM(data.tag)
                    if (distance) then
                        label:SetText(string.format("%.1fm", distance))
                    else
                        distance = 30
                    end

                    local red = 0
                    local green = 1
                    if (distance >= 20) then
                        red = 1
                        green = 0.3
                    elseif (distance >= 16) then
                        red = 1
                        green = 1
                    end
                    texture:SetColor(red, green, 0)
                    texture:SetHidden(false)
                    label:SetHidden(not KyzderpsDerps.savedOptions.hodor.hornLabel)
                else
                    texture:SetHidden(true)
                end
            else
                -- If ult isn't ready or close to ready, just hide it
                texture:SetHidden(true)
            end
        end
    end
end


---------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------
local origFunction

function Hodor.Initialize()
    if (not HodorReflexes) then return end
    SLASH_COMMANDS["/unhorn"] = Unhorn

    if (not KyzderpsDerps.savedOptions.hodor.horn) then return end

    KyzderpsDerps:dbg("    Initializing Hodor integration...")

    if (origFunction ~= nil) then return end
    if (not HodorReflexes.modules or not HodorReflexes.modules.share or not HodorReflexes.modules.share.RefreshControls) then return end -- TODO: just to not error with hodor 2 for now

    origFunction = HodorReflexes.modules.share.RefreshControls
    HodorReflexes.modules.share.RefreshControls = function(...)
        UpdateInRange()
        origFunction(...)
    end

    -- If it's aligned to the right of the screen it gets pushed to the left, annoying
    if (HodorReflexes_Share_Ultimates) then
        HodorReflexes_Share_Ultimates:SetClampedToScreen(false)
    end
end

function Hodor.Uninitialize()
    if (not HodorReflexes) then return end

    -- Note: the function restoration only takes effect after Hodor restarts polling (like after leaving group?)
    if (origFunction ~= nil) then
        HodorReflexes.modules.share.RefreshControls = origFunction
        origFunction = nil
    end

    if (HodorReflexes_Share_Ultimates) then
        HodorReflexes_Share_Ultimates:SetClampedToScreen(true)
    end

    KyzderpsDerps:dbg("    Removed Hodor integration...")
end


---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
function Hodor.GetSettings()
    return {
        {
            type = "checkbox",
            name = "Enable horn distance icon",
            tooltip = "When enabled, a colored icon will show next to the horn list if the player almost has horn ready and is within support range. The icon shows green, yellow, or orange depending on distance to yourself. Useful for raid leads especially in vCR with tank gone in portal. NOTE: This is incompatible with Hodor 2.0 for now",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.hodor.horn end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.hodor.horn = value

                Hodor.Uninitialize()
                Hodor.Initialize()
            end,
            width = "full",
            disabled = function() return not HodorReflexes.modules or not HodorReflexes.modules.share or not HodorReflexes.modules.share.RefreshControls end,
        },
        {
            type = "checkbox",
            name = "Enable horn distance label",
            tooltip = "Additionally shows the horn player's distance in meters to yourself. NOTE: This is incompatible with Hodor 2.0 for now",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.hodor.hornLabel end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.hodor.hornLabel = value
            end,
            width = "full",
            disabled = function()
                return not KyzderpsDerps.savedOptions.hodor.horn or not HodorReflexes.modules or not HodorReflexes.modules.share or not HodorReflexes.modules.share.RefreshControls
            end,
        },
    }
end
