local SRC = SupportRotationCallouts
local Diagnostics = SRC.Diagnostics

if not Diagnostics then return end

Diagnostics.DEVELOPER_PAGE_SIZE = 22

local function SortedKeys(map)
    local keys = {}
    for key in pairs(map or {}) do keys[#keys + 1] = key end
    table.sort(keys)
    return keys
end

local function EntryName(entry)
    return tostring(entry and (entry.name or entry.displayName or entry.key or entry.id) or "Unknown")
end

local function Join(values, separator)
    local output = {}
    for _, value in ipairs(values or {}) do output[#output + 1] = tostring(value) end
    return table.concat(output, separator or ", ")
end

local function ContextText(context)
    local parts = {}
    for _, key in ipairs(SortedKeys(context or {})) do
        parts[#parts + 1] = tostring(key) .. "=" .. tostring(context[key])
    end
    return table.concat(parts, " ")
end

function Diagnostics:SetDeveloperPage(title, lines, footer)
    self.developerTitle = title or "DEVELOPER TOOLS"
    self.developerLines = lines or {}
    self.developerFooter = footer or ""
    self.developerPage = 1
    self:RefreshDeveloperPage()
end

function Diagnostics:RefreshDeveloperPage()
    if not self.viewer or not self.developerLines then return end
    local lines = self.developerLines
    local pageSize = self.DEVELOPER_PAGE_SIZE or 22
    local pageCount = zo_max(1, math.ceil(#lines / pageSize))
    self.developerPage = zo_clamp(self.developerPage or 1, 1, pageCount)
    local first = ((self.developerPage - 1) * pageSize) + 1
    local last = zo_min(#lines, first + pageSize - 1)
    local pageLines = {}
    for index = first, last do pageLines[#pageLines + 1] = lines[index] end

    self:ActivateViewer()
    self.viewerTitle:SetText(self.developerTitle or "DEVELOPER TOOLS")
    self.viewerBody:SetText(#pageLines > 0 and table.concat(pageLines, "\n") or "No data available.")
    local pageText = string.format("Page %d / %d", self.developerPage, pageCount)
    if self.developerFooter and self.developerFooter ~= "" then pageText = pageText .. "    " .. self.developerFooter end
    self.viewerFooter:SetText(pageText)
    self:UpdateViewerKeybinds(true)
end

function Diagnostics:ChangeDeveloperPage(delta)
    if not self.developerLines then return end
    self.developerPage = zo_max(1, (self.developerPage or 1) + (delta or 0))
    self:RefreshDeveloperPage()
end

function Diagnostics:HideDeveloperPage()
    self:CloseActiveViewer()
end

function Diagnostics:GetKnowledgeBaseLines()
    local lines = { "KNOWLEDGE BASE HEALTH" }
    local snapshot = SRC.KnowledgeDiagnostics and SRC.KnowledgeDiagnostics:GetSnapshot() or {}
    lines[#lines + 1] = ""
    lines[#lines + 1] = string.format("Platform version: %s", tostring(snapshot.platformVersion or SRC.version or "Unknown"))
    lines[#lines + 1] = string.format("Registry schema: %s", tostring(snapshot.registrySchemaVersion or "Unknown"))
    lines[#lines + 1] = string.format("Current API / patch: %s", tostring(snapshot.currentPatch or "Unknown"))
    lines[#lines + 1] = string.format("Health: %s", snapshot.healthy and "PASS" or "REVIEW REQUIRED")
    lines[#lines + 1] = ""
    lines[#lines + 1] = string.format("Collections: %d", tonumber(snapshot.collections) or 0)
    lines[#lines + 1] = string.format("Total entries: %d", tonumber(snapshot.entries) or 0)
    lines[#lines + 1] = string.format("Effects: %d", tonumber(snapshot.effects) or 0)
    lines[#lines + 1] = string.format("Providers: %d", tonumber(snapshot.providers) or 0)
    lines[#lines + 1] = string.format("Responsibilities: %d", tonumber(snapshot.responsibilities) or 0)
    lines[#lines + 1] = string.format("Indexed effects: %d", tonumber(snapshot.indexedEffects) or 0)
    lines[#lines + 1] = string.format("Indexed providers: %d", tonumber(snapshot.indexedProviders) or 0)
    lines[#lines + 1] = string.format("Entries needing ID validation: %d", tonumber(snapshot.unverified) or 0)
    lines[#lines + 1] = ""
    lines[#lines + 1] = string.format("Errors: %d", tonumber(snapshot.errors) or 0)
    lines[#lines + 1] = string.format("Warnings: %d", tonumber(snapshot.warnings) or 0)
    lines[#lines + 1] = string.format("Unresolved providers: %d", tonumber(snapshot.unresolvedProviders) or 0)
    lines[#lines + 1] = ""
    lines[#lines + 1] = "This page reports what Conductor loaded, indexed, and validated."
    return lines
end

function Diagnostics:ShowKnowledgeBaseHealth()
    self:SetDeveloperPage("KNOWLEDGE BASE", self:GetKnowledgeBaseLines(), "Developer Tools")
end

function Diagnostics:GetValidationLines()
    local report = SRC.KnowledgeValidation and SRC.KnowledgeValidation:GetReport() or {errors={},warnings={},unresolvedProviders={}}
    local lines = { "VALIDATION RESULTS", "" }
    lines[#lines + 1] = string.format("Errors: %d", #(report.errors or {}))
    lines[#lines + 1] = string.format("Warnings: %d", #(report.warnings or {}))
    lines[#lines + 1] = string.format("Unresolved providers: %d", #(report.unresolvedProviders or {}))
    lines[#lines + 1] = ""

    if #(report.errors or {}) == 0 then
        lines[#lines + 1] = "ERROR CHECKS: PASS"
    else
        lines[#lines + 1] = "ERRORS"
        for index, issue in ipairs(report.errors or {}) do
            lines[#lines + 1] = string.format("%d. [%s] %s", index, tostring(issue.code or "ERROR"), tostring(issue.message or "Unknown error"))
            local context = ContextText(issue.context)
            if context ~= "" then lines[#lines + 1] = "   " .. context end
        end
    end

    lines[#lines + 1] = ""
    if #(report.warnings or {}) == 0 then
        lines[#lines + 1] = "WARNING CHECKS: PASS"
    else
        lines[#lines + 1] = "WARNINGS"
        for index, issue in ipairs(report.warnings or {}) do
            lines[#lines + 1] = string.format("%d. [%s] %s", index, tostring(issue.code or "WARNING"), tostring(issue.message or "Unknown warning"))
            local context = ContextText(issue.context)
            if context ~= "" then lines[#lines + 1] = "   " .. context end
        end
    end
    return lines
end

function Diagnostics:RunAndShowValidation()
    local started = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
    if SRC.KnowledgeValidation and SRC.KnowledgeValidation.Run then SRC.KnowledgeValidation:Run() end
    if SRC.KnowledgeBase and SRC.KnowledgeBase.RebuildIndexes then SRC.KnowledgeBase:RebuildIndexes() end
    local finished = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or started
    SRC.saved.lastKnowledgeValidationMs = zo_max(0, finished - started)
    self:SetDeveloperPage("KNOWLEDGE VALIDATION", self:GetValidationLines(), string.format("Validation %d ms", SRC.saved.lastKnowledgeValidationMs or 0))
end

function Diagnostics:GetRegistryCollectionItems()
    local items = {}
    for _, collectionName in ipairs(SortedKeys(SRC.Registry and SRC.Registry.collections or {})) do
        items[#items + 1] = { name = collectionName, data = collectionName }
    end
    if #items == 0 then items[1] = { name = "No collections", data = "" } end
    return items
end

function Diagnostics:GetRegistryLines(collectionName)
    collectionName = collectionName or SRC.saved.developerRegistryCollection or "EFFECTS"
    local entries = SRC.Registry and SRC.Registry:GetAll(collectionName, true) or {}
    table.sort(entries, function(a, b) return EntryName(a) < EntryName(b) end)
    local lines = { tostring(collectionName) .. " REGISTRY", string.format("Entries: %d", #entries), "" }
    for _, entry in ipairs(entries) do
        local state = entry.status or "ACTIVE"
        local verification = entry.needsIdValidation and "ID REVIEW" or "VERIFIED / NOT FLAGGED"
        lines[#lines + 1] = string.format("%s", EntryName(entry))
        lines[#lines + 1] = string.format("  ID: %s", tostring(entry.id or entry.key or "Unknown"))
        lines[#lines + 1] = string.format("  Status: %s | %s", tostring(state), verification)
        if entry.effectKey then lines[#lines + 1] = "  Effect: " .. tostring(entry.effectKey) end
        if entry.provides and #entry.provides > 0 then lines[#lines + 1] = "  Provides: " .. Join(entry.provides) end
        if entry.providers and #entry.providers > 0 then lines[#lines + 1] = "  Providers: " .. Join(entry.providers) end
        if entry.abilityId then lines[#lines + 1] = "  Ability ID: " .. tostring(entry.abilityId) end
        if entry.setId then lines[#lines + 1] = "  Set ID: " .. tostring(entry.setId) end
        if entry.lastVerifiedPatch then lines[#lines + 1] = "  Last verified: " .. tostring(entry.lastVerifiedPatch) end
        lines[#lines + 1] = ""
    end
    return lines
end

function Diagnostics:ShowSelectedRegistry()
    local collection = SRC.saved.developerRegistryCollection or "EFFECTS"
    self:SetDeveloperPage(collection .. " REGISTRY", self:GetRegistryLines(collection), "Alphabetical registry explorer")
end

function Diagnostics:GetResponsibilityLines()
    local lines = { "RESPONSIBILITY EXPLORER", "" }
    local responsibilities = SRC.Registry and SRC.Registry:GetAll("RESPONSIBILITIES", true) or {}
    table.sort(responsibilities, function(a, b) return EntryName(a) < EntryName(b) end)
    for _, responsibility in ipairs(responsibilities) do
        local providers = SRC.KnowledgeBase and SRC.KnowledgeBase:GetProvidersForResponsibility(responsibility.key, true) or {}
        lines[#lines + 1] = EntryName(responsibility)
        lines[#lines + 1] = "  ID: " .. tostring(responsibility.id or responsibility.key)
        lines[#lines + 1] = "  Effect: " .. tostring(responsibility.effectKey or "None")
        lines[#lines + 1] = "  Required by default: " .. (responsibility.requiredByDefault and "YES" or "NO")
        lines[#lines + 1] = "  Acceptable providers: " .. tostring(#providers)
        for _, provider in ipairs(providers) do
            lines[#lines + 1] = string.format("    - %s [%s]", EntryName(provider), tostring(provider.sourceRegistry or provider.registry or "Unknown"))
        end
        lines[#lines + 1] = ""
    end
    return lines
end

function Diagnostics:ShowResponsibilities()
    self:SetDeveloperPage("RESPONSIBILITIES", self:GetResponsibilityLines(), "Responsibility -> effect -> provider")
end

local function MatchesLookup(entry, query)
    local lower = string.lower(query or "")
    if lower == "" then return false end
    local fields = { entry.key, entry.id, entry.name, entry.displayName, entry.abilityId, entry.setId, entry.effectKey, entry.sourceKey }
    for _, value in ipairs(fields) do
        if value ~= nil and string.find(string.lower(tostring(value)), lower, 1, true) then return true end
    end
    for _, value in ipairs(entry.provides or {}) do
        if string.find(string.lower(tostring(value)), lower, 1, true) then return true end
    end
    for _, value in ipairs(entry.providers or {}) do
        if string.find(string.lower(tostring(value)), lower, 1, true) then return true end
    end
    return false
end

function Diagnostics:GetLookupLines(query)
    query = zo_strtrim(query or "")
    local lines = { "KNOWLEDGE LOOKUP", "Query: " .. (query ~= "" and query or "(empty)"), "" }
    if query == "" then
        lines[#lines + 1] = "Enter a name, stable ID, Ability ID, Set ID, effect, or provider key."
        return lines
    end

    local matches = 0
    for _, collectionName in ipairs(SortedKeys(SRC.Registry and SRC.Registry.collections or {})) do
        for _, entry in ipairs(SRC.Registry:GetAll(collectionName, true)) do
            if MatchesLookup(entry, query) then
                matches = matches + 1
                lines[#lines + 1] = string.format("%s | %s", collectionName, EntryName(entry))
                lines[#lines + 1] = "  Stable ID: " .. tostring(entry.id or entry.key)
                if entry.abilityId then lines[#lines + 1] = "  Ability ID: " .. tostring(entry.abilityId) end
                if entry.setId then lines[#lines + 1] = "  Set ID: " .. tostring(entry.setId) end
                if entry.effectKey then lines[#lines + 1] = "  Effect: " .. tostring(entry.effectKey) end
                if entry.provides and #entry.provides > 0 then lines[#lines + 1] = "  Provides: " .. Join(entry.provides) end
                if entry.providers and #entry.providers > 0 then lines[#lines + 1] = "  Providers: " .. Join(entry.providers) end
                lines[#lines + 1] = "  ID validation: " .. (entry.needsIdValidation and "REQUIRED" or "NOT FLAGGED")
                lines[#lines + 1] = ""
            end
        end
    end
    if matches == 0 then lines[#lines + 1] = "No registry matches found." end
    lines[3] = string.format("Matches: %d", matches)
    return lines
end

function Diagnostics:RunKnowledgeLookup()
    local query = SRC.saved.developerLookupQuery or ""
    self:SetDeveloperPage("KNOWLEDGE LOOKUP", self:GetLookupLines(query), "Search all registries")
end

function Diagnostics:GetPerformanceLines()
    local lines = { "PERFORMANCE AND FOUNDATIONS", "" }
    lines[#lines + 1] = string.format("Last manual validation: %d ms", tonumber(SRC.saved.lastKnowledgeValidationMs) or 0)
    local registryStats = SRC.Registry and SRC.Registry:GetStatistics() or {}
    lines[#lines + 1] = string.format("Registry entries: %d active / %d removed", tonumber(registryStats.active) or 0, tonumber(registryStats.removed) or 0)
    lines[#lines + 1] = string.format("Entries needing ID validation: %d", tonumber(registryStats.needsIdValidation) or 0)
    lines[#lines + 1] = ""
    for _, line in ipairs(self:GetNetworkSummaryLines()) do lines[#lines + 1] = line end
    local share = Conductor.SessionShareDiagnostics and Conductor.SessionShareDiagnostics:GetSnapshot() or {}
    lines[#lines + 1] = ""
    lines[#lines + 1] = "RAID SESSION TRANSFER"
    lines[#lines + 1] = "State: " .. tostring(share.state or "IDLE")
    lines[#lines + 1] = "Direction: " .. tostring(share.direction or "NONE")
    lines[#lines + 1] = string.format("Chunks: %d / %d", tonumber(share.chunksReceived) or 0, tonumber(share.chunksExpected) or 0)
    lines[#lines + 1] = string.format("Bytes: %d / %d", tonumber(share.bytesReceived) or 0, tonumber(share.bytesExpected) or 0)
    if tostring(share.failureReason or "") ~= "" then lines[#lines + 1] = "Failure: " .. tostring(share.failureReason) end
    lines[#lines + 1] = ""
    lines[#lines + 1] = "EVENT TRACE FOUNDATION"
    lines[#lines + 1] = "Logging mode: " .. tostring(self:GetMode())
    lines[#lines + 1] = "Active session: " .. (self:GetActiveSession() and tostring(self:GetActiveSession().name) or "None")
    lines[#lines + 1] = string.format("Live diagnostic lines retained: %d", #(self.lines or {}))
    return lines
end

function Diagnostics:ShowPerformanceFoundations()
    self:SetDeveloperPage("PERFORMANCE / NETWORK", self:GetPerformanceLines(), "Foundation metrics")
end

function Diagnostics:GetProviderMappingAuditLines()
    local lines = { "PROVIDER MAPPING AUDIT", "" }
    local unresolved, reverseMissing, verified = 0, 0, 0
    local registries = { "PROVIDERS", "SKILLS", "ULTIMATES", "GEAR", "MONSTER_SETS", "ENCHANTMENTS", "MASTERIES", "SCRIBED_ABILITIES" }
    local function FindProvider(key)
        for _, registry in ipairs(registries) do
            local entry = Conductor.Registry and Conductor.Registry:Get(registry, key)
            if entry then return entry, registry end
        end
        return nil, nil
    end
    for _, effect in ipairs(Conductor.Registry and Conductor.Registry:GetAll("EFFECTS") or {}) do
        for _, providerKey in ipairs(effect.providers or {}) do
            local provider, registry = FindProvider(providerKey)
            if not provider then
                unresolved = unresolved + 1
                lines[#lines + 1] = string.format("UNRESOLVED  %s <- %s", tostring(effect.name or effect.key), tostring(providerKey))
            else
                local found = false
                for _, providedEffect in ipairs(provider.provides or {}) do if providedEffect == effect.key then found = true break end end
                if found then verified = verified + 1
                else
                    reverseMissing = reverseMissing + 1
                    lines[#lines + 1] = string.format("REVERSE MAP MISSING  %s <- %s [%s]", tostring(effect.name or effect.key), tostring(provider.name or providerKey), tostring(registry))
                end
            end
        end
    end
    table.insert(lines, 2, string.format("Verified relationships: %d", verified))
    table.insert(lines, 3, string.format("Unresolved providers: %d", unresolved))
    table.insert(lines, 4, string.format("Missing reverse mappings: %d", reverseMissing))
    table.insert(lines, 5, "")
    if unresolved == 0 and reverseMissing == 0 then lines[#lines + 1] = "All registered effect/provider relationships passed structural validation." end
    lines[#lines + 1] = ""
    lines[#lines + 1] = "Structural validation does not replace live Ability ID and patch verification. Entries flagged for ID validation remain research items."
    return lines
end

function Diagnostics:ShowProviderMappingAudit()
    self:SetDeveloperPage("PROVIDER MAPPING AUDIT", self:GetProviderMappingAuditLines(), "Effect -> provider integrity")
end
