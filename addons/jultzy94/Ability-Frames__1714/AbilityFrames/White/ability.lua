local ab = ab
ab.White = {}

-------------------------------------------------------------------------------------------------
--  SET ACTIVE BORDERS --
-------------------------------------------------------------------------------------------------
function ab.White:Active()
	if ab.SV.IconAForm == false then
		RedirectTexture("esoui/art/actionbar/abilityframe64_down.dds", "AbilityFrames/White/texture/whiteabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/abilityframe64_up.dds", "AbilityFrames/White/texture/whiteabilityframe_up.dds")
	else
		RedirectTexture("esoui/art/actionbar/abilityframe64_down.dds", "AbilityFrames/White/texture/whitepassiveabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/abilityframe64_up.dds", "AbilityFrames/White/texture/whitepassiveabilityframe_up.dds")
	end
end

-------------------------------------------------------------------------------------------------
--  SET PASSIVE BORDERS --
-------------------------------------------------------------------------------------------------
function ab.White:Passive()
	if ab.SV.IconPForm == false then
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_down.dds", "AbilityFrames/White/texture/whitepassiveabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_empty.dds", "AbilityFrames/White/texture/whitepassiveabilityframe_empty.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_up.dds", "AbilityFrames/White/texture/whitepassiveabilityframe_up.dds")
	else
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_down.dds", "AbilityFrames/White/texture/whiteabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_empty.dds", "AbilityFrames/White/texture/whiteabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_up.dds", "AbilityFrames/White/texture/whiteabilityframe_up.dds")
	end
end

-------------------------------------------------------------------------------------------------
--  CALL FOR BORDERS --
-------------------------------------------------------------------------------------------------
function ab.White:Initialize()

	if ab.SV.IconA == "White Borders" then
		ab.White:Active()
	end

	if ab.SV.IconP == "White Borders" then
		ab.White:Passive()
	end
end