# Validation Rules

All channel-scout skills run this validation before any other step. If any check fails, print the error message and stop — never proceed with broken inputs.

## Required checks per skill

### SCAN
- [ ] `~/channel-scout/*/founder-profile.md` exists
- [ ] Contains `## Search Parameters` section
- [ ] `search_parameters.primary_keywords` is a non-empty list
- [ ] `~/channel-scout/*/watchlist.md` exists and has at least one entry

Error message: "founder-profile.md is missing the Search Parameters section. Re-run /channel-scout to complete onboarding."

### PREDICT
- [ ] `founder-profile.md` has `## ICP`, `## Outcome`, `## Search Parameters`
- [ ] `channel-intel/` directory has at least one `.md` file

Error message: "channel-intel/ is empty. Re-run /channel-scout to complete the scan."

### PROBE
- [ ] `prediction.md` exists
- [ ] Contains `## Top 2 Channels` with both Primary and Secondary named (not empty)
- [ ] `channel-intel/` has files for both named channels

Error message: "prediction.md is incomplete. Re-run /channel-scout to re-run the prediction."

### COACH
- [ ] `test-plan.md` exists
- [ ] `scorecard.md` exists (create it from schema template if missing — first coach run)
- [ ] `.state` exists
- [ ] `.claude/settings.json` exists in project directory

Error message (if test-plan missing): "test-plan.md not found. Complete the full strategy session first: /channel-scout"
