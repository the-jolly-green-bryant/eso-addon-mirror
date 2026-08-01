-------------------------------------------
-- English localization for AT_Finisher  --
-------------------------------------------

do
   local Add = ZO_CreateStringId

   --Settings
   Add("AT_FINISHER_DESCRIPTION",             "Displays an on-screen alert when you can use your finishers on the target")
   Add("AT_FINISHER_UNLOCK",                  "Unlock Position")
   Add("AT_FINISHER_UNLOCK_TOOLTIP",          "Place the UI wherever you want")
   Add("AT_FINISHER_LOCK",                    "Lock Position")
   Add("AT_FINISHER_TRIGGER",                 "Trigger Value")
   Add("AT_FINISHER_TRIGGER_TOOLTIP",         "20% for sorc, 25% for NBs... you can add a margin to anticipate")
   Add("AT_FINISHER_PVP",                     "PvP")
   Add("AT_FINISHER_PVP_TOOLTIP",             "Also displays alerts on hostile players")
   Add("AT_FINISHER_DIFFTHR_BTN",             "Use Difficulty Threshold")
   Add("AT_FINISHER_DIFFTHR_BTN_TOOLTIP",     "Displays alerts for targets given their difficulty rating")
   Add("AT_FINISHER_DIFFTHR_SLIDER",          "Difficulty Threshold")
   Add("AT_FINISHER_DIFFTHR_SLIDER_TOOLTIP",  "Target's minimum difficulty that can trigger an alert")
   Add("AT_FINISHER_HPTHR_BTN",               "Use HP Threshold")
   Add("AT_FINISHER_HPTHR_BTN_TOOLTIP",       "Displays alerts for targets given their max HP")
   Add("AT_FINISHER_HPTHR_SLIDER",            "HP Threshold (in kHP)")
   Add("AT_FINISHER_HPTHR_SLIDER_TOOLTIP",    "ie : for raid bosses only, choose the highest value")   
   Add("AT_FINISHER_FONTCOLOR",               "Alert Font Color")
   Add("AT_FINISHER_FONTCOLOR_TOOLTIP",       "Choose your colors")
   Add("AT_FINISHER_FINISH",				  "Finish Text")
   Add("AT_FINISHER_FINISH_TOOLTIP",		  "Choose your finish text")
   Add("AT_FINISHER_RELOAD",				  "Will need to reload")
end
