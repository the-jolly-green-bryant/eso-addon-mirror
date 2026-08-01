-- =====================================================================
-- BSCs Advanced Synergy – Tracking (Icons + CDs)
-- =====================================================================
BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy

-- ---------------------------------------------------------------------
-- Interner Zustand / Caches
-- ---------------------------------------------------------------------
local SYNERGYLIST = {}
local TSG_LIST    = {}

local TRACK = {
  controls = {},   -- pro Slot: { root, icon, syn, set, lastSynTenths, lastSetTenths }
  visible  = {},   -- Reihenfolge der gerade sichtbaren Slot-Indizes
  inited   = false,
}

local debug_mode = false
function BSCAS.TrackDebugMode()
  debug_mode = not debug_mode
  BSCAS:PrintDebug("Debug Mode (Tracking) " .. (debug_mode and "Enabled!" or "Disabled!"))
end

local function dbg(fmt, ...)
  if not debug_mode then return end
  BSCAS:PrintDebug(string.format(fmt, ...))
end

-- Kleiner Helper: Spieler-Zone (gleich wie bisher benutzt)
local function zoneIdOfPlayer()
  return GetUnitWorldPosition("player")
end

-- ---------------------------------------------------------------------
-- Enable-Liste (wie gehabt, nur leicht eingerückt)
-- ---------------------------------------------------------------------
local function UpdateEnabled()
  SYNERGYLIST = {}
  SYNERGYLIST[ABILITYID_CD_BLOOD_FUNNEL]        = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.BLOODALTAR,  id = 1,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_BLOOD_FUNNEL),     }
  SYNERGYLIST[ABILITYID_CD_FEAST_FUNNEL]        = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.BLOODALTAR,  id = 1,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_FEAST_FUNNEL),     }
  SYNERGYLIST[ABILITYID_CD_SPAWNBROODLING]      = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.SPIDERS,     id = 2,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SPAWNBROODLING),   }
  SYNERGYLIST[ABILITYID_CD_BLACK_WIDOW]         = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.SPIDERS,     id = 2,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_BLACK_WIDOW),     }
  SYNERGYLIST[ABILITYID_CD_ARACHNOPHOBIA]       = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.SPIDERS,     id = 2,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_ARACHNOPHOBIA),  }
  SYNERGYLIST[ABILITYID_CD_BONE_WALL]           = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.BONESHIELD,  id = 3,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_BONE_WALL),       }
  SYNERGYLIST[ABILITYID_CD_SPINALSURGE]         = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.BONESHIELD,  id = 3,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SPINALSURGE),     }
  SYNERGYLIST[ABILITYID_CD_SHARTBUBLE_1]        = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.SHARTSORBS,  id = 4,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SHARTBUBLE_1),    }
  SYNERGYLIST[ABILITYID_CD_SHARTBUBLE_2]        = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.SHARTSORBS,  id = 4,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SHARTBUBLE_2),    }
  SYNERGYLIST[ABILITYID_CD_SHARTBUBLE_3]        = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.SHARTSORBS,  id = 4,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SHARTBUBLE_3),    }
  SYNERGYLIST[ABILITYID_CD_HEALING_COMBUSTION]  = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.SHARTSORBS,  id = 4,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_HEALING_COMBUSTION), }
  SYNERGYLIST[ABILITYID_CD_PURIFY]              = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.PURIFY,      id = 5,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_PURIFY),        }
  SYNERGYLIST[ABILITYID_CD_CONDUIT]             = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.CONDUIT,     id = 6,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_CONDUIT),       }
  SYNERGYLIST[ABILITYID_CD_CHARGED_LIGHTNING]   = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.ATRONACH,    id = 7,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_CHARGED_LIGHTNING),}
  SYNERGYLIST[ABILITYID_CD_SHACKLE]             = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.SHACKLE,     id = 8,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SHACKLE),      }
  SYNERGYLIST[ABILITYID_CD_IGNITE]              = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.SHACKLE,     id = 8,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_IGNITE),       }
  SYNERGYLIST[ABILITYID_CD_HARVEST]             = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.HARVEST,     id = 9,  bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_HARVEST),      }
  SYNERGYLIST[ABILITYID_CD_GRAVEROBBER]         = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.GRAVEROBBER, id = 10, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_GRAVEROBBER),   }
  SYNERGYLIST[ABILITYID_CD_PURE_AGONY]          = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.PUREAGONY,   id = 11, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_PURE_AGONY),   }
  SYNERGYLIST[ABILITYID_CD_FEEDING_FRENZY]      = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.HOWLING,     id = 12, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_FEEDING_FRENZY),}
  SYNERGYLIST[ABILITYID_CD_RUNE]                = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.RUNE,        id = 17, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_RUNE),        }
  SYNERGYLIST[ABILITYID_CD_PORTAL]              = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.PORTAL,      id = 18, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_PORTAL),      }
  SYNERGYLIST[ABILITYID_CD_INNERFIRE]           = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.INNERFIRE,   id = 23, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_INNERFIRE),   }
  -- Sets
  SYNERGYLIST[ABILITYID_CD_URSUS]               = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.URSUS,       id = 13, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_URSUS),       }
  SYNERGYLIST[ABILITYID_URSUS]                  = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.URSUS,       id = 13, bFilterSource = true,  bSetCD = true,  cd = GetAbilityDuration(ABILITYID_CD_URSUS),       }
  SYNERGYLIST[ABILITYID_CD_KRAGLEN]             = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.KRAGLEN,     id = 14, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_KRAGLEN),     }
  SYNERGYLIST[ABILITYID_KRAGLEN]                = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.KRAGLEN,     id = 14, bFilterSource = false, bSetCD = true,  cd = GetAbilityDuration(ABILITYID_CD_KRAGLEN),     }
  SYNERGYLIST[ABILITYID_CD_SANGUINE]            = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.LADYTHORN,   id = 15, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SANGUINE),    }
  SYNERGYLIST[ABILITYID_SANGUINE]               = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.LADYTHORN,   id = 15, bFilterSource = true,  bSetCD = true,  cd = GetAbilityDuration(ABILITYID_SANGUINE),      }
  SYNERGYLIST[ABILITYID_CD_GPREPRISAL]          = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.GPREPRISAL,  id = 16, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_GPREPRISAL),  }
  SYNERGYLIST[ABILITYID_GPREPRISAL]             = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.GPREPRISAL,  id = 16, bFilterSource = true,  bSetCD = true,  cd = GetAbilityDuration(ABILITYID_GPREPRISAL),    }
  -- Portale
  SYNERGYLIST[ABILITYID_CD_VCRPORTAL]           = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.CR_PRTAL,    id = 19, bFilterSource = true,  bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_VCRPORTAL),  }
  SYNERGYLIST[ABILITYID_CD_DSR_REEF]            = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.DSR_REEF,    id = 20, bFilterSource = false, bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_DSR_REEF),    }
  SYNERGYLIST[ABILITYID_CD_SE_AGONY]            = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.SE_PORTAL,   id = 21, bFilterSource = true,  bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SE_AGONY),   }
  SYNERGYLIST[ABILITYID_CD_SE_VANTO_CLARITY]    = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.SE_PORTAL,   id = 21, bFilterSource = true,  bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_SE_VANTO_CLARITY), }
  SYNERGYLIST[ABILITYID_CD_LC_MIRROR]           = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.LC_MIRROR,   id = 22, bFilterSource = true,  bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_LC_MIRROR), }
  SYNERGYLIST[ABILITYID_SYNERGY_ACTIVATE]       = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.OC_SHIELD,   id = 24, bFilterSource = true,  bSetCD = false, cd = GetAbilityDuration(ABILITYID_CD_OC_CARRIONSHIELD), }

  TSG_LIST = {}
  TSG_LIST[1]  = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.BLOODALTAR,  icon = ICON_UNDAUNTED_ALTAR_0,   bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[2]  = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.SPIDERS,     icon = ICON_UNDAUNTED_WEBS_0,    bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[3]  = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.BONESHIELD,  icon = ICON_UNDAUNTED_BONE_0,    bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[4]  = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.SHARTSORBS,  icon = ICON_UNDAUNTED_ORB_2,     bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[5]  = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.PURIFY,      icon = ICON_TEMPLAR_RITUAL_0,    bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[6]  = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.CONDUIT,     icon = ICON_SORC_CONDUIT_0,      bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[7]  = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.ATRONACH,    icon = ICON_SORC_ATRO_0,         bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[8]  = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.SHACKLE,     icon = ICON_DK_CLAW_0,           bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[9]  = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.HARVEST,     icon = ICON_WARDEN_HARVEST_0,    bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[10] = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.GRAVEROBBER, icon = ICON_NECRO_GRAVE_0,       bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[11] = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.PUREAGONY,   icon = ICON_NECRO_TOTEM_0,       bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[12] = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.HOWLING,     icon = ICON_WOLF,                bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[13] = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.URSUS,       icon = ICON_ITEM_URSUS,          bSetCD=true,  cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[14] = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.KRAGLEN,     icon = ICON_ITEM_KRAGLEN,        bSetCD=true,  cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[15] = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.LADYTHORN,   icon = ICON_ITEM_SANGUINE,       bSetCD=true,  cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[16] = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.GPREPRISAL,  icon = ICON_ITEM_GPREPRISAL,     bSetCD=true,  cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[17] = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.RUNE,        icon = ICON_ARCANIST_RUNE,       bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[18] = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.PORTAL,      icon = ICON_ARCANIST_PORTAL,     bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[19] = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.CR_PRTAL,    icon = ICON_VCR_GATE,            bSetCD=false, cdset=0, cdsyn=0, zoneid=1051 }
  TSG_LIST[20] = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.DSR_REEF,    icon = ICON_DSR_DINFESTATION,    bSetCD=false, cdset=0, cdsyn=0, zoneid=1344 }
  TSG_LIST[21] = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.SE_PORTAL,   icon = ICON_SE_AGONY,            bSetCD=false, cdset=0, cdsyn=0, zoneid=1427 }
  TSG_LIST[22] = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.LC_MIRROR,   icon = ICON_LC_MIRROR,           bSetCD=false, cdset=0, cdsyn=0, zoneid=1478 }
  TSG_LIST[23] = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.INNERFIRE,   icon = ICON_UNDAUNTED_FIRE_0,    bSetCD=false, cdset=0, cdsyn=0, zoneid=-1 }
  TSG_LIST[24] = { enable = BSCAS.SV.TRACKING_UI_TSG_LIST.OC_SHIELD,   icon = ICON_OC_CARRIONSHIELD,    bSetCD=false, cdset=0, cdsyn=0, zoneid=1548 }
