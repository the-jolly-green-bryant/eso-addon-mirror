function guildtools.lang.sets.en()

	--- General Strings

	guildtools.lang.core.addonName="GuildTools";
	
	guildtools.lang.core.defaultAdvert="{guildname} are a friendly guild, looking for new members. pst {player} for invite or info."

	guildtools.lang.core.noGuild="You do not belong to any guilds!"
	
	
	guildtools.lang.core.noGuildSelected="You have no guild selected."
	guildtools.lang.core.noGuildSelectedShort="No Guild"
	guildtools.lang.core.activeGuildStub = "Active Guild: "
	
	guildtools.lang.core.guildInfoTemplate="|cFF8000MOTD|r"..string.char(13,10).."%s" --MOTD
	
	--- Mail
	
	guildtools.lang.core.mail_noSubject="Guild Mail: There is no subject!"
	guildtools.lang.core.mail_noMessage="Guild Mail: There is no message!"
	
	guildtools.lang.core.mail_msgTitle="Guild Mail has created message:"
	guildtools.lang.core.mail_msgSubj=" - Subject: |cff00ff%s|r" -- Subject
	guildtools.lang.core.mail_msgMess=" - Message: |c80FFC0%s|r" -- Message
	guildtools.lang.core.mail_msgInstr="Guild Mail message prepared. Type |cFF8000'/gmail send'|r to send."
	
	guildtools.lang.core.mail_msgGuildIdMissing="Guild does not exist!"
	
	guildtools.lang.core.mail_msgRecpt=" - Mail recipients are |cff8000%s" -- Recipient ranks
	guildtools.lang.core.mail_msgSendStart="|cFFC0C0Guild Mail is adding messages to the send queue."
	guildtools.lang.core.mail_msgSendSumm=" - |cff8000%s|r messages added to the queue." -- message count
	guildtools.lang.core.mail_msgSendState=" - There are |c30C0FF%s|r messages in the queue. It will take |c30C0FF%s|r minutes to send." -- Message Count, Time (minutes)
	
	guildtools.lang.core.mail_msgClear="Guild Mail: All messages deleted."
	
	
	guildtools.lang.core.mail_msgPause = "Pausing guild e-mail send for %s minutes to allow system to catch up.  There are %s more to send." -- added 02/05
	guildtools.lang.core.mail_msgPauseOff = "Resuming guild mail send.  There are %s more to send." -- added 02/05
	guildtools.lang.core.mail_pauselbl="|cff0000Paused.|r"-- added 02/05
	
	guildtools.lang.core.mail_tooltipA="Send the message below to\n - all |cff0000guild members|r;\n     -or-\n - all |c008000guild officers|r. \n\nThis will only send the subject and message.  No attachments or gold will be sent. \n\nMessages will only be sent whilst this send window is open. If it is closed sending of messaged will be paused."
	guildtools.lang.core.mail_tooltipB="Messages will be send to |cff8000%s|r" -- Guild name
	---  Messages
	
	guildtools.lang.core.msg_gm_left="%s : Guild member: |c008000%s |cff0000Left|r " -- guild name / player name
	guildtools.lang.core.msg_gm_new="%s : |c00ffffNew|r guild member: |c008000%s"  -- guild name / player name
	guildtools.lang.core.msg_gm_rejoin="%s : Guild member: |c008000%s |c00ffffRejoined|r "  -- guild name / player name
	guildtools.lang.core.msg_gm_notechange="%s : Guild |c00ffffnote|r for |c008000%s|r has change to '|c00ffff%s|r'"  -- guild name / player name / note
	guildtools.lang.core.msg_gm_rankchange="%s : Guild |c00ffffrank|r for |c008000%s|r has changed." -- guild name / player name
	
	guildtools.lang.core.msg_gm_levelchange="|c00ff00[%s(|c00ffff%s|c00ff00)] has got to level |c00ffff%s|c00ff00 in the |c00ffff%s" -- account name/ player name/level/Guild Name
	
	
	guildtools.lang.core.msg_gm_statuschange="|c00ffff[%s]|c00ff00 in the |c00ffff%s|r %s" -- player name / guild name / status
	guildtools.lang.core.msg_gm_statusaway="|cFFC000is away|r"
	guildtools.lang.core.msg_gm_statusDND="|cff0000should not be disturbed|r"
	guildtools.lang.core.msg_gm_statusoffline="|cff00ffis offline|r"
	guildtools.lang.core.msg_gm_statusonline="|c008000is online|r"
	guildtools.lang.core.msg_gm_statusunknown="|cffff00not sure :)|r"
	
	
	guildtools.lang.core.msg_gkeep_lost="%s : |cff0000Guild keep lost." -- guild name
	guildtools.lang.core.msg_gkeep_change="%s : |cff0000Guild keep changed." -- guild name
	
	guildtools.lang.core.motd="|c00FF00 MOTD for %s..." -- guild name
	
	guildtools.lang.core.motdchat="|c00FF00 MOTD: |cFFFF00" -- added 03/05
	
	guildtools.lang.core.msg_invite="Invited <%s> to the <%s> guild." -- player name / guild name
	guildtools.lang.core.msg_autoinvite="<%s> requested an invite to guild." -- player name 
	
	guildtools.lang.core.msg_left_guild="Left <%s> guild." -- guild name
	
	guildtools.lang.core.msg_promoted="Promoted <%s> in the <%s> guild." -- player name / guild name
	guildtools.lang.core.msg_demoted="Demoted <%s> in the <%s> guild." -- player name / guild name
	guildtools.lang.core.msg_removed="Removed <%s> from the <%s> guild." -- player name / guild name
	
	
	
	
	
	--Status Display
	
	guildtools.lang.core.status_noGuild="No Guild"
	
	-- Command Lines
	guildtools.lang.core.cmdHelp={}
	guildtools.lang.core.cmdHelp[1]="Guild Tools command lines:"
	guildtools.lang.core.cmdHelp[2]="  - /gt - show this message"
	guildtools.lang.core.cmdHelp[3]="  - /gt ga || /adv || /ga - place guild advert in chat box - press [enter] again to send"
	guildtools.lang.core.cmdHelp[4]="  - /gt ga list || /adv list || /ga list - list guild adverts"
	guildtools.lang.core.cmdHelp[5]="  - /ginvite <player> - invite player to the active guild"
	guildtools.lang.core.cmdHelp[6]="  - /g1invite -> /g5invite <player> - invite player to the specific guild"
	guildtools.lang.core.cmdHelp[7]="    |cff8000** if <player> if missing from an guild invite command the name of the last person who whispered you will be used **|r"
	guildtools.lang.core.cmdHelp[8]="  - /gpromote <player> - promote a player within the active guild"
	guildtools.lang.core.cmdHelp[9]="  - /gdemote <player> - demote the player within the active guild"
	guildtools.lang.core.cmdHelp[10]="  - /gquit - Quit the active guild"
	guildtools.lang.core.cmdHelp[11]="  - /gremove <player> - remove the player from the active guild"
	guildtools.lang.core.cmdHelp[12]="  - /gm <message> - send a message to the active guild  - press [enter] again to send"
	guildtools.lang.core.cmdHelp[13]="  - /gt debug on/off - switch debug on/off"
	guildtools.lang.core.cmdHelp[14]="  |c00ff00Adverts can by changed in the ESO setting menu."
	
	guildtools.lang.core.cmdMailHelp={}
	guildtools.lang.core.cmdMailHelp[1]="Guild Tools Mail command lines:"
	guildtools.lang.core.cmdMailHelp[2]="  - /gmail send - send message"
	guildtools.lang.core.cmdMailHelp[3]="  - /gmail status - Status of message send queue"
	guildtools.lang.core.cmdMailHelp[4]="  - /gmail clear - remove all pending messages in the queue"
	guildtools.lang.core.cmdMailHelp[5]="  - /gmail - show this message"
	
	
	guildtools.lang.core.cmdHelp_activeguild="  |cff00ff** Active Guild is <%s> **|r" -- guild name
	
	
	guildtools.lang.core.cmd_advertlist="guildtools --> |c00ff00List Adverts for <%s>|r..."  -- guild name
	
	-- Configuration UI
	guildtools.lang.config.alertLabels={"None","In Chat","In HUD", "In HUD and Chat"}
	guildtools.lang.config.alertValues={["None"]=0,["In Chat"]=1,["In HUD"]=2, ["In HUD and Chat"]=3}
	
	
	guildtools.lang.config.gen_hdr="General Settings"
	
	guildtools.lang.config.gen_dbg_lbl="Debug Mode?"
	guildtools.lang.config.gen_dbg_tip="Display debug messages?"
	guildtools.lang.config.gen_dbg_warn="This will place lots of text in your chat window!"
	
	guildtools.lang.config.gen_widget_lbl="Status Widget"
	guildtools.lang.config.gen_widget_tip="Display the in game status widget?"
	
	guildtools.lang.config.gen_widgetlock_lbl="Status Widget Lock"
	guildtools.lang.config.gen_widgetlock_tip="Lock the in game status widget?"
	
	guildtools.lang.config.msgs_hdr="Alerts and Messages"
	
	guildtools.lang.config.gen_motd_lbl="Show guild messages of the day."
	guildtools.lang.config.gen_motd_tip="Display guild MOTD's when you first login and when they are changed by the guild."
	
	
	
	
	guildtools.lang.config.gen_galert_lbl="  - Show alerts?"
	guildtools.lang.config.gen_gmotd_lbl=" - Show guild messages of the day?" -- Added 05/02
	guildtools.lang.config.gen_gmotd_tip="Display guild MOTD when you first login and when they are changed by the guild." -- Added 05/02
	guildtools.lang.config.gen_glevel_lbl=" - Show alert when player levels?" -- Added 05/02
	guildtools.lang.config.gen_glevel_tip="" -- Added 05/02
	guildtools.lang.config.gen_gstatus_lbl=" - Show player status changes?" -- Added 05/02
	guildtools.lang.config.gen_gstatus_tip="An alert will be shown if a player comes on-line or off-line or sets their status to DND, etc." -- Added 05/02
	guildtools.lang.config.gen_gstate_lbl=" - Show guild player changes?" -- Added 05/02
	guildtools.lang.config.gen_gstate_tip="Alert when players leave, join, change their note, get promoted, etc." -- Added 05/02
	
	
	guildtools.lang.config.advert_hdr="Guild Adverts"
	
	guildtools.lang.config.advert_desc="The currently selected guild is <|c00ff00%s|r>. All setting in this section will apply to this guild." -- guild name
	
	guildtools.lang.config.advert_instr="Guild advert text.  Use {guildname} for the guild name and {player} for you character name."
	
	guildtools.lang.config.advert_lbl="Advert #%s" -- Advert No.
	
	guildtools.lang.config.advert_desc_none="There is currently |cff0000NO|r guild selected. These settings will not have any affect."
	
	guildtools.lang.config.gen_motd_lbl=" - Show guild messages of the day?" -- Added 05/02
	
	guildtools.lang.config.advert_desc_autoinv="The box below can be used to define specific text that a player should whisper to you for auto invitation to the guild."
	guildtools.lang.config.advert_autoinv_lbl="Auto invite when whisper contains"
	guildtools.lang.config.advert_autoinv_instr="This is not case sensitive."
	
	guildtools.lang.config.gen_galert_none="|caaaaaa<No Guild>|r"
	
	guildtools.lang.config.mail_hdr="Guild Mail"
	
	guildtools.lang.config.mail_desc="The settings below control how guild mail will work." -- guild name
	
	guildtools.lang.config.mail_autosend_lbl="Automatically send mails"
	
	guildtools.lang.config.mail_autosend_tip="Automatically send mails when the send buttons are clicked in the mail composition window."
	
	guildtools.lang.config.mail_autosend_warn="If this setting is on.  You cannot review the list of guild roles that will receive the message."
	
	guildtools.lang.config_hudspeeed_lbl="HUD Message show for (secs)"
	guildtools.lang.config_hudspeeed_tip="The number of seconds messages will show for."
	guildtools.lang.config_hudspeeed_warn="With higher time settings, if there are a lot of cached messages it can be distracting.  Also this will affect bow fast the HUD is unlocked."
	
	--Icons
	
	guildtools.lang.core.icon_alert="/esoui/art/campaign/campaign_tabicon_history_down.dds"
	
	--Key Binding Labels
	
	
end

ZO_CreateStringId("SI_BINDING_NAME_GUILDTOOLS_ADVERT", "Send guild advert")
ZO_CreateStringId("SI_BINDING_NAME_GUILDTOOLS_LASTGUILD", "Set previous guild as active")
ZO_CreateStringId("SI_BINDING_NAME_GUILDTOOLS_NEXTGUILD", "Set next guild as active")


