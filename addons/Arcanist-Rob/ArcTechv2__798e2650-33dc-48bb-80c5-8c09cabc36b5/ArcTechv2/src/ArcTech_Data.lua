-- ArcTech_Data.lua
local ArcTech = ArcTech

ArcTech.house_owner = "@Scribe Rob"
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
    CommencementDate = "06-04-2026",

    monday = {},

    tuesday = {
        host = 'Scribe Rob',
        datetime = '1775598000',
        title = 'Harrowstorms',
        description = 'Pages torn and knowledge scattered. We descend as Arcanists to bind the storms and return what belongs to Mora.'
    },

    wednesday = {},

    thursday = {
        host = 'Scribe Rob',
        datetime = '1775761200',
        title = 'Free Choice Thursday',
        description = 'The tome lies open. Gather, decide, and inscribe the night’s path together. Your choices become the story.'
    },

    friday = {
        host = 'Aka Pixel Chick',
        datetime = '1729710000',
        title = 'Veteran Hel\'Ra Citadel / Aetherian Archive',
        description = 'Ancient knowledge awaits. We step into forgotten halls, ink ready, to claim victory in true Arcanist fashion.'
    },

    saturday = {},
    sunday = {},
}
ArcTech.Events.CommencementLabel = "Events for week: " .. ArcTech.Events.CommencementDate

function InitArcTechEvents()
    local currentDate = parseDate(ArcTech.Events.CommencementDate)
    local previousDate = ArcTech.saved.lastCommencementDate and parseDate(ArcTech.saved.lastCommencementDate)

    if not previousDate or currentDate > previousDate then
        ArcTech.Events.UpdatedMessage = "[ArcTech] New pages have been inscribed. The Events for the week have been updated."
    else
        ArcTech.Events.UpdatedMessage = nil
    end

    ArcTech.saved.lastCommencementDate = ArcTech.Events.CommencementDate
end