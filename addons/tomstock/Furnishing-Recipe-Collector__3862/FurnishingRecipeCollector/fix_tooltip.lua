-- If we overwrite this method directly, this error does not happen in gamepad.
--[[
  bad argument #2 to 'math.max' (number expected, got nil)
  |rstack traceback:
  [C]: in function 'math.max'
  EsoUI/Libraries/ZO_Tooltip/ZO_Tooltip.lua:742: in function 'ZO_TooltipSection:AddControl'
  |caaaaaa<Locals> self = ud, control = ud, spacing = 0 </Locals>|r
]]
local preventEndlessZO_TooltipSectionAddControlLoop = false
ZO_PreHook(ZO_TooltipSection, "AddControl", function(selfVar, control, primarySize, secondarySize, ...)
    if not preventEndlessZO_TooltipSectionAddControlLoop and (primarySize == nil or secondarySize == nil) then
        preventEndlessZO_TooltipSectionAddControlLoop = true
        primarySize = primarySize or 0
        secondarySize = secondarySize or 0
        selfVar:AddControl(control, primarySize, secondarySize, ...)
        preventEndlessZO_TooltipSectionAddControlLoop = false
        return true --Abort original func call
    end
    preventEndlessZO_TooltipSectionAddControlLoop = false
    return false --Call original func now
end)
