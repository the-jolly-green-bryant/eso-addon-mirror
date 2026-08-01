-- Copyright (c) 2026 Toriga (https://github.com/Master-Antonio)
-- All rights reserved.
-- TorigaCam: Cinematic third-person camera transitions for ESO.

TorigaCam = {}
TorigaCam.name = "TorigaCam"

local strings = {
    en = {
        RESET_CAM = "Reset Camera",
        TOGGLE_SHOULDER = "Shoulder Swap",
        HEADER_GENERAL = "General Settings",
        TRANSITION_DURATION = "Transition Duration (ms)",
        TRANSITION_DURATION_TOOLTIP = "Adjust the time in milliseconds for the camera to smoothly glide between states.",
        SHOULDER_RIGHT = "Start on Right Shoulder",
        SHOULDER_RIGHT_TOOLTIP = "If enabled, the camera starts over the right shoulder; otherwise, it starts on the left.",
        LOCK_ZOOM = "Lock Manual Zoom",
        LOCK_ZOOM_TOOLTIP = "If enabled, the addon automatically restores the preset zoom distance if you scroll the mouse wheel.",
        EXPLORE = "Exploration",
        COMBAT = "Combat",
        MOUNTED = "Mount",
        STEALTH = "Stealth",
        DIALOGUE = "Dialogue",
        PRESET_SUBMENU = "Preset: %s",
        PRESET_SUBMENU_TOOLTIP = "Camera settings for %s state.",
        DISTANCE = "Camera Distance",
        DISTANCE_TOOLTIP = "Adjust the zoom distance (0 = First Person, 20 = Max Zoom)",
        HORIZ_OFFSET = "Horizontal Offset",
        HORIZ_OFFSET_TOOLTIP = "Adjust side placement (-100 = Left, 100 = Right)",
        VERT_OFFSET = "Vertical Offset",
        VERT_OFFSET_TOOLTIP = "Adjust height placement (-100 = Bottom, 100 = Top)",
        FOV = "Field of View (FOV)",
        FOV_TOOLTIP = "Adjust the field of view angle (35 = Narrow, 130 = Wide)",
        MSG_SHOULDER_RIGHT = "[TorigaCam] Camera over RIGHT shoulder",
        MSG_SHOULDER_LEFT = "[TorigaCam] Camera over LEFT shoulder",
    },
    it = {
        RESET_CAM = "Ripristina Telecamera",
        TOGGLE_SHOULDER = "Inverti Spalla",
        HEADER_GENERAL = "Impostazioni Generali",
        TRANSITION_DURATION = "Durata Transizione (ms)",
        TRANSITION_DURATION_TOOLTIP = "Regola il tempo in millisecondi che impiega la telecamera a passare fluidamente da uno stato all'altro.",
        SHOULDER_RIGHT = "Inizia sulla Spalla Destra",
        SHOULDER_RIGHT_TOOLTIP = "Se abilitato, all'avvio la telecamera si posiziona sulla spalla destra, altrimenti sulla spalla sinistra.",
        LOCK_ZOOM = "Blocca lo Zoom Manuale",
        LOCK_ZOOM_TOOLTIP = "Se abilitato, l'add-on ripristinerà automaticamente lo zoom originale se provi a zoomare avanti o indietro usando la rotellina del mouse.",
        EXPLORE = "Esplorazione",
        COMBAT = "Combattimento",
        MOUNTED = "Cavalcatura",
        STEALTH = "Furtività",
        DIALOGUE = "Conversazione",
        PRESET_SUBMENU = "Preset: %s",
        PRESET_SUBMENU_TOOLTIP = "Impostazioni della telecamera per lo stato di %s.",
        DISTANCE = "Distanza Telecamera",
        DISTANCE_TOOLTIP = "Regola lo zoom della telecamera (0 = Prima Persona, 20 = Zoom Massimo)",
        HORIZ_OFFSET = "Offset Orizzontale (Spalla)",
        HORIZ_OFFSET_TOOLTIP = "Regola lo spostamento laterale della telecamera (-100 = Sinistra, 100 = Destra)",
        VERT_OFFSET = "Offset Verticale (Altezza)",
        VERT_OFFSET_TOOLTIP = "Regola l'altezza della telecamera (-100 = Bassa, 100 = Alta)",
        FOV = "Campo Visivo (FOV)",
        FOV_TOOLTIP = "Imposta l'angolo visivo (35 = stretto/zoomato, 130 = grandangolare)",
        MSG_SHOULDER_RIGHT = "[TorigaCam] Visuale sopra la spalla DESTRA",
        MSG_SHOULDER_LEFT = "[TorigaCam] Visuale sopra la spalla SINISTRA",
    },
    de = {
        RESET_CAM = "Kamera zurücksetzen",
        TOGGLE_SHOULDER = "Schulter wechseln",
        HEADER_GENERAL = "Allgemeine Einstellungen",
        TRANSITION_DURATION = "Übergangsdauer (ms)",
        TRANSITION_DURATION_TOOLTIP = "Stellt die Zeit in Millisekunden ein, die die Kamera benötigt, um weich zwischen Zuständen zu gleiten.",
        SHOULDER_RIGHT = "Auf rechter Schulter beginnen",
        SHOULDER_RIGHT_TOOLTIP = "Wenn aktiviert, startet die Kamera über der rechten Schulter, andernfalls über der linken.",
        LOCK_ZOOM = "Manuellen Zoom sperren",
        LOCK_ZOOM_TOOLTIP = "Wenn aktiviert, stellt das Add-on automatisch die voreingestellte Zoom-Distanz wieder her, wenn das Mausrad gedreht wird.",
        EXPLORE = "Erkundung",
        COMBAT = "Kampf",
        MOUNTED = "Reiten",
        STEALTH = "Schleichen",
        DIALOGUE = "Dialog",
        PRESET_SUBMENU = "Preset: %s",
        PRESET_SUBMENU_TOOLTIP = "Kameraeinstellungen für den Zustand %s.",
        DISTANCE = "Kamera-Abstand",
        DISTANCE_TOOLTIP = "Zoom-Distanz anpassen (0 = Egoperspektive, 20 = Maximaler Zoom)",
        HORIZ_OFFSET = "Horizontaler Versatz",
        HORIZ_OFFSET_TOOLTIP = "Seitliche Platzierung anpassen (-100 = Links, 100 = Rechts)",
        VERT_OFFSET = "Vertikaler Versatz",
        VERT_OFFSET_TOOLTIP = "Höhenplatzierung anpassen (-100 = Unten, 100 = Oben)",
        FOV = "Sichtfeld (FOV)",
        FOV_TOOLTIP = "Sichtfeldwinkel anpassen (35 = Eng, 130 = Weit)",
        MSG_SHOULDER_RIGHT = "[TorigaCam] Kamera über RECHTER Schulter",
        MSG_SHOULDER_LEFT = "[TorigaCam] Kamera über LINKER Schulter",
    },
    fr = {
        RESET_CAM = "Réinitialiser la caméra",
        TOGGLE_SHOULDER = "Changer d'épaule",
        HEADER_GENERAL = "Paramètres généraux",
        TRANSITION_DURATION = "Durée de transition (ms)",
        TRANSITION_DURATION_TOOLTIP = "Ajuste le temps en millisecondes pour que la caméra glisse en douceur d'un état à l'autre.",
        SHOULDER_RIGHT = "Commencer sur l'épaule droite",
        SHOULDER_RIGHT_TOOLTIP = "Si activé, la caméra commence sur l'épaule droite; sinon, sur la gauche.",
        LOCK_ZOOM = "Verrouiller le zoom manuel",
        LOCK_ZOOM_TOOLTIP = "Si activé, l'addon rétablit automatiquement la distance de zoom prédéfinie si vous utilisez la molette de la souris.",
        EXPLORE = "Exploration",
        COMBAT = "Combat",
        MOUNTED = "Monture",
        STEALTH = "Discrétion",
        DIALOGUE = "Dialogue",
        PRESET_SUBMENU = "Preset : %s",
        PRESET_SUBMENU_TOOLTIP = "Paramètres de caméra pour l'état %s.",
        DISTANCE = "Distance de la caméra",
        DISTANCE_TOOLTIP = "Ajuster la distance de zoom (0 = Première personne, 20 = Zoom max)",
        HORIZ_OFFSET = "Décalage horizontal",
        HORIZ_OFFSET_TOOLTIP = "Ajuster le placement latéral (-100 = Gauche, 100 = Droite)",
        VERT_OFFSET = "Décalage vertical",
        VERT_OFFSET_TOOLTIP = "Ajuster la hauteur de la caméra (-100 = Bas, 100 = Haut)",
        FOV = "Champ de vision (FOV)",
        FOV_TOOLTIP = "Ajuster l'angle du champ de vision (35 = Étroit, 130 = Large)",
        MSG_SHOULDER_RIGHT = "[TorigaCam] Caméra sur l'épaule DROITE",
        MSG_SHOULDER_LEFT = "[TorigaCam] Caméra sur l'épaule GAUCHE",
    },
    es = {
        RESET_CAM = "Restablecer cámara",
        TOGGLE_SHOULDER = "Cambiar de hombro",
        HEADER_GENERAL = "Ajustes generales",
        TRANSITION_DURATION = "Duración de transición (ms)",
        TRANSITION_DURATION_TOOLTIP = "Ajusta el tiempo en milisegundos para que la cámara se desplace suavemente entre estados.",
        SHOULDER_RIGHT = "Iniciar en el hombro derecho",
        SHOULDER_RIGHT_TOOLTIP = "Si está activado, la cámara comienza sobre el hombro derecho; de lo contrario, sobre el izquierdo.",
        LOCK_ZOOM = "Bloquear zoom manual",
        LOCK_ZOOM_TOOLTIP = "Si está activado, el addon restablece automáticamente la distancia de zoom predeterminada al usar la rueda del ratón.",
        EXPLORE = "Exploración",
        COMBAT = "Combate",
        MOUNTED = "Montura",
        STEALTH = "Sigilo",
        DIALOGUE = "Diálogo",
        PRESET_SUBMENU = "Preajuste: %s",
        PRESET_SUBMENU_TOOLTIP = "Ajustes de cámara para el estado de %s.",
        DISTANCE = "Distancia de la cámara",
        DISTANCE_TOOLTIP = "Ajustar distancia de zoom (0 = Primera persona, 20 = Zoom máx)",
        HORIZ_OFFSET = "Desplazamiento horizontal",
        HORIZ_OFFSET_TOOLTIP = "Ajustar colocación lateral (-100 = Izquierda, 100 = Derecha)",
        VERT_OFFSET = "Desplazamiento vertical",
        VERT_OFFSET_TOOLTIP = "Ajustar altura de la cámara (-100 = Abajo, 100 = Arriba)",
        FOV = "Campo de visión (FOV)",
        FOV_TOOLTIP = "Ajustar el ángulo del campo de visión (35 = Estrecho, 130 = Ancho)",
        MSG_SHOULDER_RIGHT = "[TorigaCam] Cámara sobre el hombro DERECHO",
        MSG_SHOULDER_LEFT = "[TorigaCam] Cámara sobre el hombro IZQUIERDO",
    },
    ru = {
        RESET_CAM = "Сбросить камеру",
        TOGGLE_SHOULDER = "Смена плеча",
        HEADER_GENERAL = "Общие настройки",
        TRANSITION_DURATION = "Длительность перехода (мс)",
        TRANSITION_DURATION_TOOLTIP = "Регулировка времени в миллисекундах для плавного перехода камеры между состояниями.",
        SHOULDER_RIGHT = "Начинать с правого плеча",
        SHOULDER_RIGHT_TOOLTIP = "Если включено, камера будет изначально находиться над правым плечом, иначе — над левым.",
        LOCK_ZOOM = "Блокировка ручного зума",
        LOCK_ZOOM_TOOLTIP = "Если включено, аддон автоматически восстанавливает предустановленную дистанцию при прокрутке колеса мыши.",
        EXPLORE = "Исследование",
        COMBAT = "Бой",
        MOUNTED = "Верхом",
        STEALTH = "Скрытность",
        DIALOGUE = "Диалог",
        PRESET_SUBMENU = "Предустановка: %s",
        PRESET_SUBMENU_TOOLTIP = "Настройки камеры для состояния %s.",
        DISTANCE = "Дистанция камеры",
        DISTANCE_TOOLTIP = "Регулировка дистанции зума (0 = От первого лица, 20 = Макс. зум)",
        HORIZ_OFFSET = "Горизонтальный сдвиг",
        HORIZ_OFFSET_TOOLTIP = "Регулировка бокового положения (-100 = Слева, 100 = Справа)",
        VERT_OFFSET = "Вертикальный сдвиг",
        VERT_OFFSET_TOOLTIP = "Регулировка высоты камеры (-100 = Снизу, 100 = Сверху)",
        FOV = "Поле зрения (FOV)",
        FOV_TOOLTIP = "Регулировка угла поля зрения (35 = Узкое, 130 = Широкое)",
        MSG_SHOULDER_RIGHT = "[TorigaCam] Камера над ПРАВЫМ плечом",
        MSG_SHOULDER_LEFT = "[TorigaCam] Камера над ЛЕВЫМ плечом",
    },
    zh = {
        RESET_CAM = "重置相机",
        TOGGLE_SHOULDER = "肩膀切换",
        HEADER_GENERAL = "通用设置",
        TRANSITION_DURATION = "过渡时间（毫秒）",
        TRANSITION_DURATION_TOOLTIP = "调整相机在状态之间平滑过渡所需的时间（毫秒）。",
        SHOULDER_RIGHT = "初始右肩视角",
        SHOULDER_RIGHT_TOOLTIP = "启用时，相机将在右肩上方启动；否则，在左肩上方启动。",
        LOCK_ZOOM = "锁定手动缩放",
        LOCK_ZOOM_TOOLTIP = "启用时，如果您滚动鼠标滚轮，插件会自动恢复预设的缩放距离。",
        EXPLORE = "探索",
        COMBAT = "战斗",
        MOUNTED = "坐骑",
        STEALTH = "潜行",
        DIALOGUE = "对话",
        PRESET_SUBMENU = "预设: %s",
        PRESET_SUBMENU_TOOLTIP = "%s 状态下的相机设置。",
        DISTANCE = "相机距离",
        DISTANCE_TOOLTIP = "调整缩放距离（0 = 第一人称，20 = 最大缩放）",
        HORIZ_OFFSET = "水平偏移",
        HORIZ_OFFSET_TOOLTIP = "调整侧边位置（-100 = 左，100 = 右）",
        VERT_OFFSET = "垂直偏移",
        VERT_OFFSET_TOOLTIP = "调整相机高度（-100 = 底部，100 = 顶部）",
        FOV = "视场角 (FOV)",
        FOV_TOOLTIP = "调整视角（35 = 窄，130 = 宽）",
        MSG_SHOULDER_RIGHT = "[TorigaCam] 相机移至右肩",
        MSG_SHOULDER_LEFT = "[TorigaCam] 相机移至左肩",
    }
}

local lang = GetCVar("Language.2") or "en"
if not strings[lang] then lang = "en" end
local L = strings[lang]

-- Localized string IDs for the keybinding settings menu
ZO_CreateStringId("SI_BINDING_NAME_TORIGACAM_HEADER", "TorigaCam")
ZO_CreateStringId("SI_BINDING_NAME_TORIGACAM_TOGGLE_SHOULDER", L.TOGGLE_SHOULDER)
ZO_CreateStringId("SI_BINDING_NAME_TORIGACAM_RESET_CAMERA", L.RESET_CAM)

-- Default configurations for the addon
TorigaCam.defaults = {
    presets = {
        explore = {
            distance = 3.0,     -- Mid-close zoom to see the character clearly (like Elden Ring / RDR2)
            horizontal = 0.0,   -- Perfectly centered horizontally (like Elden Ring / Nier)
            vertical = 0.0,     -- Perfectly level camera, character is centered vertically (fully visible)
            fov = 85.0,         -- Wide immersive FOV
        },
        combat = {
            distance = 5.5,     -- Action-focused close combat camera (like God of War)
            horizontal = 0.0,   -- Perfectly centered horizontally (like Elden Ring / Nier)
            vertical = 0.0,     -- Perfectly level camera, character is centered vertically
            fov = 90.0,         -- Wide combat FOV
        },
        mounted = {
            distance = 6.0,     -- Zoomed closer to the mount (like RDR2 / Elden Ring)
            horizontal = 0.0,   -- Centered horizontally
            vertical = 0.0,     -- Centered vertically
            fov = 95.0,         -- Speed FOV
        },
        stealth = {
            distance = 2.4,     -- Balanced sneak distance
            horizontal = 0.0,   -- Perfectly centered (like Elden Ring / Nier)
            vertical = 0.0,     -- Level camera
            fov = 80.0,         -- Focus
        },
        dialogue = {
            distance = 1.5,     -- Close-up portrait
            horizontal = 0.0,   -- Perfectly centered
            vertical = 0.0,     -- Eye-level centering
            fov = 70.0,         -- Focus
        }
    },
    transitionDuration = 550,
    shoulderRight = true,
    lockZoom = false
}

-- State variables for smooth transition (lerping)
TorigaCam.isTransitioning = false
TorigaCam.transitionStartTime = 0
TorigaCam.startCamera = nil
TorigaCam.targetCamera = nil
TorigaCam.lastState = nil
TorigaCam.isInteracting = false

-- Interpolates settings smoothly over time
function TorigaCam.StartTransition(targetPreset)
    -- Read current state from the game client to interpolate from
    local curDist = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)) or 3.0
    local curHoriz = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET)) or 0.0
    local curVert = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET)) or 0.0
    local curFov = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW)) or 70.0

    TorigaCam.startCamera = {
        distance = curDist,
        horizontal = curHoriz,
        vertical = curVert,
        fov = curFov
    }
    TorigaCam.targetCamera = targetPreset
    TorigaCam.transitionStartTime = GetFrameTimeMilliseconds()
    
    if not TorigaCam.isTransitioning then
        TorigaCam.isTransitioning = true
        -- Registers update callback to run roughly every 15ms (60 FPS transition steps)
        EVENT_MANAGER:RegisterForUpdate(TorigaCam.name .. "Update", 15, TorigaCam.OnUpdate)
    end
