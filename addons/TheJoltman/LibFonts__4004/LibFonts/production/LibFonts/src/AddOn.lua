--------------------------------------------------------------------------------------------------------------------------------------------------------------------
LibFonts = {}

LibFonts.AddName = "LibFonts"
LibFonts.AddId = "LibFonts"
LibFonts.Version = 10000
LibFonts.Author = "TheJoltman"
LibFonts.PanelTitle = "LibFonts"
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
if LibDebugLogger then

    LibFonts.Logger = LibDebugLogger("LibFonts")
    LibFonts.Logger:Debug("Initializing "..LibFonts.AddName.."...")

else

    d("Error loading LibDebugLogger!")

end

if LibChatMessage then

    LibFontsChat = LibChatMessage(LibFonts.AddName, LibFonts.AddId)

else

    d("Error loading LibChatMessage!")

end

if LibMediaProvider then

    LibFontsLmp = LibMediaProvider

else

    d("Error loading LibMediaProvider!")

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
LibFonts.Fonts = LibFontsLmp:List("font")
LibFonts.FontStyle = {
    ESO_Standard_Font = { index = 1, friendlyName = "ESO_Standard_Font", name = "ESO Standard Font", path = "EsoUI/Common/Fonts/univers57.slug" },
    ESO_Book_Font = {  index = 2, friendlyName = "ESO_Book_Font", name = "ESO Book Font", path = "EsoUI/Common/Fonts/ProseAntiquePSMT.slug" },
    ESO_Handwritten_Font = { index = 3, friendlyName = "ESO_Handwritten_Font", name = "ESO Handwritten Font", path = "EsoUI/Common/Fonts/Handwritten_Bold.slug" },
    ESO_Tablet_Font = { index = 4, friendlyName = "ESO_Tablet_Font", name = "ESO Tablet Font", path = "EsoUI/Common/Fonts/TrajanPro-Regular.slug" },
    ESO_Gamepad_Font = { index = 5, friendlyName = "ESO_Gamepad_Font", name = "ESO Gamepad Font", path = "EsoUI/Common/Fonts/FuturaStd-Condensed.slug" },
    Arvo = { index = 6, friendlyName = "Arvo", name = "Arvo", path = "LibFonts/production/LibFonts/fonts/Arvo/Arvo-Regular.slug" },
    DejaVuSans = { index = 7, friendlyName = "DejaVuSans", name = "DejaVuSans", path = "LibFonts/production/LibFonts/fonts/DejaVu/DejaVuSans.slug" },
    DejaVuSans_Condensed = { index = 8, friendlyName = "DejaVuSans_Condensed", name = "DejaVuSansCondensed", path = "LibFonts/production/LibFonts/fonts/DejaVu/DejaVuSansCondensed.slug" },
    DejaVuSans_Mono = { index = 9, friendlyName = "DejaVuSans_Mono", name = "DejaVuSansMono", path = "LibFonts/production/LibFonts/fonts/DejaVu/DejaVuSansMono.slug" },
    DejaVuSans_Serif = { index = 10, friendlyName = "DejaVuSans_Serif", name = "DejaVuSerif", path = "LibFonts/production/LibFonts/fonts/DejaVu/DejaVuSerif.slug" },
    Droid_Sans = { index = 11, friendlyName = "Droid_Sans", name = "DroidSans", path = "LibFonts/production/LibFonts/fonts/Droid_Sans/DroidSans.slug" },
    Open_Sans = { index = 12, friendlyName = "Open_Sans", name = "OpenSans", path = "LibFonts/production/LibFonts/fonts/OpenSans/OpenSans-Regular.slug" },
    Open_Sans_Semibold = { index = 13, friendlyName = "Open_Sans_Semibold", name = "OpenSans Semibold", path = "LibFonts/production/LibFonts/fonts/OpenSans/OpenSans-Semibold.slug" },
    Prociono = { index = 14, friendlyName = "Prociono", name = "Prociono", path = "LibFonts/production/LibFonts/fonts/Prociono/Prociono-Regular.slug" },
    PT_Sans = { index = 15, friendlyName = "PT_Sans", name = "PT_Sans", path = "LibFonts/production/LibFonts/fonts/PT_Sans/PT_Sans-Web-Regular.slug" },
    Ubuntu = { index = 16, friendlyName = "Ubuntu", name = "Ubuntu", path = "LibFonts/production/LibFonts/fonts/Ubuntu/Ubuntu-Regular.slug" },
    Ubuntu_Medium = { index = 17, friendlyName = "Ubuntu_Medium", name = "Ubuntu Medium", path = "LibFonts/production/LibFonts/fonts/Ubuntu/Ubuntu-Medium.slug" },
    Vollkorn = { index = 18, friendlyName = "Vollkorn", name = "Vollkorn", path = "LibFonts/production/LibFonts/fonts/Vollkorn/Vollkorn-Regular.slug" },
    RuEsoChat = { index = 19, friendlyName = "RuEsoChat", name = "RuEsoChat", path = "LibFonts/production/LibFonts/fonts/RuEsoChat/RuEsoChat.slug" },
    Abnormal = { index = 20, friendlyName = "Abnormal", name = "ABNORMAL", path = "LibFonts/production/LibFonts/fonts/abnormal/ABNORMAL.slug" },
    AirmoleStripe = { index = 21, friendlyName = "AirmoleStripe", name = "AirmoleStripe", path = "LibFonts/production/LibFonts/fonts/airmole-stripe/AirmoleStripe.slug" },
    AkaFrivolity = { index = 22, friendlyName = "AkaFrivolity", name = "akaFrivolity", path = "LibFonts/production/LibFonts/fonts/aka-frivolity/akaFrivolity.slug" },
    AlphaWood = { index = 23, friendlyName = "AlphaWood", name = "AlphaWood", path = "LibFonts/production/LibFonts/fonts/alpha-wood/AlphaWood.slug" },
    AmishCyborg_Regular = { index = 24, friendlyName = "AmishCyborg_Regular", name = "AmishCyborg-Regular", path = "LibFonts/production/LibFonts/fonts/amish-cyborg/AmishCyborg-Regular.slug" },
    Anud_regular = { index = 25, friendlyName = "Anud_regular", name = "ANUDRG__", path = "LibFonts/production/LibFonts/fonts/anudaw/ANUDRG__.slug" },
    AvenueX_Regular = { index = 26, friendlyName = "AvenueX_Regular", name = "AvenueX-Regular", path = "LibFonts/production/LibFonts/fonts/avenue-x/AvenueX-Regular.slug" },
    Bather = { index = 27, friendlyName = "Bather", name = "Bather", path = "LibFonts/production/LibFonts/fonts/bather/Bather.slug" },
    Bimasakti = { index = 28, friendlyName = "Bimasakti", name = "bimasakti", path = "LibFonts/production/LibFonts/fonts/bimasakti/bimasakti.slug" },
    Blade_Runner = { index = 29, friendlyName = "Blade_Runner", name = "BLADRMF_", path = "LibFonts/production/LibFonts/fonts/blade-runner/BLADRMF_.slug" },
    Blitz = { index = 30, friendlyName = "Blitz", name = "Blitz", path = "LibFonts/production/LibFonts/fonts/blitz/Blitz.slug" },
    Blox2 = { index = 31, friendlyName = "Blox2", name = "Blox2", path = "LibFonts/production/LibFonts/fonts/blox/Blox2.slug" },
    Boxing_Brophius = { index = 32, friendlyName = "Boxing_Brophius", name = "Boxing Brophius", path = "LibFonts/production/LibFonts/fonts/boxing-brophius/Boxing Brophius.slug" },
    Breakaway = { index = 33, friendlyName = "Breakaway", name = "breakaway", path = "LibFonts/production/LibFonts/fonts/breakaway/breakaway.slug" },
    CarbonPhyber = { index = 34, friendlyName = "CarbonPhyber", name = "CarbonPhyber", path = "LibFonts/production/LibFonts/fonts/carbon-phyber/CarbonPhyber.slug" },
    Caricatura = { index = 35, friendlyName = "Caricatura", name = "Caricatura", path = "LibFonts/production/LibFonts/fonts/caricatura/Caricatura.slug" },
    Chopin_Script = { index = 36, friendlyName = "Chopin_Script", name = "ChopinScript", path = "LibFonts/production/LibFonts/fonts/chopin-script/ChopinScript.slug" },
    Cleopatra = { index = 37, friendlyName = "Cleopatra", name = "Cleopatra", path = "LibFonts/production/LibFonts/fonts/cleopatra/Cleopatra.slug" },
    Decocard = { index = 38, friendlyName = "Decocard", name = "decocard", path = "LibFonts/production/LibFonts/fonts/deco-card/decocard.slug" },
    DeutscheZierschrift = { index = 39, friendlyName = "DeutscheZierschrift", name = "DeutscheZierschrift", path = "LibFonts/production/LibFonts/fonts/deutsche-zierschrift/DeutscheZierschrift.slug" },
    Devo = { index = 40, friendlyName = "Devo", name = "DEVO", path = "LibFonts/production/LibFonts/fonts/devo/DEVO.slug" },
    Din_Schablonierschrift_Cracked = { index = 41, friendlyName = "Din_Schablonierschrift_Cracked", name = "DIN_Schablonierschrift_Cracked", path = "LibFonts/production/LibFonts/fonts/din-schablonierschrift-cracked/DIN_Schablonierschrift_Cracked.slug" },
    Ds_Thorowgood_Contour = { index = 42, friendlyName = "Ds_Thorowgood_Contour", name = "DS Thorowgood Contour", path = "LibFonts/production/LibFonts/fonts/ds-thorowgood/DS Thorowgood Contour.slug" },
    Egypat = { index = 43, friendlyName = "Egypat", name = "Egypat", path = "LibFonts/production/LibFonts/fonts/egypat/Egypat.slug" },
    Favorita = { index = 44, friendlyName = "Favorita", name = "Favorita", path = "LibFonts/production/LibFonts/fonts/favorita/Favorita.slug" },
    Fisherman = { index = 45, friendlyName = "Fisherman", name = "Fisherman", path = "LibFonts/production/LibFonts/fonts/fisherman/Fisherman.slug" },
    Fisherman_Book = { index = 46, friendlyName = "Fisherman_Book", name = "FishermanBook", path = "LibFonts/production/LibFonts/fonts/fisherman/FishermanBook.slug" },
    Fraktur_Shadowed = { index = 47, friendlyName = "Fraktur_Shadowed", name = "FrakturShadowed", path = "LibFonts/production/LibFonts/fonts/fraktur-shadowed/FrakturShadowed.slug" },
    GrandPrix = { index = 48, friendlyName = "GrandPrix", name = "GRANPS__", path = "LibFonts/production/LibFonts/fonts/grand-prix/GRANPS__.slug" },
    Husky_Stash = { index = 49, friendlyName = "Husky_Stash", name =  "HUSKYSTA", path = "LibFonts/production/LibFonts/fonts/husky-stash/HUSKYSTA.slug" },
    Industrial_Revolution_Regular = { index = 50, friendlyName = "Industrial_Revolution_Regular", name = "IndustrialRevolution-Regular", path = "LibFonts/production/LibFonts/fonts/industrial-revolution/IndustrialRevolution-Regular.slug" },
    Kingthings_Lupine = { index = 51, friendlyName = "Kingthings_Lupine", name = "Kingthings Lupine1.1", path = "LibFonts/production/LibFonts/fonts/kingthings-lupine/Kingthings Lupine1.1.slug" },
    MagicSchool_One = { index = 52, friendlyName = "MagicSchool_One", name = "MagicSchoolOne", path = "LibFonts/production/LibFonts/fonts/magic-school/MagicSchoolOne.slug" },
    MagicSchool_Two = { index = 53, friendlyName = "MagicSchool_Two", name = "MagicSchoolTwo", path = "LibFonts/production/LibFonts/fonts/magic-school/MagicSchoolTwo.slug" },
    Marlboro = { index = 54, friendlyName = "Marlboro", name = "Marlboro", path = "LibFonts/production/LibFonts/fonts/marlboro/Marlboro.slug" },
    Mastodon_Db_ = { index = 55, friendlyName = "Mastodon_Db_", name = "MASTODB_", path = "LibFonts/production/LibFonts/fonts/mastodon/MASTODB_.slug" },
    Mastodon_D = { index = 56, friendlyName = "Mastodon_D", name = "MASTOD__", path = "LibFonts/production/LibFonts/fonts/mastodon/MASTOD__.slug" },
    Measurements = { index = 57, friendlyName = "Measurements", name = "Measurements", path = "LibFonts/production/LibFonts/fonts/measurements/Measurements.slug" },
    MexicanTequila = { index = 58, friendlyName = "MexicanTequila", name = "MexicanTequila", path = "LibFonts/production/LibFonts/fonts/mexican-tequila/MexicanTequila.slug" },
    Mk_UnCiale_Pen = { index = 59, friendlyName = "Mk_UnCiale_Pen", name = "MKUnCiale-Pen", path = "LibFonts/production/LibFonts/fonts/mk-unciale/MKUnCiale-Pen.slug" },
    Mk_UnCiale_FS = { index = 60, friendlyName = "Mk_UnCiale_FS", name = "MKUnCialeFS", path = "LibFonts/production/LibFonts/fonts/mk-unciale/MKUnCialeFS.slug" },
    Monte_Carlo = { index = 61, friendlyName = "Monte_Carlo", name = "MonteCarlo", path = "LibFonts/production/LibFonts/fonts/monte-carlo/MonteCarlo.slug" },
    Monte_Carlo_Extravagant = { index = 62, friendlyName = "Monte_Carlo_Extravagant", name = "MonteCarloExtravagant", path = "LibFonts/production/LibFonts/fonts/monte-carlo/MonteCarloExtravagant.slug" },
    Old_Lettres_Ombrees = { index = 63, friendlyName = "Old_Lettres_Ombrees", name = "OldLettresOmbrees", path = "LibFonts/production/LibFonts/fonts/old-lettres-ombrees/OldLettresOmbrees.slug" },
    Oliver = { index = 64, friendlyName = "Oliver", name = "oliver__", path = "LibFonts/production/LibFonts/fonts/oliver/oliver__.slug" },
    Planet_Benson = { index = 65, friendlyName = "Planet_Benson", name = "planetbe", path = "LibFonts/production/LibFonts/fonts/planet-benson/planetbe.slug" },
    Quadlateral = { index = 66, friendlyName = "Quadlateral", name = "Quadlate", path = "LibFonts/production/LibFonts/fonts/quadlateral/Quadlate.slug" },
    Rialto = { index = 67, friendlyName = "Rialto", name = "RialtoNF", "LibFonts/production/LibFonts/fonts/rialto/RialtoNF.slug" },
    Romantiques = { index = 68, friendlyName = "Romantiques", name = "Romantiques", path = "LibFonts/production/LibFonts/fonts/romantiques/Romantiques.slug" },
    Shanghai = { index = 69, friendlyName = "Shanghai", name = "shanghai", path = "LibFonts/production/LibFonts/fonts/shanghai/shanghai.slug" },
    Sho_Card_Caps = { index = 70, friendlyName = "Sho_Card_Caps", name = "Sho-CardCapsNF", path = "LibFonts/production/LibFonts/fonts/shocardcaps/Sho-CardCapsNF.slug" },
    Sibay = { index = 71, friendlyName = "Sibay", name = "Sibay", path = "LibFonts/production/LibFonts/fonts/sibay/Sibay.slug" },
    Soerjaputera = { index = 72, friendlyName = "Soerjaputera", name = "Soerjaputera", path = "LibFonts/production/LibFonts/fonts/soerjaputera/Soerjaputera.slug" },
    Sparkle = { index = 73, friendlyName = "Sparkle", name = "Sparkle", path = "LibFonts/production/LibFonts/fonts/sparkle/Sparkle.slug" },
    Star_Tracks = { index = 74, friendlyName = "Star_Tracks", name = "StarTracks", path = "LibFonts/production/LibFonts/fonts/star-tracks/StarTracks.slug" },
    Striped_Sans_Black = { index = 75, friendlyName = "Striped_Sans_Black", name = "StripedSansBlack", path = "LibFonts/production/LibFonts/fonts/striped-sans-black/StripedSansBlack.slug" },
    United = { index = 76, friendlyName = "United", name = "united", path = "LibFonts/production/LibFonts/fonts/united/united.slug" },
    Valium = { index = 77, friendlyName = "Valium", name = "Valium__", path = "LibFonts/production/LibFonts/fonts/valium/Valium__.slug" },
    Volcano_Book = { index = 78, friendlyName = "Volcano_Book", name = "Volcano-Book", path = "LibFonts/production/LibFonts/fonts/volcano/Volcano-Book.slug" },
    Volcano = { index = 79, friendlyName = "Volcano", name = "Volcano", path = "LibFonts/production/LibFonts/fonts/volcano/Volcano.slug" },
    Wet_Paint = { index = 80, friendlyName = "Wet_Paint", name = "WetPaint", path = "LibFonts/production/LibFonts/fonts/wetpaint/WetPaint.slug" },
    Zigzag_Displays = { index = 81, friendlyName = "Zigzag_Displays", name = "ZigzagDisplays", path = "LibFonts/production/LibFonts/fonts/zigzag-displays/ZigzagDisplays.slug" },
    Zippo = { index = 82, friendlyName = "Zippo", name = "Zippo", path = "LibFonts/production/LibFonts/fonts/zippo/Zippo.slug" }
}