OSI.special = { }

local ICONS_CUSTOM = {
    -- custom
    "odysupporticons/icons/donut.dds",
    "odysupporticons/icons/emoji-crazy.dds",
    "odysupporticons/icons/emoji-poop.dds",
    "odysupporticons/icons/green_arrow.dds",
    "odysupporticons/icons/lightning-bolt.dds",
    "odysupporticons/icons/pepe.dds",
    "odysupporticons/icons/trollface.dds",
    "odysupporticons/icons/wolf.dds",
    -- halloween
    "odysupporticons/icons/bat.dds",
    "odysupporticons/icons/casper.dds",
    "odysupporticons/icons/chuckie.dds",
    "odysupporticons/icons/count.dds",
    "odysupporticons/icons/dave.dds",
    "odysupporticons/icons/devil.dds",
    "odysupporticons/icons/diablo.dds",
    "odysupporticons/icons/dracula.dds",
    "odysupporticons/icons/et.dds",
    "odysupporticons/icons/fatso.dds",
    "odysupporticons/icons/fawkes.dds",
    "odysupporticons/icons/fester.dds",
    "odysupporticons/icons/frankenstein.dds",
    "odysupporticons/icons/freddie.dds",
    "odysupporticons/icons/ghostface.dds",
    "odysupporticons/icons/gomez.dds",
    "odysupporticons/icons/goomba.dds",
    "odysupporticons/icons/hannibal.dds",
    "odysupporticons/icons/harley.dds",
    "odysupporticons/icons/hellboy.dds",
    "odysupporticons/icons/jason.dds",
    "odysupporticons/icons/jigsaw.dds",
    "odysupporticons/icons/kokey.dds",
    "odysupporticons/icons/lantern.dds",
    "odysupporticons/icons/leatherface.dds",
    "odysupporticons/icons/marshmallow.dds",
    "odysupporticons/icons/miguel.dds",
    "odysupporticons/icons/mike.dds",
    "odysupporticons/icons/mummy.dds",
    "odysupporticons/icons/myers.dds",
    "odysupporticons/icons/oompa.dds",
    "odysupporticons/icons/paul.dds",
    "odysupporticons/icons/pennywise.dds",
    "odysupporticons/icons/pig.dds",
    "odysupporticons/icons/pinhead.dds",
    "odysupporticons/icons/reaper.dds",
    "odysupporticons/icons/sam.dds",
    "odysupporticons/icons/skellington.dds",
    "odysupporticons/icons/skull.dds",
    "odysupporticons/icons/slimer.dds",
    "odysupporticons/icons/spaulding.dds",
    "odysupporticons/icons/stuart.dds",
    "odysupporticons/icons/sulley.dds",
    "odysupporticons/icons/vampbat.dds",
    "odysupporticons/icons/vampire.dds",
    "odysupporticons/icons/witch.dds",
    "odysupporticons/icons/worms.dds",
    "odysupporticons/icons/zombie.dds",
    -- superheros
    "odysupporticons/icons/baronzemo.dds",
    "odysupporticons/icons/blackpanther.dds",
    "odysupporticons/icons/bullseye.dds",
    "odysupporticons/icons/captainamerica.dds",
    "odysupporticons/icons/captainbritain.dds",
    "odysupporticons/icons/cyclops.dds",
    "odysupporticons/icons/daredevil.dds",
    "odysupporticons/icons/deadpool.dds",
    "odysupporticons/icons/hawkeye.dds",
    "odysupporticons/icons/ironfist.dds",
    "odysupporticons/icons/ironman.dds",
    "odysupporticons/icons/redguardian.dds",
    "odysupporticons/icons/spiderman.dds",
    "odysupporticons/icons/vision.dds",
    "odysupporticons/icons/wolverine.dds",
    "odysupporticons/icons/xavier.dds",
}

-- exposed function to add custom icon packs
function OSI.AddCustomIconPack( iconPack )
    OSI.TableAppend( ICONS_CUSTOM, iconPack )
end

-- restore cached icons
function OSI.CacheRestoreIcons()
    local cache = OSI.GetOption( "cache" )
    if OSI.GetOption( "save" ) then
        for key, val in pairs( cache ) do
            if val then
                OSI.special[key] = val
            end
        end
    end
    OSI.RefreshData()
end

-- clear cached icons
function OSI.CacheClearIcons( all )
    if all then
        OSI.UpdateCache( nil )
        OSI.special = { }
    else
        for i = 1, GROUP_SIZE_MAX do
            local displayName = GetUnitDisplayName( "group" .. i )
            if displayName and displayName ~= "" then
                local name = string.lower( displayName )
                OSI.UpdateCache( name, nil )
                OSI.special[name] = nil
            end
        end
    end
    OSI.RefreshData()
end

function OSI.SetCustomIconForUnit( displayName, texture, color )
    OSI.special[displayName] = {
        ["texture"] = texture,
        ["color"]   = color,
    }
    OSI.RefreshData()
    -- store custom icon
    if OSI.GetOption( "save" ) then
        OSI.UpdateCache( displayName, OSI.special[displayName] )
    end
end

function OSI.RemoveCustomIconFromUnit( displayName )
    OSI.special[displayName] = nil
    OSI.RefreshData()
    -- remove custom icon from store
    if OSI.GetOption( "save" ) then
        OSI.UpdateCache( displayName, nil )
    end
end

function OSI.ChooseCustomIconForUnit( displayName )
    -- assign icon set
    OSI.pickicon:UpdateChoices( ICONS_CUSTOM, { } )
    OSI.pickicon.data.choices = ICONS_CUSTOM

    OSI.custom.raidlead    = false
    OSI.custom.displayName = displayName

    if OSI.special[displayName] then
        OSI.custom.texture = OSI.special[displayName].texture or ICONS_CUSTOM[1]
    else
        OSI.custom.texture = ICONS_CUSTOM[1]
    end

    OSI.picklabel:SetText( "|cffff00ICON FOR " .. string.upper( displayName ) .. "|r" )
    OSI.pickicon.icon:SetTexture( OSI.custom.texture )
    OSI.pick:SetHidden( false )
end
