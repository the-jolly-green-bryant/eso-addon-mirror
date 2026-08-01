EldenRingUI_CmxModule = {}
EldenRingUI_CmxModule.name = "EldenRingUI-CmxModule"

local defaults = {
    isVisible = true
}

function EldenRingUI_CmxModule.UpdateLiveDPS()
    local cmxTargetLabel = _G["CombatMetrics_LiveReportDamageOutSingleLabel"]
    
    if cmxTargetLabel and type(cmxTargetLabel.GetText) == "function" then
        local targetText = cmxTargetLabel:GetText()
        if targetText and targetText ~= "" then
            EldenRingUI_CmxModule_UILabel:SetText(targetText)
        else
            EldenRingUI_CmxModule_UILabel:SetText("0")
        end
    else
        EldenRingUI_CmxModule_UILabel:SetText("0")
    end
end

function EldenRingUI_CmxModule.ApplyPermanentGhosting()
    local cmxMainWindow = _G["CombatMetrics_LiveReport"]
    
    if cmxMainWindow then
        cmxMainWindow:SetAlpha(0)
        cmxMainWindow:SetMouseEnabled(false)
        
        ZO_PreHook(cmxMainWindow, "SetAlpha", function(self, alpha)
            if alpha > 0 then return true end 
        end)

        for i = 1, cmxMainWindow:GetNumChildren() do
            local child = cmxMainWindow:GetChild(i)
            
            child:SetAlpha(0)
            child:SetMouseEnabled(false)
            
            ZO_PreHook(child, "SetAlpha", function(self, alpha)
                if alpha > 0 then return true end
            end)
        end
    end
end

function EldenRingUI_CmxModule.UpdateVisibility()
    local sv = EldenRingUI_CmxModule.savedVariables
    local updateLoopName = EldenRingUI_CmxModule.name .. "UpdateLoop"
    
    if sv.isVisible then
        EldenRingUI_CmxModule_UI:SetHidden(false)
        HUD_SCENE:AddFragment(EldenRingUI_CmxModule.fragment)
        HUD_UI_SCENE:AddFragment(EldenRingUI_CmxModule.fragment)
        EVENT_MANAGER:RegisterForUpdate(updateLoopName, 500, EldenRingUI_CmxModule.UpdateLiveDPS)
    else
        HUD_SCENE:RemoveFragment(EldenRingUI_CmxModule.fragment)
        HUD_UI_SCENE:RemoveFragment(EldenRingUI_CmxModule.fragment)
        EldenRingUI_CmxModule_UI:SetHidden(true)
        EVENT_MANAGER:UnregisterForUpdate(updateLoopName)
    end
end

function EldenRingUI_CmxModule.ToggleTracker()
    local sv = EldenRingUI_CmxModule.savedVariables
    sv.isVisible = not sv.isVisible
    
    EldenRingUI_CmxModule.UpdateVisibility() 
    local stateText = sv.isVisible and "Shown" or "Hidden"
    CHAT_ROUTER:AddSystemMessage("[EldenRing CMX] Tracker is now: " .. stateText)
end

function EldenRingUI_CmxModule.OnAddOnLoaded(event, addonName)
    if addonName ~= EldenRingUI_CmxModule.name then return end
    EVENT_MANAGER:UnregisterForEvent(EldenRingUI_CmxModule.name, EVENT_ADD_ON_LOADED)
    
    EldenRingUI_CmxModule.savedVariables = ZO_SavedVars:NewAccountWide("EldenRingUI_CmxModule_SavedVariables", 1, nil, defaults)
    EldenRingUI_CmxModule.fragment = ZO_HUDFadeSceneFragment:New(EldenRingUI_CmxModule_UI)
    
    EldenRingUI_CmxModule.UpdateVisibility()
    SLASH_COMMANDS["/erdps"] = EldenRingUI_CmxModule.ToggleTracker
    
    zo_callLater(EldenRingUI_CmxModule.ApplyPermanentGhosting, 2000)
end

EVENT_MANAGER:RegisterForEvent(EldenRingUI_CmxModule.name, EVENT_ADD_ON_LOADED, EldenRingUI_CmxModule.OnAddOnLoaded)