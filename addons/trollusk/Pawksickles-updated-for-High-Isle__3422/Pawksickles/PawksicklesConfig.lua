
local tsort         = table.sort
local tinsert       = table.insert
local LAM           = LibAddonMenu2
local LMP           = LibMediaProvider

local PawksicklesConfig =
{
    _name = '_pawksickles',
    _headers = setmetatable( {}, { __mode = 'kv' } )
}

local CBM = CALLBACK_MANAGER

local THIN          = 'soft-shadow-thin'
local THICK         = 'soft-shadow-thick'
local SHADOW        = 'shadow'
local NONE          = 'none'

local defaults =
{
    ZoFontWinH1 = { face = 'Univers 67', size = 30, decoration = THICK },
    ZoFontWinH2 = { face = 'Univers 67', size = 24, decoration = THICK },
    ZoFontWinH3 = { face = 'Univers 67', size = 20, decoration = THICK },
    ZoFontWinH4 = { face = 'Univers 67', size = 18, decoration = THICK },
    ZoFontWinH5 = { face = 'Univers 67', size = 16, decoration = THICK },

    ZoFontWinH3SoftShadowThin = { face = 'Univers 67', size = 20, decoration = THIN },

    ZoFontWinT1 = { face = 'Univers 67', size = 18, decoration = THIN },
    ZoFontWinT2 = { face = 'Univers 67', size = 16, decoration = THIN },

    ZoFontGame = { face = 'Univers 57', size = 18, decoration = THIN },
    ZoFontGameMedium = { face = 'Univers 57', size = 18, decoration = THIN },
    ZoFontGameBold = { face = 'Univers 67', size = 18, decoration = THIN },
    ZoFontGameOutline = { face = 'Univers 67', size = 18, decoration = THIN },
    ZoFontGameShadow = { face = 'Univers 67', size = 18, decoration = THIN },

    ZoFontKeyboard28ThickOutline = { face = 'Univers 67', size = 28, decoration = OUTLINE },
    ZoFontKeyboard24ThickOutline = { face = 'Univers 67', size = 24, decoration = OUTLINE },
    ZoFontKeyboard18ThickOutline = { face = 'Univers 67', size = 18, decoration = OUTLINE },

    ZoFontGameSmall = { face = 'Univers 67', size = 13, decoration = THIN },
    ZoFontGameLarge = { face = 'Univers 57', size = 18, decoration = THIN },
    ZoFontGameLargeBold = { face = 'Univers 67', size = 18, decoration = THICK },
    ZoFontGameLargeBoldShadow = { face = 'Univers 67', size = 18, decoration = THICK },

    ZoFontHeader  = { face = 'Univers 67', size = 18, decoration = THICK },
    ZoFontHeader2  = { face = 'Univers 67', size = 20, decoration = THICK },
    ZoFontHeader3  = { face = 'Univers 67', size = 24, decoration = THICK },
    ZoFontHeader4  = { face = 'Univers 67', size = 26, decoration = THICK },

    ZoFontHeaderNoShadow  = { face = 'Univers 67', size = 18, decoration = NONE },

    ZoFontCallout  = { face = 'Univers 67', size = 36, decoration = THICK },
    ZoFontCallout2  = { face = 'Univers 67', size = 48, decoration = THICK },
    ZoFontCallout3  = { face = 'Univers 67', size = 54, decoration = THICK },

    ZoFontEdit  = { face = 'Univers 57', size = 18, decoration = SHADOW },
    ZoFontEdit20NoShadow = { face = 'Univers 67', size = 20, decoration = NONE },

    ZoFontChat  = { face = 'Univers 57', size = 18, decoration = THIN },
    ZoFontEditChat  = { face = 'Univers 57', size = 18, decoration = SHADOW },

    ZoFontWindowTitle  = { face = 'Univers 67', size = 30, decoration = THICK },
    ZoFontWindowSubtitle  = { face = 'Univers 67', size = 18, decoration = THICK },

    ZoFontTooltipTitle  = { face = 'Univers 67', size = 22, decoration = NONE },
    ZoFontTooltipSubtitle  = { face = 'Univers 57', size = 18, decoration = NONE },

    ZoFontAnnounce  = { face = 'Univers 67', size = 28, decoration = THICK },
    ZoFontAnnounceMessage  = { face = 'Univers 67', size = 24, decoration = THICK },
    ZoFontAnnounceMedium  = { face = 'Univers 67', size = 24, decoration = THICK },
    ZoFontAnnounceLarge  = { face = 'Univers 67', size = 36, decoration = THICK },
    ZoFontAnnounceLargeNoShadow = { face = 'Univers 67', size = 36, decoration = NONE },

    ZoFontAnnounceNoShadow  = { face = 'Univers 67', size = 36, decoration = NONE },

    ZoFontCenterScreenAnnounceLarge  = { face = 'Univers 67', size = 40, decoration = THICK },
    ZoFontCenterScreenAnnounceSmall  = { face = 'Univers 67', size = 30, decoration = THICK },

    ZoFontAlert  = { face = 'Univers 67', size = 24, decoration = THICK },

    ZoFontConversationName  = { face = 'Univers 67', size = 28, decoration = THICK },
    ZoFontConversationText  = { face = 'Univers 67', size = 24, decoration = THICK },
    ZoFontConversationOption  = { face = 'Univers 67', size = 22, decoration = THICK },
    ZoFontConversationQuestReward  = { face = 'Univers 67', size = 20, decoration = THICK },

    ZoFontKeybindStripKey  = { face = 'Univers 57', size = 20, decoration = THIN },
    ZoFontKeybindStripDescription  = { face = 'Univers 67', size = 25, decoration = THICK },
    ZoFontDialogKeybindDescription  = { face = 'Univers 67', size = 20, decoration = THICK },

    ZoInteractionPrompt  = { face = 'Univers 67', size = 24, decoration = THICK },

    ZoFontCreditsHeader  = { face = 'Univers 67', size = 24, decoration = NONE },
    ZoFontCreditsText  = { face = 'Univers 67', size = 18, decoration = NONE },

    ZoFontSubtitleText = { face = 'Univers 57', size = 28, decoration = THICK },

    ZoMarketAnnouncementCalloutFont = { face = 'Univers 67', size = 32, decoration = THIN },

    ZoFontBookPaper  = { face = 'ProseAntique', size = 20, decoration = NONE },
    ZoFontBookSkin  = { face = 'ProseAntique', size = 20, decoration = NONE },
    ZoFontBookRubbing  = { face = 'ProseAntique', size = 20, decoration = NONE },
    ZoFontBookLetter  = { face = 'Skyrim Handwritten', size = 20, decoration = NONE },
    ZoFontBookNote  = { face = 'Skyrim Handwritten', size = 22, decoration = NONE },
    ZoFontBookScroll  = { face = 'Skyrim Handwritten', size = 26, decoration = NONE },
    ZoFontBookTablet  = { face = 'Trajan Pro', size = 30, decoration = THICK },
    ZoFontBookMetal  = { face = 'ProseAntique', size = 20, decoration = THICK },

    ZoFontBookPaperTitle  = { face = 'ProseAntique', size = 30, decoration = NONE },
    ZoFontBookSkinTitle  = { face = 'ProseAntique', size = 30, decoration = NONE },
    ZoFontBookRubbingTitle  = { face = 'ProseAntique', size = 30, decoration = NONE },
    ZoFontBookLetterTitle  = { face = 'Skyrim Handwritten', size = 30, decoration = NONE },
    ZoFontBookNoteTitle  = { face = 'Skyrim Handwritten', size = 32, decoration = NONE },
    ZoFontBookScrollTitle  = { face = 'Skyrim Handwritten', size = 34, decoration = NONE },
    ZoFontBookTabletTitle  = { face = 'Trajan Pro', size = 48, decoration = THICK },
    ZoFontBookMetalTitle  = { face = 'ProseAntique', size = 30, decoration = THICK },


    ZoFontGamepad61 = { face = 'Futura Condensed', size = 61, decoration = THICK },
    ZoFontGamepad54 = { face = 'Futura Condensed', size = 54, decoration = THICK },
    ZoFontGamepad45 = { face = 'Futura Condensed', size = 45, decoration = THICK },
    ZoFontGamepad42 = { face = 'Futura Condensed', size = 42, decoration = THICK },
    ZoFontGamepad36 = { face = 'Futura Condensed', size = 36, decoration = THICK },
    ZoFontGamepad34 = { face = 'Futura Condensed', size = 34, decoration = THICK },
    ZoFontGamepad27 = { face = 'Futura Condensed', size = 27, decoration = THICK },
    ZoFontGamepad25 = { face = 'Futura Condensed', size = 25, decoration = THICK },
    ZoFontGamepad22 = { face = 'Futura Condensed', size = 22, decoration = THICK },
    ZoFontGamepad20 = { face = 'Futura Condensed', size = 20, decoration = THICK },
    ZoFontGamepad18 = { face = 'Futura Condensed', size = 18, decoration = THICK },

    ZoFontGamepad27NoShadow = { face = 'Futura Condensed', size = 27, decoration = NONE },
    ZoFontGamepad42NoShadow = { face = 'Futura Condensed', size = 42, decoration = NONE },

    ZoFontGamepadCondensed61 = { face = 'Futura Condensed Light', size = 61, decoration = THICK },
    ZoFontGamepadCondensed54 = { face = 'Futura Condensed Light', size = 54, decoration = THICK },
    -- ZoFontGamepadCondensed45 = { face = 'Futura Condensed Light', size = 45, decoration = THICK },
    ZoFontGamepadCondensed42 = { face = 'Futura Condensed Light', size = 42, decoration = THICK },
    ZoFontGamepadCondensed36 = { face = 'Futura Condensed Light', size = 36, decoration = THICK },
    ZoFontGamepadCondensed34 = { face = 'Futura Condensed Light', size = 34, decoration = THICK },
    ZoFontGamepadCondensed27 = { face = 'Futura Condensed Light', size = 27, decoration = THICK },
    ZoFontGamepadCondensed25 = { face = 'Futura Condensed Light', size = 25, decoration = THICK },
    -- ZoFontGamepadCondensed22 = { face = 'Futura Condensed Light', size = 22, decoration = THICK },
    -- ZoFontGamepadCondensed20 = { face = 'Futura Condensed Light', size = 20, decoration = THICK },
    -- ZoFontGamepadCondensed18 = { face = 'Futura Condensed Light', size = 18, decoration = THICK },

    -- ZoFontGamepadBold61 = { face = 'Futura Condensed Bold', size = 61, decoration = THICK },
    ZoFontGamepadBold54 = { face = 'Futura Condensed Bold', size = 54, decoration = THICK },
    ZoFontGamepadBold48 = { face = 'Futura Condensed Bold', size = 48, decoration = THICK },
    -- ZoFontGamepadBold42 = { face = 'Futura Condensed Bold', size = 42, decoration = THICK },
    -- ZoFontGamepadBold36 = { face = 'Futura Condensed Bold', size = 36, decoration = THICK },
    ZoFontGamepadBold34 = { face = 'Futura Condensed Bold', size = 34, decoration = THICK },
    ZoFontGamepadBold27 = { face = 'Futura Condensed Bold', size = 27, decoration = THICK },
    ZoFontGamepadBold25 = { face = 'Futura Condensed Bold', size = 25, decoration = THICK },
    ZoFontGamepadBold22 = { face = 'Futura Condensed Bold', size = 22, decoration = THICK },
    ZoFontGamepadBold20 = { face = 'Futura Condensed Bold', size = 20, decoration = THICK },
    ZoFontGamepadBold18 = { face = 'Futura Condensed Bold', size = 18, decoration = THICK },

    ZoFontGamepadChat = { face = 'Futura Condensed', size = 20, decoration = THICK },
    ZoFontGamepadEditChat = { face = 'Futura Condensed', size = 20, decoration = THICK },

    ZoFontGamepadBookPaper  = { face = 'ProseAntique', size = 20, decoration = NONE },
    ZoFontGamepadBookSkin  = { face = 'ProseAntique', size = 20, decoration = NONE },
    ZoFontGamepadBookRubbing  = { face = 'ProseAntique', size = 20, decoration = NONE },
    ZoFontGamepadBookLetter  = { face = 'Skyrim Handwritten', size = 20, decoration = NONE },
    ZoFontGamepadBookNote  = { face = 'Skyrim Handwritten', size = 22, decoration = NONE },
    ZoFontGamepadBookScroll  = { face = 'Skyrim Handwritten', size = 26, decoration = NONE },
    ZoFontGamepadBookTablet  = { face = 'Trajan Pro', size = 30, decoration = THICK },
    ZoFontGamepadBookMetal  = { face = 'ProseAntique', size = 30, decoration = THICK },

    ZoFontGamepadBookPaperTitle  = { face = 'ProseAntique', size = 30, decoration = NONE },
    ZoFontGamepadBookSkinTitle  = { face = 'ProseAntique', size = 30, decoration = NONE },
    ZoFontGamepadBookRubbingTitle  = { face = 'ProseAntique', size = 30, decoration = NONE },
    ZoFontGamepadBookLetterTitle  = { face = 'Skyrim Handwritten', size = 30, decoration = NONE },
    ZoFontGamepadBookNoteTitle  = { face = 'Skyrim Handwritten', size = 32, decoration = NONE },
    ZoFontGamepadBookScrollTitle  = { face = 'Skyrim Handwritten', size = 34, decoration = NONE },
    ZoFontGamepadBookTabletTitle  = { face = 'Trajan Pro', size = 48, decoration = THICK },
    ZoFontGamepadBookMetalTitle  = { face = 'ProseAntique', size = 40, decoration = THICK },

    ZoFontTributeAntique20NoShadow = { face = 'ProseAntique', size = 20, decoration = NONE },
    ZoFontTributeAntique20 = { face = 'ProseAntique', size = 20, decoration = THICK },
    ZoFontTributeAntique30NoShadow = { face = 'ProseAntique', size = 30, decoration = NONE },
    ZoFontTributeAntique30 = { face = 'ProseAntique', size = 30, decoration = THICK },
    ZoFontTributeAntique40 = { face = 'ProseAntique', size = 40, decoration = THICK },
    ZoFontTributeAntique52 = { face = 'ProseAntique', size = 52, decoration = THICK },

    ZoFontGamepadHeaderDataValue = { face = 'Futura Condensed', size = 42, decoration = THICK },

    ZoMarketGamepadCalloutFont = { face = 'Futura Condensed', size = 42, decoration = THIN },
}

