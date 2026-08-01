Archaeology = Archaeology or {}
local AA = Archaeology

AA.name = "Archaeology"
AA.maxDisplayedLeads = 3
AA.hasShownLoginSummary = false
AA.defaults = {
    loginMaxLeadAgeDays = 14,
    autoLoginSummaryEnabled = true,
    autoZoneSummaryEnabled = true,
}
AA.savedVariables = nil
AA.loginMaxLeadAgeDays = AA.defaults.loginMaxLeadAgeDays
AA.loginMaxLeadAgeSeconds = AA.loginMaxLeadAgeDays * 24 * 60 * 60
AA.autoLoginSummaryEnabled = AA.defaults.autoLoginSummaryEnabled
AA.autoZoneSummaryEnabled = AA.defaults.autoZoneSummaryEnabled
AA.lastAnnouncedZoneId = nil
AA.usageText = "Usage: /archaeology [all|zone|zone all|<number>|top <number>|zone <number>|help]"

AA.unearthedSuccessMessages = {
    "Brushed, polished, and proudly pocketed.",
    "Archaeology says: certified dirt wizardry.",
    "That relic did not stand a chance.",
    "You excavated that like a pro with a tiny shovel.",
    "Another antiquity rescued from eternal mud.",
    "Museum curators are quietly impressed.",
    "Dust: defeated. Treasure: secured.",
    "A flawless extraction from the layers of history.",
    "You read that soil like an open book.",
    "This relic has officially been promoted to backpack.",
    "Careful hands, clean pull, great success.",
    "Ancient puzzle solved by modern shovel science.",
    "You unearthed that like it owed you gold.",
    "No cracks, no chaos, just perfect excavation.",
    "Dig site closed. Trophy acquired.",
    "Your trowel deserves a standing ovation.",
    "One more mystery turned into inventory.",
    "That antiquity is now under new management.",
    "You just won another argument with the dirt.",
    "History called. It said thank you.",
    "Smooth recovery. Zero panic. Maximum style.",
    "Relic found and absolutely vibing.",
    "Outstanding excavation posture. Very professional.",
    "You made that look suspiciously easy.",
    "The soil never saw it coming.",
    "Excavation complete. Confidence increased.",
    "Another fragment of the past, safely retrieved.",
    "Trowel technique: immaculate.",
    "Legend says the dirt is still confused.",
    "Treasure secured with surgical precision.",
    "Archaeologists everywhere nod in approval.",
    "You excavated with grace and unreasonable efficiency.",
    "The ground yielded. You prevailed.",
    "Another relic saved from eternal underground storage.",
    "Calm hands, sharp eyes, perfect pull.",
    "Textbook excavation. Someone frame this moment.",
    "Relic acquired. Mud politely dismissed.",
    "That's how professionals do controlled chaos.",
    "You turned guesswork into greatness.",
    "Precision digging at its finest.",
    "Clean extraction confirmed.",
    "The antiquity has left the chat... and entered your bag.",
    "You dug smart, not hard.",
    "Even the brush looked impressed.",
    "Artifact secured without drama. Love to see it.",
}

AA.difficultyNameFallbacks = {
    "Simple",
    "Intermediate",
    "Advanced",
    "Master",
    "Ultimate",
}
