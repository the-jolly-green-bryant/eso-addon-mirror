--	Inner Sea Trading Company Guild Utils
--
--	Author:			@lintydruid
--
--	Description:	Utils for Guild Member (Inner Sea Trading Company EU)
--
--	Usage Notes:	/guildtools
--			
--
--
--  GLOBALS & LOCALS



-- create global CW object
guildtools = {dataStrucVer=0.17, data={}}


guildtools.defaults={
		dataStrucVer=0.17,
		showdebug=false,
		showmotd=true,
		guilds={},
		alerts={level=2, online=2, -- 0=off, 1 = chart, 2 = chat and alert
			x=0, y =0, config=ldrude_qmess.data}, -- Alert Windows Position adjustment
		status={x=0,y=0,show=true,mode="Normal"},
		mailq={},
		mail_auto_send=false,
		messageDuration=1000
		}
		

		
--	Declare Vars
guildtools.gupdateFirstRun=true
guildtools.guildname="None"
guildtools.adv_last=0;
guildtools.guildid=0;
guildtools.guildcount=0;
guildtools.gchannel="g1"
guildtools.lastWisper=""
guildtools.guild_changes={}
guildtools.mail={message="", subject="", cansend = false, targetRank=1, sentTotal=0, sentPhase=0, pauseUntil=0, paused=false, maxSend=15, pause=2}  -- pause is used to control the number of minutes between batch sends.

guildtools.timers={init=12000, update=1500, mailsend=5000}



-- Declare Locale Control

guildtools.lang={}
guildtools.lang.sets={}
guildtools.lang.core={}
guildtools.lang.config={}

--  maintain data structures
function guildtools.upgradeData()
	
	if guildtools.data.alerts==nil then guildtools.data.alerts={level=2, online=2, x=0, y =0}  end
	
	if guildtools.data.showmotd==nil then guildtools.data.showmotd=true end
	
	if guildtools.data.alerts.confi==nil then guildtools.data.alerts.config=ldrude_qmess.data end
			
	if guildtools.data.status==nil then guildtools.data.status={x=0,y=0,show=true,mode="Normal"} end
	
	if guildtools.data.messageDuration==nil then guildtools.data.messageDuration=1000 end
		
	for id,guild in pairs(guildtools.data.guilds) do -- upgrade guild structure
		if guildtools.data.guilds[id].config==nil then
			guildtools.data.guilds[id].config={
						alert=3, -- 0 - none, 1 - chat , 2 -notify , 3 -all ,
						showGuildList = true,
						showMOTD = true
						}
		end
		
		if guildtools.data.guilds[id].config.showLevelChanges==nil then guildtools.data.guilds[id].config.showLevelChanges=true end
		if guildtools.data.guilds[id].config.showStatusChanges==nil then guildtools.data.guilds[id].config.showStatusChanges=true end
		if guildtools.data.guilds[id].config.showGuildPlayerChanges==nil then guildtools.data.guilds[id].config.showGuildPlayerChanges=true end
		
		if guildtools.data.guilds[id].autoInviteText==nil then
				guildtools.data.guilds[id].autoInviteText=""
		end
		
	end
	
	
	if guildtools.data.mailq==nil then guildtools.data.mailq={} end
			
	if guildtools.data.mail_auto_send==nil then guildtools.data.mail_auto_send=false end
	

	guildtools.debug("Data Upgrade ran (if needed)")
end

function guildtools.getGuildTemplate()
	return {
		adverts={
			
			guildtools.lang.core.defaultAdvert,
			guildtools.lang.core.defaultAdvert,
			guildtools.lang.core.defaultAdvert,
			guildtools.lang.core.defaultAdvert,
			guildtools.lang.core.defaultAdvert
			
			},
			
			autoInviteText="",
			
			memberCount=-1,
			motd="",
			members={},
			rank=-1,
			
			keep=-1, -- Claimed Keep ID.
			
			config={
				alert=3, -- 0 - none, 1 - chat , 2 -notify , 3 -all ,
				showGuildList = true,
				showMOTD = true,
				showLevelChanges=true,
				showStatusChanges=true,
				showGuildPlayerChanges=true
				
				},
			
		}
