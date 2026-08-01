# DiabloOrbs — Changelog

## v2.1.1 — 2026-04-18

- **Fixed:** Fresh install now automatically applies the "D4 default" profile on first launch — interface is no longer displayed with raw/unstyled defaults.
- **Fixed:** Angel/Demon decorations (Legacy) are now hidden by default — existing users upgrading from 2.0.x will not see decorations appear unexpectedly. Load the "Legacy default" profile to enable them.
- **Technical:** Version bump to 2.1.1 / AddOnVersion 211.

## v2.1.0 — 2026-04-18

- **Added:** Profile system — "D4 default" and "Legacy default" built-in profiles with calibrated values, available to all users on install.
- **Added:** Profile save / load / create / delete — full profile management panel (submenu Profiles in settings).
- **Added:** Smart reload UI on profile load — only triggers when switching between themes (D4↔Legacy); applies live when staying on the same theme.
- **Added:** Built-in profiles are protected — cannot be overwritten, renamed or deleted.
- **Added:** Legacy layer sizes calibrated and locked as defaults (Border 173px, Shade 160px, Split 165px, Glow 160px).
- **Added:** Angel/Demon decorations section fully localized (EN/FR/DE/ES/IT/RU).
- **Added:** Legacy layer size sliders fully localized (EN/FR/DE/ES/IT/RU).
- **Added:** All profile management UI strings localized in 6 languages (EN/FR/DE/ES/IT/RU), including protection error messages.
- **Fixed:** Hotkey label on quickslot button shifting outside the slot when a long-duration potion is activated — re-anchored after ESO's native icon refresh.
- **Fixed:** Tooltip ID collisions — Legacy slider tooltips renamed B93–B96 (was B79–B82), decoration tooltips renamed LD10–LD17 (was LD01–LD08).
- **Fixed:** Profile dropdown search no longer relies on localized submenu name (now uses control reference).
- **Removed:** "Reset D4" and "Reset Legacy" buttons from General submenu (replaced by built-in profiles).
- **Technical:** Added `## AddOnVersion: 210` to manifest (required by ESOUI).

## v2.0.0 — 2026-04-01

- **Added:** Theme D4 (textures, barre d’action, orbes, jauge ultime) + thème Legacy conservé.
- **Added:** Teinte globale D4 (cadre orbes, socles, fond barre, fond jauge ultime, surcouche contour) avec couleur et intensité.
- **Added:** Option taille du glow d’alerte ressource basse (%).
- **Added:** Localisation complète du panneau de réglages (EN, FR, DE, ES, IT, RU) ; prise en charge des tooltips avec suffixe `[ID: …]`.
- **Fixed:** Décalage des orbes Legacy après nage / changement de zone (repositionnement + textures thème).
- **Fixed:** Couche ombre D4 : visibilité et alpha corrects (ne plus dépendre de l’alpha Legacy).
- **Fixed:** Tooltip orbe mana/endurance D4 : affiche magicka **et** endurance (deux lignes), plus une seule ressource dupliquée.
- **Fixed:** Texte d’aide ESO (Réglages > Combat) : entrée de localisation P489 complète dans toutes les langues.
- **Improved:** Organisation du panneau LAM (sous-menus D4 / Legacy / commun, alertes, texte).
- **Improved:** Tooltips : libellés explicites, cohérence « barre secondaire », corrections diverses.
- **Improved:** Texte jauge ultime en mode valeur : affiche l’ultime **cumulé** / coût de l’ultime équipé (sans plafonner l’affichage au coût).
- **Changed:** Reset D4 réapplique aussi `D4_SHOW_OFFBAR` (dualbar suit les valeurs par défaut).
- **Changed:** Valeurs par défaut : dualbar D4 et Legacy activés par défaut (reset / nouveaux persos).
- **Technical:** Dépendance `LibAddonMenu-2.0>=41` ; pas de LibStub ; réduction des fuites globales Lua (forward `local` pour fonctions internes).

---

## v1.1.3 — 2026-03-22

- **Fixed:** LibAddonMenu-2.0 dependency version corrected to >=41

## v1.1.2 — 2026-03-22

- **Fixed:** Removed outdated APIVersion entry 101034, kept 101049 only
- **Fixed:** Added proper >= version check for LibAddonMenu-2.0 dependency
- **Fixed:** TopLevelControl renamed from DiabloFrame to DiabloFrameTLC to avoid global naming collision
- Dependencies now clearly listed in addon description

## v1.1.1 — (Continued by BulDeZir)

- Continuation of original addon by Forsion
