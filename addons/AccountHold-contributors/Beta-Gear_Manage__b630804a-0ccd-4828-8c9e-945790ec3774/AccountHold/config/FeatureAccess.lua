-- AccountHold/config/FeatureAccess.lua
-- =============================================================================
-- MAINTAINER-EDITED ACCESS DATA. This is the ONE file you edit to control who
-- gets the add-on and which optional features roll out to which testers.
--
-- It is plain Lua on purpose: ESO loads Lua natively, so no JSON/parser
-- dependency is added. Edit the tables below, save, and reload the UI in game
-- (`/reloadui` on PC) — no code changes required.
--
-- ----------------------------------------------------------------------------
-- HOW MATCHING WORKS (read once, then it is obvious):
--   * List ESO account @handles / Xbox gamertags as strings, e.g. "@noobuddy".
--   * The leading "@" is OPTIONAL — "@noobuddy" and "noobuddy" are equivalent.
--   * Matching is CASE-INSENSITIVE — "@NooBuddy" matches "@noobuddy".
--   * Surrounding whitespace is TRIMMED — "  @noobuddy " is fine.
--   * INTERNAL spaces are PRESERVED — an Xbox gamertag like "Gamer Tag" is
--     stored/decorated by ESO as "@Gamer Tag"; write it exactly, spaces and
--     all: "@Gamer Tag". Do NOT collapse or remove the internal space.
--
-- WHERE THE NAME COMES FROM:
--   The add-on reads the local identity from GetDisplayName(), which is the
--   authoritative cross-platform account handle. On Xbox, ESO decorates the
--   gamertag as "@<gamertag>". So an Xbox player "Gamer Tag" is matched as
--   "@Gamer Tag".
--
-- ⚠ XBOX / GAMERTAG RENAMES: the gamertag IS the key. If a tester renames
--   their Xbox gamertag, their old entry here STOPS matching — update the list
--   with the new name. There is no stable numeric id available to an add-on.
--
-- ⚠ THIS IS NOT SECURITY. These allowlists are a ROLLOUT / UX control, not an
--   entitlement or license check. This file SHIPS AS READABLE SOURCE with the
--   add-on: anyone who downloads it can read (and edit) the names. Never treat
--   a client-side gate as a security boundary — it only decides which UI is
--   built for a given account, nothing an attacker can't bypass locally.
-- =============================================================================

AccountHold = AccountHold or {}

AccountHold.FeatureAccessConfig = {

    -- -------------------------------------------------------------------------
    -- WHOLE-ADD-ON GATE (migrated from the old AUTHORIZED_ACCOUNTS list).
    --
    -- mode:
    --   "allowlist" — only accounts in `allow` get the add-on. IMPORTANT legacy
    --                 behaviour: an EMPTY `allow` list is treated as OPEN (the
    --                 add-on is inert / enabled for everyone) so you are never
    --                 unexpectedly locked out before you configure names.
    --   "on"        — force OPEN for everyone (same as an empty allowlist).
    --   "off"       — global kill-switch: DISABLE the add-on for everyone
    --                 (locked "[BETA TEST IN PROGRESS]" experience). Use this to
    --                 pull the whole add-on in a hotfix. This is a deliberate
    --                 choice, distinct from the "empty = open" default.
    --
    -- A malformed/absent `addon` block FAILS OPEN (with a diagnostic) — again,
    -- so a typo can never lock the author out.
    -- -------------------------------------------------------------------------
    -- CURRENT STATE: private beta. `mode = "allowlist"` grants ONLY the accounts
    -- listed below; every other account gets the locked
    -- "[BETA TEST IN PROGRESS]" experience and nothing else is initialized.
    --
    -- ⚠ NEVER empty `allow` while mode is "allowlist": an empty allowlist is
    -- deliberately treated as OPEN, so `mode = "allowlist"` + `allow = {}`
    -- ships the add-on to EVERYONE. To close the gate to all accounts set
    -- `mode = "off"` (the global kill-switch) — that is the only setting that
    -- locks everybody out, and it overrides this list without clearing it.
    addon = {
        mode  = "allowlist",
        allow = {
            -- Xbox gamertags: ESO decorates them with a leading "@", e.g.
            -- "@I Hitman I 47 I". Internal spaces are significant and are
            -- preserved by NormalizeAccount — keep them exactly as written.
            -- Matching ignores case and the leading @ is optional.
            "I Hitman I 47 I",
            "I Hitgirl I 5 I",
            "NooStepBr0",
            "swishertweet",
        },
    },

    -- -------------------------------------------------------------------------
    -- PER-FEATURE GATES. Each key must match a feature declared in the code
    -- registry (see AccountHold/src/Features.lua REGISTRY). Editing a name here
    -- does NOT make an unfinished feature work: a feature only appears / runs
    -- once its module is IMPLEMENTED in code (registry `available = true`). Until
    -- then these entries are inert placeholders you can pre-configure.
    --
    -- mode:
    --   "on"        — enabled for everyone allowed by the add-on gate.
    --   "off"       — disabled for everyone.
    --   "allowlist" — enabled only for accounts in `allow`. IMPORTANT: unlike
    --                 the whole-add-on gate above, an EMPTY per-feature `allow`
    --                 list DENIES EVERYONE (safe rollout — a half-finished
    --                 feature stays off until you explicitly opt testers in).
    --
    -- A non-empty allowlist FAILS CLOSED if the local identity can't be
    -- resolved. A malformed/absent entry falls back to the code registry
    -- default (off) with a concise diagnostic.
    --
    -- Users can only NARROW access in the in-game settings panel: an allowed
    -- feature is on by default and a user may switch it off; a user can never
    -- switch on a feature they are gated out of here.
    -- -------------------------------------------------------------------------
    features = {

        -- Epic 0002 — Armory build creator. Allowlisted to the author while the
        -- UI is validated on hardware; an EMPTY per-feature list denies
        -- everyone, so adding a handle here is what turns it on.
        buildCreator = {
            mode  = "allowlist",
            allow = {
                "I Hitman I 47 I",
                "NooStepBr0",
                "swishertweet",
            },
        },

        -- Epic 0008 — Quality-of-life conveniences on base-game screens.
        -- Allowlisted to the author while each action is validated on hardware.
        qol = {
            mode  = "allowlist",
            allow = {
                "I Hitman I 47 I",
                "NooStepBr0",
                "swishertweet",
            },
        },

        -- Epic 0005 — Priorities tracker. IMPLEMENTED and usable.
        --
        -- mode = "allowlist" + a NON-EMPTY list means only these accounts get
        -- it. Unlike the whole-add-on gate above, an EMPTY per-feature list
        -- DENIES EVERYONE — that asymmetry is deliberate (safe rollout), so
        -- adding a name here is what turns the feature on for that person.
        --
        -- To give a tester this feature: add their handle below.
        -- To take it away: remove the line, or set mode = "off".
        priorities = {
            mode  = "allowlist",
            allow = {
                "I Hitman I 47 I",
                "NooStepBr0",
                "swishertweet",
            },
        },

        -- Epic 0003 — Guild store indexer. Not implemented yet; stays off.
        guildStoreIndexer = {            mode  = "allowlist",
            allow = {
                -- "@noobuddy",
            },
        },

        -- Epic 0004 — Tip menu. Deferred (ToS/API spike). Kept explicitly off.
        tipMenu = {
            mode  = "off",
            allow = {},
        },
    },
}