local logical = {}
local decorations = { 'none', 'outline', 'thin-outline', 'thick-outline', 'soft-shadow-thin', 'soft-shadow-thick', 'shadow' }

function PawksicklesConfig:FormatFont( fontEntry )
    local str = '%s|%d'
    if ( fontEntry.decoration ~= NONE ) then
        str = str .. '|%s'
    end

    fontEntry.face = string.gsub(fontEntry.face, '^Futura Std Condensed', 'Futura Condensed', 1)
    return string.format( str, LMP:Fetch( 'font', fontEntry.face ), fontEntry.size or 10, fontEntry.decoration )
end

function PawksicklesConfig:OnLoaded()
    self.db = ZO_SavedVars:NewAccountWide( 'PAWKSICKLES_DB', 1.0, nil, defaults )

    --fonts removed in Update 7
    self.db[ 'ZoLargeFontEdit' ]  = nil
    self.db[ 'ZoFontAnnounceSmall' ]  = nil
    self.db[ 'ZoFontBossName' ]  = nil
    self.db[ 'ZoFontBoss' ]  = nil

    for k,_ in pairs( defaults ) do
        tinsert( logical, k )
    end

    tsort( logical )

    self.config_panel = LAM:RegisterAddonPanel(self._name, {
        type = panel,
        name = 'Pawksickles',
        displayName = ZO_HIGHLIGHT_TEXT:Colorize('Pawksickles'),
        author = "Pawkette (updated by Garkin)",
        version = "1.4",
        slashCommand = "/pawksickles",
        registerForRefresh = true,
        registerForDefaults = true,
    })

    self:BeginAddingOptions()

    local UpdateHeaders
    UpdateHeaders = function(panel)
        if panel == self.config_panel then
            for i, gameFont in ipairs(logical) do
                local newFont = self:FormatFont( self.db[ gameFont ] )
                self._headers[ gameFont ] = _G[self._name .. '_header_' .. i].header
                self._headers[ gameFont ]:SetFont( newFont )
            end
            CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", UpdateHeaders)
        end
    end
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", UpdateHeaders)
end