end

-- ---------------------------------------------------------------------
-- UI: Controls erzeugen (einmalig)
-- ---------------------------------------------------------------------
local function CreateControls()
  TRACK.controls = {}

  for i = 1, #TSG_LIST do
    -- Namensschema deiner XML: "$(parent)Cooldown" + Index
    WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Cooldown", BSCASTackingUI, "BSCASTackingCD", i)
    local root = BSCASTackingUI:GetNamedChild("Cooldown"..i)
    local icon = root:GetNamedChild("Icon")
    local syn  = root:GetNamedChild("SynCD")
    local set  = root:GetNamedChild("SetCD")

    icon:SetTexture(TSG_LIST[i].icon)
    root:SetHidden(true)

    TRACK.controls[i] = { root=root, icon=icon, syn=syn, set=set, lastSynTenths=-1, lastSetTenths=-1 }
  end

  TRACK.inited = true
end

-- Hintergrund-Größe
local function UpdateBackGround(countVisible)
  local size    = BSCAS.SV.TRACKING_UI_SIZE or 48
  local outline = BSCAS.SV.TRACKING_UI_SIZE_OUTLINE or math.floor(size/10)
  local orient  = BSCAS.SV.TRACKING_UI_ORIENT or "Horizontal"

  local bg = BSCASTackingUI:GetNamedChild("Texture")
  if countVisible > 0 then
    bg:SetHidden(false)
    if orient == "Horizontal" then
      bg:SetDimensions(countVisible*(size+outline)+outline, size + 2*outline)
    else
      bg:SetDimensions(size + 2*outline, countVisible*(size+outline)+outline)
    end
  else
    bg:SetHidden(true)
  end
