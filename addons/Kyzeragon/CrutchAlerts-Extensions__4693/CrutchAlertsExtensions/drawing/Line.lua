local CAE = CrutchAlertsExtensions
local Crutch = CrutchAlerts


---------------------------------------------------------------------
local LINE_NUM = "CAETempLine"
function CAE.DrawLine(tag1, tag2)
    if (not tag1 or not tag2) then return end

    Crutch.RemoveLine(LINE_NUM)
    Crutch.SetLineColor(1, 0, 0, 1, 1, Crutch.savedOptions.debugLineDistance, LINE_NUM)
    Crutch.DrawLineBetweenPlayers(tag1, tag2, nil, LINE_NUM)
end

function CAE.RemoveLine()
    Crutch.RemoveLine(LINE_NUM)
end
