---
schema: watchlist/v1
---

# Watchlist Schema

One entry per creator or competitor. Entries added by ONBOARD, expanded by SCAN.

## Entry Format

```yaml
- handle: "@name or company name"
  type: competitor | admired_creator | lookalike
  channels:
    substack_rss: "url or null"
    reddit_handle: "u/handle or null"
    youtube_channel: "@handle or null"
    twitter_handle: "@handle or null"
    linkedin_url: "url or null"
  last_fetched: "YYYY-MM-DD or null"
  notes: "one line about why they're on this list"
```
