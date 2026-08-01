local LAM = LibStub( 'LibAddonMenu-2.0', true )
local LMP = LibStub( 'LibMediaProvider-1.0', true )

if ( not LAM ) then return end
if ( not LMP ) then return end

local tsort = table.sort
local tinsert = table.insert

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
    ZoFontWinH1 = { face = 'esojp1', size = 30, decoration = THICK },
    ZoFontWinH2 = { face = 'esojp1', size = 24, decoration = THICK },
    ZoFontWinH3 = { face = 'esojp1', size = 20, decoration = THICK },
    ZoFontWinH4 = { face = 'esojp1', size = 18, decoration = THICK },
    ZoFontWinH5 = { face = 'esojp1', size = 16, decoration = THICK },

    ZoFontWinT1 = { face = 'esojp1', size = 18, decoration = THIN },
    ZoFontWinT2 = { face = 'esojp1', size = 16, decoration = THIN },

    ZoFontGame = { face = 'esojp1', size = 18, decoration = THIN },
    ZoFontGameMedium = { face = 'esojp1', size = 18, decoration = THIN },
    ZoFontGameBold = { face = 'esojp1', size = 18, decoration = THIN },
    ZoFontGameOutline = { face = 'esojp1', size = 18, decoration = THIN },
    ZoFontGameShadow = { face = 'esojp1', size = 18, decoration = THIN },

    ZoFontGameSmall = { face = 'esojp1', size = 13, decoration = THIN },
    ZoFontGameLarge = { face = 'esojp1', size = 18, decoration = THIN },
    ZoFontGameLargeBold = { face = 'esojp1', size = 18, decoration = THICK },
    ZoFontGameLargeBoldShadow = { face = 'esojp1', size = 18, decoration = THICK },

    ZoFontHeader  = { face = 'esojp1', size = 18, decoration = THICK },
    ZoFontHeader2  = { face = 'esojp1', size = 20, decoration = THICK },
    ZoFontHeader3  = { face = 'esojp1', size = 24, decoration = THICK },
    ZoFontHeader4  = { face = 'esojp1', size = 26, decoration = THICK },

    ZoFontHeaderNoShadow  = { face = 'esojp1', size = 18, decoration = NONE },

    ZoFontCallout  = { face = 'esojp1', size = 36, decoration = THICK },
    ZoFontCallout2  = { face = 'esojp1', size = 48, decoration = THICK },
    ZoFontCallout3  = { face = 'esojp1', size = 54, decoration = THICK },

    ZoFontEdit  = { face = 'esojp1', size = 18, decoration = SHADOW },

    ZoFontChat  = { face = 'esojp2', size = 18, decoration = THIN },
    ZoFontEditChat  = { face = 'esojp2', size = 18, decoration = SHADOW },

    ZoFontWindowTitle  = { face = 'esojp1', size = 30, decoration = THICK },
    ZoFontWindowSubtitle  = { face = 'esojp1', size = 18, decoration = THICK },

    ZoFontTooltipTitle  = { face = 'esojp1', size = 22, decoration = NONE },
    ZoFontTooltipSubtitle  = { face = 'esojp1', size = 18, decoration = NONE },

    ZoFontAnnounce  = { face = 'esojp1', size = 28, decoration = THICK },
    ZoFontAnnounceMessage  = { face = 'esojp1', size = 24, decoration = THICK },
    ZoFontAnnounceMedium  = { face = 'esojp1', size = 24, decoration = THICK },
    ZoFontAnnounceLarge  = { face = 'esojp1', size = 36, decoration = THICK },

    ZoFontAnnounceNoShadow  = { face = 'esojp1', size = 36, decoration = NONE },

    ZoFontCenterScreenAnnounceLarge  = { face = 'esojp1', size = 40, decoration = THICK },
    ZoFontCenterScreenAnnounceSmall  = { face = 'esojp1', size = 30, decoration = THICK },

    ZoFontAlert  = { face = 'esojp1', size = 24, decoration = THICK },

    ZoFontConversationName  = { face = 'esojp1', size = 28, decoration = THICK },
    ZoFontConversationText  = { face = 'esojp1', size = 24, decoration = THICK },
    ZoFontConversationOption  = { face = 'esojp1', size = 22, decoration = THICK },
    ZoFontConversationQuestReward  = { face = 'esojp1', size = 20, decoration = THICK },

    ZoFontKeybindStripKey  = { face = 'esojp1', size = 20, decoration = THIN },
    ZoFontKeybindStripDescription  = { face = 'esojp1', size = 25, decoration = THICK },
    ZoFontDialogKeybindDescription  = { face = 'esojp1', size = 20, decoration = THICK },

    ZoInteractionPrompt  = { face = 'esojp1', size = 24, decoration = THICK },

    ZoFontCreditsHeader  = { face = 'esojp1', size = 24, decoration = NONE },
    ZoFontCreditsText  = { face = 'esojp1', size = 18, decoration = NONE },

    ZoFontBookPaper  = { face = 'esojp1', size = 20, decoration = NONE },
    ZoFontBookSkin  = { face = 'esojp1', size = 20, decoration = NONE },
    ZoFontBookRubbing  = { face = 'esojp1', size = 20, decoration = NONE },
    ZoFontBookLetter  = { face = 'esojp1', size = 20, decoration = NONE },
    ZoFontBookNote  = { face = 'esojp1', size = 22, decoration = NONE },
    ZoFontBookScroll  = { face = 'esojp1', size = 26, decoration = NONE },
    ZoFontBookTablet  = { face = 'esojp1', size = 30, decoration = THICK },

    ZoFontBookPaperTitle  = { face = 'esojp1', size = 30, decoration = NONE },
    ZoFontBookSkinTitle  = { face = 'esojp1', size = 30, decoration = NONE },
    ZoFontBookRubbingTitle  = { face = 'esojp1', size = 30, decoration = NONE },
    ZoFontBookLetterTitle  = { face = 'esojp1', size = 30, decoration = NONE },
    ZoFontBookNoteTitle  = { face = 'esojp1', size = 32, decoration = NONE },
    ZoFontBookScrollTitle  = { face = 'esojp1', size = 34, decoration = NONE },
    ZoFontBookTabletTitle  = { face = 'esojp1', size = 48, decoration = THICK },


    ZoFontGamepad61 = { face = 'esojp1', size = 61, decoration = THICK },
    ZoFontGamepad54 = { face = 'esojp1', size = 54, decoration = THICK },
    ZoFontGamepad45 = { face = 'esojp1', size = 45, decoration = THICK },
    ZoFontGamepad42 = { face = 'esojp1', size = 42, decoration = THICK },
    ZoFontGamepad36 = { face = 'esojp1', size = 36, decoration = THICK },
    ZoFontGamepad34 = { face = 'esojp1', size = 34, decoration = THICK },
    ZoFontGamepad27 = { face = 'esojp1', size = 27, decoration = THICK },
    ZoFontGamepad25 = { face = 'esojp1', size = 25, decoration = THICK },
    ZoFontGamepad22 = { face = 'esojp1', size = 22, decoration = THICK },
    ZoFontGamepad20 = { face = 'esojp1', size = 20, decoration = THICK },
    ZoFontGamepad18 = { face = 'esojp1', size = 18, decoration = THICK },

    ZoFontGamepad27NoShadow = { face = 'esojp1', size = 27, decoration = NONE },
    ZoFontGamepad42NoShadow = { face = 'esojp1', size = 42, decoration = NONE },

    ZoFontGamepadCondensed61 = { face = 'esojp1', size = 61, decoration = THICK },
    ZoFontGamepadCondensed54 = { face = 'esojp1', size = 54, decoration = THICK },
    ZoFontGamepadCondensed45 = { face = 'esojp1', size = 45, decoration = THICK },
    ZoFontGamepadCondensed42 = { face = 'esojp1', size = 42, decoration = THICK },
    ZoFontGamepadCondensed36 = { face = 'esojp1', size = 36, decoration = THICK },
    ZoFontGamepadCondensed34 = { face = 'esojp1', size = 34, decoration = THICK },
    ZoFontGamepadCondensed27 = { face = 'esojp1', size = 27, decoration = THICK },
    ZoFontGamepadCondensed25 = { face = 'esojp1', size = 25, decoration = THICK },
    ZoFontGamepadCondensed22 = { face = 'esojp1', size = 22, decoration = THICK },
    ZoFontGamepadCondensed20 = { face = 'esojp1', size = 20, decoration = THICK },
    ZoFontGamepadCondensed18 = { face = 'esojp1', size = 18, decoration = THICK },

    ZoFontGamepadBold61 = { face = 'esojp1', size = 61, decoration = THICK },
    ZoFontGamepadBold54 = { face = 'esojp1', size = 54, decoration = THICK },
    ZoFontGamepadBold45 = { face = 'esojp1', size = 45, decoration = THICK },
    ZoFontGamepadBold42 = { face = 'esojp1', size = 42, decoration = THICK },
    ZoFontGamepadBold36 = { face = 'esojp1', size = 36, decoration = THICK },
    ZoFontGamepadBold34 = { face = 'esojp1', size = 34, decoration = THICK },
    ZoFontGamepadBold27 = { face = 'esojp1', size = 27, decoration = THICK },
    ZoFontGamepadBold25 = { face = 'esojp1', size = 25, decoration = THICK },
    ZoFontGamepadBold22 = { face = 'esojp1', size = 22, decoration = THICK },
    ZoFontGamepadBold20 = { face = 'esojp1', size = 20, decoration = THICK },
    ZoFontGamepadBold18 = { face = 'esojp1', size = 18, decoration = THICK },

    ZoFontGamepadChat = { face = 'esojp1', size = 20, decoration = THICK },
    ZoFontGamepadEditChat = { face = 'esojp1', size = 20, decoration = THICK },

    ZoFontGamepadBookPaper  = { face = 'esojp1', size = 20, decoration = NONE },
    ZoFontGamepadBookSkin  = { face = 'esojp1', size = 20, decoration = NONE },
    ZoFontGamepadBookRubbing  = { face = 'esojp1', size = 20, decoration = NONE },
    ZoFontGamepadBookLetter  = { face = 'esojp1', size = 20, decoration = NONE },
    ZoFontGamepadBookNote  = { face = 'esojp1', size = 22, decoration = NONE },
    ZoFontGamepadBookScroll  = { face = 'esojp1', size = 26, decoration = NONE },
    ZoFontGamepadBookTablet  = { face = 'esojp1', size = 30, decoration = THICK },

    ZoFontGamepadBookPaperTitle  = { face = 'esojp1', size = 30, decoration = NONE },
    ZoFontGamepadBookSkinTitle  = { face = 'esojp1', size = 30, decoration = NONE },
    ZoFontGamepadBookRubbingTitle  = { face = 'esojp1', size = 30, decoration = NONE },
    ZoFontGamepadBookLetterTitle  = { face = 'esojp1', size = 30, decoration = NONE },
    ZoFontGamepadBookNoteTitle  = { face = 'esojp1', size = 32, decoration = NONE },
    ZoFontGamepadBookScrollTitle  = { face = 'esojp1', size = 34, decoration = NONE },
    ZoFontGamepadBookTabletTitle  = { face = 'esojp1', size = 48, decoration = THICK },

    ZoFontGamepadHeaderDataValue = { face = 'esojp1', size = 42, decoration = THICK },
}

local logical = {}
local decorations = { 'none', 'outline', 'thin-outline', 'thick-outline', 'soft-shadow-thin', 'soft-shadow-thick', 'shadow' }

function PawksicklesConfig:FormatFont( fontEntry )
    local str = '%s|%d'
    if ( fontEntry.decoration ~= NONE ) then
        str = str .. '|%s'
    end

    fontEntry.face = string.gsub(fontEntry.face, '^Futura Std Condensed', 'EsoUI/Common/Fonts/ESO_FWNTLGUDC70-DB.ttf', 1)
    return string.format( str, LMP:Fetch( 'font', fontEntry.face ), fontEntry.size or 10, fontEntry.decoration )
end

function PawksicklesConfig:OnLoaded()
    self.db = ZO_SavedVars:NewAccountWide( 'PAWKSICKLES_DB_JP', 1.0, nil, defaults )

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