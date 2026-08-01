-- NOTE :
-- This is a template file !!
-- in this modified version, some global variables in the standard version have been stored in the gloval LorePlay table.
-- To maintain compatibility with the standard version, add the following header part to each lua file as needed.
-- Note that global variables defaultEmotesForDolmens and defaultEmotesForHousing have been converted to local variables.

--[[
LorePlay = LorePlay or {}
-- --- definitions : LPCategoryStrings.lua
local Appearance = LorePlay.Appearance
local Hats = LorePlay.Hats
local Costumes = LorePlay.Costumes
local Skins = LorePlay.Skins
local Polymorphs = LorePlay.Polymorphs
local Hair = LorePlay.Hair
local FacialAcc = LorePlay.FacialAcc
local FacialHair = LorePlay.FacialHair
local BodyMarkings = LorePlay.BodyMarkings
local HeadMarkings = LorePlay.HeadMarkings
local Jewelry = LorePlay.Jewelry
local Personalities = LorePlay.Personalities
local VanityPets = LorePlay.VanityPets
local City = LorePlay.City
local Housing = LorePlay.Housing
local Dungeon = LorePlay.Dungeon
local Adventure = LorePlay.Adventure
local Total = LorePlay.Total
local player = LorePlay.player
local stringToColTypeTable = LorePlay.stringToColTypeTable
-- ---
-- --- definitions : LPUtilities.lua
local EVENT_ACTIVE_EMOTE = LorePlay.EVENT_ACTIVE_EMOTE
local EVENT_ON_SMART_EMOTE = LorePlay.EVENT_ON_SMART_EMOTE
local EVENT_ON_IDLE_EMOTE = LorePlay.EVENT_ON_IDLE_EMOTE
local EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE = LorePlay.EVENT_PLEDGE_OF_MARA_RESULT_MARRIAGE
local EVENT_INDICATOR_MOVED = LorePlay.EVENT_INDICATOR_MOVED
local LPUtilities = LorePlay.LPUtilities
]]
-- ------------------------------------------------------------

-- === filename.lua ===
