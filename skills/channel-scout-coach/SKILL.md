---
name: channel-scout-coach
description: "Daily coaching run. Tracks progress, updates scorecard, opens dashboard. Run automatically or via /channel-scout coach."
version: 1.0.0
---

# Channel Scout — COACH

## Purpose

Run the daily check. Update the scorecard. Write the coaching note. Open the dashboard. Ask for feedback.

## Step 0: Check pause status and validate inputs

First, locate the project directory. Run:
```bash
find ~/channel-scout -name ".state" -maxdepth 2 2>/dev/null
```
If multiple found, use the most recently modified. If none found, print "No Channel Scout project found. Run /channel-scout to get started." and stop.

Read `.state`. Find `pause_until` field.

If `pause_until` is not null:
- Compare `pause_until` date to today's date (YYYY-MM-DD format)
- If today ≤ pause_until: print "Coaching paused until [date]. Run /channel-scout coach to resume early." and stop completely.
- If today > pause_until: set `pause_until: null` in `.state` and continue.

**If `scorecard.md` does not exist** (first coach run or missing):
Create a minimal `scorecard.md`:
```markdown
---
schema: scorecard/v1
---

## Header
- Company: [from .state company field]
- Test started: [today's date]
- Day: 1
- Channels: [read from test-plan.md if exists, else TBD]

## Metrics Table
| date | channel | metric | value | delta | trend |
|------|---------|--------|-------|-------|-------|

## Kill Signal
None

## Coaching Mode
Mode: [read from .state coach_mode field, or TBD if null]
Last run: [today]
Pause until: null

## Weekly Synthesis Reference
- day-7-call.md: pending
- day-14-call.md: pending
```

## Step 1: Build context stack

Read ONLY these files, in this order:

1. `scorecard.md` — full file (kept compact by schema)
2. `test-plan.md` — ONLY the `## Kill Criteria` and `## Success Signal` sections for each channel
3. `daily-log/[yesterday's date].md` — ONLY the `## Summary` and `## Founder Notes` sections. If yesterday's log doesn't exist (day 1), skip this read.
4. Most recent `day-N-call.md` (if any exist) — full file. Find with: `ls [project_dir]/day-*-call.md 2>/dev/null | sort -V | tail -1`

Do NOT read older daily logs. Do NOT re-read `founder-profile.md` or `channel-intel/` on daily runs.

Determine today's day number: count daily-log files that exist, then add 1.

## Step 2: Get today's stats

Print exactly:
```
Day [N] check. Paste your numbers (or type "skip today" / "pause N days"):

[Channel 1]: [metric name] ___  [metric name] ___
[Channel 2]: [metric name] ___  [metric name] ___
```

Populate channel names and metric names from `test-plan.md` kill criteria section.

**If they type "skip today":**
- Write a minimal daily log entry with `## Summary: Skipped.`
- Do not update scorecard metrics.
- Print "Skipped today. See you tomorrow." and stop.

**If they type "pause N days" BEFORE pasting stats:**
- Today is day 1 of the pause
- `pause_until` = today's date + (N-1) days
- Write to `.state`: `pause_until: [calculated date]`
- Print: "Paused. Next check on [date]." and stop.

**Otherwise:** parse the numbers they paste.

## Step 3: Fetch changed competitor feeds

