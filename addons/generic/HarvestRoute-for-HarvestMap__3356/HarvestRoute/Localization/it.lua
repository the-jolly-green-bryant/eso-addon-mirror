-- translations by @horizonxael
HarvestRoute.localizedStrings = {
  -- testi di configurazione
  ["addonsettingstext"] = "HarvestRoute Tracker utilizza una distanza separata per il rilevamento dei nodi. Di solito questa dovrebbe essere considerevolmente inferiore alla normale distanza di rilevamento per assicurarti di aver effettivamente camminato molto vicino a un nodo da aggiungere.",
  ["routenodes"] = "Nuove visite e aiuti alla raccolta",
  ["routerangemultiplier"] = "Distanza delle visite dei nodi",
  ["routerangemultipliertooltip"] = "I nodi entro X metri saranno considerati visitati dal tracker del percorso.",
  ["enabletrackerwindow"] = "Attiva la finestra del tracker",
  ["enabletrackerwindowtooltip"] = "Avisualizza le informazioni sul percorso, la struttura più vicina e l'ultimo nodo del percorso.",
  ["showtrackerwindow"] = "Mostra sempre la finestra del tracker",
  ["showtrackerwindowtooltip"] = "Quando questa opzione è disabilitata, la finestra del tracker non apparirà finché non si attiva il tracker.",
  ["usepathheuristics"] = "Abilita percorso intelligente",
  ["usepathheuristicstooltip"] = "Questa opzione riduce i percorsi a zigzag determinando se l'inserimento di nuove risorse dopo l'ultimo nodo AGGIUNTO o l'ultimo nodo VISITATO crea un percorso più breve",
  
  -- finestra del tracker
  ["trackeractive"] = "|C7FCF7FIl tracker è attivato|r",
  ["trackerinactive"] = "|CFF7F7FIl tracker è disattivato|r",
  ["pathinfomissing"] = "|CFF7F7FPasso del percorso attivo|r",
  ["pathinfotitle"] = "Percorso attuale:",
  ["pathinfo"] = "<<1>> Nodi|CA0A0A0(<<2>> m lunghezza)|r",
  ["nearestnodetitle"] = "Risorsa più vicina:",
  ["nearestnodetooltip"] = "Indica la struttura più vicina alla tua posizione, che non è inclusa nel percorso corrente.",
  ["lastpathnodetitle"] = "Ultima risorsa del corso:",
  ["lastpathnodetooltip"] = "Indica che verranno inseriti nuovi nodi dopo quest'ultimo nodo incluso nel percorso corrente.",
  ["nodeinfounknown"] = "|CA0A0A0Nessun nodo sotto i 50 m|r",
  ["nodeinfo"] = [[<<1>> |CA0A0A0(<<2>> m)|r]],
  
  -- generatore di percorsi di Harvestmap
  ["tourtrackerdescription"] = [[L'abilitazione del tracker inserirà automaticamente nuovi nodi dopo l'ultimo raccolto incluso nel tuo percorso. Senza un percorso attivo, ne verrà creato uno nuovo dopo aver visitato almeno 3 nodi noti. Le icone dovrebbero essere non nascoste.]]  ,
  ["buttonstarttracker"] = "Attiva il tracker",
  ["buttonstoptracker"] = "Disattiva il tracker",
}