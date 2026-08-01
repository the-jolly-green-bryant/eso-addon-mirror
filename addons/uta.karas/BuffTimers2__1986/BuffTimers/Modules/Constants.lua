BuffTimers = {
  name    = 'BuffTimers',
  version = '2.31.1',
  author  = 'coolmodi, Uta',
}

BuffTimers.activeBars = {}

BuffTimers.defaultBarData = {
  buffName        = '',
  offset          = {x=200, y=150},
  locked          = false,
  alwaysShow      = true,
  width           = 200,
  height          = 30,
  textSize        = 20,
  reverse         = false,
  colorBar        = {1,0,0,1,0,1,0,1},
  colorEdge       = {0,0,0,1},
  colorBackground = {0.2,0.2,0.2,0.4},
  colorLabel      = {1,1,1,1},
  icon            = {show = true, size = 30, texture = '', customIcon = false, customIconTexture = '', color = {1,1,1,1}},
  notification    = {threshold = 2, sound = 'none', text = true, customText = ''},
}

BuffTimers.targetEffectTypes = {
  [EFFECT_RESULT_GAINED]  = true,
  [EFFECT_RESULT_UPDATED] = true,
}

BuffTimers.acceptFadeAbilityId = {
  [21007]   = true, -- Reflective Scale
  [21014]   = true, -- Reflective Plate
  [21017]   = true, -- Dragon Fire Scale
  [24574]   = true, -- Defensive Rune
  [28727]   = true, -- Defensive Posture
  [38312]   = true, -- Defensive Stance
  [38317]   = true, -- Absorb Magic
  [46327]   = true, -- Crystal Fragments Proc
  [63151]   = true, -- Vengeance
  [79089]   = true, -- Varen's Wall
  [100306]  = true, -- Concentrated Force (Asylum Destruction Staff)
  [114861]  = true, -- Blastbones
  [114863]  = true, -- Blastbones
  [115924]  = true, -- Shocking Siphon
  [116445]  = true, -- Shocking Siphon
  [117691]  = true, -- Blighted Blastbones
  [117692]  = true, -- Blighted Blastbones
  [117750]  = true, -- Stalking Blastbones
  [117751]  = true, -- Stalking Blastbones
  [118008]  = true, -- Mystic Siphon
  [118009]  = true, -- Mystic Siphon
  [118763]  = true, -- Detonating Siphon
  [118764]  = true, -- Detonating Siphon
  [147843]  = true, -- Wrath of Elements (Vateshran Destruction Staff)
  [147872]  = true, -- Force Overflow (Vateshran Restoration Staff)
}

BuffTimers.GROUP_BUFF_WARHORN = 21
BuffTimers.GROUP_BUFF_ALKOSH  = 22
BuffTimers.groupBuffs = {
  [1] = {
    name        = 'Alkosh',
    barNumber   = BuffTimers.GROUP_BUFF_ALKOSH,
    iconTexture = '/esoui/art/icons/gear_dromathra_medium_head_a.dds',
  },
  [2] = {
    name        = 'Warhorn',
    barNumber   = BuffTimers.GROUP_BUFF_WARHORN,
    iconTexture = '/esoui/art/icons/ability_ava_003.dds',
  },
}
BuffTimers.groupBuffsAbilityId = {
  [38564] = BuffTimers.GROUP_BUFF_WARHORN, -- War Horn
  [40221] = BuffTimers.GROUP_BUFF_WARHORN, -- Sturdy Horn
  [40224] = BuffTimers.GROUP_BUFF_WARHORN, -- Aggressive Horn
  [76667] = BuffTimers.GROUP_BUFF_ALKOSH,  -- Roar of Alkosh
}

BuffTimers.sounds = {
  'none',
  'Achievement_Awarded',
  'Console_Character_Click',
  'Console_Game_Enter',  
  'Duel_Start',
  'Duel_Won',
  'Emperor_Abdicated',
  'Emperor_Coronated_Aldmeri',
  'EnlightenedState_Gained',
  'EnlightenedState_Lost',
  'General_Alert_Error',
  'Justice_NowKOS',
  'Justice_StateChanged',
  'Justice_NoLongerKOS',
  'Justice_PickpocketBonus',
  'Justice_PickpocketFailed',
  'LevelUp',
  'Lockpicking_lockpick_broke',
  'Lockpicking_force',
  'Money_Transact',
  'New_Mail',
  'New_Notification',
  'New_NotificationTimed',
  'Objective_Accept',
  'Objective_Discovered',
  'Quest_Abandon',
  'Quest_Accept',
  'Skill_Gained',
  'SkillLine_Leveled',
  'Telvar_MultiplierMax',
  'Telvar_MultiplierUp',
  'Voice_Chat_Menu_Channel_Joined',
  'Voice_Chat_Menu_Channel_Left',
  'Voice_Chat_Menu_Channel_Made_Active',
}