end

-- ---------------------------------------------------------------------
-- Layout anwenden (inkl. TRACKING_ONLY_ACTIVE)
-- ---------------------------------------------------------------------
local function ApplyLayout()
  if not TRACK.inited then return end

  local size      = BSCAS.SV.TRACKING_UI_SIZE or 48
  local outline   = BSCAS.SV.TRACKING_UI_SIZE_OUTLINE or math.floor(size/10)
  local orient    = BSCAS.SV.TRACKING_UI_ORIENT or "Horizontal"
  local alpha     = BSCAS.SV.TRACKING_UI_ALPHA or 1
  local fontFace  = BSCAS.SV.TRACKING_UI_FONT or "BOLD_FONT"
  local fontStyle = BSCAS.SV.TRACKING_UI_FONT_STYLE or "soft-shadow-thick"
  local colN      = BSCAS.SV.TRACKING_UI_FONT_COLOR_N or {0,1,0,1}
  local onlyAct   = BSCAS.SV.TRACKING_ONLY_ACTIVE == true
  local zid       = zoneIdOfPlayer()
  local now       = GetGameTimeMilliseconds()/1000

  local countVisible = 0
  TRACK.visible = {}

  for i = 1, #TSG_LIST do
    local slot = TSG_LIST[i]
    local ctrl = TRACK.controls[i]
    if ctrl then
      local enabled = slot.enable
      if slot.zoneid ~= -1 and slot.zoneid ~= zid then
        enabled = false
      end

      if enabled and onlyAct then
        local synRemain = math.max(0, slot.cdsyn - now)
        local setRemain = math.max(0, slot.cdset - now)
        enabled = (synRemain > 0) or (setRemain > 0)
      end

      if enabled then
        countVisible = countVisible + 1
        TRACK.visible[countVisible] = i

        ctrl.root:SetHidden(false)
        ctrl.root:ClearAnchors()
        if orient == "Horizontal" then
          ctrl.root:SetAnchor(TOPLEFT, BSCASTackingUI, TOPLEFT, outline + (countVisible-1)*(size+outline), outline)
        else
          ctrl.root:SetAnchor(TOPLEFT, BSCASTackingUI, TOPLEFT, outline, outline + (countVisible-1)*(size+outline))
        end

        ctrl.icon:SetDimensions(size, size)

        local fSyn = BSCAS.FontCheck(math.floor(size*0.6))
        local fSet = BSCAS.FontCheck(math.floor(size*0.4))

        ctrl.syn:ClearAnchors()
        ctrl.syn:SetAnchor(CENTER, ctrl.icon, CENTER, 0, (slot.bSetCD and -(fSet/2) or 0))
        ctrl.syn:SetFont(string.format("$(%s)|$(KB_%d)|%s", fontFace, fSyn, fontStyle))
        ctrl.syn:SetColor(unpack(colN))

        ctrl.set:SetHidden(not slot.bSetCD)
        if slot.bSetCD then
          ctrl.set:ClearAnchors()
          ctrl.set:SetAnchor(CENTER, ctrl.icon, CENTER, 0, (fSet/2))
          ctrl.set:SetFont(string.format("$(MEDIUM_FONT)|$(KB_%d)|%s", fSet, fontStyle))
          ctrl.set:SetColor(unpack(colN))
        end
      else
        ctrl.root:SetHidden(true)
      end
    end
  end

  BSCASTackingUI:SetAlpha(alpha)
  UpdateBackGround(countVisible)
