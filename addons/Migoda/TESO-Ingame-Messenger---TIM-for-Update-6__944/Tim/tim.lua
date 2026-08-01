--	===============================================================================================================
--
--	TIM - TESO Ingame Messenger
--	---------------------------
--
--
--	Nie wieder eine wichtige Nachricht verpassen!
--
--	TESO in seinen ersten Versionen hat eine Schwaeche im Bereich Chatsystem.
--	TIM will hier in die Bresche springen und die eingehenden Nachrichten sortiert aufbewahren
--
--	Entscheide selbst, was TIM fuer Dich aufbewahren soll und wie lange.
--	TIM zeigt Dir, wenn wichtige Nachrichten fuer Dich eingegangen sind, so dass Du nicht mehr
--	andauernd an den Bildschirm gefesselt bist.
--
--	Bist Du Gildenmeister steht Dir TIM bei, wenn gildenweite Aktionen zu erledigen sind...
--	...Einladungen zum Gildentreffen, Aufraeumaktionen wegen zu langer Abwesenheit, Gildenwerbung und vieles mehr
--
--
--	Ich hoffe, TIM wird auch Dir helfen und Dich begeistern...
--
--
--	Bis bald - irgendwo in Tamriel!
--
--	(c) im Juni 2014	by @Sternentau
--
--	===============================================================================================================

tim={}
tim.name="tim"
tim.version="5.52"
tim.isDebug=false
tim.loaded=false
tim.PlayerReady=false

function tim.sendMessage(message,bPrefixed)
	if(CHAT_SYSTEM)	then
		if bPrefixed==true then
			CHAT_SYSTEM:AddMessage("|cFCFCFCTIM: |r|c"..tim.chatcolor..message.."|r")
		else
			CHAT_SYSTEM:AddMessage("|c"..tim.chatcolor..message.."|r")
		end
	end
end


function tim.sendDebugMessage(message)
	if tim.isDebug==true then
		tim.sendMessage("DEBUG: "..message,false)
	end
end


function tim.sendChatMessage(message)
	if(CHAT_SYSTEM)	then
		-- an das Chatsystem weitergeben
		CHAT_SYSTEM:StartTextEntry(message)
		ZO_ChatWindowTextEntry:SetAlpha(1)
		ZO_ChatWindowTextEntryEditBox:SelectAll()
		ZO_ChatWindowTextEntryEditBox:TakeFocus()
	end
end


function tim.isAlertMessage(mtype)
	local alert=false
	if (tim.isChannel(mtype)==tim.queuew) and (string.sub(tim.vars.AlertOptionW,1,1)=="2") then
		alert=true
	end
	if (tim.isChannel(mtype)==tim.queuep) and (string.sub(tim.vars.AlertOptionP,1,1)=="2") then
		alert=true
	end
	if (((mtype==tim.msgTypeG1) or (mtype==tim.msgTypeO1)) and (string.sub(tim.vars.AlertOptionG1,1,1)=="2")) then
		alert=true
	end
	if (((mtype==tim.msgTypeG2) or (mtype==tim.msgTypeO2)) and (string.sub(tim.vars.AlertOptionG2,1,1)=="2")) then
		alert=true
	end
	if (((mtype==tim.msgTypeG3) or (mtype==tim.msgTypeO3)) and (string.sub(tim.vars.AlertOptionG3,1,1)=="2")) then
		alert=true
	end
	if (((mtype==tim.msgTypeG4) or (mtype==tim.msgTypeO4)) and (string.sub(tim.vars.AlertOptionG4,1,1)=="2")) then
		alert=true
	end
	if (((mtype==tim.msgTypeG5) or (mtype==tim.msgTypeO5)) and (string.sub(tim.vars.AlertOptionG5,1,1)=="2")) then
		alert=true
	end
	if (tim.isChannel(mtype)==tim.queuez) and (string.sub(tim.vars.AlertOptionZ,1,1)=="2") then
		alert=true
	end
	if (tim.isChannel(mtype)==tim.queues) and (string.sub(tim.vars.AlertOptionS,1,1)=="2") then
		alert=true
	end
	return alert
end


function tim.isMessageAllowed(mtype)
	local allowed=false
	if tim.isChannel(mtype)==tim.queuew and string.sub(tim.vars.AlertOptionW,1,1)~="0" then
		allowed=true
	end
	if tim.isChannel(mtype)==tim.queuep and string.sub(tim.vars.AlertOptionP,1,1)~="0" then
		allowed=true
	end
	if (((mtype==tim.msgTypeG1) or (mtype==tim.msgTypeO1)) and (string.sub(tim.vars.AlertOptionG1,1,1)~="0")) then
		allowed=true
	end
	if (((mtype==tim.msgTypeG2) or (mtype==tim.msgTypeO2)) and (string.sub(tim.vars.AlertOptionG2,1,1)~="0")) then
		allowed=true
	end
	if (((mtype==tim.msgTypeG3) or (mtype==tim.msgTypeO3)) and (string.sub(tim.vars.AlertOptionG3,1,1)~="0")) then
		allowed=true
	end
	if (((mtype==tim.msgTypeG4) or (mtype==tim.msgTypeO4)) and (string.sub(tim.vars.AlertOptionG4,1,1)~="0")) then
		allowed=true
	end
	if (((mtype==tim.msgTypeG5) or (mtype==tim.msgTypeO5)) and (string.sub(tim.vars.AlertOptionG5,1,1)~="0")) then
		allowed=true
	end
	if tim.isChannel(mtype)==tim.queuez and string.sub(tim.vars.AlertOptionZ,1,1)~="0" then
		allowed=true
	end
	if tim.isChannel(mtype)==tim.queues and string.sub(tim.vars.AlertOptionS,1,1)~="0" then
		allowed=true
	end
	return allowed
end


function tim.isChannel(mtype)
	local temp=0
	if ((mtype==2) or (mtype==4)) then
		temp=tim.queuew
	end
	if ((mtype==0) or (mtype==1) or (mtype==6)) then
		temp=tim.queues
	end
	if mtype==3 then
		temp=tim.queuep
	end
	if ((mtype>=tim.msgTypeZ1) and (mtype<=tim.msgTypeZ4)) then
		temp=tim.queuez
	end
	if ((mtype>=tim.msgTypeG1) and (mtype<=tim.msgTypeO5)) then
		temp=tim.queueg
	end
	return temp
end


function tim.to2string(wert)
	local swert=tostring(wert)
	if string.len(swert)<2 then
		swert="0"..swert
	end
	return swert
end


function tim.trim(inStr)
	local temp=inStr
	if temp~=nil then
		while string.len(temp)>0 and string.sub(temp,1,1)==" " do
			temp=string.sub(temp,2)
		end
		while string.len(temp)>0 and string.sub(temp,string.len(temp),string.len(temp))==" " do
			temp=string.sub(temp,1,string.len(temp)-1)
		end
	end
	return temp
end


function tim.detil(withit)
	local pos=string.find(withit,"^",1,true)
	if pos then
		return string.sub(withit,1,pos-1)
	else
		return withit
	end
end


function tim.getMessageFrom(messagesender,part,messageType)
	local toReturn=messagesender
	local pos=string.find(messagesender,tim.messageFromSeparator,1,true)
	if pos then
		if part==1 then
			toReturn=string.sub(messagesender,1,pos-1)
		else
			toReturn=string.sub(messagesender,pos+1)
		end
	else
		if part==1 then
			toReurn=messagesender
		else
			toReturn=tim.getGuildCharName(messagesender,messageType)
		end
	end
	return toReturn
end


function tim.addTimMessage(queue,index,toClipboard)
	-- auf gelesen setzen, wenn das Fenster sichtbar ist
	if toClipboard==false then
		if tim.WindowVisible==true then
			tim.vars.msg[queue].munread[index]=false
		end
	end
	local mtype=tim.vars.msg[queue].mtype[index]
	local mfrom=tim.vars.msg[queue].mfrom[index]
	if mtype==4 then
		-- bei Whisper den Namen des Senders korrigieren... muss der eigene Name sein
		mfrom=tim.vars.DisplayName
		-- moeglicherweise funktioniert GetDisplayName() ab Craglorn nicht mehr?
		if mfrom=="" then
			mfrom=GetUnitName("player")
		end
	end
	-- Farbe grundsaetzlich auf weiss setzen
	local r,g,b,a=GetInterfaceColor(INTERFACE_COLOR_TYPE_CHAT_CHANNEL_CATEGORY_DEFAULTS,1)
	-- Farbe nach Nachrichtentypen korrigieren
	if mtype==2 then
		r,g,b,a=GetInterfaceColor(INTERFACE_COLOR_TYPE_CHAT_CHANNEL_CATEGORY_DEFAULTS,3)
	else
		if mtype==4 then
			r,g,b,a=GetInterfaceColor(INTERFACE_COLOR_TYPE_CHAT_CHANNEL_CATEGORY_DEFAULTS,4)
		else
			if mtype==6 then
				r,g,b,a=GetInterfaceColor(INTERFACE_COLOR_TYPE_CHAT_CHANNEL_CATEGORY_DEFAULTS,8)
			else
				if tim.isChannel(mtype)==tim.queuep then
					r,g,b,a=GetInterfaceColor(INTERFACE_COLOR_TYPE_CHAT_CHANNEL_CATEGORY_DEFAULTS,7)
				else
					if tim.isChannel(mtype)==tim.queuez then
						r,g,b,a=GetInterfaceColor(INTERFACE_COLOR_TYPE_CHAT_CHANNEL_CATEGORY_DEFAULTS,6)
					else
						if ((mtype>=tim.msgTypeG1) and (mtype<=tim.msgTypeO5)) then
							if mtype<tim.msgTypeO1 then
								r,g,b,a=GetInterfaceColor(INTERFACE_COLOR_TYPE_CHAT_CHANNEL_CATEGORY_DEFAULTS,13)
							else
								r,g,b,a=GetInterfaceColor(INTERFACE_COLOR_TYPE_CHAT_CHANNEL_CATEGORY_DEFAULTS,18)
							end
						end
					end
				end
			end
		end
	end
	-- die Nachricht formatiert aufbauen
	local mtext=tim.trim(tim.vars.msg[queue].mtext[index])
	local trigger=string.sub(mtext,1,string.len(tim.codeTrigger))
	-- eine verschluesselte Nachricht entschluesseln
	if trigger==tim.codeTrigger then
		mtext=tim.decodeMessage(string.sub(mtext,string.len(tim.codeTrigger)+1))
	end
	-- Timestamp formatieren
	local mdate=math.floor(tim.vars.msg[queue].mtime[index] / 1000000)
	local mtime=tim.vars.msg[queue].mtime[index]-mdate*1000000
	local myear=math.floor(mdate/10000)
	mdate=mdate-myear*10000
	local mmonth=math.floor(mdate/100)
	local mday=mdate-mmonth*100
	-- US-Datum formatieren
	local sdate=tim.to2string(mmonth).."/"..tim.to2string(mday)
	if tim.loadedLoc=="DE" then
		sdate=tim.to2string(mday).."/"..tim.to2string(mmonth)
	end
	local mhour=math.floor(mtime/10000)
	local mminute=mtime-mhour*10000
	mminute=math.floor(mminute/100)
	local stime=tim.to2string(mhour)..":"..tim.to2string(mminute)
	-- bei Gilden den Charnamen umwandeln, wenn gewuenscht
	local mfromG=mfrom
	if queue==tim.queueg then
		if tim.vars.rtvGuildCharNames==true then
			mfromG=tim.getMessageFrom(mfrom,2,mtype)
		else
			mfromG=tim.getMessageFrom(mfrom,1,mtype)
		end
	end
	-- Bei Gilden den Sender korrigieren, damit der Link funktioniert
	if queue==tim.queueg then
		mfrom=tim.getMessageFrom(mfrom,1,mtype)
	end
	-- So, jetzt alles zusammenstoepseln, zuerst den Timestamp
	local msgtod=""
	if ((tim.vars.MsgOptD==true) or (tim.vars.MsgOptT==true)) then
		if toClipboard==false then
			msgtod=msgtod.."|c"..tim.timestampColor
		end
		if tim.vars.MsgOptD==true then
			msgtod=msgtod..sdate.." "
		end
		if tim.vars.MsgOptT==true then
			msgtod=msgtod..stime.." "
		end
		if toClipboard==false then
			msgtod=msgtod.."|r"
		end
	end
	-- Dann den Absender und dann raus damit
	if toClipboard==false then
		msgtod=msgtod..tim.playerLink(mfromG,mfrom)..": "
	else
		msgtod=msgtod..mfromG..": "
	end
	if toClipboard==true then
		if string.len(tim.vars.Clipboard)>0 then
			tim.vars.Clipboard=tim.vars.Clipboard.."\n"..msgtod..mtext
		else
			tim.vars.Clipboard=msgtod..mtext
		end
	else
		timWindowRolle:AddMessage(msgtod..mtext,r,g,b,a)
		-- den Slider an die neue Anzahl Zeilen anpassen und wieder hochstellen, wenn er ganz oben war
		local s2min,s2max=tim.slider2:GetMinMax()
		if tim.slider2:GetValue()==s2max then
			tim.UpdateRolleSlider()
			tim.slider2:SetValue(timWindowRolle:GetNumHistoryLines())
		else
			tim.UpdateRolleSlider()
		end
		-- jetzt noch die Tooltipstatistiken anpassen und gut
		tim.TooltipStatistics()
	end
end


function tim.isLoMmessage(lomtype,queue,index)
	local isLoM=false
	local LoMword={}
	local mtext=""
	local looper=0
	local isAnActiveQueue=true
	local mtype=tim.vars.msg[queue].mtype[index]
	-- sehen, ob der Nachrichtentyp ueberhaupt aktiv ist
	if tim.isSupressedMessage(mtype)==false then
		-- sehen, ob der LoM ueberhaupt aktiv ist
		if string.len(tim.vars.LoM[lomtype-tim.firstMagic+1].LoMname)>0 then
			-- die magischen Worte holen
			for looper=1,tim.LoMwords,1 do
				LoMword[looper]=string.upper(tim.vars.LoM[lomtype-tim.firstMagic+1].LoMword[looper])
			end
			mtext=tim.vars.msg[queue].mtext[index]
			mtext=string.upper(mtext)
			mfrom=tim.vars.msg[queue].mfrom[index]
			mfrom=string.upper(mfrom)
			for looper=1,tim.LoMwords,1 do
				if looper<tim.LoMwords then
					-- durch die *SELECT Words gehen
					if string.len(LoMword[looper])>1 then
						-- Den Nachrichteninhalt UND den Absendernamen betrachten
						if ((string.find(mtext,LoMword[looper],1,true)~=nil) or (string.find(mfrom,LoMword[looper],1,true)~=nil)) then
							isLoM=true
						end
					end
				else
					-- durch die *OMIT Words (nur das letzte) gehen
					if string.len(LoMword[looper])>1 then
						if string.find(mtext,LoMword[looper],1,true)~=nil then
							isLoM=false
						end
					end
				end
			end
		end
	end
	return isLoM
end


function tim.addTempMessage(queue,index)
	tim.tcount=tim.tcount+1
	tim.ttime[tim.tcount]=tim.vars.msg[queue].mtime[index]
	tim.tqueue[tim.tcount]=queue
	tim.tindex[tim.tcount]=index
end


function tim.sortTempMessages()
	local bswitched=true
	local firstElem=1
	local lastElem=tim.tcount
	while bswitched==true do
		bswitched=false
		local looper=firstElem
		while looper<lastElem do
			if tim.ttime[looper]>tim.ttime[looper+1] then
				local xtime=tim.ttime[looper]
				local xqueue=tim.tqueue[looper]
				local xindex=tim.tindex[looper]
				tim.ttime[looper]=tim.ttime[looper+1]
				tim.tqueue[looper]=tim.tqueue[looper+1]
				tim.tindex[looper]=tim.tindex[looper+1]
				tim.ttime[looper+1]=xtime
				tim.tqueue[looper+1]=xqueue
				tim.tindex[looper+1]=xindex
				bswitched=true
			end
			looper=looper+1
		end
		lastElem=lastElem-1
	end
end


function tim.changeGOVrolle(govindex,toClipboard)
	-- Anwender hat auf einen GOV-Button gedrueckt
	tim.govactive=govindex
	if toClipboard==true then
		tim.vars.Clipboard=""
	else
		timWindowRolle:Clear()
	end
	local Looper=0
	if govindex>0 then
		if tim.isChannel(tim.gov.vtype[govindex])==tim.queuew then
			-- wir suchen einen Whisper
			Looper=0
			while Looper<tim.vars.msgindex[tim.queuew] do
				Looper=Looper+1
				if tim.vars.msg[tim.queuew].mfrom[Looper]==tim.gov.vname[govindex] then
					tim.addTimMessage(tim.queuew,Looper,toClipboard)
				end
			end
		end
		if tim.isChannel(tim.gov.vtype[govindex])==tim.queuep then
			-- Wir suchen eine Gruppennachricht
			Looper=0
			while Looper<tim.vars.msgindex[tim.queuep] do
				Looper=Looper+1
				if tim.vars.msg[tim.queuep].mtype[Looper]==tim.gov.vtype[govindex] then
					tim.addTimMessage(tim.queuep,Looper,toClipboard)
				end
			end
		end
		if tim.isChannel(tim.gov.vtype[govindex])==tim.queueg then
			-- Wir suchen eine Gildennachricht
			Looper=0
			while Looper<tim.vars.msgindex[tim.queueg] do
				Looper=Looper+1
				if tim.vars.msg[tim.queueg].mtype[Looper]==tim.gov.vtype[govindex] then
					tim.addTimMessage(tim.queueg,Looper,toClipboard)
				end
			end
		end
		if tim.isChannel(tim.gov.vtype[govindex])==tim.queuez then
			-- Wir suchen eine Zonennachricht
			Looper=0
			while Looper<tim.vars.msgindex[tim.queuez] do
				Looper=Looper+1
				if tim.vars.msg[tim.queuez].mtype[Looper]==tim.gov.vtype[govindex] then
					tim.addTimMessage(tim.queuez,Looper,toClipboard)
				end
			end
		end
		if tim.isChannel(tim.gov.vtype[govindex])==tim.queues then
			-- Wir suchen eine Sprechen-Nachricht
			Looper=0
			while Looper<tim.vars.msgindex[tim.queues] do
				Looper=Looper+1
				tim.addTimMessage(tim.queues,Looper,toClipboard)
			end
		end
		if (tim.gov.vtype[govindex]>=tim.firstMagic) and (tim.gov.vtype[govindex]<=(tim.firstMagic+tim.LoMrecords-1)) then
			-- Anwender hat auf einen magischen Kanal gedrueckt - der muss komplett zusammengestellt werden
			tim.tcount=0
			tim.ttime={}
			tim.tqueue={}
			tim.tindex={}
			-- Wir suchen eine LoM Nachricht im Whisper
			Looper=0
			while Looper<tim.vars.msgindex[tim.queuew] do
				Looper=Looper+1
				if tim.isLoMmessage(tim.gov.vtype[govindex],tim.queuew,Looper)==true then
					tim.addTempMessage(tim.queuew,Looper)
				end
			end
			-- Wir suchen eine LoM Nachricht in der Gruppe
			Looper=0
			while Looper<tim.vars.msgindex[tim.queuep] do
				Looper=Looper+1
				if tim.isLoMmessage(tim.gov.vtype[govindex],tim.queuep,Looper)==true then
					tim.addTempMessage(tim.queuep,Looper,toClipboard)
				end
			end
			-- Wir suchen eine LoM Nachricht in der Gilde
			Looper=0
			while Looper<tim.vars.msgindex[tim.queueg] do
				Looper=Looper+1
				if tim.isLoMmessage(tim.gov.vtype[govindex],tim.queueg,Looper)==true then
					tim.addTempMessage(tim.queueg,Looper,toClipboard)
				end
			end
			-- Wir suchen eine LoM Nachricht in der Zone
			Looper=0
			while Looper<tim.vars.msgindex[tim.queuez] do
				Looper=Looper+1
				if tim.isLoMmessage(tim.gov.vtype[govindex],tim.queuez,Looper)==true then
					tim.addTempMessage(tim.queuez,Looper,toClipboard)
				end
			end
			-- Wir suchen eine LoM Nachricht in der Sprache
			Looper=0
			while Looper<tim.vars.msgindex[tim.queues] do
				Looper=Looper+1
				if tim.isLoMmessage(tim.gov.vtype[govindex],tim.queues,Looper)==true then
					tim.addTempMessage(tim.queues,Looper,toClipboard)
				end
			end
			tim.sortTempMessages()
			Looper=0
			while Looper<tim.tcount do
				Looper=Looper+1
				tim.addTimMessage(tim.tqueue[Looper],tim.tindex[Looper],toClipboard)
			end
			tim.tcount=nil
			tim.ttime=nil
			tim.tqueue=nil
			tim.tindex=nil
		end
		tim.gov.vunread[govindex]=0
	end
	-- Aktuelle Markierung setzen
	if toClipboard==false then
		tim.slider2:SetValue(timWindowRolle:GetNumHistoryLines())
	end
	tim.UpdateGovButtons(tim.govFirstButton)
end


function tim.govcmd(mtype)
	local scmd=""
	if mtype==2 or mtype==4 then
		scmd="/w"
	else
		if mtype==0 or mtype==1 or mtype==6 then
			scmd="/s"
		else
			if mtype==3 then
				scmd="/p"
			else
				if mtype==tim.msgTypeZ1 then
					scmd="/z"
				else
					if mtype==tim.msgTypeZ2 then
						scmd="/zen"
					else
						if mtype==tim.msgTypeZ3 then
							scmd="/zfr"
						else
							if mtype==tim.msgTypeZ4 then
								scmd="/zde"
							else
								if mtype==tim.msgTypeG1 then
									scmd="/g1"
								else
									if mtype==tim.msgTypeG2 then
										scmd="/g2"
									else
										if mtype==tim.msgTypeG3 then
											scmd="/g3"
										else
											if mtype==tim.msgTypeG4 then
												scmd="/g4"
											else
												if mtype==tim.msgTypeG5 then
													scmd="/g5"
												else
													if mtype==tim.msgTypeO1 then
														scmd="/o1"
													else
														if mtype==tim.msgTypeO2 then
															scmd="/o2"
														else
															if mtype==tim.msgTypeO3 then
																scmd="/o3"
															else
																if mtype==tim.msgTypeO4 then
																	scmd="/o4"
																else
																	if mtype==tim.msgTypeO5 then
																		scmd="/o5"
																	end
																end
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	return scmd
end


function tim.deletemsg(queue,entry)
	local looper=entry
	-- loeschen durch herunterziehen
	while looper<tim.vars.msgindex[queue] do
		tim.vars.msg[queue].mtime[looper]=tim.vars.msg[queue].mtime[looper+1]
		tim.vars.msg[queue].mtype[looper]=tim.vars.msg[queue].mtype[looper+1]
		tim.vars.msg[queue].mfrom[looper]=tim.vars.msg[queue].mfrom[looper+1]
		tim.vars.msg[queue].mtext[looper]=tim.vars.msg[queue].mtext[looper+1]
		tim.vars.msg[queue].munread[looper]=tim.vars.msg[queue].munread[looper+1]
		looper=looper+1
	end
	--- tatsaechlich loeschen
	tim.vars.msg[queue].mtime[tim.vars.msgindex[queue]]=nil
	tim.vars.msg[queue].mtype[tim.vars.msgindex[queue]]=nil
	tim.vars.msg[queue].mfrom[tim.vars.msgindex[queue]]=nil
	tim.vars.msg[queue].mtext[tim.vars.msgindex[queue]]=nil
	tim.vars.msg[queue].munread[tim.vars.msgindex[queue]]=nil
	tim.vars.msgindex[queue]=tim.vars.msgindex[queue]-1
	tim.TooltipStatistics()
end


function tim.deleteGOV(index)
	local looper=0
	tim.talkHistoryRemove(tim.gov.vname[index])
	if tim.isChannel(tim.gov.vtype[index])==tim.queuew then
		-- einen bestimmten whisper loeschen
		looper=1
		while looper<=tim.vars.msgindex[tim.queuew] do
			if tim.vars.msg[tim.queuew].mfrom[looper]==tim.gov.vname[index] then
				tim.deletemsg(tim.queuew,looper)
			else
				looper=looper+1
			end
		end
	end
	if tim.isChannel(tim.gov.vtype[index])==tim.queueg then
		-- Nachrichten einer bestimmten Gilde loeschen
		looper=1
		while looper<=tim.vars.msgindex[tim.queueg] do
			if tim.vars.msg[tim.queueg].mtype[looper]==tim.gov.vtype[index] then
				tim.deletemsg(tim.queueg,looper)
			else
				looper=looper+1
			end
		end
	end
	if tim.isChannel(tim.gov.vtype[index])==tim.queuez then
		-- eine bestimmte Zone loeschen
		looper=1
		while looper<=tim.vars.msgindex[tim.queuez] do
			if tim.vars.msg[tim.queuez].mtype[looper]==tim.gov.vtype[index] then
				tim.deletemsg(tim.queuez,looper)
			else
				looper=looper+1
			end
		end
	end
	if tim.isChannel(tim.gov.vtype[index])==tim.queues then
		-- gesamte say loeschen
		tim.vars.msg[tim.queues]={mtime={}, mtype={}, mfrom={}, mtext={}, munread={}}
		tim.vars.msgindex[tim.queues]=0
	end
	if tim.isChannel(tim.gov.vtype[index])==tim.queuep then
		-- gesamte party loeschen
		tim.vars.msg[tim.queuep]={mtime={}, mtype={}, mfrom={}, mtext={}, munread={}}
		tim.vars.msgindex[tim.queuep]=0
	end
	tim.ReCreateGOV()
	-- Auf den "gleichen" Eintrag wieder klicken, oder auf den hoechsten, wenn das nicht geht (das kann auch 0 sein)
	if tim.govindex>=index then
		tim.changeGOVrolle(index,false)
	else
		tim.changeGOVrolle(tim.govindex,false)
	end
	tim.TooltipStatistics()
