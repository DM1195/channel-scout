---
name: channel-scout-onboard
description: "[Internal] Interviews the founder, enriches with web data, creates project folder structure."
version: 1.0.0
---

# Channel Scout — ONBOARD

## Purpose

Collect founder context through 5 conversational questions, enrich answers with web fetches, create the project folder structure, and write `founder-profile.md` and `watchlist.md`.

**Do not rush. One question at a time. Wait for the full answer before continuing.**

## Step 1: Ask Q1 — Identity

Say exactly:
> "First question: what's your name? And if you have a LinkedIn URL, drop it here — I'll pull your headline automatically."

After they answer:
- Extract name
- If LinkedIn URL provided: fetch the page, extract headline and bio text (first 300 words of the About section). Store as `linkedin_headline` and `linkedin_bio_raw`.
- If no LinkedIn URL: set `linkedin_headline: "not provided"`, `linkedin_bio_raw: ""`

## Step 2: Ask Q2 — Company

Say exactly:
> "What are you building? Give me the company name and website URL."

After they answer:
- Extract company name (this becomes the folder name — sanitize to lowercase, hyphens only, e.g. "My Startup" → "my-startup")
- Fetch the website homepage
- Extract: product description (what it does, 1-2 sentences), any pricing/audience signals, the exact vocabulary used on the page (not paraphrased — copy the phrases)
- Store as: `website_description`, `homepage_raw_vocab` (key phrases copied verbatim, comma-separated)

**Create the project folder now:**

Run this bash command (substitute the actual company slug):

```bash
COMPANY_SLUG="[sanitized company name]"
PROJECT_DIR="$HOME/channel-scout/$COMPANY_SLUG"
mkdir -p "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR/channel-intel"
mkdir -p "$PROJECT_DIR/daily-log"

# Create .claude/settings.json for headless tool permissions
mkdir -p "$PROJECT_DIR/.claude"
cat > "$PROJECT_DIR/.claude/settings.json" << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(*)",
      "WebFetch(*)",
      "WebSearch(*)",
      "Read(*)",
      "Write(*)",
      "Edit(*)"
    ]
  }
}
EOF

# Write initial .state
cat > "$PROJECT_DIR/.state" << EOF
company: "$COMPANY_SLUG"
project_dir: "$PROJECT_DIR"
onboard_complete: false
scan_complete: false
predict_complete: false
probe_complete: false
coach_mode: null
pause_until: null
last_coach_run: null
EOF
```

Tell the founder: "Got it. I've set up your Channel Scout workspace at `~/channel-scout/[company]/`."

## Step 3: Ask Q3 — Current channels

Say exactly:
> "What have you published so far? Fill in what you have — skip anything you haven't tried:
>
> Instagram: posts ___ avg views ___ followers ___
> LinkedIn: posts ___ avg impressions ___ followers ___
> Substack: issues ___ subscribers ___ recent follower delta ___
> Reddit: posts ___ avg upvotes ___ communities active in ___
> YouTube: videos ___ avg views ___ subscribers ___
> Twitter/X: posts ___ avg impressions ___ followers ___
> Other: ___
>
> Rough numbers are fine."

After they answer: parse into the Current Channels table. Note which channels have any activity.

## Step 4: Ask Q4 — ICP

Say exactly:
> "Who are you trying to reach? Describe them — their role, what they're struggling with, what they read, who they follow."

After they answer:
- Store full answer as `icp_description`
- Extract verbatim phrases (the exact words they used to describe the ICP) as `their_words` list

## Step 5: Ask Q5 — Outcome

Say exactly:
> "Last one: what outcome do you actually want? Be specific — not 'grow my audience.' A real number, by when, and how many hours per week can you put into distribution?"

After they answer:
- Extract `goal` (the number + outcome), `timeline`, `hours_per_week`

## Step 6: Collect competitors and admired creators

Say:
> "One more thing before I dig in: drop any competitor URLs or creator profiles you've been watching. And 2-3 posts you've written or seen that you think actually worked — paste the URLs or the text."

After they answer:
- For each URL: attempt to resolve to a feed (Substack → append `/feed`, Reddit → append `.json`, YouTube → resolve to RSS via channel ID)
- Build initial `watchlist.md` entries

## Step 7: Run the translation layer

**This is the critical prompt engineering step. Do not skip it.**

You now have:
- Founder's own words (Q1-Q5 answers)
- Homepage raw vocabulary (fetched in Step 2)
- LinkedIn bio (fetched in Step 1, if available)
- Competitor page text (fetched in Step 6)

Reason explicitly through this before writing any files:

> "I need to derive the search parameters that SCAN will use. My task is to find the vocabulary gap between how the founder describes their product and how their ICP actually searches for it on each platform.
>
> Homepage says: [homepage_raw_vocab]
> ICP description: [icp_description]
> ICP's own words: [their_words]
> Competitor vocabulary: [from fetched competitor pages]
>
> Primary keywords: the 3-5 terms that appear in the homepage/competitor text AND match ICP language — not the founder's casual description.
>
> For each channel query, use platform-native search syntax:
> - Reddit: `subreddit:[most relevant sub] [keyword]`
> - LinkedIn: `[role keyword] [pain point keyword] [niche]`
> - Substack: `[category keyword] [audience descriptor] newsletter`
> - YouTube: `[pain point] [role] [solution category]`
>
> Competitor feed URLs: for each competitor in the watchlist, include the resolved RSS/JSON endpoint or null."

Write the result as the `## Search Parameters` YAML block in `founder-profile.md`. The field names MUST match `founder-profile.schema.md` exactly:
- `primary_keywords`
- `niche_modifiers`
- `icp_descriptors`
- `channel_queries` (with keys: linkedin, reddit, substack, youtube, twitter)
- `competitor_feeds` (list of objects with: name, website, substack_rss, reddit_handle, youtube_channel, twitter_handle)
- `lookalike_search_queries`

## Step 8: Write the output files

**Write `founder-profile.md`:**

Populate the template at `~/.claude/skills/channel-scout/templates/founder-profile.template.md` with all collected data including the `## Search Parameters` block from Step 7. Replace the placeholder `[Added by translation layer — see Task 5]` with the actual YAML block.

Save to `~/channel-scout/[company]/founder-profile.md`.

**Write `watchlist.md`:**

```markdown
---
schema: watchlist/v1
generated: [today's date]
---

# Watchlist

[one YAML entry per competitor/creator, following watchlist.schema.md format]
```

Each entry format (from watchlist.schema.md):
```yaml
- handle: "@name or company name"
  type: competitor | admired_creator | lookalike
  channels:
    substack_rss: "url or null"
    reddit_handle: "u/handle or null"
    youtube_channel: "@handle or null"
    twitter_handle: "@handle or null"
    linkedin_url: "url or null"
  last_fetched: null
  notes: "one line about why they're on this list"
```

**Update `.state`:**

Set `onboard_complete: true` in `~/channel-scout/[company]/.state`. All other flags remain as they were.

## Step 9: Hand off

Print:
> "Onboarding complete. I know who you are, who you're trying to reach, and what your competitors are doing.
>
> Starting the field scan now — this pulls competitor content and maps each channel. Takes about 3 minutes."

The orchestrator will pick up `scan_complete: false` and route to SCAN automatically. Do not invoke SCAN directly — return control to the orchestrator.
