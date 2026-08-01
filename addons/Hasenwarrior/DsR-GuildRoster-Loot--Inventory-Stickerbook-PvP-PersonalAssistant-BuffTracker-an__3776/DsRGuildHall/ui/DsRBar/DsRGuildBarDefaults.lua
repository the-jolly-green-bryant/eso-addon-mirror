-- DsRGuildWindowSettings

-- Create namespace
DsRGuildBarDefaults = {}
local DsRGuildBarDefaults = DsRGuildBarDefaults  or {}

DsRGuildBarDefaults.name = "DsRGuildBarDefaults"
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildBarDefaults:Defaults()
    local BarDefaults = {
        BarOnOff                 = false,
        BarRefreshTimer          = 30,
        BarScale                 = 1,
        BarBG                    = false,
        BarBGtrans               = 75,
        BarOffSetX               = 3,
        BarMenueHide             = true,
        BarOStime                = true,
        BarCP                    = true,
        BarCrowns                = true,
        BarshowXP                = true,
        BarPosition              = 2,
        BarGold                  = 3,
        BarAP                    = 3,
        BarBankspace             = 3,
        BarInventoryspace        = 3,
        BarTelVar                = 3,
        BarUndaunted             = true,
        BarTransmute             = true,
        -- BarEticket               = true,
        BarEndeavor              = true,
        BarEndless               = true,
        BarImperialFragements    = true,
        BarWritvoucher           = 3,
        BarRepairKits            = true,
        BarSoulGems              = true,
        BarLockpicks             = true,
        BarStolen                = true,
        BaromeChallenge          = false,
        BarTomePoints            = false,
        BarTomePointCach         = false,
        BarTomeToken             = false,
        BarTradeBars             = false,
    }

	DsRGuildBar.SV = ZO_SavedVars:NewAccountWide("DsRGuildBarSettings", 1, nil, BarDefaults)
end