end
	
		
--	Initialisation Function
function guildtools.init( self, addOnName )
	
	guildtools.lang.Set() -- Init language
	
	
	if ( addOnName ~= "guildtools" ) then return end -- is it for this addon?

	--	Load saved vars
	guildtools.data = ZO_SavedVars:NewAccountWide( "guildtools_data" , 1 , nil , guildtools.defaults , nil )
	
	-- Data Clean-up/Upgrade
	
	
	guildtools.upgradeData();

	


	
		
	--- Init UI	
		
	--guildtools_ui_create()	
	--------Update Guild Dataset---------
	
	--guildtools.updateGuilds();
	
	

	-- Get updates for Message Settings Changes
	
	 ldrude_qmess.RegisterForConfigChangeEvent(guildtools.qmess_data_changed)
	 
	 ldrude_qmess.Config(guildtools.data.alerts.config)
	 
	 --Init UI
	 
	 guildtools.ui.create()
	 
	 
	 
	---- Init Config window
	
	guildtools.config.create()
	 
	guildtools.debug("Initialised")
	
	ld_timer.add("guildtoolsInit",guildtools.timers.init,guildtools.FirstRun, 1) --- One off init timer
	

	--------- Register Events -------------------
	
	EVENT_MANAGER:RegisterForEvent( "guildtools" , EVENT_CHAT_MESSAGE_CHANNEL, guildtools.onChat)
	
	EVENT_MANAGER:RegisterForEvent( "guildtools" ,EVENT_GUILD_MEMBER_CHARACTER_LEVEL_CHANGED, guildtools.player_has_levelled)

	EVENT_MANAGER:RegisterForEvent( "guildtools" ,EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, guildtools.player_has_changed)
	
end

function  guildtools.qmess_data_changed(value)
	guildtools.data.alerts.config=value
end


--------- Guild Scrolling
function guildtools.currGuildSelectedIndex()
	local guildname=GUILD_ROSTER_MANAGER.guildName
	local numGuilds=GetNumGuilds()
	
	for n=1,numGuilds,1 do
		local gid = GetGuildId(n)
		local guildnameCheck = GetGuildName(gid)
		if guildname==guildnameCheck then
			 return n
		end
	
	end
	
	return 0
end

function  guildtools.ChangeGuild(adjust)

	local numGuilds=GetNumGuilds()

	local currentGuild= guildtools.currGuildSelectedIndex()
	
	currentGuild=currentGuild+adjust
	
	if numGuilds<currentGuild then
	
		currentGuild=1
		
	elseif currentGuild<1 then
		currentGuild=numGuilds
	end
	
	
	GUILD_ROSTER_MANAGER:SetGuildId(GetGuildId(currentGuild))
	
end

--------------------Update Guild Dataset
function guildtools.FirstRun()


	ld_timer.add("guildtoolsUpdate",guildtools.timers.update,guildtools.updateGuilds, 0) --- start timer
	ld_timer.add("guildtoolsSendMail",guildtools.timers.mailsend,guildtools.mail_send, 0) --- start timer

	guildtools.updateGuilds()
	guildtools.mail_send()
	
	
end

	
--------------------Update Guild Dataset

