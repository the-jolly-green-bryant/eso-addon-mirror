-- =============================================================================
-- === OptimalWeave Language File: Turkish (tr.lua)                          ===
-- =============================================================================
--[[
    AddOn Name:         OptimalWeave
    File:               lang/tr.lua
    Description:        Turkish localization using ZO_CreateStringId
    Version:            1.17.0
    Author:             Orollas & VollständigerName
--]]
-- =============================================================================

-- =============================================================================
-- == PANEL & AUTHOR INFORMATION ===============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_PANEL_NAME", "|c6D6D6DOp|r|c8A8A8Atim|r|cA7A7A7al |r|cC4C4C4Wea|r|c6D6D6Dve|r")
ZO_CreateStringId("OW_MENU_AUTHORS", "|cEE82EEO|r|cDD74ECr|r|cCD65EAo|r|cBC57E8l|r|cAB48E6l|r|c9B3AE4a|r|c8A2BE2s|r & |cFFD700Vo|r|cF7D418l|r|cF3D324l|r|cEFD130s|r|cEBD03Ctä|r|cE3CD54n|r|cE0CC60d|r|cDCCA6Ci|r|cD8C978g|r|cD4C784e|r|cD0C690r|r|cCCC49CNa|r|cC4C1B4me|r")
ZO_CreateStringId("OW_MENU_WEBSITE", "https://github.com/VollstaendigerName")

-- =============================================================================
-- == INFORMATION SECTION ======================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_INFO_HEADER", "Bilgi & OKUBENİ")
ZO_CreateStringId("OW_MENU_INFO_TEXT", "OptimalWeave, seçtiğiniz moda dayalı olarak yetenek sıralamasını optimize etmek için akıllı yetenek yönetimi sağlar.\n\n"..
"Blok davranışını tercihlerinize ve oyun tarzınıza uyacak şekilde ayarlamak için alt menülerdeki ayarları özelleştirin.")
ZO_CreateStringId("OW_MENU_MODE_HEADER", "Temel Ayarlar")
ZO_CreateStringId("OW_MENU_CONDITIONS_HEADER", "Aktivasyon Kuralları")
ZO_CreateStringId("OW_MENU_ADVANCED_HEADER", "Gelişmiş Kontroller")
ZO_CreateStringId("OW_MENU_PERFORMANCE_HEADER", "Performans Ayarları")
ZO_CreateStringId("OW_MENU_MODE_ACTIVE", "Eklenti aktif")
ZO_CreateStringId("OW_MENU_MODE_INACTIVE", "Eklenti pasif")
ZO_CreateStringId("OW_MENU_DISABLED_TOOLTIP", "Bu seçenek şu anda devre dışı")
ZO_CreateStringId("OW_MENU_LATENCY_WARNING", "Uyarı: Yüksek gecikme değerleri giriş gecikmesine neden olabilir!")

ZO_CreateStringId("OW_MENU_DISCLAIMER_LABEL", "|cFF0000Uyarı|r") 
ZO_CreateStringId("OW_MENU_DISCLAIMER_TOOLTIP",  "|cFF0000Uyarı:|rBu eklenti ZeniMax Media Inc. veya bağlı kuruluşları tarafından üretilmemiş, onlarla bağlantılı değildir veya desteklenmemektedir. The Elder Scrolls® ve ilgili logoları, ZeniMax Media Inc.'in Amerika Birleşik Devletleri ve/veya diğer ülkelerdeki tescilli ticari markaları veya ticari markalarıdır. Tüm hakları saklıdır.")

