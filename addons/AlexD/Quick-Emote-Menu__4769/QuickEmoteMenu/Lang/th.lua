local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME          = "?",
    SI_QUICKEMOTEMENU_CATEGORIES            = "หมวดหมู่",
    SI_QUICKEMOTEMENU_FAVORITES             = "รายการโปรด",
    SI_QUICKEMOTEMENU_NO_FAVORITES          = "(ว่าง)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE        = "สลับ",
    SI_QUICKEMOTEMENU_OPTION_HOVER          = "หน่วงเวลาเมนูย่อยเมื่อชี้ (ms)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP  = "0 = เปิดเฉพาะเมื่อคลิก",
    SI_QUICKEMOTEMENU_OPTION_UIMODE         = "แสดงปุ่มเฉพาะในโหมด UI",
    SI_QUICKEMOTEMENU_OPTION_UIMODE_TOOLTIP =
    "แสดงปุ่มหลักเฉพาะเมื่อเคอร์เซอร์เมาส์ทำงานอยู่ (โหมด UI) ปุ่มจะถูกซ่อนเมื่อกลับสู่โหมดการเล่น/การโต้ตอบปกติ.",
    SI_QUICKEMOTEMENU_OPTION_DETACH         = "แยกปุ่มออกจากแชต",
    SI_QUICKEMOTEMENU_OPTION_DETACH_TOOLTIP = "ย้ายปุ่มออกนอกหน้าต่างแชต สามารถลากปุ่มไปวางได้อย่างอิสระ",
    SI_QUICKEMOTEMENU_OPTION_SETTINGS       = "การตั้งค่า",
    SI_QUICKEMOTEMENU_OPTION_ATTACH_BUTTON  = "แนบปุ่ม",
    SI_QUICKEMOTEMENU_OPTION_DETACH_BUTTON  = "แยกปุ่ม",
    SI_QUICKEMOTEMENU_OPTION_SHOW_PANEL     = "แสดงแผงการตั้งค่า",
    SI_QUICKEMOTEMENU_OPTION_CLOSE          = "ปิดเมนูหลังเล่นอีโมต (คลิกซ้าย)",
    SI_QUICKEMOTEMENU_OPTION_RESET          = "รีเซ็ตตำแหน่งปุ่ม",
    SI_QUICKEMOTEMENU_OPTION_CHAT_BUTTON_OFFSET_X         = "ออฟเซ็ต X ของปุ่มแชต",
    SI_QUICKEMOTEMENU_OPTION_CHAT_BUTTON_OFFSET_X_TOOLTIP = "ระยะเลื่อนแนวนอนของปุ่มเมื่อเทียบกับปุ่มตัวเลือกของหน้าต่างแชต ใช้เฉพาะเมื่อปุ่มถูกแนบกับหน้าต่างแชตเท่านั้น",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION    = [[
|c3399FFฟีเจอร์|r
• เข้าถึงอีโมตได้อย่างรวดเร็วด้วยหมวดหมู่และรายการโปรด
• หมวดหมู่และอีโมตโหลดโดยตรงจากข้อมูลเกม
• อีโมตใหม่ที่เพิ่มเข้ามาในเกมจะแสดงในรายการโดยอัตโนมัติ

|c3399FFการควบคุม|r
• คลิกซ้ายที่ปุ่มเพื่อเปิดหรือปิดเมนู
• คลิกขวาและลากปุ่มเพื่อย้าย
• คลิกซ้ายที่อีโมตเพื่อเล่น
• คลิกขวาที่อีโมตเพื่อเพิ่มหรือลบจากรายการโปรด

|c3399FFเมนู|r
• หมวดหมู่ — ดูอีโมตตามหมวดหมู่
• รายการโปรด — เข้าถึงอีโมตที่บันทึกไว้อย่างรวดเร็ว
• เมนูย่อยเปิดเมื่อชี้หรือคลิก (ดูการตั้งค่าหน่วงเวลา)
• เมนูเปิดด้านบน/ล่าง และซ้าย/ขวา ตามตำแหน่งปุ่ม

|c3399FFเคล็ดลับ|r
• ใช้ปุ่มลัดเพื่อสลับเมนู
• /qempanel เปิดแผงการตั้งค่านี้
• รายการโปรดบันทึกทั้งบัญชี
]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
