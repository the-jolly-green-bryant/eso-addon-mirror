local mb = MailBuddy

local WM = WINDOW_MANAGER

function mb.UpdateRecipientText(pageIndex, doDelete)
--d("[MailBuddy]UpdateRecipientText-pageIndex: " ..tostring(pageIndex))
	if pageIndex == nil then return end
	doDelete = doDelete or false

    local page, pageEntry = mb.mapPageAndEntry(pageIndex, "recipient")
    if page ~= nil and pageEntry ~= nil then
        local settings = mb.settingsVars.settings
        local pages = mb.recipientPages.pages
		if pages[page][pageEntry] ~= "" then
			local labelControl = WM:GetControlByName(pages[page][pageEntry], "")
	        if labelControl ~= nil then
				--local currentName = labelControl:GetText()
                local currentName = settings.SetRecipient[pageIndex]
                local currentNameAbbreviated = settings.SetRecipientAbbreviated[pageIndex] or currentName
                if currentName ~= nil and currentName ~= "" then
				    if doDelete then
						labelControl:SetText("")
						mb.settingsVars.settings.SetRecipient[pageIndex] = ""
                        mb.settingsVars.settings.SetRecipientAbbreviated[pageIndex] = ""
						mb.PlaySoundNow(SOUNDS["MAIL_ITEM_DELETED"])
	                    if mb.editRecipient ~= nil then
		                    mb.editRecipient:TakeFocus()
	                    end
					else
                        if not settings.useAlternativeLayout then
                            MailBuddy_MailSendRecipientLabelActiveText:SetText(currentNameAbbreviated)
						    mb.UpdateEditFieldToolTip(MailBuddy_MailSendRecipientLabelActiveText, currentName, currentNameAbbreviated)
                        else
                            ZO_MailSendToField:SetText(string.format(currentName))
                        end
						mb.settingsVars.settings.curRecipient = currentName
                        mb.settingsVars.settings.curRecipientAbbreviated = currentNameAbbreviated
                        --Remember the last used recipient text
                        mb.settingsVars.settings.remember.recipient["text"] = currentName
                        mb.FocusNextField()
                        mb.PlaySoundNow(SOUNDS["QUEST_FOCUSED"])
                        mb.AutoCloseBox("recipients")
                    end
				end
	        end
	    end
    end
    --Revert to the original edit box clicked sound
    SOUNDS["EDIT_CLICK"] = SOUNDS["EDIT_CLICK_MAILBUDDY_BACKUP"]
end

