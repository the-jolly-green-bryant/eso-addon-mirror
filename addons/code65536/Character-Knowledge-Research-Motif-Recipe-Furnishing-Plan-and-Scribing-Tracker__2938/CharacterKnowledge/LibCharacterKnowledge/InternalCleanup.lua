-- Remove from the global namespace
LibCharacterKnowledgeInternal = nil

-- Prevent outside modification
LibCharacterKnowledge = LibCodesCommonCode.ReadOnlyTable(LibCharacterKnowledge)