function guildtools.updateGuilds()
	
	local guildInfo="";
	local gname=string.upper();
	
		
	local isRefresh=not guildtools.gupdateFirstRun -- Is it a second or subsequent run?
	
	guildtools.gupdateFirstRun=false -- Not now first run
	

	guildtools.guildcount= GetNumGuilds()
	
	if guildtools.guildcount <1 then
		guildtools.message(guildtools.lang.core.noGuild);
		return
	end	
	--- Create base data for guild.
	
	local oldgid=guildtools.guildid
	
	guildtools.guildid=-1
	
	local curr_guildie_online=0 
	local curr_guild_online=0 
	local tot_guildie=0 
	
	
	
	
	for n=1, guildtools.guildcount, 1 do
		local gid = GetGuildId(n)
		
		guildtools.debug("Checking out guild ... ".. GetGuildName(gid) .. "Is it "..GUILD_ROSTER_MANAGER.guildName);
		if GetGuildName(gid)==GUILD_ROSTER_MANAGER.guildName then
			guildtools.debug("--- Found");
			guildtools.guildid=gid;
			guildtools.gchannel="g"..n
			if (GetGuildName(gid)~=guildtools.guildname) then
				guildtools.message(guildtools.lang.core.activeGuildStub..GetGuildName(gid))
				guildtools.guildname=GetGuildName(gid);
				guildtools.config.setGuildInfoText()
				guildtools.config.loadAdverts()
			end
			
		end
		
		--- Create data structure if does not exist
		
		if guildtools.data.guilds[GetGuildName(gid)] == nil then
				guildtools.data.guilds[GetGuildName(gid)]=guildtools.getGuildTemplate()
		elseif (isRefresh==false) then
				 guildtools.data.guilds[GetGuildName(gid)].motd="" -- reset motd on first pass
		end
		
		--- Update Guild Member Data
		
		
		
		for id,member in pairs(guildtools.data.guilds[GetGuildName(gid)].members) do
		
			if (member.left==false and member.found==false) then
				member.left=true
				table.insert(guildtools.guild_changes,string.format(guildtools.lang.core.msg_gm_left,GetGuildName(gid),id))
				
			end
			
			member.found=false -- reset for next search
		
		end
		
		
		for f =1, GetNumGuildMembers(gid),1 do
			
			tot_guildie=tot_guildie+1
			
		
			gname, gnote, rankIndex, playerStatus, secsSinceLogoff = GetGuildMemberInfo(gid,f)
			
			if guildtools.data.guilds[GetGuildName(gid)].members[gname]==nil then
					guildtools.data.guilds[GetGuildName(gid)].members[gname]={name=gname, note=gnote, lastStatus=playerStatus, lastSeen=secsSinceLogoff, rank=rankIndex, left=false, found=true}
					
					
					if guildtools.data.guilds[GetGuildName(gid)].config.showGuildPlayerChanges then
						table.insert(guildtools.guild_changes,string.format(guildtools.lang.core.msg_gm_new,GetGuildName(gid),gname))
					end
					
			else
				
					if (guildtools.data.guilds[GetGuildName(gid)].members[gname].left) then
						if guildtools.data.guilds[GetGuildName(gid)].config.showGuildPlayerChanges then
							table.insert(guildtools.guild_changes,string.format(guildtools.lang.core.msg_gm_rejoin,GetGuildName(gid),gname))
						end
						guildtools.data.guilds[GetGuildName(gid)].members[gname].left=false
					end
					
					if (guildtools.data.guilds[GetGuildName(gid)].members[gname].note~=gnote) and guildtools.data.guilds[GetGuildName(gid)].config.showGuildPlayerChanges then
						table.insert(guildtools.guild_changes,string.format(guildtools.lang.core.msg_gm_notechange,GetGuildName(gid),gname,gnote))
					end
					
					if (guildtools.data.guilds[GetGuildName(gid)].members[gname].rank~=rankIndex) and guildtools.data.guilds[GetGuildName(gid)].config.showGuildPlayerChanges then
						table.insert(guildtools.guild_changes,string.format(guildtools.lang.core.msg_gm_rankchange,GetGuildName(gid),gname))
					end
					
					
					guildtools.data.guilds[GetGuildName(gid)].members[gname]={name=gname, note=gnote, lastStatus=playerStatus, lastSeen=secsSinceLogoff, rank=rankIndex, left=false, found=true}
					
					if playerStatus~=PLAYER_STATUS_OFFLINE then
						curr_guildie_online=curr_guildie_online+1
					end
					
					if playerStatus~=PLAYER_STATUS_OFFLINE and gid == guildtools.guildid then
						curr_guild_online=curr_guild_online+1
					end
					
			end
		end
		
		--- Update Config
		
		guildtools.config.setGuildInfoText()
		
		--- Check Keep Status 		
		if (not DoesGuildHaveClaimedKeep(gid)) then
			if guildtools.data.guilds[GetGuildName(gid)].keep>-1 then
				table.insert(guildtools.guild_changes,string.format(guildtools.lang.core.msg_gkeep_lost,GetGuildName(gid)))
				guildtools.data.guilds[GetGuildName(gid)].keep=-1
			end
		else
			claimedKeep=GetGuildClaimedKeep(gid)
			if (claimedKeep~=guildtools.data.guilds[GetGuildName(gid)].keep) then
				guildtools.data.guilds[GetGuildName(gid)].keep=claimedKeep
				table.insert(guildtools.guild_changes,string.format(guildtools.lang.core.msg_gkeep_change,GetGuildName(gid)))
			end
		end
		
			
		
			
			
			
		--- Only on refresh, not initially (create some delay)
		
		if isRefresh then
			if guildtools.data.guilds[GetGuildName(gid)].motd ~= GetGuildMotD(gid) then
				
				if (guildtools.data.guilds[GetGuildName(gid)].config.showMOTD) then
					guildtools.data.guilds[GetGuildName(gid)].motd=GetGuildMotD(gid)
					guildtools.message(string.format(guildtools.lang.core.motd,GetGuildName(gid)))
					guildtools.message("|c008000"..GetGuildMotD(gid) )
				end
		
			end
		
		end
		
		
		
	end	
	
	
	if (isRefresh) then --  Only on refresh, not initially (create some delay)
	
		for n=1,#guildtools.guild_changes,1 do
		
			d(guildtools.guild_changes[n])
		
		end
		
		guildtools.guild_changes={} --- reset
	
	end
	
	
		
	if (guildtools.guildid==-1) then -- No guild selected/active
		guildtools.guildname="None";
		if (guildtools.guildid~=oldgid) then
			guildtools.message("|cFF0000"..guildtools.lang.core.noGuildSelected)
		--	guildtools.config.setGuildInfoText()
			guildtools.config.loadAdverts()
			guildtools.gchannel="g1"
			
			
			
		end
		guildtools.ui.status.updateInfo(guildtools.lang.core.noGuildSelected)
		guildtools.ui.status.update(guildtools.lang.core.status_noGuild,0,0,curr_guildie_online,tot_guildie,0)
		return
	end
	
	
	-- Create guild Info String
	
	guildInfo=string.format(guildtools.lang.core.guildInfoTemplate,GetGuildMotD(guildtools.guildid))
	
	-- Update Guild Display
	if (guildtools.ui.status.update~=nil) then
		guildtools.ui.status.update(GetGuildName(guildtools.guildid),curr_guild_online, GetNumGuildMembers(guildtools.guildid), curr_guildie_online,tot_guildie,GetGuildAlliance(guildtools.guildid)) -- *** Get Numbers
		guildtools.ui.status.updateInfo(guildInfo)
		guildtools.ui.status.setVisibility()
	end
	

	

