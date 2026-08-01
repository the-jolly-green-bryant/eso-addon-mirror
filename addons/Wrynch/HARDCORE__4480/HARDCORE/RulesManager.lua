local RuleManager = {}
local HARDCORE = HARDCORE
RuleManager.__index = RuleManager

RuleManager.rules = {}
RuleManager.enabledRuntime = {}

local function GetCharSV()
    if not (HARDCORE and HARDCORE.rulesSaved) then
        return nil
    end
    HARDCORE.rulesSaved.enabled = HARDCORE.rulesSaved.enabled or {}
    return HARDCORE.rulesSaved
end

local function EnsureSavedEnable(rule)
    local sv = GetCharSV()
    if not sv then
        return (rule.defaultEnabled ~= false) and true or false
    end
    if sv.enabled[rule.id] == nil then
        sv.enabled[rule.id] = (rule.defaultEnabled ~= false) and true or false
    end
    return sv.enabled[rule.id]
end

function RuleManager:RegisterRule(rule)
    assert(type(rule) == "table" and rule.id, "Rule must be a table with a unique 'id'")
    assert(not self.rules[rule.id], ("Duplicate rule id '%s'"):format(tostring(rule.id)))
    self.rules[rule.id] = rule
    if HARDCORE and HARDCORE.rulesSaved then
        EnsureSavedEnable(rule)
    end
    if HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive then
        local sv = GetCharSV()
        if sv and sv.enabled[rule.id] then
            self:EnableRule(rule.id)
        end
    end
end

function RuleManager:GetRule(id)
    return self.rules[id]
end

function RuleManager:ForEachRule(fn)
    for id, rule in pairs(self.rules) do
        fn(id, rule)
    end
end

function RuleManager:EnableRule(id, persist)
    local rule = self.rules[id]
    if not rule then
        return
    end
    if self.enabledRuntime[id] then
        return
    end
    if type(rule.OnEnable) == "function" then
        rule:OnEnable()
    end
    self.enabledRuntime[id] = true
    local sv = persist and GetCharSV()
    if sv then
        sv.enabled[id] = true
    end
end

function RuleManager:DisableRule(id, persist)
    local rule = self.rules[id]
    if not rule then
        return
    end
    if not self.enabledRuntime[id] then
        return
    end
    if type(rule.OnDisable) == "function" then
        rule:OnDisable()
    end
    self.enabledRuntime[id] = false
    local sv = persist and GetCharSV()
    if sv then
        sv.enabled[id] = false
    end
end

function RuleManager:SetRuleEnabled(id, enabled)
    local sv = GetCharSV()
    if sv then
        sv.enabled[id] = enabled and true or false
    end
    if HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive then
        if enabled then
            self:EnableRule(id)
        else
            self:DisableRule(id)
        end
    end
end

function RuleManager:ApplyAll()
    local sv = GetCharSV()
    if not sv then
        return
    end
    for id, rule in pairs(self.rules) do
        EnsureSavedEnable(rule)
        if sv.enabled[id] then
            self:EnableRule(id)
        else
            self:DisableRule(id)
        end
    end
end

function RuleManager:DisableAll()
    for id, _ in pairs(self.enabledRuntime) do
        if self.enabledRuntime[id] then
            self:DisableRule(id)
        end
    end
end

function RuleManager:SetActive(isActive)
    if not HARDCORE or not HARDCORE.saved then
        return
    end
    HARDCORE.saved.isActive = isActive and true or false
    if HARDCORE.saved.isActive then
        self:ApplyAll()
    else
        self:DisableAll()
    end
end

function RuleManager:RefreshActiveState()
    local active = HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive
    if active then
        self:ApplyAll()
    else
        self:DisableAll()
    end
end

function RuleManager:Init()
    if HARDCORE and HARDCORE.InitRulesSaved then
        HARDCORE.InitRulesSaved()
    end
    for _, rule in pairs(self.rules) do
        EnsureSavedEnable(rule)
    end
    self:RefreshActiveState()
    -- log("RuleManager initialized (active=" .. tostring(HARDCORE and HARDCORE.saved and HARDCORE.saved.isActive) .. ")")
end

HARDCORE = HARDCORE or {}
HARDCORE.RuleManager = RuleManager

return RuleManager