-- =============================================================================
-- == CORE SETTINGS ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SETTINGS_HEADER", "Ana Ayarlar")
ZO_CreateStringId("OW_MENU_MODE_LABEL", "Çalışma Modu")
ZO_CreateStringId("OW_MENU_MODE_TOOLTIP", "|c00FF00Sıralı:|r Yetenek kullanımına yalnızca hafif saldırıdan sonra izin verir.\n|cFF0000Katı:|r Katı bloklama. GCD sırasında yetenek sıralaması yok.\n|cFFFF00Akıllı:|r Akıllı bloklama. Kuyrukta Hafif Saldırı yoksa yetenek sıralamasına izin verilir.\n|c00FFFFDevre Dışı:|r Devre dışı.")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_COND", "Sıralı")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_HARD", "Katı")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_SOFT", "Akıllı")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_NONE", "Devre Dışı")
ZO_CreateStringId("OW_MENU_COMBAT_LABEL", "Sadece Savaşta Aktif")
ZO_CreateStringId("OW_MENU_COMBAT_TOOLTIP", "Etkinleştirildiğinde, OptimalWeave sıralamayı sadece savaş sırasında yönetir.")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_LABEL", "Sadece Düşman Hedefle")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_TOOLTIP", "Etkinleştirildiğinde, OptimalWeave sıralamayı sadece seçili bir düşman hedefi varken yönetir.")
ZO_CreateStringId("OW_MENU_BLOCKING_LABEL", "Bloklarken Yoksay")
ZO_CreateStringId("OW_MENU_BLOCKING_TOOLTIP", "Etkinleştirildiğinde, OptimalWeave aktif bloklama sırasında sıralamayı etkilemez.")
ZO_CreateStringId("OW_MENU_GROUNDAOE_LABEL", "Yer Yetenek Çift Kullanımını Engelle")
ZO_CreateStringId("OW_MENU_GROUNDAOE_TOOLTIP", "Aynı yere hedeflenen yeteneğin kısa sürede yanlışlıkla iki kez kuyruğa alınmasını önler.")
ZO_CreateStringId("OW_MENU_DISABLE_TANK", "Tank Olarak Devre Dışı Bırak")
ZO_CreateStringId("OW_MENU_DISABLE_TANK_TOOLTIP", "Tank rolü aktif olduğunda otomatik olarak kapat")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL", "Healer Olarak Devre Dışı Bırak")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL_TOOLTIP", "Healer rolü aktif olduğunda otomatik olarak kapat")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR", "İkinci çubuğundaki özellikleri devre dışı bırak")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR_TOOLTIP", "Eklentinin çoğu özelliğini ikinci silah çubuğunda devre dışı bırakır.")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR", "İkinci çubuğundaki Weave Asistanını devre dışı bırak")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR_TOOLTIP", "İkinci silah çubuğundaki Weave Asistanını (GCD yönetimi) devre dışı bırakır.")

ZO_CreateStringId("OW_MENU_DEACTIVATE_IN_PVP_HEADER", "PvP Devre Dışı Bırakma")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP", "PvP bölgelerinde özellikleri devre dışı bırak")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP_TOOLTIP", "PvP bölgelerinde eklentinin çoğu özelliğini devre dışı bırakır")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP", "PvP'de Weave Asistanını devre dışı bırak")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP_TOOLTIP", "PvP bölgelerinde Weave Asistanını (GCD yönetimi) devre dışı bırakır")

-- =============================================================================
-- == BLOCK ID SETTINGS ========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKED_HEADER", "Engellenen Yetenekler")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_LABEL", "Yeni ID Engelle")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_TOOLTIP", "Bir Yetenek ID'si girin (örn: 134160)")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_LABEL", "Şu Anda Engellenen ID'ler")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_TOOLTIP", "Kaldırmak için tıklayın")

