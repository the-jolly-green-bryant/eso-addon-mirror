local ab = ab
ab.Dragonknight = {}

-------------------------------------------------------------------------------------------------
--  SET ACTIVE BORDERS --
-------------------------------------------------------------------------------------------------
function ab.Dragonknight:Active()
	if ab.SV.IconAForm == false then
		RedirectTexture("esoui/art/actionbar/abilityframe64_down.dds", "AbilityFrames/Dragonknight/texture/dragonknightabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/abilityframe64_up.dds", "AbilityFrames/Dragonknight/texture/dragonknightabilityframe_up.dds")
	else
		RedirectTexture("esoui/art/actionbar/abilityframe64_down.dds", "AbilityFrames/Dragonknight/texture/dragonknightpassiveabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/abilityframe64_up.dds", "AbilityFrames/Dragonknight/texture/dragonknightpassiveabilityframe_up.dds")
	end
end

-------------------------------------------------------------------------------------------------
--  SET PASSIVE BORDERS --
-------------------------------------------------------------------------------------------------
function ab.Dragonknight:Passive()
	if ab.SV.IconPForm == false then
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_down.dds", "AbilityFrames/Dragonknight/texture/dragonknightpassiveabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_empty.dds", "AbilityFrames/Dragonknight/texture/dragonknightpassiveabilityframe_empty.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_up.dds", "AbilityFrames/Dragonknight/texture/dragonknightpassiveabilityframe_up.dds")
	else
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_down.dds", "AbilityFrames/Dragonknight/texture/dragonknightabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_empty.dds", "AbilityFrames/Dragonknight/texture/dragonknightabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_up.dds", "AbilityFrames/Dragonknight/texture/dragonknightabilityframe_up.dds")
	end
end

-------------------------------------------------------------------------------------------------
--  CALL FOR BORDERS --
-------------------------------------------------------------------------------------------------
function ab.Dragonknight:Initialize()
	
	if ab.SV.IconA == "Dragonknight Borders" then
		ab.Dragonknight:Active()
	end

	if ab.SV.IconP == "Dragonknight Borders" then
		ab.Dragonknight:Passive()
	end
end


