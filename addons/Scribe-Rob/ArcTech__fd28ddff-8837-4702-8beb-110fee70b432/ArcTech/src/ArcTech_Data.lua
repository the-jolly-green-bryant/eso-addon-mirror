-- ArcTech_Data.lua
local ArcTech = ArcTech

ArcTech.house_owner = "@Arcanist Rob"
ArcTech.guild_id = 381665

ArcTech.houses = {
	main = { label = "|cffff00Main - Kthendral Deep Mines|r", owner = ArcTech.house_owner, id = 113 },
	pvp = { label = "|cffff00PvP - Elinhir Arena|r", owner =ArcTech.house_owner, id = 66 },
	auction = { label = "|cffff00Auction - Theatre of the Ancestors|r", owner = ArcTech.house_owner, id = 119 },
}

ArcTech.Status_Colours = {
    standard = '|cc7cdbf',
    active = '|c568203',
    disabled = '|cff0000'
}

ArcTech.QR = { data = "https://discord.gg/hj2eWtra66", size = 240 }

-- helper FIRST
local function parseDate(dateStr)
    local day, month, year = dateStr:match("(%d+)%-(%d+)%-(%d+)")
    return os.time({
        day = tonumber(day),
        month = tonumber(month),
        year = tonumber(year),
        hour = 0
    })
end

ArcTech.Events = {
    CommencementDate = "11-05-2026",

    monday = {},

    tuesday = {},

    wednesday = {
        host = 'Scribe Rob',
        datetime = '1778698800',
        title = 'The Night Market',
        description = 'The Night Market is Here! The Arcanists descend with the aim of unlocking the secrets it holds, expect this to be a regular event for the next seven weeks.'
    },

    thursday = {},

    friday = {
        host = 'Scribe Rob',
        datetime = '1779044400',
        title = "Bal Sunnah Conqueror Achievement (Taskmaster's Banner Skin)",
        description = 'Part of being an Arcanist is looking the part, tonight we head down to Veteran Bal Sunnar to get the last skin you will ever wear (bonus points for guessing the reference ;) )'
    },

    saturday = {},

    sunday = {
        host = 'Scribe Rob',
        datetime = '1777834800',
        title = 'The Night Market',
        description = 'The Night Market is Here! The Arcanists descend with the aim of unlocking the secrets it holds, expect this to be a regular event for the next seven weeks.'
    },
}
ArcTech.Events.CommencementLabel = "Events for week: " .. ArcTech.Events.CommencementDate

function InitArcTechEvents()
    local currentStr = ArcTech.Events.CommencementDate
    local previousStr = ArcTech.saved.lastCommencementDate

    local isNew = false

    if not previousStr then
        isNew = true
    elseif currentStr ~= previousStr then
        -- only then compare timestamps
        local currentDate = parseDate(currentStr)
        local previousDate = parseDate(previousStr)

        if currentDate and previousDate and currentDate > previousDate then
            isNew = true
        end
    end

    if isNew then
        ArcTech.Events.UpdatedMessage = "[ArcTech] New pages have been inscribed. The Events for the week have been updated."
    else
        ArcTech.Events.UpdatedMessage = nil
    end

    ArcTech.saved.lastCommencementDate = currentStr
end