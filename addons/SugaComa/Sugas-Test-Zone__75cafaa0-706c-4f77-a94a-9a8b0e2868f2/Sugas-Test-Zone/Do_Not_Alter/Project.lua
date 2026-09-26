-- Active STZ project bootstrap.
-- Project modules load after STZ_Core and initialize only after host access is approved.

SugasTestZoneProject = SugasTestZoneProject or {}
local Project = SugasTestZoneProject

function Project:Initialize()
    if self.initialized then return true end

    local host = SUGAS_TEST_ZONE
    if not host or type(host.CanLoadProject) ~= "function" then
        return false
    end

    local allowed = host:CanLoadProject(self.Config.displayName)
    self.authorized = allowed == true
    if not self.authorized then return false end

    self.Controller:Initialize()
    self.initialized = true
    return true
end
