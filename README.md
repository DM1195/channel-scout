# Channel Scout

Find your best distribution channel as a solo founder. One session, a real answer.

Built for Claude Code (Pro or Max subscription). No API key needed.

---

## What it does

You run one command. Claude interviews you (5 questions), scans your competitors, ranks every channel by voice fit and saturation gap, drafts your first test posts, and sets kill criteria. Same day, you have a strategy.

Then it coaches you daily — tracking what's working, flagging when to pivot.

## Install

```bash
git clone https://github.com/[your-handle]/channel-scout
cd channel-scout
./install.sh
```

That's it. The script copies skill files to `~/.claude/skills/`.

## Run

In Claude Code:

```
/channel-scout
```

That's the only command for the full strategy session. It resumes automatically if you stop mid-way.

For daily coaching (if you chose manual mode):

```
/channel-scout coach
```

## What gets created

All files live in `~/channel-scout/[your-company]/`:

```
founder-profile.md    your profile + search parameters
watchlist.md          competitors and creators being tracked
channel-intel/        teardown of each scanned channel
prediction.md         ranked channels with reasoning
test-plan.md          your test posts + kill criteria
scorecard.md          running daily metrics
daily-log/            one file per day
dashboard.html        opens automatically after each coach run
```

## How daily coaching works

At the end of your first session, you choose:

- **Automatic** — registers a launchd task (Mac) or crontab (Linux) that runs daily at your chosen time. If your laptop is asleep, fires when you open it.
- **On open** — runs every time you open Claude Code.
- **Manual** — you run `/channel-scout coach` yourself.

To pause: type `pause N days` at the post-run prompt.
To skip tomorrow: type `skip tomorrow`.

## A note on permissions

The coach skill runs headlessly (no one clicking Allow). During setup, Channel Scout writes a `.claude/settings.json` to your project directory that pre-approves the required tools: `Bash`, `WebFetch`, `WebSearch`, `Read`, `Write`, `Edit`.

This only affects runs from inside `~/channel-scout/[company]/` — not your other Claude Code projects.

---

Built with [Table For One](https://oneplease.substack.com) — solo founder distribution, figured out.
