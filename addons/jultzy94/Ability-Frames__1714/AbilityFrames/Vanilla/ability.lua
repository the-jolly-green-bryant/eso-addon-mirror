local ab = ab
ab.Vanilla = {}

-------------------------------------------------------------------------------------------------
--  SET ACTIVE BORDERS --
-------------------------------------------------------------------------------------------------
function ab.Vanilla:Active()
	if ab.SV.IconAForm == false then
		RedirectTexture("esoui/art/actionbar/abilityframe64_down.dds", "esoui/art/actionbar/abilityframe64_down.dds")
		RedirectTexture("esoui/art/actionbar/abilityframe64_up.dds", "esoui/art/actionbar/abilityframe64_up.dds")
	else
		RedirectTexture("esoui/art/actionbar/abilityframe64_down.dds", "esoui/art/actionbar/passiveabilityframe_round_down.dds")
		RedirectTexture("esoui/art/actionbar/abilityframe64_up.dds", "esoui/art/actionbar/passiveabilityframe_round_up.dds")
	end
end

-------------------------------------------------------------------------------------------------
--  SET PASSIVE BORDERS --
-------------------------------------------------------------------------------------------------
function ab.Vanilla:Passive()
	if ab.SV.IconPForm == false then
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_down.dds", "esoui/art/actionbar/passiveabilityframe_round_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_empty.dds", "esoui/art/actionbar/passiveabilityframe_round_empty.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_up.dds", "esoui/art/actionbar/passiveabilityframe_round_up.dds")
	else
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_down.dds", "esoui/art/actionbar/abilityframe64_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_empty.dds", "esoui/art/actionbar/abilityframe64_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_up.dds", "esoui/art/actionbar/abilityframe64_up.dds")
	end
end

-------------------------------------------------------------------------------------------------
--  CALL FOR BORDERS --
-------------------------------------------------------------------------------------------------
function ab.Vanilla:Initialize()
	
	if ab.SV.IconA == "Vanilla Borders" then
		ab.Vanilla:Active()
	end

	if ab.SV.IconP == "Vanilla Borders" then
		ab.Vanilla:Passive()
	end
end