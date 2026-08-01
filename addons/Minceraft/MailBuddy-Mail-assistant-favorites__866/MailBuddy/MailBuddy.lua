    --The addon table/array
    MailBuddy = {}
    local mb = MailBuddy

    --Information about the addon
    mb.addonVars = {}
    mb.addonVars.name = "MailBuddy"
    mb.addonVars.displayName = "|cFFFF00MailBuddy|r"
    mb.addonVars.author = "Minceraft, current: Baertram"
	mb.addonVars.addonVersionOptionsNumber = 3.6
    mb.addonVars.version = tostring(mb.addonVars.addonVersionOptionsNumber)

    mb.addonVars.savedVariablesName = "MailBuddy_SavedVars"
    mb.addonVars.gSettingsLoaded = false
    local addonVars =  mb.addonVars
    local addonName = addonVars.name

    --Librraies
    local LAM = LibAddonMenu2
    local LMP = LibMediaProvider

    local EM = EVENT_MANAGER
    local SM = SCENE_MANAGER
    local WM = WINDOW_MANAGER
    
    mb.guildRosterAndFriendsListRowPatterns = {
        "^ZO_KeyboardFriendsListList1Row%d+DisplayName*",
        "^ZO_KeyboardFriendsListList1Row%d%d+DisplayName*",
        "^ZO_GuildRosterList1Row%d+DisplayName*",
        "^ZO_GuildRosterList1Row%d%d+DisplayName*",
    }
    local guildRosterAndFriendsListRowPatterns = mb.guildRosterAndFriendsListRowPatterns

    --The arrays for the saved variables
    mb.settingsVars	= {}
    mb.settingsVars.settingsVersion = 2.4
    mb.settingsVars.fontStyles = {
        "none",
        "outline",
        "thin-outline",
        "thick-outline",
        "shadow",
        "soft-shadow-thin",
        "soft-shadow-thick",
    }
    --Additional settings arrays for the first run of this addon, default values, etc.
    mb.settingsVars.settings			= {}
    mb.settingsVars.defaultSettings	= {}
    mb.settingsVars.firstRunSettings = {}
    mb.settingsVars.defaults			= {}

    --The LAM settings panel
	mb.SettingsPanel = nil

    --Array with prevention variables
    mb.preventerVars = {}
    mb.preventerVars.gLocalizationDone = false
    mb.preventerVars.KeyBindingTexts   = false
    mb.preventerVars.dontUseLastRecipientName = false

	--Build list of saved text controls for the recipients
	mb.recipientPages = {}
    mb.recipientPages.pages = {}
	--Page 1
    mb.recipientPages.pages[1] = {}
    table.insert(mb.recipientPages.pages[1], 1, "MailBuddy_RecipientsPage1CustomRecipientLabel1")
    table.insert(mb.recipientPages.pages[1], 2, "MailBuddy_RecipientsPage1CustomRecipientLabel2")
    table.insert(mb.recipientPages.pages[1], 3, "MailBuddy_RecipientsPage1CustomRecipientLabel3")
    table.insert(mb.recipientPages.pages[1], 4, "MailBuddy_RecipientsPage1CustomRecipientLabel4")
    table.insert(mb.recipientPages.pages[1], 5, "MailBuddy_RecipientsPage1CustomRecipientLabel5")
    table.insert(mb.recipientPages.pages[1], 6, "MailBuddy_RecipientsPage1CustomRecipientLabel6")
    table.insert(mb.recipientPages.pages[1], 7, "MailBuddy_RecipientsPage1CustomRecipientLabel7")
	--Page 2
    mb.recipientPages.pages[2] = {}
    table.insert(mb.recipientPages.pages[2], 1, "MailBuddy_RecipientsPage2CustomRecipientLabel8")
    table.insert(mb.recipientPages.pages[2], 2, "MailBuddy_RecipientsPage2CustomRecipientLabel9")
    table.insert(mb.recipientPages.pages[2], 3, "MailBuddy_RecipientsPage2CustomRecipientLabel10")
    table.insert(mb.recipientPages.pages[2], 4, "MailBuddy_RecipientsPage2CustomRecipientLabel11")
    table.insert(mb.recipientPages.pages[2], 5, "MailBuddy_RecipientsPage2CustomRecipientLabel12")
    table.insert(mb.recipientPages.pages[2], 6, "MailBuddy_RecipientsPage2CustomRecipientLabel13")
    table.insert(mb.recipientPages.pages[2], 7, "MailBuddy_RecipientsPage2CustomRecipientLabel14")
	--Page 3
    mb.recipientPages.pages[3] = {}
    table.insert(mb.recipientPages.pages[3], 1, "MailBuddy_RecipientsPage3CustomRecipientLabel15")
    table.insert(mb.recipientPages.pages[3], 2, "MailBuddy_RecipientsPage3CustomRecipientLabel16")
    table.insert(mb.recipientPages.pages[3], 3, "MailBuddy_RecipientsPage3CustomRecipientLabel17")
    table.insert(mb.recipientPages.pages[3], 4, "MailBuddy_RecipientsPage3CustomRecipientLabel18")
    table.insert(mb.recipientPages.pages[3], 5, "MailBuddy_RecipientsPage3CustomRecipientLabel19")
    table.insert(mb.recipientPages.pages[3], 6, "MailBuddy_RecipientsPage3CustomRecipientLabel20")
    table.insert(mb.recipientPages.pages[3], 7, "MailBuddy_RecipientsPage3CustomRecipientLabel21")

	--Variables for the entries on recipient pages
    mb.recipientPages.entriesPerPage = 7
    mb.recipientPages.totalEntries = 21
    mb.recipientPages.maxEntriesUntilHere = {}
    mb.recipientPages.maxEntriesUntilHere[1] = 7
    mb.recipientPages.maxEntriesUntilHere[2] = 14
    mb.recipientPages.maxEntriesUntilHere[3] = 21
    mb.recipientPages.selectedLabel = "MailBuddy_MailSendRecipientLabelActiveText"

	--Build list of saved text controls for the subjects
	mb.subjectPages = {}
    mb.subjectPages.pages = {}
	--Page 1
    mb.subjectPages.pages[1] = {}
    table.insert(mb.subjectPages.pages[1], 1, "MailBuddy_SubjectsPage1CustomSubjectLabel1")
    table.insert(mb.subjectPages.pages[1], 2, "MailBuddy_SubjectsPage1CustomSubjectLabel2")
    table.insert(mb.subjectPages.pages[1], 3, "MailBuddy_SubjectsPage1CustomSubjectLabel3")
    table.insert(mb.subjectPages.pages[1], 4, "MailBuddy_SubjectsPage1CustomSubjectLabel4")
    table.insert(mb.subjectPages.pages[1], 5, "MailBuddy_SubjectsPage1CustomSubjectLabel5")
	--Page 2
    mb.subjectPages.pages[2] = {}
    table.insert(mb.subjectPages.pages[2], 1, "MailBuddy_SubjectsPage2CustomSubjectLabel6")
    table.insert(mb.subjectPages.pages[2], 2, "MailBuddy_SubjectsPage2CustomSubjectLabel7")
    table.insert(mb.subjectPages.pages[2], 3, "MailBuddy_SubjectsPage2CustomSubjectLabel8")
    table.insert(mb.subjectPages.pages[2], 4, "MailBuddy_SubjectsPage2CustomSubjectLabel9")
    table.insert(mb.subjectPages.pages[2], 5, "MailBuddy_SubjectsPage2CustomSubjectLabel10")
	--Page 3
    mb.subjectPages.pages[3] = {}
    table.insert(mb.subjectPages.pages[3], 1, "MailBuddy_SubjectsPage3CustomSubjectLabel11")
    table.insert(mb.subjectPages.pages[3], 2, "MailBuddy_SubjectsPage3CustomSubjectLabel12")
    table.insert(mb.subjectPages.pages[3], 3, "MailBuddy_SubjectsPage3CustomSubjectLabel13")
    table.insert(mb.subjectPages.pages[3], 4, "MailBuddy_SubjectsPage3CustomSubjectLabel14")
    table.insert(mb.subjectPages.pages[3], 5, "MailBuddy_SubjectsPage3CustomSubjectLabel15")

	--Variables for the entries on subject pages
    mb.subjectPages.entriesPerPage = 5
    mb.subjectPages.totalEntries = 15
    mb.subjectPages.maxEntriesUntilHere = {}
    mb.subjectPages.maxEntriesUntilHere[1] = 5
    mb.subjectPages.maxEntriesUntilHere[2] = 10
    mb.subjectPages.maxEntriesUntilHere[3] = 15
    mb.subjectPages.selectedLabel = "MailBuddy_MailSendSubjectLabelActiveText"

	--Boolean value to check if the keybind was pressed
    mb.keybindUsed = false

	--Get the current player name
    mb.playerName = GetUnitName("player")
    --get the current account name
    mb.accountName = GetDisplayName()

    --Maximum characters shown inside the recipients/subjects list (tested with letter W, which is the widest)
    mb.maximumCharacters = {
    	["recipients"]	= 14,
        ["subjects"]	= 10,
    }
    --MailBuddy controls
    mb.subjectsBox = nil
    mb.recipientsBox = nil
    mb.editSubject = nil
    mb.editRecipient = nil
    mb.subjectsLabel = nil
    mb.recipientsLabel = nil
    mb.mailSendFromLabel = nil

    --Localization variables
    mb.localizationVars = {}
    mb.localizationVars.mb_loc 	 	= {}
    mb.localizationVars.all = {} --See file loc/MailBuddyLoc.lua
    local mailbuddyLoc

    --Keybindstrip variables
    local keystripDefCopyFriend         = {}
    local keystripDefCopyGuildMember    = {}

    --Backup the edit click sound
    SOUNDS["EDIT_CLICK_MAILBUDDY_BACKUP"] = SOUNDS["EDIT_CLICK"]

    local otherAddons = {}
    otherAddons.isMailRActive = false

    --Localized texts etc.
    function mb.Localization()
        --Was localization already done during keybindings? Then abort here
        local preventerVars = mb.preventerVars
        if preventerVars.KeyBindingTexts == true and preventerVars.gLocalizationDone == true then return end

        local settingsBase = mb.settingsVars
        local settingsDef = settingsBase.defaultSettings
        local settings = settingsBase.settings
        --Fallback to english
        if (settingsDef.language == nil or (settingsDef.language ~= 1 and settingsDef.language ~= 2 and settingsDef.language ~= 3 and settingsDef.language ~= 4 and settingsDef.language ~= 5)) then
            mb.settingsVars.defaultSettings.language = 1
        end
        --Is the standard language english set?
        if (preventerVars.KeyBindingTexts == true or (settingsDef.language == 1 and settings.languageChoosen == false)) then
            local lang = GetCVar("language.2")
            --Check for supported languages
            if(lang == "de") then
                mb.settingsVars.defaultSettings.language = 2
            elseif (lang == "en") then
                mb.settingsVars.defaultSettings.language = 1
            elseif (lang == "fr") then
                mb.settingsVars.defaultSettings.language = 3
            elseif (lang == "es") then
                mb.settingsVars.defaultSettings.language = 4
            elseif (lang == "it") then
                mb.settingsVars.defaultSettings.language = 5
            else
                mb.settingsVars.defaultSettings.language = 1
            end
        end
        mb.localizationVars.mb_loc = {}
        mb.localizationVars.mb_loc = mb.localizationVars.all[mb.settingsVars.defaultSettings.language]
        mailbuddyLoc = mb.localizationVars.mb_loc

        mb.preventerVars.gLocalizationDone = true

        --Abort here if we only needed the keybinding texts
        --if preventerVars.KeyBindingTexts == true then return end
    end

    --Global function to get text for the keybindings etc.
    function mb.GetLocText(textName, isKeybindingText)
        isKeybindingText = isKeybindingText or false
        mb.preventerVars.KeyBindingTexts = isKeybindingText
        --Do the localization now
        mb.Localization()
        if textName == nil or mailbuddyLoc == nil or mailbuddyLoc[textName] == nil then return "" end
        return mailbuddyLoc[textName]
    end

    function mb.ShowBox(boxType, doToggleShowHide, doCloseNow, doShowNow, doPlaySound, parentControl, doX, doY)
        if boxType == "" then return end
        doToggleShowHide = doToggleShowHide or false
        doCloseNow = doCloseNow or false
        doShowNow = doShowNow or false
        doPlaySound = doPlaySound or false

        local settings = mb.settingsVars.settings

        --recipients box
        if boxType == "recipients" then
            if settings.useAlternativeLayout then
                parentControl = parentControl or ZO_MailSendSubject
                doX = doX or -20
                doY = doY or -300
                mb.recipientsLabel:SetHidden(true)
                mb.recipientsLabel:SetMouseEnabled(false)
                MailBuddy_UseRecipientButton:SetHidden(true)
                MailBuddy_UseRecipientButton:SetMouseEnabled(false)
                mb.recipientsBox:ClearAnchors()
                if mb.recipientsBox:GetParent() ~= parentControl then
                    mb.recipientsBox:SetParent(parentControl)
                end
                mb.recipientsBox:SetAnchor(TOPRIGHT, parentControl, TOPLEFT, doX, doY)
                mb.recipientsBox:SetMouseEnabled(true)
            else
                parentControl = parentControl or mb.recipientsLabel
                doX = doX or -15
                doY = doY or 0
                mb.recipientsLabel:SetHidden(false)
                mb.recipientsLabel:SetMouseEnabled(true)
                MailBuddy_UseRecipientButton:SetHidden(false)
                MailBuddy_UseRecipientButton:SetMouseEnabled(true)
                mb.recipientsBox:ClearAnchors()
                if mb.recipientsBox:GetParent() ~= parentControl then
                    mb.recipientsBox:SetParent(parentControl)
                end
                mb.recipientsBox:SetAnchor(TOPRIGHT, parentControl, TOPLEFT, doX, doY)
                mb.recipientsBox:SetMouseEnabled(true)
            end
            if doToggleShowHide then
                if mb.recipientsBox:IsHidden() then
                    mb.GetZOMailRecipient()
                    mb.recipientsBox:SetHidden(false)
                    mb.editRecipient:TakeFocus()
                    mb.recipientsBox:SetMouseEnabled(true)
                    if doPlaySound then mb.PlaySoundNow(SOUNDS["BOOK_OPEN"]) end
                else
                    if  ( (not settings.useAlternativeLayout and settings.additional["RecipientsBoxVisibility"])
                      or  (settings.useAlternativeLayout) ) then

                        mb.recipientsBox:SetHidden(true)
                        mb.recipientsBox:SetMouseEnabled(false)
                        if doPlaySound then mb.PlaySoundNow(SOUNDS["BOOK_CLOSE"]) end
                    end
                end
            end
            if doCloseNow then
                ZO_Tooltips_HideTextTooltip()
                mb.recipientsBox:SetHidden(true)
                if doPlaySound then mb.PlaySoundNow(SOUNDS["BOOK_CLOSE"]) end
            elseif doShowNow then
                mb.recipientsBox:SetHidden(false)
                if doPlaySound then mb.PlaySoundNow(SOUNDS["BOOK_OPEN"]) end
            end

        --Subjects box
        elseif boxType == "subjects" then
            if settings.useAlternativeLayout then
                parentControl = parentControl or ZO_MailSendSubject
                doX = doX or -20
                doY = doY or 0
                MailBuddy_MailSendSubjectLabel:SetHidden(true)
                MailBuddy_MailSendSubjectLabel:SetMouseEnabled(false)
                MailBuddy_UseSubjectButton:SetHidden(true)
                MailBuddy_UseSubjectButton:SetMouseEnabled(false)
                mb.subjectsBox:ClearAnchors()
                if mb.subjectsBox:GetParent() ~= parentControl then
                    mb.subjectsBox:SetParent(parentControl)
                end
                mb.subjectsBox:SetAnchor(TOPRIGHT, parentControl, TOPLEFT, doX, doY)
            else
                parentControl = parentControl or mb.subjectsLabel
                doX = doX or 0
                doY = doY or 10
                MailBuddy_MailSendSubjectLabel:SetHidden(false)
                MailBuddy_MailSendSubjectLabel:SetMouseEnabled(true)
                MailBuddy_UseSubjectButton:SetHidden(false)
                MailBuddy_UseSubjectButton:SetMouseEnabled(true)
                mb.subjectsBox:ClearAnchors()
                if mb.subjectsBox:GetParent() ~= parentControl then
                    mb.subjectsBox:SetParent(parentControl)
                end
                mb.subjectsBox:SetAnchor(TOP, parentControl, BOTTOM, doX, doY)
            end
            if doToggleShowHide then
                if mb.subjectsBox:IsHidden() then
                    mb.GetZOMailSubject()
                    mb.subjectsBox:SetHidden(false)
                    mb.editSubject:TakeFocus()
                    if doPlaySound then mb.PlaySoundNow(SOUNDS["BOOK_OPEN"]) end
                else
                    if  ( (not settings.useAlternativeLayout and settings.additional["SubjectsBoxVisibility"])
                      or  (settings.useAlternativeLayout) ) then
                        mb.subjectsBox:SetHidden(true)
                        if doPlaySound then mb.PlaySoundNow(SOUNDS["BOOK_CLOSE"]) end
                    end
                end
            end
            if doCloseNow then
                ZO_Tooltips_HideTextTooltip()
                mb.subjectsBox:SetHidden(true)
                if doPlaySound then mb.PlaySoundNow(SOUNDS["BOOK_CLOSE"]) end
            elseif doShowNow then
                mb.subjectsBox:SetHidden(false)
                if doPlaySound then mb.PlaySoundNow(SOUNDS["BOOK_OPEN"]) end
            else
            end
        end

