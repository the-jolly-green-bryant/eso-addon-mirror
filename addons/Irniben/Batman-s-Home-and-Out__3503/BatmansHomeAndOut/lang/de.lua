local L = {}

L.SI_BINDING_NAME_BHAO = "Haus verlinken und Instanz verlassen"

L.BatmansHAO_LocationDropdown = "Haus zum Verlinken"
L.BatmansHAO_CustomText = "Text vor dem Link"
L.BatmansHAO_CustomTextStandard = "P-T-E und porten nach:"
L.BatmansHAO_WaitingTime = "Warte auf Senden des Textes (in Sekunden)"
L.BatmansHAO_WaitingTimeTT = "Solltest du die Funktion einmal benutzen und es dir dann noch anders überlegen, wird das Addon die festgelegte Zeit in Sekunden warten, bevor es sich zurücksetzt. Das verhindert, dass du später aus einer Instanz gekickt wirst, falls du doch noch dein Haus im Chat verlinkst."
L.BatmansHAO_ExitOnChat = "Automatisch porten oder Instanz verlassen, wenn der Gruppenanführer ein Haus postet"
L.BatmansHAO_AutoReset  = "Instanz automatisch nach dem Verlassen zurücksetzen"
L.BatmansHAO_PortToHouse = "Reise automatisch zum Haus, falls du nach Verlassen der Instanz nicht schon dort bist (und die ultimative Kraft nicht bei 100% ist)."
L.BatmansHAO_PortBack = "Reise wieder in die zurückgesetzte Instanz, nachdem die Ressourcen aufgefüllt wurden (oder nach dem Zurücksetzen, falls kein Auffüllen nötig ist)."
L.BatmansHAO_PortBackWait = "Wartezeit zwischen Reisen"
L.BatmansHAO_PortBackWaitTT = "Wenn deine Ressourcen bereits gefüllt sind, wird das Addon versuchen, direkt zurück in die Instanz zu porten. Dabei können evtl. andere Addons dazwischenfunken. Stelle hier eine höhere Wartezeit ein, falls es beim Zurückreisen zu Problemen kommt."
L.BatmansHAO_PortBackRetry = "Reisen erneut versuchen"
L.BatmansHAO_PortBackRetryTT = "Wählst du einen Wert über 0, wird das Addon für diese Anzahl an Sekunden immer wieder versuchen, zu reisen, falls der Vorgang unterbrochen wird. Stelle hier einen höheren Wert ein, falls es trotz Wartezeit zu Problemen beim Zurückreisen kommt."
L.BatmansHAO_VeteranOnly = "Nur in Veteranenmodus aktivieren."

L.BatmansHAO_UseStrangersHouse = "Fremdes Haus verwenden"
L.BatmansHAO_AutoResetSuccess = "Instanz zurückgesetzt"

L.BatmansHAO_PortToLeader = "Reise zum Anführer, sobald dieser zurück in der Instanz ist"
L.BatmansHAO_WaitForUlti = "Reise erst, wenn alle Ressourcen auf 100% sind"

L.BatmansHAO_DiagPortNow = "Instanz verlassen und zu %s reisen?"

for stringId, stringValue in pairs(L) do
	SafeAddString(_G[stringId], stringValue, 0)
end