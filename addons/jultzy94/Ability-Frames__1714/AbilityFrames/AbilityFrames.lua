--[[
	Ability Frames
    ----------------------------------------------------------
    Ability Frames is a frame boarder overhaul for The Elder Scrolls Online
	It replaces the standard borders for abilities and passives with new designs.

    The add-on features several components:
    (1) Frame Shapes
    (2) Aactive Ability Borders
    (3) Passive Ability Borders

    Author:   Jultzy
    Version:  1.0
    Updated:  2017-06-05
--]]

ab = {}
ab.name = "AbilityFrames"
ab.tag = "AbilityFrames"
ab.version = "1.0"
--ab.init = {}


--[[
function abreset()
-------------------------------------------------------------------------------------------------
--  Reset Functions -- UNUSED FOR NOW
-------------------------------------------------------------------------------------------------
--  Clean UI Reset --
		RedirectTexture("AbilityFrames/textures/Clean/cleanabilityframe_down.dds", "esoui/art/actionbar/abilityframe64_down.dds")
        RedirectTexture("AbilityFrames/textures/Clean/cleanabilityframe_up.dds", "esoui/art/actionbar/abilityframe64_up.dds")
		RedirectTexture("AbilityFrames/textures/Clean/cleanpassiveabilityframe_down.dds", "esoui/art/actionbar/passiveabilityframe_round_down.dds")
		RedirectTexture("AbilityFrames/textures/Clean/cleanpassiveabilityframe_empty.dds", "esoui/art/actionbar/passiveabilityframe_round_empty.dds")
		RedirectTexture("AbilityFrames/textures/Clean/cleanpassiveabilityframe_up.dds", "esoui/art/actionbar/passiveabilityframe_round_up.dds")

--  Orange UI Reset --
        RedirectTexture("AbilityFrames/textures/Orange/orangeabilityframe_down.dds", "esoui/art/actionbar/abilityframe64_down.dds")
        RedirectTexture("AbilityFrames/textures/Orange/orangeabilityframe_up.dds", "esoui/art/actionbar/abilityframe64_up.dds")
		RedirectTexture("AbilityFrames/textures/Orange/orangepassiveabilityframe_down.dds", "esoui/art/actionbar/passiveabilityframe_round_down.dds")
		RedirectTexture("AbilityFrames/textures/Orange/orangepassiveabilityframe_empty.dds", "esoui/art/actionbar/passiveabilityframe_round_empty.dds")
		RedirectTexture("AbilityFrames/textures/Orange/orangepassiveabilityframe_up.dds", "esoui/art/actionbar/passiveabilityframe_round_up.dds")

	end

--]]

-------------------------------------------------------------------------------------------------
--  UI Functions --
-------------------------------------------------------------------------------------------------

function abvanilla()

	RedirectTexture("esoui/art/actionbar/abilityframe64_down.dds", "esoui/art/actionbar/abilityframe64_down.dds")
	RedirectTexture("esoui/art/actionbar/abilityframe64_up.dds", "esoui/art/actionbar/abilityframe64_up.dds")
	RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_down.dds", "esoui/art/actionbar/passiveabilityframe_round_down.dds")
	RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_empty.dds", "esoui/art/actionbar/passiveabilityframe_round_empty.dds")
	RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_up.dds", "esoui/art/actionbar/passiveabilityframe_round_up.dds")
end

