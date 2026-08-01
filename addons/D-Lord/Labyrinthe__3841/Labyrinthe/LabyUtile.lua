function LabyODD.Temps(tempsTotal)
    local seconde = tempsTotal%60
    local tempsSansSeconde = tempsTotal - seconde
    local minute = (tempsSansSeconde/60)%60
    local tempsSansMinute = tempsSansSeconde - minute*60
    local heure = tempsSansMinute/3600
    return heure.."h "..minute.."min "..seconde.."s"
end

ODDLabyFurnitureId = nil

function LabyODDTest()
    ODDLabyFurnitureId = GetNextPlacedHousingFurnitureId(ODDLabyFurnitureId)
end
