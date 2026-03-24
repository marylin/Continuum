# Promo Content: /do and /catalog Skills

> Created by Muse (Content & Brand Lead) for MAR-8
> Date: 2026-03-22

---

## GIF Storyboard: /do (Smart Skill Router)

**Duration:** ~15 seconds
**Tool:** asciinema, vhs (charmbracelet), or screen recording → gifski
**Existing asset:** `docs/do skill sr.mp4` (convert to GIF with `ffmpeg -i "do skill sr.mp4" -vf "fps=12,scale=800:-1" do-demo.gif`)

### Script

1. **Frame 1 (0-2s):** Terminal open in a project directory. Type:
   ```
   /do optimize my landing page for conversions
   ```
2. **Frame 2 (3-7s):** Claude processes → shows match result:
   ```
   Best match: page-cro (gstack)
   "Conversion rate optimization for any marketing page"

   Use this skill? (yes / show alternatives / skip)
   ```
3. **Frame 3 (8-10s):** User types `yes` → skill invokes and starts working
4. **Frame 4 (11-15s):** Fade/cut with text overlay: **"80+ skills. One command."**

### Alt scenario (multiple matches):
```
/do help me write better emails
```
Shows the multi-match picker with email-sequence, cold-email, and copy-editing as options.

---

## GIF Storyboard: /catalog (Skills Catalog Scanner)

**Duration:** ~12 seconds
**Tool:** Same as above

### Script

1. **Frame 1 (0-2s):** Terminal. Type:
   ```
   /catalog
   ```
2. **Frame 2 (3-6s):** Claude scans plugins, shows progress:
   ```
   Scanning installed skills...
   - Session skills: 47
   - User commands: 10
   - Plugin commands: 23
   ```
3. **Frame 3 (7-9s):** Category breakdown appears:
   ```
   Skills catalog updated: 62 skills across 6 categories
   - Dev Workflow: 14
   - Project Management: 8
   - Quality & Testing: 9
   - UI/Design: 7
   - Marketing & Growth: 18
   - Infrastructure & Config: 6
   ```
4. **Frame 4 (10-12s):** Quick scroll of the generated `skills-reference.md` showing the "Most Used (30 days)" leaderboard table. Text overlay: **"All your skills. Organized."**

---

## Twitter Posts

### Post 1 — Launch announcement (English)

> I had 80+ Claude Code skills installed and couldn't find any of them.
>
> So I built /do — a smart skill router. Describe what you need in plain English, it finds the right skill.
>
> And /catalog to auto-organize everything into categories with usage tracking.
>
> Open source: github.com/marylin/whateverai-commands
>
> [attach: do-demo.gif]

### Post 2 — Spanish version

> Tenía 80+ skills de Claude Code instalados y no encontraba ninguno.
>
> Construí /do — un router inteligente. Describes lo que necesitas y encuentra el skill correcto.
>
> Y /catalog para auto-organizar todo en categorías con tracking de uso.
>
> Open source: github.com/marylin/whateverai-commands
>
> [attach: do-demo.gif]

### Post 3 — Thread follow-up (English)

> How it works:
>
> 1. Run /catalog → scans all plugins, categorizes 6 groups, tracks usage
> 2. Run /do "deploy my app" → matches to the best skill instantly
> 3. Learns from your usage → frequently-used skills rank higher
>
> No more scrolling through flat alphabetical lists.
>
> Part of whateverai-commands — 18 commands across 2 plugin packs for Claude Code.

### Post 4 — Build-in-public angle

> The problem with Claude Code plugins: great ecosystem, terrible discoverability.
>
> The /skills dialog is a flat list with no search, no categories, no descriptions.
>
> So I built the layer that should exist:
> → /catalog indexes everything
> → /do routes by intent
> → Usage tracking surfaces your favorites
>
> Shipping it today as MIT open source.

---

## Discord Announcement

### Channel: #announcements or #showcase

**Title:** New plugin: whateverai-commands — Smart skill routing for Claude Code

**Body:**

Hey everyone! Sharing something I built to solve a real pain point.

**The problem:** I had 80+ Claude Code skills installed across 10 plugins and couldn't find any of them. The `/skills` dialog is a flat alphabetical list — no search, no categories, no descriptions.

**The solution:** Two new commands that fix skill discoverability:

**`/catalog`** — Scans all your installed skills (session, user commands, plugins), deduplicates them, and generates a categorized reference file with 6 groups: Dev Workflow, Project Management, Quality & Testing, UI/Design, Marketing & Growth, and Infrastructure & Config. Includes a "Most Used (30 days)" leaderboard.

**`/do`** — Smart skill router. Just describe what you want to do in plain English:
```
/do optimize my landing page for conversions
→ Best match: page-cro (gstack) — "Conversion rate optimization"
```
It learns from your usage — frequently-used skills rank higher over time.

**Install:**
```
/plugin add github:marylin/whateverai-commands/whateverai-workflow-skills
```

Also includes 8 universal dev commands (build, debug, test, review, etc.) in a separate pack:
```
/plugin add github:marylin/whateverai-commands/whateverai-dev-skills
```

18 commands total, MIT licensed. Feedback welcome!

**Links:**
- GitHub: `github.com/marylin/whateverai-commands`
- Author: Marylin Alarcon (WhateverAI) — building from Medellin

[attach: do-demo.gif]