end


function tim.answerGOV(index)
	if index>0 then
		local cmdString=tim.govcmd(tim.gov.vtype[index])
		if string.len(cmdString)>0 then
			cmdString=cmdString.." "
			if tim.isChannel(tim.gov.vtype[index])==tim.queuew then
				cmdString=cmdString..tim.gov.vname[index].." "
			end
			-- an das Chatsystem weitergeben
			tim.sendChatMessage(cmdString)
		end
	end
end


function tim.addToGuild(xname,xplayerStatus,xsecsSinceLogoff,xhasCharacter,xcharacterName,xzoneName,xclassType,xalliance,xlevel,xveteranRank)
	tim.guildindex=tim.guildindex+1
	tim.guild.maccount[tim.guildindex]=xname
	tim.guild.mstatus[tim.guildindex]=xplayerStatus
	tim.guild.msecsoff[tim.guildindex]=xsecsSinceLogoff
	if xhasCharacter==true then
		tim.guild.mchar[tim.guildindex]=tim.detil(xcharacterName)
	else
		tim.guild.mchar[tim.guildindex]=""
	end
	tim.guild.mzone[tim.guildindex]=tim.detil(xzoneName)
	tim.guild.mclasstype[tim.guildindex]=xclassType
	tim.guild.malliance[tim.guildindex]=xalliance
	tim.guild.mlevel[tim.guildindex]=xlevel
	tim.guild.mveteranRank[tim.guildindex]=xveteranRank
end


function tim.GetMyDisplayName()
	local guildID=GetGuildId(1)
	if guildID~=0 then
		local guildMembers=GetNumGuildMembers(guildID) 
		local looper=0
		local myCharName=GetUnitName("player")
		while looper<guildMembers do
			looper=looper+1
			local xname, xnote, xrankIndex, xplayerStatus, xsecsSinceLogoff=GetGuildMemberInfo(guildID, looper)
			local xhasCharacter, xcharacterName, xzoneName, xclassType, xalliance, xlevel, xveteranRank=GetGuildMemberCharacterInfo(guildID, looper)
			if tim.detil(xcharacterName)==myCharName then
				tim.vars.DisplayName=xname
			end
		end
	else
		-- Ohne Gilde kann der Accountname nicht festgestellt werden
		tim.vars.DisplayName=""
	end
end

			
function tim.guildReadGuild()
	tim.guild={maccount={}, mstatus={}, msecsoff={}, mchar={}, mzone={}, mclasstype={}, malliance={}, mlevel={},mveteranRank={},}
	tim.guildindex=0
	if tim.vars.actualGuild~=0 then
		local multi=1
		if tim.vars.queryUnits==1 then
			multi=60
		else
			if tim.vars.queryUnits==2 then
				multi=3600
			else
				if tim.vars.queryUnits==3 then
					multi=86400
				else
					if tim.vars.queryUnits==4 then
						multi=2678400
					end
				end
			end
		end
		local offseconds=tim.vars.queryCounts*multi
		local guildID=GetGuildId(tim.vars.actualGuild)
		local guildMembers=GetNumGuildMembers(guildID) 
		local looper=0
		while looper<guildMembers do
			looper=looper+1
			local xname, xnote, xrankIndex, xplayerStatus, xsecsSinceLogoff=GetGuildMemberInfo(guildID, looper)
			local xhasCharacter, xcharacterName, xzoneName, xclassType, xalliance, xlevel, xveteranRank=GetGuildMemberCharacterInfo(guildID, looper)
			-- grundsaetzlich anzeigen
			local bAddMember=true
			if (tim.vars.queryStatus==2) and (xplayerStatus==4) then
				-- online sollte gesucht werden, member ist aber offline
				bAddMember=false
			end
			if (tim.vars.queryStatus==3) and (xplayerStatus<4) then
				-- onffline sollte gesucht werden, member ist aber online
				bAddMember=false
			end
--	///		if (tim.vars.queryIgnore==1) and (xsecsSinceLogoff<offseconds) then
--				-- nicht lange genug offline
--				bAddMember=false
--			end
			if tim.vars.queryIgnore==1 then
				if tim.vars.queryGtlt==1 then
					if xsecsSinceLogoff<offseconds then
						-- nicht lange offline genug
						bAddMember=false
					end
				else
					if xsecsSinceLogoff>offseconds then
						-- zu lange offline
						bAddMember=false
					end
				end
			end
			if bAddMember==true then
				tim.addToGuild(xname,xplayerStatus,xsecsSinceLogoff,xhasCharacter,xcharacterName,xzoneName,xclassType,xalliance,xlevel,xveteranRank)
			end
		end
		-- Die Gildenauflistung sortieren
		local bswitched=true
		local firstElem=1
		local lastElem=tim.guildindex
		while bswitched==true do
			bswitched=false
			looper=firstElem
			while looper<lastElem do
				if ((tim.vars.queryAccount==true) and (tim.guild.maccount[looper]>tim.guild.maccount[looper+1])) or ((tim.vars.queryAccount==false) and (tim.guild.mchar[looper]>tim.guild.mchar[looper+1])) then
					local xaccount=tim.guild.maccount[looper]
					local xstatus=tim.guild.mstatus[looper]
					local xsecsoff=tim.guild.msecsoff[looper]
					local xchar=tim.guild.mchar[looper]
					local xzone=tim.guild.mzone[looper]
					local xclasstype=tim.guild.mclasstype[looper]
					local xalliance=tim.guild.malliance[looper]
					local xlevel=tim.guild.mlevel[looper]
					local xveteranRank=tim.guild.mveteranRank[looper]
					tim.guild.maccount[looper]=tim.guild.maccount[looper+1]
					tim.guild.mstatus[looper]=tim.guild.mstatus[looper+1]
					tim.guild.msecsoff[looper]=tim.guild.msecsoff[looper+1]
					tim.guild.mchar[looper]=tim.guild.mchar[looper+1]
					tim.guild.mzone[looper]=tim.guild.mzone[looper+1]
					tim.guild.mclasstype[looper]=tim.guild.mclasstype[looper+1]
					tim.guild.malliance[looper]=tim.guild.malliance[looper+1]
					tim.guild.mlevel[looper]=tim.guild.mlevel[looper+1]
					tim.guild.mveteranRank[looper]=tim.guild.mveteranRank[looper+1]
					tim.guild.maccount[looper+1]=xaccount
					tim.guild.mstatus[looper+1]=xstatus
					tim.guild.msecsoff[looper+1]=xsecsoff
					tim.guild.mchar[looper+1]=xchar
					tim.guild.mzone[looper+1]=xzone
					tim.guild.mclasstype[looper+1]=xclasstype
					tim.guild.malliance[looper+1]=xalliance
					tim.guild.mlevel[looper+1]=xlevel
					tim.guild.mveteranRank[looper+1]=xveteranRank
					bswitched=true
				end
				looper=looper+1
			end
			lastElem=lastElem-1
		end
	end
	tim.UpdateGuildList()
	tim.UpdateGuildButtons(1)
	tim.guildSetGuildWindow()
	tim.slider3:SetValue(1)
end


function tim.rotateGuild()
	local nextGuild=0
	local looper=0
	while ((nextGuild==0) and (looper<5)) do
		looper=looper+1
		local index=looper+tim.vars.actualGuild
		if index>5 then
			index=index-5
		end
		if string.sub(tim.guilds[index],1,1)~="*" then
			nextGuild=index
		end
	end
	return nextGuild
end


function tim.toggleAcountClick()
	if tim.vars.queryAccount==true then
		tim.vars.queryAccount=false
	else
		tim.vars.queryAccount=true
	end
	tim.guildReadGuild()
end


function tim.guildSetGuildWindow()
	if tim.vars.actualGuild~=0 then
		timGuildGilde:SetText(tim.guilds[tim.vars.actualGuild])
	else
		timGuildGilde:SetText(tim.locGuildNone)
	end
	timGuildqrySuche:SetText(tim.locGuildQuery[1])
	timGuildqryAuswahl:SetText(tim.locGuildQuery[2][tim.vars.queryStatus])
	timGuildqryZusatz:SetText(tim.locGuildQuery[3])
	timGuildqryGtlt:SetText(tim.locGuildQuery[4][tim.vars.queryGtlt])
	timGuildqryAnzahl:SetText(tim.vars.queryCounts)
	timGuildqryEinheit:SetText(tim.locGuildQuery[5][tim.vars.queryUnits])
	timGuildqryMode:SetText(tim.locGuildQuery[6][tim.vars.queryIgnore])
	timGuildFooterLMTAction:SetText(tim.locGuildFooterMTAction[tim.vars.queryLMT])
	timGuildFooterRMTAction:SetText(tim.locGuildFooterMTAction[tim.vars.queryRMT])
	local temp=tim.locGuildDisplayed
	temp=string.gsub(temp,"#",tim.guildindex,1)
	timGuildFooterDisplayed:SetText(temp)
end


function tim.guildNextGuild(bRotate)
	local nextguild=tim.vars.actualGuild
	if bRotate==true then
		nextGuild=tim.rotateGuild()
	end
	if nextGuild~=0 then
		tim.vars.actualGuild=nextGuild
		tim.guildReadGuild()
	else
		tim.sendMessage(tim.locGuildNone,true)
	end
end


function tim.CopyGovToClip()
	-- Anwender drueckt auf kopieren zum Clipboard
	if tim.PlayerReady==true then
		if tim.govactive~=0 then
			-- den kompletten GOV ins Clipboard holen
			tim.changeGOVrolle(tim.govactive,true)
			timWindowClipboard:Clear()
			timWindowClipboard:SetText(tim.vars.Clipboard)
			local cliplen=string.len(tim.vars.Clipboard)
			local temp=timWindowClipboard:GetText()
			local templen=string.len(temp)
			if cliplen==templen then
				tim.sendMessage(tim.locClipCopied)
			else
				-- GOV-Text war zu lang, muss (von vorne beginnend) gekuerzt werden
				tim.sendMessage(tim.locClipCopiedLong)
				temp=string.sub(tim.vars.Clipboard,cliplen-templen,cliplen)
				tim.vars.Clipboard=temp
				timWindowClipboard:SetText(temp)
			end
			timWindowClipboard:CopyAllTextToClipboard()
			timWindowClipboard:Clear()
		end
	end
end


function tim.AlerterClick()
	-- Anwender drueckt auf den Alerter
	if tim.PlayerReady==true then
		tim.ToggleWindowVisible()
	end
end


function tim.killGovClick()
	-- Anwender drueckt auf den Gruppe loeschen
	if tim.govactive>0 then
		tim.deleteGOV(tim.govactive)
	end
end


function tim.answerGovClick()
	-- Anwender drueckt auf antworten
	if tim.govactive>0 then
		tim.answerGOV(tim.govactive)
	end
end


function tim.RolleClick(button)
	-- Anwender klickt in das Nachrichtenfenster
	if button==2 then
		-- rechte Maustaste - Text in das Clipboard kopieren
		-- tim.CopyGovToClip()
	end
end


function tim.playerLink(char,account)
	return "|c"..tim.senderColor..ZO_LinkHandler_CreateLink(char, nil, CHARACTER_LINK_TYPE, account).."|r"
end

function tim.sendQueuedMail()
  if tim.mailQueueindex>0 then
    if (tim.UpdateThrottle("SendQueuedMail", tim.throttleCountMail) == true) then
      -- EINEN MailQueue-Eintrag senden (pro Aufruf dieser Funktion)
      local mailboxwasopen=tim.MailBoxOpen
      if tim.MailBoxOpen==false then
        RequestOpenMailbox()
      end
      tim.wait4mail=true
      tim.MailInQueue=tim.mailQueue.mTO[tim.mailQueueindex]
      tim.MailInQueueSUB=tim.mailQueue.mSUB[tim.mailQueueindex]
      SendMail(tim.mailQueue.mTO[tim.mailQueueindex], tim.mailQueue.mSUB[tim.mailQueueindex], tim.mailQueue.mTEXT[tim.mailQueueindex])
      if mailboxwasopen==false then
        CloseMailbox()
      end
      tim.mailQueueindex=tim.mailQueueindex-1
    end
  end
end

function tim.addtoMailQueue(mailTO,mailSUB,mailTEXT)
	tim.mailQueueindex=tim.mailQueueindex+1
	tim.mailQueue.mTO[tim.mailQueueindex]=mailTO
	tim.mailQueue.mSUB[tim.mailQueueindex]=mailSUB
	tim.mailQueue.mTEXT[tim.mailQueueindex]=mailTEXT
end


function tim.MailSendActionClick(button)
	local xZiel=timMailTarget:GetText()
	local xBetreff=timMailBetreff:GetText()
	local xNachricht=timMailNachricht:GetText()
	if ((string.len(xZiel)>0) and (string.len(xBetreff)>0) and (string.len(xBetreff)>0)) then
		tim.addtoMailQueue(xZiel,xBetreff,xNachricht)
		-- Eigennachricht simulieren, um die Mail zu dokumentieren
		-- Fenster schliessen
		tim.ToggleMailVisible()
	else
		tim.sendMessage(tim.locMailLeer,true)
	end
end


function tim.MailCancelActionClick(button)
	tim.ToggleMailVisible()
end


function tim.GuildMemberInfo(index)
	local temp=tim.locGuildMbrStatus
	local link=tim.playerLink(tim.guild.mchar[index],tim.guild.maccount[index]).."|c"..tim.chatcolor
	temp=string.gsub(temp,"#",link,1)
	local klasse=tim.locClassType[tim.guild.mclasstype[index]]
	if klasse==nil then klasse="" end
	temp=string.gsub(temp,"#",klasse,1)
	if tim.guild.mveteranRank[index]==0 then
		temp=string.gsub(temp,"#",tim.guild.mlevel[index],1)
	else
		temp=string.gsub(temp,"#","V"..tim.guild.mveteranRank[index],1)
	end
	local allianz=tim.locAlliance[tim.guild.malliance[index]]
	if allianz==nil then allianz="" end
	temp=string.gsub(temp,"#",allianz,1)
	link=tim.playerLink(tim.guild.maccount[index],tim.guild.maccount[index]).."|c"..tim.chatcolor
	temp=string.gsub(temp,"#",link,1)
	temp=string.gsub(temp,"#",tim.guild.mzone[index],1)
	if tim.guild.mstatus[index]<4 then
		temp=temp.."online"
	else
		temp=temp.."offline "..tim.locGuildMbrOff
		local seconds=tim.guild.msecsoff[index]
		local days=math.floor(seconds / 86400)
		seconds=seconds-days*86400
		local hours=math.floor(seconds / 3600)
		seconds=seconds-hours*3600
		local minutes=math.floor(seconds/60)
		seconds=seconds-minutes*60
		temp=string.gsub(temp,"#",days,1)
		temp=string.gsub(temp,"#",hours,1)
		temp=string.gsub(temp,"#",minutes,1)
		temp=string.gsub(temp,"#",seconds,1)
	end
	temp=temp.."|r"
	return temp
end


function tim.processGuildRequest(button,index)
	-- Gildenfunktion ausfuehren
	local actionToProcess=tim.vars.queryLMT
	if button==2 then
		actionToProcess=tim.vars.queryRMT
	end
	if actionToProcess==1 then
		-- Gildenfunktion "Status ausgeben"
		tim.sendMessage(tim.GuildMemberInfo(index),false)
	else
		if actionToProcess==2 then
			-- Gildenfunktion "zu Spieler reisen"
			JumpToGuildMember(tim.guild.maccount[index])
		else
			if actionToProcess==3 then
				-- Gildenfunktion "Mail senden"
				if ((string.len(timGuildBetreff:GetText())>0) and (string.len(timGuildNachricht:GetText())>0)) then
					tim.addtoMailQueue(tim.guild.maccount[index],timGuildBetreff:GetText(),timGuildNachricht:GetText())
				else
					tim.sendMessage(tim.locGuildMailBoxLeer,true)
				end
			else
				if actionToProcess==4 then
					-- Gildenfunktion "Betreff fluestern"
					tim.sendChatMessage("/w "..tim.guild.maccount[index].." "..timGuildBetreff:GetText())
				else
					if actionToProcess==5 then
						-- Gildenfunktion "Nachricht fluestern"
						tim.sendChatMessage("/w "..tim.guild.maccount[index].." "..timGuildNachricht:GetText())
					else
						if actionToProcess==6 then
							-- Gildenfunktion "aus Gilde entfernen"
							GuildRemove(GetGuildId(tim.vars.actualGuild), tim.guild.maccount[index])
						else
							if actionToProcess==7 then
								-- Gildenfunktion "Mail an ALLE angezeigten"
								local mBetreff=timGuildBetreff:GetText()
								local mText=timGuildNachricht:GetText()
								if ((string.len(mBetreff)>0) and (string.len(mText)>0)) then
									local looper=0
									while looper<tim.guildindex do
										looper=looper+1
										tim.addtoMailQueue(tim.guild.maccount[looper],mBetreff,mText)
									end
								else
									tim.sendMessage(tim.locGuildMailBoxLeer,true)
								end
							else
								if actionToProcess==8 then
									-- Gildenfunktion "Betreff>Gildenchat"
									tim.sendChatMessage("/g"..tostring(tim.vars.actualGuild).." "..timGuildBetreff:GetText())
								else
									if actionToProcess==9 then
										-- Gildenfunktion "Nachricht>Gildenchat"
										tim.sendChatMessage("/g"..tostring(tim.vars.actualGuild).." "..timGuildNachricht:GetText())
									else
										if actionToProcess==10 then
											-- Gildenfunktion "Betreff>Gebiet"
											tim.sendChatMessage("/z "..timGuildBetreff:GetText())
										else
											if actionToProcess==11 then
												-- Gildenfunktion "Nachricht>Gebiet"
												tim.sendChatMessage("/z "..timGuildNachricht:GetText())
											else
												if actionToProcess==12 then
													-- Gildenfunktion "Betreff>DE"
													tim.sendChatMessage("/zde "..timGuildBetreff:GetText())
												else
													if actionToProcess==13 then
														-- Gildenfunktion "Nachricht>DE"
														tim.sendChatMessage("/zde "..timGuildNachricht:GetText())
													else
														if actionToProcess==14 then
															-- Gildenfunktion "Betreff>EN"
															tim.sendChatMessage("/zen "..timGuildBetreff:GetText())
														else
															if actionToProcess==15 then
																-- Gildenfunktion "Nachricht>EN"
																tim.sendChatMessage("/zen "..timGuildNachricht:GetText())
															else
																if actionToProcess==16 then
																	-- Gildenfunktion "Betreff>FR"
																	tim.sendChatMessage("/zfr "..timGuildBetreff:GetText())
																else
																	if actionToProcess==17 then
																		-- Gildenfunktion "Nachricht>FR"
																		tim.sendChatMessage("/zfr "..timGuildNachricht:GetText())
																	else
																		if actionToProcess==18 then
																			-- Gildenfunktion "Betreff>sagen"
																			tim.sendChatMessage("/s "..timGuildBetreff:GetText())
																		else
																			if actionToProcess==19 then
																				-- Gildenfunktion "Nachricht>sagen"
																				tim.sendChatMessage("/s "..timGuildNachricht:GetText())
																			else
																				if actionToProcess==20 then
																					-- Gildenfunktion "Betreff>Gruppe"
																					tim.sendChatMessage("/p "..timGuildBetreff:GetText())
																				else
																					if actionToProcess==21 then
																						-- Gildenfunktion "Nachricht>Gruppe"
																						tim.sendChatMessage("/p "..timGuildNachricht:GetText())
																					else
																						if actionToProcess==22 then
																							-- Gildenfunktion "anfluestern"
																							tim.sendChatMessage("/w "..tim.guild.maccount[index].." ")
																						else
																							tim.sendMessage("not implemented",true)
																						end
																					end
																				end
																			end
																		end
																	end
																end
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end


function tim.OnGovClick(govButtonName,button)
	-- Anwender drueckt auf einen GOV-Knopf
	local ButtonNum=string.sub(govButtonName,10,11)+0
	tim.changeGOVrolle(ButtonNum+tim.govFirstButton-1,false)
	if button==2 then
		-- rechte Maustaste - Antworten ausloesen
		tim.answerGovClick()
	end
end


function tim.OnGuildClick(button,guildButtonName)
	-- Anwender drueckt auf einen Gilden-Knopf
	local ButtonNum=string.sub(guildButtonName,12,13)+0
	tim.guildactive=ButtonNum+tim.guildFirstButton-1
	tim.UpdateGuildButtons(tim.slider3:GetValue())
	tim.processGuildRequest(button,ButtonNum+tim.guildFirstButton-1)
end


function tim.OnScanClick(button,scanButtonName)
	-- Anwender drueckt auf einen Scan-Knopf
	local ButtonNum=string.sub(scanButtonName,11,12)+0
	if tim.vars.scanTargets[ButtonNum]~=nil then
		local xKlammer=string.find(tim.vars.scanTargets[ButtonNum],"[",1,true)
		local xPlayer=string.sub(tim.vars.scanTargets[ButtonNum],1,xKlammer-1)
		if button==2 then
			-- ueber Katakomben ansprechen
			timCatacombTarget:SetText(xPlayer)
			if tim.CatacombVisible==false then
				tim.ToggleCatacombVisible()
			end
			tim.sendChatMessage("/w "..xPlayer.." ")
		else
			-- ueber Mail ansprechen
			timMailTarget:SetText(xPlayer)
			if tim.MailVisible==false then
				tim.ToggleMailVisible()
			end
		end
	end
end


function tim.magicGovClick()
	-- Anwender drueckt auf Magic Fenster
	tim.ToggleWindowVisible()
	tim.ToggleMagicVisible()
end


function tim.guildClick()
	-- Anwender drueckt auf Gildenfenster anzeigen
	tim.ToggleWindowVisible()
	tim.ToggleGuildVisible()
end


function tim.catacombClick()
	-- Anwender drueckt auf Katakomben anzeigen
	tim.ToggleCatacombVisible()
end


function tim.guildToggle()
	-- Anwender drueckt auf Gildenfenster anzeigen (F11)
	if tim.PlayerReady==true then
		tim.ToggleGuildVisible()
	end
end


function tim.catacombToggle()
	-- Anwender drueckt auf Katakombenfenster anzeigen (F8)
	if tim.PlayerReady==true then
		tim.ToggleCatacombVisible()
	end
end


function tim.scanToggle()
	-- Anwender drueckt auf Zielscanner anzeigen (F8)
	if tim.PlayerReady==true then
		tim.ToggleScanVisible()
	end
end


function tim.MagicCloseClick()
	-- Anwender drueckt auf Magic Fenster schliessen
	tim.ToggleMagicVisible()
	-- Die Werte zurueckschreiben
	tim.storeMagicValues(true)
	-- den GOV neu aufbauen
	tim.rebuildGOVDisplay()
	tim.ToggleWindowVisible()
end


function tim.GuildCloseClick()
	-- Anwender drueckt auf Gildenfenster schliessen
	tim.ToggleGuildVisible()
end


function tim.CatacombCloseClick()
	-- Anwender drueckt auf Katakombenfenster schliessen
	tim.ToggleCatacombVisible()
	-- Die Werte zurueckschreiben
	tim.storeMagicValues(true)
end


function tim.ScanCloseClick()
	-- Anwender drueckt auf Scanfenster schliessen
	tim.ToggleScanVisible()
end


function tim.MailCloseClick()
	-- Anwender drueckt auf Scanfenster schliessen
	tim.ToggleMailVisible()
end


function tim.NextGuildClick()
	-- Anwender drueckt auf naechste Gilde
	tim.guildNextGuild(true)
end


function tim.RefreshGuildClick()
	-- Anwender drueckt auf Gildenrefresh
	tim.guildNextGuild(false)
end


function tim.queryAuswahlDo(value)
	tim.vars.queryStatus=tim.vars.queryStatus+value
	if tim.vars.queryStatus>3 then
		tim.vars.queryStatus=1
	end
	if tim.vars.queryStatus<1 then
		tim.vars.queryStatus=3
	end
	tim.guildReadGuild()
end


function tim.queryAuswahlClick(button)
	-- Anwender aendert Query-Auswahl
	if button==1 then
		tim.queryAuswahlDo(1)
	else
		tim.queryAuswahlDo(-1)
	end
end


function tim.queryAnzahlDo(value)
	tim.vars.queryCounts=tim.vars.queryCounts+value
	if tim.vars.queryCounts>31 then
		tim.vars.queryCounts=1
	end
	if tim.vars.queryCounts<1 then
		tim.vars.queryCounts=31
	end
	tim.guildReadGuild()
end