--d(string.format("[MailBuddy]ShowBox-type: %s, doToggleShowHide: %s, doCloseNow: %s, doShowNow: %s, doPlaySound: %s, parentControl: %s, doX: %s, doY: %s", tostring(boxType), tostring(doToggleShowHide), tostring(doCloseNow), tostring(doShowNow), tostring(doPlaySound), parentControl:GetName(), tostring(doX), tostring(doY)))

    end

    function mb.UpdateFontAndColor(labelCtrl, updateWhere, fontArea)
        if labelCtrl == nil then return end
        --Get labe control by help of the name
        local labelControl
        if type(labelCtrl) == "string" then
            labelControl = WM:GetControlByName(labelCtrl, "")
        else
            labelControl = labelCtrl
        end
        if labelControl == nil then return end
        updateWhere = updateWhere or "recipients"
        fontArea = fontArea or 1
        if fontArea ~= 1 and fontArea ~= 2 then return end
        if updateWhere ~= "recipients" and updateWhere ~= "subjects" then return end
        --font for the selected recipient/subject
        local font = mb.settingsVars.settings.font[updateWhere][fontArea]
        local color = font.color
        local fontPath = LMP:Fetch('font', font.family)
        local fontString = string.format('%s|%u|%s', fontPath, font.size, font.style)
        --local fontString = "ZoFontGame"
        if fontString  == nil then return end
        labelControl:SetFont(fontString)
        labelControl:SetColor(color.r, color.g, color.b, color.a)
    end

    function mb.UpdateAllLabels(updateWhere, pageNr, ctrlNr)
        updateWhere = updateWhere or "recipients"
        local maxLoop = 0
        local startLoop = 0
        if      updateWhere == "recipients" then
            if pageNr == -1 then
                startLoop = 1
                maxLoop = 3
            else
                startLoop = pageNr
                maxLoop = pageNr
            end
            for page=startLoop, maxLoop, 1 do
                for labelNr, recipientName in pairs(mb.recipientPages.pages[page]) do
                    if ctrlNr == -1 or ctrlNr == labelNr then
                        local labelControl = WM:GetControlByName(recipientName, "")
                        if labelControl ~= nil then
                            --Change font etc.
                            mb.UpdateFontAndColor(labelControl, updateWhere, 2)
                        end
                    end
                end
            end

        elseif  updateWhere == "subjects" then
            if pageNr == -1 then
                startLoop = 1
                maxLoop = 1
            else
                startLoop = pageNr
                maxLoop = pageNr
            end
            for page=startLoop, maxLoop, 1 do
                for labelNr, subjectName in pairs(mb.subjectPages.pages[page]) do
                    if ctrlNr == -1 or ctrlNr == labelNr then
                        local labelControl = WM:GetControlByName(subjectName, "")
                        if labelControl ~= nil then
                            --Chaneg font etc.
                            mb.UpdateFontAndColor(labelControl, updateWhere, 2)
                        end
                    end
                end
            end
        end
    end

 	--Clear player/account name from the recipients list, as you are not allowed to send mails to yourself
	local function RemoveOwnCharactersFromSavedRecipients(index, recipientName)
        if index == nil or recipientName == nil then return false end
		if recipientName == mb.playerName or recipientName == mb.accountName then
            --One of your characters or your account name was added to teh recipients list
            --> It will be removed now and clearedfrom the SavedVariables at the next reloadui/zone change/logout
            mb.settingsVars.settings.SetRecipient[index] = ""
            mb.settingsVars.settings.SetRecipientAbbreviated[index] = ""
        	return true
        end
        return false
	end

    --=============================================================================================================
    --	LOAD USER SETTINGS
    --=============================================================================================================
    --Load the SavedVariables now
    function mb.LoadUserSettings()
        if not addonVars.gSettingsLoaded then
            --Prepare the keybindings in the keybindstrip
            keystripDefCopyFriend = {
                {
                    name = mb.GetLocText("SI_BINDING_NAME_MAILBUDDY_FRIEND_COPY", true),
                    keybind = "MAILBUDDY_COPY",
                    callback = function() mb.CopyNameUnderControl() end,
                    alignment = KEYBIND_STRIP_ALIGN_CENTER,
                }
            }
            keystripDefCopyGuildMember = {
                {
                    name = mb.GetLocText("SI_BINDING_NAME_MAILBUDDY_GUILD_MEMBER_COPY", true),
                    keybind = "MAILBUDDY_COPY",
                    callback = function() mb.CopyNameUnderControl() end,
                    alignment = KEYBIND_STRIP_ALIGN_CENTER,
                }
            }

            --The default settings (loaded if no SavedVariables are given)
            mb.settingsVars.defaults = {
                curRecipient						= "",
                curRecipientAbbreviated				= "",
                curSubject 							= "RETURN",
                curSubjectAbbreviated				= "RETURN",
                curRecipientPage 					= "1",
                lastRecipientPage                   = "0",
                curSubjectPage 			 			= "1",
                lastSubjectPage 			 		= "0",
                remember                    = {
                    recipient                   = {
                        ["last"]                    = false,
                        ["text"]                    = "",
                    },
                    subject                     = {
                        ["last"]                    = false,
                        ["text"]                    = "",
                    },
                    body                     = {
                        ["last"]                    = false,
                        ["text"]                    = "",
                    },
                },
                lastShown                   = {
                    recipients                  = {
                        ["FriendsList"]             = false,
                        ["GuildRoster"]             = false,
                        ["MailSend"]                = false,
                    },
                    subjects                    = {
                        ["FriendsList"]             = false,
                        ["GuildRoster"]             = false,
                        ["MailSend"]                = false,
                    },
                },
                SetRecipient 				= {},
                SetRecipientAbbreviated		= {},
                SetSubject 					= {},
                SetSubjectAbbreviated		= {},
                playSounds                  = true,
                standard					= {
                    ["To"]							= "",
                    ["Subject"]						= "",
                },
                automatism              = {
                    close					= {
                        ["RecipientsList"] 			= false,
                        ["SubjectsList"]   			= false,
                    },
                    focus					= {
                        ["To"] 				        = false,
                        ["Subject"]   				= false,
                        ["Body"]                    = false,
                    },
                    hide					= {
                        ["RecipientsList"] 			= false,
                        ["SubjectsList"]   			= false,
                    },
                    focusOpen				= {
                        ["To"] 				        = false,
                        ["Subject"]   				= false,
                    },
                },
                additional					= {
                    ["RecipientsBoxVisibility"]		= true,
                    ["SubjectsBoxVisibility"]   	= true,
                },
                useAlternativeLayout				= false,
                showAlternativeLayoutTooltip        = false,
                font = {
                    ["recipients"]  = {
                        [1] =                   {
                                        family 	= "STONE_TABLET_FONT",
                                        size    = 18,
                                        style	= "shadow",
                                        color	= {
                                            ["r"] = 1,
                                            ["g"] = 1,
                                            ["b"] = 1,
                                            ["a"] = 1
                                        }
                        },
                        [2] =                   {
                                        family 	= "Univers 55",
                                        size    = 14,
                                        style	= "none",
                                        color	= {
                                            ["r"] = 1,
                                            ["g"] = 1,
                                            ["b"] = 1,
                                            ["a"] = 1
                                        }
                        },
                    },
                    ["subjects"] = {
                        [1] =                   {
                            family 	= "STONE_TABLET_FONT",
                            size    = 18,
                            style	= "shadow",
                            color	= {
                                ["r"] = 1,
                                ["g"] = 1,
                                ["b"] = 1,
                                ["a"] = 1
                            }
                        },
                        [2] =                   {
                            family 	= "Univers 55",
                            size    = 14,
                            style	= "none",
                            color	= {
                                ["r"] = 1,
                                ["g"] = 1,
                                ["b"] = 1,
                                ["a"] = 1
                            }
                        },
                    }
                },
                showAccountName 			= false,
                showCharacterName 		  	= false,
				showTotalMailCountInInbox	= false,
            }
            local defaults = mb.settingsVars.defaults

            --The default values for the language and save mode
            mb.settingsVars.firstRunSettings = {
                language 	 		    = 1, --Standard: English
                saveMode     		    = 2, --Standard: Account wide mb.settingsVars.settings
            }
            local firstRunSettings = mb.settingsVars.firstRunSettings
            local svName = addonVars.savedVariablesName
            local svVersion = mb.settingsVars.settingsVersion

            --=========== BEGIN - SAVED VARIABLES ==========================================
            --Load the user's mb.settingsVars.settings from SavedVariables file -> Account wide of basic version 999 at first
            mb.settingsVars.defaultSettings = ZO_SavedVars:NewAccountWide(svName, 999, "SettingsForAll", firstRunSettings)

            --Check, by help of basic version 999 mb.settingsVars.settings, if the settings should be loaded for each character or account wide
            --Use the current addon version to read the mb.settingsVars.settings now
            if (mb.settingsVars.defaultSettings.saveMode == 1) then
                mb.settingsVars.settings = ZO_SavedVars:New(svName, svVersion, "Settings", defaults)
            else
                mb.settingsVars.settings = ZO_SavedVars:NewAccountWide(svName, svVersion, "Settings", defaults)
            end
            --=========== END - SAVED VARIABLES ============================================

            local settings = mb.settingsVars.settings

            --Read the settings and set the mail recipient names
            for idx, recipientName in pairs(settings.SetRecipient) do
                --d("Recipient name: " .. recipientName .. ", index: " .. idx)
                if recipientName ~= "" and not RemoveOwnCharactersFromSavedRecipients(idx, recipientName) then
                    local page, pageEntry = mb.mapPageAndEntry(idx, "recipient")
                    if page ~= nil and pageEntry ~= nil then
                        local editControl = WM:GetControlByName(mb.recipientPages.pages[page][pageEntry], "")
                        if editControl ~= nil then
                            local recipientNameAbbreviated = settings.SetRecipientAbbreviated[idx] or recipientName
                            editControl:SetText(string.format(recipientNameAbbreviated))
                            mb.UpdateEditFieldToolTip(editControl, recipientName, recipientNameAbbreviated)
                        end
                    end
                end
            end

            --Read the settings and set the mail subjects
            for idx, subjectText in pairs(settings.SetSubject) do
                if subjectText ~= "" then
                    local page, pageEntry = mb.mapPageAndEntry(idx, "subject")
                    if page ~= nil and pageEntry ~= nil then
                        local subjectEditControl = WM:GetControlByName(mb.subjectPages.pages[page][pageEntry], "")
                        if subjectEditControl ~= nil then
                            local subjectTextAbbreviated = settings.SetSubjectAbbreviated[idx] or subjectText
                            subjectEditControl:SetText(string.format(subjectTextAbbreviated))
                            mb.UpdateEditFieldToolTip(subjectEditControl, subjectText, subjectTextAbbreviated)
                        end
                    end
                end
            end

            --Set settings = loaded
            mb.addonVars.gSettingsLoaded = true
        end
        --=============================================================================================================
    end

    local function PlayerActivatedCallback(eventCode)
	   -- zo_callLater(MailBuddyGetMail(), 2500)
	    EM:UnregisterForEvent(addonName, eventCode)

        --Update the anchors and positions of the recipients and subjects list
        mb.ShowBox("recipients", false, false, false, false)
        mb.ShowBox("subjects", false, false, false, false)

       --Add new recipient and new subject into an edit group and add autocomplete for the recipient name
	    local editControlGroup = ZO_EditControlGroup:New()
	    mb.autoCompleteRecipient = ZO_AutoComplete:New(MailBuddy_MailSendRecipientsBoxEditNewRecipient, { AUTO_COMPLETE_FLAG_ALL }, nil, AUTO_COMPLETION_ONLINE_OR_OFFLINE, MAX_AUTO_COMPLETION_RESULTS)
        editControlGroup:AddEditControl(MailBuddy_MailSendRecipientsBoxEditNewRecipient, mb.autoCompleteRecipient)
        editControlGroup:AddEditControl(MailBuddy_MailSendSubjectsBoxEditNewSubject, nil)
	end

    --Add button to the friends list to show recipients list
    local function AddButtonToFriendsList()
		if ZO_KeyboardFriendsList ~= nil and not ZO_KeyboardFriendsList:IsHidden() then
            --Automatically hide the recipients box?
            local settings = mb.settingsVars.settings
            local doHide = settings.automatism.hide["RecipientsBox"]
            local doOpen = settings.lastShown.recipients["FriendsList"]
            if doOpen == false then
                doHide = true
            end
            mb.ShowBox("recipients", false, doHide, doOpen, false, ZO_KeyboardFriendsList, -16, 0)

			--Add a button to the friends list, at top left corner near the "online status icon" to show/hide MailBuddy
	        if ZO_DisplayNameStatusSelectedItem ~= nil then
	        	if MailBuddy_FriendsToggleButton == nil then
					--Create the button control at the parent
					local button = WM:CreateControl("MailBuddy_FriendsToggleButton", ZO_KeyboardFriendsList, CT_BUTTON)
	                if button ~= nil then
				        --Set the button's size
					    button:SetDimensions(24, 24)
						--Align the button
						--SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
						button:SetAnchor(TOPLEFT, ZO_DisplayNameStatusSelectedItem, TOPLEFT, -20, 5)
			        	--Texture
						local texture
					    --Create the texture for the button to hold the image
					    texture = WM:CreateControl("MailBuddy_FriendsToggleButtonTexture", button, CT_TEXTURE)
					    texture:SetAnchorFill()
				        --Set the texture for normale state now
				        texture:SetTexture("EsoUI/Art/Inventory/inventory_tabIcon_quickslot_up.dds")
						--Do we have seperate textures for the button states?
			 			button.upTexture 	  = "EsoUI/Art/Inventory/inventory_tabIcon_quickslot_up.dds"
						button.downTexture 	  = "EsoUI/Art/Inventory/inventory_tabIcon_quickslot_over.dds"
						button.clickedTexture = "EsoUI/Art/Inventory/inventory_tabIcon_quickslot_down.dds"
						button:SetNormalTexture(button.upTexture)
						button:SetMouseOverTexture(button.downTexture)
						button:SetPressedMouseOverTexture(button.clickedTexture)
						button:SetHandler("OnMouseEnter", function(self)
	                    	local mailBuddyToggleButtonTooltip
	                        if mb.recipientsBox:IsHidden() then
	                        	mailBuddyToggleButtonTooltip = "Show MailBuddy"
	                        else
		                        mailBuddyToggleButtonTooltip = "Hide MailBuddy"
	                        end
							ZO_Tooltips_ShowTextTooltip(button, LEFT, mailBuddyToggleButtonTooltip)
						end)
						button:SetHandler("OnMouseExit", function(self)
							ZO_Tooltips_HideTextTooltip()
						end)
						--Set the callback function of the button
					    button:SetHandler("OnClicked", function(...)
	                        ZO_Tooltips_HideTextTooltip()
                            mb.ShowBox("recipients", true, false, false, true, ZO_KeyboardFriendsList, -16, 0)
				        end)
	                    button:SetHidden(false)
	                end
	            end
	        end
        end
	end

    --Add button to the guild roster to show recipients list
    local function AddButtonToGuildRoster()
        if ZO_GuildRoster ~= nil and not ZO_GuildRoster:IsHidden() then
            --Automatically hide the recipients box?
            local settings = mb.settingsVars.settings
            local doHide = settings.automatism.hide["RecipientsBox"]
            local doOpen = settings.lastShown.recipients["GuildRoster"]
            if doOpen == false then
                doHide = true
            end
            mb.ShowBox("recipients", false, doHide, doOpen, false, ZO_GuildRoster, -16, 0)

            --Add a button to the guild roster, at top left corner near the "online status icon" to show/hide MailBuddy
            if ZO_DisplayNameStatusSelectedItem ~= nil then
                if MailBuddy_GuildRosterToggleButton == nil then
                    --Create the button control at the parent
                    local button = WM:CreateControl("MailBuddy_GuildRosterToggleButton", ZO_GuildRoster, CT_BUTTON)
                    if button ~= nil then
                        --Set the button's size
                        button:SetDimensions(24, 24)
                        --Align the button
                        --SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
                        button:SetAnchor(TOPLEFT, ZO_DisplayNameStatusSelectedItem, TOPLEFT, -20, 5)
                        --Texture
                        local texture
                        --Create the texture for the button to hold the image
                        texture = WM:CreateControl("MailBuddy_GuildRosterToggleButtonTexture", button, CT_TEXTURE)
                        texture:SetAnchorFill()
                        --Set the texture for normale state now
                        texture:SetTexture("EsoUI/Art/Inventory/inventory_tabIcon_quickslot_up.dds")
                        --Do we have seperate textures for the button states?
                        button.upTexture 	  = "EsoUI/Art/Inventory/inventory_tabIcon_quickslot_up.dds"
                        button.downTexture 	  = "EsoUI/Art/Inventory/inventory_tabIcon_quickslot_over.dds"
                        button.clickedTexture = "EsoUI/Art/Inventory/inventory_tabIcon_quickslot_down.dds"
                        button:SetNormalTexture(button.upTexture)
                        button:SetMouseOverTexture(button.downTexture)
                        button:SetPressedMouseOverTexture(button.clickedTexture)
                        button:SetHandler("OnMouseEnter", function(self)
                            local mailBuddyToggleButtonTooltip
                            if mb.recipientsBox:IsHidden() then
                                mailBuddyToggleButtonTooltip = "Show MailBuddy"
                            else
                                mailBuddyToggleButtonTooltip = "Hide MailBuddy"
                            end
                            ZO_Tooltips_ShowTextTooltip(button, LEFT, mailBuddyToggleButtonTooltip)
                        end)
                        button:SetHandler("OnMouseExit", function(self)
                            ZO_Tooltips_HideTextTooltip()
                        end)
                        --Set the callback function of the button
                        button:SetHandler("OnClicked", function(...)
                            ZO_Tooltips_HideTextTooltip()
                            mb.ShowBox("recipients", true, false, false, true, ZO_GuildRoster, -16, 0)
                        end)
                        button:SetHidden(false)
                    end
                end
            end
        end
	end

    function mb.PlaySoundNow(soundName, itemSoundCategory, itemSoundAction)
        --Only play sounds if enabled ins ettings
        if mb.settingsVars.settings.playSounds == false then return end
        if soundName == nil or soundName == "" and
            ((itemSoundCategory == nil or itemSoundCategory == "") or
             (itemSoundAction == nil or itemSoundAction == "")) then return end

        if soundName ~= nil and soundName ~= "" then
            PlaySound(soundName)
        else
            if itemSoundCategory ~= nil and itemSoundAction ~= nil then
                PlayItemSound(itemSoundCategory, itemSoundAction)
            end
        end
    end

	function mb.CopyNameUnderControl()
        local mouseOverControl = moc()
        if not mouseOverControl then return end
        local mocName = mouseOverControl:GetName()

        for _, findMeStr in ipairs(guildRosterAndFriendsListRowPatterns) do
            if mocName:find(findMeStr) then
                mb.editRecipient:SetText(mouseOverControl:GetText())
                return true
            end
        end
        return false
    end

    function mb.GetZOMailRecipient(doOverride)
        doOverride = doOverride or false

        local editRecipient = mb.editRecipient
