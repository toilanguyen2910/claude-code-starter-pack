# Contributing

Thanks for your interest in contributing! This project is small and
intentionally simple — contributions that keep that spirit are very welcome.

## What we're looking for

- **New skills** that follow the same style: short, grounded in real repo
  state, no invented output. Each `SKILL.md` should be under 60 lines.
- **Bug fixes** for the setup script, hooks, or tests.
- **Documentation improvements** — typos, clearer examples, better
  getting-started instructions.
- **Windows compatibility** improvements for Git Bash / WSL.

## How to contribute

1. **Fork** this repository.
2. **Create a branch** for your change:
   ```bash
   git checkout -b feat/my-new-skill
   ```
3. **Make your changes.** Follow existing code style.
4. **Run the tests** to make sure nothing is broken:
   ```bash
   # Linux/macOS/Git Bash
   ./tests/run.sh

   # Windows PowerShell
   powershell -ExecutionPolicy Bypass -File tests/run_windows.ps1
   ```
5. **Commit** using [Conventional Commits](https://www.conventionalcommits.org/):
   ```bash
   git commit -m "feat(skills): add deploy-checker skill"
   ```
6. **Open a Pull Request** with a clear description of what and why.

## Adding a new skill

1. Create `skills/your-skill-name/SKILL.md`.
2. Follow the format documented in [`docs/writing-skills.md`](docs/writing-skills.md).
3. Make sure the `name` in frontmatter matches the directory name.
4. Add the skill name to the table in `README.md`.
5. Run tests — test 1 (frontmatter) and test 8 (README consistency) should
   both pass with your new skill.

## Code style

- Shell scripts: pass `shellcheck -S warning`.
- Markdown: one sentence per line where practical.
- Keep things simple — no build steps, no dependencies beyond bash/python/jq.

## What we won't merge

- Skills that invent output instead of reading the actual project state.
- Changes that add mandatory dependencies.
- PRs without a clear description of the change.

## License

By contributing, you agree that your contributions will be licensed under the
[MIT License](LICENSE).