end

-- Update handler called during transition
function TorigaCam.OnUpdate()
    local now = GetFrameTimeMilliseconds()
    local elapsed = now - TorigaCam.transitionStartTime
    local duration = TorigaCam.db.transitionDuration
    local progress = elapsed / duration

    if progress >= 1.0 then
        -- Finalize transition and unregister loop
        EVENT_MANAGER:UnregisterForUpdate(TorigaCam.name .. "Update")
        TorigaCam.isTransitioning = false
        
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, tostring(TorigaCam.targetCamera.distance))
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET, tostring(TorigaCam.targetCamera.horizontal))
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET, tostring(TorigaCam.targetCamera.vertical))
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW, tostring(TorigaCam.targetCamera.fov))
    else
        -- Cosine interpolation (Smooth Step / Ease In Out)
        local factor = (1 - math.cos(progress * math.pi)) / 2

        local dist = TorigaCam.startCamera.distance + (TorigaCam.targetCamera.distance - TorigaCam.startCamera.distance) * factor
        local horiz = TorigaCam.startCamera.horizontal + (TorigaCam.targetCamera.horizontal - TorigaCam.startCamera.horizontal) * factor
        local vert = TorigaCam.startCamera.vertical + (TorigaCam.targetCamera.vertical - TorigaCam.startCamera.vertical) * factor
        local fov = TorigaCam.startCamera.fov + (TorigaCam.targetCamera.fov - TorigaCam.startCamera.fov) * factor

        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, tostring(dist))
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET, tostring(horiz))
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET, tostring(vert))
        SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW, tostring(fov))
    end