--d("[MailBuddy]GetZOMailRecipient: " ..tostring(editRecipient:GetText()))
        if not doOverride and editRecipient:GetText() ~= "" then return "" end
        local getTo = ZO_MailSendToField:GetText()
        if getTo ~= "" then
            if not doOverride then editRecipient:SetText(getTo)
            else return getTo end
        else return "" end
    end

    function mb.GetZOMailSubject(doOverride)
        doOverride = doOverride or false
        local editSubject = mb.editSubject
--d("[MailBuddy]GetZOMailSubject: " ..tostring(editSubject:GetText()))
        if not doOverride and editSubject:GetText() ~= "" then return "" end
        local getSubject = ZO_MailSendSubjectField:GetText()
        if getSubject ~= "" then
            if not doOverride then editSubject:SetText(getSubject)
            else return getSubject end
        else return "" end
    end

    function mb.GetZOMailBody()
        local getBody = ZO_MailSendBodyField:GetText()
--d("[MailBuddy]GetZOMailBody: " ..tostring(getBody))
        return getBody
    end

	local function GetMouseOverFriends(mouseOverControl)
		if not ZO_KeyboardFriendsList:IsHidden() then
            KEYBIND_STRIP:AddKeybindButtonGroup(keystripDefCopyFriend)
		else
			KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripDefCopyFriend)
            KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripDefCopyGuildMember)
		end
	end

	local function GetMouseOverGuildMembers(mouseOverControl)
		if not ZO_GuildRoster:IsHidden() then
            KEYBIND_STRIP:AddKeybindButtonGroup(keystripDefCopyGuildMember)
		else
            KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripDefCopyFriend)
			KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripDefCopyGuildMember)
		end
	end

    --Set the Mail-Brain "last used" mail recipient and subject for new mails
    local function SetRememberedRecipientSubjectAndBody()
