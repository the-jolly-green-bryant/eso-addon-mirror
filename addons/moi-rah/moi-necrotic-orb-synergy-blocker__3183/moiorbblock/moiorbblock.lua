OrbBlocker = OrbBlocker or {}
local OB = OrbBlocker

function OB.OrbBlocker(_,addonName)
   ZO_PreHook(SYNERGY, 'OnSynergyAbilityChanged',
              function()
                 local name, icon = GetSynergyInfo()

                 if name and icon then
                    if icon == "/esoui/art/icons/ability_undaunted_004.dds" or
                       icon == "/esoui/art/icons/ability_undaunted_004b.dds" then

                       SYNERGY.lastSynergyName = ""
                       SYNERGY:SetHidden(true)
                       return true

                    end
                 end
              end
   )
end

EVENT_MANAGER:RegisterForEvent("moiorbblock", EVENT_ADD_ON_LOADED, OB.OrbBlocker)