-- =============================================================================
-- == ADVANCED SETTINGS ========================================================
-- =============================================================================    
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL", "Anlık Büyü Tamponu (ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL_TOOLTIP", "Anlık yetenekler için güvenlik payı (0-100ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED", "Kanalize Tamponu (ms)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED_TOOLTIP", "Kanalize yetenekler için tampon süresi (0-400ms)")
ZO_CreateStringId("OW_MENU_GCD_SLOT", "GCD Takip Slotu")
ZO_CreateStringId("OW_MENU_GCD_SLOT_TOOLTIP", "GCD algılama için aksiyon çubuğu slotu (1-8)")
ZO_CreateStringId("OW_MENU_MIN_GCD", "Minimum GCD Süresi (ms)")
ZO_CreateStringId("OW_MENU_MIN_GCD_TOOLTIP", "Algılama için minimum GCD süresi (0-20ms)")
ZO_CreateStringId("OW_MENU_RESET_TIME_LABEL", "Sıfırlama Süresi (saniye)")
ZO_CreateStringId("OW_MENU_RESET_TIME_TOOLTIP", "Bu kadar saniye boyunca hiçbir şey yapılmadıktan sonra takibi sıfırlar.")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_LABEL", "Otomatik GCD Takip Slotu")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_TOOLTIP", "3-8 slotları arasından en iyi GCD takip slotunu otomatik seçer")
ZO_CreateStringId("OW_MENU_QUEUE_TIME", "Temel Kuyruk Süresi (ms)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME_TOOLTIP", "Varsayılan giriş kuyruk penceresi (100-2000ms)")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_LABEL", "Silah değişiminde sıfırla")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_TOOLTIP", "Silah değişiminde GCD'yi sıfırlar")
ZO_CreateStringId("OW_MENU_RESETONDODGE_LABEL", "Savurma sırasında sıfırla")
ZO_CreateStringId("OW_MENU_RESETONDODGE_TOOLTIP", "Savurma sırasında GCD'yi sıfırlar")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_LABEL", "Silahı otomatik çek")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_TOOLTIP", "Savaşta iken silahları otomatik çek")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_LABEL", "Hepsini Sıfırla")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_TOOLTIP", "Tüm ayarları varsayılan değerlere sıfırlar")

-- =============================================================================
-- == LATENCY COMPENSATION =====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_LATENCY_HEADER", "Gecikme Telafisi")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_LABEL", "Otomatik Gecikme Ayarlaması")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_TOOLTIP", "Mevcut gecikmeye dayalı otomatik zamanlama ayarlaması. Sabit bağlantı için önerilir.")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_LABEL", "Manuel Giriş Gecikmesi (ms)")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_TOOLTIP", "Sabit gecikme değeri (0-200ms). Sadece otomatik mod devre dışı olduğunda kullanılır.")

-- =============================================================================
-- == (SUB)CLASS SETTINGS ======================================================
-- =============================================================================

-- == Grim Focus SETTINGS ======================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_HEADER", "Sınıf ve Lonca Özel Ayarları")
ZO_CreateStringId("OW_MENU_SUBCLASS_GRIMFOCUS", "Kasvetli Odak")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS", "Gerekli Yığınlar")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS_TOOLTIP", "Kasvetli Odak'ın aktif hale gelmesi için gereken yığın sayısı (Önerilen: 10)")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS", "Tüm Kasvetli Odak Morflarını Engelle")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS_TOOLTIP", "|cFF5555• Amansız Odak:|r Her zaman engellenir\n|cFFFF00• Kasvetli Odak ve Acımasız Azim:|r Sadece 10 yığında kullanılabilir\n|cAAAAAADevre Dışı Bırak:|r Tüm morflar için varsayılan davranış")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE", "Özel Yığınları Etkinleştir")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE_TOOLTIP", "|cFFD700Etkin:|r Yığın ayarını kullanır \n"..
                  "|cAAAAAADevre Dışı:|r Kasvetli Odak ve Acımasız Azim'i her zaman 10 yığına kadar engeller, Amansız Odak'ı her zaman engeller\n")

-- == BLOCK GUILDS SETTINGS ===================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_GUILDS", "Loncalar")

ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS", "Savaşçı Loncası Avcı Yeteneklerini Engelle")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS_TOOLTIP", "Savaşçı Loncası avcı yeteneklerinin tüm morflarını engeller (Uzman Avcı, Kamuflaj Avcı & Kötülük Avcısı)")

ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS", "Büyücü Loncası Işık Yeteneklerini Engelle")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS_TOOLTIP", "Işık yeteneklerinin tüm morflarını engeller (Büyü Işığı, İçsel Işık & Parlak Büyü Işığı)")      

ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS", "PvP'de Devre Dışı Bırak")
ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS_TOOLTIP", "PvP bölgelerinde Avcı/Işık yetenek engellemesini devre dışı bırakır")

