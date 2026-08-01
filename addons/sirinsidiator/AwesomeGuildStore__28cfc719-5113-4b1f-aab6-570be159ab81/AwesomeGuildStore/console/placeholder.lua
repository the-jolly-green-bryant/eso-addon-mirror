local AGS = AwesomeGuildStore
local function InitializeConsolePlaceholder()
    AGS.internal.logger:Debug("InitializeConsolePlaceholder")

    local consoleResults = GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS
    local container = consoleResults.container
    local qrCode = CreateControlFromVirtual("AwesomeGuildStoreConsoleQRCode", container,
        "AwesomeGuildStoreConsoleQRTemplate")

    local function RefreshNotice(isVisible)
        qrCode:SetHidden(not isVisible)
        if (isVisible) then
            consoleResults:SetEmptyText(
                "AwesomeGuildStore for consoles is currently in development.\nConsider becoming a patron and support sirinsidiator!")
        end
    end

    SecurePostHook(consoleResults, "OnSearchStateChanged",
        function(self, searchState, searchOutcome)
            RefreshNotice(searchState == TRADING_HOUSE_SEARCH_STATE_NONE)
        end)
    RefreshNotice(true)
end

AGS.internal.InitializeConsolePlaceholder = InitializeConsolePlaceholder