function tim.queryAnzahlClick(button)
	-- Anwender aendert Query-Auswahl
	if button==1 then
		tim.queryAnzahlDo(1)
	else
		tim.queryAnzahlDo(-1)
	end
end


function tim.queryGtltClick(button)
	-- Anwender aendert Query-groesser/kleiner
	if tim.vars.queryGtlt==1 then
		tim.vars.queryGtlt=2
	else
		tim.vars.queryGtlt=1
	end
	tim.guildReadGuild()
end


function tim.queryEinheitDo(value)
	tim.vars.queryUnits=tim.vars.queryUnits+value
	if tim.vars.queryUnits>4 then
		tim.vars.queryUnits=1
	end
	if tim.vars.queryUnits<1 then
		tim.vars.queryUnits=4
	end
	tim.guildReadGuild()
end


function tim.queryEinheitClick(button)
	-- Anwender aendert Query-Auswahl
	if button==1 then
		tim.queryEinheitDo(1)
	else
		tim.queryEinheitDo(-1)
	end
end


function tim.queryModeDo(value)
	tim.vars.queryIgnore=tim.vars.queryIgnore+value
	if tim.vars.queryIgnore>2 then
		tim.vars.queryIgnore=1
	end
	if tim.vars.queryIgnore<1 then
		tim.vars.queryIgnore=2
	end
	tim.guildReadGuild()
end


function tim.queryModeClick(button)
	-- Anwender aendert Query-Auswahl
	if button==1 then
		tim.queryModeDo(1)
	else
		tim.queryModeDo(-1)
	end
end


function tim.queryLMTDo(value)
	tim.vars.queryLMT=tim.vars.queryLMT+value
	if tim.vars.queryLMT>tim.guildMouseActions then
		tim.vars.queryLMT=1
	end
	if tim.vars.queryLMT<1 then
		tim.vars.queryLMT=tim.guildMouseActions
	end
	tim.guildSetGuildWindow()
end


function tim.queryLMTClick(button)
	-- Anwender aendert Query-Auswahl
	if button==1 then
		tim.queryLMTDo(1)
	else
		tim.queryLMTDo(-1)
	end
end


function tim.queryRMTDo(value)
	tim.vars.queryRMT=tim.vars.queryRMT+value
	if tim.vars.queryRMT>tim.guildMouseActions then
		tim.vars.queryRMT=1
	end
	if tim.vars.queryRMT<1 then
		tim.vars.queryRMT=tim.guildMouseActions
	end
	tim.guildSetGuildWindow()
end


function tim.queryRMTClick(button)
	-- Anwender aendert Query-Auswahl
	if button==1 then
		tim.queryRMTDo(1)
	else
		tim.queryRMTDo(-1)
	end
end


function tim.rebuildGOVDisplay()
	local GovPosition=tim.getActualGovName()
	tim.ReCreateGOV()
	tim.changeGOVrolle(tim.GetGOV(GovPosition),false)
end


function tim.UpdateGovButtons(nFirst)
	if nFirst>0 then
		tim.govFirstButton=nFirst
		local Looper=1
		while Looper<=tim.govButtons do
			local index=nFirst+Looper-1
			local button=GetControl("govButton"..tim.to2string(Looper))
			if index<=tim.govindex then
				button:SetHidden(false)
				button:SetText(tim.gov.vname[index])
				if tim.gov.vunread[index]>0 then
					button:SetColor(1,1,0.7,1)
				else
					if index==tim.govactive then
						button:SetColor(0.9,0.9,0.9,1)
					else
						button:SetColor(0.9,0.9,0.6,0.6)
					end
				end
				button=GetControl("govButton"..tim.to2string(Looper).."BG")
				if index==tim.govactive then
					button:SetAlpha(0.2)
				else
					button:SetAlpha(0)
				end
			else
				button:SetHidden(true)
				button:SetText("darfniegesehenwerden")
			end
			Looper=Looper+1
		end
		if tim.govactive~=0 then
			timWindowActiveGov:SetText(tim.gov.vname[tim.govactive])
		else
			timWindowActiveGov:SetText("---")
		end
	end
end


function tim.UpdateGuildButtons(nFirst)
	if nFirst>0 then
		tim.guildFirstButton=nFirst
		local Looper=1
		while Looper<=tim.guildButtons do
			local index=nFirst+Looper-1
			local button=GetControl("guildButton"..tim.to2string(Looper))
			if index<=tim.guildindex then
				button:SetHidden(false)
				if tim.vars.queryAccount==true then
					button:SetText(tim.guild.maccount[index])
				else
					button:SetText(tim.guild.mchar[index])
				end
				if index==tim.guildactive then
					button:SetColor(0.9,0.9,0.9,1)
				else
					button:SetColor(0.9,0.9,0.6,0.6)
				end
				button=GetControl("guildButton"..tim.to2string(Looper).."BG")
				button:SetHidden(false)
				if index==tim.guildactive then
					button:SetAlpha(0.2)
				else
					button:SetAlpha(0)
				end
				button=GetControl("guildStatusButton"..tim.to2string(Looper))
				button:SetHidden(false)
				if tim.guild.mstatus[index]==1 then
					button:SetTexture("/esoui/art/contacts/social_status_online.dds")
				else
					if tim.guild.mstatus[index]==2 then
						button:SetTexture("/esoui/art/contacts/social_status_afk.dds")
					else
						if tim.guild.mstatus[index]==3 then
							button:SetTexture("/esoui/art/contacts/social_status_dnd.dds")
						else
							if tim.guild.mstatus[index]==4 then
								button:SetTexture("/esoui/art/contacts/social_status_offline.dds")
							end
						end
					end
				end
			else
				button:SetHidden(true)
				button:SetText("darfniegesehenwerden")
				button=GetControl("guildStatusButton"..tim.to2string(Looper))
				button:SetHidden(true)
				button=GetControl("guildButton"..tim.to2string(Looper).."BG")
				button:SetHidden(true)
			end
			Looper=Looper+1
		end
	end
end


function tim.OnMagicSliderMove(nvalue)
	if tim.MagicVisible==true then
		tim.storeMagicValues(true)
		tim.LoMindex=nvalue
		tim.storeMagicValues(false)
	end
end


function tim.OnSliderMove(nvalue)
	tim.UpdateGovButtons(nvalue)
end


function tim.OnSlider2Move(nvalue)
	timWindowRolle:SetScrollPosition(timWindowRolle:GetNumHistoryLines()-nvalue)
end


function tim.OnSlider3Move(nvalue)
	tim.UpdateGuildButtons(nvalue)
end


function tim.UpdateRolleSlider()
	if timWindowRolle:GetNumHistoryLines()<=timWindowRolle:GetNumVisibleLines() then
		tim.slider2:SetHidden(true)
	else
		tim.slider2:SetMinMax(0,timWindowRolle:GetNumHistoryLines())
		tim.slider2:SetHidden(false)
	end
end


function tim.UpdateWindowGovList()
	if tim.govindex<=tim.govButtons then
		tim.slider:SetHidden(true)
	else
		tim.slider:SetMinMax(0,tim.govindex-tim.govButtons+1)
		tim.slider:SetHidden(false)
	end
end


function tim.UpdateGuildList()
	if tim.guildindex<=tim.guildButtons then
		tim.slider3:SetHidden(true)
	else
		tim.slider3:SetMinMax(0,tim.guildindex-tim.guildButtons+1)
		tim.slider3:SetHidden(false)
	end
end


function tim.msgtimestamp(diff)
	-- gibt aktuelles (oder um diff vermindertes) Datum/Zeit als timStamp zurueck (verkuerztes Jahr)
	local months={31,28,31,30,31,30,31,31,30,31,30,31}
	local ddate=GetDate()
	if diff>0 then
		local dyear=math.floor(ddate/10000)
		ddate=ddate-dyear*10000
		local dmonth=math.floor(ddate/100)
		local dday=ddate-dmonth*100
		if diff<dday then
			dday=dday-diff
		else
			local dmrest=diff-dday
			-- vom Vormonat eins abziehen
			if dmonth>1 then
				dmonth=dmonth-1
			else
				-- vom Vorjahr eins abziehen
				dmonth=12
				dyear=dyear-1
			end
			dday=months[dmonth]
			dday=dday-dmrest
		end
		ddate=dyear*10000+dmonth*100+dday
	end
	ddate=ddate-20000000
	dtime=GetSecondsSinceMidnight()
	local dhour=math.floor(dtime/3600)
	dtime=dtime-dhour*3600
	local dminute=math.floor(dtime/60)
	dtime=dtime-dminute*60
	local stimestamp=tostring(ddate)..tim.to2string(dhour)..tim.to2string(dminute)..tim.to2string(dtime)
	return stimestamp
end


function tim.isMyOwnMessage(mtype,mfrom)
	local bmyown=false
	-- Nachsehen, ob die beschriebene Nachricht von mir ist
	if tim.isChannel(mtype)==tim.queuew then
		if mtype==4 then
			bmyown=true
		end
	else
		if mfrom==GetUnitName("player") or mfrom==GetRawUnitName("player") or mfrom==tim.vars.DisplayName then
			bmyown=true
		end
	end
	return bmyown
end


function tim.checkAutoOpen(mtype, mfrom)
	if tim.vars.openOnAlarm==true then
		if tim.WindowVisible==false then
			if tim.isAlertMessage(mtype)==true then
				if tim.isMyOwnMessage(mtype,mfrom)==false then
					if IsUnitInCombat("player")==false then
						tim.KeepWindowClosed=false
						tim.SetWindowVisible(true)
					end
				end
			end
		end
	end
end


function tim.checkAutoSwitch(mtype,switchGOV)
	if tim.vars.switchToAlarm==true then
		if tim.isAlertMessage(mtype)==true then
			tim.changeGOVrolle(switchGOV,false)
		end
	end
end


function tim.SwitchGOV(GOVname)
	local switched=false
	local GOVindex=tim.GetGOV(GOVname)
	if GOVindex~=0 then
		switched=true
		tim.changeGOVrolle(GOVindex,false)
	end
	return switched
end


function tim.storeMagicValues(backtovars)
	local Looper=0
	local Looper2=1
	while Looper2<=tim.magicQueues do
		Looper=0
		while Looper<=tim.LoMwords do
			tim.mycontrol=GetControl("timMagicEdit"..tostring(Looper2)..tostring(Looper))
			if Looper==0 then
				if backtovars==true then
					tim.vars.LoM[Looper2+tim.LoMindex-1].LoMname=tim.adjustMessage(tim.trim(tim.mycontrol:GetText()))
				else
					tim.mycontrol:SetText(tim.trim(tim.vars.LoM[Looper2+tim.LoMindex-1].LoMname))
					tim.mycontrol:SetCursorPosition(0)
				end
			else
				if backtovars==true then
					tim.vars.LoM[Looper2+tim.LoMindex-1].LoMword[Looper]=tim.adjustMessage(tim.trim(tim.mycontrol:GetText()))
				else
					tim.mycontrol:SetText(tim.trim(tim.vars.LoM[Looper2+tim.LoMindex-1].LoMword[Looper]))
					tim.mycontrol:SetCursorPosition(0)
				end
			end
			Looper=Looper+1
		end
		Looper2=Looper2+1
	end
end


function tim.adjustMessage(messg)
	local temp=messg
	temp=string.gsub(temp,"%[%[","{{")
	temp=string.gsub(temp,"%]%]","}}")
	if string.sub(temp,1,1)=="[" then
		temp=" "..temp
	end
	if string.sub(temp,string.len(temp),string.len(temp))=="]" then
		temp=temp.." "
	end
	if string.sub(temp,string.len(temp),string.len(temp))=="\\" then
		temp=temp.." "
	end
	return temp
end


function tim.StoreMessage(messageType, messageFrom, messageText)
	if tim.isMessageAllowed(messageType)==true then
		local nchannel=tim.isChannel(messageType)
		local timdatetime=tim.msgtimestamp(0)
		tim.vars.msgindex[nchannel]=tim.vars.msgindex[nchannel]+1
		tim.vars.msg[nchannel].mtime[tim.vars.msgindex[nchannel]]=timdatetime
		tim.vars.msg[nchannel].mtype[tim.vars.msgindex[nchannel]]=messageType
		tim.vars.msg[nchannel].mfrom[tim.vars.msgindex[nchannel]]=messageFrom
		tim.vars.msg[nchannel].mtext[tim.vars.msgindex[nchannel]]=tim.adjustMessage(messageText)
		tim.vars.msg[nchannel].munread[tim.vars.msgindex[nchannel]]=true
		if tim.isChannel(messageType)==tim.queueg then
			tim.vars.msg[nchannel].mfrom[tim.vars.msgindex[nchannel]]=messageFrom..tim.messageFromSeparator..tim.getGuildCharName(messageFrom,messageType)
		end
		if messageType==4 then
			-- die eigenen Nachrichten als gelesen markieren
			tim.vars.msg[nchannel].munread[tim.vars.msgindex[nchannel]]=false
		end
		if tim.isSupressedMessage(messageType)==true then
			-- die zu ignorierenden Nachrichten auf gelesen setzen, damit nicht alarmiert wird
			tim.vars.msg[nchannel].munread[tim.vars.msgindex[nchannel]]=false
		end
		-- nachsehen, ob das Fenster automatisch geoeffnet werden kann/soll
		tim.checkAutoOpen(messageType, messageFrom)
		-- in das Fenster einlaufen lassen, wenn diese Gruppe aktiv ist (wird damit auf gelesen gesetzt)
		if isGOVonline(messageType,messageFrom,nchannel,tim.vars.msgindex[nchannel])==true then
			tim.addTimMessage(nchannel,tim.vars.msgindex[nchannel],false)
		end
		local arrivedGOV=tim.UpdateGOVentry(messageType, tim.vars.msgindex[nchannel])
		-- Aktuelle Markierung setzen
		tim.UpdateGovButtons(tim.govFirstButton)
		-- nachsehen, ob sutomatisch zu diesem GOV gewechselt werden soll
		tim.checkAutoSwitch(messageType,arrivedGOV)
		-- Die Tooltip-Statistiken in Ordnung bringen
		tim.TooltipStatistics()
		if tim.isMyOwnMessage(messageType,messageFrom)==true then
			-- Eigene Nachrichten in die talkHistory aufnehmen
			tim.talkHistoryAdd(tim.gov.vname[arrivedGOV])
			if tim.vars.switchToMyMsg==true then
				-- zu diesem GOV wechseln, wenn meine Nachrichten angezeigt werden sollen
				tim.SwitchGOV(tim.gov.vname[arrivedGOV])
			end
		end
	end
end


function tim.talkHistoryResize(NewSize)
	local Looper=0
	while Looper<tim.talkHistoryAbsMax do
		Looper=Looper+1
		if ((Looper<=NewSize) and (tim.vars.talkHistory[Looper]==nil)) then
			tim.vars.talkHistory[Looper]=""
		end
		if ((Looper>NewSize) and (tim.vars.talkHistory[Looper]~=nil)) then
			tim.vars.talkHistory[Looper]=nil
		end
	end
	tim.talkHistoryMax=NewSize
	tim.vars.talkHistoryMax=NewSize
end


function tim.isInTalkHistory(GOVname)
	local nFound=0
	local Looper=0
	while ((Looper<tim.talkHistoryMax) and (nFound==0)) do
		Looper=Looper+1
		if tim.vars.talkHistory[Looper]==GOVname then
			nFound=Looper
		end
	end
	return nFound
end


function tim.talkHistoryRemove(GOVname)
	local temp=tim.isInTalkHistory(GOVname)
	if temp~=0 then
		if temp<tim.talkHistoryMax then
			for Looper=temp,tim.talkHistoryMax-1,1 do
				tim.vars.talkHistory[Looper]=tim.vars.talkHistory[Looper+1]
			end
		end
		tim.vars.talkHistory[tim.talkHistoryMax]=""
	end
end


function tim.addToTalkHistory(GOVname)
	for Looper=tim.talkHistoryMax-1,1,-1 do
		tim.vars.talkHistory[Looper+1]=tim.vars.talkHistory[Looper]
	end
	tim.vars.talkHistory[1]=GOVname
end


function tim.shiftTalkHistory(GOVname)
	local currentPos=tim.isInTalkHistory(GOVname)
	if currentPos~=1 then
		-- neueste Diskussion - an die erste Stelle verschieben
		for Looper=currentPos-1,1,-1 do
			tim.vars.talkHistory[Looper+1]=tim.vars.talkHistory[Looper]
		end
		tim.vars.talkHistory[1]=GOVname
		tim.talkHistoryIndex=1
	end
end


function tim.talkHistoryAdd(GOVname)
	if tim.isInTalkHistory(GOVname)==0 then
		tim.addToTalkHistory(GOVname)
	else
		tim.shiftTalkHistory(GOVname)
	end
end


function tim.talkHistoryRotate(UpDown)
	if ((tim.PlayerReady==true) and (tim.WindowVisible==true)) then
		local Rotations=0
		local hasChanged=false
		-- durch die talkHistory rotieren, bis ein Eintrag gefunden wird... oder wir einmal komplett durch sind
		while ((hasChanged==false) and (Rotations<tim.talkHistoryMax)) do
			Rotations=Rotations+1
			if UpDown==true then
				tim.talkHistoryIndex=tim.talkHistoryIndex+1
				if tim.talkHistoryIndex>tim.talkHistoryMax then
					tim.talkHistoryIndex=1
				end
			else
				tim.talkHistoryIndex=tim.talkHistoryIndex-1
				if tim.talkHistoryIndex<1 then
					tim.talkHistoryIndex=tim.talkHistoryMax
				end
			end
			if tim.vars.talkHistory[tim.talkHistoryIndex]~="" then
				-- naechsten Eintrag gefunden
				hasChanged=true
			end
		end
		if Rotations~=tim.talkHistoryMax then
			-- wir haben einen Eintrag gefunden - zu diesem springen
			if tim.SwitchGOV(tim.vars.talkHistory[tim.talkHistoryIndex])==false then
				-- den Eintrag loeschen, wenn es ihn nicht mehr gibt
				local temp=string.gsub(tim.locTalkHistoryMissed,"#",tim.vars.talkHistory[tim.talkHistoryIndex],1)
				tim.sendMessage(temp,true)
				tim.talkHistoryRemove(tim.vars.talkHistory[tim.talkHistoryIndex])
			end
		else
			-- wir haben keinen Eintrag gefunden (und stehen wieder dort, wo wir waren)
			if tim.vars.talkHistory[tim.talkHistoryIndex]~="" then
				local temp=string.gsub(tim.locTalkHistorySingle,"#",tim.vars.talkHistory[tim.talkHistoryIndex],1)
				tim.sendMessage(temp,false)
				-- trotzdem anzeigen, falls das Spiel grade erst betreten wurde und GOV auf 1 steht
				tim.SwitchGOV(tim.vars.talkHistory[tim.talkHistoryIndex])
			else
				tim.sendMessage(tim.locTalkHistoryEmpty,false)
			end
		end
	end
end


function tim.AddNewGOVentry(govName, govType)
	tim.govindex=tim.govindex+1
	tim.gov.vname[tim.govindex]=govName
	tim.gov.vtype[tim.govindex]=govType
	tim.gov.vunread[tim.govindex]=0
	-- GOV-Prioritaet ermitteln und eintragen
	local govpri="9"
	if tim.isChannel(govType)==tim.queuew then
		govpri="1"
	else
		if tim.isChannel(govType)==tim.queuep then
			govpri="2"
		else
			if tim.isChannel(govType)==tim.queueg then
				govpri="3"
			else
				if (govType>=tim.firstMagic) and (govType<=(tim.firstMagic+tim.LoMrecords-1)) then
					govpri="4"
				else
					if tim.isChannel(govType)==tim.queues then
						govpri="5"
					else
						if tim.isChannel(govType)==tim.queuez then
							govpri="6"
						end
					end
				end
			end
		end
	end
	tim.gov.vprio[tim.govindex]=govpri..govName
	return tim.govindex
end


function tim.getActualGovName()
	local gname=""
	if tim.govactive>0 then
		gname=tim.gov.vname[tim.govactive]
	end
	return gname
end


function tim.GetGOV(searchGOV)
	local Looper=0
	local nfound=0
	while (Looper<tim.govindex) and (nfound==0) do
		Looper=Looper+1
		if (tim.gov.vname[Looper]==searchGOV) then
			nfound=Looper
		end
	end
	return nfound
end


function tim.isSupressedMessage(mtype)
	local bSupressed=false
	if ((mtype==tim.msgTypeG1) and (tim.vars.ShowG1==false)) then
		bSupressed=true
	end
	if ((mtype==tim.msgTypeG2) and (tim.vars.ShowG2==false)) then
		bSupressed=true
	end
	if ((mtype==tim.msgTypeG3) and (tim.vars.ShowG3==false)) then
		bSupressed=true
	end
	if ((mtype==tim.msgTypeG4) and (tim.vars.ShowG4==false)) then
		bSupressed=true
	end
	if ((mtype==tim.msgTypeG5) and (tim.vars.ShowG5==false)) then
		bSupressed=true
	end
	if ((mtype==tim.msgTypeO1) and (tim.vars.ShowG1==false)) then
		bSupressed=true
	end
	if ((mtype==tim.msgTypeO2) and (tim.vars.ShowG2==false)) then
		bSupressed=true
	end
	if ((mtype==tim.msgTypeO3) and (tim.vars.ShowG3==false)) then
		bSupressed=true
	end
	if ((mtype==tim.msgTypeO4) and (tim.vars.ShowG4==false)) then
		bSupressed=true
	end
	if ((mtype==tim.msgTypeO5) and (tim.vars.ShowG5==false)) then
		bSupressed=true
	end
	if ((mtype==tim.msgTypeZ1) and (tim.vars.ShowZ1==false)) then
		bSupressed=true
	end
	if ((mtype==tim.msgTypeZ2) and (tim.vars.ShowZEN==false)) then
		bSupressed=true
	end
	if ((mtype==tim.msgTypeZ3) and (tim.vars.ShowZFR==false)) then
		bSupressed=true
	end
	if ((mtype==tim.msgTypeZ4) and (tim.vars.ShowZDE==false)) then
		bSupressed=true
	end
	return bSupressed
end


function tim.UpdateGOVentry(msgType,msgIndex)
	local govID="*"
	local GOVindex=0
	local nchannel=tim.isChannel(msgType)
	-- nachsehen, ob es eine magische Nachricht ist
	local looper=0
	for looper=tim.firstMagic,tim.firstMagic+tim.LoMrecords-1,1 do
		if tim.isLoMmessage(looper,nchannel,msgIndex)==true then
			-- wenn ja, dann ggf. einen neuen GOV erstellen
			govID="*"..tim.trim(tim.vars.LoM[looper-tim.firstMagic+1].LoMname)
			GOVindex=tim.GetGOV(govID)
			if GOVindex==0 then
				GOVindex=tim.AddNewGOVentry(govID,looper)
				tim.UpdateWindowGovList()
			end
			if tim.vars.msg[nchannel].munread[msgIndex]==true then
				tim.gov.vunread[GOVindex]=tim.gov.vunread[GOVindex]+1
			end
		end
	end
	if tim.isSupressedMessage(msgType)==false then
		govID="*"
		nchannel=tim.isChannel(msgType)
		if nchannel==tim.queuew then
			-- whisper: Hier ist die ID der Absender
			govID=tim.vars.msg[nchannel].mfrom[msgIndex]
		end
		if nchannel==tim.queueg then
			-- Gilde: Hier ist die ID der Gildenname
			if msgType>tim.msgTypeG5 then
				-- Gildenchat Offiziere
				govID="{"..tim.vars.guilds[msgType-tim.msgTypeO1+1].."}"
			else
				-- GildenChat normal
				govID=tim.vars.guilds[msgType-tim.msgTypeG1+1]
			end
		end
		if nchannel==tim.queuez then
			-- Zone: Hier ist die ID der Zonenname
			govID=tim.locZone[msgType-30]
		end
		if nchannel==tim.queuep then
			-- Zone: Hier ist die ID ein "P"
			govID="Gruppe"
			govID=tim.locParty
		end
		if nchannel==tim.queues then
			-- Zone: Hier ist die ID ein "S"
			govID="Sagen"
			govID=tim.locSay
		end
		GOVindex=tim.GetGOV(govID)
		if GOVindex==0 then
			GOVindex=tim.AddNewGOVentry(govID,msgType)
			tim.UpdateWindowGovList()
		end
		if tim.vars.msg[nchannel].munread[msgIndex]==true then
			tim.gov.vunread[GOVindex]=tim.gov.vunread[GOVindex]+1
		end
		return GOVindex
	end
end


