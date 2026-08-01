SetContainerCollector = SetContainerCollector or {}
local SCC = SetContainerCollector
SCC.Data = SCC.Data or {}

local RS = SCC.Data.RegisterSets
local RP = SCC.Data.RegisterPool
local SHOULDER = EQUIP_TYPE_SHOULDERS

-- Source: https://en.uesp.net/wiki/Online:Pledge_Masters
RP(153513, "maj_mystery", "Maj's Mystery Coffer")
RP(153514, "glirion_mystery", "Glirion's Mystery Coffer")
RP(153515, "urgarlag_mystery", "Urgarlag's Mystery Coffer")

local CURATED_COFFERS = {
  { 211131, "Curated Banished Cells Coffer", { 265, 170 } },
  { 211132, "Curated Darkshade Caverns Coffer", { 268, 166 } },
  { 211133, "Curated Elden Hollow Coffer", { 269, 167 } },
  { 211134, "Curated Fungal Grotto Coffer", { 266, 162 } },
  { 211135, "Curated Spindleclutch Coffer", { 267, 163 } },
  { 211136, "Curated Wayrest Coffer", { 270, 165 } },
  { 211137, "Curated City of Ash Coffer", { 272, 169 } },
  { 211138, "Curated Crypt of Hearts Coffer", { 273, 168 } },
  { 211139, "Curated Serpents and Sailors Coffer", { 271, 277 } },
  { 211140, "Curated Frigid Crucible Coffer", { 278, 274 } },
  { 211141, "Curated Winds and Webs Coffer", { 279, 275 } },
  { 211142, "Curated Sands and Madness Coffer", { 276, 280 } },
  { 211143, "Curated Imperial City Coffer", { 164, 183 } },
  { 211144, "Curated Shadows of the Hist Coffer", { 257, 256 } },
  { 211145, "Curated Horns of the Reach Coffer", { 341, 342 } },
  { 211146, "Curated Dragon Bones Coffer", { 349, 350 } },
  { 211147, "Curated Wolfhunter Coffer", { 398, 397 } },
  { 211148, "Curated Wrathstone Coffer", { 436, 432 } },
  { 211149, "Curated Scalebreaker Coffer", { 458, 459 } },
  { 211150, "Curated Harrowstorm Coffer", { 478, 479 } },
  { 211151, "Curated Stonethorn Coffer", { 534, 535 } },
  { 211152, "Curated Flames of Ambition Coffer", { 577, 578 } },
  { 211153, "Curated Waking Flame Coffer", { 608, 609 } },
  { 211154, "Curated Ascending Tide Coffer", { 633, 632 } },
  { 211155, "Curated Lost Depths Coffer", { 666, 667 } },
  { 211156, "Curated Scribes of Fate Coffer", { 683, 687 } },
  { 211157, "Curated Scions of Ithelia Coffer", { 734, 738 } },
  { 214317, "Curated Fallen Banners Coffer", { 797, 801 } },
  { 219848, "Curated Feast of Shadows Coffer", { 828, 829 } },
}

for _, entry in ipairs(CURATED_COFFERS) do
  RS(entry[1], entry[2], entry[3], { equipSlot = SHOULDER })
end