end


function guildtools.message (text)
	d (text)
end

function guildtools.debug (text)
	if guildtools.data.showdebug~=nil  then
		if guildtools.data.showdebug==true then
			guildtools.message("|c0000CCguildtools debug :: |r"..text)
		end
	end
end

function guildtools.error (text)
	
		guildtools.message("|cFF0000guildtools error :: |r"..text)
	
end

--- ************************
--- **** Command Lines ****
--- ************************

function guildtools.cmd_advert( text )

	if (string.upper(text)=="LIST")then
		guildtools.cmd("GA LIST")
	else
		guildtools.cmd("GA"); -- Call command line GA
	end
	

end

function guildtools.cmd_chat( text )

	guildtools.postChatMessage(text, guildtools.gchannel)

		

end


function guildtools.postChatMessage(msg, channel)

	
	ZO_ChatWindowTextEntryEditBox:TakeFocus()
	ZO_ChatWindowTextEntryEditBox:Clear()
	ZO_ChatWindowTextEntryEditBox:SetText("/"..channel.." "..msg )
		
	ZO_ChatWindowTextEntryEditBox:SetSelection(string.len(msg)-1, string.len(msg))
	ZO_ChatWindowTextEntryEditBox:TakeFocus()

end

function guildtools.cmd_invite( text )

	if (guildtools.guildid<1) then
			guildtools.error(guildtools.lang.core.noGuild)
			return
	end
	
	
	 guildtools.guild_invite(guildtools.guildid, text)
	
end

function guildtools.cmd_invite1( text )

	guildtools.guild_invite(GetGuildId(1), text )
	
end

function guildtools.cmd_invite3( text )

	guildtools.guild_invite(GetGuildId(2), text )
	
end

function guildtools.cmd_invite3( text )

	guildtools.guild_invite(GetGuildId(3), text )
	
end

function guildtools.cmd_invite4( text )

	guildtools.guild_invite(GetGuildId(4), text )
	
end

function guildtools.cmd_invite5( text )

	guildtools.guild_invite(GetGuildId(5), text )
	
end


function guildtools.guild_invite(guildID, text )

	if GetGuildName(guildID)=="" then
		guildtools.error(guildtools.lang.core.mail_msgGuildIdMissing);
		return
	end
	
	if text=="" then text=guildtools.lastWisper end
	
	
	
	GuildInvite(guildID, text)
	
	guildtools.message(string.format(guildtools.lang.core.msg_invite,text,GetGuildName(guildID)))
end

function guildtools.cmd_leave( text )

	if (guildtools.guildid<1) then
			guildtools.error(guildtools.lang.core.noGuild)
			return
	end
	
	guildtools.message(string.format(guildtools.lang.core.msg_left_guild,guildtools.guildname))

	GuildLeave(guildtools.guildid)
	
	
end


function guildtools.cmd_promote( text )

	if (guildtools.guildid<1) then
			guildtools.error(guildtools.lang.core.noGuild)
			return
	end
	

	GuildPromote(guildtools.guildid, text)
	
	guildtools.message(string.format(guildtools.lang.core.msg_promoted,text,guildtools.guildname))
end

function guildtools.cmd_demote( text )

	if (guildtools.guildid<1) then
			guildtools.error(guildtools.lang.core.noGuild)
			return
	end
	
	GuildDemote(guildtools.guildid, text)
	
	guildtools.message(string.format(guildtools.lang.core.msg_demoted,text,guildtools.guildname))