function tim.ReCreateGOV()
	local newgovactive=0
	local govtype=0
	local govname=""
	if tim.govactive~=0 then
		govtype=tim.gov.vtype[tim.govactive]
		govname=tim.gov.vname[tim.govactive]
	end
	tim.gov={vname={}, vtype={}, vunread={}, vprio={},}
	tim.govindex=0
	local looper=0
	local Looper1=0
	while Looper1<5 do
		Looper1=Looper1+1
		local Looper2=0
		while Looper2<tim.vars.msgindex[Looper1] do
			Looper2=Looper2+1
			-- hier werden neue GOVs bei Bedarf auch zugefuegt
			tim.UpdateGOVentry(tim.vars.msg[Looper1].mtype[Looper2],Looper2)
		end
	end	
	-- die GOV sortieren
	local bswitched=true
	local firstElem=1
	local lastElem=tim.govindex
	while bswitched==true do
		bswitched=false
		looper=firstElem
		while looper<lastElem do
			if tim.gov.vprio[looper]>tim.gov.vprio[looper+1] then
				local xname=tim.gov.vname[looper]
				local xtype=tim.gov.vtype[looper]
				local xunread=tim.gov.vunread[looper]
				local xprio=tim.gov.vprio[looper]
				tim.gov.vname[looper]=tim.gov.vname[looper+1]
				tim.gov.vtype[looper]=tim.gov.vtype[looper+1]
				tim.gov.vunread[looper]=tim.gov.vunread[looper+1]
				tim.gov.vprio[looper]=tim.gov.vprio[looper+1]
				tim.gov.vname[looper+1]=xname
				tim.gov.vtype[looper+1]=xtype
				tim.gov.vunread[looper+1]=xunread
				tim.gov.vprio[looper+1]=xprio
				bswitched=true
			end
			looper=looper+1
		end
		lastElem=lastElem-1
	end
	-- den aktiven Eintrag wieder suchen
	Looper1=0
	while Looper1<tim.govindex do
		Looper1=Looper1+1
		if tim.isChannel(tim.gov.vtype[Looper1])==tim.isChannel(govtype) then
			if tim.isChannel(govtype)==tim.queuew then
				-- bei whisper muss der Name zusaetzlich uebereinstimmen
				if tim.gov.vname[Looper1]==govname then
					newgovactive=Looper1
				end
			else
				-- Nicht-whisper Kanaele muessen im Typ uebereinstimmen
				if tim.gov.vtype[Looper1]==govtype then
					newgovactive=Looper1
				end
			end
		end
	end
	tim.govactive=newgovactive
	tim.UpdateGovButtons(1)
end


function tim.IncomingMessage(eventcode, messageType, messageFrom, messageText)
	if (tim.PlayerReady==true) then
		-- npc ignorieren
		if (messageType~=8) and (messageType~=7) then
			if tim.isChannel(messageType)~=0 then
				local numberGOV=tim.govindex
				tim.StoreMessage(messageType, tim.detil(messageFrom), messageText)
				-- GOV neu aufbauen, wenn sich die Anzahl Eintraege veraendert hat
				if tim.govindex~=numberGOV then
					tim.ReCreateGOV()
				end
			else
				tim.sendDebugMessage("unbekannter Nachrichtentyp " .. tostring(messageType) .. ": " .. messageText)
			end
		end
	end
end


function isGOVonline(mtype,mfrom,queue,index)
	local breturn=false
	if tim.govactive~=0 then
		if tim.govactive~=nil then
			if (tim.gov.vtype[tim.govactive]>=tim.firstMagic) and (tim.gov.vtype[tim.govactive]<=(tim.firstMagic+tim.LoMrecords-1)) then
				-- ist ein magischer Kanal
				if tim.isLoMmessage(tim.gov.vtype[tim.govactive],queue,index)==true then
					breturn=true
				end
			else
				-- ist kein magischer Kanal
				if tim.isChannel(tim.gov.vtype[tim.govactive])==tim.queuew then
					-- Bei einem Fluesterkanal schauen, ob der Name passt
					if tim.gov.vname[tim.govactive]==mfrom then
						breturn=true
					end
				else
					if tim.isChannel(tim.gov.vtype[tim.govactive])==tim.queues then
						-- Bei einem Sprachkanal schauen, ob der Typ "Sprache" ist
						if tim.isChannel(tim.gov.vtype[tim.govactive])==tim.isChannel(mtype) then
							breturn=true
						end
					else
						-- bei anderen Kanaelen schauen, ob der Typ passt
						if tim.gov.vtype[tim.govactive]==mtype then
							breturn=true
						end
					end
				end
			end
		end
	end
	return breturn
end


function tim.Statistics()
	local nMessages=0
	local looper=0
	local sStatmsg=tim.locStatistics
	while looper<5 do
		looper=looper+1
		nMessages=nMessages+tim.vars.msgindex[looper]
	end
	sStatmsg=string.gsub(sStatmsg,"#",nMessages,1)
	looper=0
	while looper<5 do
		looper=looper+1
		sStatmsg=string.gsub(sStatmsg,"#",tim.vars.msgindex[looper],1)
	end
	return sStatmsg
end


function tim.TooltipStatistics()
	if tim.vars.showTimButton==true then
		timWindowBubble.tooltipText=tim.Statistics()
		timAlerterBubble.tooltipText=tim.Statistics()
	else
		timWindowBubble.tooltipText=""
		timAlerterBubble.tooltipText=""
	end
end

function tim.SlashResize(svar)
	local temp=string.upper(svar)
	local nslot=tonumber(string.sub(temp,1,1))
	local bSave=false
	if string.find(temp,"SAVE",1,true)~=nil then
		bSave=true
	end
	if bSave==true then
		if nslot>5 then
			-- die aktuelle Groesse wegschreiben
			tim.vars.dSizes[nslot+1][1]=tim.vars.WdX
			tim.vars.dSizes[nslot+1][2]=tim.vars.WdY
			local sStatmsg=tim.locWindowSizeSet
			sStatmsg=string.gsub(sStatmsg,"#",tim.vars.WdX,1)
			sStatmsg=string.gsub(sStatmsg,"#",tim.vars.WdY,1)
			sStatmsg=string.gsub(sStatmsg,"#",nslot,1)
			tim.sendMessage(sStatmsg,true)
		else
			local sStatmsg=tim.locWindowSizeLck
			sStatmsg=string.gsub(sStatmsg,"#",nslot,1)
			tim.sendMessage(sStatmsg,true)
		end
	else
		-- auf eine gespeicherte Groesse setzen
		tim.vars.WdX=tim.vars.dSizes[nslot+1][1]
		tim.vars.WdY=tim.vars.dSizes[nslot+1][2]
		tim.WindowResize(tim.vars.WdX,tim.vars.WdY)
		local sStatmsg=tim.locWindowSizeChg
		sStatmsg=string.gsub(sStatmsg,"#",tim.vars.WdX,1)
		sStatmsg=string.gsub(sStatmsg,"#",tim.vars.WdY,1)
		tim.sendMessage(sStatmsg,true)
	end
end


function tim.encodeMessage(svar)
	local temp=""
	local looper=0
	while looper<string.len(svar) do
		looper=looper+1
		tempc=string.sub(svar,looper,looper)
		local pos=string.find(tim.code1,tempc,1,true)
		if pos then
			tempc=string.sub(tim.code2,pos,pos)
		end
		temp=temp..tempc
	end
	return temp
end


function tim.decodeMessage(svar)
	local temp=""
	local looper=0
	while looper<string.len(svar) do
		looper=looper+1
		tempc=string.sub(svar,looper,looper)
		local pos=string.find(tim.code2,tempc,1,true)
		if pos then
			tempc=string.sub(tim.code1,pos,pos)
		end
		temp=temp..tempc
	end
	return temp
end


function tim.sendCodedMessage(svar,codeMessage)
	local temp=svar
	-- verschluesseln, wenn angefordert
	if codeMessage==true then
		temp=tim.codeTrigger..tim.encodeMessage(svar)
	end
	-- an das Chatsystem weitergeben
	tim.sendChatMessage(temp)
end


function tim.toggleCryptBox()
	tim.vars.CryptBoxShown=not tim.vars.CryptBoxShown
	if tim.vars.CryptBoxShown==true then
		tim.sendMessage(tim.locCryptWarn,true)
	end
	timWindowCrypt:SetHidden(not tim.vars.CryptBoxShown)
	timWindowCryptLbl:SetHidden(not tim.vars.CryptBoxShown)
	tim.updateResize(0,0)
end


function tim.logout(mode)
	if mode==true then
		Quit()
	else
		Logout()
	end
end


function tim.goOffline(mode)
	SelectPlayerStatus(4)
	tim.logout(mode)
end


function tim.timHelp()
	tim.sendMessage(tim.locTimHelp,false)
end


function tim.SlashCMD(svar)
	if svar=="" then
		-- ohne Parameter diese Hilfe anzeigen und TIM umschalten
		tim.timHelp()
		tim.ToggleWindowVisible()
	else
		-- Groessenaenderung des Fensters
		if ((string.sub(svar,1,1)>="0") and (string.sub(svar,1,1)<="9")) then
			tim.SlashResize(svar)
		else
			-- Cryptbox umschalten
			if string.sub(svar,1,4)=="timi" then
				tim.toggleCryptBox()
			else
				-- Spielerscanner umschalten
				if string.sub(svar,1,4)=="scan" then
					tim.ToggleScanVisible()
				else
					-- Mailfunktion umschalten
					if string.sub(svar,1,4)=="mail" then
						tim.ToggleMailVisible()
					else
						-- katakomben umschalten
						if string.sub(svar,1,4)=="cata" then
							tim.catacombToggle()
						else
							-- Gildenfenster umschalten
							if string.sub(svar,1,4)=="guil" then
								tim.ToggleGuildVisible()
							else
								-- offline gehen und beenden
								if string.sub(svar,1,4)=="quit" then
									tim.goOffline(true)
								else
									-- offline gehen und abmelden
									if string.sub(svar,1,4)=="logo" then
										tim.goOffline(false)
									else
										-- Unbekannter Befehl
										local sStatmsg=tim.locCommandUk
										sStatmsg=string.gsub(sStatmsg,"#",svar,1)
										tim.sendMessage(sStatmsg,true)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end


function tim.UpdateThrottle(key, frequency)
	if key == nil then return end
	if tim.throttle[key] == nil then tim.throttle[key] = {} end
	tim.throttle[key].frequency = frequency or 10
	tim.throttle[key].now = GetFrameTimeMilliseconds()
	if tim.throttle[key].last == nil then tim.throttle[key].last = tim.throttle[key].now end
	tim.throttle[key].diff = tim.throttle[key].now - tim.throttle[key].last
	tim.throttle[key].eval = tim.throttle[key].diff >= tim.throttle[key].frequency
	if tim.throttle[key].eval then tim.throttle[key].last = tim.throttle[key].now end
	return tim.throttle[key].eval
end


function tim.processAlarm()
	if tim.AlarmCount~=0 then
		tim.AlarmCount=tim.AlarmCount+1
		if tim.AlarmCount>tim.AlarmMax then
			tim.AlarmCount=1
			tim.SwitchAlarm()
		end
	end
end


function tim.SwitchAlarm()
	if tim.AlarmCycle==0 then
		tim.AlarmCycle=1
		timAlerterBubble:SetTexture("/esoui/art/chatwindow/chat_notification_up.dds")
	else
		tim.AlarmCycle=0
		timAlerterBubble:SetTexture("/esoui/art/chatwindow/chat_notification_down.dds")
	end
end


function tim.Setalarm(mode)
	if mode==0 then
		-- Alarm ausschalten (wenn eingeschaltet)
		if tim.AlarmCount~=0 then
			tim.AlarmCycle=0
			tim.AlarmCount=0
			tim.SwitchAlarm()
		end
	else
		-- Alarm einschalten (wenn ausgeschaltet)
		if tim.AlarmCount==0 then
			tim.AlarmCycle=0
			tim.AlarmCount=1
			tim.SwitchAlarm()
		end
	end
end


function tim.checkForAlarm()
	local looper=0
	local ring=false
	-- pruefen, ob ungelesene Nachrichten mit Alarmierung vorhanden sind
	while looper<tim.govindex do
		looper=looper+1
		if tim.gov.vunread[looper]>0 then
			-- ungelesene Nachricht stuende an
			if tim.isAlertMessage(tim.gov.vtype[looper]) then
				ring=true
			end
		end
	end
	-- Den Alarm entsprechend setzen oder loeschen
	if ring==true then
		tim.Setalarm(1)
	else
		tim.Setalarm(0)
	end
end


function tim.SetWindowVisible(visible)
	if visible==false then
			if timWindow:IsHidden()==false then
				timWindow:SetHidden(true)
				tim.WindowVisible=false
				tim.playTimSound(1)
			end
	else
		-- Nur anzeigen, wenn nicht im Kampf und das Fenster geoeffnet war
		if IsUnitInCombat("player")==false and tim.KeepWindowClosed==false then
			if timWindow:IsHidden()==true then
				timWindow:SetHidden(false)
				tim.WindowVisible=true
				tim.playTimSound(1)
			end
		end
	end
end


function tim.SetMagicVisible(visible)
	if visible==false then
			if timMagic:IsHidden()==false then
				timMagic:SetHidden(true)
				tim.MagicVisible=false
				tim.playTimSound(1)
			end
	else
		-- Nur anzeigen, wenn nicht im Kampf und das Fenster geoeffnet war
		if IsUnitInCombat("player")==false and tim.KeepMagicClosed==false then
			if timMagic:IsHidden()==true then
				tim.storeMagicValues(false)
				timMagic:SetHidden(false)
				tim.MagicVisible=true
				tim.playTimSound(1)
			end
		end
	end
end


function tim.SetCatacombVisible(visible)
	if visible==false then
			if timCatacomb:IsHidden()==false then
				timCatacomb:SetHidden(true)
				tim.CatacombVisible=false
				tim.playTimSound(1)
			end
	else
		-- Nur anzeigen, wenn nicht im Kampf und das Fenster geoeffnet war
		if IsUnitInCombat("player")==false and tim.KeepCatacombClosed==false then
			if timCatacomb:IsHidden()==true then
				timCatacomb:SetHidden(false)
				tim.CatacombVisible=true
				tim.playTimSound(1)
			end
		end
	end
end


function tim.SetScanVisible(visible)
	if visible==false then
			if timScan:IsHidden()==false then
				timScan:SetHidden(true)
				tim.ScanVisible=false
				tim.scanTarget=false
				tim.playTimSound(1)
			end
	else
		-- Nur anzeigen, wenn nicht im Kampf und das Fenster geoeffnet war
		if IsUnitInCombat("player")==false and tim.KeepScanClosed==false then
			if timScan:IsHidden()==true then
				timScan:SetHidden(false)
				tim.ScanVisible=true
				tim.scanTarget=true
				tim.playTimSound(1)
			end
		end
	end
end


function tim.SetMailVisible(visible)
	if visible==false then
			if timMail:IsHidden()==false then
				timMail:SetHidden(true)
				tim.MailVisible=false
				tim.playTimSound(1)
			end
	else
		-- Nur anzeigen, wenn nicht im Kampf und das Fenster geoeffnet war
		if IsUnitInCombat("player")==false and tim.KeepMailClosed==false then
			if timMail:IsHidden()==true then
				timMail:SetHidden(false)
				tim.MailVisible=true
				tim.playTimSound(1)
			end
		end
	end
end


function tim.SetGuildVisible(visible)
	if visible==false then
			if timGuild:IsHidden()==false then
				timGuild:SetHidden(true)
				tim.GuildVisible=false
				tim.playTimSound(1)
			end
	else
		-- Nur anzeigen, wenn nicht im Kampf und das Fenster geoeffnet war
		if IsUnitInCombat("player")==false and tim.KeepGuildClosed==false then
			if timGuild:IsHidden()==true then
				timGuild:SetHidden(false)
				tim.GuildVisible=true
				tim.playTimSound(1)
			end
		end
	end
end


function tim.playTimSound(soundNo)
	if tim.PlayerReady==true then
		if soundNo==1 then
			if tim.vars.playOpenSound==true then
				PlayItemSound(ITEM_SOUND_CATEGORY_DEFAULT, 4)
			end
		end
	end
end


function tim.PromoteNews()
	if tim.vars.CatacombIsPromoted==false then
		-- nichts mehr unternehmen, die Katakomben werden nicht mehr promoted
		if tim.CatacombVisible==false then
			tim.vars.CatacombIsPromoted=true
		end
	end
	if tim.vars.TIMishIsPromoted==false then
		-- einmalig TIMish promoten
		tim.sendMessage(tim.locCryptPromotion,true)
		tim.vars.TIMishIsPromoted=true
	end
end


function tim.ToggleWindowVisible()
	if tim.WindowVisible==false then
		-- Anzeigen, wenn nicht im Kampf
		if IsUnitInCombat("player")==false then
			tim.KeepWindowClosed=false
			tim.SetWindowVisible(true)
			if tim.MagicVisible==true then
				tim.ToggleMagicVisible()
			end
			tim.PromoteNews()
		end
	else
		-- Verbergen und geschlossen halten
		tim.KeepWindowClosed=true
		tim.SetWindowVisible(false)
	end
end


function tim.ToggleMagicVisible()
	if tim.MagicVisible==false then
		-- Anzeigen, wenn nicht im Kampf
		if IsUnitInCombat("player")==false then
			tim.KeepMagicClosed=false
			tim.SetMagicVisible(true)
		end
	else
		-- Verbergen und geschlossen halten
		tim.KeepMagicClosed=true
		tim.SetMagicVisible(false)
	end
end


function tim.ToggleGuildVisible()
	if tim.GuildVisible==false then
		-- Anzeigen, wenn nicht im Kampf
		if IsUnitInCombat("player")==false then
			tim.KeepGuildClosed=false
			tim.SetGuildVisible(true)
			-- Die Gilde lesen
			tim.guildReadGuild()
		end
	else
		-- Verbergen und geschlossen halten
		tim.KeepGuildClosed=true
		tim.SetGuildVisible(false)
	end
end


function tim.ToggleCatacombVisible()
	if tim.CatacombVisible==false then
		-- Anzeigen, wenn nicht im Kampf
		if IsUnitInCombat("player")==false then
			tim.KeepCatacombClosed=false
			tim.SetCatacombVisible(true)
		end
	else
		-- Verbergen und geschlossen halten
		tim.KeepCatacombClosed=true
		tim.SetCatacombVisible(false)
	end
end


function tim.ToggleScanVisible()
	if tim.ScanVisible==false then
		-- Anzeigen, wenn nicht im Kampf
		if IsUnitInCombat("player")==false then
			tim.KeepScanClosed=false
			tim.SetScanVisible(true)
		end
	else
		-- Verbergen und geschlossen halten
		tim.KeepScanClosed=true
		tim.SetScanVisible(false)
	end
end


function tim.ToggleMailVisible()
	if tim.MailVisible==false then
		-- Anzeigen, wenn nicht im Kampf
		if IsUnitInCombat("player")==false then
			tim.KeepMailClosed=false
			tim.SetMailVisible(true)
		end
	else
		-- Verbergen und geschlossen halten
		tim.KeepMailClosed=true
		tim.SetMailVisible(false)
	end
end


function tim.GarbageCleanQueue(queue,garbagedays,garbagecount)
	local cleaned=0
	local mhd=tim.msgtimestamp(garbagedays)
	local Looper=1
	while Looper<=tim.vars.msgindex[queue] do
		if tim.vars.msg[queue].mtime[Looper]<mhd then
			tim.deletemsg(queue,Looper)
			cleaned=cleaned+1
		else
			-- ist okay, zum naechsten
			Looper=Looper+1
		end
	end
	if tim.vars.msgindex[queue]>garbagecount then
		local versatz=tim.vars.msgindex[queue]-garbagecount
		Looper=1
		while Looper<=garbagecount do
			--- loeschen durch herunterziehen
			tim.vars.msg[queue].mtime[Looper]=tim.vars.msg[queue].mtime[Looper+versatz]
			tim.vars.msg[queue].mtype[Looper]=tim.vars.msg[queue].mtype[Looper+versatz]
			tim.vars.msg[queue].mfrom[Looper]=tim.vars.msg[queue].mfrom[Looper+versatz]
			tim.vars.msg[queue].mtext[Looper]=tim.vars.msg[queue].mtext[Looper+versatz]
			tim.vars.msg[queue].munread[Looper]=tim.vars.msg[queue].munread[Looper+versatz]
			Looper=Looper+1
		end
		-- den gesamten ueberhang loeschen
		while Looper<=tim.vars.msgindex[queue] do
			tim.vars.msg[queue].mtime[Looper]=nil
			tim.vars.msg[queue].mtype[Looper]=nil
			tim.vars.msg[queue].mfrom[Looper]=nil
			tim.vars.msg[queue].mtext[Looper]=nil
			tim.vars.msg[queue].munread[Looper]=nil
			Looper=Looper+1
		end
		-- und fertig
		tim.vars.msgindex[queue]=garbagecount
	end
	return cleaned
end


function tim.GarbageCollection()
	local cleaned=0
	local GC_Start=GetGameTimeMilliseconds()
	local GovPosition=tim.getActualGovName()
	cleaned=cleaned+tim.GarbageCleanQueue(tim.queuew,tim.vars.queuewGarbageDays,tim.vars.queuewGarbageCount)
	cleaned=cleaned+tim.GarbageCleanQueue(tim.queuep,tim.vars.queuepGarbageDays,tim.vars.queuepGarbageCount)
	cleaned=cleaned+tim.GarbageCleanQueue(tim.queueg,tim.vars.queuegGarbageDays,tim.vars.queuegGarbageCount)
	cleaned=cleaned+tim.GarbageCleanQueue(tim.queuez,tim.vars.queuezGarbageDays,tim.vars.queuezGarbageCount)
	cleaned=cleaned+tim.GarbageCleanQueue(tim.queues,tim.vars.queuesGarbageDays,tim.vars.queuesGarbageCount)
	tim.vars.lastGCruntime=GetGameTimeMilliseconds()-GC_Start
	tim.vars.lastGCcleaned=cleaned
	tim.rebuildGOVDisplay()
	tim.TooltipStatistics()
end


function tim.GarbageDrop()
	-- Daten loeschen, wenn sie nicht mehr benoetigt werden
	if string.sub(tim.vars.AlertOptionW,1,1)=="0" then
		tim.vars.msg[tim.queuew]={mtime={}, mtype={}, mfrom={}, mtext={}, munread={}}
		tim.vars.msgindex[tim.queuew]=0
	end
	if string.sub(tim.vars.AlertOptionP,1,1)=="0" then
		tim.vars.msg[tim.queuep]={mtime={}, mtype={}, mfrom={}, mtext={}, munread={}}
		tim.vars.msgindex[tim.queuep]=0
	end
	if ((string.sub(tim.vars.AlertOptionG1,1,1)=="0") and (string.sub(tim.vars.AlertOptionG2,1,1)=="0") and (string.sub(tim.vars.AlertOptionG3,1,1)=="0") and (string.sub(tim.vars.AlertOptionG4,1,1)=="0") and (string.sub(tim.vars.AlertOptionG5,1,1)=="0")) then
		tim.vars.msg[tim.queueg]={mtime={}, mtype={}, mfrom={}, mtext={}, munread={}}
		tim.vars.msgindex[tim.queueg]=0
	end
	if string.sub(tim.vars.AlertOptionS,1,1)=="0" then
		tim.vars.msg[tim.queues]={mtime={}, mtype={}, mfrom={}, mtext={}, munread={}}
		tim.vars.msgindex[tim.queues]=0
	end
	if string.sub(tim.vars.AlertOptionZ,1,1)=="0" then
		tim.vars.msg[tim.queuez]={mtime={}, mtype={}, mfrom={}, mtext={}, munread={}}
		tim.vars.msgindex[tim.queuez]=0
	end
	tim.TooltipStatistics()
end


function tim.gcnLookup(accountName,lMode,updateChar)
	local runMode=lMode
	local charName=""
	local bfound=false
	local looper=0
	local nowStamp=GetTimeStamp()
	while ((looper<tim.gcnindex) and (bfound==false)) do
		looper=looper+1
		if accountName==tim.gcn.gaccount[looper] then
--			tim.sendDebugMessage("accountname: "..accountName.." Alter:"..GetDiffBetweenTimeStamps(nowStamp, tim.gcn.glease[looper]))
			bfound=true
			if runMode==2 then
				-- den Lease dieses Accounts auffrischen
				charName=tim.gcn.gname[looper]
				tim.gcn.gname[looper]=updateChar
				tim.gcn.glease[looper]=nowStamp
				tim.sendDebugMessage("refresh Account "..accountName.." als "..updateChar.." um "..tim.gcn.glease[looper])
			end
			if runMode==0 then
				-- den Cache zuueckgeben, wenn nicht abgelaufen
				if GetDiffBetweenTimeStamps(nowStamp, tim.gcn.glease[looper])<tim.gcnMaxLease then
					charName=tim.gcn.gname[looper]
				else
					-- ist abgelaufen - im nächsten Schritt entfernen lassen
					runMode=1
				end
			end
			if runMode==1 then
				-- diesen Account wegen logout entfernen
				charName=tim.gcn.gname[looper]
				tim.sendDebugMessage("Entferne Account "..accountName)
				for looper2=looper,tim.gcnindex-1 do
					tim.gcn.gname[looper2]=tim.gcn.gname[looper2+1]
					tim.gcn.gaccount[looper2]=tim.gcn.gaccount[looper2+1]
					tim.gcn.glease[looper2]=tim.gcn.glease[looper2+1]
				end
				tim.gcnindex=tim.gcnindex-1
			end
		end
	end
	return charName
end


