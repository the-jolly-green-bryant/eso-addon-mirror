function GS.InitRows()
	GS.Rows[1] = GS.TitleRow("GSRowTitle", ZO_GroupListHeaders, {633,4}, "$(BOLD_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
	local grouped = IsUnitGrouped("player")
	GS.Rows[1]:SetGrouped(grouped)
	if not grouped then return end
	
	local v, n
	-- efficient programming btw
	if ZO_GroupListList1Row1 ~= nil then
            n = string.match(ZO_GroupListList1Row1CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[2] = GS.Row("GSRow1", ZO_GroupListList1Row1, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[2]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row1Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row2 ~= nil then
            n = string.match(ZO_GroupListList1Row2CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[3] = GS.Row("GSRow2", ZO_GroupListList1Row2, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[3]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row2Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row3 ~= nil then
            n = string.match(ZO_GroupListList1Row3CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[4] = GS.Row("GSRow3", ZO_GroupListList1Row3, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[4]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row3Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row4 ~= nil then
            n = string.match(ZO_GroupListList1Row4CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[5] = GS.Row("GSRow4", ZO_GroupListList1Row4, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[5]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row4Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row5 ~= nil then
            n = string.match(ZO_GroupListList1Row5CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[6] = GS.Row("GSRow5", ZO_GroupListList1Row5, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[6]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row5Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row6 ~= nil then
            n = string.match(ZO_GroupListList1Row6CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[7] = GS.Row("GSRow6", ZO_GroupListList1Row6, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[7]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row6Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row7 ~= nil then
            n = string.match(ZO_GroupListList1Row7CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[8] = GS.Row("GSRow7", ZO_GroupListList1Row7, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[8]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row7Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row8 ~= nil then
            n = string.match(ZO_GroupListList1Row8CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[9] = GS.Row("GSRow8", ZO_GroupListList1Row8, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[9]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row8Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row9 ~= nil then
            n = string.match(ZO_GroupListList1Row9CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[10] = GS.Row("GSRow9", ZO_GroupListList1Row9, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[10]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row9Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row10 ~= nil then
            n = string.match(ZO_GroupListList1Row10CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[11] = GS.Row("GSRow10", ZO_GroupListList1Row10, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[11]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row10Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row11 ~= nil then
            n = string.match(ZO_GroupListList1Row11CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[12] = GS.Row("GSRow11", ZO_GroupListList1Row11, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[12]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row11Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row12 ~= nil then
            n = string.match(ZO_GroupListList1Row12CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[13] = GS.Row("GSRow12", ZO_GroupListList1Row12, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[13]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row12Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row13 ~= nil then
            n = string.match(ZO_GroupListList1Row13CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[14] = GS.Row("GSRow13", ZO_GroupListList1Row13, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[14]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row13Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row14 ~= nil then
            n = string.match(ZO_GroupListList1Row14CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[15] = GS.Row("GSRow14", ZO_GroupListList1Row14, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[15]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row14Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row15 ~= nil then
            n = string.match(ZO_GroupListList1Row15CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[16] = GS.Row("GSRow15", ZO_GroupListList1Row15, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[16]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row15Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row16 ~= nil then
            n = string.match(ZO_GroupListList1Row16CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[17] = GS.Row("GSRow16", ZO_GroupListList1Row16, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[17]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row16Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row17 ~= nil then
            n = string.match(ZO_GroupListList1Row17CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[18] = GS.Row("GSRow17", ZO_GroupListList1Row17, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[18]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row17Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row18 ~= nil then
            n = string.match(ZO_GroupListList1Row18CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[19] = GS.Row("GSRow18", ZO_GroupListList1Row18, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[19]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row18Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row19 ~= nil then
            n = string.match(ZO_GroupListList1Row19CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[20] = GS.Row("GSRow19", ZO_GroupListList1Row19, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[20]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row19Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row20 ~= nil then
            n = string.match(ZO_GroupListList1Row20CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[21] = GS.Row("GSRow20", ZO_GroupListList1Row20, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[21]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row20Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row21 ~= nil then
            n = string.match(ZO_GroupListList1Row21CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[22] = GS.Row("GSRow21", ZO_GroupListList1Row21, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[22]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row21Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row22 ~= nil then
            n = string.match(ZO_GroupListList1Row22CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[23] = GS.Row("GSRow22", ZO_GroupListList1Row22, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[23]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row22Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row23 ~= nil then
            n = string.match(ZO_GroupListList1Row23CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[24] = GS.Row("GSRow23", ZO_GroupListList1Row23, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[24]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row23Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
	if ZO_GroupListList1Row24 ~= nil then
            n = string.match(ZO_GroupListList1Row24CharacterName:GetText(),'%d%.%s(.+)')
            for i = 1,24 do
                    if GetUnitName("group"..i) == n then
                            v = i
                            break
                    end
            end
            GS.Rows[25] = GS.Row("GSRow24", ZO_GroupListList1Row24, {630,3}, v, "$(CHAT_FONT)|$(KB_18)|soft-shadow-thin", GS.savedVars.extended)
            GS.Rows[25]:SetOffline(not IsUnitOnline("group"..v))
			if GS.savedVars.useExisting == true then ZO_GroupListList1Row24Level:SetText(GetUnitChampionPoints("group"..v)) end
    end
end