-- == BLOCK MOLTEN WHIP SETTINGS ===============================================
ZO_CreateStringId("OW_MENU_SUBCLASS_MOLTENWHIP", "Erimiş Kırbaç")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK", "Erimiş Kırbaç Yeteneğini Engelle")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK_TOOLTIP", "Üç yığını kaybetmemek için Erimiş Kırbaç yeteneğini engeller.")      

-- == BLOCK FATECARVER SETTINGS ================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_FATECARVER", "Kader Oymacısı")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS", "Kader Oymacısı'nı Engelle")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS_TOOLTIP", "Koşullar sağlanana kadar Kader Oymacısı'nın kullanılmasını önler.")
ZO_CreateStringId("OW_MENU_CRUX_STACKS", "Gerekli Crux Yığınları")
ZO_CreateStringId("OW_MENU_CRUX_STACKS_TOOLTIP", "Kader Oymacısı kullanılabilmesi için minimum Crux yığın sayısı (Önerilen: 3)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM", "HP Eşik Değeri (%)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOLTIP", "HP bu değerin altındayken Kader Oymacısı engellemesini devre dışı bırak")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE", "Kader Oymacısı için HP Kontrolünü Etkinleştir")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE_TOOLTIP", "Düşük sağlıkta Kader Oymacısı engellemesini devre dışı bırakır")

ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM", "Dayanıklılık Eşik Değeri (%)")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOLTIP", "Düşük dayanıklılıkta Fatecarver engellemesini devre dışı bırak")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE", "Fatecarver için Dayanıklılık Kontrolünü Etkinleştir")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE_TOOLTIP", "Düşük dayanıklılıkta Fatecarver engellemesini devre dışı bırakır")

-- == BLOCK CEPHALIARCH'S FLAIL SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_CEPHALIARCHSFLAIL", "Kefaliark'ın Döveni")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL", "Kefaliark'ın Dövenini Engelle")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL_TOOLTIP", "3 Crux yığını olduğunda Kefaliark'ın Dövenini engeller")

-- == BLOCK TENTACULAR DREAD SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_TENTACULAR", "Dokunsal Dehşet")
ZO_CreateStringId("OW_MENU_TENTACULAR", "Dokunsal Dehşet'i Engelle")
ZO_CreateStringId("OW_MENU_TENTACULAR_TOOLTIP", "Koşullar sağlanana kadar Dokunsal Dehşet yeteneğini engeller.")

-- == Execute Check Settings ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_HEADER", "Execute Kontrolü")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE", "Execute Kontrolünü Etkinleştir")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE_TOOLTIP", "Execute kontrol özelliğini etkinleştirir veya devre dışı bırakır")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD", "Execute Eşik Değeri (%)")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD_TOOLTIP", "Execute büyülerine izin verilen hedef sağlık yüzdesi")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELLS_HEADER", "Execute Büyüleri")

-- == Grouped Execute Spells ==========================================
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS", "Parlak Yıkım, Parlak İhtişam, Parlak Baskı")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS_TOOLTIP", "Hedef execute aralığında olana kadar Parlak Yıkım morflarını engeller")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS", "Suikastçı Bıçağı, Kazığa Oturtma, Katil Bıçağı")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS_TOOLTIP", "Hedef execute aralığında olana kadar Suikastçı Bıçağı morflarını engeller")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS", "Büyücülerin Gazabı, Büyücülerin Öfkesi, Sonsuz Öfke")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS_TOOLTIP", "Hedef execute aralığında olana kadar Büyücülerin Öfkesi morflarını engeller")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS", "Ters Kesik, Ters Dilim, Cellat")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS_TOOLTIP", "Hedef execute aralığında olana kadar Ters Kesik morflarını engeller")

-- == Work in progress ================================================
ZO_CreateStringId("OW_WIP", "Geliştirme Aşamasında")

