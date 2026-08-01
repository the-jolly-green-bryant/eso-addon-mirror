local function GetKills(killLocationIndex)
	local kills = {}

	for alliance = ALLIANCE_ITERATION_BEGIN, ALLIANCE_ITERATION_END do
		local numKills = GetNumKillLocationAllianceKills(killLocationIndex, alliance)
		kills[alliance] = numKills
	end

	return kills
end

local function FormatKills(allAlliancesKills)
    local tbl = {}

    for alliance, allianceKills in pairs(allAlliancesKills) do
        if allianceKills > 0 then
            local allianceColor = GetAllianceColor(alliance)
            local allianceIcon = allianceColor:Colorize(zo_iconFormatInheritColor(ZO_GetAllianceIcon(alliance), 16, 32))

            table.insert(tbl, string.format('%s %s', allianceIcon, allianceColor:Colorize(allianceKills)))
        end
    end

    return table.concat(tbl, '  / ')
end

local R, G, B = ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB()
local function AppendKillLocationInfo(self, pin)
	local killLocationIndex = pin.m_PinTag

	local kills = GetKills(killLocationIndex)
	local text = FormatKills(kills)

	self:AddLine(text, '', R, G, B, CENTER, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT)
end

function IMP_BV_InitializeCompactTooltip()
    ZO_PreHook(InformationTooltip, 'AppendKillLocationInfo', function(self, pin)
        AppendKillLocationInfo(self, pin)
        return true
    end)
end