function tim.getGuildCharName(accountName,index)
	local guildIndex=index-12+1
	-- den Charnamen aus dem Cache oder dem Gildenregister holen 
	local charName=tim.gcnLookup(accountName,0)
	if string.len(charName)<1 then
		-- Noch nicht in der gcn Tabelle vorhanden
		local guildId = GetGuildId(guildIndex)
		local looper=0
		local bfound=false
		while ((looper<GetNumGuildMembers(guildId)) and (bfound==false)) do
			looper=looper+1
			local xname, xnote, xrankIndex, xplayerStatus, xsecsSinceLogoff=GetGuildMemberInfo(guildId, looper)
			local xhasCharacter, xcharacterName, xzoneName, xclassType, xalliance, xlevel, xveteranRank=GetGuildMemberCharacterInfo(guildId, looper)
			charName=tim.detil(xcharacterName)
			if (xname == accountName) then
				bfound=true
				tim.gcnindex=tim.gcnindex+1
				tim.gcn.gaccount[tim.gcnindex]=accountName
				tim.gcn.gname[tim.gcnindex]=charName
				tim.gcn.glease[tim.gcnindex]=GetTimeStamp()
				tim.sendDebugMessage("Account "..accountName.." als "..charName.." angelegt")
			else
				-- Diesen Char auffrischen, wenn es ihn gibt
				tim.gcnLookup(xname,2,charName)
			end
		end
		if bfound==false then
			-- nicht gefunden, der Accountname wird zurueckgegeben
			charName=accountName
		end
	end
	return charName
end


function tim.hasToClose()
	local forceClose=false
	local keybindIsHidden=ZO_KeybindStripControl:IsHidden()
	local isInCombat=IsUnitInCombat("player")
	local inGameMenu=GAME_MENU_SCENE:IsShowing()
	local closeForCombat=isInCombat and tim.vars.CloseInCombat
	if ((keybindIsHidden==false) or (closeForCombat==true) or (tim.isChattering==true) or (inGameMenu==true)) then
		forceClose=true
	end
	return forceClose
end


-- Callback fuer den Alerter
function tim.AlerterUpdate()
	-- Nur ausfuehren, wenn TIM fertig geladen ist
	if (tim.loaded == true) then
		if (tim.UpdateThrottle("AlerterUpd", tim.throttleCount) == true) then
			local keybindIsHidden=ZO_KeybindStripControl:IsHidden()
			-- Die Fenster ausblenden, wenn die Oberflaeche wegfaded
			if tim.hasToClose()==true then
				timAlerter:SetAlpha(0)
				tim.SetWindowVisible(false)
				tim.SetMagicVisible(false)
				tim.SetGuildVisible(false)
				tim.SetCatacombVisible(false)
				tim.SetScanVisible(false)
				tim.SetMailVisible(false)
			else
				tim.SetMailVisible(true)
				tim.SetScanVisible(true)
				tim.SetMagicVisible(true)
				tim.SetWindowVisible(true)
				tim.SetGuildVisible(true)
				tim.SetCatacombVisible(true)
				timAlerter:SetAlpha(1)
			end
			-- Nachsehen, ob alarmiert werden muss
			tim.checkForAlarm()
			tim.processAlarm()
			-- nachsehen, ob sich an den Gilden was geaendert hat
			tim.updateGuilds()
			-- Mail senden, wenn etwas in der Queue ist
			 tim.sendQueuedMail()
		end
		-- Die Garbage-Collection aufrufen
		if (tim.UpdateThrottle("GarbageCollection", tim.GarbageCount)==true) then
			tim.GarbageCollection()
		end
		-- Gildenaktivitaet feststellen
		if (tim.UpdateThrottle("WatchGuild", tim.GuildWatchCount)==true) then
			tim.processGuildWatch()
		end
		-- Zwangstrennung verhindern
		if (tim.UpdateThrottle("LogoutPrevention", tim.LogoutPreventionCount)==true) then
			tim.processLogoutPrevention()
		end
	end
end


function tim.processLogoutPrevention()
	if (tim.PlayerReady==true) then
		tim.sendDebugMessage("LogoutPrevention")
		-- Versuchen, die Zwangstrennung zu verhindern
		meDps,meHeal,meTank=GetPlayerRoles()
		UpdatePlayerRole(LFG_ROLE_HEAL, not meHeal)
		UpdatePlayerRole(LFG_ROLE_HEAL, meHeal)
	end
end


function tim.AlerterMoveStop()
	-- Nur ausfuehren, wenn Das AddON schon geladen ist
	if (tim.loaded == true) then
		-- der Anwender hat den Alerter verschoben - das merken wir uns
		tim.vars.AofX = timAlerter:GetLeft()
		tim.vars.AofY = timAlerter:GetTop()
		timAlerter:ClearAnchors()
		timAlerter:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tim.vars.AofX, tim.vars.AofY)
	end
end


function tim.AlerterBubbleMoveStop()
	-- Nur ausfuehren, wenn Das AddON schon geladen ist
	if (tim.loaded == true) then
		-- der Anwender hat den Alerter (die Bubble) verschoben - das merken wir uns
		tim.vars.AofX = timAlerterBubble:GetLeft()
		tim.vars.AofY = timAlerterBubble:GetTop()
		timAlerter:ClearAnchors()
		timAlerter:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tim.vars.AofX, tim.vars.AofY)
	end
end


function tim.CatacombMoveStop()
	-- Nur ausfuehren, wenn Das AddON schon geladen ist
	if (tim.loaded == true) then
		-- der Anwender hat das Fenster verschoben - das merken wir uns
		tim.vars.CofX = timCatacomb:GetLeft()
		tim.vars.CofY = timCatacomb:GetTop()
		timCatacomb:ClearAnchors()
		timCatacomb:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tim.vars.CofX, tim.vars.CofY) 
	end
end


function tim.ScanMoveStop()
	-- Nur ausfuehren, wenn Das AddON schon geladen ist
	if (tim.loaded == true) then
		-- der Anwender hat das Fenster verschoben - das merken wir uns
		tim.vars.SofX = timScan:GetLeft()
		tim.vars.SofY = timScan:GetTop()
		timScan:ClearAnchors()
		timScan:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tim.vars.SofX, tim.vars.SofY) 
	end
end


function tim.MailMoveStop()
	-- Nur ausfuehren, wenn Das AddON schon geladen ist
	if (tim.loaded == true) then
		-- der Anwender hat das Fenster verschoben - das merken wir uns
		tim.vars.EofX = timMail:GetLeft()
		tim.vars.EofY = timMail:GetTop()
		timMail:ClearAnchors()
		timMail:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tim.vars.EofX, tim.vars.EofY) 
	end
end


function tim.WindowMoveStop()
	-- Nur ausfuehren, wenn Das AddON schon geladen ist
	if (tim.loaded == true) then
		-- der Anwender hat das Fenster verschoben - das merken wir uns (und passen das Magie-Fenster mit an)
		tim.vars.WofX = timWindow:GetLeft()
		tim.vars.WofY = timWindow:GetTop()
		timWindow:ClearAnchors()
		timWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tim.vars.WofX, tim.vars.WofY) 
	end
end


function tim.MagicMoveStop()
	-- der Anwender hat das Magie-Fenster verschoben - aber das laesst uns kalt
end


function tim.GuildMoveStop()
	-- Nur ausfuehren, wenn Das AddON schon geladen ist
	if (tim.loaded == true) then
		-- der Anwender hat das Fenster verschoben - das merken wir uns
		tim.vars.GofX = timGuild:GetLeft()
		tim.vars.GofY = timGuild:GetTop()
		timGuild:ClearAnchors()
		timGuild:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tim.vars.GofX, tim.vars.GofY)
	end
end


function tim.UpdateLockStatus(newValue)
	tim.vars.lockWindowPosition = newValue
	timAlerter:SetMovable(not tim.vars.lockWindowPosition)
	timWindow:SetMovable(not tim.vars.lockWindowPosition)
end


function tim.getGuilds()
	local Looper=0
	while Looper<5 do
		Looper=Looper+1
		local guildID=GetGuildId(Looper)
		if guildID~=0 then
			tim.guilds[Looper]=GetGuildName(guildID)
		else
			tim.guilds[Looper]="*"..tostring(Looper)
		end
	end
end


function tim.searchGN(tofind,stored)
	local thisGN=0
	if string.sub(tofind,1,1)~="*" then
		local looper=0
		while looper<5 do
			looper=looper+1
			if stored==true then
				if tofind==tim.vars.guilds[looper] then
					thisGN=looper
				end
			else
				if tofind==tim.guilds[looper] then
					thisGN=looper
				end
			end
		end
	end
	return thisGN
end


function tim.retypeGuild(von,nach,gilde)
	local looper=0
	if von==0 then
		-- die hochgeshifteten Type zurueckstellen und zum Loeschen markierte nachrichten loeschen
		while looper<tim.vars.msgindex[tim.queueg] do
			looper=looper+1
			if tim.vars.msg[tim.queueg].mtype[looper]>=200 then
				if tim.vars.msg[tim.queueg].mtype[looper]==200 then
					-- Diese Nachricht loeschen
					tim.deletemsg(tim.queueg,looper)
					-- Die heruntergezogene Nachricht prozessieren
					looper=looper-1
				else
					-- den neuen Gildentype eintragen
					tim.vars.msg[tim.queueg].mtype[looper]=tim.vars.msg[tim.queueg].mtype[looper]-200
				end
			end
		end
	else
		-- den Nachrichtentyp hochshiften
		while looper<tim.vars.msgindex[tim.queueg] do
			looper=looper+1
			if tim.vars.msg[tim.queueg].mtype[looper]==von then
				tim.vars.msg[tim.queueg].mtype[looper]=nach
			end
		end
	end
end


function tim.isNewWatchMember(xName,xRichtung)
	local bisNew=false
	local looper=0
	if xRichtung==false then
		while ((looper<tim.watchGuildMemberCount) and (bisNew==false)) do
			looper=looper+1
			if tim.watchGuildMembers[looper]==xName then
				bisNew=true
			end
		end
	else
		while ((looper<tim.watchactualGuildMemberCount) and (bisNew==false)) do
			looper=looper+1
			if tim.watchactualGuildMembers[looper]==xName then
				bisNew=true
			end
		end
	end
	return bisNew
end


function tim.processGuildWatch()
	if tim.PlayerReady==true then
		if tim.vars.watchGuild>0 then
			local guildID=GetGuildId(tim.vars.watchGuild)
			if guildID~=0 then
				local xGuildName=GetGuildName(guildID)
				tim.watchactualGuildMemberCount=0
				for looper=1,GetNumGuildMembers(guildID),1 do
					local xname, xnote, xrankIndex, xplayerStatus, xsecsSinceLogoff=GetGuildMemberInfo(guildID, looper)
					if xplayerStatus<4 then
						tim.watchactualGuildMemberCount=tim.watchactualGuildMemberCount+1
						tim.watchactualGuildMembers[tim.watchactualGuildMemberCount]=xname
					end
				end
				for looper=1,tim.watchactualGuildMemberCount,1 do
					if tim.isNewWatchMember(tim.watchactualGuildMembers[looper],false)==false then
						local xcharacterName=tim.getGuildCharName(tim.watchactualGuildMembers[looper],tim.vars.watchGuild+11)
						local temp=string.gsub(tim.locGuildWatchOnline,"#",xcharacterName,1)
						temp=xGuildName..": "..tim.watchactualGuildMembers[looper]..temp
						if tim.vars.watchGuildOnMsgs==true then
							tim.sendMessage(temp,false)
						end
					end
				end
				for looper=1,tim.watchGuildMemberCount,1 do
					if tim.isNewWatchMember(tim.watchGuildMembers[looper],true)==false then
						-- Den Account aus der Tabelle entfernen, weil nach einem Logout der Account mit einem anderen Character einloggen könnte/wird
						xcharacterName=tim.gcnLookup(tim.watchGuildMembers[looper],1)
						local temp=""
						if xcharacterName=="" then
							temp=string.gsub(tim.locGuildWatchOffline,"#",tim.watchGuildMembers[looper],1)
						else
							temp=tim.watchGuildMembers[looper]..string.gsub(tim.locGuildWatchOffline,"#"," ("..xcharacterName..") ",1)
						end
						temp=xGuildName..": "..temp
						if tim.vars.watchGuildOffMsgs==true then
							tim.sendMessage(temp,false)
						end
					end
				end
				tim.watchGuildMemberCount=tim.watchactualGuildMemberCount
				for looper=1,tim.watchactualGuildMemberCount,1 do
					tim.watchGuildMembers[looper]=tim.watchactualGuildMembers[looper]
				end
			end
		end
	end
end


function tim.readWatchguild()
	tim.watchGuildMemberCount=0
	tim.watchactualGuildMemberCount=0
	if tim.vars.watchGuild>0 then
		local guildID=GetGuildId(tim.vars.watchGuild)
		if guildID~=0 then
			local xGuildName=GetGuildName(guildID)
			for looper=1,GetNumGuildMembers(guildID),1 do
				local xname, xnote, xrankIndex, xplayerStatus, xsecsSinceLogoff=GetGuildMemberInfo(guildID, looper)
				if xplayerStatus<4 then
					tim.watchGuildMemberCount=tim.watchGuildMemberCount+1
					tim.watchactualGuildMemberCount=tim.watchactualGuildMemberCount+1
					tim.watchGuildMembers[tim.watchGuildMemberCount]=xname
					tim.watchactualGuildMembers[tim.watchactualGuildMemberCount]=xname
				end
			end
			tim.sendMessage(xGuildName..": "..tim.watchGuildMemberCount..tim.locGuildWatchReport,false)
		end
	end
end


function tim.updateGuilds()
	tim.getGuilds()
	local bAnyChanged=false
	local looper=0
	local oldGN=0
	local newGN=0
	while looper<5 do
		-- Durch die alten Gilden rotieren
		looper=looper+1
		if tim.guilds[looper]~=tim.vars.guilds[looper] then
			newGN=tim.searchGN(tim.vars.guilds[looper],false)
			oldGN=tim.searchGN(tim.vars.guilds[looper],true)
			if newGN~=0 then
				if oldGN==0 then
					-- die Gilde ist neu hinzugekommen - nichts zu tun (kann dies hier ueberhaupt eintreffen?)
					tim.sendMessage(tim.locNewGuild..tim.guilds[newGN],true)
				else
					-- die Gilde hat sich geaendert
					tim.retypeGuild(oldGN+tim.msgTypeG1-1,newGN+tim.msgTypeG1-1+200,tim.vars.guilds[looper])
				end
			else
				if oldGN~=0 then
					-- die Gilde wurde geloescht
					tim.sendMessage(tim.locKillGuild..tim.vars.guilds[oldGN],true)
					-- bisherige Gilde war looper+tim.msgTypeG1-1 - diese Nachrichten zum loeschen markieren
					tim.retypeGuild(oldGN+tim.msgTypeG1-1,200,tim.vars.guilds[looper])
					-- Offiziersnachrichten dieser Gilde ebenfalls entfernen
					tim.retypeGuild(oldGN+tim.msgTypeO1-1,200,tim.vars.guilds[looper])
				else
					-- die Gilde ist neu hinzugekommen - nichts zu tun
					tim.sendMessage(tim.locNewGuild..tim.guilds[looper].." ("..looper..")",true)
				end
			end
			tim.vars.guilds[looper]=tim.guilds[looper]
			bAnyChanged=true
		end
	end
	if bAnyChanged==true then
		tim.retypeGuild(0,0,"keine")
		tim.rebuildGOVDisplay()
		if string.sub(tim.vars.guilds[1],1,1)=="*" then
			tim.vars.actualGuild=0
		else
			tim.vars.actualGuild=1
		end
		tim.guildReadGuild()
	end
end


function tim.slider3MouseWheel(event,value)
	-- Nur ausfuehren, wenn Das AddON schon geladen ist
	if (tim.loaded == true) then
		tim.slider3:SetValue(tim.slider3:GetValue()-value)
	end
end


function tim.slider2MouseWheel(event,value)
	-- Nur ausfuehren, wenn Das AddON schon geladen ist
	if (tim.loaded == true) then
		tim.slider2:SetValue(tim.slider2:GetValue()-value)
	end
end


function tim.sliderMouseWheel(event,value)
	-- Nur ausfuehren, wenn Das AddON schon geladen ist
	if (tim.loaded == true) then
		tim.slider:SetValue(tim.slider:GetValue()-value)
	end
end


function tim.infoDelayIgnore(value)
	if tim.GarbageInfoDisplayed==false then
		if string.sub(value,1,1)=="0" then
			tim.sendMessage(tim.locGarbageInfo,true)
			-- Nur einmal pro Sitzung anzeigen
			tim.GarbageInfoDisplayed=true
		end
	end
end


function tim.setBackgroundAlpha(value)
	timWindowBackground:SetAlpha(1-value/100)
	timMagicBackground:SetAlpha(1-value/100)
end


function tim.updateResize(valuex, valuey)
	if valuex~=0 then
		tim.vars.WdX=valuex
	end
	if valuey~=0 then
		tim.vars.WdY=valuey
	end
	tim.WindowResize(tim.vars.WdX, tim.vars.WdY)
end


function tim.WindowResize(dimx,dimy)
	local setx=dimx
	local sety=dimy
	if setx<tim.WindowDimX then
		setx=tim.WindowDimX
	end
	if sety<tim.WindowDimY then
		sety=tim.WindowDimY
	end
	-- die Fenster anpassen
	timWindow:SetDimensions(setx,sety)
	timMagic:SetDimensions(setx,sety)
	local RolleDimx=setx-tim.GovBlockWidth-40
	local RolleDimy=sety-tim.WindowBlock2-20
	if tim.vars.CryptBoxShown==true then
		RolleDimy=RolleDimy-tim.WindowBlock4
	end
	local GovDimy=sety-tim.WindowBlock2-tim.WindowBlock3
	-- den Nachrichtenbereich anpassen
	timWindowRolle:SetDimensions(RolleDimx,RolleDimy)
	timWindowRolle:ClearAnchors()
	timWindowRolle:SetAnchor(TOPLEFT, timWindow, TOPLEFT, setx-RolleDimx-30, tim.WindowBlock2)
	-- die Linien anpassen
	tim.tctrl=GetControl("timWindowLine1")
	tim.tctrl:SetDimensions(setx,2)
	tim.tctrl:ClearAnchors()
	tim.tctrl:SetAnchor(TOPLEFT, timWindow, TOPLEFT, 0, tim.WindowBlock2-10)
	tim.tctrl=GetControl("timWindowLine2")
	tim.tctrl:SetDimensions(2,sety-tim.WindowBlock2)
	tim.tctrl:ClearAnchors()
	tim.tctrl:SetAnchor(TOPLEFT, timWindow, TOPLEFT, tim.GovBlockWidth, tim.WindowBlock2-10)
	tim.tctrl=GetControl("timWindowLine3")
	tim.tctrl:SetDimensions(setx-tim.GovBlockWidth,2)
	tim.tctrl:ClearAnchors()
	if tim.vars.CryptBoxShown==true then
		tim.tctrl:SetAnchor(TOPLEFT, timWindow, TOPLEFT, tim.GovBlockWidth, sety-10-tim.WindowBlock4)
	else
		tim.tctrl:SetAnchor(TOPLEFT, timWindow, TOPLEFT, tim.GovBlockWidth, sety-10)
	end
	-- Die CryptBox anpassen
	tim.tctrl=GetControl("timWindowCryptLbl")
	tim.tctrl:ClearAnchors()
	tim.tctrl:SetAnchor(TOPLEFT, timWindow, TOPLEFT, tim.GovBlockWidth+10, sety-tim.WindowBlock4+3)
	tim.tctrl=GetControl("timWindowCrypt")
	tim.tctrl:SetDimensions(setx-tim.GovBlockWidth-75,25)
	tim.tctrl:ClearAnchors()
	tim.tctrl:SetAnchor(TOPLEFT, timWindow, TOPLEFT, tim.GovBlockWidth+65, sety-tim.WindowBlock4+3)
	-- den Nachrichtenslider anpassen
	tim.slider2:SetDimensions(10,RolleDimy)
	tim.slider2:ClearAnchors()
	tim.slider2:SetAnchor(TOPLEFT, timWindow, TOPLEFT, setx-15, tim.WindowBlock2)
	tim.UpdateRolleSlider()
	tim.slider2:SetValue(timWindowRolle:GetNumHistoryLines())
	-- den GOV-Slider anpassen
	tim.slider:SetDimensions(10,GovDimy)
	tim.slider:ClearAnchors()
	tim.slider:SetAnchor(TOPLEFT, timWindow, TOPLEFT, tim.GovBlockWidth-15, tim.WindowBlock2)
	-- den Magic-Slider anpassen
	tim.sliderM:SetDimensions(10,24*tim.magicQueues)
	tim.sliderM:ClearAnchors()
	tim.sliderM:SetAnchor(TOPLEFT, timMagic, TOPLEFT, 5, tim.MagicBlock)
	-- berechnen, wieviele Buttons Platz haben
	tim.govButtons=math.floor(GovDimy / tim.govbuttonheight)
	tim.UpdateWindowGovList()
	-- Buttons nacherstellen, wenn es zu wenige sind
	local looper=tim.govButtonsCreated
	while looper<tim.govButtons do
		looper=looper+1
		tim.createGOVbutton(looper)
	end
	tim.govButtonsCreated=looper
	-- Buttons unsichtbar machen, wenn es zuviele sind
	looper=0
	while looper<tim.govButtonsCreated do
		looper=looper+1
		tim.tctrl=GetControl("govButton"..tim.to2string(looper))
		if looper<=tim.govButtons then
			tim.tctrl:SetHidden(false)
		else
			tim.tctrl:SetHidden(true)
		end
	end
	tim.UpdateGovButtons(1)
end


function tim.createGOVbutton(nButton)
	local govButtonControl=CreateControlFromVirtual("govButton"..tim.to2string(nButton), timWindow, "govButton")
	govButtonControl:SetDimensions(tim.govbuttonwidth,tim.govbuttonheight-2)
	govButtonControl:SetAnchor(TOPLEFT, timWindow, TOPLEFT, 10, tim.WindowBlock2+(nButton-1)*tim.govbuttonheight)
	govButtonControl:SetFont("EsoUI/Common/Fonts/univers67.otf|16|soft-shadow-thin")
	govButtonControl:SetText(tostring(nButton))
	govButtonControl:SetHandler("OnMouseUp", function(self,button) tim.OnGovClick(self:GetName(),button) end)
end


function tim.createGUILDbutton(nButton)
	local guildButtonControl=CreateControlFromVirtual("guildButton"..tim.to2string(nButton), timGuild, "guildButton")
	guildButtonControl:SetDimensions(tim.guildbuttonwidth,tim.guildbuttonheight-2)
	guildButtonControl:SetAnchor(TOPLEFT, timGuild, TOPLEFT, 40, tim.GuildBlock3+(nButton-1)*tim.guildbuttonheight)
	guildButtonControl:SetFont("EsoUI/Common/Fonts/univers67.otf|16|soft-shadow-thin")
	guildButtonControl:SetText(tostring(nButton))
	guildButtonControl:SetHandler("OnMouseUp", function(self,button) tim.OnGuildClick(button,self:GetName()) end)
	guildButtonControl=CreateControlFromVirtual("guildStatusButton"..tim.to2string(nButton), timGuild, "guildStatusButton")
	guildButtonControl:SetDimensions(tim.guildstatusbuttonwidth,tim.guildbuttonheight-2)
	guildButtonControl:SetAnchor(TOPLEFT, timGuild, TOPLEFT, 10, tim.GuildBlock3+(nButton-1)*tim.guildbuttonheight)
end


function tim.createSCANbutton(nButton)
	local scanButtonControl=CreateControlFromVirtual("scanButton"..tim.to2string(nButton), timScan, "scanButton")
	scanButtonControl:SetDimensions(tim.scanbuttonwidth,tim.scanbuttonheight-2)
	scanButtonControl:SetAnchor(TOPLEFT, timScan, TOPLEFT, 20, 50+(nButton-1)*tim.scanbuttonheight)
	scanButtonControl:SetFont("EsoUI/Common/Fonts/univers67.otf|16|soft-shadow-thin")
	scanButtonControl:SetHandler("OnMouseUp", function(self,button) tim.OnScanClick(button,self:GetName()) end)
end


function tim.EditStart()
	timWindowCrypt:SetKeyboardEnabled(true)
	timWindowCrypt:TakeFocus()
end


function tim.EditEnde(process)
	timWindowCrypt:SetKeyboardEnabled(false)
	timWindowCrypt:LoseFocus()
	if process==true then
		local textEntered=timWindowCrypt:GetText()
		-- verschleiert an das Chatsystem senden
		tim.sendCodedMessage(textEntered,true)
		timWindowCrypt:Clear()
	end
end


function tim.BetreffStart()
	timGuildBetreff:SetKeyboardEnabled(true)
	timGuildBetreff:TakeFocus()
end


function tim.BetreffEnde(bZuNachricht)
	timGuildBetreff:SetKeyboardEnabled(false)
	timGuildBetreff:LoseFocus()
	tim.vars.GuildSubject=timGuildBetreff:GetText()
	if bZuNachricht==true then
		tim.NachrichtStart()
	end
end


function tim.NachrichtStart()
	timGuildNachricht:SetKeyboardEnabled(true)
	timGuildNachricht:TakeFocus()
end


function tim.NachrichtEnde(bZuBetreff)
	timGuildNachricht:SetKeyboardEnabled(false)
	timGuildNachricht:LoseFocus()
	tim.vars.GuildMessage=timGuildNachricht:GetText()
	if bZuBetreff==true then
		tim.BetreffStart()
	end
end


function tim.MailZielStart()
	timMailTarget:SetKeyboardEnabled(true)
	timMailTarget:TakeFocus()
