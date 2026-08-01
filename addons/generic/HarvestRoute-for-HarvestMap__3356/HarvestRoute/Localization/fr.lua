-- translations by XXXspartiateXXX
HarvestRoute.localizedStrings = {
  -- textes de configuration
  ["addonsettingstext"] = "HarvestRoute Tracker de parcours utilise une distance distincte pour la détection des nœuds. Habituellement, cela devrait être considérablement inférieur à la distance de détection normale pour s'assurer que vous avez réellement marché très près d'un nœud à ajouter.",
  ["routenodes"] = "Nœuds visités et aide à la récolte",
  ["routerangemultiplier"] = "Distance de visite des nœuds",
  ["routerangemultipliertooltip"] = "Les nœuds situés à moins de X mètres seront considérés comme visités par le tracker de parcours.",
  ["enabletrackerwindow"] = "Activer la fenêtre du Tracker",
  ["enabletrackerwindowtooltip"] = "Affiche les informations sur le parcours, la ressource la plus proche et le dernier nœud du parcours.",
  ["showtrackerwindow"] = "Toujours afficher la fenêtre du Tracker",
  ["showtrackerwindowtooltip"] = "Lorsque cette option est désactivée, la fenêtre du tracker ne s'affichera qu'une fois que vous aurez activé le tracker.",
  ["usepathheuristics"] = "Activer Chemin intelligent",
  ["usepathheuristicstooltip"] = "Cette option réduit les chemins en zigzag en déterminant si l'insertion de nouvelles ressources après le dernier nœud AJOUTÉ ou le dernier nœud VISITÉ crée un chemin plus court",
  
  -- fenêtre du tracker
  ["trackeractive"] = "|C7FCF7FLe tracker est activé|r",
  ["trackerinactive"] = "|CFF7F7FLe tracker est désactivé|r",
  ["pathinfomissing"] = "|CFF7F7FPas de parcours actif|r",
  ["pathinfotitle"] = "Parcours actuel:",
  ["pathinfo"] = "<<1>> Nœuds|CA0A0A0(<<2>> m longueur)|r",
  ["nearestnodetitle"] = "Ressource la plus proche:",
  ["nearestnodetooltip"] = "Indique la ressource la plus proche de votre position, qui n'est pas incluse dans le parcours en cours.",
  ["lastpathnodetitle"] = "Dernière ressource du parcours:",
  ["lastpathnodetooltip"] = "Indique que les nouveaux nœuds seront insérés après ce dernier nœud inclus dans le parcours en cours.",
  ["nodeinfounknown"] = "|CA0A0A0Aucun nœud à moins de 50 m|r",
  ["nodeinfo"] = [[<<1>> |CA0A0A0(<<2>> m)|r]],
  
  -- générateur de parcours d'harvestmap
  ["tourtrackerdescription"] = [[Activer le tracker insérera de nouveaux nœuds automatiquement après le dernier collecté inclus dans votre parcours. Sans parcours actif, il en sera crée un nouveau après avoir visité 3 nœuds connus au minimum. Les icônes doivent être non masquées.]]  ,
  ["buttonstarttracker"] = "Activer le tracker",
  ["buttonstoptracker"] = "Désactiver le tracker",
}