-- =============================================================================
-- == WEAPON SETTINGS ==========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEADER", "Silah Tipine Göre Devre Dışı Bırakma")

ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON", "Silah Tipinde Weave Asistanını Devre Dışı Bırak")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON_TOOLTIP", "Sadece seçilen silah tipleri için Weave Asistanını (GCD yönetimi) devre dışı bırakır")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON", "Silah Tipinde Özellikleri Devre Dışı Bırak")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON_TOOLTIP", "Seçilen silah tipleri için eklentinin çoğu özelliğini devre dışı bırakır")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE", "Balta")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE_TOOLTIP", "Balta kuşanıldığında devre dışı bırak")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER", "Çekiç")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER_TOOLTIP", "Çekiç kuşanıldığında devre dışı bırak")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD", "Kılıç")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD_TOOLTIP", "Kılıç kuşanıldığında devre dışı bırak")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER", "Hançer")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER_TOOLTIP", "Hançer kuşanıldığında devre dışı bırak")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD", "İki Ellik Kılıç")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD_TOOLTIP", "İki ellik kılıç kuşanıldığında devre dışı bırak")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE", "İki Ellik Balta")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE_TOOLTIP", "İki ellik balta kuşanıldığında devre dışı bırak")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER", "İki Ellik Çekiç")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER_TOOLTIP", "İki ellik çekiç kuşanıldığında devre dışı bırak")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW", "Yay")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW_TOOLTIP", "Yay kuşanıldığında devre dışı bırak")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF", "Ateş Asası")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF_TOOLTIP", "Ateş asası kuşanıldığında devre dışı bırak")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF", "Buz Asası")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF_TOOLTIP", "Buz asası kuşanıldığında devre dışı bırak")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF", "Yıldırım Asası")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF_TOOLTIP", "Yıldırım asası kuşanıldığında devre dışı bırak")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF", "İyileştirme Asası")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF_TOOLTIP", "İyileştirme asası kuşanıldığında devre dışı bırak")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD", "Kalkan")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD_TOOLTIP", "Kalkan kuşanıldığında devre dışı bırak")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE", "Rün")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE_TOOLTIP", "Rün kuşanıldığında devre dışı bırak")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE", "Silah Yok")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE_TOOLTIP", "Silah kuşanılmadığında devre dışı bırak")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED", "Rezerve Silah")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED_TOOLTIP", "Rezerve silah tipi kuşanıldığında devre dışı bırak")

-- =============================================================================
-- == CUSTOM BLOCK LIST SETTINGS ===============================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLIST_HEADER", "Özel Engelleme Listeleri")
ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_HEADER", "Özel Engelleme Listesi")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_DESC", "Kullanılmasını engellemek için büyü ID'leri ekleyin. Ayrıca, eylem çubuğu yuvasına sağ tıklayarak büyüler ekleyebilirsiniz (yeniden yükleme gerektirir)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_LABEL", "Yetenek ID")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP", "Sayısal yetenek ID'sini girin (örn: 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_ADD_BUTTON", "Engelleme Listesine Ekle")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_LIST_HEADER", "Engellenen Yetenekler:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST", "Özel Engelleme Listesini Etkinleştir")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_TOOLTIP", "Özel engelleme listesi işlevselliğini etkinleştirir veya devre dışı bırakır")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SV_DESC", "SavedVariables dosyanızı kontrol edin:\n customBlockList = {\n   [YetenekID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK", "Engelleme Listesi için Sağlık Kontrolünü Etkinleştir")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "Etkinleştirildiğinde, engelleme listesindeki büyüler yalnızca sağlığınız eşiğin üzerindeyse engellenecektir.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT", "Engelleme Listesi için Sağlık Eşiği (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Engelleme listesindeki büyüler yalnızca sağlığınız bu yüzdenin üzerindeyse engellenir.")