end

-- UI-Update (extern nutzbar)
function BSCAS.TrackUpdateUI()
  UpdateEnabled()
  ApplyLayout()
end

-- Position speichern/wiederherstellen
function BSCAS.TrackOnMoveStop()
  BSCAS.SV.TRACKING_UI_LEFT = BSCASTackingUI:GetLeft()
  BSCAS.SV.TRACKING_UI_TOP  = BSCASTackingUI:GetTop()
end

function BSCAS:TrackRestorePosition()
  BSCASTackingUI:ClearAnchors()
  BSCASTackingUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, BSCAS.SV.TRACKING_UI_LEFT, BSCAS.SV.TRACKING_UI_TOP)
  BSCASTackingUI:SetMovable(not BSCAS.SV.TRACKING_LOCK_UI)
end

-- ---------------------------------------------------------------------
-- Kampf-Events -> Start der CDs
-- ---------------------------------------------------------------------
local function OnCombatEvent(_, result, _, _, _, _, sourceName, _, targetName, _, _, _, _, _, sourceUnitId, targetUnitId, abilityId)
  if result ~= ACTION_RESULT_EFFECT_GAINED then
    if debug_mode and result == ACTION_RESULT_EFFECT_FADED then
      dbg("FADED  ID[%d] Name[%s]", abilityId, GetAbilityName(abilityId))
    end
    return
  end

  local cfg = SYNERGYLIST[abilityId]
  if not (cfg and cfg.enable) then
    if debug_mode and GetAbilityDuration(abilityId) >= 10000 then
      dbg("GAINED Unknown ID[%d] Name[%s] Dur[%d]", abilityId, GetAbilityName(abilityId), GetAbilityDuration(abilityId))
    end
    return
  end

  local slot = TSG_LIST[cfg.id]
  if not slot then return end

  local now = GetGameTimeMilliseconds()/1000
  local dur = (cfg.cd or 0)/1000

  if cfg.bSetCD then
    slot.cdset = now + dur
  else
    slot.cdsyn = now + dur
  end

  if debug_mode then
    dbg("GAINED Known ID[%d] Name[%s] Dur[%d]", abilityId, GetAbilityName(abilityId), cfg.cd or -1)
  end

  -- Nur-aktive-Modus: Icon sofort sichtbar machen
  if BSCAS.SV.TRACKING_ONLY_ACTIVE then
    ApplyLayout()
  end
