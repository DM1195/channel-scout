---
schema: founder-profile/v1
---

# Founder Profile Schema

Required sections and fields. All skills that read this file validate these exist before proceeding.

## Identity
- `name:` string
- `linkedin_url:` string or "not provided"
- `linkedin_headline:` string or "not fetched"

## Company
- `name:` string  ← used to name the project folder
- `website:` string
- `description:` string  ← fetched from homepage, 1-2 sentences
- `stage:` one of: idea / pre-revenue / early-revenue / scaling
- `category:` string  ← derived from homepage text, e.g. "B2B SaaS invoicing"

## Current Channels
Freeform table. At minimum one row per channel the founder mentioned in Q3.
Format:
| platform | posts | followers | avg_reach | last_post |
|----------|-------|-----------|-----------|-----------|

## ICP
- `description:` string  ← founder's Q4 answer
- `their_words:` list of verbatim phrases from Q4 answer

## Outcome
- `goal:` string  ← specific metric from Q5
- `timeline:` string
- `hours_per_week:` integer

## Search Parameters
CRITICAL — SCAN reads ONLY this section. Never modify field names.

```yaml
search_parameters:
  primary_keywords: []      # list of strings
  niche_modifiers: []       # list of strings
  icp_descriptors: []       # list of strings
  channel_queries:
    linkedin: ""
    reddit: ""
    substack: ""
    youtube: ""
    twitter: ""
  competitor_feeds: []      # list of {name, website, substack_rss, reddit_handle, youtube_channel, twitter_handle}
  lookalike_search_queries: []  # list of strings
```
