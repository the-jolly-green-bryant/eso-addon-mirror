if FCOStarveStop == nil then FCOStarveStop = {} end
local FCOSS = FCOStarveStop

------------------------------------------------------------------------------------------------------------
-- Other addons
------------------------------------------------------------------------------------------------------------
--Check for other addons
local function checkForOtherAddons()
    --Is addon AutoSlotSwitch loaded?
    FCOSS.otherAddons.autoSlotSwitch["isLoaded"] = (ASS ~= nil or AutoSlotSwitch ~= nil) or false
end

--Check if other addons are currently active
function FCOSS.checkIfOtherAddonsAreActive()
    --Check for other loaded addons
    checkForOtherAddons()
end