end

function guildtools.cmd_remove( text )

	if (guildtools.guildid<1) then
			guildtools.error(guildtools.lang.core.noGuild)
			return
	end
	

	GuildRemove(guildtools.guildid, text)
	
	guildtools.message(string.format(guildtools.lang.core.msg_removed,text,guildtools.guildname))
end


	

function guildtools.cmd( text )

	cmd_text=text; -- keep pure copy
	
	text = string.upper(text)
	if (guildtools.guildid<1) then
			guildtools.error(guildtools.lang.core.noGuild)
			return
	end
	
	

	if text=="" then 
		for n =1,#guildtools.lang.core.cmdHelp,1 do
			guildtools.message(guildtools.lang.core.cmdHelp[n])
		end
		
		guildtools.message(string.format(guildtools.lang.core.cmdHelp_activeguild,guildtools.guildname))
	
	
		
	elseif text=="GA" then 
		
		if (guildtools.data.guilds[guildtools.guildname].adverts[1]=="" and
			guildtools.data.guilds[guildtools.guildname].adverts[2]=="" and
			guildtools.data.guilds[guildtools.guildname].adverts[3]=="" and
			guildtools.data.guilds[guildtools.guildname].adverts[4]=="" and
			guildtools.data.guilds[guildtools.guildname].adverts[5]=="") then
			
			return
		end
		
		guildtools.adv_last=guildtools.adv_last+1 --Next Message
		
		if (guildtools.adv_last<1 or guildtools.adv_last> 5) then
			guildtools.adv_last=1
		end
		
		while guildtools.data.guilds[guildtools.guildname].adverts[guildtools.adv_last]=="" do 
		
			guildtools.adv_last=guildtools.adv_last+1 --Next Message
			
			if (guildtools.adv_last<1 or guildtools.adv_last> 5) then
				guildtools.adv_last=1
			end
		end
		
		
		
		
		-- get raw advert
		local advert=guildtools.data.guilds[guildtools.guildname].adverts[guildtools.adv_last];
	
		-- replace macro strings
		advert = guildtools.getAdvString(advert)
		
		--advert = "/zone "..advert
	
	--	local param= userdata: 00000000
		--SendChatMessage(advert, GetChatChannelId("zone"), "")
		
		--ZO_ChatWindowTextEntryEditBox.SetText("/zone "..advert)
		
		guildtools.postChatMessage(advert, "zone")
		
		guildtools.debug("Chat command -> Advert |c00ff00["..guildtools.adv_last.." of 5]|r "..advert);
	
	elseif text=="GA LIST" then 
		guildtools.message(string.format(guildtools.lang.core.cmd_advertlist,guildtools.guildname))
		for n=1,5,1 do
			guildtools.message("  - |c00ff00["..n.." of 5 ]|r "..guildtools.getAdvString(guildtools.data.guilds[guildtools.guildname].adverts[n]))
		end
		
	elseif text=="DEBUG ON" then 
		guildtools.message("guildtools --> debug |c00ff00on|r")
		guildtools.data.showdebug=true
		guildtools.debug("Outputing debug.")
	elseif text=="DEBUG OFF" then 
		guildtools.message("guildtools --> debug |cff0000off|r")
		guildtools.data.showdebug=false
	else
		guildtools.error("Command not recognised!")
	end
end


function guildtools.DisplayMailMessage(showInstr)

	
	
	local targets=""
	for n=1,GetNumGuildRanks(guildtools.guildid),1 do
	
		if guildtools.mail.targetRank==2 or 
			(DoesGuildRankHavePermission(guildtools.guildid,n,GUILD_PERMISSION_DEMOTE) or
			DoesGuildRankHavePermission(guildtools.guildid,n,GUILD_PERMISSION_PROMOTE) or
			DoesGuildRankHavePermission(guildtools.guildid,n,GUILD_PERMISSION_OFFICER_CHAT_READ) or
			DoesGuildRankHavePermission(guildtools.guildid,n,GUILD_PERMISSION_OFFICER_CHAT_WRITE)) then
		
		
			targets=targets..GetGuildRankCustomName(guildtools.guildid,n).."; "
			
		end
		
	end
	
	
	guildtools.message(guildtools.lang.core.mail_msgTitle)
	guildtools.message(string.format(guildtools.lang.core.mail_msgRecpt,targets))
	guildtools.message(string.format(guildtools.lang.core.mail_msgSubj,guildtools.mail.subject))
	guildtools.message(string.format(guildtools.lang.core.mail_msgMess,guildtools.mail.message))
	
	if (showInstr) then
		guildtools.message(guildtools.lang.core.mail_msgInstr)
	end

