-- =============================================================================
-- === OptimalWeave Language File: Thai (th.lua)                              ===
-- =============================================================================
--[[
    AddOn Name:         OptimalWeave
    File:               lang/th.lua
    Description:        Thai localization using ZO_CreateStringId
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

ZO_CreateStringId("OW_MENU_INFO_HEADER", "ข้อมูล & README")
ZO_CreateStringId("OW_MENU_INFO_TEXT", "เวลาคูลดาวน์รวม (GCD) คือ 1000 มิลลิวินาที OptimalWeave ช่วยจัดการการจัดคิวความสามารถตามโหมดที่เลือกเพื่อเพิ่มประสิทธิภาพการโจมตีแบบวีฟ ใช้การตั้งค่าด้านล่างเพื่อปรับแต่งการทำงาน")
ZO_CreateStringId("OW_MENU_MODE_HEADER", "กลไกหลัก")
ZO_CreateStringId("OW_MENU_CONDITIONS_HEADER", "กฎการเปิดใช้งาน")
ZO_CreateStringId("OW_MENU_ADVANCED_HEADER", "การควบคุมขั้นสูง")
ZO_CreateStringId("OW_MENU_PERFORMANCE_HEADER", "การตั้งค่าประสิทธิภาพ")
ZO_CreateStringId("OW_MENU_MODE_ACTIVE", "ส่วนเสริมทำงาน")
ZO_CreateStringId("OW_MENU_MODE_INACTIVE", "ส่วนเสริมไม่ทำงาน")
ZO_CreateStringId("OW_MENU_DISABLED_TOOLTIP", "ตัวเลือกนี้ถูกปิดใช้งานอยู่ในขณะนี้")
ZO_CreateStringId("OW_MENU_LATENCY_WARNING", "คำเตือน: ค่าความหน่วงสูงอาจทำให้เกิดความล่าช้าในการป้อนข้อมูล!")

ZO_CreateStringId("OW_MENU_DISCLAIMER_LABEL", "|cFF0000ข้อจำกัดความรับผิดชอบ|r") 
ZO_CreateStringId("OW_MENU_DISCLAIMER_TOOLTIP",  "|cFF0000ข้อจำกัดความรับผิดชอบ:|r ส่วนเสริมนี้ไม่ได้สร้าง เกี่ยวข้อง หรือได้รับการสนับสนุนโดย ZeniMax Media Inc. The Elder Scrolls® และโลโก้ที่เกี่ยวข้องเป็นเครื่องหมายการค้าจดทะเบียนของ ZeniMax Media Inc. ในสหรัฐอเมริกาและ/หรือประเทศอื่นๆ สงวนลิขสิทธิ์")

-- =============================================================================
-- == CORE SETTINGS ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SETTINGS_HEADER", "การตั้งค่าหลัก")
ZO_CreateStringId("OW_MENU_MODE_LABEL", "โหมดการทำงาน")
ZO_CreateStringId("OW_MENU_MODE_TOOLTIP", "|c00FF00Sequential:|r อนุญาตให้ใช้ความสามารถหลังจากทำ Light Attack เท่านั้น\n|cFF0000Strict:|r บล็อกแบบเข้มงวด ไม่มีการจัดคิวสกิลระหว่าง GCD\n|cFFFF00Intelligent:|r บล็อกอัจฉริยะ อนุญาตจัดคิวสกิลก็ต่อเมื่อไม่มี Light Attack ในคิว\n|c00FFFFDisabled:|r ปิดใช้งาน")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_COND", "Sequential")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_HARD", "Strict")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_SOFT", "Intelligent")
ZO_CreateStringId("OW_MENU_MODE_CHOICE_NONE", "Disabled")
ZO_CreateStringId("OW_MENU_COMBAT_LABEL", "ทำงานเฉพาะในการต่อสู้")
ZO_CreateStringId("OW_MENU_COMBAT_TOOLTIP", "หากเลือก OptimalWeave จะจัดการการจัดคิวความสามารถเฉพาะในช่วงการต่อสู้เท่านั้น")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_LABEL", "ทำงานเฉพาะกับเป้าหมายศัตรู")
ZO_CreateStringId("OW_MENU_ENEMYTARGET_TOOLTIP", "ต้องมีเป้าหมายศัตรูจึงจะจัดการการจัดคิว")
ZO_CreateStringId("OW_MENU_BLOCKING_LABEL", "ละเว้นขณะบล็อก")
ZO_CreateStringId("OW_MENU_BLOCKING_TOOLTIP", "ปิดการควบคุมระหว่างการบล็อก")
ZO_CreateStringId("OW_MENU_GROUNDAOE_LABEL", "บล็อกการกดซ้ำความสามารถพื้นที่")
ZO_CreateStringId("OW_MENU_GROUNDAOE_TOOLTIP", "ป้องกันการกดซ้ำโดยไม่ได้ตั้งใจของความampuan ที่กำหนดเป้าหมายพื้นที่")
ZO_CreateStringId("OW_MENU_DISABLE_TANK", "ปิดใช้งานเมื่อเป็น Tank")
ZO_CreateStringId("OW_MENU_DISABLE_TANK_TOOLTIP", "ปิดอัตโนมัติเมื่อบทบาท Tank ทำงาน")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL", "ปิดใช้งานเมื่อเป็น Healer")
ZO_CreateStringId("OW_MENU_DISABLE_HEAL_TOOLTIP", "ปิดอัตโนมัติเมื่อบทบาท Healer ทำงาน")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR", "ปิดฟีเจอร์บนแถบอาวุธที่สอง")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_BACKBAR_TOOLTIP", "ปิดฟีเจอร์ส่วนใหญ่ของส่วนเสริมบนแถบอาวุธที่สอง")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR", "ปิดตัวช่วยวีฟบนแถบอาวุธที่สอง")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_BACKBAR_TOOLTIP", "ปิดตัวช่วยวีฟ (การจัดการ GCD) บนแถบอาวุธที่สอง")

