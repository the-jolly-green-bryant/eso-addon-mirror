-- A plugin for Research Assistant which adds items to the category only if they 
-- are marked as researchable by Reasearch Assistant (e.g. orange colored icon)
--
-- Just a simple function with no arguments

AutoCategory_ResearchAssistant = {
    RuleFunc = {},
}

--Initialize plugin for Auto Category - ResearchAssistant
function AutoCategory_ResearchAssistant.Initialize()
  if not ResearchAssistant then
        AutoCategory.AddRuleFunc("keepresearchassistant", AutoCategory.dummyRuleFunc)
        return
    end
    
    -- load supporting rule functions
    AutoCategory.AddRuleFunc("keepresearchassistant", AutoCategory_ResearchAssistant.RuleFunc.KeepResearchAsisstant)
    
end

-- Implement isresearch() check function for Research Assistant
function AutoCategory_ResearchAssistant.RuleFunc.KeepResearchAsisstant( ... )
  if ResearchAssistant == nil then
    return false
  end

  -- This can return true, false or "duplicate". 
  local research = ResearchAssistant.IsItemResearchableOrDuplicateWithSettingsCharacter(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
  if research == true then
    return true
  end
  return false
end

-- Register this plugin with AutoCategory to be initialized and used when AutoCategory loads.
AutoCategory.RegisterPlugin("ResearchAssistant", AutoCategory_ResearchAssistant.Initialize)
