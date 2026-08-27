local releaseNotes = {
    en = [[

Current release · 0.18.8
• Added a shopping-session summary with purchases, spending, updated lists, and remaining entries.
• Expanded the public API with list management, progress snapshots, and non-mutating matching previews.
• Added protected list, item, and purchase update callbacks while retaining API v1 and v2 compatibility.
• Added crafting-material transfers for companion add-ons and a WritWorthy Master Writ action that merges requirements into Own Total entries.

0.18.7
• Reorganized the add-on into clear core, feature, integration, keyboard, gamepad, and shared UI modules.
• Added per-list item searching and sorting by name, quantity, ownership, completion, price target, and date added.
• Added favorite and pinned lists plus optional list categories.

0.18.5
• Added recurring lists and safe progress resets that preserve purchase history.
• Added Buy More and Own Total quantity targets with inventory-driven remaining counts.
• Added tradeable set-piece autocomplete backed by LibSets.
• Added schema-versioned migrations and five automatic safety copies before risky data changes.
• Added keyboard and gamepad restoration of automatic safety copies.
• Added safe, one-time recovery for lists saved under the former add-on name.
• Added strict typed validation and atomic restoration for SLB1 full backups.
• Corrected missing window visuals and gamepad backdrop warnings.

0.17.0
• Expanded the public API with atomic named-list creation, batch entry, matching-rule overrides, and stable errors.
• Added SL2 sharing for links, notes, matching rules, and price targets while retaining SL1 imports.

0.16.0–0.16.4
• Added inventory-aware quantities, notes, full SLB1 backup, accessibility settings, chat-link actions, and Spanish and French translations.]],
    es = [[

Versión actual · 0.18.8
• Se añadió un resumen de la sesión de compras con compras, gastos, listas actualizadas y entradas pendientes.
• Se amplió la API pública con gestión de listas, datos de progreso y vistas previas de coincidencia sin modificaciones.
• Se añadieron eventos protegidos para cambios de listas, artículos y compras, conservando la compatibilidad con las API v1 y v2.
• Se añadieron transferencias de materiales para complementos de artesanía y una acción de encargos magistrales de WritWorthy que combina los requisitos como Total propio.

0.18.7
• Se reorganizó el complemento en módulos claros de núcleo, funciones, integraciones e interfaz para teclado, mando y elementos compartidos.
• Se añadieron búsquedas y ordenación por lista según nombre, cantidad, posesión, estado, precio objetivo y fecha de adición.
• Se añadieron listas favoritas y fijadas, además de categorías opcionales.

0.18.5
• Se añadieron listas recurrentes y reinicios seguros que conservan el historial de compras.
• Se añadieron objetivos Comprar más y Total propio con cantidades pendientes según el inventario.
• Se añadió el autocompletado de piezas de conjunto comerciables mediante LibSets.
• Se añadieron migraciones con versión de esquema y cinco copias automáticas antes de cambios de datos arriesgados.
• Se añadió la restauración de copias automáticas para teclado y mando.
• Se añadió una recuperación segura y única de listas guardadas con el nombre anterior del complemento.
• Se añadieron validación estricta y restauración atómica para copias completas SLB1.
• Se corrigieron los elementos visuales ausentes y los avisos del fondo para mando.

0.17.0
• Se amplió la API pública con creación atómica de listas, entrada por lotes, reglas de coincidencia y errores estables.
• Se añadió el uso compartido SL2 para enlaces, notas, reglas y precios objetivo, conservando la importación SL1.

0.16.0–0.16.4
• Se añadieron cantidades de inventario, notas, copia completa SLB1, accesibilidad, acciones de enlaces del chat y traducciones al español y francés.]],
    fr = [[

Version actuelle · 0.18.8
• Ajout d'un résumé de session avec achats, dépenses, listes mises à jour et entrées restantes.
• Extension de l'API publique avec gestion des listes, états de progression et aperçus de correspondance sans modification.
• Ajout de rappels protégés pour les mises à jour des listes, articles et achats, tout en conservant la compatibilité avec les API v1 et v2.
• Ajout du transfert de matériaux pour les extensions d'artisanat et d'une action WritWorthy qui fusionne les besoins d'une commande de maître en objectifs Total possédé.

0.18.7
• Réorganisation de l'extension en modules clairs pour le cœur, les fonctions, les intégrations et les interfaces clavier, manette et partagées.
• Ajout de la recherche par liste et du tri par nom, quantité, possession, état, prix cible et date d'ajout.
• Ajout des listes favorites et épinglées ainsi que de catégories facultatives.

0.18.5
• Ajout des listes récurrentes et de réinitialisations sûres conservant l'historique d'achat.
• Ajout des objectifs Acheter plus et Total possédé avec le calcul restant selon l'inventaire.
• Ajout de la saisie semi-automatique des pièces d'ensemble échangeables grâce à LibSets.
• Ajout de migrations versionnées et de cinq copies automatiques avant les modifications de données risquées.
• Ajout de la restauration des copies automatiques au clavier et à la manette.
• Ajout d'une récupération sûre et unique des listes enregistrées sous l'ancien nom de l'extension.
• Ajout d'une validation stricte et d'une restauration atomique des sauvegardes complètes SLB1.
• Correction des éléments visuels absents et des avertissements d'arrière-plan de la manette.

0.17.0
• Extension de l'API publique avec création atomique de listes, ajout groupé, règles de correspondance et erreurs stables.
• Ajout du partage SL2 pour les liens, notes, règles et prix cibles, tout en conservant l'importation SL1.

0.16.0–0.16.4
• Ajout des quantités d'inventaire, notes, sauvegardes SLB1, options d'accessibilité, actions des liens de discussion et traductions espagnole et française.]],
}

local language = GetCVar("language.2")
SafeAddString(
    SI_SHOPPING_LIST_RELEASE_NOTES_CONTENT,
    releaseNotes[language] or releaseNotes.en,
    2
)
