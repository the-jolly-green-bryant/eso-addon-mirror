LC = LC or {}
local LC = LC
LC.Common = {}

LC.Common.data = {
  hindered_effect = 165972, -- Heal absorption LC.Common.data.hindered_effect
}

function LC.Common.Hindered(result, targetType, targetUnitId, hitValue)
	  local isDPS, isHeal, isTank = GetPlayerRoles()
      if isHeal then
        if LC.savedVariables.showCommonHinderedAlertForHealers2 then
            local hinderedPlayersName = LC.units[targetUnitId].name

            if result == ACTION_RESULT_EFFECT_GAINED_DURATION or result == ACTION_RESULT_EFFECT_GAINED then
                if hinderedPlayersName ~= nil then
                    LCMessage2Label:SetText(hinderedPlayersName .. " Hindered!")
                    LCMessage2:SetHidden(not LC.savedVariables.showCommonHinderedAlertForHealers2)
                end
            elseif result == ACTION_RESULT_EFFECT_FADED then
                LCMessage2:SetHidden(true)
            end
        end
      end
end

function LC.Common.UpdateArrowStyle()

	LibSimpleArrowSlip.ApplyStyle(LC.name .. "/texture/arrow2.dds", LC.data.arrowColor, LC.data.arrowScale)

end

function LC.Common.InitializeSimpleArrow()

    LibSimpleArrowSlip.CreateTexture()
    LC.Common.UpdateArrowStyle()

end