--d("[MailBuddy]SetRememberedRecipientSubjectAndBody")
        local settingsRemember = mb.settingsVars.settings.remember
        if settingsRemember.recipient["last"] and ZO_MailSendToField ~= nil and settingsRemember.recipient["text"] ~= nil and settingsRemember.recipient["text"] ~= "" then
--d(">1")
            if not mb.preventerVars.dontUseLastRecipientName and ZO_MailSendToField:GetText() == "" then
--d(">2")
                ZO_MailSendToField:SetText(settingsRemember.recipient["text"])
            end
        end
        if settingsRemember.subject["last"] and ZO_MailSendSubjectField ~= nil and settingsRemember.subject["text"] ~= nil and settingsRemember.subject["text"] ~= "" then
--d(">3")
            zo_callLater(function()
--d(">4")
                ZO_MailSendSubjectField:SetText(settingsRemember.subject["text"])
            end, 50)
        end
        if settingsRemember.body["last"] and ZO_MailSendBodyField ~= nil and settingsRemember.body["text"] ~= nil and settingsRemember.body["text"] ~= "" then
--d(">5")
            ZO_MailSendBodyField:SetText(settingsRemember.body["text"])
        end
    end

    --Set the standard mail recipient and subject for new mails
	local function SetStandardRecipientAndSubject()
        local settings = mb.settingsVars.settings
        local settingsRemember = settings.remember
    	if not settingsRemember.recipient["last"] and ZO_MailSendToField ~= nil and settings.standard["To"] ~= nil and settings.standard["To"] ~= "" then
            ZO_MailSendToField:SetText(settings.standard["To"])
	    end
	 	if not settingsRemember.subject["last"] and ZO_MailSendSubjectField ~= nil and settings.standard["Subject"] ~= nil and settings.standard["Subject"] ~= "" then
            ZO_MailSendSubjectField:SetText(settings.standard["Subject"])
        end
	end

