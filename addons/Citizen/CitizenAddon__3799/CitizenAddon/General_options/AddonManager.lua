CitizenAddonManager = {
    name = "CitizenAddonManager",
}
local AM = GetAddOnManager()
local addonNumbers = AM:GetNumAddOns()

--Refresh the amount of active addons
---CitizenAddonManager.name .."ActiveAddons", 1000
local function UpdateActiveAddons()
    local deactiveAddons = 0

    for i=1, addonNumbers, 1 do
        local _, _, _, _, enabled, addOnLoadState, _, _ = AM:GetAddOnInfo(i)
        if enabled==false or addOnLoadState==3 or addOnLoadState==5 then
            deactiveAddons = deactiveAddons + 1
        end
    end

    ZO_AddOnsTitle:SetText(GetString(SI_WINDOW_TITLE_ADDON_MANAGER) .." (".. tostring(addonNumbers-deactiveAddons) .."/".. tostring(addonNumbers) ..")")
end
---SCENE_MANAGER:GetScene("gameMenuInGame"):RegisterCallback("StateChange", x)
function CitizenAddonManager.MenuScene(_, scene)
    if scene == SCENE_SHOWN then
        EVENT_MANAGER:RegisterForUpdate(CitizenAddonManager.name .."ActiveAddons", 1000, UpdateActiveAddons)
    else
        EVENT_MANAGER:UnregisterForUpdate(CitizenAddonManager.name .."ActiveAddons")
    end
end

--Check required libraries
function CitizenAddonManager.CheckRequiredLibraries()
    local requierdLibs = {}
    local activeLibs = {}

    for i=1, addonNumbers, 1 do
        local name, _, _, _, enabled, addOnLoadState, _, isLibrary = AM:GetAddOnInfo(i)
        if isLibrary and enabled and addOnLoadState~=3 and addOnLoadState~=5 then
            activeLibs[name] = 1
        end
    end
    for i=1, addonNumbers, 1 do
        local _, _, _, _, enabled, addOnLoadState, _, _ = AM:GetAddOnInfo(i)
        if enabled and addOnLoadState~=3 and addOnLoadState~=5 then
            for j=1, AM:GetAddOnNumDependencies(i), 1 do
                local DepName, _, _, _, _ = AM:GetAddOnDependencyInfo(i, j)
                if requierdLibs[DepName] ~= 1 then
                    requierdLibs[DepName] = 1
                end
            end
        end
    end
    for key, _ in pairs(requierdLibs) do
        if activeLibs[key] == 1 then
            activeLibs[key] = 0
        end
    end
    for key, value in pairs(activeLibs) do
        if value == 1 then
            if key == "LibStub" then
                d("|cffffff[CITI]|r |cffdd99LibStub|r helps to improve lots of addons, reguardless of the fact that it is not a current dependency, we suggest that do not turn it off because some of the addons functions may not work properly")
            elseif key == "LibCharacterKnowledge" then
                d("|cffffff[CITI]|r |cffdd99LibCharacterKnowledge|r is not a current dependency, but it adds some functions to AutoCategory if you have it")
            else
                d("|cffffff[CITI]|r |cffdd99".. key .."|r is not a dependency to any active addon")
            end
        end
    end
end
