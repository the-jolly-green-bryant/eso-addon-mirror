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

ArcTech.QR = {data = "https://discord.gg/hj2eWtra66", size = 240}

function InitSavedVars()
    ArcTech.SV = ZO_SavedVars:NewAccountWide("ArcTechSavedVars", 1, nil, {
        events = {
            monday = "",
            tuesday = "",
            wednesday = "",
            thursday = "20:00 - Harrowstorms. Come and destroy the scourge of the Gray Host.",
            friday = "",
            saturday = "",
            sunday = "",
        },
    })
end