end

-- Checks player status and initiates transition if state changes
function TorigaCam.UpdateCameraState()
    -- Skip adjustment if in first-person camera mode (zoom distance is 0)
    local curDist = tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)) or 3.0
    if curDist == 0 then
        TorigaCam.lastState = "firstperson"
        return
    end

    local currentState = "explore"
    local preset = TorigaCam.db.presets.explore

    if TorigaCam.isInteracting then
        currentState = "dialogue"
        preset = TorigaCam.db.presets.dialogue
    elseif IsMounted() then
        currentState = "mounted"
        preset = TorigaCam.db.presets.mounted
    elseif IsUnitInCombat("player") then
        currentState = "combat"
        preset = TorigaCam.db.presets.combat
    elseif GetUnitStealthState("player") ~= STEALTH_STATE_NONE then
        currentState = "stealth"
        preset = TorigaCam.db.presets.stealth
    end

    -- Trigger transition only if we changed states or presets were updated
    if TorigaCam.lastState ~= currentState then
        TorigaCam.lastState = currentState
        TorigaCam.StartTransition(preset)
    elseif TorigaCam.db.lockZoom and not TorigaCam.isTransitioning then
        -- Restores preset zoom if the player scrolled the wheel and lockZoom is enabled
        local targetDist = preset.distance
        if math.abs(curDist - targetDist) > 0.05 then
            TorigaCam.StartTransition(preset)
        end
    end
