local ab = ab
ab.Swedish = {}

-------------------------------------------------------------------------------------------------
--  SET ACTIVE BORDERS --
-------------------------------------------------------------------------------------------------
function ab.Swedish:Active()
	if ab.SV.IconAForm == false then
		RedirectTexture("esoui/art/actionbar/abilityframe64_down.dds", "AbilityFrames/Swedish/texture/swedishabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/abilityframe64_up.dds", "AbilityFrames/Swedish/texture/swedishabilityframe_up.dds")
	else
		RedirectTexture("esoui/art/actionbar/abilityframe64_down.dds", "AbilityFrames/Swedish/texture/swedishpassiveabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/abilityframe64_up.dds", "AbilityFrames/Swedish/texture/swedishpassiveabilityframe_up.dds")
	end
end

-------------------------------------------------------------------------------------------------
--  SET PASSIVE BORDERS --
-------------------------------------------------------------------------------------------------
function ab.Swedish:Passive()
	if ab.SV.IconPForm == false then
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_down.dds", "AbilityFrames/Swedish/texture/swedishpassiveabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_empty.dds", "AbilityFrames/Swedish/texture/swedishpassiveabilityframe_empty.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_up.dds", "AbilityFrames/Swedish/texture/swedishpassiveabilityframe_up.dds")
	else
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_down.dds", "AbilityFrames/Swedish/texture/swedishabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_empty.dds", "AbilityFrames/Swedish/texture/swedishabilityframe_down.dds")
		RedirectTexture("esoui/art/actionbar/passiveabilityframe_round_up.dds", "AbilityFrames/Swedish/texture/swedishabilityframe_up.dds")
	end
end

-------------------------------------------------------------------------------------------------
--  CALL FOR BORDERS --
-------------------------------------------------------------------------------------------------
function ab.Swedish:Initialize()
	
	if ab.SV.IconA == "Swedish Borders" then
		ab.Swedish:Active()
	end

	if ab.SV.IconP == "Swedish Borders" then
		ab.Swedish:Passive()
	end
end