end


function tim.MailZielEnde(bZuBetreff)
	timMailTarget:SetKeyboardEnabled(false)
	timMailTarget:LoseFocus()
	tim.vars.MailTarget=timMailTarget:GetText()
	if bZuBetreff==true then
		tim.MailBetreffStart()
	end
end


function tim.MailBetreffStart()
	timMailBetreff:SetKeyboardEnabled(true)
	timMailBetreff:TakeFocus()
end


function tim.MailBetreffEnde(bZuNachricht)
	timMailBetreff:SetKeyboardEnabled(false)
	timMailBetreff:LoseFocus()
	tim.vars.MailSubject=timMailBetreff:GetText()
	if bZuNachricht==true then
		tim.MailNachrichtStart()
	end
end


function tim.MailNachrichtStart()
	timMailNachricht:SetKeyboardEnabled(true)
	timMailNachricht:TakeFocus()
end


function tim.MailNachrichtEnde(bZuBetreff)
	timMailNachricht:SetKeyboardEnabled(false)
	timMailNachricht:LoseFocus()
	tim.vars.MailMessage=timMailNachricht:GetText()
	if bZuBetreff==true then
		tim.MailBetreffStart()
	end
end


function tim.CatacombEditStart()
	timCatacombEdit:SetKeyboardEnabled(true)
	timCatacombEdit:TakeFocus()
end


function tim.CatacombEditEnde()
	timCatacombEdit:SetKeyboardEnabled(false)
	timCatacombEdit:LoseFocus()
	local textEntered=timCatacombEdit:GetText()
	if tim.vars.CatacombMessageIndex~=0 then
		-- geaenderten Text zurueckspeichern
		tim.vars.CatacombMessage=textEntered
		tim.vars.CatacombScrollsText[tim.vars.CatacombMessageIndex]=textEntered
		tim.loadCatacombScrollPage()
	end
end


function tim.CatacombTargetStart()
	timCatacombTarget:SetKeyboardEnabled(true)
	timCatacombTarget:TakeFocus()
end


function tim.CatacombTargetEnde()
	timCatacombTarget:SetKeyboardEnabled(false)
	timCatacombTarget:LoseFocus()
	local textEntered=timCatacombTarget:GetText()
	-- geaenderten Text zurueckspeichern
	tim.vars.CatacombTarget=textEntered
end


function tim.loadCatacombScrollPage()
	timCatacombScrollsPage:SetText(tim.vars.CatacombScrollsPage)
	tim.CatacombSlider:SetValue(tim.vars.CatacombScrollsPage)
	for looper=1,tim.CatacombRows,1 do
		local CatacombText=GetControl("timCatacombText"..tostring(looper))
		CatacombText:SetText(tim.vars.CatacombScrollsText[looper+tim.CatacombRows*(tim.vars.CatacombScrollsPage-1)])
	end
end


function tim.CatacombScrollPageClick(direction)
	if direction==true then
		tim.vars.CatacombScrollsPage=tim.vars.CatacombScrollsPage+1
		if tim.vars.CatacombScrollsPage>tim.CatacombScrollsMaxPages then
			tim.vars.CatacombScrollsPage=1
		end
	else
		tim.vars.CatacombScrollsPage=tim.vars.CatacombScrollsPage-1
		if tim.vars.CatacombScrollsPage<1 then
			tim.vars.CatacombScrollsPage=tim.CatacombScrollsMaxPages
		end
	end
	tim.loadCatacombScrollPage()
end


function tim.OnCatacombSliderMove(value)
	if tim.PlayerReady==true then
		tim.vars.CatacombScrollsPage=value
		tim.loadCatacombScrollPage()
	end
end


function tim.CatacombButtonHandler(event, button)
	local buttonName=event:GetName()
	local CatacombIndex=0
	if string.sub(buttonName,1,18)=="timCatacombInsKill" then
		CatacombIndex=string.sub(buttonName,19,20)
		local pageIndex=CatacombIndex+0
		CatacombIndex=CatacombIndex+tim.CatacombRows*(tim.vars.CatacombScrollsPage-1)
		if button==1 then
			-- Zeile Einfuegen wenn moeglich
			if tim.vars.CatacombScrollsText[CatacombIndex+tim.CatacombRows-pageIndex]==nil then
				-- eine Zeile durch hinaufschieben einfuegen
				if pageIndex<tim.CatacombRows then
					for looper=tim.CatacombRows-pageIndex,1,-1 do
						tim.vars.CatacombScrollsText[CatacombIndex+looper]=tim.vars.CatacombScrollsText[CatacombIndex+looper-1]
					end
				end
				tim.vars.CatacombScrollsText[CatacombIndex]=nil
				tim.loadCatacombScrollPage()
			else
				-- Kein Platz zum Einfuegen
				tim.sendMessage(tim.locCatacombInsert,true)
				tim.playTimSound(1)
			end
		else
			-- diese Zeile durch herunterziehen loeschen
			if pageIndex<tim.CatacombRows then
				for looper=1,tim.CatacombRows-pageIndex,1 do
					tim.vars.CatacombScrollsText[CatacombIndex+looper-1]=tim.vars.CatacombScrollsText[CatacombIndex+looper]
				end
			end
			tim.vars.CatacombScrollsText[CatacombIndex+tim.CatacombRows-pageIndex]=nil
			tim.loadCatacombScrollPage()
		end
	end
	if string.sub(buttonName,1,17)=="timCatacombSndEdt" then
		CatacombIndex=string.sub(buttonName,18,19)
		CatacombIndex=CatacombIndex+tim.CatacombRows*(tim.vars.CatacombScrollsPage-1)
		tim.vars.CatacombMessageIndex=CatacombIndex
		timCatacombEdit:SetText(tim.vars.CatacombScrollsText[tim.vars.CatacombMessageIndex])
		if button==1 then
			-- Catacomb senden
			if tim.vars.CatacombScrollsText[tim.vars.CatacombMessageIndex]~=nil then
				tim.sendChatMessage(tim.expandTokens(tim.vars.CatacombScrollsText[tim.vars.CatacombMessageIndex]))
			end
		else
			-- Catacomb editieren
			tim.CatacombEditStart()
		end
	end
end


function tim.expandTokens(message)
	local temp=message
	local xTarget=timCatacombTarget:GetText()
	local xStandort=GetUnitZone("player")
	local xStandort=tim.detil(GetMapName())
	local xCharName=GetUnitName("player")
	local xAccount=tim.vars.DisplayName
	temp=string.gsub(temp,"%%t",xTarget)
	temp=string.gsub(temp,"%%o",xStandort)
	temp=string.gsub(temp,"%%c",xCharName)
	temp=string.gsub(temp,"%%a",xAccount)
	return temp
end


function tim.sendMailFailure(event,reason)
	if tim.wait4mail==true then
		tim.wait4mail=false
		local temp=tim.locGuildMailBoxFehler
		temp=string.gsub(temp,"#",tim.MailInQueue,1)
		tim.sendMessage(temp,true)
		-- Eigennachricht simulieren, um die Mail zu dokumentieren
		tim.StoreMessage(2, "*mail", "'"..tim.MailInQueueSUB.."' "..tim.locScanMailDoctoFailed..tim.MailInQueue)
	end
end


function tim.sendMailSuccess()
	if tim.wait4mail==true then
		tim.wait4mail=false
		local temp=tim.locGuildMailBoxSent
		temp=string.gsub(temp,"#",tim.MailInQueue,1)
		tim.sendMessage(temp,true)
		-- Eigennachricht simulieren, um die Mail zu dokumentieren
		tim.StoreMessage(2, "*mail", "'"..tim.MailInQueueSUB.."' "..tim.locScanMailDocto..tim.MailInQueue)
	end
end


function tim.sendMailopenMailBox()
	tim.MailBoxOpen=true
end


function tim.sendMailcloseMailBox()
	tim.MailBoxOpen=false
end


function tim.updateScanTargets()
	for looper=1,tim.scanTargetMax,1 do
		local button=GetControl("scanButton"..tim.to2string(looper))
		button:SetText(tim.vars.scanTargets[looper])
	end
end


function tim.scanClearClick()
	for looper=1,tim.scanTargetMax,1 do
		tim.vars.scanTargets[looper]=nil
	end
	tim.updateScanTargets()
end


function tim.addScanTarget(targetID)
	local isFound=false
	for looper=1,tim.scanTargetMax,1 do
		if tim.vars.scanTargets[looper]==targetID then
			isFound=true
		end
	end
	if isFound==false then
		for looper=tim.scanTargetMax,2,-1 do
			tim.vars.scanTargets[looper]=tim.vars.scanTargets[looper-1]
		end
		tim.vars.scanTargets[1]=targetID
		tim.updateScanTargets()
	end
end


function tim.targetChanged()
	if tim.scanTarget==true then
		if IsUnitPlayer("reticleover")==true then
			local xname=GetUnitName("reticleover")
			local xonline=IsUnitOnline("reticleover")
			if xonline==true then
				if IsUnitVeteran("reticleover")==true then
					local xstufe=GetUnitVeteranRank("reticleover")
					tim.addScanTarget(xname.."[V"..xstufe.."]")
				else
					local xstufe=GetUnitEffectiveLevel("reticleover")
					tim.addScanTarget(xname.."["..xstufe.."]")
				end
			end
		end
	end
end


function tim.beginChatter()
	tim.isChattering=true
end

function tim.endChatter()
	tim.isChattering=false
end

function tim.Ready4Action()
	if tim.PlayerReady==false then
		tim.Initialize_Level2()
		tim.PlayerReady=true
	end
end


function tim.AlerterAlpha(showWarning)
	if tim.vars.showTimButton==true then
		timAlerterBubble:SetAlpha(1)
	else
		if showWarning==true then
			tim.sendMessage(tim.locShowButtonWarning)
		end
		timAlerterBubble:SetAlpha(0)
	end
end


function tim.InitializeSetup(screenWidth, screenHeight)
		-- Das Einstellungsfenster aufbauen - LibAddonMenu Version 2.0
        local panelData = {
            type = "panel",
            name = "TIM 5",
            displayName = "|c00B5FF" .. "TESO Ingame Messenger" .. "|r",
            author = "@Sternentau (updated by Migoda)",
            version = tim.version,
            registerForRefresh = true,
            registerForDefaults = true,
        }
		local optionsData = {
			[1] = {
				type = "header",
				name = tim.locAlertEinstellungen,
				reference = "TIMConfigAddonAlert",
				},
			[2] = {
				type = "checkbox",
				name = tim.locMsgOpAl,
				tooltip = tim.locMsgOpAldsc,
				getFunc = function() return tim.vars.openOnAlarm end,
				setFunc = function(newValue) tim.vars.openOnAlarm=newValue end,
				width = "full",
				default = tim.timdefaults.openOnAlarm,
				reference = "TIMConfigMsgOpAl",
				},
			[3] = {
				type = "checkbox",
				name = tim.locMsgCloC,
				tooltip = tim.locMsgCloCdsc,
				getFunc = function() return tim.vars.CloseInCombat end,
				setFunc = function(newValue) tim.vars.CloseInCombat=newValue end,
				width = "full",
				default = tim.timdefaults.CloseInCombat,
				reference = "TIMConfigMsgCloC",
				},
			[4] = {
				type = "checkbox",
				name = tim.locMsgSwTo,
				tooltip = tim.locMsgSwTodsc,
				getFunc = function() return tim.vars.switchToAlarm end,
				setFunc = function(newValue) tim.vars.switchToAlarm=newValue end,
				width = "full",
				default = tim.timdefaults.switchToAlarm,
				reference = "TIMConfigMsgSwTo",
				},
			[5] = {
				type = "checkbox",
				name = tim.locMsgSwMy,
				tooltip = tim.locMsgSwMydsc,
				getFunc = function() return tim.vars.switchToMyMsg end,
				setFunc = function(newValue) tim.vars.switchToMyMsg=newValue end,
				width = "full",
				default = tim.timdefaults.switchToMyMsg,
				reference = "TIMConfigMsgSwMy",
				},
			[6] = {
				type = "dropdown",
				name = tim.locAlertOptionW,
				tooltip = tim.locAlertOptionWdsc,
				choices = tim.locAlertOption,
				getFunc = function() return tim.vars.AlertOptionW end,
				setFunc = function(value) tim.vars.AlertOptionW = value tim.infoDelayIgnore(value) end,
				width = "full",
				default = tim.timdefaults.AlertOptionW,
				reference = "TIMConfigAddonConfigWdd",
				},
			[7] = {
				type = "dropdown",
				name = tim.locAlertOptionP,
				tooltip = tim.locAlertOptionPdsc,
				choices = tim.locAlertOption,
				getFunc = function() return tim.vars.AlertOptionP end,
				setFunc = function(value) tim.vars.AlertOptionP = value tim.infoDelayIgnore(value) end,
				width = "full",
				default = tim.timdefaults.AlertOptionP,
				reference = "TIMConfigAlertConfigPdd",
				},
			[8] = {
				type = "dropdown",
				name = tim.locAlertOptionG1,
				tooltip = tim.locAlertOptionG1dsc,
				choices = tim.locAlertOption,
				getFunc = function() return tim.vars.AlertOptionG1 end,
				setFunc = function(value) tim.vars.AlertOptionG1 = value tim.infoDelayIgnore(value) end,
				width = "full",
				default = tim.timdefaults.AlertOptionG1,
				reference = "TIMConfigAlertConfigG1dd",
				},
			[9] = {
				type = "dropdown",
				name = tim.locAlertOptionG2,
				tooltip = tim.locAlertOptionG2dsc,
				choices = tim.locAlertOption,
				getFunc = function() return tim.vars.AlertOptionG2 end,
				setFunc = function(value) tim.vars.AlertOptionG2 = value tim.infoDelayIgnore(value) end,
				width = "full",
				default = tim.timdefaults.AlertOptionG2,
				reference = "TIMConfigAlertConfigG2dd",
				},
			[10] = {
				type = "dropdown",
				name = tim.locAlertOptionG3,
				tooltip = tim.locAlertOptionG3dsc,
				choices = tim.locAlertOption,
				getFunc = function() return tim.vars.AlertOptionG3 end,
				setFunc = function(value) tim.vars.AlertOptionG3 = value tim.infoDelayIgnore(value) end,
				width = "full",
				default = tim.timdefaults.AlertOptionG3,
				reference = "TIMConfigAlertConfigG3dd",
				},
			[11] = {
				type = "dropdown",
				name = tim.locAlertOptionG4,
				tooltip = tim.locAlertOptionG4dsc,
				choices = tim.locAlertOption,
				getFunc = function() return tim.vars.AlertOptionG4 end,
				setFunc = function(value) tim.vars.AlertOptionG4 = value tim.infoDelayIgnore(value) end,
				width = "full",
				default = tim.timdefaults.AlertOptionG4,
				reference = "TIMConfigAlertConfigG4dd",
				},
			[12] = {
				type = "dropdown",
				name = tim.locAlertOptionG5,
				tooltip = tim.locAlertOptionG5dsc,
				choices = tim.locAlertOption,
				getFunc = function() return tim.vars.AlertOptionG5 end,
				setFunc = function(value) tim.vars.AlertOptionG5 = value tim.infoDelayIgnore(value) end,
				width = "full",
				default = tim.timdefaults.AlertOptionG5,
				reference = "TIMConfigAlertConfigG5dd",
				},
			[13] = {
				type = "dropdown",
				name = tim.locAlertOptionS,
				tooltip = tim.locAlertOptionSdsc,
				choices = tim.locAlertOption,
				getFunc = function() return tim.vars.AlertOptionS end,
				setFunc = function(value) tim.vars.AlertOptionS = value tim.infoDelayIgnore(value) end,
				width = "full",
				default = tim.timdefaults.AlertOptionS,
				reference = "TIMConfigAlertConfigSdd",
				},
			[14] = {
				type = "dropdown",
				name = tim.locAlertOptionZ,
				tooltip = tim.locAlertOptionZdsc,
				choices = tim.locAlertOption,
				getFunc = function() return tim.vars.AlertOptionZ end,
				setFunc = function(value) tim.infoDelayIgnore(value) tim.vars.AlertOptionZ = value end,
				width = "full",
				default = tim.timdefaults.AlertOptionZ,
				reference = "TIMConfigAlertConfigZdd",
				},
			[15] = {
				type = "header",
				name = tim.locChannelHide,
				reference = "TIMConfigChannelHide",
				},
			[16] = {
				type = "checkbox",
				name = tim.locChannelShowG1,
				tooltip = tim.locChannelShowG15dsc,
				getFunc = function() return tim.vars.ShowG1 end,
				setFunc = function(newValue) tim.vars.ShowG1=newValue tim.rebuildGOVDisplay() end,
				width = "full",
				default = tim.timdefaults.ShowG1,
				reference = "TIMConfigShowG1",
				},
			[17] = {
				type = "checkbox",
				name = tim.locChannelShowG2,
				tooltip = tim.locChannelShowG15dsc,
				getFunc = function() return tim.vars.ShowG2 end,
				setFunc = function(newValue) tim.vars.ShowG2=newValue tim.rebuildGOVDisplay() end,
				width = "full",
				default = tim.timdefaults.ShowG2,
				reference = "TIMConfigShowG2",
				},
			[18] = {
				type = "checkbox",
				name = tim.locChannelShowG3,
				tooltip = tim.locChannelShowG15dsc,
				getFunc = function() return tim.vars.ShowG3 end,
				setFunc = function(newValue) tim.vars.ShowG3=newValue tim.rebuildGOVDisplay() end,
				width = "full",
				default = tim.timdefaults.ShowG3,
				reference = "TIMConfigShowG3",
				},
			[19] = {
				type = "checkbox",
				name = tim.locChannelShowG4,
				tooltip = tim.locChannelShowG15dsc,
				getFunc = function() return tim.vars.ShowG4 end,
				setFunc = function(newValue) tim.vars.ShowG4=newValue tim.rebuildGOVDisplay() end,
				width = "full",
				default = tim.timdefaults.ShowG4,
				reference = "TIMConfigShowG4",
				},
			[20] = {
				type = "checkbox",
				name = tim.locChannelShowG5,
				tooltip = tim.locChannelShowG15dsc,
				getFunc = function() return tim.vars.ShowG5 end,
				setFunc = function(newValue) tim.vars.ShowG5=newValue tim.rebuildGOVDisplay() end,
				width = "full",
				default = tim.timdefaults.ShowG5,
				reference = "TIMConfigShowG5",
				},
			[21] = {
				type = "checkbox",
				name = tim.locChannelShowZ1,
				tooltip = tim.locChannelShowZ15dsc,
				getFunc = function() return tim.vars.ShowZ1 end,
				setFunc = function(newValue) tim.vars.ShowZ1=newValue tim.rebuildGOVDisplay() end,
				width = "full",
				default = tim.timdefaults.ShowZ1,
				reference = "TIMConfigShowZ1",
				},
			[22] = {
				type = "checkbox",
				name = tim.locChannelShowZEN,
				tooltip = tim.locChannelShowZ15dsc,
				getFunc = function() return tim.vars.ShowZEN end,
				setFunc = function(newValue) tim.vars.ShowZEN=newValue tim.rebuildGOVDisplay() end,
				width = "full",
				default = tim.timdefaults.ShowZEN,
				reference = "TIMConfigShowZEN",
				},
			[23] = {
				type = "checkbox",
				name = tim.locChannelShowZFR,
				tooltip = tim.locChannelShowZ15dsc,
				getFunc = function() return tim.vars.ShowZFR end,
				setFunc = function(newValue) tim.vars.ShowZFR=newValue tim.rebuildGOVDisplay() end,
				width = "full",
				default = tim.timdefaults.ShowZFR,
				reference = "TIMConfigShowZFR",
				},
			[24] = {
				type = "checkbox",
				name = tim.locChannelShowZDE,
				tooltip = tim.locChannelShowZ15dsc,
				getFunc = function() return tim.vars.ShowZDE end,
				setFunc = function(newValue) tim.vars.ShowZDE=newValue tim.rebuildGOVDisplay() end,
				width = "full",
				default = tim.timdefaults.ShowZDE,
				eference = "TIMConfigShowZDE",
				},
			[25] = {
				type = "header",
				name = tim.locMsgOpt,
				reference = "TIMConfigMsgOpt",
				},
			[26] = {
				type = "checkbox",
				name = tim.locMsgOptD,
				tooltip = tim.locMsgOptDdsc,
				getFunc = function() return tim.vars.MsgOptD end,
				setFunc = function(newValue) tim.vars.MsgOptD=newValue tim.rebuildGOVDisplay() end,
				width = "full",
				default = tim.timdefaults.MsgOptD,
				reference = "TIMConfigMsgOptD",
				},
			[27] = {
				type = "checkbox",
				name = tim.locMsgOptT,
				tooltip = tim.locMsgOptTdsc,
				getFunc = function() return tim.vars.MsgOptT end,
				setFunc = function(newValue) tim.vars.MsgOptT=newValue tim.rebuildGOVDisplay() end,
				width = "full",
				default = tim.timdefaults.MsgOptT,
				reference = "TIMConfigMsgOptT",
				},
			[28] = {
				type = "header",
				name = tim.locGarbageEinstellungen,
				reference = "TIMConfigAddonGarbage",
			},
			[29] = {
				type = "dropdown",
				name = tim.locGarbageDaysW,
				tooltip = tim.locGarbageDaysWdsc,
				choices = tim.garbage_days,
				getFunc = function() return tim.vars.queuewGarbageDays end,
				setFunc = function(value) tim.vars.queuewGarbageDays = value+0 end,
				width = "full",
				default = tim.timdefaults.queuewGarbageDays,
				reference = "TIMConfigGarbageDaysWdd",
				},
			[30] = {
				type = "dropdown",
				name = tim.locGarbageCountW,
				tooltip = tim.locGarbageCountWdsc,
				choices = tim.garbage_count,
				getFunc = function() return tim.vars.queuewGarbageCount end,
				setFunc = function(value) tim.vars.queuewGarbageCount = value+0 end,
				width = "full",
				default = tim.timdefaults.queuewGarbageCount,
				reference = "TIMConfigGarbageCountWdd",
				},
			[31] = {
				type = "dropdown",
				name = tim.locGarbageDaysP,
				tooltip = tim.locGarbageDaysPdsc,
				choices = tim.garbage_days,
				getFunc = function() return tim.vars.queuepGarbageDays end,
				setFunc = function(value) tim.vars.queuepGarbageDays = value+0 end,
				width = "full",
				default = tim.timdefaults.queuepGarbageDays,
				reference = "TIMConfigGarbageDaysPdd",
				},
			[32] = {
				type = "dropdown",
				name = tim.locGarbageCountP,
				tooltip = tim.locGarbageCountPdsc,
				choices = tim.garbage_count,
				getFunc = function() return tim.vars.queuepGarbageCount end,
				setFunc = function(value) tim.vars.queuepGarbageCount = value+0 end,
				width = "full",
				default = tim.timdefaults.queuepGarbageCount,
				reference = "TIMConfigGarbageCountPdd",
				},
			[33] = {
				type = "dropdown",
				name = tim.locGarbageDaysG,
				tooltip = tim.locGarbageDaysGdsc,
				choices = tim.garbage_days,
				getFunc = function() return tim.vars.queuegGarbageDays end,
				setFunc = function(value) tim.vars.queuegGarbageDays = value+0 end,
				width = "full",
				default = tim.timdefaults.queuegGarbageDays,
				reference = "TIMConfigGarbageDaysGdd",
				},
			[34] = {
				type = "dropdown",
				name = tim.locGarbageCountG,
				tooltip = tim.locGarbageCountGdsc,
				choices = tim.garbage_count,
				getFunc = function() return tim.vars.queuegGarbageCount end,
				setFunc = function(value) tim.vars.queuegGarbageCount = value+0 end,
				width = "full",
				default = tim.timdefaults.queuegGarbageCount,
				reference = "TIMConfigGarbageCountGdd",
				},
			[35] = {
				type = "dropdown",
				name = tim.locGarbageDaysS,
				tooltip = tim.locGarbageDaysSdsc,
				choices = tim.garbage_days,
				getFunc = function() return tim.vars.queuesGarbageDays end,
				setFunc = function(value) tim.vars.queuesGarbageDays = value+0 end,
				width = "full",
				default = tim.timdefaults.queuesGarbageDays,
				reference = "TIMConfigGarbageDaysSdd",
				},
			[36] = {
				type = "dropdown",
				name = tim.locGarbageCountS,
				tooltip = tim.locGarbageCountSdsc,
				choices = tim.garbage_count,
				getFunc = function() return tim.vars.queuesGarbageCount end,
				setFunc = function(value) tim.vars.queuesGarbageCount = value+0 end,
				width = "full",
				default = tim.timdefaults.queuesGarbageCount,
				reference = "TIMConfigGarbageCountSdd",
				},
			[37] = {
				type = "dropdown",
				name = tim.locGarbageDaysZ,
				tooltip = tim.locGarbageDaysZdsc,
				choices = tim.garbage_days,
				getFunc = function() return tim.vars.queuezGarbageDays end,
				setFunc = function(value) tim.vars.queuezGarbageDays = value+0 end,
				width = "full",
				default = tim.timdefaults.queuezGarbageDays,
				reference = "TIMConfigGarbageDaysZdd",
				},
			[38] = {
				type = "dropdown",
				name = tim.locGarbageCountZ,
				tooltip = tim.locGarbageCountZdsc,
				choices = tim.garbage_count,
				getFunc = function() return tim.vars.queuezGarbageCount end,
				setFunc = function(value) tim.vars.queuezGarbageCount = value+0 end,
				width = "full",
				default = tim.timdefaults.queuezGarbageCount,
				reference = "TIMConfigGarbageCountZdd",
				},
			[39] = {
				type = "header",
				name = tim.locAddonEinstellungen,
				reference = "TIMConfigAddonCommon",
			},
			[40] = {
				type = "checkbox",
				name = tim.locGuildCharNames,
				tooltip = tim.locGuildCharNamesDsc,
				getFunc = function() return tim.vars.rtvGuildCharNames end,
				setFunc = function(newValue) tim.vars.rtvGuildCharNames=newValue tim.rebuildGOVDisplay() end,
				width = "full",
				default = tim.timdefaults.rtvGuildCharNames,
				reference = "TIMConfigGuildCharNames",
			},
			[41] = {
				type = "slider",
				name = tim.locConfigWinSizeX,
				tooltip = tim.locConfigWinSizeXdsc,
				min = 600,
				max = math.floor(screenWidth-50),
				step = 10,
				getFunc = function() return tim.vars.WdX end,
				setFunc = function(value) tim.vars.WdX=value tim.updateResize(value,0) end,
				width = "full",
				default = tim.timdefaults.WdX,
				reference = "TIMConfigWinSizeX",
				},
			[42] = {
				type = "slider",
				name = tim.locConfigWinSizeY,
				tooltip = tim.locConfigWinSizeYdsc,
				min = 310,
				max = screenHeight-50,
				step = 1,
				getFunc = function() return tim.vars.WdY end,
				setFunc = function(value) tim.vars.WdY=value tim.updateResize(0, value) end,
				width = "full",
				default = tim.timdefaults.WdY,
				reference = "TIMConfigWinSizeY",
			},
			[43] = {
				type = "checkbox",
				name = tim.locLockWindowConfig,
				tooltip = tim.locLockWindowConfigDsc,
				getFunc = function() return tim.vars.lockWindowPosition end,
				setFunc = function(newValue) tim.UpdateLockStatus(newValue) end,
				width = "full",
				default = tim.timdefaults.lockWindowPosition,
				reference = "TIMConfigLockWindowConfig",
			},
			[44] = {
				type = "slider",
				name = tim.locConfigBackAlpha,
				tooltip = tim.locConfigBackAlphadsc,
				min = 0,
				max = 100,
				step = 10,
				getFunc = function() return tim.vars.BackgroundAlpha end,
				setFunc = function(value) tim.vars.BackgroundAlpha=value tim.setBackgroundAlpha(tim.vars.BackgroundAlpha) end,
				width = "full",
				default = tim.timdefaults.BackgroundAlpha,
				reference = "TIMConfigBackgroundAlpha",
			},
			[45] = {
				type = "checkbox",
				name = tim.locplayOpSnd,
				tooltip = tim.locplayOpSnddsc,
				getFunc = function() return tim.vars.playOpenSound end,
				setFunc = function(newValue) tim.vars.playOpenSound=newValue end,
				width = "full",
				default = tim.timdefaults.playOpenSound,
				reference = "TIMConfigplyOpSnd",
			},
			[46] = {
				type = "dropdown",
				name = tim.locTalkHistoryMax,
				tooltip = tim.locTalkHistoryMaxdsc,
				choices = tim.talkHistory_sizes,
				getFunc = function() return tim.vars.talkHistoryMax end,
				setFunc = function(value) tim.talkHistoryResize(value) end,
				width = "full",
				default = tim.timdefaults.talkHistoryMax,
				reference = "TIMConfigTalkHistoryMax",
				},
			[47] = {
				type = "dropdown",
				name = tim.locGuildWatch,
				tooltip = tim.locGuildWatchDsc,
				choices = tim.watchGuild_options,
				getFunc = function() return tim.vars.watchGuild end,
				setFunc = function(value) tim.vars.watchGuild=value tim.readWatchguild() end,
				width = "full",
				default = tim.timdefaults.watchGuild,
				reference = "TIMConfigWatchGuild",
				},
			[48] = {
				type = "checkbox",
				name = tim.locGuildWatchOn,
				tooltip = tim.locGuildWatchOnDsc,
				getFunc = function() return tim.vars.watchGuildOnMsgs end,
				setFunc = function(newValue) tim.vars.watchGuildOnMsgs=newValue end,
				width = "full",
				default = tim.timdefaults.watchGuildOnMsgs,
				disabled = function() return tim.vars.watchGuild==0 end,
				reference = "TIMConfigWatchGuildOn",
			},
			[49] = {
				type = "checkbox",
				name = tim.locGuildWatchOff,
				tooltip = tim.locGuildWatchOffDsc,
				getFunc = function() return tim.vars.watchGuildOffMsgs end,
				setFunc = function(newValue) tim.vars.watchGuildOffMsgs=newValue end,
				width = "full",
				default = tim.timdefaults.watchGuildOffMsgs,
				disabled = function() return tim.vars.watchGuild==0 end,
				reference = "TIMConfigWatchGuildOff",
			},
			[50] = {
				type = "checkbox",
				name = tim.locShowButton,
				tooltip = tim.locShowButtondsc,
				getFunc = function() return tim.vars.showTimButton end,
				setFunc = function(newValue) tim.vars.showTimButton=newValue tim.AlerterAlpha(true) end,
				width = "full",
				default = tim.timdefaults.showTimButton,
				reference = "TIMConfigshowAlerter",
			},
			[51] = {
				type = "checkbox",
				name = tim.locConfigCrypt,
				tooltip = tim.locConfigCryptdsc,
				getFunc = function() return tim.vars.CryptBoxShown end,
				setFunc = function(newValue) if tim.vars.CryptBoxShown~=newValue then tim.toggleCryptBox() end end,
				width = "full",
				default = tim.timdefaults.showTimButton,
				reference = "TIMConfigshowCryptBox",
			},
			[52] = {
				type = "header",
				name = "version",
                reference = "TIMConfigCommonVersion",
            },
			[53] = {
				type = "description",
				title = "Version " .. tim.version,
				text = tim.locDescriptionConfig,
				width = "full",
				reference = "TIMConfigDescriptionConfig",
				},
		}

        local LAM2 = LibStub("LibAddonMenu-2.0")
        LAM2:RegisterAddonPanel("TIMConfig", panelData)
        LAM2:RegisterOptionControls("TIMConfig", optionsData)