--------------------------------------------------------------------------------
	--Create the options panel with LAM 2.0
    --BuildAddonMenu
	function mb.CreateLAMPanel()
		local panelData = {
			type 				= 'panel',
			name 				= addonName,
			displayName 		= addonVars.displayName,
			author 				= addonVars.author,
			version 			= addonVars.version,
			registerForRefresh 	= true,
			registerForDefaults = true,
			slashCommand 		= "/mbs",
		}
		mb.SettingsPanel = LAM:RegisterAddonPanel(addonName.."panel", panelData)

        local settingsAtLAM = mb.settingsVars.settings
        local settingsAtLAMDefaults = mb.settingsVars.defaults

    --[[ Try to add auto complete to LAM 2.o edit box but it doesn't work. Maybe the inherits="ZO_DefaultEditForBackdrop" is relevant?
        local UpdateMailBuddySettingsFields = function(panel)
			if panel == mb.SettingsPanel then
		        --Update the standard recipient name edit field with an auto complete feature
				if MailBuddy_StandardRecipientName_SettingsEdit ~= nil then
				    local editControlGroup = ZO_EditControlGroup:New()
				    mb.autoCompleteRecipientSettings = ZO_AutoComplete:New(MailBuddy_StandardRecipientName_SettingsEdit, { AUTO_COMPLETE_FLAG_ALL }, nil, AUTO_COMPLETION_ONLINE_OR_OFFLINE, MAX_AUTO_COMPLETION_RESULTS)
			        editControlGroup:AddEditControl(MailBuddy_StandardRecipientName_SettingsEdit, mb.autoCompleteRecipientSettings)
		        end
				CALLBACK_MANAGER:UnregisterCallback("LAM-RefreshPanel", UpdateMailBuddySettingsFields)
			end
		end
		CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", UpdateMailBuddySettingsFields)
    ]]

        --The preview label for the fon's data inside the LAM settings panel for this addon (left to the font dropdown box)
        local previewLabel1
        local previewLabel2
        local previewLabel3
        local previewLabel4
        local fontPreview = function(panel)
            if panel == mb.SettingsPanel then
                previewLabel1 = WM:CreateControl(nil, panel.controlsToRefresh[10], CT_LABEL)
                previewLabel1:SetAnchor(RIGHT, panel.controlsToRefresh[10].dropdown:GetControl(), LEFT, -10, 0)
                previewLabel1:SetText("@Accountname")
                previewLabel1:SetHidden(false)
                mb.UpdateFontAndColor(previewLabel1, "recipients", 1)

                previewLabel2 = WM:CreateControl(nil, panel.controlsToRefresh[14], CT_LABEL)
                previewLabel2:SetAnchor(RIGHT, panel.controlsToRefresh[14].dropdown:GetControl(), LEFT, -10, 0)
                previewLabel2:SetText("Character name")
                previewLabel2:SetHidden(false)
                mb.UpdateFontAndColor(previewLabel2, "recipients", 2)

                previewLabel3 = WM:CreateControl(nil, panel.controlsToRefresh[18], CT_LABEL)
                previewLabel3:SetAnchor(RIGHT, panel.controlsToRefresh[18].dropdown:GetControl(), LEFT, -10, 0)
                previewLabel3:SetText("SUBJECT")
                previewLabel3:SetHidden(false)
                mb.UpdateFontAndColor(previewLabel3, "subjects", 1)

                previewLabel4 = WM:CreateControl(nil, panel.controlsToRefresh[22], CT_LABEL)
                previewLabel4:SetAnchor(RIGHT, panel.controlsToRefresh[22].dropdown:GetControl(), LEFT, -10, 0)
                previewLabel4:SetText("Subject")
                previewLabel4:SetHidden(false)
                mb.UpdateFontAndColor(previewLabel4, "subjects", 4)
                CALLBACK_MANAGER:UnregisterCallback("LAM-RefreshPanel", fontPreview)
            end
        end
        CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", fontPreview)

        local languageOptions = {
            [1] = mailbuddyLoc["options_language_dropdown_selection1"],
            [2] = mailbuddyLoc["options_language_dropdown_selection2"],
            [3] = mailbuddyLoc["options_language_dropdown_selection3"],
            [4] = mailbuddyLoc["options_language_dropdown_selection4"],
            [5] = mailbuddyLoc["options_language_dropdown_selection5"],
        }
        local languageOptionsValues = {
            [1] = 1,
            [2] = 2,
            [3] = 3,
            [4] = 4,
            [5] = 5,
        }

        local savedVariablesOptions = {
            [1] = mailbuddyLoc["options_savedVariables_dropdown_selection1"],
            [2] = mailbuddyLoc["options_savedVariables_dropdown_selection2"],
        }
        local savedVariablesOptionsValues = {
            [1] = 1,
            [2] = 2,
        }

		local optionsTable =
	    {	-- BEGIN OF OPTIONS TABLE
			{
				type = 'description',
				text = mailbuddyLoc["options_description"],
			},
	--==============================================================================
            {
                type = 'header',
                name = mailbuddyLoc["options_header1"],
            },
            {
                type = 'dropdown',
                name = mailbuddyLoc["options_language"],
                tooltip = mailbuddyLoc["options_language_tooltip"],
                choices = languageOptions,
                choicesValues = languageOptionsValues,
                --[[
                getFunc = function() return languageOptions[mb.settingsVars.defaultSettings.language] end,
                setFunc = function(value)
                    for i,v in pairs(languageOptions) do
                        if v == value then
                            mb.settingsVars.defaultSettings.language = i
                            --Tell the settings that you have manually chosen the language and want to keep it
                            --Read in function mb.Localization() after ReloadUI()
                            settingsAtLAM.languageChoosen = true
                            ReloadUI()
                        end
                    end
                end,
                ]]
                getFunc = function() return mb.settingsVars.defaultSettings.language end,
                setFunc = function(value)
                    mb.settingsVars.defaultSettings.language = value
                    settingsAtLAM.languageChoosen = true
                    ReloadUI()
                end,
                warning = mailbuddyLoc["options_language_description1"],
            },
            {
                type = 'dropdown',
                name = mailbuddyLoc["options_savedvariables"],
                tooltip = mailbuddyLoc["options_savedvariables_tooltip"],
                choices = savedVariablesOptions,
                choicesValues = savedVariablesOptionsValues,
                --[[
                getFunc = function() return savedVariablesOptions[mb.settingsVars.defaultSettings.saveMode] end,
                setFunc = function(value)
                    for i,v in pairs(savedVariablesOptions) do
                        if v == value then
                            mb.settingsVars.defaultSettings.saveMode = i
                            ReloadUI()
                        end
                    end
                end,
                ]]
                getFunc = function() return mb.settingsVars.defaultSettings.saveMode end,
                setFunc = function(value)
                    mb.settingsVars.defaultSettings.saveMode = value
                    ReloadUI()
                end,
                warning = mailbuddyLoc["options_language_description1"],
            },
			{
	        	type = 'header',
	        	name = mailbuddyLoc["options_appearance"],
	        },
            {
				type = "checkbox",
				name = mailbuddyLoc["options_alternative_layout"],
				tooltip = mailbuddyLoc["options_alternative_layout_tooltip"],
				getFunc = function() return settingsAtLAM.useAlternativeLayout end,
				setFunc = function(value)
                	settingsAtLAM.useAlternativeLayout = value
                    mb.ShowBox("recipients", false, false, false, false)
                    mb.ShowBox("subjects", false, false, false, false)
                    settingsAtLAM.showAlternativeLayoutTooltip = settingsAtLAM.useAlternativeLayout
                end,
	            default = settingsAtLAMDefaults.useAlternativeLayout,
	            width   = "full",
			},
            {
                type = "checkbox",
                name = mailbuddyLoc["options_show_alternative_layout_tooltip"],
                tooltip = mailbuddyLoc["options_show_alternative_layout_tooltip_tooltip"],
                getFunc = function() return settingsAtLAM.showAlternativeLayoutTooltip end,
                setFunc = function(value)
                    settingsAtLAM.showAlternativeLayoutTooltip = value
                end,
                default = settingsAtLAMDefaults.showAlternativeLayoutTooltip,
                width   = "full",
                disabled = function() return not settingsAtLAM.useAlternativeLayout end
            },
            {
                type = "checkbox",
                name = mailbuddyLoc["options_play_sounds"],
                tooltip = mailbuddyLoc["options_play_sounds_tooltip"],
                getFunc = function() return settingsAtLAM.playSounds end,
                setFunc = function(value)
                    settingsAtLAM.playSounds = value
                end,
                default = settingsAtLAMDefaults.playSounds,
                width   = "full",
            },

            {
                type = 'header',
                name = mailbuddyLoc["options_fonts"],
            },
            {
                type = 'dropdown',
                name = mailbuddyLoc["options_font_recipient_label"],
                choices = LMP:List('font'),
                getFunc = function() return settingsAtLAM.font["recipients"][1].family end,
                setFunc = function(value) settingsAtLAM.font["recipients"][1].family = value
                    mb.UpdateFontAndColor(previewLabel1, "recipients", 1)
                    mb.UpdateFontAndColor(mb.recipientPages.selectedLabel, "recipients", 1)
                end,
                default = settingsAtLAMDefaults.font["recipients"][1].family,
            },
            {
                type = "slider",
                name = mailbuddyLoc["options_font_recipient_label_size"],
                min = 8,
                max = 32,
                getFunc = function() return settingsAtLAM.font["recipients"][1].size end,
                setFunc = function(size) settingsAtLAM.font["recipients"][1].size = size
                    mb.UpdateFontAndColor(previewLabel1, "recipients", 1)
                    mb.UpdateFontAndColor(mb.recipientPages.selectedLabel, "recipients", 1)
                end,
                default = settingsAtLAMDefaults.font["recipients"][1].size,
            },
            {
                type = 'dropdown',
                name = mailbuddyLoc["options_font_recipient_label_style"],
                choices = mb.settingsVars.fontStyles,
                getFunc = function() return settingsAtLAM.font["recipients"][1].style end,
                setFunc = function(value) settingsAtLAM.font["recipients"][1].style = value
                    mb.UpdateFontAndColor(previewLabel1, "recipients", 1)
                    mb.UpdateFontAndColor(mb.recipientPages.selectedLabel, "recipients", 1)
                end,
                width = "half",
                default = settingsAtLAMDefaults.font["recipients"][1].style,
            },
            {
                type = "colorpicker",
                name = mailbuddyLoc["options_font_recipient_label_color"],
                getFunc = function() return settingsAtLAM.font["recipients"][1].color.r, settingsAtLAM.font["recipients"][1].color.g, settingsAtLAM.font["recipients"][1].color.b, settingsAtLAM.font["recipients"][1].color.a end,
                setFunc = function(r,g,b,a) settingsAtLAM.font["recipients"][1].color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
                    mb.UpdateFontAndColor(previewLabel1, "recipients", 1)
                    mb.UpdateFontAndColor(mb.recipientPages.selectedLabel, "recipients", 1)
                end,
                width = "half",
                default = settingsAtLAMDefaults.font["recipients"][1].color,
            },

            {
                type = 'dropdown',
                name = mailbuddyLoc["options_font_recipients_box"],
                choices = LMP:List('font'),
                getFunc = function() return settingsAtLAM.font["recipients"][2].family end,
                setFunc = function(value) settingsAtLAM.font["recipients"][2].family = value
                    mb.UpdateFontAndColor(previewLabel2, "recipients", 2)
                    mb.UpdateAllLabels("recipients", -1, -1)
                end,
                default = settingsAtLAMDefaults.font["recipients"][2].family,
            },
            {
                type = "slider",
                name = mailbuddyLoc["options_font_recipients_box_size"],
                min = 8,
                max = 32,
                getFunc = function() return settingsAtLAM.font["recipients"][2].size end,
                setFunc = function(size) settingsAtLAM.font["recipients"][2].size = size
                    mb.UpdateFontAndColor(previewLabel2, "recipients", 2)
                    mb.UpdateAllLabels("recipients", -1, -1)
                end,
                default = settingsAtLAMDefaults.font["recipients"][2].size,
            },
            {
                type = 'dropdown',
                name = mailbuddyLoc["options_font_recipients_box_style"],
                choices = mb.settingsVars.fontStyles,
                getFunc = function() return settingsAtLAM.font["recipients"][2].style end,
                setFunc = function(value) settingsAtLAM.font["recipients"][2].style = value
                    mb.UpdateFontAndColor(previewLabel2, "recipients", 2)
                    mb.UpdateAllLabels("recipients", -1, -1)
                end,
                width = "half",
                default = settingsAtLAMDefaults.font["recipients"][2].style,
            },
            {
                type = "colorpicker",
                name = mailbuddyLoc["options_font_recipients_box_color"],
                getFunc = function() return settingsAtLAM.font["recipients"][2].color.r, settingsAtLAM.font["recipients"][2].color.g, settingsAtLAM.font["recipients"][2].color.b, settingsAtLAM.font["recipients"][2].color.a end,
                setFunc = function(r,g,b,a) settingsAtLAM.font["recipients"][2].color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
                    mb.UpdateFontAndColor(previewLabel2, "recipients", 2)
                    mb.UpdateAllLabels("recipients", -1, -1)
                end,
                width = "half",
                default = settingsAtLAMDefaults.font["recipients"][2].color,
            },

            {
                type = 'dropdown',
                name = mailbuddyLoc["options_font_subject_label"],
                choices = LMP:List('font'),
                getFunc = function() return settingsAtLAM.font["subjects"][1].family end,
                setFunc = function(value) settingsAtLAM.font["subjects"][1].family = value
                    mb.UpdateFontAndColor(previewLabel3, "subjects", 1)
                    mb.UpdateFontAndColor(mb.subjectPages.selectedLabel, "subjects", 1)
                end,
                default = settingsAtLAMDefaults.font["subjects"][1].family,
            },
            {
                type = "slider",
                name = mailbuddyLoc["options_font_subject_label_size"],
                min = 8,
                max = 32,
                getFunc = function() return settingsAtLAM.font["subjects"][1].size end,
                setFunc = function(size) settingsAtLAM.font["subjects"][1].size = size
                    mb.UpdateFontAndColor(previewLabel3, "subjects", 1)
                    mb.UpdateFontAndColor(mb.subjectPages.selectedLabel, "subjects", 1)
                end,
                default = settingsAtLAMDefaults.font["subjects"][1].size,
            },
            {
                type = 'dropdown',
                name = mailbuddyLoc["options_font_subject_label_style"],
                choices = mb.settingsVars.fontStyles,
                getFunc = function() return settingsAtLAM.font["subjects"][1].style end,
                setFunc = function(value) settingsAtLAM.font["subjects"][1].style = value
                    mb.UpdateFontAndColor(previewLabel3, "subjects", 1)
                    mb.UpdateFontAndColor(mb.subjectPages.selectedLabel, "subjects", 1)
                end,
                width = "half",
                default = settingsAtLAMDefaults.font["subjects"][1].style,
            },
            {
                type = "colorpicker",
                name = mailbuddyLoc["options_font_subject_label_color"],
                getFunc = function() return settingsAtLAM.font["subjects"][1].color.r, settingsAtLAM.font["subjects"][1].color.g, settingsAtLAM.font["subjects"][1].color.b, settingsAtLAM.font["subjects"][1].color.a end,
                setFunc = function(r,g,b,a) settingsAtLAM.font["subjects"][1].color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
                    mb.UpdateFontAndColor(previewLabel3, "subjects", 1)
                    mb.UpdateFontAndColor(mb.subjectPages.selectedLabel, "subjects", 1)
                end,
                width = "half",
                default = settingsAtLAMDefaults.font["subjects"][1].color,
            },

            {
                type = 'dropdown',
                name = mailbuddyLoc["options_font_subjects_box"],
                choices = LMP:List('font'),
                getFunc = function() return settingsAtLAM.font["subjects"][2].family end,
                setFunc = function(value) settingsAtLAM.font["subjects"][2].family = value
                    mb.UpdateFontAndColor(previewLabel4, "subjects", 2)
                    mb.UpdateAllLabels("subjects", -1, -1)
                end,
                default = settingsAtLAMDefaults.font["subjects"][2].family,
            },
            {
                type = "slider",
                name = mailbuddyLoc["options_font_subjects_box_size"],
                min = 8,
                max = 32,
                getFunc = function() return settingsAtLAM.font["subjects"][2].size end,
                setFunc = function(size) settingsAtLAM.font["subjects"][2].size = size
                    mb.UpdateFontAndColor(previewLabel4, "subjects", 2)
                    mb.UpdateAllLabels("subjects", -1, -1)
                end,
                default = settingsAtLAMDefaults.font["subjects"][2].size,
            },
            {
                type = 'dropdown',
                name = mailbuddyLoc["options_font_subjects_box_style"],
                choices = mb.settingsVars.fontStyles,
                getFunc = function() return settingsAtLAM.font["subjects"][2].style end,
                setFunc = function(value) settingsAtLAM.font["subjects"][2].style = value
                    mb.UpdateFontAndColor(previewLabel4, "subjects", 2)
                    mb.UpdateAllLabels("subjects", -1, -1)
                end,
                width = "half",
                default = settingsAtLAMDefaults.font["subjects"][2].style,
            },
            {
                type = "colorpicker",
                name = mailbuddyLoc["options_font_subjects_box_color"],
                getFunc = function() return settingsAtLAM.font["subjects"][2].color.r, settingsAtLAM.font["subjects"][2].color.g, settingsAtLAM.font["subjects"][2].color.b, settingsAtLAM.font["subjects"][2].color.a end,
                setFunc = function(r,g,b,a) settingsAtLAM.font["subjects"][2].color = {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a}
                    mb.UpdateFontAndColor(previewLabel4, "subjects", 2)
                    mb.UpdateAllLabels("subjects", -1, -1)
                end,
                width = "half",
                default = settingsAtLAMDefaults.font["subjects"][2].color,
            },

            {
                type = 'header',
                name = mailbuddyLoc["options_additional"],
            },
			{
				type = "checkbox",
				name = mailbuddyLoc["options_toggle_recipients_box_click"],
				tooltip = mailbuddyLoc["options_toggle_recipients_box_click_tooltip"],
				getFunc = function() return settingsAtLAM.additional["RecipientsBoxVisibility"] end,
				setFunc = function(value) settingsAtLAM.additional["RecipientsBoxVisibility"] = value end,
	            default = settingsAtLAMDefaults.additional["RecipientsBoxVisibility"],
                disabled = function() return settingsAtLAM.useAlternativeLayout end,
	            width   = "full",
			},
			{
				type = "checkbox",
				name = mailbuddyLoc["options_toggle_subjects_box_click"],
				tooltip = mailbuddyLoc["options_toggle_subjects_box_click_tooltip"],
				getFunc = function() return settingsAtLAM.additional["SubjectsBoxVisibility"] end,
				setFunc = function(value) settingsAtLAM.additional["SubjectsBoxVisibility"] = value end,
	            default = settingsAtLAMDefaults.additional["SubjectsBoxVisibility"],
                disabled = function() return settingsAtLAM.useAlternativeLayout end,
	            width   = "full",
			},
            {
                type = 'header',
                name = mailbuddyLoc["options_standard_mail"],
            },
	   		{
				type = "editbox",
				name = mailbuddyLoc["options_standard_recipient"],
				tooltip = mailbuddyLoc["options_standard_recipient_tooltip"],
				getFunc = function() return settingsAtLAM.standard["To"] end,
				setFunc = function(newValue)
	            	settingsAtLAM.standard["To"] = newValue
	            end,
				width = "full",
				default = settingsAtLAMDefaults.standard["To"],
                reference = "MailBuddy_StandardRecipientName_SettingsEdit",
                disabled = function() return settingsAtLAM.remember.recipient["last"] end,
			},
            {
                type = "editbox",
                name = mailbuddyLoc["options_standard_subject"],
                tooltip = mailbuddyLoc["options_standard_subject_tooltip"],
                getFunc = function() return settingsAtLAM.standard["Subject"] end,
                setFunc = function(newValue)
                    settingsAtLAM.standard["Subject"] = newValue
                end,
                width = "full",
                default = settingsAtLAMDefaults.standard["Subject"],
                disabled = function() return settingsAtLAM.remember.subject["last"] end,
            },
            {
                type = 'header',
                name = mailbuddyLoc["options_mail_brain"],
            },
            {
                type = "checkbox",
                name = mailbuddyLoc["options_reuse_recipient"],
                tooltip = mailbuddyLoc["options_reuse_recipient_tooltip"],
                getFunc = function() return settingsAtLAM.remember.recipient["last"] end,
                setFunc = function(value) settingsAtLAM.remember.recipient["last"] = value end,
                default = settingsAtLAMDefaults.remember.recipient["last"],
                width   = "full",
            },
            {
                type = "checkbox",
                name = mailbuddyLoc["options_reuse_subject"],
                tooltip = mailbuddyLoc["options_reuse_subject_tooltip"],
                getFunc = function() return settingsAtLAM.remember.subject["last"] end,
                setFunc = function(value) settingsAtLAM.remember.subject["last"] = value end,
                default = settingsAtLAMDefaults.remember.subject["last"],
                width   = "full",
            },
            {
                type = "checkbox",
                name = mailbuddyLoc["options_reuse_body"],
                tooltip = mailbuddyLoc["options_reuse_body_tooltip"],
                getFunc = function() return settingsAtLAM.remember.body["last"] end,
                setFunc = function(value) settingsAtLAM.remember.body["last"] = value end,
                default = settingsAtLAMDefaults.remember.body["last"],
                width   = "full",
            },
            {
                type = 'header',
                name = mailbuddyLoc["options_automatism"],
            },
			{
				type = "checkbox",
				name = mailbuddyLoc["options_auto_hide_recipients_box"],
				tooltip = mailbuddyLoc["options_auto_hide_recipients_box_tooltip"],
				getFunc = function() return settingsAtLAM.automatism.hide["RecipientsBox"] end,
				setFunc = function(value) settingsAtLAM.automatism.hide["RecipientsBox"] = value end,
	            default = settingsAtLAMDefaults.automatism.hide["RecipientsBox"],
	            width   = "full",
			},
			{
				type = "checkbox",
				name = mailbuddyLoc["options_auto_hide_subjects_box"],
				tooltip = mailbuddyLoc["options_auto_hide_subjects_box_tooltip"],
				getFunc = function() return settingsAtLAM.automatism.hide["SubjectsBox"] end,
				setFunc = function(value) settingsAtLAM.automatism.hide["SubjectsBox"] = value end,
	            default = settingsAtLAMDefaults.automatism.hide["SubjectsBox"],
	            width   = "full",
			},
            {
                type = "checkbox",
                name = mailbuddyLoc["options_auto_close_recipients_box"],
                tooltip = mailbuddyLoc["options_auto_close_recipients_box_tooltip"],
                getFunc = function() return settingsAtLAM.automatism.close["RecipientsBox"] end,
                setFunc = function(value) settingsAtLAM.automatism.close["RecipientsBox"] = value end,
                default = settingsAtLAMDefaults.automatism.close["RecipientsBox"],
                width   = "full",
            },
            {
                type = "checkbox",
                name = mailbuddyLoc["options_auto_close_subjects_box"],
                tooltip = mailbuddyLoc["options_auto_close_subjects_box_tooltip"],
                getFunc = function() return settingsAtLAM.automatism.close["SubjectsBox"] end,
                setFunc = function(value) settingsAtLAM.automatism.close["SubjectsBox"] = value end,
                default = settingsAtLAMDefaults.automatism.close["SubjectsBox"],
                width   = "full",
            },
            {
                type = 'header',
                name = mailbuddyLoc["options_autofocus"],
            },
            {
                type = "checkbox",
                name = mailbuddyLoc["options_auto_focus_recipients_field"],
                tooltip = mailbuddyLoc["options_auto_focus_recipients_field_tooltip"],
                getFunc = function() return settingsAtLAM.automatism.focus["To"] end,
                setFunc = function(value) settingsAtLAM.automatism.focus["To"] = value end,
                default = settingsAtLAMDefaults.automatism.focus["To"],
                width   = "full",
            },
            {
                type = "checkbox",
                name = mailbuddyLoc["options_auto_focus_auto_open_recipients_field"],
                tooltip = mailbuddyLoc["options_auto_focus_auto_open_recipients_field_tooltip"],
                getFunc = function() return settingsAtLAM.automatism.focusOpen["To"] end,
                setFunc = function(value) settingsAtLAM.automatism.focusOpen["To"] = value end,
                default = settingsAtLAMDefaults.automatism.focusOpen["To"],
				disabled = function() return not settingsAtLAM.automatism.focus["To"] end,
                width   = "full",
            },
            {
                type = "checkbox",
                name = mailbuddyLoc["options_auto_focus_subjects_field"],
                tooltip = mailbuddyLoc["options_auto_focus_subjects_field_tooltip"],
                getFunc = function() return settingsAtLAM.automatism.focus["Subject"] end,
                setFunc = function(value) settingsAtLAM.automatism.focus["Subject"] = value end,
                default = settingsAtLAMDefaults.automatism.focus["Subject"],
                width   = "full",
            },
            {
                type = "checkbox",
                name = mailbuddyLoc["options_auto_focus_auto_open_subjects_field"],
                tooltip = mailbuddyLoc["options_auto_focus_auto_open_subjects_field_tooltip"],
                getFunc = function() return settingsAtLAM.automatism.focusOpen["Subject"] end,
                setFunc = function(value) settingsAtLAM.automatism.focusOpen["Subject"] = value end,
                default = settingsAtLAMDefaults.automatism.focusOpen["Subject"],
				disabled = function() return not settingsAtLAM.automatism.focus["Subject"] end,
                width   = "full",
            },
            {
                type = "checkbox",
                name = mailbuddyLoc["options_auto_focus_body_field"],
                tooltip = mailbuddyLoc["options_auto_focus_body_field_tooltip"],
                getFunc = function() return settingsAtLAM.automatism.focus["Body"] end,
                setFunc = function(value) settingsAtLAM.automatism.focus["Body"] = value end,
                default = settingsAtLAMDefaults.automatism.focus["Body"],
                width   = "full",
            },
            {
                type = 'header',
                name = mailbuddyLoc["options_header_sender"],
            },
            {
                type = "checkbox",
                name = mailbuddyLoc["options_show_account_name"],
                tooltip = mailbuddyLoc["options_show_account_name_tooltip"],
                getFunc = function() return settingsAtLAM.showAccountName end,
                setFunc = function(value) settingsAtLAM.showAccountName = value end,
                default = settingsAtLAMDefaults.showAccountName,
                width   = "full",
                disabled = function() return settingsAtLAM.showCharacterName end,
            },
            {
                type = "checkbox",
                name = mailbuddyLoc["options_show_character_name"],
                tooltip = mailbuddyLoc["options_show_character_name_tooltip"],
                getFunc = function() return settingsAtLAM.showCharacterName end,
                setFunc = function(value) settingsAtLAM.showCharacterName = value end,
                default = settingsAtLAMDefaults.showCharacterName,
                width   = "full",
                disabled = function() return settingsAtLAM.showAccountName end,
            },
            {
                type = 'header',
                name = mailbuddyLoc["options_header_inbox"],
            },
            {
                type = "checkbox",
                name = mailbuddyLoc["options_show_mail_count"],
                tooltip = mailbuddyLoc["options_show_mail_count_tooltip"],
                getFunc = function() return settingsAtLAM.showTotalMailCountInInbox end,
                setFunc = function(value) settingsAtLAM.showTotalMailCountInInbox = value end,
                default = settingsAtLAMDefaults.showTotalMailCountInInbox,
                width   = "full",
            },

		} -- END OF OPTIONS TABLE
		LAM:RegisterOptionControls(addonName.."panel", optionsTable)
	end
