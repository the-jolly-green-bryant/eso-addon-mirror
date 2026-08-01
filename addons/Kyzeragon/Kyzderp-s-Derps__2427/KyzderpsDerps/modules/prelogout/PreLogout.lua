KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.PreLogout = KyzderpsDerps.PreLogout or {}
local PreLogout = KyzderpsDerps.PreLogout

---------------------------------------------------------------------
 -- Set to offline before logging out
---------------------------------------------------------------------
local function HideOnLogout()
    if (KyzderpsDerps.savedOptions.misc.hideOnLogout) then
        SelectPlayerStatus(PLAYER_STATUS_OFFLINE)
    end
end


---------------------------------------------------------------------
-- Turn off most addons
---------------------------------------------------------------------
PreLogout.doNotLoadOverride = false
local function LoadFewAddons()
    if (not KyzderpsDerps.savedOptions.preLogout.loadFewAddons or PreLogout.doNotLoadOverride) then
        return
    end

    local addonManager = GetAddOnManager()
    local addonsToLoad = KyzderpsDerps.savedOptions.preLogout.addonsToLoad

    for index = 1, addonManager:GetNumAddOns() do
        local name, title, author, description, enabled, state, isOutOfDate, isLibrary = addonManager:GetAddOnInfo(index)
        if (enabled and not addonsToLoad[name]) then
            addonManager:SetAddOnEnabled(index, false)
        elseif (not enabled and addonsToLoad[name]) then
            addonManager:SetAddOnEnabled(index, true)
        end
    end
end
-- PreLogout.LoadFewAddons = LoadFewAddons
-- /script KyzderpsDerps.savedOptions.preLogout.loadFewAddons = true
-- /script KyzderpsDerps.PreLogout.LoadFewAddons()
-- /script local am = GetAddOnManager() for i = 1, am:GetNumAddOns() do local name = am:GetAddOnInfo(i) d(name) end
-- /script local am = GetAddOnManager() for i = 1, am:GetNumAddOns() do local name, _, _, _, enabled = am:GetAddOnInfo(i) if enabled then d(name) end end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
local function OnLogout()
    HideOnLogout()
    LoadFewAddons()
end

local prehooked = false
function PreLogout.Initialize()
    KyzderpsDerps:dbg("    Initializing PreLogout module...")

    if (not prehooked) then
        ZO_PreHook("Logout", OnLogout)
        ZO_PreHook("Quit", OnLogout)
        prehooked = true
    end
end


---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
function PreLogout.GetSettings()
    return {
        {
            type = "checkbox",
            name = "Hide before logout",
            tooltip = "Automatically set your status to OFFLINE before you log out or quit the game. For you lurkers out there :D This can also be toggled with |c99FF99/kdd hide|r",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.misc.hideOnLogout end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.misc.hideOnLogout = value
            end,
            width = "full",
        },
        {
            type = "description",
            title = nil,
            text = "The below is intended to help addon addicts have shorter load screens when switching between alts that aren't being played at the moment. You can specify a list of addons below using their exact names. These and only these addons will be turned on when you log out or quit manually (timing out or getting kicked doesn't count). This allows your next load in on that character to be relatively fast. Then, if you do plan to play on that character, you can reload with the addons you want. I would recommend running this alongside something like |c99FF99Addon Selector|r to manage the subsequent reload. To log out without changing your loaded addons, use |c99FF99/kdd normlogout|r.\n\nThe way I personally use this is: I do trials on several different characters. Sometimes I forget to put my gear back in the bank, so when I discover that I don't have the right gear, I'm able to switch characters to get it much faster than if I had all my addons enabled. I can also log in much more quickly for casual dailies.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Load specific addons before logout",
            tooltip = "Automatically enables only the below specified addons before you log out or quit the game",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.preLogout.loadFewAddons end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.preLogout.loadFewAddons = value
            end,
            width = "full",
        },
        {
            type = "editbox",
            name = "Addons to load on logout",
            tooltip = "Separate addon names with a % sign. Include the needed dependencies!",
            default = "AddonSelector%AlphaGear%CarosSkillPointSaver%DolgubonsLazyWritCreator%IIfA%KyzderpsDerps%LibVotansAddonList%RulebasedInventory%VotansKeybinder%libAddonKeybinds%LibAddonMenu-2.0%LibAsync%LibCustomMenu%LibDialog%LibLazyCrafting%LibScrollableMenu",
            getFunc = function()
                local names = {}
                for name, _ in pairs(KyzderpsDerps.savedOptions.preLogout.addonsToLoad) do
                    table.insert(names, name)
                end
                return table.concat(names, "%")
            end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.preLogout.addonsToLoad = {}
                for str in string.gmatch(value, "([^%%]+)") do
                    str = string.gsub(str, "^%s+", "")
                    str = string.gsub(str, "%s+$", "")
                    KyzderpsDerps.savedOptions.preLogout.addonsToLoad[str] = true
                end
            end,
            isExtraWide = true,
            isMultiline = true,
            width = "full",
            disabled = function()
                return not KyzderpsDerps.savedOptions.preLogout.loadFewAddons
            end,
        },
        {
            type = "button",
            name = "Print Addons",
            tooltip = "Shows a list of all your installed addons' names",
            width = "full",
            func = function()
                local am = GetAddOnManager()
                local names = {}
                for i = 1, am:GetNumAddOns() do
                    local name, _ = am:GetAddOnInfo(i)
                    table.insert(names, name)
                end
                table.sort(names)
                d(names)
            end
        }
    }
end