end

function tim.OnMouseEnter(control)
   control.data = control.data or setmetatable({}, {__index = control})
   if (control.tooltipText and control.data.tooltipText == nil) then
      control.data.tooltipText = control.tooltipText
	end
end

function tim.Initialize_Level2()
	-- Den Accountnamen suchen, wenn er nicht erhalten werden kann (Bug ab 1.2.2)
	if GetDisplayName()~="" then
		tim.vars.DisplayName=GetDisplayName()
	else
		tim.GetMyDisplayName()
	end
	-- Der eigene CharName wurde zu früh in den Cache gelesen - den entfernen wir
	tim.gcnLookup(tim.vars.DisplayName,1)
	-- Watchguild elnlesen
	tim.readWatchguild()
	-- Eine Garbage-Collection beim ersten Welteintritt aufrufen
	tim.GarbageCollection()
	-- Die neue Version 5 einmalig promoten
	if tim.vars.TIM5IsPromoted==false then
		tim.sendMessage(tim.locTIM5Promotion)
		tim.vars.TIM5IsPromoted=true
	end
	-- Mitteilen, dass DEBUG evtl. aktiv ist
	tim.sendDebugMessage("Nicht veroeffentlichen - DEBUG ist aktiv")
end


function tim.Initialize(eventCode, addOnName)
	if (addOnName == tim.name) then
		--	Variablen anlegen
		tim.timdefaults = {
			msg={	{mtime={}, mtype={}, mfrom={}, mtext={}, munread={},},
					{mtime={}, mtype={}, mfrom={}, mtext={}, munread={},},
					{mtime={}, mtype={}, mfrom={}, mtext={}, munread={},},
					{mtime={}, mtype={}, mfrom={}, mtext={}, munread={},},
					{mtime={}, mtype={}, mfrom={}, mtext={}, munread={},},},
			msgindex={0,0,0,0,0},
			LoM={	{LoMname="#", LoMword={"","","","","",""},},
					{LoMname="", LoMword={"","","","",""},},
					{LoMname="", LoMword={"","","","",""},},
					{LoMname="", LoMword={"","","","",""},},
					{LoMname="", LoMword={"","","","",""},},
					{LoMname="", LoMword={"","","","",""},},},
			guilds={"*1","*2","*3","*4","*5",},
			talkHistory={},
			Clipboard="",
			talkHistoryMax=7,
			dSizes={{600,310,},{700,353,},{800,410,},{900,450,},{1000,515,},{1200,695,},{600,310,},{600,310,},{600,310,},{600,310,},},
			MsgOptD=false,
			MsgOptT=true,
			DisplayName="",
			lockWindowPosition=false,
			openOnAlarm=true,
			CloseInCombat=true,
			switchToAlarm=true,
			switchToMyMsg=true,
			playOpenSound=true,
			showTimButton=true,
			rtvGuildCharNames=true,
			CryptBoxShown=false,
			BackgroundAlpha=20,
			GuildSubject="",
			GuildMessage="",
			MailSubject="",
			MailMessage="",
			actualGuild=0,
			queryStatus=1,
			queryGtlt=1,
			queryCounts=30,
			queryUnits=3,
			queryIgnore=2,
			queryLMT=1,
			queryRMT=1,
			queryAccount=true,
			CatacombOutput=1,
			CatacombScrollsPage=1,
			CatacombScrollsText={"*2303"},
			CatacombTarget="Tamirel Sternentau",
			CatacombMessageIndex=0,
			CatacombMessage="",
			CatacombIsPromoted=false,
			TIMishIsPromoted=false,
			TIM5IsPromoted=false,
			AofX=0,
			AofY=0,
			WofX=0,
			WofY=0,
			CofX=0,
			CofY=0,
			GofX=0,
			GofY=0,
			SofX=0,
			SofY=0,
			EofX=0,
			EofY=0,
			WdX=600,
			WdY=310,
			AlertOptionW="2",
			AlertOptionP="2",
			AlertOptionG1="1",
			AlertOptionG2="1",
			AlertOptionG3="1",
			AlertOptionG4="1",
			AlertOptionG5="1",
			AlertOptionS="1",
			AlertOptionZ="1",
			ShowG1=true,
			ShowG2=true,
			ShowG3=true,
			ShowG4=true,
			ShowG5=true,
			ShowZ1=true,
			ShowZDE=true,
			ShowZEN=true,
			ShowZFR=true,
			queuewGarbageDays=30,
			queuepGarbageDays=30,
			queuegGarbageDays=8,
			queuezGarbageDays=1,
			queuesGarbageDays=3,
			queuewGarbageCount=1000,
			queuepGarbageCount=300,
			queuegGarbageCount=500,
			queuezGarbageCount=300,
			queuesGarbageCount=200,
			scanTargets={},
			watchGuild=0,
			watchGuildOffMsgs=true,
			watchGuildOnMsgs=true,
		}
		tim.queuew=1
		tim.queuep=2
		tim.queueg=3
		tim.queuez=4
		tim.queues=5
		tim.msgTypeG1=12
		tim.msgTypeG2=13
		tim.msgTypeG3=14
		tim.msgTypeG4=15
		tim.msgTypeG5=16
		tim.msgTypeO1=17
		tim.msgTypeO2=18
		tim.msgTypeO3=19
		tim.msgTypeO4=20
		tim.msgTypeO5=21
		tim.msgTypeZ1=31
		tim.msgTypeZ2=32
		tim.msgTypeZ3=33
		tim.msgTypeZ4=34
		tim.firstMagic=80
		tim.magicQueues=6
		tim.LoMwords=6
		tim.LoMrecords=30
		tim.LoMindex=1
		tim.talkHistoryIndex=1
		tim.talkHistoryAbsMax=25
		tim.CatacombRows=15
		tim.CatacombScrollsMaxPages=50
		tim.gov={vname={}, vtype={}, vunread={}, vprio={},}
		tim.govindex=0
		tim.govactive=0
		tim.govbuttonheight=24
		tim.govbuttonwidth=128
		tim.govButtons=8
		tim.govButtonsCreated=0
		tim.govFirstButton=1
		tim.guildButtons=24
		tim.guildbuttonheight=24
		tim.guildbuttonwidth=128
		tim.guildstatusbuttonwidth=24
		tim.guildFirstButton=1
		tim.scanbuttonheight=24
		tim.scanbuttonwidth=220
		tim.wait4mail=false
		tim.isChattering=false
		tim.guildMouseActions=22
		tim.gcn={gaccount={}, gname={}, glease={},}
		tim.gcnindex=0
		tim.WindowDimY=310
		tim.WindowDimX=600
		tim.WindowBlock2=50
		tim.WindowBlock3=40
		tim.WindowBlock4=36
		tim.MagicBlock=158
		tim.GovBlockWidth=155
		tim.GuildBlockWidth=195
		tim.GuildBlock3=90
		tim.guildindex=0
		tim.guild={maccount={}, mstatus={}, msecsoff={}, mchar={}, mzone={}, mclasstype={}, malliance={}, mlevel={},mveteranRank={},}
		tim.govactive=0
		tim.mailQueue={mTO={}, mSUB={}, mTEXT={},}
		tim.mailQueueindex=0
		tim.MailBoxOpen=false
		tim.AlarmMax=1
		tim.throttle = {}
		tim.throttleCount=300				-- 3x pro Sekunde
    tim.throttleCountMail=1000	-- jede Sekunde
		tim.GarbageCount=1800000			-- jede halbe Stunde
		tim.GuildWatchCount=10000			-- alle 10 Sekunden
		tim.LogoutPreventionCount=300000	-- alle 5 Minuten
		tim.timestampColor="808080"
		tim.senderColor="C0C0C0"
		tim.chatcolor="E6E6AA"
		tim.code1="aeiouAEIOUbcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ5678901234"
		tim.code2="eiouaEIOUAzbcdfghjklmnpqrstvwxyZBCDFGHJKLMNPQRSTVWXY0123456789"
		tim.codeTrigger="(TIMish): "
		tim.scanTarget=false
		tim.scanTargetMax=20
		tim.watchGuildMembers={}
		tim.watchGuildMemberCount=0
		tim.watchactualGuildMembers={}
		tim.watchactualGuildMemberCount=0
		tim.messageFromSeparator="|"
		tim.gcnMaxLease=180					-- Gildenchars bleiben 3 Minuten gueltig  ///
		-- Variablen hinzuladen
		tim.vars = ZO_SavedVars:NewAccountWide("timvars", 2, nil, tim.timdefaults)
		-- Spracheinstellung laden, wenn Sprachdatei vorhanden (sonst die Standardsprache EN)
		if tim.LoadLocalization~=nil then
			tim.LoadLocalization()
		else
			tim.LoadDefaultLocalization()
		end
		-- ab Update 5 funktioniert OnMouseEnter nicht mehr richtig
		ZO_PreHook("ZO_Options_OnMouseEnter", tim.OnMouseEnter)
		-- Die gespeicherten Gilden erstmalig korrigieren
		tim.guilds={"*1","*2","*3","*4","*5",}
		tim.getGuilds()
		local Looper=0
		while Looper<5 do
			Looper=Looper+1
			if tim.vars.guilds[Looper]=="*" then
				tim.vars.guilds[Looper]=tim.guilds[Looper]
			end
		end
		-- die Gildenauswahlen fuer Version 4.7 korrigieren
		if tim.vars.AlertoptionG~=nil then
			tim.vars.AlertoptionG1=tim.vars.AlertoptionG
			tim.vars.AlertoptionG2=tim.vars.AlertoptionG
			tim.vars.AlertoptionG3=tim.vars.AlertoptionG
			tim.vars.AlertoptionG4=tim.vars.AlertoptionG
			tim.vars.AlertoptionG5=tim.vars.AlertoptionG
			tim.vars.AlertoptionG=nil
		end
		-- die lokalisierten Auswahlen eintragen
		tim.vars.AlertOptionW=tim.locAlertOption[string.byte(tim.vars.AlertOptionW)-string.byte("0")+1]
		tim.vars.AlertOptionP=tim.locAlertOption[string.byte(tim.vars.AlertOptionP)-string.byte("0")+1]
		tim.vars.AlertOptionG1=tim.locAlertOption[string.byte(tim.vars.AlertOptionG1)-string.byte("0")+1]
		tim.vars.AlertOptionG2=tim.locAlertOption[string.byte(tim.vars.AlertOptionG2)-string.byte("0")+1]
		tim.vars.AlertOptionG3=tim.locAlertOption[string.byte(tim.vars.AlertOptionG3)-string.byte("0")+1]
		tim.vars.AlertOptionG4=tim.locAlertOption[string.byte(tim.vars.AlertOptionG4)-string.byte("0")+1]
		tim.vars.AlertOptionG5=tim.locAlertOption[string.byte(tim.vars.AlertOptionG5)-string.byte("0")+1]
		tim.vars.AlertOptionZ=tim.locAlertOption[string.byte(tim.vars.AlertOptionZ)-string.byte("0")+1]
		tim.vars.AlertOptionS=tim.locAlertOption[string.byte(tim.vars.AlertOptionS)-string.byte("0")+1]
		-- Fehler aus Version bis einschliesslich 2.3 korrigieren
		tim.vars.queuewGarbageDays=tim.vars.queuewGarbageDays+0
		tim.vars.queuepGarbageDays=tim.vars.queuepGarbageDays+0
		tim.vars.queuegGarbageDays=tim.vars.queuegGarbageDays+0
		tim.vars.queuezGarbageDays=tim.vars.queuezGarbageDays+0
		tim.vars.queuesGarbageDays=tim.vars.queuesGarbageDays+0
		tim.vars.queuewGarbageCount=tim.vars.queuewGarbageCount+0
		tim.vars.queuepGarbageCount=tim.vars.queuepGarbageCount+0
		tim.vars.queuegGarbageCount=tim.vars.queuegGarbageCount+0
		tim.vars.queuezGarbageCount=tim.vars.queuezGarbageCount+0
		tim.vars.queuesGarbageCount=tim.vars.queuesGarbageCount+0
		-- LoM-1 beim ersten Aufruf erstellen
		if tim.vars.LoM[1].LoMname=="#" then
			tim.vars.LoM[1].LoMname=tim.locFirstMagic
			tim.vars.LoM[1].LoMword[1]="wts"
		end
		-- erweiterte LoM (ab version 4.3) aufbauen
		Looper=0
		while Looper<tim.LoMrecords do
			Looper=Looper+1
			if tim.vars.LoM[Looper]==nil then
				tim.vars.LoM[Looper]={LoMname="", LoMword={"","","","",""},}
			end
		end
		-- Katakomben-Schriftrollen erstmalig initialisieren
		if tim.vars.CatacombScrollsText[1]=="*2303" then
			tim.vars.CatacombScrollsText=tim.locCatacombScrollsText
		end
		-- Katakomben-Schriftrollen korrigieren (ab version 4.8)
		Looper=0
		while Looper<(tim.CatacombRows*tim.CatacombScrollsMaxPages) do
			Looper=Looper+1
			if tim.vars.CatacombScrollsText[Looper]=="" then
				tim.vars.CatacombScrollsText[Looper]=nil
			end
		end
		-- talkHistory aufbauen (ab version 4.3)
		tim.talkHistory_sizes = { 7,10,12,15,20,tim.talkHistoryAbsMax, }
		tim.talkHistoryResize(tim.vars.talkHistoryMax)
		-- Auswahlen fuer die Gildenbeobachtung
		tim.watchGuild_options={0,1,2,3,4,5}
		-- Vorgaben fuer die Garbage-Collection
		tim.garbage_days = { 1,2,3,4,5,6,7,14,21,30,45,60,90, }
		tim.garbage_count = { 200,500,750,1000,1500,2500, }
		local screenWidth, screenHeight = GuiRoot:GetDimensions()
		-- Das Einstellungsfenster aufbauen
		tim.InitializeSetup(screenWidth, screenHeight)
		-- Die Fensterpositionen korrigieren, wenn das der erste Aufruf ist oder das Fenster ausserhalb des gueltigen Bereichs
		if (tim.vars.AofX == 0 and tim.vars.AofY == 0) then
			tim.vars.AofX = math.floor(screenWidth / 2) - 70
			tim.vars.AofY = math.floor(screenHeight / 2)
		end
		if (tim.vars.WofX == 0 and tim.vars.WofY == 0) then
			tim.vars.WofX = math.floor(screenWidth / 2)
			tim.vars.WofY = math.floor(screenHeight / 2)
		end
		if (tim.vars.GofX == 0 and tim.vars.GofY == 0) then
			tim.vars.GofX = 100
			tim.vars.GofY = 100
		end
		if (tim.vars.CofX == 0 and tim.vars.CofY == 0) then
			tim.vars.CofX = 120
			tim.vars.CofY = 120
		end
		if (tim.vars.SofX == 0 and tim.vars.SofY == 0) then
			tim.vars.SofX = 80
			tim.vars.SofY = 80
		end
		if (tim.vars.EofX == 0 and tim.vars.EofY == 0) then
			tim.vars.EofX = 30
			tim.vars.EofY = 80
		end
		if (tim.vars.AofX >= screenWidth) then tim.vars.AofX=math.floor(screenWidth / 2) end
		if (tim.vars.AofY >= screenHeight) then tim.vars.AofY=math.floor(screenHeight / 2) end
		if (tim.vars.WofX >= screenWidth) then tim.vars.WofX=math.floor(screenWidth / 2) end
		if (tim.vars.WofY >= screenHeight) then tim.vars.WofY=math.floor(screenHeight / 2) end
		if (tim.vars.GofX >= screenWidth) then tim.vars.GofX=math.floor(screenWidth / 2) end
		if (tim.vars.GofY >= screenHeight) then tim.vars.GofY=math.floor(screenHeight / 2) end
		if (tim.vars.CofX >= screenWidth) then tim.vars.CofX=math.floor(screenWidth / 2) end
		if (tim.vars.CofY >= screenHeight) then tim.vars.CofY=math.floor(screenHeight / 2) end
		if (tim.vars.SofX >= screenWidth) then tim.vars.SofX=math.floor(screenWidth / 2) end
		if (tim.vars.SofY >= screenHeight) then tim.vars.SofY=math.floor(screenHeight / 2) end
		if (tim.vars.EofX >= screenWidth) then tim.vars.EofX=math.floor(screenWidth / 2) end
		if (tim.vars.EofY >= screenHeight) then tim.vars.EofY=math.floor(screenHeight / 2) end
		-- Den Alerter einstellen und anzeigen
		timAlerter:ClearAnchors()
		timAlerter:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tim.vars.AofX, tim.vars.AofY)
		timAlerterBubble:SetTexture("/esoui/art/chatwindow/chat_notification_echo.dds")
		timAlerter:SetMovable(not tim.vars.lockWindowPosition)
		timAlerterBubble:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timAlerterBubble:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		-- Das Nachrichtenfenster einstellen und anzeigen
		timWindow:ClearAnchors()
		timWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tim.vars.WofX, tim.vars.WofY)
		timWindow:SetMovable(not tim.vars.lockWindowPosition)
		timWindowBubble:SetTexture("/esoui/art/chatwindow/chat_notification_up.dds")
		timWindowBubble:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timWindowBubble:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timWindowCloser:SetTexture("/esoui/art/buttons/cancel_up.dds")
		timWindowCloser.tooltipText=tim.locWindowttCloser
		timWindowCloser:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timWindowCloser:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timWindowKill.tooltipText=tim.locWindowttKill
		timWindowKill:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timWindowKill:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timWindowAnswer.tooltipText=tim.locWindowttAnswer
		timWindowAnswer:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timWindowAnswer:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timWindowMagic.tooltipText=tim.locWindowttMagic
		timWindowMagic:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timWindowMagic:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timWindowRotate.tooltipText=tim.locWindowttRotate
		timWindowRotate:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timWindowRotate:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timWindowGuild.tooltipText=tim.locWindowttGuild
		timWindowGuild:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timWindowGuild:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timWindowCatacomb.tooltipText=tim.locWindowttCatacomb
		timWindowCatacomb:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timWindowCatacomb:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		tim.setBackgroundAlpha(tim.vars.BackgroundAlpha)
		tim.TooltipStatistics()
		-- Das Gildenfenster einstellen und anzeigen
		timGuild:ClearAnchors()
		timGuild:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tim.vars.GofX, tim.vars.GofY)
		timGuildHead1:SetText(tim.locGuildDesc)
		timGuildBubble:SetTexture("/esoui/art/chatwindow/chat_notification_up.dds")
		timGuildCloser:SetTexture("/esoui/art/buttons/cancel_up.dds")
		timGuildCloser.tooltipText=tim.locGuildttCloser
		timGuildCloser:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timGuildCloser:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timGuildNext:SetTexture("/esoui/art/ava/ava_resourcestatus_tabicon_production.dds")
		timGuildNext.tooltipText=tim.locGuildttNext
		timGuildNext:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timGuildNext:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timGuildFooterLMTAction:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timGuildFooterLMTAction:SetText(tim.locGuildFooterMTAction[tim.vars.queryLMT])
		timGuildFooterRMTAction:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timGuildFooterRMTAction:SetText(tim.locGuildFooterMTAction[tim.vars.queryRMT])
		timGuildFooterLMTAction.tooltipText=tim.locGuildFooterttLMTAction
		timGuildFooterLMTAction:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timGuildFooterLMTAction:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timGuildFooterRMTAction.tooltipText=tim.locGuildFooterttRMTAction
		timGuildFooterRMTAction:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timGuildFooterRMTAction:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timGuildSwitch.tooltipText=tim.locGuildttSwitch
		timGuildSwitch:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timGuildSwitch:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timGuildFooterDisplayed:SetFont("EsoUI/Common/Fonts/univers57.otf|14|soft-shadow-thin")
		timGuildRefresh.tooltipText=tim.locGuildttRefresh
		timGuildRefresh:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timGuildRefresh:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		-- Das Magiefenster einstellen und anzeigen
		timMagic:ClearAnchors()
		timMagic:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tim.vars.WofX, tim.vars.WofY)
		timMagicBubble:SetTexture("/esoui/art/chatwindow/chat_notification_up.dds")
		timMagicCloser:SetTexture("/esoui/art/buttons/cancel_up.dds")
		timMagicDesc:SetText(tim.locMagicDesc)
		timMagicDesc:SetFont("EsoUI/Common/Fonts/univers57.otf|15|soft-shadow-thin")
		timMagic:SetMovable(not tim.vars.lockWindowPosition)
		timMagicCloser.tooltipText=tim.locMagicttCloser
		timMagicCloser:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timMagicCloser:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		-- Magicfenster Eingabebereich aufbauen
		Looper=0
		local Looper2=1
		while Looper2<=tim.magicQueues do
			Looper=0
			while Looper<=tim.LoMwords do
				tim.mycontrol=CreateControlFromVirtual("timMagicBack"..tostring(Looper2)..tostring(Looper),timMagic, "MagicBack")
				tim.mycontrol:SetDimensions( 78, 35 )
				tim.mycontrol:ClearAnchors()
				tim.mycontrol:SetAnchor(TOPLEFT, timMagic, TOPLEFT, 17+Looper*83, tim.MagicBlock+(Looper2-1)*24)
				if Looper==0 then
					tim.mycontrol:SetTexture("/esoui/art/campaign/overview_scoringbg_aldmeri_left.dds")
				else
					if Looper<tim.LoMwords then
						tim.mycontrol:SetTexture("/esoui/art/campaign/overview_scoringbg_daggerfall_left.dds")
					else
						tim.mycontrol:SetTexture("/esoui/art/campaign/overview_scoringbg_ebonheart_left.dds")
					end
				end
				tim.mycontrol=CreateControlFromVirtual("timMagicEdit"..tostring(Looper2)..tostring(Looper),timMagic, "ZO_DefaultEditForBackdrop")
				tim.mycontrol:SetDimensions( 68, 24 )
				tim.mycontrol:ClearAnchors()
				tim.mycontrol:SetAnchor(TOPLEFT, timMagic, TOPLEFT, 27+Looper*83, tim.MagicBlock+2+(Looper2-1)*24)
				tim.mycontrol:SetMaxInputChars(16)
				tim.mycontrol:SetMultiLine(false)
				tim.mycontrol:SetColor(1,1,0.8,1)
				tim.mycontrol:SetFont("EsoUI/Common/Fonts/univers57.otf|14|soft-shadow-thin")
				if Looper==0 then
					tim.mycontrol.tooltipText=tim.locMagicnameDesc
				else
					if Looper<tim.LoMwords then
						tim.mycontrol.tooltipText=tim.locMagicwordDesc
					else
						tim.mycontrol.tooltipText=tim.locMagicomitDesc
					end
				end
				tim.mycontrol:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
				tim.mycontrol:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
				Looper=Looper+1
			end
			Looper2=Looper2+1
		end
		tim.storeMagicValues(false)
		-- Den Magic-Slider platzieren
		tim.sliderM = CreateControl("MagicSlider",timMagic,CT_SLIDER)
		tim.sliderM:SetMouseEnabled(true)
		tim.sliderM:SetThumbTexture("ESOUI/art/lorelibrary/lorelibrary_scroll.dds","ESOUI/art/lorelibrary/lorelibrary_scroll.dds","ESOUI/art/lorelibrary/lorelibrary_scroll.dds",15,25,0,0,1,1)
		tim.sliderM:SetHandler("OnValueChanged",function(self,value,eventReason) tim.OnMagicSliderMove(value) end)
		tim.sliderM:SetDimensions(10,24*tim.magicQueues)
		tim.sliderM:ClearAnchors()
		tim.sliderM:SetAnchor(TOPLEFT, timMagic, TOPLEFT, 5, tim.MagicBlock)
		tim.sliderM:SetHidden(false)
		tim.sliderM:SetMinMax(1,tim.LoMrecords-tim.LoMwords)
		tim.sliderM:SetValueStep(1)
		tim.sliderM:SetValue(tim.LoMindex)
		-- Das Katakombenfenster einstellen und anzeigen
		timCatacomb:ClearAnchors()
		timCatacomb:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tim.vars.CofX, tim.vars.CofY)
		timCatacombBubble:SetTexture("/esoui/art/chatwindow/chat_notification_up.dds")
		timCatacombCloser:SetTexture("/esoui/art/buttons/cancel_up.dds")
		timCatacomb:SetMovable(not tim.vars.lockWindowPosition)
		timCatacombCloser.tooltipText=tim.locCatacombttCloser
		timCatacombCloser:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timCatacombCloser:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timCatacombHelp.tooltipText=tim.locCatacombttHelp
		timCatacombHelp:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timCatacombHelp:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timCatacombScan.tooltipText=tim.locCatacombttScan
		timCatacombScan:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timCatacombScan:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timCatacombHead1:SetText(tim.locCatacombHeader)
		timCatacombTargetTxt:SetText(tim.locCatacombTarget)
		timCatacombTargetTxt:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timCatacombTarget:SetText(tim.vars.CatacombTarget)
		timCatacombOutput:SetText(tim.locCatacombOut[tim.vars.CatacombOutput])
		timCatacombOutput:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timCatacombScrollsTxt1:SetText(tim.locCatacombScrolls1)
		timCatacombScrollsTxt1:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timCatacombScrollsTxt2:SetText(tim.locCatacombScrolls2)
		timCatacombScrollsTxt2:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		tim.CatacombSlider=CreateControl("CatacombSlider",timCatacomb,CT_SLIDER)
		tim.CatacombSlider:SetOrientation(ORIENTATION_HORIZONTAL)
		tim.CatacombSlider:SetDimensions(200,24)
		tim.CatacombSlider:SetMouseEnabled(true)
		tim.CatacombSlider:SetThumbTexture("EsoUI\\Art\\Miscellaneous\\scrollbox_elevator.dds", "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator_disabled.dds", nil, 8, 16) 
		tim.CatacombSlider:SetHandler("OnValueChanged",function(self,value,eventReason) tim.OnCatacombSliderMove(value) end)
		tim.CatacombSlider:SetHidden(false)
		tim.CatacombSlider:SetMinMax(1, tim.CatacombScrollsMaxPages)
		tim.CatacombSlider:SetValueStep(1)
		tim.CatacombSlider:SetValue(tim.vars.CatacombScrollsPage)
		tim.CatacombSlider:ClearAnchors()
		tim.CatacombSlider:SetAnchor(TOPLEFT, timCatacombScrollsMor, TOPRIGHT, 10, 0)
		tim.CatacombSlider.bg=CreateControl(nil, tim.CatacombSlider, CT_BACKDROP)
		tim.CatacombSlider.bg:SetCenterColor(0, 0, 0)
		tim.CatacombSlider.bg:SetAnchor(TOPLEFT, slider, TOPLEFT, 0, 4)
		tim.CatacombSlider.bg:SetAnchor(BOTTOMRIGHT, slider, BOTTOMRIGHT, 0, -4)
		tim.CatacombSlider.bg:SetEdgeTexture("EsoUI\\Art\\Tooltips\\UI-SliderBackdrop.dds", 32, 4)
		-- Katakombenfenster Auswahlbereich aufbauen
		Looper=0
		while Looper<tim.CatacombRows do
			Looper=Looper+1
			-- Einfuegen/Loeschen Knopf
			tim.mycontrol=CreateControlFromVirtual("timCatacombInsKill"..tostring(Looper),timCatacomb, "InsKill")
			tim.mycontrol:ClearAnchors()
			tim.mycontrol:SetAnchor(TOPLEFT, timCatacomb, TOPLEFT, 10, 250+(Looper-1)*26)
			tim.mycontrol.tooltipText=tim.locInsKillDesc
			tim.mycontrol:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
			tim.mycontrol:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
			-- Textkonserve
			tim.mycontrol=CreateControlFromVirtual("timCatacombText"..tostring(Looper),timCatacomb, "CataText")
			tim.mycontrol:ClearAnchors()
			tim.mycontrol:SetAnchor(TOPLEFT, timCatacomb, TOPLEFT, 40, 250+(Looper-1)*26)
			tim.mycontrol:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
			tim.mycontrol:SetText("Hey"..tostring(Looper))
			-- Senden/Bearbeiten Knopf
			tim.mycontrol=CreateControlFromVirtual("timCatacombSndEdt"..tostring(Looper),timCatacomb, "SndEdt")
			tim.mycontrol:ClearAnchors()
			tim.mycontrol:SetAnchor(TOPLEFT, timCatacomb, TOPLEFT, 415, 245+(Looper-1)*26)
			tim.mycontrol.tooltipText=tim.locSndEdtDesc
			tim.mycontrol:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
			tim.mycontrol:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		end
		timCatacombTarget:SetAlpha(1)
		timCatacombTarget:SetColor(1,1,1,1)
		timCatacombTarget:SetCopyEnabled(true)
		timCatacombTarget:SetPasteEnabled(true)
		timCatacombTarget:SetEditEnabled(true)
		timCatacombTarget:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timCatacombTarget:SetMaxInputChars(80)
		timCatacombTarget:SetMultiLine(false)
		timCatacombTarget:SetNewLineEnabled(false)
		timCatacombTarget:SetText(tim.vars.CatacombTarget)
		timCatacombEdit:SetAlpha(1)
		timCatacombEdit:SetColor(1,1,1,1)
		timCatacombEdit:SetCopyEnabled(true)
		timCatacombEdit:SetPasteEnabled(true)
		timCatacombEdit:SetEditEnabled(true)
		timCatacombEdit:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timCatacombEdit:SetMaxInputChars(800)
		timCatacombEdit:SetMultiLine(true)
		timCatacombEdit:SetNewLineEnabled(true)
		timCatacombEdit:SetHandler("OnLinkMouseUp", function(self, _, link, button) return ZO_LinkHandler_OnLinkMouseUp(link, button, self) end)
		tim.loadCatacombScrollPage()
		-- Das Scanfenster einstellen und anzeigen
		timScan:ClearAnchors()
		timScan:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tim.vars.SofX, tim.vars.SofY)
		timScanBubble:SetTexture("/esoui/art/chatwindow/chat_notification_up.dds")
		timScanCloser:SetTexture("/esoui/art/buttons/cancel_up.dds")
		timScanHead1:SetText(tim.locScanHeader)
		timScan:SetMovable(not tim.vars.lockWindowPosition)
		timScanCloser.tooltipText=tim.locScanttCloser
		timScanCloser:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timScanCloser:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timScanClear.tooltipText=tim.locScanttClear
		timScanClear:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timScanClear:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		timScanFooterLMTAction:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timScanFooterLMTAction:SetText(tim.locScanFooterLMTAction)
		timScanFooterRMTAction:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timScanFooterRMTAction:SetText(tim.locScanFooterRMTAction)
		-- Das Mailfenster einstellen und anzeigen
		timMail:ClearAnchors()
		timMail:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, tim.vars.EofX, tim.vars.EofY)
		timMailBubble:SetTexture("/esoui/art/chatwindow/chat_notification_up.dds")
		timMailCloser:SetTexture("/esoui/art/buttons/cancel_up.dds")
		timMailHead1:SetText(tim.locMailHeader)
		timMail:SetMovable(not tim.vars.lockWindowPosition)
		timMailCloser.tooltipText=tim.locMailttCloser
		timMailCloser:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
		timMailCloser:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
		-- Die Betreff Box anpassen
		timMailTarget:SetAlpha(1)
		timMailTarget:SetColor(1,1,1,1)
		timMailTarget:SetCopyEnabled(true)
		timMailTarget:SetPasteEnabled(true)
		timMailTarget:SetEditEnabled(true)
		timMailTarget:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timMailTarget:SetMaxInputChars(80)
		timMailTarget:SetMultiLine(false)
		timMailTarget:SetNewLineEnabled(false)
		timMailTarget:SetText(tim.vars.CatacombTarget)
		timMailTargetLBL:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timMailTargetLBL:SetText(tim.locMailTarget)
		timMailBetreffLBL:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timMailBetreffLBL:SetText(tim.locMailSubject)
		timMailBetreff:Clear()
		timMailBetreff:SetAlpha(1)
		timMailBetreff:SetColor(1,1,1,1)
		timMailBetreff:SetCopyEnabled(true)
		timMailBetreff:SetPasteEnabled(true)
		timMailBetreff:SetEditEnabled(true)
		timMailBetreff:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timMailBetreff:SetMaxInputChars(80)
		-- Die Nachrichtbox anpassen
		timMailNachricht:Clear()
		timMailNachricht:SetAlpha(1)
		timMailNachricht:SetColor(1,1,1,1)
		timMailNachricht:SetCopyEnabled(true)
		timMailNachricht:SetPasteEnabled(true)
		timMailNachricht:SetEditEnabled(true)
		timMailNachricht:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timMailNachricht:SetMaxInputChars(800)
		timMailNachricht:SetMultiLine(true)
		timMailNachricht:SetNewLineEnabled(true)
		timMailNachricht:SetHandler("OnLinkMouseUp", function(self, _, link, button) return ZO_LinkHandler_OnLinkMouseUp(link, button, self) end)
		timMailSendAction:SetText(tim.locMailSendAction)
		timMailCancelAction:SetText(tim.locMailCancelAction)
		-- gespeicherte Werte eintragen
		timMailBetreff:SetText(tim.vars.MailSubject)
		timMailNachricht:SetText(tim.vars.MailMessage)
		timMailTarget:SetText(tim.vars.MailTarget)
		-- Die GOV-Buttons aufbauen
		Looper=0
		while Looper<tim.govButtons do
			Looper=Looper+1
			tim.createGOVbutton(Looper)
		end
		tim.govButtonsCreated=tim.govButtons
		-- Die Gilden-Buttons aufbauen
		Looper=0
		while Looper<tim.guildButtons do
			Looper=Looper+1
			tim.createGUILDbutton(Looper)
		end
		-- Die Scan-Buttons aufbauen
		Looper=0
		while Looper<tim.scanTargetMax do
			Looper=Looper+1
			tim.createSCANbutton(Looper)
		end
		tim.updateScanTargets()
		-- Den GOV-Slider platzieren
		tim.slider = CreateControl("govSlider",timWindow,CT_SLIDER)
		tim.slider:SetMouseEnabled(true)
		tim.slider:SetThumbTexture("ESOUI/art/lorelibrary/lorelibrary_scroll.dds","ESOUI/art/lorelibrary/lorelibrary_scroll.dds","ESOUI/art/lorelibrary/lorelibrary_scroll.dds",15,25,0,0,1,1)
		tim.slider:SetHandler("OnValueChanged",function(self,value,eventReason) tim.OnSliderMove(value) end)
		tim.UpdateWindowGovList()
		tim.slider:SetHidden(true)
		tim.slider:SetValueStep(1)
		-- Den Nachrichtenbereich konfigurieren
		timWindowRolle:SetLinkEnabled(true)
		timWindowRolle:SetMouseEnabled(true)
		timWindowRolle:SetHidden(false)
		timWindowRolle:SetClearBufferAfterFadeout(false)
		timWindowRolle:SetMaxHistoryLines(1000)
		timWindowRolle:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timWindowRolle:SetHandler("OnLinkMouseUp", function(self, _, link, button) return ZO_LinkHandler_OnLinkMouseUp(link, button, self) end)
		tim.KeepWindowClosed=true
		tim.SetWindowVisible(false)
		-- Den Magie-Nachrichtenbereich konfigurieren
		tim.KeepMagicClosed=true
		tim.SetMagicVisible(false)
		-- Den Katakomben-Nachrichtenbereich konfigurieren
		tim.KeepCatacombClosed=true
		tim.SetCatacombVisible(false)
		-- Scan-Nachrichtenbereich konfigurieren
		tim.KeepScanClosed=true
		tim.SetScanVisible(false)
		-- Mail-Nachrichtenbereich konfigurieren
		tim.KeepMailClosed=true
		tim.SetMailVisible(false)
		-- Den Nachrichten-Slider platzieren
		tim.slider2 = CreateControl("timSlider",timWindow,CT_SLIDER)
		tim.slider2:SetMouseEnabled(true)
		tim.slider2:SetThumbTexture("ESOUI/art/lorelibrary/lorelibrary_scroll.dds","ESOUI/art/lorelibrary/lorelibrary_scroll.dds","ESOUI/art/lorelibrary/lorelibrary_scroll.dds",15,25,0,0,1,1)
		tim.slider2:SetHandler("OnValueChanged",function(self,value,eventReason) tim.OnSlider2Move(value) end)
		tim.UpdateRolleSlider()
		tim.slider2:SetValue(timWindowRolle:GetNumHistoryLines())
		tim.slider2:SetValueStep(1)
		-- Die CryptBox anpassen
		timWindowCrypt:Clear()
		timWindowCrypt:SetAlpha(1)
		timWindowCrypt:SetColor(1,1,1,1)
		timWindowCrypt:SetCopyEnabled(true)
		timWindowCrypt:SetPasteEnabled(true)
		timWindowCrypt:SetEditEnabled(true)
		timWindowCrypt:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timWindowCrypt:SetMaxInputChars(300)
		timWindowCrypt:SetHidden(not tim.vars.CryptBoxShown)
		timWindowCryptLbl:SetFont("EsoUI/Common/Fonts/univers67.otf|14|soft-shadow-thin")
		timWindowCryptLbl:SetHidden(not tim.vars.CryptBoxShown)
		-- Den Gilden-Slider platzieren
		tim.slider3 = CreateControl("guildSlider",timGuild,CT_SLIDER)
		tim.slider3:SetMouseEnabled(true)
		tim.slider3:SetThumbTexture("ESOUI/art/lorelibrary/lorelibrary_scroll.dds","ESOUI/art/lorelibrary/lorelibrary_scroll.dds","ESOUI/art/lorelibrary/lorelibrary_scroll.dds",15,25,0,0,1,1)
		tim.slider3:SetHandler("OnValueChanged",function(self,value,eventReason) tim.OnSlider3Move(value) end)
		tim.UpdateGuildList()
		tim.slider3:SetHidden(true)
		tim.slider3:SetValueStep(1)
		tim.guildSetGuildWindow()
		-- Den Gilden-Nachrichtenbereich konfigurieren
		tim.KeepGuildClosed=true
		tim.SetGuildVisible(false)
		-- Die Betreff Box anpassen
		timGuildBetreffLBL:ClearAnchors()
		timGuildBetreffLBL:SetAnchor(TOPLEFT, timGuildBackground, TOPLEFT, 220, 100)
		timGuildBetreffLBL:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timGuildBetreffLBL:SetText(tim.locGuildSubject)
		timGuildBetreff:Clear()
		timGuildBetreff:SetAlpha(1)
		timGuildBetreff:SetColor(1,1,1,1)
		timGuildBetreff:SetCopyEnabled(true)
		timGuildBetreff:SetPasteEnabled(true)
		timGuildBetreff:SetEditEnabled(true)
		timGuildBetreff:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timGuildBetreff:SetMaxInputChars(80)
		timGuildBetreff:SetDimensions(290,25)
		timGuildBetreff:ClearAnchors()
		timGuildBetreff:SetAnchor(TOPLEFT, timGuild, TOPLEFT, 290, 100)
		-- Die Nachrichtbox anpassen
		timGuildNachricht:Clear()
		timGuildNachricht:SetDimensions(360,480)
		timGuildNachricht:SetAlpha(1)
		timGuildNachricht:SetColor(1,1,1,1)
		timGuildNachricht:SetCopyEnabled(true)
		timGuildNachricht:SetPasteEnabled(true)
		timGuildNachricht:SetEditEnabled(true)
		timGuildNachricht:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timGuildNachricht:SetMaxInputChars(410)
		timGuildNachricht:SetMultiLine(true)
		timGuildNachricht:SetNewLineEnabled(true)
		timGuildNachricht:SetHandler("OnLinkMouseUp", function(self, _, link, button) return ZO_LinkHandler_OnLinkMouseUp(link, button, self) end)
		-- Schrift in der Suchzeile einstellen
		timGuildqrySuche:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timGuildqryAuswahl:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timGuildqryZusatz:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timGuildqryGtlt:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timGuildqryAnzahl:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timGuildqryEinheit:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		timGuildqryMode:SetFont("EsoUI/Common/Fonts/univers57.otf|16|soft-shadow-thin")
		-- Wenn noch nie eine aktuelle Gilde gesetzt war, dann auf die erste Gilde setzen, wenn es denn eine gibt
		if tim.vars.actualGuild==0 then
			if string.sub(tim.vars.guilds[1],1,1)~="*" then
				tim.guildNextGuild(true)
			end
		end
		-- den Gilden-Slider anpassen
		tim.slider3:SetDimensions(10,tim.guildButtons*tim.guildbuttonheight)
		tim.slider3:ClearAnchors()
		tim.slider3:SetAnchor(TOPLEFT, timGuild, TOPLEFT, tim.GuildBlockWidth-15, tim.GuildBlock3)
		-- Die Werte aus den Savedvariables eintragen
		timGuildBetreff:SetText(tim.vars.GuildSubject)
		timGuildNachricht:SetText(tim.vars.GuildMessage)
		-- Die Fenster anpassen
		tim.WindowResize(tim.vars.WdX,tim.vars.WdY)
		tim.AlerterAlpha(false)
		-- Daten loeschen, wenn sie nicht mehr aufgezeichnet sein sollen
		tim.GarbageDrop()
		-- Den GOV aufbauen
		tim.ReCreateGOV()
		-- Die erste Gruppe einfach mal anklicken, wenn es denn eine gibt
		if tim.govindex>0 then
			tim.changeGOVrolle(1,false)
		else
			tim.changeGOVrolle(0,false)
		end
		-- Wenn es eine talkHistory gibt, dann die letzte Diskussion anklicken
		if tim.vars.talkHistory[1]~="" then
			tim.SwitchGOV(tim.vars.talkHistory[1])
		end
		-- Alarm auf "aus" setzen
		tim.AlarmCycle=0
		tim.AlarmCount=0
		tim.SwitchAlarm()
		-- Keybinding ermoeglichen
		ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_TIM", tim.locBindingToggle)
		ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_GUILD", tim.locBindingGuildToggle)
		ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_CATACOMB", tim.locBindingCatacombToggle)
		ZO_CreateStringId("SI_BINDING_NAME_TOGGLE_SCANNER", tim.locBindingScanToggle)
		ZO_CreateStringId("SI_BINDING_NAME_ROTATE_UP", tim.locBindingRotateUp)
		ZO_CreateStringId("SI_BINDING_NAME_ROTATE_DOWN", tim.locBindingRotateDown)
		ZO_CreateStringId("SI_BINDING_NAME_DO_LOGOUT", tim.locBindingLogout)
		ZO_CreateStringId("SI_BINDING_NAME_DO_QUIT", tim.locBindingQuit)
		tim.updateGuilds()
		tim.vars.Clipboard=""
		tim.loaded=true
	end