--------------------------------------------------------------------------------

	function mb.GetPage(pageType, oldPage, doPlaySound)
        if pageType == nil or pageType == "" then return end
        oldPage = oldPage or 0
        doPlaySound = doPlaySound or false

        local settings = mb.settingsVars.settings

        if pageType == "recipients" then
            if settings.curRecipientPage ~= oldPage then
                --Pages for the recipients
                if settings.curRecipientPage == "1" then
                    MailBuddy_RecipientsPage1:SetHidden(false)
                    MailBuddy_RecipientsPage2:SetHidden(true)
                    MailBuddy_RecipientsPage3:SetHidden(true)
                    MailBuddy_MailSendRecipientsBoxButtonGlow1:SetHidden(false)
                    MailBuddy_MailSendRecipientsBoxButtonGlow2:SetHidden(true)
                    MailBuddy_MailSendRecipientsBoxButtonGlow3:SetHidden(true)
                    if doPlaySound then
                        mb.PlaySoundNow(SOUNDS["BOOK_PAGE_TURN"])
                    end
                elseif settings.curRecipientPage == "2" then
                    MailBuddy_RecipientsPage2:SetHidden(false)
                    MailBuddy_RecipientsPage1:SetHidden(true)
                    MailBuddy_RecipientsPage3:SetHidden(true)
                    MailBuddy_MailSendRecipientsBoxButtonGlow2:SetHidden(false)
                    MailBuddy_MailSendRecipientsBoxButtonGlow1:SetHidden(true)
                    MailBuddy_MailSendRecipientsBoxButtonGlow3:SetHidden(true)
                    if doPlaySound then
                        mb.PlaySoundNow(SOUNDS["BOOK_PAGE_TURN"])
                    end
                elseif settings.curRecipientPage == "3" then
                    MailBuddy_RecipientsPage3:SetHidden(false)
                    MailBuddy_RecipientsPage1:SetHidden(true)
                    MailBuddy_RecipientsPage2:SetHidden(true)
                    MailBuddy_MailSendRecipientsBoxButtonGlow3:SetHidden(false)
                    MailBuddy_MailSendRecipientsBoxButtonGlow1:SetHidden(true)
                    MailBuddy_MailSendRecipientsBoxButtonGlow2:SetHidden(true)
                    if doPlaySound then
                        mb.PlaySoundNow(SOUNDS["BOOK_PAGE_TURN"])
                    end
                end
            end
        elseif pageType == "subjects" then
            if settings.curSubjectPage ~= oldPage then
                --Pages for the subjects
                if settings.curSubjectPage == "1" then
                    MailBuddy_SubjectsPage1:SetHidden(false)
                    MailBuddy_SubjectsPage2:SetHidden(true)
                    MailBuddy_SubjectsPage3:SetHidden(true)
                    MailBuddy_MailSendSubjectsBoxButtonGlow1:SetHidden(false)
                    MailBuddy_MailSendSubjectsBoxButtonGlow2:SetHidden(true)
                    MailBuddy_MailSendSubjectsBoxButtonGlow3:SetHidden(true)
                    if doPlaySound then
                        mb.PlaySoundNow(SOUNDS["BOOK_PAGE_TURN"])
                    end
                elseif settings.curSubjectPage == "2" then
                    MailBuddy_SubjectsPage2:SetHidden(false)
                    MailBuddy_SubjectsPage1:SetHidden(true)
                    MailBuddy_SubjectsPage3:SetHidden(true)
                    MailBuddy_MailSendSubjectsBoxButtonGlow2:SetHidden(false)
                    MailBuddy_MailSendSubjectsBoxButtonGlow1:SetHidden(true)
                    MailBuddy_MailSendSubjectsBoxButtonGlow3:SetHidden(true)
                    if doPlaySound then
                        mb.PlaySoundNow(SOUNDS["BOOK_PAGE_TURN"])
                    end
                elseif settings.curSubjectPage == "3" then
                    MailBuddy_SubjectsPage3:SetHidden(false)
                    MailBuddy_SubjectsPage1:SetHidden(true)
                    MailBuddy_SubjectsPage2:SetHidden(true)
                    MailBuddy_MailSendSubjectsBoxButtonGlow3:SetHidden(false)
                    MailBuddy_MailSendSubjectsBoxButtonGlow1:SetHidden(true)
                    MailBuddy_MailSendSubjectsBoxButtonGlow2:SetHidden(true)
                    if doPlaySound then
                        mb.PlaySoundNow(SOUNDS["BOOK_PAGE_TURN"])
                    end
                end
            end
        end
	end

	function mb.mapPageAndEntry(p_pageIndex, p_Type)
		if p_pageIndex == nil or p_Type == nil then return end
		local pageEntry
		if p_pageIndex ~= 0 then
			--Get the recipient page and entry
		    if p_Type == "recipient" then
                local recipientPages = mb.recipientPages
	            for pageNr, maxEntries in pairs (recipientPages.maxEntriesUntilHere) do
		        	if p_pageIndex <= maxEntries then
	                    if pageNr > 1 then
		                    pageEntry = p_pageIndex - ((pageNr-1) * recipientPages.entriesPerPage)
						else
							pageEntry = p_pageIndex
	                    end
	                    return pageNr, pageEntry
					end
	           	end
			--Get the subject page and entry
	        elseif p_Type == "subject" then
                local subjectPages = mb.subjectPages
	            for pageNr, maxEntries in pairs (subjectPages.maxEntriesUntilHere) do
		        	if p_pageIndex <= maxEntries then
	                    if pageNr > 1 then
		                    pageEntry = p_pageIndex - ((pageNr-1) * subjectPages.entriesPerPage)
						else
							pageEntry = p_pageIndex
	                    end
	                    return pageNr, pageEntry
					end
	           	end
		    else
		    	return nil, nil
	        end
	    else
	    	return nil, nil
	    end
	end

	--Update the tooltips of the edit field to show the non-abbreviated text inside the tooltip
	function mb.UpdateEditFieldToolTip(editControl, tooltipText, tooltiptextShort)
    	if editControl == nil or tooltipText == "" then return end

        if tooltipText ~= tooltiptextShort then
	        editControl:SetHandler("OnMouseEnter", function(self)
				ZO_Tooltips_ShowTextTooltip(editControl, LEFT, tooltipText)
			end)
			editControl:SetHandler("OnMouseExit", function(self)
				ZO_Tooltips_HideTextTooltip()
			end)
		else
	        editControl:SetHandler("OnMouseEnter", nil)
        end
    end

    --Set the focus to the next field that needs it
    function mb.FocusNextField()
        local automatism = mb.settingsVars.settings.automatism
        local automatismFocus = automatism.focus
        if  not automatismFocus["To"]
            and not automatismFocus["Subject"]
            and not automatismFocus["Body"] then return end
        if automatismFocus["Body"] and ZO_MailSendToField:GetText() ~= "" and ZO_MailSendSubjectField:GetText() ~= "" then
            SOUNDS["EDIT_CLICK"] = SOUNDS["NONE"]
            ZO_MailSendBodyField:TakeFocus()
            SOUNDS["EDIT_CLICK"] = SOUNDS["EDIT_CLICK_MAILBUDDY_BACKUP"]
        elseif automatismFocus["To"] and ZO_MailSendToField:GetText() == "" and ZO_MailSendSubjectField:GetText() ~= "" then
            SOUNDS["EDIT_CLICK"] = SOUNDS["NONE"]
            ZO_MailSendToField:TakeFocus()
            SOUNDS["EDIT_CLICK"] = SOUNDS["EDIT_CLICK_MAILBUDDY_BACKUP"]
            if automatism.focusOpen["To"] then
        		mb.ShowBox("recipients", false, false, true, true)
            end
        elseif automatismFocus["Subject"] and ZO_MailSendToField:GetText() ~= "" and ZO_MailSendSubjectField:GetText() == "" then
            SOUNDS["EDIT_CLICK"] = SOUNDS["NONE"]
            ZO_MailSendSubjectField:TakeFocus()
            SOUNDS["EDIT_CLICK"] = SOUNDS["EDIT_CLICK_MAILBUDDY_BACKUP"]
            if automatism.focusOpen["Subject"] then
		        mb.ShowBox("subjects", false, false, true, true)
            end
        end
    end

    --Close the recipients/subjects lists automatically
    function mb.AutoCloseBox(boxType, doOverride)
        if boxType == nil or boxType == "" then return end
        doOverride = doOverride or false
        local isGuildRoster = false
        local isFriendsList = false

        if ZO_KeyboardFriendsList ~= nil and not ZO_KeyboardFriendsList:IsHidden() then isFriendsList = true
        elseif ZO_GuildRoster ~= nil and not ZO_GuildRoster:IsHidden() then isGuildRoster = true end
        local closeSettings = mb.settingsVars.settings.automatism.close
        if    (boxType == "subjects" and (doOverride or closeSettings["SubjectsBox"]))
           or (boxType == "recipients" and (doOverride or closeSettings["RecipientsBox"])) then
            mb.ShowBox(boxType, false, true, false, false)
        end
    end

	function mb.UpdateNumTotalMails()
        --Show the current total count of mails?
		if mb.settingsVars.settings.showTotalMailCountInInbox then
			zo_callLater(function()
				if ZO_MailInboxUnreadLabel ~= nil then
					local unreadMails = GetNumUnreadMail()
					if MAIL_INBOX == nil or MAIL_INBOX.masterList == nil then return false end
                    local currentMailCount = 0
                    --Is the addon MaiLR active?
                    otherAddons.isMailRActive = (MailR ~= nil)
                    if otherAddons.isMailRActive then
						currentMailCount = 0
						for key, mailData in pairs(MAIL_INBOX.masterList) do
							--Is the mail not a MailR "sent" mail?
                            if mailData.expiresText == nil or mailData.expiresText ~= "MAILR" then
								--Increase the counter by 1
	                        	currentMailCount = currentMailCount + 1
                            end
                        end
                    else
                    	currentMailCount = #MAIL_INBOX.masterList
                    end
	                if currentMailCount ~= nil then
						--Colorize the current mails in inbox count. If it is below the half of MAX_LOCAL_MAILS it will be white.
                        --If it reaches the half of MAX_LOCAL_MAILS it will be yellow, otherweise it will be red
                        local colorText = ""
                        if MAX_LOCAL_MAILS ~= nil and MAX_LOCAL_MAILS > 0 then
                            local halfMax = (MAX_LOCAL_MAILS / 2)
                            if halfMax == 0 then halfMax = 1 end
                        	if currentMailCount < halfMax then
                            	colorText = ""
                            elseif currentMailCount >= halfMax and currentMailCount < MAX_LOCAL_MAILS then
                            	colorText = "|cFFA500"
                            elseif currentMailCount >= MAX_LOCAL_MAILS then
                            	colorText = "|cDD2222"
                            end
                        end
                        if colorText ~= "" then
	                    	ZO_MailInboxUnreadLabel:SetText(unreadMails .. " / " .. colorText .. currentMailCount .."|r")
                        else
	                    	ZO_MailInboxUnreadLabel:SetText(unreadMails .. " / " .. currentMailCount)
                        end
	                else
						ZO_MailInboxUnreadLabel:SetText(unreadMails)
	                end
				end
            end, 100)
		end
	end

    function mb.RememberMailData()
