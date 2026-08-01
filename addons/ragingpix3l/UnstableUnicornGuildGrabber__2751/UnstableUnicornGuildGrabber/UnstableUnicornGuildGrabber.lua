-------------------------------------------------------------------------------
-- Author
-- ragingpix3l
--
-- Full terms
-- https://account.elderscrollsonline.com/add-on-terms
--
---------------------------------------------------------------------------------
UNSTABLEUNICORNS = UNSTABLEUNICORNS or {}
local uu = UNSTABLEUNICORNS

uu.AddonName    = "UnstableUnicornGuildGrabber"
uu.version      = "0.03"
uu.maxGuildNum  = 5

local AddonName = uu.AddonName

uu.MyGuildMembersCache = {}
uu.Initialized = false

function uu.NumSharedGuilds(displayName)
    displayName = string.lower(displayName)

    return (uu.MyGuildMembersCache[displayName] and #uu.MyGuildMembersCache[displayName]) or 0
end

function uu.GetGuildId(displayName,guildIndex)
    displayName = string.lower(displayName)

    if (uu.MyGuildMembersCache[displayName]~=nil and uu.MyGuildMembersCache[displayName][guildIndex]~=nil) then
        return (uu.MyGuildMembersCache[displayName][guildIndex].guildId)
    end
    return -1
end

function uu.GetGuildName(displayName,guildIndex)
    local displayname = string.lower(displayName)
    if (uu.MyGuildMembersCache[displayname]~=nil) then
        if (guildIndex <=#(uu.MyGuildMembersCache[displayname])) then
            return uu.MyGuildMembersCache[displayname][guildIndex].guildName
        end

    end
    return nil
end

function uu.ByDisplayName(displayname)
    displayname = string.lower(displayname)
    local ret = ""
    if (uu.MyGuildMembersCache[displayname]~=nil) then
        ret = ret .. "|CFF0000Guild(s):|r\n"
        for i=1,#(uu.MyGuildMembersCache[displayname]) do
            ret = ret .. uu.MyGuildMembersCache[displayname][i].guildName
            ret = ret .. "\n"
        end
        return ret
    end
    return ""
end



function uu.FetchGuildMembers()
    local numGuilds = GetNumGuilds()
    if (numGuilds<1) then
        return
    end

    for i=1,numGuilds do
        local guildId = GetGuildId(i)
        local guildName = GetGuildName(guildId)

        for j=1,GetNumGuildMembers(guildId) do
            local tdisplayName = GetGuildMemberInfo(guildId, j)
            tdisplayName = string.lower(tdisplayName)

            uu.MyGuildMembersCache[tdisplayName] = uu.MyGuildMembersCache[tdisplayName]  or {}
            table.insert(uu.MyGuildMembersCache[tdisplayName] ,{guildName=guildName,guildId=guildId})
        end

    end

end

local function enableHooks()
    --Mail Inbox hook to display shared guild names in tooltip and buttons for each shared guild to edit FCONotes if FCONotes is enabled
    ZO_PostHook(MAIL_INBOX  , "OnMailReadable", function(self)
        if self.mailId then
            local mailData = self:GetMailData(self.mailId)

            self.fromControl.data = self.fromControl.data or {}

            if mailData.senderCharacterName and string.len(mailData.senderCharacterName)>1 then
                d("sender: " .. mailData.senderCharacterName)

                self.fromControl.data.displayName = mailData.senderDisplayName
                local bFCONoteExists = (FCONotes ~= nil)

                mailData.senderTooltipName = ZO_GetSecondaryPlayerName(mailData.senderDisplayName, mailData.senderCharacterName) .. "\n" .. uu.ByDisplayName(mailData.senderDisplayName)
                if (bFCONoteExists) then


                    if ( (not uu.Initialized) ) then
                        uu.Initialized = true
                        local parentForButtons = self.fromControl:GetParent()
                        local anchor = self.fromControl

                        for i = 1,uu.maxGuildNum do
                            local sButtonName = "fcoNoteButton" .. i;
                            self[sButtonName] = CreateControlFromVirtual("GuildNoteButton" .. tostring(i), parentForButtons, "ZO_DefaultButton")
                            local button = self[sButtonName]
                            button:SetText("" .. tostring(i))
                            button:SetDimensions(34,34)
                            button:SetAnchor(RIGHT,anchor,RIGHT,i == 1 and 90 or 20, i == 1 and 110 or 0)
                            anchor = button

                            button.data = button.data or {}
                            button.data.guildIndex = i
                            button.data.displayName = ""
                            button:SetHandler("OnMouseUp", function (o)
                                local displayName = o.data.displayName

                                if not displayName or string.len(displayName) == 0 then return false end

                                local guildId = uu.GetGuildId(displayName,o.data.guildIndex)
                                if guildId<0 then return end

                                o.data.guildId = guildId
                                local noteText = FCONotes.GetGuildMemberNote(guildId, displayName)
                                FCONotes.SetGuildMemberNote(guildId, displayName, noteText, true)
                            end)
                        end


                    else


                    end
                    local anchor = self.fromControl
                    for i=1,uu.maxGuildNum do
                        local button = self["fcoNoteButton" .. tostring(i)]
                        local bShouldBeVisible = uu.NumSharedGuilds(mailData.senderDisplayName)>=i

                        if (bShouldBeVisible) then
                            local caption = uu.GetGuildName(mailData.senderDisplayName,i)
                            button:SetText(caption)
                            button:SetDimensions(string.len(caption)*9 + 20,34)
                            button.data.displayName = mailData.senderDisplayName
                            button:ClearAnchors()
                            button:SetAnchor(LEFT,anchor,i==1 and LEFT or RIGHT,i == 1 and 1 or 10, i == 1 and 115 or 0)
                        end

                        anchor = button
                        button:SetHidden(  not (bShouldBeVisible))
                    end

                end
            else
                
                for i=1,uu.maxGuildNum do
                    local button = self["fcoNoteButton" .. tostring(i)]
                    if button then button:SetHidden( true )
                    end
                end

            end
        end
    end)

end

function uu.Startup()
    uu.MyGuildMembersCache = {}

    --Load the hooks
    enableHooks()

    uu.FetchGuildMembers()
end

function uu.H_PlayerActivated (eventCode)

    EVENT_MANAGER:UnregisterForEvent(AddonName, eventCode)

    uu.Startup()
end

local function onAddOnLoaded(eventCode, pAddonName)
    --As EVENT_ADD_ON_LOADED will be called for ALL addons from Z to A, in the order of ## (Optional)DependsOn:
    --Only run the code after this line for my own addon!
    if not pAddonName == AddonName then return end


    EVENT_MANAGER:UnregisterForEvent(AddonName, EVENT_ADD_ON_LOADED)

    EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_PLAYER_ACTIVATED, uu.H_PlayerActivated)

end


EVENT_MANAGER:RegisterForEvent(AddonName, EVENT_ADD_ON_LOADED, onAddOnLoaded)
