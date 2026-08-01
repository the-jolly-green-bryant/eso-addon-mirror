ZO_CreateStringId("SI_BINDING_NAME_JUMP_TO_GUILDHALL", "Springe zur Gildenhalle")
 
function VisitGuildhall_JumpToGuildhall()
	if GetDisplayName() == "@Stolli36" then
		RequestJumpToHouse(GetHousingPrimaryHouse(), false)
	else
		JumpToHouse("@Stolli36")
	end
end