--d("[MailBuddy]RememberMailData()")
        --Remember the last used recipient and subject text
        mb.settingsVars.settings.remember.recipient["text"] = mb.GetZOMailRecipient(true)
        mb.settingsVars.settings.remember.subject["text"]   = mb.GetZOMailSubject(true)
        mb.settingsVars.settings.remember.body["text"]      = mb.GetZOMailBody()
    end

    function mb.SetRememberedMailData()
        SetStandardRecipientAndSubject()
        SetRememberedRecipientSubjectAndBody()
    end

    --Initialization of this addon
	local function Initialize(eventCode, addOnNameOfEachAddon)
	        if addOnNameOfEachAddon ~= addonName then return end

            --Unregister the addon loaded event again so it won't be called twice!
	        EM:UnregisterForEvent(addonName, eventCode)
	        EM:RegisterForEvent(addonName, EVENT_PLAYER_ACTIVATED, PlayerActivatedCallback)

            --Load the saved variables etc.
            mb.LoadUserSettings()

            --Load localization file
            mb.preventerVars.KeyBindingTexts = false
            mb.Localization()

	        --Build the settings panel
	        mb.CreateLAMPanel()

            --Create the text for the keybinding
	        ZO_CreateStringId("SI_BINDING_NAME_MAILBUDDY_COPY", mb.GetLocText("SI_BINDING_NAME_MAILBUDDY_COPY", true))

            --Select the current page at recipients and subjects (from the saved variables)
	        mb.GetPage("recipients", 0, false)
            mb.GetPage("subjects", 0, false)

		--New after patch 1.6
			--======== FRIENDS LIST ================================================================
			--Register a callback function for the friends list scene
			FRIENDS_LIST_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		        if 	   newState == SCENE_SHOWN then
                    AddButtonToFriendsList()

		        elseif newState == SCENE_HIDING then
                    mb.settingsVars.settings.lastShown.recipients["FriendsList"] = not mb.recipientsBox:IsHidden()
                end
			end)
            --PreHook the MouseEnter and Exit functions for the friends list rows + names in the rows
			ZO_PreHook("ZO_FriendsListRowDisplayName_OnMouseEnter", function(control)
            	--d("Mouse enter friend name: " .. control:GetName())
               GetMouseOverFriends(control)
            end)
			ZO_PreHook("ZO_FriendsListRowDisplayName_OnMouseExit", function(control)
            	--d("Mouse exit friend name: " .. control:GetName())
   				KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripDefCopyFriend)
            end)
			ZO_PreHook("ZO_FriendsListRow_OnMouseExit", function(control)
            	--d("Mouse exit friends row: " .. control:GetName())
   				KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripDefCopyFriend)
            end)

			--======== GUILD ROSTER ================================================================
			--Register a callback function for the guild roster scene
			GUILD_ROSTER_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		        if 	   newState == SCENE_SHOWN then
                    AddButtonToGuildRoster()
                elseif newState == SCENE_HIDING then
                    mb.settingsVars.settings.lastShown.recipients["GuildRoster"] = not mb.recipientsBox:IsHidden()
	            end
			end)

            --PreHook the MouseEnter and Exit functions for the guild roster list rows + names in the rows
			ZO_PreHook("ZO_KeyboardGuildRosterRowDisplayName_OnMouseEnter", function(control)
               --d("Mouse enter guild roster name: " .. control:GetName())
               GetMouseOverGuildMembers(control)
            end)
			ZO_PreHook("ZO_KeyboardGuildRosterRowDisplayName_OnMouseExit", function(control)
            	--d("Mouse exit guild roster  name: " .. control:GetName())
   				KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripDefCopyGuildMember)
            end)
			ZO_PreHook("ZO_KeyboardGuildRosterRow_OnMouseExit", function(control)
            	--d("Mouse exit guild roster row: " .. control:GetName())
   				KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripDefCopyGuildMember)
            end)


			--======== MAIL INBOX ================================================================
            local function updateNumTotalMails(newState)
                if (newState ~= nil and newState == SCENE_SHOWN) or (not newState and SM:IsShowing("mailInbox")) then
                    --Update the total number of mails label
                	mb.UpdateNumTotalMails()
                end
            end
			--Register a callback function for the mail inbox scene
			MAIL_INBOX_SCENE:RegisterCallback("StateChange", function(oldState, newState)
 		        updateNumTotalMails(newState)
            end)
            --PreHook the mail inbox update functions so the number of current mails at the label will be updated too
            ZO_PreHook(MAIL_INBOX, "OnMailNumUnreadChanged", function(...)
                updateNumTotalMails()
            end)
            ZO_PreHook(MAIL_INBOX, "OnMailRemoved", function(...)
                updateNumTotalMails()
            end)

			--======== MAIL SEND ================================================================
			--Register a callback function for the mail send scene
			MAIL_SEND_SCENE:RegisterCallback("StateChange", function(oldState, newState)
 		        local mailSendFromLabel = mb.mailSendFromLabel
                if 	   	   newState == SCENE_SHOWING then
                    local settings = mb.settingsVars.settings
                    local autoHide = settings.automatism.hide
                	--Hide the UI elements for the recipients and subjects lists if enabled in the settings
                    if autoHide["RecipientsBox"] then
                        mb.ShowBox("recipients", false, true, false, false)
                    else
                        local doClose = false
                        local doOpen = settings.lastShown.recipients["MailSend"]
                        if doOpen == false then doClose = true end
                        mb.ShowBox("recipients", false, doClose, doOpen, false)
                    end
                    if autoHide["SubjectsBox"] then
                        mb.ShowBox("subjects", false, true, false, false)
                    else
                        local doClose = false
                        local doOpen = settings.lastShown.subjects["MailSend"]
                        if doOpen == false then doClose = true end
                        mb.ShowBox("subjects", false, doClose, doOpen, false)
                    end

                    --Add the "from" label above the "to" label and show the current account name if activated in the settings
                    if settings.showAccountName or settings.showCharacterName then
                       	if mailSendFromLabel == nil then
                           	mailSendFromLabel = WM:CreateControl("MailBuddy_MailSendFromLabel", ZO_MailSend, CT_LABEL)
                            mb.mailSendFromLabel = mailSendFromLabel
						end
                        if mailSendFromLabel ~= nil then
							--Set the name to display at the label
                            local nameToShow = ""
                            if settings.showAccountName then
                            	nameToShow = GetDisplayName()
                            elseif settings.showCharacterName then
	                            local playerName = GetUnitName("player")
                                nameToShow = playerName
                            end
                        	--Change the label values
							mailSendFromLabel:SetFont("ZoFontWinH3")
							mailSendFromLabel:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
							mailSendFromLabel:SetScale(1)
							mailSendFromLabel:SetDrawLayer(DT_HIGH)
							mailSendFromLabel:SetDrawTier(DT_HIGH)
							mailSendFromLabel:SetAnchor(TOPLEFT, ZO_MailSendToLabel, TOPLEFT, 0, -30)
							mailSendFromLabel:SetDimensions(326, 23)
				        	mailSendFromLabel:SetHidden(false)
							mailSendFromLabel:SetText(mailbuddyLoc["options_mail_from"] .. "   " .. nameToShow)
						end
                   	elseif not settings.showAccountName and not settings.showCharacterName then
						if mailSendFromLabel ~= nil then
                        	mailSendFromLabel:SetHidden(true)
						end
                    end

 		        elseif 	   newState == SCENE_SHOWN then
	 				--Preset the standard mail recipient and subject from the settings after mail was send/not sent (error)
                    --Delay the automatic text filling of the subject and body texts as "send mail" from guild roster will clear the texts
                    zo_callLater(function()
                        mb.SetRememberedMailData()
                    end, 150)
                elseif     newState == SCENE_HIDING then
                    --Remember if the recipients list and subjects list are currently shown
                    mb.settingsVars.settings.lastShown.recipients["MailSend"] = not mb.recipientsBox:IsHidden()
                    mb.settingsVars.settings.lastShown.subjects["MailSend"] = not mb.subjectsBox:IsHidden()
                    --Remember the last used recipient and subject text
                    mb.RememberMailData()
                    --Hide the account name/character name label
					if mailSendFromLabel ~= nil then
                       	mailSendFromLabel:SetHidden(true)
					end
            	end
			end)

            --PreHook the OnMouseDown Handler at the ZOs mail to edit field
            ZO_PreHookHandler(ZO_MailSendToField, "OnMouseDown", function(control, button)
                if mb.settingsVars.settings.useAlternativeLayout then
                    if button == MOUSE_BUTTON_INDEX_RIGHT then
                        SOUNDS["EDIT_CLICK"] = SOUNDS["NONE"]
                    end
                end
            end)
            --PreHook the OnMouseUp Handler at the ZOs mail to edit field
            ZO_PreHookHandler(ZO_MailSendToField, "OnMouseUp", function(control, button, upInside)
                if mb.settingsVars.settings.useAlternativeLayout then
                    ZO_Tooltips_HideTextTooltip()
                    if upInside and button == MOUSE_BUTTON_INDEX_RIGHT then
                        mb.ShowBox("recipients", true, false, false, true)
                        SOUNDS["EDIT_CLICK"] = SOUNDS["EDIT_CLICK_MAILBUDDY_BACKUP"]
                    end
                end
            end)
            --PreHook the OnMouseEnter Handler at the ZOs mail to edit field
            ZO_PreHookHandler(ZO_MailSendToField, "OnMouseEnter", function(control)
                local settings = mb.settingsVars.settings
                if settings.showAlternativeLayoutTooltip and settings.useAlternativeLayout then
                    local recipientFieldTooltipText = ""
                    if mb.recipientsBox:IsHidden() then
                        recipientFieldTooltipText = "|cF0F0F0Right click|r to |c22DD22show|r recipients list"
                    else
                        recipientFieldTooltipText = "|cF0F0F0Right click to |cDD2222hide|r recipients list"
                    end
                    ZO_Tooltips_ShowTextTooltip(control, BOTTOMRIGHT, recipientFieldTooltipText)
                end
            end)
            --PreHook the OnMouseExit Handler at the ZOs mail to edit field
            ZO_PreHookHandler(ZO_MailSendToField, "OnMouseExit", function(control)
                --local settings = mb.settingsVars.settings
                --if settings.showAlternativeLayoutTooltip and settings.useAlternativeLayout then
                    ZO_Tooltips_HideTextTooltip()
                --end
            end)
            --PreHook the OnMouseDown Handler at the ZOs mail subject edit field
            ZO_PreHookHandler(ZO_MailSendSubjectField, "OnMouseDown", function(control, button)
                if mb.settingsVars.settings.useAlternativeLayout then
                    ZO_Tooltips_HideTextTooltip()
                    if button == MOUSE_BUTTON_INDEX_RIGHT then
                        SOUNDS["EDIT_CLICK"] = SOUNDS["NONE"]
                    end
                end
            end)
            --PreHook the OnMouseUp Handler at the ZOs mail subject edit field
            ZO_PreHookHandler(ZO_MailSendSubjectField, "OnMouseUp", function(control, button, upInside)
                if mb.settingsVars.settings.useAlternativeLayout then
                    if upInside and button == MOUSE_BUTTON_INDEX_RIGHT then
                        mb.ShowBox("subjects", true, false, false, true)
                        SOUNDS["EDIT_CLICK"] = SOUNDS["EDIT_CLICK_MAILBUDDY_BACKUP"]
                    end
                end
            end)
            --PreHook the OnMouseEnter Handler at the ZOs mail subject edit field
            ZO_PreHookHandler(ZO_MailSendSubjectField, "OnMouseEnter", function(control)
                local settings = mb.settingsVars.settings
                if settings.showAlternativeLayoutTooltip and settings.useAlternativeLayout then
                    local subjectFieldTooltipText = ""
                    if mb.subjectsBox:IsHidden() then
                        subjectFieldTooltipText = "|cF0F0F0Right click|r to |c22DD22show|r subjects list"
                    else
                        subjectFieldTooltipText = "|cF0F0F0Right click|r to |cDD2222hide|r subjects list"
                    end
                    ZO_Tooltips_ShowTextTooltip(control, BOTTOMRIGHT, subjectFieldTooltipText)
                end
            end)
            --PreHook the OnMouseExit Handler at the ZOs mail subject edit field
            ZO_PreHookHandler(ZO_MailSendSubjectField, "OnMouseExit", function(control)
                --local settings = mb.settingsVars.settings
                --if settings.showAlternativeLayoutTooltip and settings.useAlternativeLayout then
                    ZO_Tooltips_HideTextTooltip()
                --end
            end)

            --PreHook the standard mail sent method to store the recipient, subject and text (if wished)
            ZO_PreHook(MAIL_SEND, "Send", function()
                mb.RememberMailData()
            end)
            --PostHook the standard mail clear fields method to store the recipient, subject and text (if wished)
            ZO_PreHook(MAIL_SEND, "ClearFields", function()
                mb.RememberMailData()
                zo_callLater(function()
                    mb.SetRememberedMailData()
                end, 150)
            end)

            --Set the current selected recipient and subject texts
            local settings = mb.settingsVars.settings
            local curRecipientAbbreviated = settings.curRecipientAbbreviated
            local curSubjectAbbreviated = settings.curSubjectAbbreviated
            MailBuddy_MailSendRecipientLabelActiveText:SetText(curRecipientAbbreviated)
            mb.UpdateEditFieldToolTip(MailBuddy_MailSendRecipientLabelActiveText, settings.curRecipient, curRecipientAbbreviated)
	        MailBuddy_MailSendSubjectLabelActiveText:SetText(curSubjectAbbreviated)
            mb.UpdateEditFieldToolTip(MailBuddy_MailSendSubjectLabelActiveText, settings.curSubject, curSubjectAbbreviated)

			--Preset the standard mail recipient and subject from the settings after mail was send/not sent (error)
	        EM:RegisterForEvent(addonName, EVENT_MAIL_SEND_SUCCESS, function()
            	zo_callLater(function()
                    mb.SetRememberedMailData()
                end, 150)
            end)
	        EM:RegisterForEvent(addonName, EVENT_MAIL_SEND_FAILED, function()
            	zo_callLater(function()
                    mb.SetRememberedMailData()
                end, 150)
            end)

	end

    --Event Registry--
	EM:RegisterForEvent(addonName, EVENT_ADD_ON_LOADED, Initialize)