ZO_CreateStringId("OW_MENU_DEACTIVATE_IN_PVP_HEADER", "การปิดใช้งานใน PvP")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP", "ปิดฟีเจอร์ใน PvP")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_IN_PVP_TOOLTIP", "ปิดฟีเจอร์ส่วนใหญ่ของส่วนเสริมในพื้นที่ PvP")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP", "ปิดตัวช่วยวีฟใน PvP")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_IN_PVP_TOOLTIP", "ปิดตัวช่วยวีฟ (การจัดการ GCD) ในพื้นที่ PvP")

ZO_CreateStringId("OW_MENU_BLOCKAOEIFNOTARGET_LABEL", "บล็อก AoE เมื่อไม่มีเป้าหมาย")
ZO_CreateStringId("OW_MENU_BLOCKAOEIFNOTARGET_TOOLTIP", "บล็อกความสามารถที่กำหนดเป้าหมายพื้นที่เมื่อไม่มีเป้าหมายที่เลือก")

-- =============================================================================
-- == BLOCK ID SETTINGS ========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKED_HEADER", "ความสามารถที่ถูกบล็อก")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_LABEL", "บล็อก ID ใหม่")
ZO_CreateStringId("OW_MENU_BLOCKED_ADD_TOOLTIP", "ป้อน ID ความสามารถ (เช่น 134160)")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_LABEL", "ID ที่ถูกบล็อกอยู่ในขณะนี้")
ZO_CreateStringId("OW_MENU_BLOCKED_LIST_TOOLTIP", "คลิกเพื่อลบ")

