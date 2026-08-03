local C = Conductor
C.KnowledgeDiagnostics = C.KnowledgeDiagnostics or {}
local Diagnostics = C.KnowledgeDiagnostics

local function CountMap(map)
    local count = 0
    for _ in pairs(map or {}) do count = count + 1 end
    return count
end

function Diagnostics:GetSnapshot()
    local report = C.KnowledgeValidation and C.KnowledgeValidation:GetReport() or {counts={},errors={},warnings={},unresolvedProviders={}}
    local coverage = C.KnowledgeBase and C.KnowledgeBase:GetCoverageReport() or {collections={},effectsWithoutResponsibility=0,effectsWithoutProvider=0}
    return {
        platformVersion = C.Platform and C.Platform.version or C.version,
        registrySchemaVersion = C.Registry and C.Registry.schemaVersion or 0,
        currentPatch = C.Registry and C.Registry.currentPatch or 0,
        collections = report.counts.collections or 0,
        entries = report.counts.entries or 0,
        effects = report.counts.effects or 0,
        providers = report.counts.providers or 0,
        responsibilities = report.counts.responsibilities or 0,
        unverified = report.counts.unverified or 0,
        errors = #(report.errors or {}),
        warnings = #(report.warnings or {}),
        unresolvedProviders = #(report.unresolvedProviders or {}),
        indexedEffects = CountMap(C.KnowledgeBase and C.KnowledgeBase.providersByEffect),
        indexedProviders = CountMap(C.KnowledgeBase and C.KnowledgeBase.effectsByProvider),
        healthy = #(report.errors or {}) == 0,
        effectsWithoutResponsibility = coverage.effectsWithoutResponsibility or 0,
        effectsWithoutProvider = coverage.effectsWithoutProvider or 0,
        knowledgeScopeCollections = CountMap(coverage.collections),
    }
end

function Diagnostics:WriteToDeveloperLog()
    if not C.Diagnostics or not C.Diagnostics.AddFields then return end
    local snapshot = self:GetSnapshot()
    C.Diagnostics:AddFields("KNOWLEDGE_BASE", "Knowledge Base initialized", snapshot)
end

function Diagnostics:Initialize()
    self:WriteToDeveloperLog()
    self.initialized = true
end