-- =============================================================================
-- == CUSTOM RECAST BLOCK LIST SETTINGS ========================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLERECASTBLOCK_HEADER", "Özel Yeniden Kullanım Engelleme Listesi")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_DESC", "Büyü ID'leri ekleyerek, kalan etki süresi eşik değerin altına düşene kadar yeniden kullanılmalarını engelleyin. Ayrıca, eylem çubuğu yuvasına sağ tıklayarak büyüler ekleyebilirsiniz (yeniden yükleme gerektirir).")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_LABEL", "Yetenek ID")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_TOOLTIP", "Sayısal yetenek ID'sini girin (örn: 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_ADD_BUTTON", "Yeniden Kullanım Engelleme Listesine Ekle")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_LIST_HEADER", "Yeniden Kullanım Engellenen Yetenekler:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST", "Özel Yeniden Kullanım Engelleme Listesini Etkinleştir")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_TOOLTIP", "Özel yeniden kullanım engelleme listesi işlevselliğini etkinleştirir veya devre dışı bırakır")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME", "Yeniden Kullanım Engelleme Süresi (s)")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME_TOOLTIP", "Yeniden kullanım engelleme listesindeki bir yeteneğin tekrar kullanılabileceği saniye cinsinden süre (1.0 = 1 saniye)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SV_DESC", "SavedVariables dosyanızı kontrol edin:\n customRecastBlockList = {\n   [YetenekID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK", "Yeniden Kullanım Engelleme Listesi için Sağlık Kontrolünü Etkinleştir")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "Etkinleştirildiğinde, yeniden kullanım engelleme listesindeki büyüler yalnızca sağlığınız eşiğin üzerindeyse engellenecektir.")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT", "Yeniden Kullanım Engelleme Listesi için Sağlık Eşiği (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "Yeniden kullanım engelleme listesindeki büyüler yalnızca sağlığınız bu yüzdenin üzerindeyse engellenir.")

-- =============================================================================

ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_MAIN_TEXT", "Yetenek ID'si eklendi/kaldırıldı. Daha fazla yetenek eklemek veya kaldırmak istemiyorsanız, değişikliklerin görüntülenmesi için lütfen arayüzü yeniden yükleyin.")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_YES", "Arayüzü yeniden yükle")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_LATER", "Sonra")

ZO_CreateStringId("OW_MENU_DIALOG_BUTTON_OK", "TAMAM")
ZO_CreateStringId("OW_MENU_INVALID_ID_DIALOG_MAIN_TEXT", "Hata: Lütfen geçerli bir yetenek ID'si girin")
ZO_CreateStringId("OW_MENU_ID_NOT_EXIST_DIALOG_MAIN_TEXT", "Yetenek ID'si mevcut değil")
ZO_CreateStringId("OW_MENU_ID_IS_IN_SV_DIALOG_MAIN_TEXT", "Yetenek ID'si zaten engelleme listesinde")

-- =============================================================================
-- == RESOURCE-BASED BLOCK LIST SETTINGS =======================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_RESOURCE_HEADER", "Kaynak Tabanlı Engelleme Listesi")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_RESOURCE_DESC", "Birincil kaynağınız (Büyü veya Dayanıklılık) eşiğin altındayken engellemek için yetenek ID'leri ekleyin. Ayrıca, aksiyon çubuğu yuvasına sağ tıklayarak yetenek ekleyebilirsiniz (yeniden yükleme gerektirir).")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST", "Kaynak Tabanlı Engelleme Listesini Etkinleştir")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST_TOOLTIP", "Kaynak tabanlı engelleme listesi işlevini etkinleştirir veya devre dışı bırakır")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK", "Kaynak Kontrolünü Etkinleştir")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK_TOOLTIP", "Etkinleştirildiğinde, kaynak engelleme listesindeki yetenekler yalnızca birincil kaynağınız (Büyü veya Dayanıklılık) eşiğin üstündeyse engellenir.")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT", "Kaynak Eşiği (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT_TOOLTIP", "Kaynak engelleme listesindeki yetenekler yalnızca birincil kaynağınız (Büyü veya Dayanıklılık) bu yüzdenin üstündeyse engellenir.")
ZO_CreateStringId("OW_MENU_RESOURCE_BLOCK_SPELL", "Yetenek: ")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK", "Büyü Kontrolü")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK_TOOLTIP", "Bu yetenek için Büyü tabanlı engellemeyi etkinleştir")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE", "Büyü eşiğin altındayken engelle")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE_TOOLTIP", "Büyü eşiğin altındayken yeteneği engelle (yalnızca altındayken izin vermek için işareti kaldırın)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD", "Büyü Eşiği (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD_TOOLTIP", "Büyü yüzde eşiği")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK", "Dayanıklılık Kontrolü")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK_TOOLTIP", "Bu yetenek için Dayanıklılık tabanlı engellemeyi etkinleştir")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE", "Dayanıklılık eşiğin altındayken engelle")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE_TOOLTIP", "Dayanıklılık eşiğin altındayken yeteneği engelle (yalnızca altındayken izin vermek için işareti kaldırın)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD", "Dayanıklılık Eşiği (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD_TOOLTIP", "Dayanıklılık yüzde eşiği")