function mb.UpdateSubjectText(pageIndex, doDelete, newText)
--d("[MailBuddy]UpdateSubjectText-pageIndex: " ..tostring(pageIndex) .. ", newText: " ..tostring(newText))
	if pageIndex == nil and (newText == nil or newText == "") then return end
    local settings = mb.settingsVars.settings
    --Only update the MailBuddy label/ZOs mail subject field witht he given text here
	if pageIndex == nil and (newText ~= nil and newText ~= "") then
        if not settings.useAlternativeLayout then
            MailBuddy_MailSendSubjectLabelActiveText:SetText(newText)
            mb.UpdateEditFieldToolTip(MailBuddy_MailSendSubjectLabelActiveText, newText, newText)
        else
            ZO_MailSendSubjectField:SetText(newText)
        end
        mb.settingsVars.settings.curSubject = newText
        mb.settingsVars.settings.curSubjectAbbreviated = newText
        --Remember the last used subject text
        mb.settingsVars.settings.remember.subject["text"]   = newText
        mb.FocusNextField()
        mb.PlaySoundNow(SOUNDS["QUEST_FOCUSED"])
        mb.AutoCloseBox("subjects")
        --Revert to the original edit box clicked sound
        SOUNDS["EDIT_CLICK"] = SOUNDS["EDIT_CLICK_MAILBUDDY_BACKUP"]
        return
    end
	doDelete = doDelete or false

    local page, pageEntry = mb.mapPageAndEntry(pageIndex, "subject")
    if page ~= nil and pageEntry ~= nil then
        local pages = mb.subjectPages.pages
		if pages[page][pageEntry] ~= "" then
			local labelControl = WM:GetControlByName(pages[page][pageEntry], "")
	        if labelControl ~= nil then
				--local currentSubject = labelControl:GetText()
    			local currentSubject = settings.SetSubject[pageIndex]
    			local currentSubjectAbbreviated = settings.SetSubjectAbbreviated[pageIndex] or currentSubject
				if currentSubject ~= nil and currentSubject ~= "" then
				    if doDelete then
						labelControl:SetText("")
						mb.settingsVars.settings.SetSubject[pageIndex] = ""
						mb.settingsVars.settings.SetSubjectAbbreviated[pageIndex] = ""
						mb.PlaySoundNow(SOUNDS["MAIL_ITEM_DELETED"])
                        if mb.editSubject ~= nil then
	                        mb.editSubject:TakeFocus()
                        end
					else
                        if not settings.useAlternativeLayout then
                            MailBuddy_MailSendSubjectLabelActiveText:SetText(currentSubjectAbbreviated)
                            mb.UpdateEditFieldToolTip(MailBuddy_MailSendSubjectLabelActiveText, currentSubject, currentSubjectAbbreviated)
                        else
                            ZO_MailSendSubjectField:SetText(currentSubject)
                        end
						mb.settingsVars.settings.curSubject = currentSubject
                        mb.settingsVars.settings.curSubjectAbbreviated = currentSubjectAbbreviated
                        --Remember the last used subject text
                        mb.settingsVars.settings.remember.subject["text"]   = currentSubject
                        mb.FocusNextField()
                        mb.PlaySoundNow(SOUNDS["QUEST_FOCUSED"])
                        mb.AutoCloseBox("subjects")
                    end
				end
	        end
	    end
    end
    --Revert to the original edit box clicked sound
    SOUNDS["EDIT_CLICK"] = SOUNDS["EDIT_CLICK_MAILBUDDY_BACKUP"]
end

function mb.StoreRecipient()
    --Check if the keybinding was pressed inside the guild roster or friends list, or if the mail send panel is open
    --and abort if not one of the panels is opened
    if 	  ZO_GuildRoster:IsHidden()
       and ZO_KeyboardFriendsList:IsHidden()
       and ZO_MailSend:IsHidden() then
    	return
    elseif not ZO_MailSend:IsHidden() and mb.keybindUsed then
    	return
    end

--d("StoreRecipients")
    --The new entered recipient text (sent by RETURN key)
	local enteredName = MailBuddy_MailSendRecipientsBoxEditNewRecipient:GetText()
	--Abort here if no name was given and just RETURN key was pressed
	if enteredName == "" or enteredName == mb.playerName or enteredName == mb.accountName then
    	return
    else
    	--Check if the entered name is valid
		local enteredNameFirstChar = string.sub(enteredName, 1)
        if enteredNameFirstChar:match("^[@A-Za-z0-9]+") == nil then
        	return
        end

    	--Name can only be 128 characters in length
        if string.len(enteredName) > 128 then
	        enteredName = string.sub(enteredName, 1, 128)
        end
    end

	--Add the text of the already saved names to an arry for a later comparison etc.
	local SetRecipients = {}
    local recipientPages = mb.recipientPages
    for i = 1, recipientPages.totalEntries, 1 do
	    local page, pageEntry = mb.mapPageAndEntry(i, "recipient")
	    if page ~= nil and pageEntry ~= nil then
			local editControl = WM:GetControlByName(recipientPages.pages[page][pageEntry], "")
			if editControl ~= nil then
--d("SetRecipients["..i.."] = mb.recipientPages.pages["..page.."]["..pageEntry.."]: " .. editControl:GetName())
	   			SetRecipients[i] = editControl:GetText()
	        end
		end
    end

	--Check new entered name against given names now and add it, if not already in the list
	local alreadyInList = false
    local newEntry = {}
    newEntry.found = false
    newEntry.page = 0
    newEntry.pageEntry = 0
    newEntry.index = 0
    local chatOutputRecipientAlreadyInListStr = mb.localizationVars.mb_loc["chat_output_recipient_already_in_list"]

	--Check all entered names before adding a new one
	for idx, nameText in pairs(SetRecipients) do
	    local page, pageEntry = mb.mapPageAndEntry(idx, "recipient")
	    if page ~= nil and pageEntry ~= nil then
