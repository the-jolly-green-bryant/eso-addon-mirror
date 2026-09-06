local BA = BMGAdventures
BA.RegistryValidation = BA.RegistryValidation or {}

function BA.RegistryValidation:ValidateAll()
    local ids = {}
    local errors = {}
    for i, def in ipairs(BA.Challenges or {}) do
        if not def.id or def.id == "" then errors[#errors+1] = "challenge #"..i.." missing id" end
        if def.id and ids[def.id] then errors[#errors+1] = "duplicate id "..def.id end
        if def.id then ids[def.id] = true end
        if not def.activityType then errors[#errors+1] = tostring(def.id).." missing activityType" end
        if not def.goal or def.goal < 1 then errors[#errors+1] = tostring(def.id).." invalid goal" end
        if def.category ~= "ADV" and not BA.Disciplines[def.category] then errors[#errors+1] = tostring(def.id).." invalid category" end
        for _, unlockId in ipairs((def.rewards and def.rewards.unlocks) or {}) do
            if not BA.Rewards.unlocks[unlockId] and not BA.Rewards.titles[unlockId] and not BA.Rewards.badges[unlockId] then
                errors[#errors+1] = tostring(def.id).." unknown unlock "..tostring(unlockId)
            end
        end
    end
    if #BA.Challenges ~= 106 then errors[#errors+1] = "expected 106 challenges, found "..tostring(#BA.Challenges) end
    self.errors = errors
    if #errors > 0 then
        for _, err in ipairs(errors) do d("|cFF4444[BMG Adventures Registry]|r "..err) end
    end
end