-- =============================================================================
-- == KEYBINDINGS LOCALIZATION =================================================
-- =============================================================================

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_OPTIMALWEAVE", "|c6D6D6DOpti|r|c8A8A8AmalWea|r|cC4C4C4ve|r")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_MODE", "Mod Değiştir (Katı/Akıllı/Devre Dışı)")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_BLOCK_LIST", "Özel Engelleme Listesini Değiştir")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_RECAST_BLOCK_LIST", "Özel Yeniden Kullanım Engelleme Listesini Değiştir")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_FEATURES", "Arka Çubuk Özelliklerini Değiştir")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_WEAVE_ASSIST", "Arka Çubuk Weave Asistanını Değiştir")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_EXECUTE_CHECK", "Execute Kontrolünü Değiştir")

-- =============================================================================
-- == REMOVE BUTTON ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_BUTTON", "Kaldır")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_TOOLTIP", "Bu yeteneği engelleme listesinden kaldır (/reloadui gerekli)")

-- =============================================================================
-- == SETTIINGS MODE ===========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_MODE_SELECTION_LABEL", "Ayarlar Modu")
ZO_CreateStringId("OW_MENU_MODE_SELECTION_TOOLTIP", "Ayarların bu hesaptaki tüm karakterler arasında paylaşılmasını mı (Hesap geneli) yoksa her karakter için ayrı ayrı mı (Karaktere özel) saklanmasını istediğinizi seçin.")
ZO_CreateStringId("OW_MENU_MODE_ACCOUNTWIDE", "Hesap geneli")
ZO_CreateStringId("OW_MENU_MODE_PERCHARACTER", "Karaktere özel")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_SETTINGS_MAIN_TEXT", "Ayarlar modu değiştirildi. Değişiklikleri uygulamak için arayüz yeniden yüklensin mi?")

-- =============================================================================
-- == IN COMBAT MENU BLOCKING ==================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU", "Savaşta Son Menüyü Engelle")
ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU_TOOLTIP", "Savaş sırasında son menünün (ALT) açılmasını engeller.")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU", "Savaşta Karakter Menüsünü Engelle")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU_TOOLTIP", "Savaş sırasında karakter menüsünün (C) açılmasını engeller.")

-- =============================================================================
-- == GCD DISPLAY ==============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SHOW_GCD_LABEL", "Küresel Bekleme Süresini (GCD) Göster")
ZO_CreateStringId("OW_MENU_SHOW_GCD_TOOLTIP", "Eylem çubuğunun üzerinde GCD göstergesini (ZOS tarafından sağlanır) görüntüler.")

-- =============================================================================
-- == BLOCKLIST COMBAT ONLY ====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_LABEL", "Engel listeleri yalnızca savaşta")
ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_TOOLTIP", "Tüm özel engel listeleri yalnızca savaş halindeyken aktiftir. Savaş dışında, tüm engel listeleri devre dışıdır.")

-- =============================================================================
-- === END OF TURKISH LOCALIZATION =============================================
-- =============================================================================