function guildtools.lang.sets.fr()
	--- General Strings

	guildtools.lang.core.addonName="GuildTools";
	
	guildtools.lang.core.defaultAdvert="{guildname} nous sommes une guilde active, a la recherche de nouveaux membres. pm {player} pour plus d'info ou invite ."

	guildtools.lang.core.noGuild="Vous n'appartenez a aucune guilde!"
	
	
	guildtools.lang.core.noGuildSelected="Vous n'avez pas de guilde selectionnee."
	guildtools.lang.core.noGuildSelectedShort="Pas de Guilde"
	guildtools.lang.core.activeGuildStub = "Guilde active: "
	
	guildtools.lang.core.guildInfoTemplate="|cFF8000MOTD|r"..string.char(13,10).."%s" --MOTD
	
	--- Mail
	
	guildtools.lang.core.mail_noSubject="Guilde Mail: Il n'ya pas de sujet!"
	guildtools.lang.core.mail_noMessage="Guilde Mail: Il n'ya pas de message!"
	
	guildtools.lang.core.mail_msgTitle="Guilde Mail a cree un message:"
	guildtools.lang.core.mail_msgSubj=" - Sujet: |cff00ff%s|r" -- Subject
	guildtools.lang.core.mail_msgMess=" - Message: |c80FFC0%s|r" -- Message
	guildtools.lang.core.mail_msgInstr="Guilde Mail: Message pret. Tapez |cFF8000'/gmail send'|r pour envoyer."
	
	guildtools.lang.core.mail_msgGuildIdMissing="La guilde n'existe pas!"
	
	guildtools.lang.core.mail_msgRecpt=" - Destinataires de courrier sont |cff8000%s" -- Recipient ranks
	guildtools.lang.core.mail_msgSendStart="|cFFC0C0Guild Mise en place des messages a la file d'attente."
	guildtools.lang.core.mail_msgSendSumm=" - |cff8000%s|r messages ajoute a la file d'attente." -- message count
	guildtools.lang.core.mail_msgSendState=" - Il y a |c30C0FF%s|r messages en attente d'envois. Cela va prendre |c30C0FF%s|r minutes pour envoyer." -- Message Count, Time (minutes)
	
	guildtools.lang.core.mail_msgClear="Guilde Mail: Tous les messages sont supprime."
	
	
	guildtools.lang.core.mail_tooltipA="Envoyer le message ci-dessous a\n - tous les |cff0000membres|r;\n     -ou-\n - tous les |c008000Officiers|r. \n\nCela va seulment envoyer le sujet et le message.  Les pieces jointes ou l'or ne sera pas envoyes. \n\nLes messages seront envoyes uniquement quand la fenetre d'envois est ouverte. Si la fenetre d'envois est ferme les envois se mettent en pause."
	guildtools.lang.core.mail_tooltipB="Les messages seront envoyes a |cff8000%s|r" -- Guild name
	---  Messages
	
	guildtools.lang.core.msg_gm_left="%s : Membre de Guilde: |c008000%s |cff0000Left|r " -- guild name / player name
	guildtools.lang.core.msg_gm_new="%s : |c00ffffNew|r membre de guilde: |c008000%s"  -- guild name / player name
	guildtools.lang.core.msg_gm_rejoin="%s : Membre de guilde: |c008000%s |c00ffffRevenue|r "  -- guild name / player name
	guildtools.lang.core.msg_gm_notechange="%s : Guilde |c00ffffnote|r pour |c008000%s|r a change en '|c00ffff%s|r'"  -- guild name / player name / note
	guildtools.lang.core.msg_gm_rankchange="%s : Guilde |c00ffffrang|r pour |c008000%s|r a change." -- guild name / player name
	
	guildtools.lang.core.msg_gm_levelchange="|c00ff00[%s(|c00ffff%s|c00ff00)] a obtenu un niveau |c00ffff%s|c00ff00 en |c00ffff%s" -- account name/ player name/level/Guild Name
	
	
	guildtools.lang.core.msg_gm_statuschange="|c00ffff[%s]|c00ff00 en |c00ffff%s|r %s" -- player name / guild name / status
	guildtools.lang.core.msg_gm_statusaway="|cFFC000est absent|r"
	guildtools.lang.core.msg_gm_statusDND="|cff0000ne devrait pas être derange|r"
	guildtools.lang.core.msg_gm_statusoffline="|cff00ffest hors ligne|r"
	guildtools.lang.core.msg_gm_statusonline="|c008000est en ligne|r"
	guildtools.lang.core.msg_gm_statusunknown="|cffff00pas sûr :)|r"
	
	
	guildtools.lang.core.msg_gkeep_lost="%s : |cff0000Guild keep lost." -- guild name
	guildtools.lang.core.msg_gkeep_change="%s : |cff0000Guild keep changed." -- guild name
	
	guildtools.lang.core.motd="|c00FF00 MOTD for %s..." -- guild name
	
	guildtools.lang.core.msg_invite="invite <%s> dans la <%s> guilde." -- player name / guild name
	guildtools.lang.core.msg_autoinvite="<%s> a demande une invitation." -- player name 
	
	guildtools.lang.core.msg_left_guild="Viens de quitter <%s> la guilde." -- guild name
	
	guildtools.lang.core.msg_promoted="Promu <%s> dans la <%s> guilde." -- player name / guild name
	guildtools.lang.core.msg_demoted="Retrograde <%s> dans la <%s> guilde." -- player name / guild name
	guildtools.lang.core.msg_removed="Renvoye <%s> de la <%s> guilde." -- player name / guild name
	
	
	
	
	
	--Status Display
	
	guildtools.lang.core.status_noGuild="Pas de Guilde"
	
	-- Command Lines
	guildtools.lang.core.cmdHelp={}
	guildtools.lang.core.cmdHelp[1]="Guild Tools les lignes de commande: (en FR pas de caracters speciaux)"
	guildtools.lang.core.cmdHelp[2]="  - /gt - affiche ce message"
	guildtools.lang.core.cmdHelp[3]="  - /gt ga || /adv || /ga - Place annonce de guilde dans chat - appuyez sur [ENTER] encore une fois pour envoyer"
	guildtools.lang.core.cmdHelp[4]="  - /gt ga list || /adv list || /ga list - Liste des annonces"
	guildtools.lang.core.cmdHelp[5]="  - /ginvite <player> - Invite joueur dans la guilde selectionne"
	guildtools.lang.core.cmdHelp[6]="  - /g1invite -> /g5invite <player> - Invite joueur dans une guilde specifique"
	guildtools.lang.core.cmdHelp[7]="    |cff8000** Si <player> n'est pas indique dans la commande d'invite, le nom de la derniere personne qui vous a chuchote sera utilise **|r"
	guildtools.lang.core.cmdHelp[8]="  - /gpromote <player> - promouvoir un joueur dans la guilde selectionne"
	guildtools.lang.core.cmdHelp[9]="  - /gdemote <player> - degrader un joueur dans la guilde selectionne"
	guildtools.lang.core.cmdHelp[10]="  - /gquit - Quiter la guilde selectionne"
	guildtools.lang.core.cmdHelp[11]="  - /gremove <player> - retire un joueur depuis la guilde selectionne"
	guildtools.lang.core.cmdHelp[12]="  - /gm <message> - Envois un message dans la guilde selectionne  - appuyez sur [ENTER] encore une fois pour envoyer"
	guildtools.lang.core.cmdHelp[13]="  - /gt debug on/off - debuggage active/desactive"
	guildtools.lang.core.cmdHelp[14]="  |c00ff00Annonces peuvent etre change dans les parametres d jeu."
	
	guildtools.lang.core.cmdMailHelp={}
	guildtools.lang.core.cmdMailHelp[1]="Guild Tools Mail lignes de commande:"
	guildtools.lang.core.cmdMailHelp[2]="  - /gmail send - envois un message"
	guildtools.lang.core.cmdMailHelp[3]="  - /gmail status - etat des messages dans la file d'attente"
	guildtools.lang.core.cmdMailHelp[4]="  - /gmail clear - retire tous les messages place dans la file d'attente"
	guildtools.lang.core.cmdMailHelp[5]="  - /gmail - affiche le message"
	
	
	guildtools.lang.core.cmdHelp_activeguild="  |cff00ff** La guilde active est <%s> **|r" -- guild name
	
	
	guildtools.lang.core.cmd_advertlist="guildtools --> |c00ff00Liste des annonces pour <%s>|r..."  -- guild name
	
	-- Configuration UI
	guildtools.lang.config.alertLabels={"None","Dans Chat","Dans HUD", "Dans HUD et Chat"}
	guildtools.lang.config.alertValues={["None"]=0,["Dans Chat"]=1,["Dans HUD"]=2, ["Dans HUD et Chat"]=3}
	
	
	guildtools.lang.config.gen_hdr="General Settings"
	
	guildtools.lang.config.gen_dbg_lbl="Debug Mode?"
	guildtools.lang.config.gen_dbg_tip="Afficher les messages de debuggage?"
	guildtools.lang.config.gen_dbg_warn="Cela va placer beaucoup de texte dans le chat attention !"
	
	guildtools.lang.config.gen_widget_lbl="Widget d'etat"
	guildtools.lang.config.gen_widget_tip="Afficher le widget d'etat dans le jeu?"
	
	guildtools.lang.config.gen_widgetlock_lbl="Verouillage de widget"
	guildtools.lang.config.gen_widgetlock_tip="Verouiller le widget d'etat?"
	
	guildtools.lang.config.msgs_hdr="Messages et Alertes"
	
	guildtools.lang.config.gen_motd_lbl="Afficher le message du jour de guilde."
	guildtools.lang.config.gen_motd_tip="Afficher le MDJ lors de la premiere connexion et quand il est modifie par la guilde."
	
	guildtools.lang.config.gen_galert_lbl="  - Afficher les alertes?"
	
	guildtools.lang.config.advert_hdr="Annonces"
	
	guildtools.lang.config.advert_desc="Guilde selectionne <|c00ff00%s|r>. All setting in this section will apply to this guild." -- guild name
	
	guildtools.lang.config.advert_instr="Texte d'annonce.  Utilisez {guildname} pour nom de guilde et {player} pour votre pseudo."
	
	guildtools.lang.config.advert_lbl="Annonce #%s" -- Advert No.
	
	guildtools.lang.config.advert_desc_none="Il y a actuellement |cff0000NO|r guildes selectionne. Ces parametres n'ont aucun effet."
	
	guildtools.lang.config.advert_desc_autoinv="Ici vous pouvez definir un texte specifique que le joueur doit vous chuchoter pour l'invitation automatique dans la guilde."
	guildtools.lang.config.advert_autoinv_lbl="Inviter automatiquement quand message prive contient"
	guildtools.lang.config.advert_autoinv_instr="Ce n'est pas une case sensible"
	
	guildtools.lang.config.gen_galert_none="|caaaaaa<Pas de Guilde>|r"
	
	guildtools.lang.config.mail_hdr="Guilde Mail"
	
	guildtools.lang.config.mail_desc="Les parametres ci-dessous controlent le fonctionnement du courrier de guilde." -- guild name
	
	guildtools.lang.config.mail_autosend_lbl="Auto-envois"
	
	guildtools.lang.config.mail_autosend_tip="Envois automatiquement les messages lors du click sur le bouton d'envoi dans la fenetre de composition du courrier."
	
	guildtools.lang.config.mail_autosend_warn="Si ce parametre est active. Vous ne pouvez pas consulter la liste des rangs de guilde qui recevront le message."
	
	guildtools.lang.config_hudspeeed_lbl="HUD Affichage des messages(en sec)"
	guildtools.lang.config_hudspeeed_tip="Le temps d'affichage de message (en sec)"
	guildtools.lang.config_hudspeeed_warn="Avec le reglage de temps plus eleve, si il y a beaucoup de messages mis en cache, cela peut cree des ralentissements. Cela affect egalement la vitesse de deverouillage d'interface."
	
	--Icons
	
	guildtools.lang.core.icon_alert="/esoui/art/campaign/campaign_tabicon_history_down.dds"
	
	--Key Binding Labels
	-- 05/02
guildtools.lang.config.gen_gmotd_lbl=" - Afficher le message du jour de guilde?" -- Added 05/02
guildtools.lang.config.gen_gmotd_tip="Afficher le MDJ lors de la premiere connexion et quand il est modifie par la guilde." -- Added 05/02
guildtools.lang.config.gen_glevel_lbl=" - Affiche une alerte quand un joeur augment le niveau?" -- Added 05/02
guildtools.lang.config.gen_glevel_tip="" -- Added 05/02
guildtools.lang.config.gen_gstatus_lbl=" - Afficher le changement d'etat des joueurs ?" -- Added 05/02
guildtools.lang.config.gen_gstatus_tip="An alert will be shown if a player comes on-line or off-line or sets their status to DND, etc." -- Added 05/02
guildtools.lang.config.gen_gstate_lbl=" - Afficher les changements de joueurs dans la guilde?" -- Added 05/02
guildtools.lang.config.gen_gstate_tip="Affiche une alerte quand les joueurs quittent, rejoignent, changent leurs notes, ou sont promu, etc." -- Added 05/02
guildtools.lang.config.gen_motd_lbl=" - Afficher le message du jour de guilde ?" -- Added 05/02
	
end