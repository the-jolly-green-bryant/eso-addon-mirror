KinrasTracker = {}
KinrasTracker.name = "KinrasTracker"

function KinrasTracker.OnUpdate()
	local kinrasStacks = 0
    for i = 0, GetNumBuffs("player") do
        local _, _, _, _, stackCount, _, _, _, _, _, abilityId, _ = GetUnitBuffInfo("player", i)
        if abilityId == 150750 then
			kinrasStacks = stackCount
        end
    end
	KinrasTrackerControlText:SetText(kinrasStacks)
	if (kinrasStacks == 5) then
		KinrasTrackerControlText:SetColor(0, 1, 0, 1)
	else
		KinrasTrackerControlText:SetColor(1, 1, 1, 1)
	end
end
