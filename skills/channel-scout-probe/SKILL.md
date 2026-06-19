---
name: channel-scout-probe
description: "[Internal] Drafts test posts in founder's voice, sets cadence and kill criteria. Writes test-plan.md."
version: 1.0.0
---

# Channel Scout — PROBE

## Purpose

Draft the first real posts in the founder's voice. Set cadence and kill criteria. End the strategy session.

## Step 0: Validate inputs

Confirm `prediction.md` has `## Top 2 Channels` with Primary and Secondary named. Confirm `channel-intel/` has files for both channels. Stop and explain if missing.

## Step 1: Read context

From `prediction.md`:
- Top 2 channel names
- Reasoning for each (voice fit note, gap analysis note)

From `channel-intel/[primary].md` and `channel-intel/[secondary].md`:
- Winning template (hook pattern, body structure, length, format)
- Cadence of top performers

From `founder-profile.md`:
- Founder's own writing (standout posts they pasted in onboarding)
- ICP description and `their_words`
- Outcome goal

## Step 2: Draft 2 test posts per channel

For each of the 2 top channels, write 2 complete native posts. Rules:
- Match the winning template structure exactly (hook style, length, format)
- Use the founder's voice — if they have pasted examples, mirror their sentence length and tone, not a polished AI tone
- Use ICP vocabulary from `their_words` in the content
- Each post must address the founder's core angle (what they build, who it's for)
- Each post must be different in hook style (e.g., one question hook, one bold statement)

Label clearly:
```
### [Channel] — Post 1 (question hook)
[full post text]

### [Channel] — Post 2 (statement hook)
[full post text]
```

## Step 3: Set cadence

For each channel, based on top performers' frequency from channel intel:
- Posts per week (realistic minimum to get signal)
- Best days/times (from channel intel observations)
- Format notes (thread vs single post, video length, etc.)

## Step 4: Set kill criteria

For each channel, set specific numbers:

> "If [metric] stays below [number] after [N] posts, stop this channel."

Base the metric and threshold on the channel's normal engagement range from the channel intel (what did LOW performers get vs. HIGH performers). Set the kill threshold at 30% of what an average post gets on this channel.

Example:
> "LinkedIn: if average impressions per post stay below 180 after 7 posts → stop. (Average on this channel is ~600; 30% = 180.)"

## Step 5: Set success signal

For each channel, define what "it's working" looks like at 7 days (positive wind tunnel indicators showing up as real engagement).

## Step 6: Write test-plan.md

Use `test-plan.schema.md` as structure. Include all 4 draft posts, cadence, kill criteria, and success signals for both channels.

Leave `## Coaching Mode` section as "TBD — set in next step."

## Step 6b: Write initial scorecard.md

Write a minimal `scorecard.md` now so the orchestrator can display the strategy summary without errors (the orchestrator reads scorecard.md in its "all done" state):

```markdown
---
schema: scorecard/v1
generated: [today's date]
---

## Header
- Company: [company name from .state]
- Test started: [today's date]
- Day: 0 (not yet started)
- Channels: [Primary channel] · [Secondary channel]

## Metrics Table
| date | channel | metric | value | delta | trend |
|------|---------|--------|-------|-------|-------|

## Kill Signal
None

## Coaching Mode
Mode: TBD
Last run: never
Pause until: null

## Weekly Synthesis Reference
- day-7-call.md: pending
- day-14-call.md: pending
```

## Step 7: Update .state

Set `probe_complete: true`. Also update `coach_mode` after the automation choice in Step 9 is made.

## Step 8: Offer coaching setup

Print:
```
Your strategy is ready.

  Primary channel:   [channel name]
  Secondary channel: [channel name]
  Test posts:        ~/channel-scout/[company]/test-plan.md

Post the first round, then come back. Daily coaching will track what's working.

─────────────────────────────────────
How should daily coaching work?

  [1] Automatic  — runs at a set time daily (launchd on Mac, cron on Linux)
  [2] On open    — runs every time you open Claude Code
  [3] Manual     — you run /channel-scout coach yourself

If your laptop is off at run time, Automatic mode fires the moment you open it.
```

