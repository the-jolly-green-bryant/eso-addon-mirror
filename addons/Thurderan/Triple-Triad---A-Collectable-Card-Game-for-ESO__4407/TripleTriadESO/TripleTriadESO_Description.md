# Triple Triad ESO

**A fully playable card game addon inspired by Final Fantasy's Triple Triad, built entirely within ESO.**

Challenge any friendly NPC in Tamriel to a strategic card battle on a 3×3 grid. Collect 57 unique cards featuring creatures from across the Elder Scrolls, build your deck, and climb the ranks against increasingly difficult opponents with advanced rule sets.

---

## How It Works

Target any friendly NPC in the world and press the keybind assigned from the keybinds menu. A game board opens and you're dealt 5 cards from your deck. Take turns placing cards on the grid — when your card's edge value is higher than an adjacent opponent's edge, you capture it. Control the most cards when the board is full and you win.

Each card has four edge values (Top, Right, Bottom, Left) ranging from 1–10, a star rating indicating overall power, and some carry elemental affinities that matter at higher ranks.

## Features

- **57 collectible cards** with unique ESO creature icons, stats, star ratings, and elemental types
- **5 NPC ranks** with scaling difficulty — higher-rank NPCs use stronger decks and unlock advanced rules
- **3 special rules** that unlock as you face tougher opponents:
  - **Same** (Rank 3+) — Capture cards by matching edge values exactly
  - **Plus** (Rank 4+) — Capture cards when edge sums are equal
  - **Elemental** (Rank 5+) — Board cells have random elements that boost or weaken card edges
- **Card collection window** — Browse your collected cards with tooltips, star ratings, and duplicate counts
- **Deck builder** — Choose which 5 cards to bring into battle from your collection
- **Statistics tracker** — Win/loss/draw records tracked per NPC
- **Cooldown system** — 3 immediate rematches per NPC, then a 5-minute cooldown to encourage variety
- **Comprehensive rules window** — In-game "How to Play" guide accessible from the [?] button or `/tt rules`
- **Card rewards** — Win a random card from the NPC's hand when you win a match
- **Keybindings** — Bindable keys for Challenge NPC, Open Collection, and Open Deck Builder
- **Chat toggle** — Use `/tt quiet` to suppress chat notifications

## Commands

- `/tt` — Open your card collection
- `/tt play` — Challenge the targeted NPC
- `/tt deck` — Open the Deck Builder
- `/tt stats` — View your win/loss statistics
- `/tt rules` — Open the rules/how-to-play guide
- `/tt quiet` — Toggle chat messages on/off
- `/tt help` — List all commands
- `/tt test` — Start a test match (optionally `/tt test 3` for a specific rank 1–5)

## Installation

Drop the `TripleTriadESO` folder into your `AddOns` directory and enable it in the addon menu. You start with 5 basic cards — win matches to grow your collection!

## Notes

- Works with any friendly, non-hostile NPC — just target them and play
- Card data and win/loss stats are saved per account
- No library dependencies
