function gsse.lang.sets.fr()
	gsse.lang.core.icon_gold=string.format(gsse.lang.core.icon_template,"EsoUI/Art/currency/currency_gold.dds")
	gsse.lang.core.icon_gstorecoins=string.format(gsse.lang.core.icon_template,"/esoui/art/guild/guild_tradinghouseaccess.dds")
	

	--- General Strings

	gsse.lang.core.addonName="Guild Store Search Extended";
    gsse.lang.core.coloredAddonName="|c2080D0Guild Store Search|r |cffffc0Extended|r";

	
	----Config------
	
	gsse.lang.config_filt_markdown_lbl="Articles en promotion(%)"
	gsse.lang.config_filt_markdown_tip="Les prix conseillés seront reduits par ce pourcentage fixe."
	
	--- GUI -----------------
	
	gsse.lang.gui.reset_btn=string.format(gsse.lang.core.icon_template1,"/esoui/art/inventory/inventory_tabicon_junk_up.dds").."Reinitialiser"
	gsse.lang.gui.rtrv_btn=string.format(gsse.lang.core.icon_template1,"/esoui/art/hud/radialicon_trade_up.dds").."Scanner"
	gsse.lang.gui.find_btn=string.format(gsse.lang.core.icon_template1,"/esoui/art/lfg/lfg_tabicon_grouptools_up.dds").."Rechercher"
	gsse.lang.gui.close_btn=string.format(gsse.lang.core.icon_template1,"/esoui/art/hud/radialicon_cancel_up.dds").."Fermer"
	gsse.lang.gui.searchfor_lbl="Mot clef:"
	gsse.lang.gui.guild_lbl="Guilde:"
	gsse.lang.gui.col_price_hdr="Total"
	gsse.lang.gui.col_unit_hdr="Unique"
	
	gsse.lang.gui.main_cmd=string.format(gsse.lang.core.icon_template1,"/esoui/art/lfg/lfg_tabicon_grouptools_up.dds").."Guild Store Search"
	--- Dynamics
	
	gsse.lang.gui.res_label=gsse.lang.core.icon_template.." |cE0FFE0%s|r [|c%s%s|r]|cffff00 x %s|r" -- icon, guild no., color, name label, count
	gsse.lang.gui.res_price="%s"..gsse.lang.core.icon_gold -- money
	gsse.lang.gui.res_unitprice="%s"..gsse.lang.core.icon_gold -- money
	gsse.lang.gui.res_buy=gsse.lang.core.icon_gstorecoins.."Afficher"
	
	local working=string.format(gsse.lang.core.icon_template1,"/esoui/art/ava/ava_resourcestatus_tabicon_production.dds")
	local complete=string.format(gsse.lang.core.icon_template1,"/esoui/art/characterwindow/sigil_stamina.dds")
	
	gsse.lang.gui.searchpause="Page suivante dans %s secondes..."
	gsse.lang.gui.searchproc="Traitement..."
	gsse.lang.gui.searchready="|c00ff00Pret pour recherche.|r"
	
	gsse.lang.gui.search=working.."Recherche Guilde |c00ffff%s|r, page |c00ffff%s|r" -- guild, page
	gsse.lang.gui.found=complete.."Résultat: |c00ffff%s|r objets de la Guilde |c00ffff%s|r" -- items, guild
	gsse.lang.gui.retrv=working.."Scan de la Guilde |c00ffff%s|r, page |c00ffff%s|r" -- guild, page
	gsse.lang.gui.foundall=complete.."Resultat: |c00ffff%s|r objets |c00ffffau total|r " -- items
	gsse.lang.gui.searchStarte=working.."Debut de la recherche..."
	gsse.lang.gui.searchBusy=working.."|cff0000Guild Store Search Ex est occupé, attendez"
	
	
	gsse.lang.gui.noTradingGuilds="|cff0000Il n'y a pas de boutique de guilde!|r"
	gsse.lang.gui.notATradingGuild="|cff0000Guilde %s n'a pas de boutique.|r"
	
	gsse.lang.gui.guild_all="|c00cc00All"
	gsse.lang.gui.guild_templ="G%s: %s%s" --Guild Num, color, Guild Name
	
	gsse.lang.gui.search_summ= "%s résultat. prix unique (Max/Min/Moy/Réduit):|cff0000%s|r/|cff8000%s|r/|cfff000%s|r/|c00ff00%s|r%s" -- Max, Min, Avg, Undercut, Sell for price
	
	
	gsse.lang.gui.search_summsell=". Sell |cff00ff%s|r @ |cffc000%sg.|r"
	
	
	gsse.lang.config.gen_dbg_lbl="Debug Mode?"
	gsse.lang.config.gen_dbg_tip="Afficher les messages de débogage?"
	gsse.lang.config.gen_dbg_warn="Cela va afficher beaucoup de texte dans votre fenêtre de chat!"	
end