Wait for their choice. Route to the automation setup steps below.

## Step 9: Automation setup (based on choice)

### If [1] Automatic:

Ask: "What time should it run? (default: 8:00 AM)"

Read company slug and project dir from `.state`:
```bash
CLAUDE_PATH=$(which claude)
COMPANY_SLUG="[company slug from .state]"
PROJECT_DIR="$HOME/channel-scout/$COMPANY_SLUG"
HOUR=[extracted from their answer, default 8]
MINUTE=0
```

**On macOS** — detect with `uname -s`:

Write `~/Library/LaunchAgents/com.channelscout.$COMPANY_SLUG.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.channelscout.[COMPANY_SLUG]</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>-c</string>
    <string>cd [PROJECT_DIR] && [CLAUDE_PATH] -p "/channel-scout coach"</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>[HOUR]</integer>
    <key>Minute</key>
    <integer>[MINUTE]</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>[PROJECT_DIR]/daily-log/launchd.log</string>
  <key>StandardErrorPath</key>
  <string>[PROJECT_DIR]/daily-log/launchd-err.log</string>
</dict>
</plist>
```

Tell the founder: "I'm about to register a daily task on your Mac. Claude Code will ask you to approve one bash command. Click Allow."

Run: `launchctl load ~/Library/LaunchAgents/com.channelscout.$COMPANY_SLUG.plist`

**On Linux** — detect with `uname -s`:

Run: `(crontab -l 2>/dev/null; echo "$MINUTE $HOUR * * * cd $PROJECT_DIR && $CLAUDE_PATH -p \"/channel-scout coach\"") | crontab -`

Confirm registration. Update `test-plan.md` `## Coaching Mode` with: `automatic — [time]`. Update `scorecard.md` `## Coaching Mode` section: `Mode: automatic`. Update `.state` with `coach_mode: automatic`.

Print:
```
Coach registered. Runs daily at [time].
If your laptop is asleep, it fires the moment you open it.

To disable: launchctl unload ~/Library/LaunchAgents/com.channelscout.[company].plist
(This command is also on your dashboard.)
```

### If [2] On open:

Add a SessionStart hook to `~/.claude/settings.json`:

Read the current `~/.claude/settings.json`. Merge the hook into the existing `"hooks"` object — do not overwrite other hooks already present. Add under `"hooks"`:
```json
"SessionStart": [
  {
    "matcher": "",
    "hooks": [
      {
        "type": "command",
        "command": "bash -c 'PAUSE=$(grep \"pause_until:\" ~/channel-scout/[COMPANY_SLUG]/.state | awk \"{print \\$2}\"); TODAY=$(date +%Y-%m-%d); if [ \"$PAUSE\" = \"null\" ] || [ \"$TODAY\" > \"$PAUSE\" ]; then cd ~/channel-scout/[COMPANY_SLUG] && claude -p \"/channel-scout coach\"; fi'"
      }
    ]
  }
]
```

Update `test-plan.md` `## Coaching Mode` with: `on-open`. Update `scorecard.md` `## Coaching Mode` section: `Mode: on-open`. Update `.state` with `coach_mode: on-open`.

Print:
```
Coach set to on-open mode.
Every time you open Claude Code, it runs your daily check automatically.

To skip a day: type "skip today" at the post-run prompt.
To pause: type "pause N days".
```

### If [3] Manual:

Update `test-plan.md` `## Coaching Mode` with: `manual`. Update `scorecard.md` `## Coaching Mode` section: `Mode: manual`. Update `.state` with `coach_mode: manual`.

Print:
```
Manual mode. Run /channel-scout coach whenever you're ready for your daily check.
```

## Step 10: Open the dashboard

Run: `open ~/channel-scout/[company]/dashboard.html` (macOS) or `xdg-open ~/channel-scout/[company]/dashboard.html` (Linux)

If no `dashboard.html` exists yet, print: "Dashboard will be ready after your first coach run."
