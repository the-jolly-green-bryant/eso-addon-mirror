local BA = BMGAdventures
BA.Migrations = BA.Migrations or {}

function BA.Migrations:Run()
    if not BA.account then return end
    local version = tonumber(BA.account.schemaVersion) or 0
    if version < 1 then version = 1 end
    if version < 2 then
        BA.account.legacyImport = BA.account.legacyImport or {}
        BA.account.legacyImport.version = BA.account.legacyImport.version or 0
        BA.account.legacyImport.completed = BA.account.legacyImport.completed or false
        BA.account.legacyImport.achievements = BA.account.legacyImport.achievements or {}
        BA.account.legacyImport.mappedIds = BA.account.legacyImport.mappedIds or {}
        BA.account.legacyImport.stats = BA.account.legacyImport.stats or {}
        BA.account.legacyImport.mapped = BA.account.legacyImport.mapped or 0
        version = 2
    end
    BA.account.schemaVersion = version
    BA.account.registryVersion = BA.Constants.REGISTRY_VERSION
end