function PawksicklesConfig:BeginAddingOptions()
    local optionsData = {}

    for i, gameFont in ipairs(logical) do
        if ( self.db[ gameFont ] ) then
            CBM:FireCallbacks( 'PAWKSICKLES_FONT_CHANGED', gameFont, self:FormatFont( self.db[ gameFont ] ) )

            tinsert( optionsData, {
                type = 'header',
                name = gameFont,
                reference = self._name .. '_header_' .. i,
                } )
            tinsert( optionsData, {
                type = 'dropdown',
                name = 'Font:',
                choices = LMP:List( 'font' ),
                getFunc = function() return self.db[ gameFont ].face end,
                setFunc = function( selection )  self:FontDropdownChanged( gameFont, selection ) end,
                default = defaults[ gameFont ].face,
                } )
            tinsert( optionsData, {
                type = 'slider',
                name = 'Size:',
                min = 5,
                max = 50,
                getFunc = function() return self.db[ gameFont ].size end,
                setFunc = function( size ) self:SliderChanged( gameFont, size ) end,
                default = defaults[ gameFont ].size,
                } )
            tinsert( optionsData, {
                type = 'dropdown',
                name = 'Decoration:',
                choices = decorations,
                getFunc = function() return self.db[ gameFont ].decoration end,
                setFunc = function( selection ) self:DecorationDropdownChanged( gameFont, selection ) end,
                default = defaults[ gameFont ].decoration,
                } )
        end
    end

    LAM:RegisterOptionControls(self._name, optionsData)