-- =============================================================================
-- == ADVANCED SETTINGS ========================================================
-- =============================================================================
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL", "บัฟเฟอร์คาถาทันที (มิลลิวินาที)")
ZO_CreateStringId("OW_MENU_CHANNEL_NORMAL_TOOLTIP", "ระยะปลอดภัยสำหรับความสามารถทันที (0-100 มิลลิวินาที)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED", "บัฟเฟอร์ความสามารถแบบช่องทาง (มิลลิวินาที)")
ZO_CreateStringId("OW_MENU_CHANNEL_CHANNELED_TOOLTIP", "บัฟเฟอร์สำหรับสกิลแบบช่องทาง (0-400 มิลลิวินาที)")
ZO_CreateStringId("OW_MENU_GCD_SLOT", "ช่องติดตาม GCD")
ZO_CreateStringId("OW_MENU_GCD_SLOT_TOOLTIP", "ช่องแถบปฏิบัติการสำหรับตรวจจับ GCD (3-8)")
ZO_CreateStringId("OW_MENU_MIN_GCD", "เกณฑ์ GCD ขั้นต่ำ (มิลลิวินาที)")
ZO_CreateStringId("OW_MENU_MIN_GCD_TOOLTIP", "ระยะเวลา GCD ขั้นต่ำที่จะตรวจจับ (0-20 มิลลิวินาที)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME", "เวลาในคิวพื้นฐาน (มิลลิวินาที)")
ZO_CreateStringId("OW_MENU_QUEUE_TIME_TOOLTIP", "หน้าต่างคิวอินพุตเริ่มต้น (100-2000 มิลลิวินาที)")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_LABEL", "รีเซ็ตเมื่อสลับแถบอาวุธ")
ZO_CreateStringId("OW_MENU_RESETONBARSWAP_TOOLTIP", "รีเซ็ต GCD เมื่อสลับแถบอาวุธ")
ZO_CreateStringId("OW_MENU_RESETONDODGE_LABEL", "รีเซ็ตเมื่อหลบ")
ZO_CreateStringId("OW_MENU_RESETONDODGE_TOOLTIP", "รีเซ็ต GCD เมื่อหลบ")
ZO_CreateStringId("OW_MENU_RESET_TIME_LABEL", "เวลารีเซ็ต (วินาที)")
ZO_CreateStringId("OW_MENU_RESET_TIME_TOOLTIP", "รีเซ็ตการติดตามหลังจากไม่ได้ร่ายอะไรเลยเป็นเวลาหลายวินาทีนี้")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_LABEL", "ช่องติดตาม GCD อัตโนมัติ")
ZO_CreateStringId("OW_MENU_AUTO_GCD_SLOT_TOOLTIP", "เลือกช่องติดตาม GCD ที่ดีที่สุดจากช่อง 3-8 โดยอัตโนมัติ")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_LABEL", "ชักอาวุธอัตโนมัติ")
ZO_CreateStringId("OW_MENU_AUTO_EQUIP_WEAPONS_TOOLTIP", "ชักอาวุธโดยอัตโนมัติเมื่ออยู่ในการต่อสู้")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_LABEL", "รีเซ็ตทั้งหมด")
ZO_CreateStringId("OW_MENU_RESET_SETTINGS_TOOLTIP", "รีเซ็ตการตั้งค่าทั้งหมดเป็นค่าเริ่มต้น")

-- =============================================================================
-- == LATENCY COMPENSATION =====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_LATENCY_HEADER", "การชดเชยความหน่วง")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_LABEL", "ปรับความหน่วงอัตโนมัติ")
ZO_CreateStringId("OW_MENU_AUTOLATENCY_TOOLTIP", "ปรับเวลาตามความหน่วงปัจจุบันอัตโนมัติ แนะนำสำหรับการเชื่อมต่อที่เสถียร")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_LABEL", "ป้อนความหน่วงด้วยตนเอง (มิลลิวินาที)")
ZO_CreateStringId("OW_MENU_MANUALLATENCY_TOOLTIP", "ค่าความหน่วงคงที่ (0-200 มิลลิวินาที) ใช้เฉพาะเมื่อปิดโหมดอัตโนมัติ")

-- =============================================================================
-- == (SUB)CLASS SETTINGS ======================================================
-- =============================================================================

-- == Grim Focus SETTINGS ======================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_HEADER", "การตั้งค่าเฉพาะคลาสและกิลด์")
ZO_CreateStringId("OW_MENU_SUBCLASS_GRIMFOCUS", "Grim Focus")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS", "จำนวน Stack ที่ต้องการ")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_STACKS_TOOLTIP", "จำนวน Stack ที่ต้องมีก่อนที่ Grim Focus จะสามารถเปิดใช้งานได้ (แนะนำ: 10)")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS", "บล็อก Grim Focus ทุก Morph")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_ALL_MORPHS_TOOLTIP", "|cFF5555• Relentless Focus:|r ถูกบล็อกเสมอ\n|cFFFF00• Grim Focus และ Merciless Resolve:|r ใช้ได้เฉพาะที่ 10 Stack\n|cAAAAAADisable:|r พฤติกรรมเริ่มต้นสำหรับทุก Morph")

ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE", "เปิดใช้งาน Stack แบบกำหนดเอง")
ZO_CreateStringId("OW_MENU_GRIMFOCUS_GRIMFOCUSSTACKS_TOOGLE_TOOLTIP", "|cFFD700เปิดใช้งาน:|r ใช้การตั้งค่า Stack แบบกำหนดเอง \n" ..
                  "|cAAAAAAปิดใช้งาน:|r บล็อก Grim Focus และ Merciless Resolve เสมอจนถึง 10 Stack และบล็อก Relentless Focus เสมอ\n")