end

-- ---------------------------------------------------------------------
-- Tick: Countdown zeichnen (+ optionales Relayout)
-- ---------------------------------------------------------------------
local function TrackUpdateCooldown()
  local now    = GetGameTimeMilliseconds()/1000
  local colN   = BSCAS.SV.TRACKING_UI_FONT_COLOR_N or {0,1,0,1}
  local colC   = BSCAS.SV.TRACKING_UI_FONT_COLOR_C or {1,0,0,1}
  local size   = BSCAS.SV.TRACKING_UI_SIZE or 48
  local onlyAct= BSCAS.SV.TRACKING_ONLY_ACTIVE == true

  local needRelayout = false

  -- nur aktuell sichtbare Slots traversieren (performant)
  for _, idx in ipairs(TRACK.visible) do
    local slot = TSG_LIST[idx]
    local ctrl = TRACK.controls[idx]
    if slot and ctrl then
      local synRemain = math.max(0, slot.cdsyn - now)
      local setRemain = math.max(0, slot.cdset - now)

      -- Icon Dimmen wenn aktiv
      if synRemain > 0 then
        ctrl.icon:SetColor(0.2, 0.2, 0.2, 1)
      else
        ctrl.icon:SetColor(1, 1, 1, 1)
      end
      ctrl.icon:SetDimensions(size, size)

      -- Syn-Anzeige (Zehntel-Optimierung)
      local synTenths = math.floor(synRemain*10 + 0.5)
      if synTenths ~= ctrl.lastSynTenths then
        ctrl.lastSynTenths = synTenths
        ctrl.syn:SetText(string.format("%.1f", synRemain))
        ctrl.syn:SetColor(unpack(synRemain > 0 and colC or colN))
      end

      -- Set-CD (falls vorhanden)
      if slot.bSetCD then
        local setTenths = math.floor(setRemain*10 + 0.5)
        if setTenths ~= ctrl.lastSetTenths then
          ctrl.lastSetTenths = setTenths
          ctrl.set:SetText(string.format("%.1f", setRemain))
          ctrl.set:SetColor(unpack(setRemain > 0 and colC or colN))
        end
      end

      -- Werte nullen + Relayout wenn nur-aktiv
      if synRemain <= 0 and slot.cdsyn ~= 0 then
        slot.cdsyn = 0
        if onlyAct and (slot.cdset <= 0) then needRelayout = true end
      end
      if setRemain <= 0 and slot.cdset ~= 0 then
        slot.cdset = 0
        if onlyAct and (slot.cdsyn <= 0) then needRelayout = true end
      end
    end
  end

  if onlyAct and needRelayout then
    ApplyLayout()
  end
