local ab = ab
ab.Ice = {}

-------------------------------------------------------------------------------------------------
--  SET ACTIVE BORDERS --
-------------------------------------------------------------------------------------------------
function ab.Ice:Active()
	if ab.SV.IconAForm == false then
		RedirectTexture("esoui/art/actionbar/abilityframe64_down.dds", "AbilityFrames/Ice/texture/iceabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/abilityframe64_up.dds", "AbilityFrames/Ice/texture/iceabilityframe_up.dds")
	else
		RedirectTexture("esoui/art/actionbar/abilityframe64_down.dds", "AbilityFrames/Ice/texture/icepassiveabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/abilityframe64_up.dds", "AbilityFrames/Ice/texture/icepassiveabilityframe_up.dds")
	end
end

-------------------------------------------------------------------------------------------------
--  SET PASSIVE BORDERS --
-------------------------------------------------------------------------------------------------
function ab.Ice:Passive()
	if ab.SV.IconPForm == false then
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_down.dds", "AbilityFrames/Ice/texture/icepassiveabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_empty.dds", "AbilityFrames/Ice/texture/icepassiveabilityframe_empty.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_up.dds", "AbilityFrames/Ice/texture/icepassiveabilityframe_up.dds")
	else
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_down.dds", "AbilityFrames/Ice/texture/iceabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_empty.dds", "AbilityFrames/Ice/texture/iceabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_up.dds", "AbilityFrames/Ice/texture/iceabilityframe_up.dds")
	end
end

-------------------------------------------------------------------------------------------------
--  CALL FOR BORDERS --
-------------------------------------------------------------------------------------------------
function ab.Ice:Initialize()
	
	if ab.SV.IconA == "Ice Borders" then
		ab.Ice:Active()
	end

	if ab.SV.IconP == "Ice Borders" then
		ab.Ice:Passive()
	end
end


