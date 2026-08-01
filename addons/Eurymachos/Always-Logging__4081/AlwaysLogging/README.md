# Always Logging

This addon ensures that the ESO encounter log is always enabled (as
far as it can).
There is no user interface, no chat commands and no key binds.

The ESO Logs uploader can archive your encounter logs into a directory
as well as pick and choose which parts of the log to upload.
I don't see a reason to ever turn off the encounter log.

This can be especially useful to UESP editors who want to know what
just happened when they weren't expecting it.

I write this addon by looking at the Easy Stalking addon by `muh` in
order to work out how to manage encounter logging and then I wrote the
following code from scratch.

    local function on_player_loaded()
        if not IsEncounterLogEnabled() then
            SetEncounterLogEnabled(true)
            CHAT_ROUTER:AddSystemMessage('Encounter logging enabled by addon.')
        end
    end

    EVENT_MANAGER:RegisterForEvent('Always Logging', EVENT_PLAYER_ACTIVATED, on_player_loaded)

That is the entire addon.
