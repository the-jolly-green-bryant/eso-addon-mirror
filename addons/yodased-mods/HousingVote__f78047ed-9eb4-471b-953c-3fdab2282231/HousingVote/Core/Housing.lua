local HV = HousingVote

-- Returns houseId, houseName for the player's currently-set primary
-- residence, or nil if they haven't set one.
--
-- GetHousingPrimaryHouse() is confirmed against the live game source.
-- GetHouseName(houseId) is the commonly-documented name lookup but wasn't
-- independently confirmed here -- if it errors on load, check the ESOUI
-- "Houses" API page in-game with /script or the LibHouseVisited house-list
-- source for the current display-name accessor and swap it in below.
function HV.GetMyPrimaryHouse()
    local houseId = GetHousingPrimaryHouse()
    if not houseId or houseId == 0 then
        return nil, nil
    end

    local houseName
    local ok, result = pcall(GetHouseName, houseId)
    if ok and result and result ~= "" then
        houseName = result
    else
        houseName = zo_strformat("House <<1>>", houseId)
    end

    return houseId, houseName
end