Read `watchlist.md`. For each competitor entry:
- Read `last_fetched` field from the entry
- **If `last_fetched` equals today's date → skip entirely** (already fetched today)
- **If `last_fetched` is a prior date:**
  - Fetch the feed (Substack RSS, Reddit .json, YouTube RSS per the entry's channel fields)
  - Check if `lastBuildDate` (RSS feeds) or most recent post date (Reddit/YouTube) has changed since `last_fetched`
  - If **unchanged since last_fetched**: note "no new content" — do not read further
  - If **changed**: read titles and dates only (never post body text) — note creator handle + title/headline of new content
  - Update `last_fetched` to today in `watchlist.md`

Token discipline: never read post body text. Titles and dates only. Max 5 items per feed.

## Step 4: Write today's daily log

Write `daily-log/[YYYY-MM-DD].md`:

```markdown
---
date: [today]
day: [N]
---

## Summary
[one sentence: what happened today numerically]

## Metrics
| channel | metric | value | delta_from_baseline | trend |
|---------|--------|-------|---------------------|-------|
[rows from pasted stats]

## Competitor Activity
[list of changed feeds, or "No changes today."]

## Coaching Note
[written in Step 5]

## Founder Notes
[blank — filled in at Step 10 if they give feedback]
```

## Step 5: Generate coaching note

Reason over: today's metrics vs. kill criteria vs. success signal vs. what yesterday's notes said vs. any Founder Notes from yesterday.

Write 1-3 sentences. Be direct and specific. Examples of good coaching notes:
- "LinkedIn impressions up 40% — the question hook is outperforming the statement hook. Post another question hook this week before testing anything else."
- "Substack open rate dropped 8 points. Could be the subject line or the send time. Change only one variable next post."
- "You're at day 5 with no movement on Reddit. That's inside the kill window — we're not pulling the plug yet, but the next two posts need to perform."

Bad coaching notes (do not write these):
- "Keep going, you're making progress!"
- "Consider experimenting with different formats."

## Step 6: Check kill criteria

From `test-plan.md` kill criteria for each channel: has this channel hit its kill threshold?

- If NO kill triggered: `kill_status = "None"`, `kill_class = "kill-none"`
- If YES kill triggered: `kill_status = "[Channel]: kill criteria met on [date] — [metric] was [value] vs threshold [threshold]"`, `kill_class = "kill-triggered"`

If kill is triggered, append to coaching note: "**[Channel] has hit its kill threshold.** Run /channel-scout to review your prediction and pivot."

## Step 7: Update scorecard.md

Append a new row to the `## Metrics Table` for today. One row per channel:
`| [today] | [channel] | [metric] | [value] | [delta vs baseline] | [↑/↗/→/↘/↓] |`

Update `## Kill Signal` section with kill_status.
Update `Last run` date in `## Coaching Mode` to today.
Update `Pause until` field to current pause_until value from .state.

## Step 8: Render dashboard

Read `~/.claude/skills/channel-scout/templates/dashboard.html`. Substitute all `{{PLACEHOLDER}}` values:

| Placeholder | Value |
|---|---|
| `{{COMPANY_NAME}}` | company slug from `.state` |
| `{{DAY_NUMBER}}` | N from daily log |
| `{{CHANNELS_ACTIVE}}` | channel names from test-plan.md |
| `{{LAST_RUN}}` | today's date + time |
| `{{PAUSE_BANNER}}` | empty string if not paused; `<div class="pause-banner">Coaching paused until [date]. Type "pause N days" to extend or run /channel-scout coach to resume early.</div>` if paused |
| `{{SCORECARD_ROWS}}` | one `<tr>` per channel: `<tr><td>[channel]</td><td>[baseline]</td><td>[today]</td><td class="[trend-up/flat/down]">[arrow]</td><td>[kill threshold]</td></tr>` |
| `{{COACHING_NOTE}}` | the coaching note from Step 5 |
| `{{COMPETITOR_ACTIVITY}}` | from Step 3, or "No changes today." |
| `{{KILL_CLASS}}` | `kill-none` or `kill-triggered` |
| `{{KILL_STATUS}}` | from Step 6 |
| `{{COACH_MODE}}` | from scorecard.md Coaching Mode → Mode field |
| `{{DISABLE_INSTRUCTION}}` | If automatic mode: "To disable: `launchctl unload ~/Library/LaunchAgents/com.channelscout.[company].plist`" / If on-open: "To pause: type 'pause N days' at next check" / If manual: "Run /channel-scout coach when ready" |

Write the rendered HTML to `~/channel-scout/[company]/dashboard.html`.

Also write a plain-text version to `~/channel-scout/[company]/dashboard.md`:
```markdown
# Channel Scout — [company] — Day [N]

## Scorecard
[scorecard metrics table]

## Today's Note
[coaching note]

## Competitor Activity
[activity]
```

## Step 9: Open dashboard

**Check file exists before opening:**
```bash
if [ -f ~/channel-scout/[company]/dashboard.html ]; then
  # macOS:
  open ~/channel-scout/[company]/dashboard.html
  # Linux:
  # xdg-open ~/channel-scout/[company]/dashboard.html
else
  echo "Dashboard rendering failed — check Step 8 output."
fi
```

Detect OS with `uname -s`: use `open` on Darwin, `xdg-open` on Linux.

## Step 10: Post-run prompt

Print:
```
Today's check is complete. Anything to add?
(feedback [text] / skip tomorrow / pause N days / done)
```

Wait for response.

**If "feedback [text]":** append their text to `## Founder Notes` in today's daily log. Print "Got it — I'll factor that in tomorrow." Done.

**If "skip tomorrow":**
- `pause_until` = tomorrow's date
- Write to `.state`
- Print "Skipping tomorrow. Next check: [day after tomorrow]." Done.

**If "pause N days" AFTER run:**
- Tomorrow is day 1 of the pause
- `pause_until` = tomorrow + (N-1) days
- Write to `.state`
- Print "Paused. Next check: [date]." Done.

**If "done" or silence or anything else:** close. Done.

## Step 11: Weekly synthesis (every 7 days)

Check if today's day number (N) is a multiple of 7. Calculate: N mod 7 == 0.

If yes, write `day-[N]-call.md` in the project directory:

```markdown
# Week [N/7] Synthesis

## What worked
[specific posts, hooks, or channels that exceeded baseline — cite actual numbers from scorecard]

## What didn't
[specific posts or channels that underperformed, with the actual numbers]

## Prediction accuracy
Did the channel ranking hold? What surprised us?

## Revised strategy
Any channel swap? Any format change? Kill any channel?

## Next 7 days
Concrete focus: what to post, what to measure, what decision to make by day [N+7].
```

Update `scorecard.md` `## Weekly Synthesis Reference` section to mark this file as existing.

On future COACH runs (day N+1 onward), Step 1 reads this file as the context anchor. The `ls ... | sort -V | tail -1` command in Step 1 automatically picks up the latest synthesis file.
