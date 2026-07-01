# Security Policy

## Supported Versions

| Version | Supported          |
|---------|--------------------|
| latest  | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it
responsibly:

1. **Do NOT open a public issue.** Security issues must be reported privately.
2. **Email**: [jack.vhknguyen@gmail.com](mailto:jack.vhknguyen@gmail.com)
3. **Include**:
   - A description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

You should receive a response within **48 hours**. Once the issue is confirmed,
a fix will be prioritized and released as soon as possible.

## Scope

This policy applies to:
- All shell scripts (`setup.sh`, `protect-files.sh`, `tests/run.sh`)
- Hook logic that handles file paths and JSON input
- Any configuration files (`.claude/settings.json.example`)

## Out of Scope

- Claude Code itself (report to [Anthropic](https://www.anthropic.com))
- Third-party dependencies (`jq`, `shellcheck`, `python`)