-- == BLOCK GUILDS SETTINGS ===================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_GUILDS", "กิลด์")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS", "บล็อกสกิล Hunter ของ Fighter's Guild")
ZO_CreateStringId("OW_MENU_HUNTER_ALL_MORPHS_TOOLTIP", "บล็อกทุก Morph ของสกิล Hunter ของ Fighter's Guild (Expert Hunter, Camouflaged Hunter & Evil Hunter)")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS", "บล็อกสกิล Light ของ Mage's Guild")
ZO_CreateStringId("OW_MENU_LIGHT_ALL_MORPHS_TOOLTIP", "บล็อกทุก Morph ของสกิล Light (Magelight, Inner Light & Radiant Magelight)")   

ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS", "ปิดใช้งานใน PvP")
ZO_CreateStringId("OW_MENU_DEACTIVATEHUNTERLIGHTINPVP_ALL_MORPHS_TOOLTIP", "ปิดการบล็อกความสามารถ Hunter/Light ในพื้นที่ PvP")

-- == BLOCK MOLTEN WHIP SETTINGS ===============================================
ZO_CreateStringId("OW_MENU_SUBCLASS_MOLTENWHIP", "Molten Whip")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK", "บล็อกสกิล Molten Whip")
ZO_CreateStringId("OW_MENU_MOLTENWHIP_BLOCK_TOOLTIP", "บล็อกสกิล Molten Whip เพื่อป้องกันการเสียสาม Stack")

-- == BLOCK FATECARVER SETTINGS ================================================
ZO_CreateStringId("OW_MENU_SUBCLASS_FATECARVER", "Arcanist Fatecarver")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS", "บล็อกการร่าย Fatecarver")
ZO_CreateStringId("OW_MENU_FATECARVER_ALL_MORPHS_TOOLTIP", "ป้องกันการร่าย Fatecarver จนกว่าเงื่อนไขจะสำเร็จ")
ZO_CreateStringId("OW_MENU_CRUX_STACKS", "จำนวน Crux Stack ที่ต้องการ")
ZO_CreateStringId("OW_MENU_CRUX_STACKS_TOOLTIP", "Crux Stack ขั้นต่ำก่อนที่จะร่าย Fatecarver ได้ (แนะนำ: 3)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM", "เกณฑ์ HP (%)")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOLTIP", "ปิดการบล็อก Fatecarver เมื่อ HP ต่ำกว่าค่านี้")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE", "เปิดใช้งานการตรวจสอบ HP สำหรับ Fatecarver")
ZO_CreateStringId("OW_MENU_CHECK_HP_FOR_BEAM_TOOGLE_TOOLTIP", "ปิดการบล็อก Fatecarver เมื่อพลังชีวิตของคุณต่ำ")

ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM", "เกณฑ์ Stamina (%)")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOLTIP", "ปิดการบล็อก Fatecarver เมื่อ Stamina ต่ำ")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE", "เปิดใช้งานการตรวจสอบ Stamina สำหรับ Fatecarver")
ZO_CreateStringId("OW_MENU_CHECK_STAMINA_FOR_BEAM_TOOGLE_TOOLTIP", "ปิดการบล็อก Fatecarver เมื่อความอดทนของคุณต่ำ")

-- == BLOCK CEPHALIARCH'S FLAIL SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_CEPHALIARCHSFLAIL", "Cephaliarch's Flail")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL", "บล็อก Cephaliarch's Flail")
ZO_CreateStringId("OW_MENU_CEPHALIARCHSFLAIL_TOOLTIP", "บล็อก Cephaliarch's Flail เมื่อคุณมี Crux 3 Stack")

-- == BLOCK TENTACULAR DREAD SETTINGS ==========================================
ZO_CreateStringId("OW_MENU_SUBCLASS_TENTACULAR", "Tentacular Dread")
ZO_CreateStringId("OW_MENU_TENTACULAR", "บล็อก Tentacular Dread")
ZO_CreateStringId("OW_MENU_TENTACULAR_TOOLTIP", "บล็อกสกิล Tentacular Dread จนกว่าเงื่อนไขจะสำเร็จ")

