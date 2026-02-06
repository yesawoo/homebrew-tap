# CLAUDE.md - homebrew-tap

Homebrew tap for kleo-receipts: `brew install yesawoo/tap/kleo-receipts`

## Repository Structure

```
Formula/
  kleo-receipts.rb    # Homebrew formula
```

This is the `yesawoo/homebrew-tap` repo. Users add it with `brew tap yesawoo/tap`.

## Updating the Formula After a Release

After a new version of kleo-receipts is published to PyPI:

```bash
# 1. From the kleo-receipts directory, get the new URL + sha256:
just bump-formula X.Y.Z

# 2. Update Formula/kleo-receipts.rb with the new url and sha256 values
# 3. Commit and push
git add Formula/kleo-receipts.rb
git commit -m "Update kleo-receipts to X.Y.Z"
git push origin main
```

Users then get the update via `brew upgrade kleo-receipts`.

## Formula Structure

Key sections in `Formula/kleo-receipts.rb`:
- **`url` + `sha256`** — points to the PyPI sdist tarball. Must be updated each release.
- **`depends_on`** — native build deps for Pillow, libusb, Python 3.12
- **`resource` blocks** — pinned Python dependencies (auto-generated, update if deps change)
- **`service do`** — Homebrew Services block for `brew services start/stop kleo-receipts`

### Service block

```ruby
service do
  run [opt_bin/"kleo", "serve"]
  keep_alive true
  log_path var/"log/kleo-receipts.log"
  error_log_path var/"log/kleo-receipts-error.log"
  environment_variables PATH: std_service_path_env
end
```

The service runs `kleo serve` with no CLI arguments. All configuration comes from `~/.config/kleo/config.toml` (managed via `kleo config set`). Logs go to Homebrew's var/log directory.

### Keeping formulas in sync

A copy of this formula also lives at `../kleo-receipts/Formula/kleo-receipts.rb`. Both must stay in sync — update both when changing the formula.
