---
schema: scorecard/v1
---

# Scorecard Schema

## Header
- Company: [name]
- Test started: [YYYY-MM-DD]
- Day: [N] of 7 (then ongoing)
- Channels: [list]

## Metrics Table
| date | channel | metric | value | delta | trend |
|------|---------|--------|-------|-------|-------|

One row per channel per day. `trend` is one of: ↑ ↗ → ↘ ↓

## Kill Signal
None | [channel]: triggered on [date] — [reason]

## Coaching Mode
Mode: automatic | on-open | manual
Last run: [YYYY-MM-DD HH:MM]
Pause until: null | [YYYY-MM-DD]

## Weekly Synthesis Reference
- day-7-call.md: [exists | pending]
- day-14-call.md: [exists | pending]