--d("Stored name: " .. nameText .. ", New name: " .. enteredName)
			--Compare the stored name with the new entered name
			if string.lower(nameText) == string.lower(enteredName) then
				--d("[MailBuddy] Recipient name is already in the list!")
                mb.PlaySoundNow(SOUNDS["GENERAL_ALERT_ERROR"])
                d(chatOutputRecipientAlreadyInListStr)
                alreadyInList = true
				--Abort here as name is already in the list
		       	break
			end
	        --Check if an empty place is found
	        if nameText == "" then
--d("Stored name field is empty: Page " .. page .. ", index " .. pageEntry)
				--Mark empty place and remember the page + index
			    newEntry.found = true
			    newEntry.page = page
                newEntry.pageEntry = pageEntry
			    newEntry.index = idx
				--Break the loop here now as we have found an empty place to store the new name
	            break
            end
        end
    end
	--Was an empty entry found? Add the new name now
	if newEntry.found == true and newEntry.page ~= 0 and newEntry.index ~= 0 and newEntry.pageEntry ~= 0 then
        local newNameEditControl = WM:GetControlByName(recipientPages.pages[newEntry.page][newEntry.pageEntry], "")
		mb.settingsVars.settings.SetRecipient[newEntry.index] = enteredName
        local shortendName
        local maxCharRec = mb.maximumCharacters["recipients"]
        if string.len(enteredName) > maxCharRec then
        	shortendName = string.sub(enteredName, 1, maxCharRec) .. "..."
        else
        	shortendName = enteredName
        end
        mb.settingsVars.settings.SetRecipientAbbreviated[newEntry.index] = shortendName
    	newNameEditControl:SetText(string.format(shortendName))
		mb.editRecipient:Clear()
		mb.UpdateEditFieldToolTip(newNameEditControl, enteredName, shortendName)
        if mb.settingsVars.settings.useAlternativeLayout then
            if ZO_MailSendToField:GetText() == "" then
                ZO_MailSendToField:SetText(string.format(enteredName))
                --Remember the last used recipient text
                mb.settingsVars.settings.remember.recipient["text"] = enteredName
            end
        end
        mb.FocusNextField()
    	mb.PlaySoundNow(nil, ITEM_SOUND_CATEGORY_RING, ITEM_SOUND_ACTION_SLOT)
        mb.AutoCloseBox("recipients")
        return
    elseif not alreadyInList then
        --d("[MailBuddy] Your recipients list is full. Please delete at least one entry!")
        mb.PlaySoundNow(SOUNDS["GENERAL_ALERT_ERROR"])
        d(mb.localizationVars.mb_loc["chat_output_recipient_list_full"])
    end
    --Revert to the original edit box clicked sound
    SOUNDS["EDIT_CLICK"] = SOUNDS["EDIT_CLICK_MAILBUDDY_BACKUP"]
	return
end

function mb.StoreSubject()
--d("StoreSub")
    --The new entered subject text (sent by RETURN key)
	local enteredSubject = MailBuddy_MailSendSubjectsBoxEditNewSubject:GetText()
	--Abort here if no subject was given and just RETURN key was pressed
	if enteredSubject == "" then
    	return
    else
		--Subject can only be 45 characters (currently) in length
        if string.len(enteredSubject) > MAIL_MAX_SUBJECT_CHARACTERS then
	        enteredSubject = string.sub(enteredSubject, 1, MAIL_MAX_SUBJECT_CHARACTERS)
        end
    	local lowerCaseEnteredSubject = string.lower(enteredSubject)
        if lowerCaseEnteredSubject == "return" or lowerCaseEnteredSubject == "rts" or lowerCaseEnteredSubject == "bounce" then
            --d("[MailBuddy] Subject is already fixed at the top of the list!")
            mb.PlaySoundNow(SOUNDS["GENERAL_ALERT_ERROR"])
            d(mb.localizationVars.mb_loc["chat_output_subject_already_in_fixed_list"])
            --Revert to the original edit box clicked sound
            return
        end
    end

	--Add the text of the already saved names to an arry for a later comparison etc.
	local SubjectLines = {}
    local subjectPages = mb.subjectPages
    for i = 1, subjectPages.totalEntries, 1 do
	    local page, pageEntry = mb.mapPageAndEntry(i, "subject")
	    if page ~= nil and pageEntry ~= nil then