end

-- Refresh current camera settings instantly (useful after settings modifications)
function TorigaCam.RefreshCurrentCamera()
    TorigaCam.lastState = nil
    TorigaCam.UpdateCameraState()
end

-- Toggles between right shoulder and left shoulder offsets (cinematic shoulder swap)
function TorigaCam.ToggleShoulder()
    TorigaCam.db.shoulderRight = not TorigaCam.db.shoulderRight
    
    local factor = TorigaCam.db.shoulderRight and 1 or -1
    -- Mirror horizontal offsets based on chosen shoulder side
    TorigaCam.db.presets.explore.horizontal = math.abs(TorigaCam.db.presets.explore.horizontal) * factor
    TorigaCam.db.presets.combat.horizontal = math.abs(TorigaCam.db.presets.combat.horizontal) * factor
    TorigaCam.db.presets.stealth.horizontal = math.abs(TorigaCam.db.presets.stealth.horizontal) * factor
    TorigaCam.db.presets.dialogue.horizontal = math.abs(TorigaCam.db.presets.dialogue.horizontal) * factor

    if TorigaCam.db.shoulderRight then
        d(L.MSG_SHOULDER_RIGHT)
    else
        d(L.MSG_SHOULDER_LEFT)
    end
    
    TorigaCam.RefreshCurrentCamera()