-------------------------------------------------------------------------------------------------
--  UI Chosen --
-------------------------------------------------------------------------------------------------
function ab.Initialize(eventCode, addOnName)

	-- Only set up for Ability Frames
    if addOnName ~= ab.name then return end
	
	-- Unregister setup event
	EVENT_MANAGER:UnregisterForEvent(ab.name, EVENT_ADD_ON_LOADED)
	
	-- Setup Menu Frame
	ab.Settings:Initialize()
	
	-- Call Texture Change Posibility
	abvanilla()
	
	
	local defaults = {
		Icon = "Vanilla Borders"
	}

	-- Load Saved Variable
    ab.SV = ZO_SavedVars:NewAccountWide('ab_Vars', ab.version, defaults, nil)
	
	-------------------------------------------------------------------------------------------------
	--  Active Ability Setup --
	-------------------------------------------------------------------------------------------------
	
	-- Standard Frames
	if ab.SV.IconA == "ESO Standard Borders" then
		ab.Vanilla:Initialize()
	end
	if ab.SV.IconA == "Clean Borders" then
		ab.Clean:Initialize()
	end
	if ab.SV.IconA == "Black Borders" then
		ab.Black:Initialize()
	end
	if ab.SV.IconA == "White Borders" then
		ab.White:Initialize()
	end
	
	-- Classic Frames
	if ab.SV.IconA == "Orange Borders" then
		ab.Orange:Initialize()
	end
	if ab.SV.IconA == "Orange2 Borders" then
		ab.Orange2:Initialize()
	end
	if ab.SV.IconA == "Brown Borders" then
		ab.Brown:Initialize()
	end
	
	-- Class Frames
	if ab.SV.IconA == "Dragonknight Borders" then
		ab.Dragonknight:Initialize()
	end
	if ab.SV.IconA == "Sorcerer Borders" then
		ab.Sorcerer:Initialize()
	end
	if ab.SV.IconA == "Templar Borders" then
		ab.Templar:Initialize()
	end
	if ab.SV.IconA == "Nightblade Borders" then
		ab.Nightblade:Initialize()
	end
	if ab.SV.IconA == "Warden Borders" then
		ab.Warden:Initialize()
	end
	
	-- Flag Frames
	if ab.SV.IconA == "Swedish Borders" then
		ab.Swedish:Initialize()
	end
	
	-- New Frames
	if ab.SV.IconA == "Yellow Borders" then
		ab.Yellow:Initialize()
	end
	if ab.SV.IconA == "Ice Borders" then
		ab.Ice:Initialize()
	end
	
	-- Guild Frames
	if ab.SV.IconA == "Fiskarna Borders" then
		ab.Fiskarna:Initialize()
	end
	
	-- Special Frames
	
	-------------------------------------------------------------------------------------------------
	--  Passive Ability Setup --
	-------------------------------------------------------------------------------------------------
	
	-- Standard Frames
	if ab.SV.IconP == "ESO Standard Borders" then
		ab.Vanilla:Initialize()
	end
	if ab.SV.IconP == "Clean Borders" then
		ab.Clean:Initialize()
	end
	if ab.SV.IconP == "Black Borders" then
		ab.Black:Initialize()
	end
	if ab.SV.IconP == "White Borders" then
		ab.White:Initialize()
	end
	
	-- Classic Frames
	if ab.SV.IconP == "Orange Borders" then
		ab.Orange:Initialize()
	end
	if ab.SV.IconP == "Orange2 Borders" then
		ab.Orange2:Initialize()
	end
	if ab.SV.IconP == "Brown Borders" then
		ab.Brown:Initialize()
	end
	
	-- Class Frames
	if ab.SV.IconP == "Dragonknight Borders" then
		ab.Dragonknight:Initialize()
	end
	if ab.SV.IconP == "Sorcerer Borders" then
		ab.Sorcerer:Initialize()
	end
	if ab.SV.IconP == "Templar Borders" then
		ab.Templar:Initialize()
	end
	if ab.SV.IconP == "Nightblade Borders" then
		ab.Nightblade:Initialize()
	end
	if ab.SV.IconP == "Warden Borders" then
		ab.Warden:Initialize()
	end
	
	-- Flag Frames
	if ab.SV.IconP == "Swedish Borders" then
		ab.Swedish:Initialize()
	end
	
	-- New Frames
	if ab.SV.IconP == "Yellow Borders" then
		ab.Yellow:Initialize()
	end
	if ab.SV.IconP == "Ice Borders" then
		ab.Ice:Initialize()
	end
	
	-- Guild Frames
	if ab.SV.IconP == "Fiskarna Borders" then
		ab.Fiskarna:Initialize()
	end
	
	-- Special Frames
end
  
EVENT_MANAGER:RegisterForEvent(ab.name, EVENT_ADD_ON_LOADED, ab.Initialize)