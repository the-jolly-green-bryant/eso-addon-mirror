LanguageChanger = {}

ZO_CreateStringId("SI_BINDING_NAME_SET_ENGLISH", "Set language to english")
ZO_CreateStringId("SI_BINDING_NAME_SET_FRENCH", "Set language to french")
ZO_CreateStringId("SI_BINDING_NAME_SET_GERMAN", "Set language to german")

function LanguageChanger:SetEnglish()
  SetCVar("Language.2", "en")
end

function LanguageChanger:SetGerman()
  SetCVar("Language.2", "de")
end

function LanguageChanger:SetFrench()
  SetCVar("Language.2", "fr")
end

function LanguageChanger:Initialize(eventType, addonName)
 d("Initializing.")
end