end

function guildtools.mail_send()
	
	if ZO_MailSendToLabel:IsHidden() then -- Compose message window not visible
		return
	end
		
	
	if #guildtools.data.mailq>0 then
		
		if guildtools.mail.paused and guildtools.mail.pauseUntil>GetGameTimeMilliseconds() then -- reducing mail pressure
			return;
		end
				
		if guildtools.mail.paused then
			guildtools.message(string.format(guildtools.lang.core.mail_msgPauseOff,#guildtools.data.mailq))
			guildtools.mail.paused=false
		end
		
				
		if guildtools.mail.sentPhase== guildtools.mail.maxSend then
			guildtools.message(string.format(guildtools.lang.core.mail_msgPause,guildtools.mail.pause,#guildtools.data.mailq))
			guildtools.mail.pauseUntil=GetGameTimeMilliseconds()+(guildtools.mail.pause*60000)
			guildtools.mail.sentPhase=0
			guildtools.mail.paused=true
			return
		end
		
	
		local msg=guildtools.data.mailq[1]
		
		table.remove(guildtools.data.mailq,1) -- Delete from Q
		
		SendMail(msg[1], msg[2], msg[3])
		
		 guildtools.mail.sentTotal= guildtools.mail.sentTotal+1
		
		 guildtools.mail.sentPhase= guildtools.mail.sentPhase+1 
		
		guildtools.debug(" -Sent to: |cff0000"..msg[1].."|r")
	end
	

	
end

function guildtools.CreateMailMessage(target, subject, message)


	-- Define target Rank -- Target (1) = officers, (2)= all
	
		
		guildtools.mail.targetRank= target
		
		---------------Create Message-----------------
		
		
		if (guildtools.guildid<1) then
				guildtools.error(guildtools.lang.core.noGuild)
				return
		end
		
		
		if subject==nil or subject=="" then
			guildtools.error(guildtools.lang.core.mail_noSubject)
			guildtools.mail.cansend = false
			return
		end
		
				
		
		if message==nil or message=="" then
			guildtools.error(guildtools.lang.core.mail_noMessage)
			guildtools.mail.cansend = false
			return
		end
		
		
		
		-- message=string.gsub(message, "\\n",string.char(13,10))
		--subject=guildtools.guildname.." - "..subject
		
		message=message..string.char(13,10,13,10).."Sent using GuildTools."
		
		guildtools.mail.message=message
		guildtools.mail.subject=subject
		guildtools.mail.cansend = true
		
		if (guildtools.data.mail_auto_send) then
			guildtools.SendMail()
		else
			guildtools.DisplayMailMessage(true)
		end
		

end

function guildtools.SendMail()
		
		
	
		
		guildtools.message(guildtools.lang.core.mail_msgSendStart)
		guildtools.DisplayMailMessage(false)
		
		
		local gplayers=GetNumGuildMembers(guildtools.guildid)
		local msgCount=0
		for n=1,gplayers,1 do
		
			local name, note, rankind, status,secsfromlogoff  = GetGuildMemberInfo(guildtools.guildid, n)
			
			
			if guildtools.mail.targetRank==2 or 
				(DoesGuildRankHavePermission(guildtools.guildid,rankind,GUILD_PERMISSION_DEMOTE) or
				DoesGuildRankHavePermission(guildtools.guildid,rankind,GUILD_PERMISSION_PROMOTE) or
				DoesGuildRankHavePermission(guildtools.guildid,rankind,GUILD_PERMISSION_OFFICER_CHAT_READ) or
				DoesGuildRankHavePermission(guildtools.guildid,rankind,GUILD_PERMISSION_OFFICER_CHAT_WRITE)) then
			
				msgCount=msgCount+1
			--SendMail(name, guildtools.mail.subject, guildtools.mail.message)
				table.insert(guildtools.data.mailq,{name, guildtools.mail.subject, guildtools.mail.message})
			end
			
			
		end
		guildtools.message(string.format(guildtools.lang.core.mail_msgSendSumm,msgCount))
		guildtools.message(guildtools.GetMailStatus())
		guildtools.mail.cansend = false
		

end
function guildtools.GetMailStatus()

	return string.format(guildtools.lang.core.mail_msgSendState,#guildtools.data.mailq,math.ceil(#guildtools.data.mailq*(1/(60/(guildtools.timers.mailsend/1000)))))
	
	
	
end

function guildtools.cmd_mail( text )

	cmd_text=text; -- keep pure copy
	
	text = string.upper(text)
	if (guildtools.guildid<1) then
			guildtools.error(guildtools.lang.core.noGuild)
			return
	end
	
	if text=="" then 
	
		for n =1,#guildtools.lang.core.cmdMailHelp,1 do
			guildtools.message(guildtools.lang.core.cmdMailHelp[n])
		end
			
	elseif text=="CLEAR" then
		guildtools.data.mailq={}
		guildtools.message(guildtools.lang.core.mail_msgClear)
		
	elseif text=="STATUS" then
		guildtools.message(guildtools.GetMailStatus())
	
	elseif text=="SEND" then 
		
		
		guildtools.SendMail()
		
		
		
	else 
		guildtools.error("Command not recognised!")
	end
end

function guildtools.getAdvString(advert)

	advert=string.gsub(advert, "({guildname})", guildtools.guildname)
	advert=string.gsub(advert, "({player})", GetUnitName("player"))
	return advert
end

guildtools.utils={}

function guildtools.utils:NameCleanup(StringVar)
		local apos=string.find( StringVar, "^", 1, true)
		 if apos == nil or apos<2 then
			return StringVar
		end
		
		return string.sub(StringVar,1,apos-1);
end 


function guildtools.utils:SafeNil(StringVar)
		if (StringVar== nil) then
			return "";
		end

		return StringVar;
end 

function guildtools.utils:TimeString(secs)

	if (secs==nil) then
		return "-";
	end
	
	if (secs<60) then
		return secs..guildtools.lang.Seconds;
	end
		
	
	
	local mins=math.floor(secs/60);
	local hours=0;
	local days=0;

	hours,mins=math.modf(mins/60);
	mins=math.floor(mins*60);

	days,hours=math.modf(hours/24);

	hours=math.floor(hours*24);

	sret=""
	if (days>0) then
		sret=days..guildtools.lang.Days.." ";
	end

	if (hours>0 or days>0) then
		sret=sret..hours..guildtools.lang.Hours.." ";
	end

	sret=sret..mins..guildtools.lang.Minutes;

return sret;




end

function guildtools.utils:Explode(delimiter, text)
  local list = {}; local pos = 1
  
  if strtrim(text)=="" then
    return {}
  end

  while 1 do
    local first, last = string.find(text, delimiter, pos)
    if first then
      table.insert(list, string.sub(text, pos, first-1))
      pos = last+1
    else
      table.insert(list, string.sub(text, pos))
      break
    end
  end
  return list
end

function guildtools.player_has_levelled( self, GuildID, PlayerName, PersoName, NewLvl)
	
	PlayerName= guildtools.utils:NameCleanup(PlayerName)
	PersoName=guildtools.utils:NameCleanup(PersoName)
	
	if guildtools.data.guilds~=nil and guildtools.data.guilds[GetGuildName(GuildID)].config.showLevelChanges then
		local msg=string.format(guildtools.lang.core.msg_gm_levelchange,PersoName,PlayerName,NewLvl,GetGuildName(GuildID))
		
		guildtools.announce(GetGuildName(GuildID), msg,guildtools.lang.core.icon_alert, -1)
	end

end


function guildtools.player_has_changed(self, GuildID, PlayerName, oldStatus, newStatus)
	PlayerName= guildtools.utils:NameCleanup(PlayerName)
	
	if (GetGuildName(GuildID)==nil or guildtools.data.guilds[GetGuildName(GuildID)]==nil) then return end;
	
	if guildtools.data.guilds~=nil and  guildtools.data.guilds[GetGuildName(GuildID)].config.showStatusChanges then
		local msg=string.format(guildtools.lang.core.msg_gm_statuschange,PlayerName,GetGuildName(GuildID),guildtools.guild_player_status(newStatus))
		
		guildtools.announce(GetGuildName(GuildID), msg,guildtools.lang.core.icon_alert, -1)
	end

end

function guildtools.announce(sguild, msg, icon, overrideMode)
	
	local mode=1
	
	if guildtools.data.guilds== nil or guildtools.data.guilds[sguild]==nil then -- not init
		overrideMode=1 -- chat only
	else	
		mode = guildtools.data.guilds[sguild].config.alert
	end
	

	
	if (overrideMode>-1) then
		mode=overrideMode
	end
	
	if mode == 0 then --- do not display
		return;
	end

	
	if (mode>1) then
		-- guildtools_ui_newalert(msg)
		ldrude_qmess.add(msg,icon,guildtools.data.messageDuration)
	end
	
	if (mode==1 or mode==3) then
		guildtools.message(msg)
	end

end



function guildtools.guild_player_status(status)
	if(status ==  PLAYER_STATUS_AWAY ) then
		return guildtools.lang.core.msg_gm_statusaway
	elseif(status ==  PLAYER_STATUS_DO_NOT_DISTURB) then
		return guildtools.lang.core.msg_gm_statusDND
	elseif(status == PLAYER_STATUS_OFFLINE) then
		return guildtools.lang.core.msg_gm_statusoffline
	elseif(status == PLAYER_STATUS_ONLINE) then
		return guildtools.lang.core.msg_gm_statusonline
	else
		return guildtools.lang.core.msg_gm_statusunknown
	end
end

-------------------------------- Watch Chat -------------------------------------------------

function guildtools.onChat(id, msgType, msgSource, msgText) -- EVENT_CHAT_MESSAGE_CHANNEL (integer messageType, string fromName, string text)

	guildtools.debug("Message --> ["..msgType.."] ["..msgSource.."] "..string.gsub(msgText,"|","#"))
--	PlaySound("bell")
	

	if (msgType==2) then -- whisper
	
		local msgU=string.upper(msgText)
			
		local playerName=string.gsub(msgSource,"(^.*)","")
		
		guildtools.lastWisper=playerName
		
		for id,guild in pairs(guildtools.data.guilds) do 
		
			if guild.autoInviteText~="" and  string.find(msgU,string.upper(guild.autoInviteText))~=nil then
			
				local guildID=0
				
				for n=1,GetNumGuilds(),1 do
					if (GetGuildName(GetGuildId(n))==id) then
						guildID=GetGuildId(n)
					end
				end
				
				guildtools.announce(id, string.format(guildtools.lang.core.msg_autoinvite,playerName),guildtools.lang.core.icon_alert, 3)
				guildtools.guild_invite(guildID, playerName )
			end
		end
		
		return
	end

	if (msgType==12) then -- guild
		-- Do nothing atm
		return
	end
	
	
end

function guildtools.motd_chat(guild)

	local guildid=-1;
	local channel=""
	
	if (guild==0) then
	
		if (guildtools.guildid<1) then
			guildtools.error(guildtools.lang.core.noGuild)
			return
		end
		
		guildid = guildtools.guildid
		channel= guildtools.gchannel
	else
		if guild>GetNumGuilds() then
			guildtools.error(guildtools.lang.core.mail_msgGuildIdMissing)
			return
		end
		
		guildid=GetGuildId(guild)
		channel="g"..guild
	end
	
	
	local msg = guildtools.lang.core.motdchat..GetGuildMotD(guildid)
	
	guildtools.postChatMessage(msg, channel)
	

end

-------------------------------- Init Code --------------------------------------------------
--	Register Init
EVENT_MANAGER:RegisterForEvent( "guildtools" , EVENT_ADD_ON_LOADED , guildtools.init )

-- Slash Commands --
SLASH_COMMANDS["/guildtools"] =  guildtools.cmd

SLASH_COMMANDS["/gm"] =  guildtools.cmd_chat

SLASH_COMMANDS["/gt"] =  guildtools.cmd

SLASH_COMMANDS["/adv"] =  guildtools.cmd_advert

SLASH_COMMANDS["/ga"] =  guildtools.cmd_advert

SLASH_COMMANDS["/ginvite"] =  guildtools.cmd_invite

SLASH_COMMANDS["/g1invite"] =  guildtools.cmd_invite1

SLASH_COMMANDS["/g2invite"] =  guildtools.cmd_invite2

SLASH_COMMANDS["/g3invite"] =  guildtools.cmd_invite3

SLASH_COMMANDS["/g4invite"] =  guildtools.cmd_invite4

SLASH_COMMANDS["/g5invite"] =  guildtools.cmd_invite5


SLASH_COMMANDS["/gquit"] =  guildtools.cmd_leave

SLASH_COMMANDS["/gpromote"] =  guildtools.cmd_promote

SLASH_COMMANDS["/gdemote"] =  guildtools.cmd_demote

SLASH_COMMANDS["/gremove"] =  guildtools.cmd_remove

SLASH_COMMANDS["/gmail"] =  guildtools.cmd_mail



SLASH_COMMANDS["/gmotd"] =  function() guildtools.motd_chat(0) end
SLASH_COMMANDS["/gmotd1"] =  function() guildtools.motd_chat(1) end
SLASH_COMMANDS["/gmotd2"] =  function() guildtools.motd_chat(2) end
SLASH_COMMANDS["/gmotd3"] =  function() guildtools.motd_chat(3) end
SLASH_COMMANDS["/gmotd4"] =  function() guildtools.motd_chat(4) end
SLASH_COMMANDS["/gmotd4"] =  function() guildtools.motd_chat(5) end


guildtools.debug("Init Code Complete");
