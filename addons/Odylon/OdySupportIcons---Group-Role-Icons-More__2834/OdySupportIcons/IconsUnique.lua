OSI.users = {
    -- schmeggd
    ["@blacksmoker"]        = "odysupporticons/icons/schmeggd/blacksmoker.dds",
    ["@dopeysmurf"]         = "odysupporticons/icons/schmeggd/dopeysmurf.dds",
    ["@käpt'n_iglo"]        = "odysupporticons/icons/schmeggd/kaeptniglo.dds",
    ["@shdw_fx"]            = "odysupporticons/icons/schmeggd/shdwfx.dds",
    ["@rhoencador"]         = "odysupporticons/icons/schmeggd/encador.dds",
    --["@sevensinsger"]       = "odysupporticons/icons/schmeggd/sevensins.dds",  --removed as requrested by player
    ["@ecbrain"]            = "odysupporticons/icons/schmeggd/ecbrain.dds",
    ["@teias"]              = "odysupporticons/icons/schmeggd/teias.dds",
    ["@grafcadoroc"]        = "odysupporticons/icons/schmeggd/grafcadoroc.dds",
    ["@jonnykreng"]         = "odysupporticons/icons/schmeggd/jonnykreng.dds",
    ["@wookie_n1"]          = "odysupporticons/icons/schmeggd/wookie.dds",
    ["@blink8027"]          = "odysupporticons/icons/schmeggd/blink.dds",
    ["@flozilla"]           = "odysupporticons/icons/schmeggd/flozilla.dds",
    -- twp
    ["@ebenerz-krieger"]    = "odysupporticons/icons/twp/ebenerz-krieger.dds",
    ["@Chay'Kashet"]             = "odysupporticons/icons/twp/chayen.dds",
    ["@pelikito"]           = "odysupporticons/icons/twp/pelikito.dds",
    ["@shadowshintaro"]     = "odysupporticons/icons/twp/shadowshintaro.dds",
    ["@zom_head"]           = "odysupporticons/icons/twp/zom_head.dds",
    ["@marcelovski"]        = "odysupporticons/icons/twp/marcelovski.dds",
    ["@lamierina7"]         = "odysupporticons/icons/twp/lamierina7.dds",
    ["@exoy94"]             = "odysupporticons/icons/twp/exoy94.dds",
    ["@czekoludek"]         = "odysupporticons/icons/twp/czekoludek.dds",
    -- misc
    ["@delava"]             = "odysupporticons/icons/misc/delava.dds",
    ["@mandroin"]           = "odysupporticons/icons/misc/mandroin.dds",
    ["@reen_84"]            = "odysupporticons/icons/misc/reen_84.dds",
    ["@targets"]            = "odysupporticons/icons/misc/targets.dds",
    ["@renegadevalor"]      = "odysupporticons/icons/misc/renegadevalor.dds",
    ["@razor78"]            = "odysupporticons/icons/misc/razor78.dds",
    ["@v3n0m78"]            = "odysupporticons/icons/misc/v3n0m78.dds",
    ["@mischalicious"]      = "odysupporticons/icons/misc/mischalicious.dds",
    ["@offi1n3"]            = "odysupporticons/icons/misc/offi1n3.dds",
    ["@vespersplea"]        = "odysupporticons/icons/misc/vespersplea.dds",
    ["@yoga'n"]             = "odysupporticons/icons/misc/yoga.dds",
}

-- exposed function to add unique icon packs
function OSI.AddUniqueIconPack( iconPack )
    for player, icon in pairs( iconPack ) do
        OSI.users[string.lower( player )] = icon
    end
end
