function BCUI.Binds.SummonCompanion(companion,delay)
    if delay==nil then delay=0 end
    local companionCollectible = companion.id
    local isCollectibleUsable = IsCollectibleUsable(companionCollectible)
    local isCollectibleBlocked = IsCollectibleBlocked(companionCollectible)
    
    local collectableCooldownLeft = GetCollectibleCooldownAndDuration(companionCollectible)
    
    if not HasActiveCompanion() or BCUI.CompanionInfo.activeId ~= companion.id then d(BCUI.Loc("Summoning")..companion.name) end
    --d(companionCollectible)        
    if IsCollectibleUsable(companionCollectible) == true then
        if IsCollectibleBlocked(companionCollectible) then return end
        zo_callLater(function()
            EVENT_MANAGER:UnregisterForEvent("BCUI_Event", EVENT_UNIT_DESTROYED)
            UseCollectible(companionCollectible)
        end,
        collectableCooldownLeft + delay
        )
    end
end

function BCUI.Binds.SummonCompanionByIndex(id)    
    local ownedCompanions = {}
    for i, data in pairs(BCUI.CompanionInfo) do
        if i~="activeId" and BCUI.CompanionInfo[i].unlocked then table.insert(ownedCompanions,BCUI.CompanionInfo[i]) end
    end

    if id>1 and ownedCompanions~=nil then
        for i in pairs(ownedCompanions) do
            if ownedCompanions[i].index==id then companion=ownedCompanions[i] end
        end
        if not companion then
            --d(ownedCompanions)
            companion=ownedCompanions[math.random(1, #ownedCompanions)]
        end

        BCUI.Binds.SummonCompanion(companion)
    end
end

function BCUI.Binds.DismissCompanion(companion,delay)
    if delay==nil then delay=0 end
    local companionCollectible = companion.id
    local collectableCooldownLeft = 0
    
    if HasActiveCompanion() then 
        d(BCUI.Loc("Dismissing")..companion.name)
        --d(companionCollectible)        
        zo_callLater(function()
            EVENT_MANAGER:UnregisterForEvent("BCUI_Event", EVENT_UNIT_DESTROYED)
            UseCollectible(companionCollectible)
        end,
        collectableCooldownLeft + delay
        )    
    end
end

BCUI.Binds.Initialize = function()
  --d("BCUI_Companion_Binds_Initialized")
end