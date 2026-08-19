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
- activation automatique des trackers normaux pour tous les sets a stacks du catalogue
- tracker visible a 0 stack des que le bonus du set est actif, puis affichage des stacks reels
- disparition automatique du tracker quand le set est retire ou perd son bonus sur la barre active
- Yokeda implacable, Siroria, Relequen, Tzogvin, Kinras, Z'en, Catalyseur elementaire et mythiques a stacks pris en charge
- liens de contact en jeu vers `@TeamFF` et `@Eyr0n`

Commande :

```text
/tsb
```

Ouvre directement la fenetre de gestion Team Shadows Buffs. Toutes les fonctions sont accessibles depuis l'interface.

Partage de groupe :

- les configurations de panneau et de tracker sont decoupees en morceaux controles
- chaque destinataire confirme chaque morceau recu
- seuls les morceaux manquants sont renvoyes, avec trois tentatives maximum
- le chat confirme le nombre de destinataires ou nomme les comptes qui n'ont pas repondu
- l'ancien format de partage reste accepte a la reception

Depuis la version `0.4.5`, l'addon envoie aussi une copie compatible avec les anciennes versions et detecte d'abord les joueurs capables de confirmer. Les anciennes versions ne provoquent donc plus de tentatives inutiles. Tous les membres doivent utiliser la version `0.4.5` ou superieure pour participer aux confirmations fiables.