-- == Execute Check Settings ================================================
ZO_CreateStringId("OW_MENU_EXECUTE_HEADER", "การตรวจสอบ Execute")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE", "เปิดใช้งานการตรวจสอบ Execute")
ZO_CreateStringId("OW_MENU_EXECUTE_ENABLE_TOOLTIP", "เปิดหรือปิดฟีเจอร์การตรวจสอบ Execute")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD", "เกณฑ์ Execute (%)")
ZO_CreateStringId("OW_MENU_EXECUTE_THRESHOLD_TOOLTIP", "เปอร์เซ็นต์พลังชีวิตของเป้าหมายที่ต่ำกว่าซึ่งอนุญาตให้ใช้คาถา Execute")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELLS_HEADER", "คาถา Execute")

-- == Grouped Execute Spells ================================================
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS", "Radiant Destruction, Radiant Glory, Radiant Oppression")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_RADIANTMORPHS_TOOLTIP", "บล็อก Morph ของ Radiant Destruction จนกว่าเป้าหมายจะอยู่ในช่วง Execute")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS", "Assassin's Blade, Impale, Killer's Blade")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_ASSASSINSBLADEMORPHS_TOOLTIP", "บล็อก Morph ของ Assassin's Blade จนกว่าเป้าหมายจะอยู่ในช่วง Execute")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS", "Mages' Wrath, Mages' Fury, Endless Fury")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_MAGESFURYMORPHS_TOOLTIP", "บล็อก Morph ของ Mages' Fury จนกว่าเป้าหมายจะอยู่ในช่วง Execute")

ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS", "Reverse Slash, Reverse Slice, Executioner")
ZO_CreateStringId("OW_MENU_EXECUTE_SPELL_REVERSESLASHMORPHS_TOOLTIP", "บล็อก Morph ของ Reverse Slash จนกว่าเป้าหมายจะอยู่ในช่วง Execute")

-- == Work in progress ================================================
ZO_CreateStringId("OW_WIP", "WIP")

-- =============================================================================
-- == WEAPON SETTINGS ==========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEADER", "ปิดใช้งานตามประเภทอาวุธ")

ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON", "ปิดตัวช่วยวีฟตามประเภทอาวุธ")
ZO_CreateStringId("OW_MENU_DISABLE_WEAVE_ASSIST_ON_WEAPON_TOOLTIP", "ปิดเฉพาะตัวช่วยวีฟ (การจัดการ GCD) สำหรับประเภทอาวุธที่เลือก")

ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON", "ปิดฟีเจอร์ตามประเภทอาวุธ")
ZO_CreateStringId("OW_MENU_DISABLE_FEATURES_ON_WEAPON_TOOLTIP", "ปิดฟีเจอร์ส่วนใหญ่ของส่วนเสริมสำหรับประเภทอาวุธที่เลือก")

-- One-handed weapons
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE", "ขวาน")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_AXE_TOOLTIP", "ปิดใช้งานเมื่อสวมขวาน")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER", "ค้อน")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HAMMER_TOOLTIP", "ปิดใช้งานเมื่อสวมค้อน")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD", "ดาบ")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SWORD_TOOLTIP", "ปิดใช้งานเมื่อสวมดาบ")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER", "กริช")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_DAGGER_TOOLTIP", "ปิดใช้งานเมื่อสวมกริช")

-- Two-handed weapons
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD", "ดาบสองมือ")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_SWORD_TOOLTIP", "ปิดใช้งานเมื่อสวมดาบสองมือ")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE", "ขวานสองมือ")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_AXE_TOOLTIP", "ปิดใช้งานเมื่อสวมขวานสองมือ")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER", "ค้อนสองมือ")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_TWOHANDED_HAMMER_TOOLTIP", "ปิดใช้งานเมื่อสวมค้อนสองมือ")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW", "ธนู")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_BOW_TOOLTIP", "ปิดใช้งานเมื่อสวมธนู")

-- Staves
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF", "คฑาไฟ")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FIRE_STAFF_TOOLTIP", "ปิดใช้งานเมื่อสวมคฑาไฟ")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF", "คฑาน้ำแข็ง")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_FROST_STAFF_TOOLTIP", "ปิดใช้งานเมื่อสวมคฑาน้ำแข็ง")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF", "คฑาสายฟ้า")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_LIGHTNING_STAFF_TOOLTIP", "ปิดใช้งานเมื่อสวมคฑาสายฟ้า")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF", "คฑารักษา")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_HEALING_STAFF_TOOLTIP", "ปิดใช้งานเมื่อสวมคฑารักษา")

