---
name: channel-scout-scan
description: "[Internal] Scans competitor feeds and web to map each channel. Reads search_parameters from founder-profile.md."
version: 1.0.0
---

# Channel Scout — SCAN

## Purpose

Execute the research plan from `founder-profile.md`. Map the field. Write one `channel-intel/[channel].md` file per relevant channel.

## Step 0: Validate inputs

Read `founder-profile.md`. Confirm `## Search Parameters` section exists and `search_parameters.primary_keywords` is not empty. If validation fails, print: "founder-profile.md is missing the Search Parameters section. Please re-run /channel-scout to complete onboarding." and stop.

Read `watchlist.md`. Confirm at least one entry exists.

## Step 1: Read the research plan

From `founder-profile.md`, extract ONLY the `## Search Parameters` YAML block:
- `primary_keywords`
- `niche_modifiers`
- `icp_descriptors`
- `channel_queries` (per platform)
- `competitor_feeds`
- `lookalike_search_queries`

Also note `hours_per_week` from `## Outcome` — channels requiring more hours than this will be flagged.

## Step 2: Fetch competitor feeds

For each entry in `competitor_feeds` from search_parameters:

**Substack:** Fetch `[substack_rss]` if not null. Read the 5 most recent items. For each: title, published date, estimated word count. Note the hook structure of each title (question / list / statement / story). Do NOT read full post body — titles and descriptions only.

**Reddit:** Fetch `[reddit_handle].json?limit=10` if not null (e.g., `reddit.com/u/founder.json`). Read top 10 posts by upvotes. Note: title, subreddit, upvote count, comment count.

**YouTube:** Fetch YouTube RSS for the channel if not null. Read 5 most recent video titles and view counts.

**Token discipline:** Never read more than 300 words of body text from any single post. Extract structure, not content.

## Step 3: Run channel queries

For each `channel_queries` entry in search_parameters, run a web search. Extract:
- Top 5 creators/publications in this niche on this platform
- Their approximate follower/subscriber counts
- Their posting frequency
- What topics dominate

## Step 4: Find lookalikes

For each `lookalike_search_queries` entry, run a web search. Find 3-5 creators the founder didn't name who are succeeding in the same niche. Add them to `watchlist.md` with `type: lookalike`.

## Step 5: For each channel — teardown and analysis

For each platform where you found active content (from Steps 2-3), write a `channel-intel/[platform].md` file using `channel-intel.schema.md` as the structure.

Fill in:
- **Top Performers:** 3-5 posts with structure description (not full text), engagement metric, what made it work
- **Winning Template:** the repeatable hook/body/format pattern
- **Gap Analysis:** what's missing for this founder's specific niche
- **Saturation Score:** 1-5 with justification
- **Fit Signal:** is the founder's ICP active here? (subreddits found, niche newsletter sizes, etc.)

## Step 6: Update watchlist.md

Add lookalikes found in Step 4. Update `last_fetched` to today for all entries you fetched.

## Step 7: Update .state

Set `scan_complete: true`.

## Step 8: Hand off

Print: "Scan complete. Found [N] channels worth analyzing. Moving to channel prediction."

The orchestrator routes to PREDICT automatically.
