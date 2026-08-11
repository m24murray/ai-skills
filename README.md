# AI Skills

Small repository of reusable GitHub Copilot skills.

## Install

From this folder, run:

```bash
./install-skills.sh
```

The script copies local `skills*` directories into:

`~/.copilot/skills`

This repository is the shared source of truth for the skills.
The installed runtime copy lives in `~/.copilot/skills`, and that is the version Copilot will actually use.

If you pull changes to this repository or update a skill locally, rerun:

```bash
./install-skills.sh
```

so your installed copy in `~/.copilot/skills` stays in sync.

## Verify

```bash
ls ~/.copilot/skills
```

In Copilot Chat, prompt:

`what skills do you have access to`

You should see your installed skills listed.

## How To Run Skills

Once the skills are installed into `~/.copilot/skills`, you can invoke them directly from Copilot Chat or Copilot CLI.

## Local Code Review Skill

Use the local code review skill when you want a repeatable static review of the current branch against the repository base branch without manually running git diff commands or test suites.

### Run It

If you are already in the app directory you want reviewed, run this command in the Copilot Chat window or Copilot CLI:

```text
/local-code-review
```

If you want the skill to be more precise and resolve the repository path more quickly, provide the app name explicitly:

```text
/local-code-review web-frontend
```

The skill will:

- resolve the repository path
- run the review context collection script
- generate a local review report under `code_reviews/` in the target repository

### Optional VS Code Setting

If you use Copilot Chat in VS Code and do not want to approve the review helper script every time, add this to your VS Code settings:

```json
"chat.tools.terminal.autoApprove": {
	"/collect-review-context\\.sh/": true
}
```

This allows Copilot Chat to run the local code review helper script without prompting for permission each time.