-- Other weapons
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD", "โล่")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_SHIELD_TOOLTIP", "ปิดใช้งานเมื่อสวมโล่")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE", "รูม")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RUNE_TOOLTIP", "ปิดใช้งานเมื่อสวมรูม")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE", "ไม่มีอาวุธ")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_NONE_TOOLTIP", "ปิดใช้งานเมื่อไม่ได้สวมอาวุธ")

ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED", "อาวุธสำรอง")
ZO_CreateStringId("OW_MENU_DEACTIVATE_ON_WEAPON_RESERVED_TOOLTIP", "ปิดใช้งานเมื่อสวมประเภทอาวุธสำรอง")

-- =============================================================================
-- == CUSTOM BLOCK LIST SETTINGS ===============================================
-- =============================================================================
ZO_CreateStringId("OW_MENU_BLOCKLIST_HEADER", "รายการบล็อกแบบกำหนดเอง")
ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_HEADER", "รายการบล็อกแบบกำหนดเอง")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_DESC", "เพิ่ม ID คาถาเพื่อบล็อกไม่ให้ใช้ คุณยังสามารถเพิ่มคาถาได้โดยคลิกขวาที่ช่องแถบปฏิบัติการ (ต้องรีโหลด UI)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_LABEL", "ID คาถา")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SPELLID_TOOLTIP", "ป้อน ID คาถาเป็นตัวเลข (เช่น 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_ADD_BUTTON", "เพิ่มในรายการบล็อก")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_LIST_HEADER", "คาถาที่ถูกบล็อก:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST", "เปิดใช้งานรายการบล็อกแบบกำหนดเอง")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_TOOLTIP", "เปิดหรือปิดฟังก์ชันรายการบล็อกแบบกำหนดเอง")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_SV_DESC", "ตรวจสอบไฟล์ SavedVariables ของคุณ:\n customBlockList = {\n   [SpellID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK", "เปิดใช้งานการตรวจสอบพลังชีวิตสำหรับรายการบล็อก")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "เมื่อเปิดใช้งาน คาถาในรายการบล็อกจะถูกบล็อกก็ต่อเมื่อพลังชีวิตของคุณสูงกว่าเกณฑ์")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT", "เกณฑ์พลังชีวิตสำหรับรายการบล็อก (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "คาถาในรายการบล็อกจะถูกบล็อกก็ต่อเมื่อพลังชีวิตของคุณสูงกว่าเปอร์เซ็นต์นี้")

-- =============================================================================
-- == CUSTOM RECAST BLOCK LIST SETTINGS ========================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLERECASTBLOCK_HEADER", "รายการบล็อกการร่ายซ้ำแบบกำหนดเอง")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_DESC", "เพิ่ม ID คาถาเพื่อบล็อกไม่ให้ร่ายซ้ำจนกว่าเวลาผลตกค้างจะต่ำกว่าเกณฑ์ คุณยังสามารถเพิ่มคาถาได้โดยคลิกขวาที่ช่องแถบปฏิบัติการ (ต้องรีโหลด UI)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_LABEL", "ID คาถา")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SPELLID_TOOLTIP", "ป้อน ID คาถาเป็นตัวเลข (เช่น 185805)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_ADD_BUTTON", "เพิ่มในรายการบล็อกการร่ายซ้ำ")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_LIST_HEADER", "คาถาที่ถูกบล็อกการร่ายซ้ำ:")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST", "เปิดใช้งานรายการบล็อกการร่ายซ้ำแบบกำหนดเอง")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_TOOLTIP", "เปิดหรือปิดฟังก์ชันรายการบล็อกการร่ายซ้ำแบบกำหนดเอง")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME", "เวลาบล็อกการร่ายซ้ำ (วินาที)")
ZO_CreateStringId("OW_MENU_RECAST_BLOCK_TIME_TOOLTIP", "เวลาเป็นวินาทีที่ต่ำกว่าซึ่งคาถาในรายการบล็อกการร่ายซ้ำสามารถร่ายได้อีกครั้ง (1.0 = 1 วินาที)")
ZO_CreateStringId("OW_MENU_CUSTOMRECASTBLOCK_SV_DESC", "ตรวจสอบไฟล์ SavedVariables ของคุณ:\n customRecastBlockList = {\n   [SpellID] = false/true\n }")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK", "เปิดใช้งานการตรวจสอบพลังชีวิตสำหรับรายการบล็อกการร่ายซ้ำ")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RECAST_BLOCK_LIST_HEALTH_CHECK_TOOLTIP", "เมื่อเปิดใช้งาน คาถาในรายการบล็อกการร่ายซ้ำจะถูกบล็อกก็ต่อเมื่อพลังชีวิตของคุณสูงกว่าเกณฑ์")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT", "เกณฑ์พลังชีวิตสำหรับรายการบล็อกการร่ายซ้ำ (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_RECAST_BLOCK_LIST_HEALTH_PERCENT_TOOLTIP", "คาถาในรายการบล็อกการร่ายซ้ำจะถูกบล็อกก็ต่อเมื่อพลังชีวิตของคุณสูงกว่าเปอร์เซ็นต์นี้")

-- =============================================================================

ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_MAIN_TEXT", "เพิ่ม/ลบ ID คาถาแล้ว หากคุณไม่ต้องการเพิ่มคาถาเพิ่มเติม กรุณารีโหลด UI เพื่อให้แสดงคาถาได้")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_YES", "รีโหลด UI")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_BUTTON_LATER", "ทีหลัง")

