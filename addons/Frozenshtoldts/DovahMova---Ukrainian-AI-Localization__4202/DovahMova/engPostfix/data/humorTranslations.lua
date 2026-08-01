-- Жартівливі переклади для DovahMova
-- Humorous translations for DovahMova
-- Файл для жартівливої адаптації перекладів

DovahMova_HumorTranslations = {
    -- Abilities / Здібності
    ["Puncturing Sweep"] = "Піздюліна з відхилом",
}

-- Функція для отримання жартівливого перекладу
function DovahMova_GetHumorTranslation(originalText)
    if not originalText or originalText == "" then
        return originalText
    end
    
    -- Перевіряємо прямий переклад
    local translation = DovahMova_HumorTranslations[originalText]
    if translation then
        return translation
    end
    
    -- Перевіряємо часткові збіги (для складних рядків)
    for english, ukrainian in pairs(DovahMova_HumorTranslations) do
        if string.find(originalText, english, 1, true) then
            return string.gsub(originalText, english, ukrainian, 1)
        end
    end
    
    return originalText
end

-- Функція для додавання нових перекладів на льоту
function DovahMova_AddHumorTranslation(english, ukrainian)
    if english and ukrainian and english ~= "" and ukrainian ~= "" then
        DovahMova_HumorTranslations[english] = ukrainian
        return true
    end
    return false
end

-- Функція для видалення перекладу  
function DovahMova_RemoveHumorTranslation(english)
    if english and DovahMova_HumorTranslations[english] then
        DovahMova_HumorTranslations[english] = nil
        return true
    end
    return false
end

-- Функція для отримання всіх доступних перекладів
function DovahMova_GetAllHumorTranslations()
    return DovahMova_HumorTranslations
end

-- Функція для очищення всіх перекладів
function DovahMova_ClearAllHumorTranslations()
    DovahMova_HumorTranslations = {}
end

-- Функція для підрахунку кількості перекладів
function DovahMova_GetHumorTranslationsCount()
    local count = 0
    for _ in pairs(DovahMova_HumorTranslations) do
        count = count + 1
    end
    return count
end
