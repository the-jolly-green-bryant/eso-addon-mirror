LazyConfirm = {}

LazyConfirm.name = "LazyConfirm"

local original = ZO_Dialogs_ShowDialog 
local function hook(...)
    zo_callLater(function()
        if ZO_Dialog1 and ZO_Dialog1.textParams and ZO_Dialog1.textParams.mainTextParams then
            local itemName= ZO_Dialog1.textParams.mainTextParams[1]
            if  true then
                for k, v in pairs(ZO_Dialog1.textParams.mainTextParams) do
                    if v == string.upper(v) then
                        ZO_Dialog1EditBox:SetText(v)
                    end
                end
                
                ZO_Dialog1EditBox:LoseFocus()
            end
        end
    end, 10)
end
ZO_PreHook("ZO_Dialogs_ShowDialog", hook)

function LazyConfirm.OnAddOnLoaded(event, addonName)
  if addonName == LazyConfirm.name then
    
  end
end

function LazyConfirm.ConsoleLoaded(event, initial)
    EVENT_MANAGER:UnregisterForEvent(LazyConfirm.name, EVENT_PLAYER_ACTIVATE)
    if IsConsoleUI() then
        local originalTrigger = KEYBIND_STRIP.TriggerCooldown
        KEYBIND_STRIP.TriggerCooldown = function(self, keybindDesc, onShowCooldown, g_keybindState)
            if true then
                return
            end
        end
    end
end
EVENT_MANAGER:RegisterForEvent(LazyConfirm.name, EVENT_PLAYER_ACTIVATED, LazyConfirm.ConsoleLoaded)
EVENT_MANAGER:RegisterForEvent(LazyConfirm.name, EVENT_ADD_ON_LOADED, LazyConfirm.OnAddOnLoaded)

--[12:33] [Bleakrock Barter Co] [lord healer the great@sol0]: or worse yet typing in lowercase
--[12:34] [Bleakrock Barter Co] [lord healer the great@sol0]: fuck my life  I TYPE IN CAPS MOST OF THE TIME