ZO_CreateStringId("OW_MENU_DIALOG_BUTTON_OK", "ตกลง")
ZO_CreateStringId("OW_MENU_INVALID_ID_DIALOG_MAIN_TEXT", "ข้อผิดพลาด: กรุณาป้อน ID คาถาที่ถูกต้อง")
ZO_CreateStringId("OW_MENU_ID_NOT_EXIST_DIALOG_MAIN_TEXT", "ไม่มี ID คาถานี้")
ZO_CreateStringId("OW_MENU_ID_IS_IN_SV_DIALOG_MAIN_TEXT", "ID คาถาอยู่ในรายการบล็อกแล้ว")

-- =============================================================================
-- == RESOURCE-BASED BLOCK LIST SETTINGS =======================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CONFIGURABLEBLOCK_RESOURCE_HEADER", "รายการบล็อกตามทรัพยากร")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_RESOURCE_DESC", "เพิ่ม ID คาถาเพื่อบล็อกเมื่อทรัพยากรหลักของคุณ (Magicka หรือ Stamina) ต่ำกว่าเกณฑ์ คุณยังสามารถเพิ่มคาถาได้โดยคลิกขวาที่ช่องแถบปฏิบัติการ (ต้องรีโหลด UI)")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST", "เปิดใช้งานรายการบล็อกตามทรัพยากร")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_RESOURCE_BLOCK_LIST_TOOLTIP", "เปิดหรือปิดฟังก์ชันรายการบล็อกตามทรัพยากร")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK", "เปิดใช้งานการตรวจสอบทรัพยากร")
ZO_CreateStringId("OW_MENU_USE_CUSTOM_BLOCK_LIST_RESOURCE_CHECK_TOOLTIP", "เมื่อเปิดใช้งาน คาถาในรายการบล็อกทรัพยากรจะถูกบล็อกก็ต่อเมื่อทรัพยากรหลักของคุณ (Magicka หรือ Stamina) สูงกว่าเกณฑ์")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT", "เกณฑ์ทรัพยากร (%)")
ZO_CreateStringId("OW_MENU_CUSTOM_BLOCK_LIST_RESOURCE_PERCENT_TOOLTIP", "คาถาในรายการบล็อกทรัพยากรจะถูกบล็อกก็ต่อเมื่อทรัพยากรหลักของคุณ (Magicka หรือ Stamina) สูงกว่าเปอร์เซ็นต์นี้")

ZO_CreateStringId("OW_MENU_RESOURCE_BLOCK_SPELL", "คาถา: ")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK", "ตรวจสอบ Magicka")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_CHECK_TOOLTIP", "เปิดใช้งานการบล็อกตาม Magicka สำหรับคาถานี้")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE", "บล็อกเมื่อ Magicka ต่ำกว่าเกณฑ์")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_BLOCK_MODE_TOOLTIP", "บล็อกคาถาเมื่อ Magicka ต่ำกว่าเกณฑ์ (ยกเลิกการเลือกเพื่ออนุญาตเฉพาะเมื่อต่ำกว่า)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD", "เกณฑ์ Magicka (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_MAGICKA_THRESHOLD_TOOLTIP", "เกณฑ์เปอร์เซ็นต์ Magicka")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK", "ตรวจสอบ Stamina")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_CHECK_TOOLTIP", "เปิดใช้งานการบล็อกตาม Stamina สำหรับคาถานี้")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE", "บล็อกเมื่อ Stamina ต่ำกว่าเกณฑ์")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_BLOCK_MODE_TOOLTIP", "บล็อกคาถาเมื่อ Stamina ต่ำกว่าเกณฑ์ (ยกเลิกการเลือกเพื่ออนุญาตเฉพาะเมื่อต่ำกว่า)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD", "เกณฑ์ Stamina (%)")
ZO_CreateStringId("OW_MENU_RESOURCE_STAMINA_THRESHOLD_TOOLTIP", "เกณฑ์เปอร์เซ็นต์ Stamina")

