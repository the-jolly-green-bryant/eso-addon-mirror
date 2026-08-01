# Team Shadows Buffs

Addon separe de Team Shadows Manager pour suivre les buffs/debuffs en cercles.

Le noyau charge chaque module avec `pcall`. Si un module plante, il est marque en erreur et les autres modules continuent.

Lib requise a installer via Minion :

- `LibAddonMenu-2.0` pour afficher les reglages dans les parametres ESO

Si la lib manque, TESO l'affiche directement comme dependance manquante dans le menu Extensions.

Reglages dans les parametres ESO :

- meme fenetre, buffs/debuffs separes, ou chaque tracker dans sa fenetre
- ordre des buffs et debuffs
- liste Major - Buffs / Major - Debuffs
- activation/desactivation de chaque tracker
- nom, abreviation, taille de cellule et couleur personnalisables par tracker
- option pour masquer les noms et garder seulement cercle + acronyme
- reset global ou par tracker

Commandes :

```text
/tsbuffs status
/tsbuffs effects
/tsbuffs toggle MajorEffects
/tsbuffs debug
```

Alias :

```text
/tsb
```
