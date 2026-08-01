CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

CDescriptor.Constants = {
  ADDON_NAME    = "CDescriptor",
  VERSION       = "1.2.1",
  SLASH_COMMAND = "/cdescriptor",
  DEBUG         = false,

  -- Control names as defined in CDescriptor.xml
  CONTROLS = {
    WINDOW          = "CDescriptorWindow",
    OUTPUT_BOX      = "CDescriptorOutputBox",
    SCROLLBAR       = "CDescriptorScrollbar",
    STATUS_LABEL    = "CDescriptorWindowStatusLabel",
    GENERATE_BUTTON = "CDescriptorWindowGenerateButton",
    COPY_BUTTON     = "CDescriptorWindowCopyButton",
    CLEAR_BUTTON    = "CDescriptorWindowClearButton",
    CHECK_SETS      = "CDescriptorWindowCheckSets",
    CHECK_STATS     = "CDescriptorWindowCheckStats",
    CHECK_BUFFS     = "CDescriptorWindowCheckBuffs",
    CHECK_PASSIVES  = "CDescriptorWindowCheckPassives",
    CHECK_CP        = "CDescriptorWindowCheckCp",
    CHECK_PROMPT    = "CDescriptorWindowCheckPrompt",
    PROMPT_PANEL        = "CDescriptorWindowPromptPanel",
    VERSION_LABEL       = "CDescriptorWindowVersionLabel",
    PROMPT_CONTENT_CAT  = "CDescriptorPromptContentCat",
    PROMPT_CONTENT_SUB  = "CDescriptorPromptContentSub",
    PROMPT_CONTENT_DIFF = "CDescriptorPromptContentDiff",
    PROMPT_ROLE         = "CDescriptorPromptRole",
    PROMPT_LANG         = "CDescriptorPromptLang",
  },

  -- UI strings
  UI = {
    GENERATE_BUTTON   = "Generate",
    COPY_BUTTON       = "Select",
    CLEAR_BUTTON      = "Clear",
    STATUS_IDLE       = "",
    STATUS_EXTRACT    = "Extracting...",
    STATUS_DONE       = "Done.",
    STATUS_ERROR      = "Error: ",
    STATUS_COPY       = "Selected — press Ctrl+C to copy",
    CHECK_SETS_LABEL      = "Set descriptions",
    CHECK_STATS_LABEL     = "Combat stats",
    CHECK_BUFFS_LABEL     = "Active buffs",
    CHECK_PASSIVES_LABEL  = "Passive skills",
    CHECK_CP_LABEL        = "Champion points",
    CHECK_PROMPT_LABEL    = "Include prompt",
  },

  -- Saved variables keys
  SAVED_VARS = {
    WINDOW_X      = "window_x",
    WINDOW_Y      = "window_y",
    WINDOW_W      = "window_w",
    WINDOW_H      = "window_h",
    INCLUDE_SETS     = "include_sets",
    INCLUDE_STATS    = "include_stats",
    INCLUDE_BUFFS    = "include_buffs",
    INCLUDE_PASSIVES = "include_passives",
    INCLUDE_CP       = "include_cp",
    INCLUDE_PROMPT   = "include_prompt",
    PROMPT_CAT       = "prompt_cat",
    PROMPT_SUB       = "prompt_sub",
    PROMPT_DIFF      = "prompt_diff",
    PROMPT_ROLE      = "prompt_role",
    PROMPT_LANG      = "prompt_lang",
  },
}
