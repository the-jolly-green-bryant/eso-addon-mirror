--Author      : LintyDruid
--Localisation Control

-- use English as the base
gsse.lang.sets.en()

function gsse.lang.Set(lang)
    local language ="en"

    if lang==nil or lang=="" or lang=="Auto" then
        language = GetCVar("language.2")
    elseif lang=="English" then
        language = "en"
    elseif lang=="Deutsch" then
        language = "de"
    elseif lang=="Français" then
        language = "fr"
    end

    if (language== nil or language=="en") then  -- No language or en
        gsse.lang.refresh()
        return;
    end

    if (language=="fr") then  -- fr
        gsse.lang.sets.fr()
        gsse.lang.refresh()
        return;
    end

    if (language=="de") then  -- de
        gsse.lang.sets.de()
        gsse.lang.refresh()
        return;
    end

    gsse.lang.refresh()
end

function gsse.lang.refresh()
    GuildStoreSearchExResetButton:SetText(gsse.lang.gui.reset_btn)
    GuildStoreSearchExRetrieveButton:SetText(gsse.lang.gui.rtrv_btn)
    GuildStoreSearchExFindMatchesButton:SetText(gsse.lang.gui.find_btn)
    GuildStoreSearchExCloseButton:SetText(gsse.lang.gui.close_btn)
    GuildStoreSearchExForLabel:SetText(gsse.lang.gui.searchfor_lbl)
    GuildStoreSearchExGuildLabel:SetText(gsse.lang.gui.guild_lbl)
    GuildStoreSearchExPriceHeader:SetText(gsse.lang.gui.col_price_hdr)
    GuildStoreSearchExUnitPriceHeader:SetText(gsse.lang.gui.col_unit_hdr)
end