-- =============================================================================
-- == KEYBINDINGS LOCALIZATION =================================================
-- =============================================================================

ZO_CreateStringId("SI_KEYBINDINGS_CATEGORY_OPTIMALWEAVE", "|c6D6D6DOpti|r|c8A8A8AmalWea|r|cC4C4C4ve|r")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_MODE", "สลับโหมด (Strict/Intelligent/Disabled)")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_BLOCK_LIST", "สลับรายการบล็อกแบบกำหนดเอง")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_CUSTOM_RECAST_BLOCK_LIST", "สลับรายการบล็อกการร่ายซ้ำแบบกำหนดเอง")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_FEATURES", "สลับการปิดฟีเจอร์บนแถบอาวุธที่สอง")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_BACKBAR_WEAVE_ASSIST", "สลับการปิดตัวช่วยวีฟบนแถบอาวุธที่สอง")
ZO_CreateStringId("SI_BINDING_NAME_OPTIMALWEAVE_TOGGLE_EXECUTE_CHECK", "สลับการตรวจสอบ Execute")

-- =============================================================================
-- == REMOVE BUTTON ============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_BUTTON", "ลบ")
ZO_CreateStringId("OW_MENU_CUSTOMBLOCK_REMOVE_TOOLTIP", "ลบคาถานี้ออกจากรายการบล็อก (ต้อง /reloadui)")

-- =============================================================================
-- == SETTIINGS MODE ===========================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_MODE_SELECTION_LABEL", "โหมดการตั้งค่า")
ZO_CreateStringId("OW_MENU_MODE_SELECTION_TOOLTIP", "เลือกว่าการตั้งค่าจะใช้ร่วมกันทุกตัวละครในบัญชีนี้ (ทั้งบัญชี) หรือเก็บแยกสำหรับแต่ละตัวละคร (ต่อตัวละคร)")
ZO_CreateStringId("OW_MENU_MODE_ACCOUNTWIDE", "ทั้งบัญชี")
ZO_CreateStringId("OW_MENU_MODE_PERCHARACTER", "ต่อตัวละคร")
ZO_CreateStringId("OW_MENU_RELOAD_DIALOG_SETTINGS_MAIN_TEXT", "เปลี่ยนโหมดการตั้งค่าแล้ว รีโหลด UI เพื่อใช้การเปลี่ยนแปลงหรือไม่?")

-- =============================================================================
-- == IN COMBAT MENU BLOCKING ==================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU", "บล็อกเมนูล่าสุดในการต่อสู้")
ZO_CreateStringId("OW_MENU_BLOCK_LAST_MENU_TOOLTIP", "ป้องกันการเปิดเมนูล่าสุด (ALT) ขณะอยู่ในการต่อสู้")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU", "บล็อกเมนูตัวละครในการต่อสู้")
ZO_CreateStringId("OW_MENU_BLOCK_CHAR_MENU_TOOLTIP", "ป้องกันการเปิดเมนูตัวละคร (C) ขณะอยู่ในการต่อสู้")

-- =============================================================================
-- == GCD DISPLAY ==============================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_SHOW_GCD_LABEL", "แสดงเวลารอคอยสากล (GCD)")
ZO_CreateStringId("OW_MENU_SHOW_GCD_TOOLTIP", "แสดงตัวบ่งชี้ GCD (จัดทำโดย ZOS) เหนือแถบการกระทำ")

-- =============================================================================
-- == BLOCKLIST COMBAT ONLY ====================================================
-- =============================================================================

ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_LABEL", "รายการบล็อกเฉพาะในการต่อสู้")
ZO_CreateStringId("OW_MENU_BLOCKLISTS_COMBAT_ONLY_TOOLTIP", "รายการบล็อกที่กำหนดเองทั้งหมดจะทำงานเฉพาะเมื่อคุณกำลังต่อสู้เท่านั้น นอกการต่อสู้ รายการบล็อกทั้งหมดจะถูกปิดใช้งาน")

-- =============================================================================
-- === END OF THAI LOCALIZATION ================================================
-- =============================================================================