--d("Page: " .. page .. ", pageEntry: " .. pageEntry)
			local editControl = WM:GetControlByName(subjectPages.pages[page][pageEntry], "")
			if editControl ~= nil then
--d("SubjectLines["..i.."] = mb.subjectPages.pages["..page.."]["..pageEntry.."]: " .. editControl:GetName())
	   			SubjectLines[i] = editControl:GetText()
	        end
		end
    end

	--Check new entered name against given names now and add it, if not already in the list
    local alreadyInList = false
	local newEntry = {}
    newEntry.found = false
    newEntry.page = 0
    newEntry.pageEntry = 0
    newEntry.index = 0
    local chatOutputSubjectAlreadyInListStr = mb.localizationVars.mb_loc["chat_output_subject_already_in_list"]

	--Check all entered names before adding a new one
	for idx, subjectText in pairs(SubjectLines) do
	    local page, pageEntry = mb.mapPageAndEntry(idx, "subject")
	    if page ~= nil and pageEntry ~= nil then
--d("Stored subject: " .. subjectText .. ", New subject: " .. enteredSubject)
			--Compare the stored subject with the new entered subject
			if string.lower(subjectText) == string.lower(enteredSubject) then
				--d("[MailBuddy] Subject is already in the list!")
                mb.PlaySoundNow(SOUNDS["GENERAL_ALERT_ERROR"])
            	d(chatOutputSubjectAlreadyInListStr)
                alreadyInList = true
				--Abort here as subject is already in the list
		       	break
			end
	        --Check if an empty place is found
	        if subjectText == "" then
--d("Stored subject field is empty: Page " .. page .. ", index " .. pageEntry)
				--Mark empty place and remember the page + index
			    newEntry.found = true
			    newEntry.page = page
                newEntry.pageEntry = pageEntry
			    newEntry.index = idx
				--Break the loop here now as we have found an empty place to store the new subject
	            break
	        end
		end
	end
	--Was an empty entry found? Add the new subject now
	if newEntry.found == true and newEntry.page ~= 0 and newEntry.index ~= 0 and newEntry.pageEntry ~= 0 then
        local newSubjectEditControl = WM:GetControlByName(subjectPages.pages[newEntry.page][newEntry.pageEntry], "")
		mb.settingsVars.settings.SetSubject[newEntry.index] = enteredSubject
        local shortendSubject
        local maxCharSub = mb.maximumCharacters["subjects"]
        if string.len(enteredSubject) > maxCharSub then
			shortendSubject = string.sub(enteredSubject, 1, maxCharSub) .. "..."
        else
        	shortendSubject = enteredSubject
        end
		mb.settingsVars.settings.SetSubjectAbbreviated[newEntry.index] = shortendSubject
    	newSubjectEditControl:SetText(string.format(shortendSubject))
		mb.UpdateEditFieldToolTip(newSubjectEditControl, enteredSubject, shortendSubject)
		mb.editRecipient:Clear()
        if mb.settingsVars.settings.useAlternativeLayout then
            if ZO_MailSendSubjectField:GetText() == "" then
                ZO_MailSendSubjectField:SetText(string.format(enteredSubject))
                --Remember the last used subject text
                mb.settingsVars.settings.remember.subject["text"]   = enteredSubject
            end
        end
        mb.FocusNextField()
    	mb.PlaySoundNow(nil, ITEM_SOUND_CATEGORY_RING, ITEM_SOUND_ACTION_SLOT)
        mb.AutoCloseBox("subjects")
        return
    elseif not alreadyInList then
        --d("[MailBuddy] Your subjects list is full. Please delete at least one entry!")
        mb.PlaySoundNow(SOUNDS["GENERAL_ALERT_ERROR"])
		d(mb.localizationVars.mb_loc["chat_output_subject_list_full"])
    end

	return
end













 