end


--	Die Events setzen, und dann kann es schon losgehen ;-)
EVENT_MANAGER:RegisterForEvent(tim.name, EVENT_ADD_ON_LOADED, tim.Initialize)
EVENT_MANAGER:RegisterForEvent(tim.name, EVENT_PLAYER_ACTIVATED, tim.Ready4Action)
EVENT_MANAGER:RegisterForEvent(tim.name, EVENT_CHAT_MESSAGE_CHANNEL, tim.IncomingMessage)
EVENT_MANAGER:RegisterForEvent(tim.name, EVENT_MAIL_OPEN_MAILBOX, tim.sendMailopenMailBox)
EVENT_MANAGER:RegisterForEvent(tim.name, EVENT_MAIL_CLOSE_MAILBOX, tim.sendMailcloseMailBox)
EVENT_MANAGER:RegisterForEvent(tim.name, EVENT_MAIL_SEND_FAILED, tim.sendMailFailure)
EVENT_MANAGER:RegisterForEvent(tim.name, EVENT_MAIL_SEND_SUCCESS, tim.sendMailSuccess)
EVENT_MANAGER:RegisterForEvent(tim.name, EVENT_RETICLE_TARGET_CHANGED, tim.targetChanged)
EVENT_MANAGER:RegisterForEvent(tim.name, EVENT_CHATTER_BEGIN, tim.beginChatter)
EVENT_MANAGER:RegisterForEvent(tim.name, EVENT_CHATTER_END, tim.endChatter)
SLASH_COMMANDS["/tim"] = tim.SlashCMD