end

-- Register Slash Command to allow player to swap shoulders in-game
SLASH_COMMANDS["/TorigaCam"] = TorigaCam.ToggleShoulder

-- LibAddonMenu-2.0 Settings Panel Creation
function TorigaCam.CreateSettingsMenu()
    local LAM = LibAddonMenu2
    if not LAM then return end -- Skip UI if LAM2 is not installed

    local panelData = {
        type = "panel",
        name = "TorigaCam",
        displayName = "|cFFD700TorigaCam|r Settings",
        author = "Toriga",
        version = "1.0.0",
        registerForRefresh = true,
        registerForDefaults = true
    }

    local panel = LAM:RegisterAddonPanel("TorigaCamSettingsPanel", panelData)

    -- Dynamic helper to generate UI slider controls for a specific preset
    local function GetPresetControls(presetKey, displayName)
        local stateName = L[presetKey:upper()] or displayName
        return {
            {
                type = "submenu",
                name = string.format(L.PRESET_SUBMENU, stateName),
                tooltip = string.format(L.PRESET_SUBMENU_TOOLTIP, stateName),
                controls = {
                    {
                        type = "slider",
                        name = L.DISTANCE,
                        tooltip = L.DISTANCE_TOOLTIP,
                        min = 0,
                        max = 20,
                        step = 0.1,
                        decimals = 1,
                        getFunc = function() return TorigaCam.db.presets[presetKey].distance end,
                        setFunc = function(value) 
                            TorigaCam.db.presets[presetKey].distance = value
                            TorigaCam.RefreshCurrentCamera()
                        end,
                        default = TorigaCam.defaults.presets[presetKey].distance,
                    },
                    {
                        type = "slider",
                        name = L.HORIZ_OFFSET,
                        tooltip = L.HORIZ_OFFSET_TOOLTIP,
                        min = -100,
                        max = 100,
                        step = 1,
                        getFunc = function() return TorigaCam.db.presets[presetKey].horizontal end,
                        setFunc = function(value) 
                            TorigaCam.db.presets[presetKey].horizontal = value
                            TorigaCam.RefreshCurrentCamera()
                        end,
                        default = TorigaCam.defaults.presets[presetKey].horizontal,
                    },
                    {
                        type = "slider",
                        name = L.VERT_OFFSET,
                        tooltip = L.VERT_OFFSET_TOOLTIP,
                        min = -100,
                        max = 100,
                        step = 1,
                        getFunc = function() return TorigaCam.db.presets[presetKey].vertical end,
                        setFunc = function(value) 
                            TorigaCam.db.presets[presetKey].vertical = value
                            TorigaCam.RefreshCurrentCamera()
                        end,
                        default = TorigaCam.defaults.presets[presetKey].vertical,
                    },
                    {
                        type = "slider",
                        name = L.FOV,
                        tooltip = L.FOV_TOOLTIP,
                        min = 35,
                        max = 130,
                        step = 1,
                        getFunc = function() return TorigaCam.db.presets[presetKey].fov end,
                        setFunc = function(value) 
                            TorigaCam.db.presets[presetKey].fov = value
                            TorigaCam.RefreshCurrentCamera()
                        end,
                        default = TorigaCam.defaults.presets[presetKey].fov,
                    }
                }
            }
        }
    end

    local optionsTable = {
        {
            type = "header",
            name = L.HEADER_GENERAL,
        },
        {
            type = "slider",
            name = L.TRANSITION_DURATION,
            tooltip = L.TRANSITION_DURATION_TOOLTIP,
            min = 100,
            max = 2000,
            step = 50,
            getFunc = function() return TorigaCam.db.transitionDuration end,
            setFunc = function(value) TorigaCam.db.transitionDuration = value end,
            default = TorigaCam.defaults.transitionDuration,
        },
        {
            type = "checkbox",
            name = L.SHOULDER_RIGHT,
            tooltip = L.SHOULDER_RIGHT_TOOLTIP,
            getFunc = function() return TorigaCam.db.shoulderRight end,
            setFunc = function(value)
                if TorigaCam.db.shoulderRight ~= value then
                    TorigaCam.ToggleShoulder()
                end
            end,
            default = TorigaCam.defaults.shoulderRight,
        },
        {
            type = "checkbox",
            name = L.LOCK_ZOOM,
            tooltip = L.LOCK_ZOOM_TOOLTIP,
            getFunc = function() return TorigaCam.db.lockZoom end,
            setFunc = function(value) TorigaCam.db.lockZoom = value end,
            default = TorigaCam.defaults.lockZoom,
        }
    }

    -- Append preset submenu controls to options list
    local function AppendPresets(list, presetKey, displayName)
        local controls = GetPresetControls(presetKey, displayName)
        for _, control in ipairs(controls) do
            table.insert(list, control)
        end
    end

    AppendPresets(optionsTable, "explore", "Exploration")
    AppendPresets(optionsTable, "combat", "Combat")
    AppendPresets(optionsTable, "mounted", "Mount")
    AppendPresets(optionsTable, "stealth", "Stealth")
    AppendPresets(optionsTable, "dialogue", "Dialogue")

    LAM:RegisterOptionControls("TorigaCamSettingsPanel", optionsTable)