end

function PawksicklesConfig:FontDropdownChanged( gameFont, fontFace )
    self.db[ gameFont ].face = fontFace
    local newFont = self:FormatFont( self.db[ gameFont ] )
    if ( self._headers[ gameFont ] ) then
        self._headers[ gameFont ]:SetFont( newFont )
    end

    CBM:FireCallbacks( 'PAWKSICKLES_FONT_CHANGED', gameFont, newFont )
end

function PawksicklesConfig:SliderChanged( gameFont, size )
    self.db[ gameFont ].size = size
    local newFont = self:FormatFont( self.db[ gameFont ] )
    if ( self._headers[ gameFont ] ) then
        self._headers[ gameFont ]:SetFont( newFont )
    end

    CBM:FireCallbacks( 'PAWKSICKLES_FONT_CHANGED', gameFont, newFont )
end

function PawksicklesConfig:DecorationDropdownChanged( gameFont, decoration )
    self.db[ gameFont ].decoration = decoration
    local newFont = self:FormatFont( self.db[ gameFont ] )
    if ( self._headers[ gameFont ] ) then
        self._headers[ gameFont ]:SetFont( newFont )
    end

    CBM:FireCallbacks( 'PAWKSICKLES_FONT_CHANGED', gameFont, newFont )
end

CBM:RegisterCallback( 'PAWKSICKLES_LOADED', function( ... ) PawksicklesConfig:OnLoaded( ... ) end )