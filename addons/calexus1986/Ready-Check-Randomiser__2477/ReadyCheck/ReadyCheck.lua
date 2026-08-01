ReadyCheck = {}
ReadyCheck.Name = "ReadyCheck"
ReadyCheck.Version = "1.4"
ReadyCheck.Author = "Calexus1986"
ReadyCheck.VariableVersion = 101
ReadyCheck.DefaultSave = {dummy = "1", select = "1"}
local argtext = nil
rcselection = "1"

function ReadyCheck.Banter()
    local rcmessage = {"You guys ready or not?", 
    "Can we go yet?", 
    "Leeroy?",
    "I haven't got all day, can we just go?",
    "Is your arse in gear yet?",
    "Damn, you're slow! Are you ready yet?"}
    rcactualmessage = rcmessage[1+math.floor(math.random()*#rcmessage)]
    BeginGroupElection(2,rcactualmessage)
    d("The ready message reads: ".. rcactualmessage)
end

function ReadyCheck.Polite()
    local rcmessage = {"Art thou ready?", 
    "Are you up for this?",
    "Wanna kill something?", 
    "Art thou prepared?",
    "Is it clobberin time"}
    rcactualmessage = rcmessage[1+math.floor(math.random()*#rcmessage)]
    BeginGroupElection(2,rcactualmessage)
    d("The ready message reads: ".. rcactualmessage)
end

function ReadyCheck.NSFW()
    local rcmessage = {"Hey fuckwit, are you ready yet?", 
    "You fucking ready or what?", 
    "Are you done standing there with your dick in your hand?",
    "Wanna fuck something up?",
    "Is it rape o'clock?"}
    rcactualmessage = rcmessage[1+math.floor(math.random()*#rcmessage)]
    BeginGroupElection(2,rcactualmessage)
    d("The ready message reads: ".. rcactualmessage)
end

function ReadyCheck.Help()
    d("Ready Check Randomiser arguments")
    d("Add these codes after /ready")
    d("help - This help menu")
    d("1 - Polite version")
    d("2 - Banter version")
    --d("0 - NSFW version")
    d("p - polite version, also sets default so next time you just need /ready")
    d("b - banter version, also sets default so next time you just need /ready")
    --d("n - nsfw version, also sets default so next time you just need /ready")
    d("polite - sets default but doesn't send a check")
    d("banter - sets default but doesn't send a check")
    --d("nsfw - sets default but doesn't send a check")

end

function ReadyCheck.SetNSFW()
    rcselection = "0"
    ReadyCheck.NSFW()
    d("Default changed to NSFW")
    ReadyCheck.savedVariables.select = rcselection
end

function ReadyCheck.SetPolite()
    rcselection = "1"
    ReadyCheck.Polite()
    d("Default changed to Polite")
    ReadyCheck.savedVariables.select = rcselection
end

function ReadyCheck.SetBanter()
    rcselection = "2"
    ReadyCheck.Banter()
    d("Default changes to Banter")
    ReadyCheck.savedVariables.select = rcselection
end

function ReadyCheck.Banter()
    rcactualmessage = argtext
    BeginGroupElection(2,rcactualmessage)
    d("The ready message reads: ".. rcactualmessage)
end

function ReadyCheck.SlashCommand(argtext)
    if (argtext == "1") then 
        ReadyCheck.Polite()
    elseif (argtext == "2") then
        ReadyCheck.Banter()
    elseif (argtext == "0") then
        ReadyCheck.NSFW()
    elseif (argtext == "help") then
        ReadyCheck.Help()
    elseif (argtext == "N") or (argtext == "n") then
        ReadyCheck.SetNSFW()
    elseif (argtext == "P") or (argtext == "p") then
        ReadyCheck.SetPolite()
    elseif (argtext == "B") or (argtext == "b") then
        ReadyCheck.SetBanter()
    elseif (argtext == "polite") or (argtext == "POLITE") then
        rcselection = "1"
        d("Default set to polite")
        ReadyCheck.savedVariables.select = rcselection
    elseif (argtext == "banter") or (argtext == "BANTER") then
        rcselection = "2"
        d("Default set to banter")
        ReadyCheck.savedVariables.select = rcselection
    elseif (argtext == "NSFW") or (argtext == "nsfw") then
        rcselection = "0"
        d("default set to NSFW")
        ReadyCheck.savedVariables.select = rcselection
    elseif (argtext == "r") or (argtext == "R") then
        rcselection = nil
        ReadyCheck.savedVariables.select = rcselection
    elseif (argtext ~= "") then
        rcactualmessage = argtext
        BeginGroupElection(2,rcactualmessage)
        d("The ready message reads: ".. rcactualmessage)
    else 
        if (rcselection == nil) then
            ReadyCheck.Help()
        elseif (rcselection == "1") then
            ReadyCheck.Polite()
        elseif (rcselection == "2") then
            ReadyCheck.Banter()
        elseif (rcselection == "0") then
            ReadyCheck.NSFW()
        else
            ReadyCheck.Help()
        end
    end
end

function ReadyCheck.Vote(VoteArg)
    rcactualmessage = VoteArg
    if VoteArg == "1" then rcactualmessage = "Hey guys, we doing the skip?" end
    if VoteArg == "" then 
        d('No vote text added, no vote will take place')
        return
    end
    BeginGroupElection(0,rcactualmessage)
    d("The vote reads: ".. rcactualmessage)
end

function ReadyCheck.Init()
    ReadyCheck.savedVariables = ZO_SavedVars:NewAccountWide("ReadyCheckSaved", ReadyCheck.VariableVersion, ReadyCheck.DefaultSave)
    rcselection = ReadyCheck.savedVariables.select
    EVENT_MANAGER:UnregisterForEvent(ReadyCheck.Name, EVENT_ADD_ON_LOADED)
end

function ReadyCheck.OnAddOnLoaded(event, addonName)
    if addonName ~= ReadyCheck.Name then return end
    ReadyCheck.Init()
end

EVENT_MANAGER:RegisterForEvent(ReadyCheck.Name, EVENT_ADD_ON_LOADED, ReadyCheck.OnAddOnLoaded)
SLASH_COMMANDS["/rdy"] = ReadyCheck.SlashCommand
SLASH_COMMANDS["/ready"] = ReadyCheck.SlashCommand
SLASH_COMMANDS["/vote"] = ReadyCheck.Vote