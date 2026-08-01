-- ============================================================
--  XANTOS-TR TARAFINDAN YAZILMIŞTIR
-- ============================================================
-- EsoTR Modülü: MapFontFix
--
-- AMAÇ:
--   Harita üzerindeki el yazısı (handwritten) fontları
--   Türkçe karakterlerle uyumlu fontla değiştirmek.
--
-- ÖNEMLİ NOT (BİLİNÇLİ TASARIM KARARI):
-- ------------------------------------------------------------
-- Bu modül BİLEREK:
--   - Scene state kullanmaz
--   - worldMap SHOWING / SHOWN kontrolü yapmaz
--   - IsShowing("worldMap") kullanmaz
--
-- SEBEP:
--   ESO Console UI yaşam döngüsü güvenilir değildir.
--   Scene callback'leri ve state kontrolleri
--   konsolda sık sık KAÇIRILIR.
--
-- Bu nedenle "çirkin ama çalışan" yöntem tercih edilmiştir:
--   → Her 500 ms'de bir kontrol
--   → UI hazır olduğunda mutlaka yakalar
--
-- Bu karar:
--   - Konsolda %100 çalışır
--   - Performans sorunu yaratmaz
--   - Save Error ile ilişkili değildir
--
-- LÜTFEN:
--   Bu dosyayı "optimize etmeye" çalışmayın.
--   Daha önce denendi ve konsolda ÇALIŞMADI.
-- ============================================================

local EsoTR = EsoTR or {}
if not EsoTR.modules then EsoTR.modules = {} end
EsoTR.modules.MapFontFix = {}

local MapFontFix = EsoTR.modules.MapFontFix
local isRunning = false

-- ------------------------------------------------------------
-- BAŞLATMA
-- ------------------------------------------------------------
function MapFontFix:Initialize()
    -- Bilinçli olarak hemen çalıştırıyoruz
    isRunning = true

    -- Konsolda UI geç oluştuğu için
    -- ilk çalışmayı biraz geciktiriyoruz
    zo_callLater(function()
        self:FixMapFonts()
    end, 1000)
end

-- ------------------------------------------------------------
-- FONT DÜZELTME (ANA DÖNGÜ)
-- ------------------------------------------------------------
function MapFontFix:FixMapFonts()
    if not isRunning then return end

    -- World Map üzerindeki blob isimlerini
    -- periyodik olarak tarıyoruz
    for i = 1, 150 do
        local control = _G["ZO_WorldMapContainerBlobName"..i]
        if control then
            local font = control:GetFont()
            if font and font:find("Handwritten") then
                control:SetFont("EsoTR/fonts/handwritten_bold_tr.slug|34")
            end
        end
    end

    -- 500 ms'de bir tekrar et
    -- (bilinçli olarak durdurulmuyor)
    zo_callLater(function()
        self:FixMapFonts()
    end, 500)
end

-- ------------------------------------------------------------
-- ADDON LOAD
-- ------------------------------------------------------------
local function OnAddonLoaded(event, addonName)
    if addonName ~= "EsoTR" then return end
    EVENT_MANAGER:UnregisterForEvent("EsoTR_MapFontFix", EVENT_ADD_ON_LOADED)

    -- Addon yüklendiğinde otomatik başlat
    MapFontFix:Initialize()
end

EVENT_MANAGER:RegisterForEvent(
    "EsoTR_MapFontFix",
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)
