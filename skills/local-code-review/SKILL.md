---
name: local-code-review
description: Perform a local static code review of the current branch against origin/main or origin/master, apply CODE_REVIEW_LEARNINGS, and save the report to code_reviews/. Use for branch reviews, pre-PR reviews, and quick static diff reviews.
argument-hint: Optional app name (e.g. lookup-pricing)
---

# Local code review

Use this skill to review the current git branch against the repository default branch without running builds or tests.

## When to use

- Review a feature branch before opening a pull request.
- Produce a local review report for a ticket or change set.
- Run a quick static diff review when command budget should stay low.

## Constraints

- Execute only one terminal command: the helper script. No other terminal commands may be run.
- After the script runs, always read `<absolute-path>/code_reviews/context/latest.json` using the Read file tool — regardless of whether the terminal returned output. "Failed to retrieve command output" does not mean the script failed; the file will be there.
- Only ask the user to paste the file manually if the Read file tool returns a file-not-found error.
- Do not fall back to individual git commands under any circumstances.
- Do not read individual source files. The unified diff in the JSON context file is sufficient context for the review.
- Do not run Maven, Gradle, npm, Node, test suites, or build commands.
- Do not run git log, git show, cat, or any other command after the script completes.
- Do not fall back to individual git commands under any circumstances.

## Inputs

- Current branch: treat the checked-out branch as the feature branch.
- Optional user input: app name, ticket slug, short description, or review focus.

### Repository selection source of truth

- Determine the target repository from only:
   - Explicit user-provided app name/path, or
   - Terminal working directory (CWD) when no app name is provided.
- Do not infer the target repository from the active editor file path, open tabs, or recent file context.
- If terminal CWD is not a git repository and no app name was provided, ask for app name as defined below.

## Repository lookup

If the user provides an app name, resolve it to an absolute path by checking these directories in order:

1. `~/hmpo/frontend/<name>`
2. `~/hmpo/backend/<name>`
3. `~/hmpo/<name>`
4. `~/<name>`

If a match is found, use that as the absolute path without asking the user to confirm.
If no match is found, ask: "I couldn't locate `<name>` in the usual directories — what is the absolute path?"

If the user provides no app name, check whether the terminal working directory is a git repository by looking for a `.git` folder at its root. If it is, use it as the target. If it is not a git repository, do not proceed — ask: "Which app would you like to review? I'll look in `~/hmpo/frontend` and `~/hmpo/backend` — just give me the app name."

## Procedure

1. Determine the absolute path to the repository being reviewed using the **Repository lookup** rules above.
2. Run `bash $HOME/.copilot/skills/local-code-review/scripts/collect-review-context.sh <absolute-path>`. Wait for the command to fully complete. Check for a line beginning with `BRANCH_GUARD_FAILED:` — if found, stop immediately and respond only with: "You are on `main` or `master`. Please check out the feature branch you want reviewed and run `/local-code-review` again." Do not proceed.
3. **Immediately read `<absolute-path>/code_reviews/context/latest.json` using the Read file tool.** Do this unconditionally — whether the terminal output was clean, truncated, or missing entirely. The script always writes this file on success. Do not ask the user to paste anything before attempting this read. Only ask if the Read itself returns a file-not-found error.
4. Check whether `<absolute-path>/.gitignore` exists. If it does, check whether `code_reviews/` is already listed in it. If it is not, append `code_reviews/` to the file on a new line. Do not modify the file in any other way. If no `.gitignore` exists, skip this step.
5. **Do not run any further terminal commands.** Treat the JSON file as the complete review context. Do not read individual source files or run git log, git show, cat, or any other repository-inspection commands. You may still use file tools needed to check or update `.gitignore` and write the final review report.
6. Use the following fields from the JSON for the review:
   - `branch`, `baseRef`, `mergeBase`, `headCommit` — for report metadata
   - `changedFiles`, `diffStat`, `workingTreeStatus`, `untrackedFiles` — for the files reviewed section
   - `committedUnifiedDiff`, `workingTreeUnifiedDiff`, `untrackedDiff` — for supplementary detail
   - Lockfiles will be intentionally excluded from the general diff collection to reduce noise. Do not raise findings based only on lockfile absence.
   - `packageLockResolvedEntries` contains only added or removed `"resolved"` lines from `package-lock.json`. Use this field only for lockfile-specific registry-policy checks from `CODE_REVIEW_LEARNINGS`; otherwise continue to ignore lockfile noise.

   **Choose the right diff source based on size:**

   - **`diffTruncated` is `false`** — use `unifiedDiff` as the primary review source. This is the normal path for small-to-medium PRs.

    - **`diffTruncated` is `true`** — a monolithic diff stream exceeded 400,000 bytes (about 400 KB) and was cut off. Switch to a file-by-file review using `fileDiffs`:
       1. `fileDiffs` is an array of `{ filename, bytes, truncated, diff }` entries — one per changed file, each capped at 60,000 bytes (about 60 KB). Review them in sequence, producing findings as you go.
       2. If any entry has `truncated: true`, note in the report that the diff for that specific file was partially truncated.
       3. `excludedFromFileDiffs` lists any files that were dropped because the 500,000-byte total file-by-file budget (about 500 KB) was exhausted. For those files, fall back to whatever portion of `unifiedDiff` covers them, and note in the report that those files received only a partial review.
          4. Add a visible banner at the top of the Findings section:
               - Coverage complete: "⚠️ Large-diff mode used; reviewed file-by-file with complete coverage."
               - Coverage partial: "⚠️ Large-diff mode used; partial coverage because some file diffs were truncated or excluded."
7. Apply the project-specific rules in [CODE_REVIEW_LEARNINGS](./references/CODE_REVIEW_LEARNINGS.md).
8. Apply **verdict guardrails** before deciding status:
    - Evaluate coverage first when `diffTruncated` is `true`:
       - Coverage is **complete** when all changed files appear in `fileDiffs`, no file entry has `truncated: true`, and `excludedFromFileDiffs` is empty.
       - Coverage is **partial** when any file entry has `truncated: true` or `excludedFromFileDiffs` is non-empty.
    - Use verdicts consistently:
       - **Green**: no high/medium findings and coverage is complete (large-diff warning banner still required).
       - **Amber**: coverage is partial, uncertainty remains material, or medium-severity risk exists.
       - **Red**: confirmed high-severity defect(s).
    - Do **not** use Amber only because `diffTruncated` is true when coverage is complete.
9. Write the report using [report-template](./assets/report-template.md), and the report template formatting is mandatory for every review output.
10. Name the report file `<branch-name>-<YYYY-MM-DD>.md`, using a filesystem-safe version of the branch name. If a file with that name already exists, overwrite it entirely — do not append to it.