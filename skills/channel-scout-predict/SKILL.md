---
name: channel-scout-predict
description: "[Internal] Ranks channels via voice fit + wind tunnel personas + hours weighting. Writes prediction.md."
version: 1.0.0
---

# Channel Scout — PREDICT

## Purpose

Rank every scanned channel. Pick the top 2. Write the reasoning. End session 1.

## Step 0: Validate inputs

Confirm `founder-profile.md` has `## Search Parameters`, `## ICP`, `## Outcome`, and `## Current Channels` sections. Confirm `channel-intel/` directory has at least one file. If any are missing, print what's missing and stop.

## Step 1: Read context

From `founder-profile.md`:
- Founder's existing content: the 2-3 standout posts they pasted during onboarding (stored in `## Current Channels` notes or the onboard notes)
- `hours_per_week` from `## Outcome`
- `icp_descriptors` from `## Search Parameters`

From each `channel-intel/[platform].md`:
- Winning template
- Saturation score
- Gap analysis
- Fit signal

## Step 2: Voice fit scoring (per channel)

For each channel with a `channel-intel/` file:

Compare the founder's existing content style against the winning template for that channel. Reason explicitly:

> "The founder's writing is [characterize: length, tone, hook style, structure]. The winning template on [channel] is [characterize]. The delta is [large/medium/small] because [specific reason]. Voice fit score: [1-5] where 5 = their natural style already matches, 1 = significant adaptation required."

Score each channel 1-5 for voice fit.

## Step 3: Wind tunnel (top 3 candidate channels only)

For the top 3 channels by voice fit score, build 3 synthetic personas. **Personas are NOT invented.** Each persona is derived from the language in the top performer posts on that channel:

> "From the top posts on [channel], I can see the audience uses phrases like [list 3-5 verbatim phrases from real posts]. This persona is someone who [characterize based on their language]. They engage with content that [characterize based on what got the most engagement]."

Build 3 such personas per channel. Then run the founder's angle (their ICP description + stated outcome) past each:

> "If this founder posted [their core angle] on this channel, Persona 1 would [engage / scroll past / comment with pushback] because [reason derived from persona's demonstrated preferences]."

Score engagement signal: positive / mixed / weak.

## Step 4: Hours weighting

For each channel, estimate the real hours per week required to be competitive (based on top performers' cadence from channel intel). If this exceeds the founder's stated `hours_per_week`, reduce the channel's total score by 1 point.

## Step 5: Rank and select top 2

Compute total score:
`total = voice_fit + audience_match (fit signal score 1-5) + saturation_gap (inverse of saturation 1-5) - hours_penalty`

Rank all channels. Select top 2. If there's a tie, prefer the channel with higher fit signal.

## Step 6: Write prediction.md

Use `prediction.schema.md` as structure. Include:
- Full rankings table
- Top 2 channels with detailed reasoning
- Wind tunnel results for each top channel
- Initial kill criteria (to be refined in PROBE)

## Step 7: Update .state

Set `predict_complete: true`.

## Step 8: Hand off

Print the prediction summary:
```
Channel prediction complete.

  Primary:   [channel] (score: N/15)
  Secondary: [channel] (score: N/15)

  Why [primary]: [one sentence from reasoning]
  Why [secondary]: [one sentence from reasoning]

Writing your test posts and setting kill criteria next.
```
