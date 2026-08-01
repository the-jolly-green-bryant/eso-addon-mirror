function gsse.lang.sets.de()

	--- General Strings

	gsse.lang.core.addonName="Guild Store Search Extended";
    gsse.lang.core.coloredAddonName="|c2080D0Guild Store Search|r |cffffc0Extended|r";

	
	----Config------
	
	gsse.lang.config_filt_markdown_lbl="Reduzire preise um (%)"
	gsse.lang.config_filt_markdown_tip="Die Preisempfehlung f\195\188r ein kleineres Gebot wird um den hier konfigurierten Prozentwert reduziert."
	
	--- GUI -----------------
	
	gsse.lang.gui.reset_btn=string.format(gsse.lang.core.icon_template1,"/esoui/art/inventory/inventory_tabicon_junk_up.dds").."Zur\195\188cksetzen."
	gsse.lang.gui.rtrv_btn=string.format(gsse.lang.core.icon_template1,"/esoui/art/hud/radialicon_trade_up.dds").."Einlesen"
	gsse.lang.gui.find_btn=string.format(gsse.lang.core.icon_template1,"/esoui/art/lfg/lfg_tabicon_grouptools_up.dds").."Suchen"
	gsse.lang.gui.close_btn=string.format(gsse.lang.core.icon_template1,"/esoui/art/hud/radialicon_cancel_up.dds").."Schlie\195\159en"
	gsse.lang.gui.searchfor_lbl="Suche nach:"
	gsse.lang.gui.guild_lbl="In Gilde:"
	gsse.lang.gui.col_price_hdr="Gesamt"
	gsse.lang.gui.col_unit_hdr="St\195\188ck"
	
	gsse.lang.gui.main_cmd=string.format(gsse.lang.core.icon_template1,"/esoui/art/lfg/lfg_tabicon_grouptools_up.dds").."Guild Store Search"
	--- Dynamics
	
	gsse.lang.gui.res_label=gsse.lang.core.icon_template.." |cE0FFE0%s|r [|c%s%s|r]|cffff00 x %s|r" -- icon, guild no., color, name label, count
	gsse.lang.gui.res_price="%s"..gsse.lang.core.icon_gold -- money
	gsse.lang.gui.res_unitprice="%s"..gsse.lang.core.icon_gold -- money
	gsse.lang.gui.res_buy=gsse.lang.core.icon_gstorecoins.."Gehe zu"
	gsse.lang.gui.res_buy_off=gsse.lang.core.icon_gstoreold.."|ccc0000Alt|r" --added 0.06
	
	local working=string.format(gsse.lang.core.icon_template1,"/esoui/art/ava/ava_resourcestatus_tabicon_production.dds")
	local complete=string.format(gsse.lang.core.icon_template1,"/esoui/art/characterwindow/sigil_stamina.dds")
	
	gsse.lang.gui.searchpause="N\195\164chste Seite in %s Sekunden..."
	gsse.lang.gui.searchproc="Verarbeite Seite..."
	gsse.lang.gui.searchready="|c00ff00Bereit zum Suchen.|r"
	
	gsse.lang.gui.search=working.."Durchsuche Gilde |c00ffff%s|r, Seite |c00ffff%s|r" -- guild, page
	gsse.lang.gui.found=complete.."|c00ffff%s|r Gegenst\195\164nde in Gilde |c00ffff%s|r gefunden." -- items, guild
	gsse.lang.gui.retrv=working.."Lese Gilde |c00ffff%s|r, Seite |c00ffff%s|r ein." -- guild, page
	gsse.lang.gui.foundall=complete.."|c00ffff%s|r Gegenst\195\164nde in allen |c00ffffGilden|r gefunden." -- items
	gsse.lang.gui.searchStarte=working.."Beginne Suche..."
	gsse.lang.gui.searchBusy=working.."|cff0000Guild Store Search Ex ist gerade mit einer anderen Suche besch\195\164ftigt, bitte warten."
	gsse.lang.gui.searchNoGS=gsse.lang.core.icon_gstoreold.."|cff0000Der Gildenladen muss geöffnet sein um eingelesen zu werden.."
	
	
	gsse.lang.gui.noTradingGuilds="|cff0000Es gibt keine Gildenl\195\164den!|r"
	gsse.lang.gui.notATradingGuild="|cff0000Gilde %s besitzt keinen Gildenladen!|r"
	
	gsse.lang.gui.guild_all="|c00cc00Alle"
	gsse.lang.gui.guild_templ="G%s: %s%s" --Guild Num, color, Guild Name
	
	gsse.lang.gui.search_summ= "%s \195\156bereinstimmungen. St\195\188ckpreis (Max/Min/Avg/Unterbieten):|cff0000%s|r/|cff8000%s|r/|cfff000%s|r/|c00ff00%s|r%s" -- Max, Min, Avg, Undercut, Sell for price
	
	gsse.lang.gui.search_summsell=". Verkaufe |cff00ff%s|r @ |cffc000%sg.|r"
	
	-- Config
	gsse.lang.config.gen_dbg_lbl="Debug Modus?"
	gsse.lang.config.gen_dbg_tip="Zeige debug Meldungen?"
	gsse.lang.config.gen_dbg_warn="Hierdurch wird viel Text im Chatfenster ausgegeben!"
	
	gsse.lang.config.tooltip_hdr="Tooltips" --added 0.06
	gsse.lang.config.tooltip_desc="Diese Einstellungen konfigurieren, was in den Tooltips angezeit werden soll." --added 0.06
	gsse.lang.config.tooltip_session_lbl="Zusammenfassung der Spielsitzung?" --added 0.06
	gsse.lang.config.tooltip_session_tip="Wird diese Einstellung aktiviert, so wird eine Zusammenfassung der Verkaufsdaten der Gegenst\195\164nde aus dieser Spielsitzung angezeigt. Diese Daten werden auf die Gilden heruntergebrochen." --added 0.06
	gsse.lang.config.tooltip_history_lbl="Zusammenfassung der Historie?" --added 0.06
	gsse.lang.config.tooltip_history_tip="Wird diese Einstellung aktiviert, so wird eine Zusammenfassung der Verkaufsdaten der Gegenst\195\164nde aller Spielsitzungen und Charaktere angezeigt. Diese Daten werden auf die Gilden heruntergebrochen." --added 0.06
	gsse.lang.config.tooltip_recom_lbl="Empfehlungen?" --added 0.06
	gsse.lang.config.tooltip_recom_tip="Wird diese Einstellung aktiviert, wird eine Empfehlung angezeigt, wo und f\195\188r wie viel ein Gegenstand am besten zu Kaufenw oder Verkaufen w\195\164re." --added 0.06
	
	
	
	--- Tooltips
	
	gsse.lang.gui.tt_line= "%s: |cff0000%s"..gsse.lang.core.icon_gold.."|r/|cff8000%s"..gsse.lang.core.icon_gold.."|r/|cfff000%s"..gsse.lang.core.icon_gold.."|r/|c00ff00%s"..gsse.lang.core.icon_gold.."|r" -- guild, Max, Min, Avg, Undercut -added 0.06
	gsse.lang.gui.tt_key= "Legende: |cff0000Min|r/|cff8000Max|r/|cfff000Avg|r/|c00ff00Unterbieten|r" --added 0.06
	gsse.lang.gui.tt_all= "Alle" --added 0.06
	gsse.lang.gui.tt_NoHistory= "Keine Historie gefunden." --added 0.06
	gsse.lang.gui.tt_Sell= "|c00FFFFVerkaufe|r in |c008000%s|r f\195\188r |c00ff00%s|r"..gsse.lang.core.icon_gold.." [|cFF80FF%s|r] (|c00FFFF%s|r)"--added 0.06 - guild, price, qty, source
	gsse.lang.gui.tt_Buy= "|c00FFFFKaufe|r bei |c008000%s|r f\195\188r |c00ff00%s|r"..gsse.lang.core.icon_gold.." [|cFF80FF%s|r] (|c00FFFF%s|r)"--added 0.06 - guild, price, qty, source
	gsse.lang.gui.tt_sesstlt= "|c00FFFFDiese Spielsitzung" --added 0.06
	gsse.lang.gui.tt_histtlt= "|c00FFFFHistorie" --added 0.06
	gsse.lang.gui.tt_histshort="hist" --added 0.06
	gsse.lang.gui.tt_sessshort="sitz" --added 0.06
	gsse.lang.gui.tt_eachshort="st\195\188ck" --added 0.06
	
	
	gsse.lang.core.cmdHelp={}
	gsse.lang.core.cmdHelp[1]="GSSE Kommandozeile:" --added 0.06
	gsse.lang.core.cmdHelp[2]="  - /gsse show || /gsse on - Zeige das GSSE Fenster." --added 0.06
	gsse.lang.core.cmdHelp[3]="  - /gsse hide || /gsse off  - Verberge das GSSE Fenster." --added 0.06

end