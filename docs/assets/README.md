# docs/assets — images & screenshots

This folder holds images referenced by the docs (screenshots, GIFs, diagrams). **It ships empty of
binaries** — the kit author can't capture screenshots of *your* Claude Code session, so the docs use
clearly-marked placeholders instead.

## How to add a real screenshot

The docs contain HTML-comment placeholders like:

```html
<!-- SCREENSHOT: terminal showing `/skills` listing the installed skills after running install.sh.
     Save as docs/assets/skills-list.png and reference it here. -->
```

To fill one in:

1. Take the screenshot (or record a short GIF) of the described moment.
2. Save it here with the filename the placeholder names, e.g. `docs/assets/skills-list.png`.
3. Replace the placeholder comment with a real image tag:
   ```markdown
   ![/skills listing after install](assets/skills-list.png)
   ```
   (Adjust the relative path: from `START-HERE.md` at the repo root it's `docs/assets/...`; from a file
   inside `docs/` it's `assets/...`.)

## Current placeholder slots

| File referencing it | Suggested filename | Shows |
|---|---|---|
| `START-HERE.md` | `skills-list.png` | `/skills` output after install |
| `README.md` | `flow-diagram.png` *(optional)* | the align→dispatch→review flow as a real diagram |

## Conventions
- Prefer PNG for stills, GIF for short flows. Keep files reasonably small (< ~1 MB) so the repo stays light.
- Use descriptive, kebab-case filenames.
- Only commit images you have the right to share (your own screenshots are fine).