end

-- Event Callback Wrappers
local function OnCombatStateChanged(eventCode, inCombat)
    TorigaCam.UpdateCameraState()
end

local function OnMountedStateChanged(eventCode, mounted)
    TorigaCam.UpdateCameraState()
end



local function OnPlayerActivated(eventCode)
    TorigaCam.UpdateCameraState()
end

local function OnChatterBegin(eventCode, optionCount)
    TorigaCam.isInteracting = true
    TorigaCam.UpdateCameraState()
end

local function OnChatterEnd(eventCode)
    TorigaCam.isInteracting = false
    TorigaCam.UpdateCameraState()
end

local function OnStealthStateChanged(eventCode, unitTag, stealthState)
    if unitTag == "player" then
        TorigaCam.UpdateCameraState()
    end
end

-- Initialization
local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName == TorigaCam.name then
        EVENT_MANAGER:UnregisterForEvent(TorigaCam.name, EVENT_ADD_ON_LOADED)
        
        -- Load Account-Wide Saved Variables or initialize with defaults (Version 8)
        TorigaCam.db = ZO_SavedVars:NewAccountWide("TorigaCamSavedVariables", 8, nil, TorigaCam.defaults)
        
        -- Registers events to monitor character state changes
        EVENT_MANAGER:RegisterForEvent(TorigaCam.name, EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
        EVENT_MANAGER:RegisterForEvent(TorigaCam.name, EVENT_MOUNTED_STATE_CHANGED, OnMountedStateChanged)

        EVENT_MANAGER:RegisterForEvent(TorigaCam.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
        
        -- Dialogues and interaction hooks
        EVENT_MANAGER:RegisterForEvent(TorigaCam.name, EVENT_CHATTER_BEGIN, OnChatterBegin)
        EVENT_MANAGER:RegisterForEvent(TorigaCam.name, EVENT_CHATTER_END, OnChatterEnd)
        
        -- Stealth state hooks
        EVENT_MANAGER:RegisterForEvent(TorigaCam.name, EVENT_STEALTH_STATE_CHANGED, OnStealthStateChanged)
        
        -- Periodic check every 400ms to handle out-of-order engine events or missed dismounts
        EVENT_MANAGER:RegisterForUpdate(TorigaCam.name .. "Periodic", 400, TorigaCam.UpdateCameraState)
        
        -- Generate Settings Menu UI via LibAddonMenu-2.0
        TorigaCam.CreateSettingsMenu()
    end
end

EVENT_MANAGER:RegisterForEvent(TorigaCam.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
