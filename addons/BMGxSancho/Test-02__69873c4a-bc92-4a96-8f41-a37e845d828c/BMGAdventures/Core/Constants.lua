local BA = BMGAdventures
BA.Constants = BA.Constants or {}

function BA.Constants:Initialize()
    self.SCHEMA_VERSION = 1
    self.REGISTRY_VERSION = "2026.09.003"
    self.MAX_DIAGNOSTIC_EVENTS = 200
    self.DEV_EVIDENCE = "DEVELOPMENT"
    self.EVIDENCE = {
        NATIVE_RESULT = "NATIVE_RESULT",
        NATIVE_STATE = "NATIVE_STATE",
        CORRELATED = "CORRELATED",
        OBSERVED = "OBSERVED",
        DEVELOPMENT = "DEVELOPMENT",
    }
    self.DISCIPLINES = { "RAID", "DUNG", "EXPL", "QUEST", "PVP", "MAST" }
end
