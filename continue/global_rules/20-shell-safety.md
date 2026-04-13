---
name: Shell safety
---

- Never run destructive shell commands.
- Never run rm, rm -rf, git reset --hard, git clean, sudo, reboot, shutdown, or poweroff commands.
- Never run package installation commands, database migration commands, deployment commands, remote shell commands, or destructive Docker commands unless explicitly requested.
- Prefer read-only shell commands first.
- When suggesting a shell command, use the safest minimal command.
- Ask before running commands that modify git state or the filesystem outside the current repository.
- Prefer editing files directly over shell-based file mutation when both would achieve the same result.