end

-- ---------------------------------------------------------------------
-- Aktivierung / Init
-- ---------------------------------------------------------------------
local function OnPlayerActivated()
  BSCAS.TrackUpdateUI()
end

function BSCAS.TrackEnable()
  if BSCAS.SV.TRACKING_ENABLED then
    -- Events registrieren
    for abilityId, cfg in pairs(SYNERGYLIST) do
      local eventName = 'BSCAS_TROEC'..abilityId
      EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, OnCombatEvent)
      EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId)

      if cfg.bFilterSource then
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
      else
        EVENT_MANAGER:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
      end
    end

    EVENT_MANAGER:RegisterForUpdate('BSCAS_TrackUpdate', BSCAS.UPDATE_INTERVAL, TrackUpdateCooldown)
    EVENT_MANAGER:RegisterForEvent("BSCAS_Track", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    SCENE_MANAGER:GetScene("hud"):AddFragment(BSCAS.TrackingFragment)
    SCENE_MANAGER:GetScene("hudui"):AddFragment(BSCAS.TrackingFragment)
    BSCASTackingUI:SetHidden(false)
  else
    -- Events deregistrieren
    for abilityId in pairs(SYNERGYLIST) do
      local eventName = 'BSCAS_TROEC'..abilityId
      EVENT_MANAGER:UnregisterForEvent(eventName, EVENT_COMBAT_EVENT)
    end
    EVENT_MANAGER:UnregisterForUpdate('BSCAS_TrackUpdate')
    EVENT_MANAGER:UnregisterForEvent("BSCAS_Track", EVENT_PLAYER_ACTIVATED)

    SCENE_MANAGER:GetScene("hud"):RemoveFragment(BSCAS.TrackingFragment)
    SCENE_MANAGER:GetScene("hudui"):RemoveFragment(BSCAS.TrackingFragment)
    BSCASTackingUI:SetHidden(true)
  end
end

function BSCAS.TrackInit()
  UpdateEnabled()
  CreateControls()
  BSCAS:TrackRestorePosition()
  BSCAS.TrackUpdateUI()

  BSCAS.TrackingFragment = ZO_SimpleSceneFragment:New(BSCASTackingUI)
  BSCAS.TrackEnable()
end
