local ab = ab
ab.Nightblade = {}

-------------------------------------------------------------------------------------------------
--  SET ACTIVE BORDERS --
-------------------------------------------------------------------------------------------------
function ab.Nightblade:Active()
	if ab.SV.IconAForm == false then
		RedirectTexture("esoui/art/actionbar/abilityframe64_down.dds", "AbilityFrames/Nightblade/texture/nightbladeabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/abilityframe64_up.dds", "AbilityFrames/Nightblade/texture/nightbladeabilityframe_up.dds")
	else
		RedirectTexture("esoui/art/actionbar/abilityframe64_down.dds", "AbilityFrames/Nightblade/texture/nightbladepassiveabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/abilityframe64_up.dds", "AbilityFrames/Nightblade/texture/nightbladepassiveabilityframe_up.dds")
	end
end

-------------------------------------------------------------------------------------------------
--  SET PASSIVE BORDERS --
-------------------------------------------------------------------------------------------------
function ab.Nightblade:Passive()
	if ab.SV.IconPForm == false then
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_down.dds", "AbilityFrames/Nightblade/texture/nightbladepassiveabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_empty.dds", "AbilityFrames/Nightblade/texture/nightbladepassiveabilityframe_empty.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_up.dds", "AbilityFrames/Nightblade/texture/nightbladepassiveabilityframe_up.dds")
	else
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_down.dds", "AbilityFrames/Nightblade/texture/nightbladeabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_empty.dds", "AbilityFrames/Nightblade/texture/nightbladeabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_up.dds", "AbilityFrames/Nightblade/texture/nightbladeabilityframe_up.dds")
	end
end

-------------------------------------------------------------------------------------------------
--  CALL FOR BORDERS --
-------------------------------------------------------------------------------------------------
function ab.Nightblade:Initialize()
	
	if ab.SV.IconA == "Nightblade Borders" then
		ab.Nightblade:Active()
	end

	if ab.SV.IconP == "Nightblade Borders" then
		ab.Nightblade:Passive()
	end
end


