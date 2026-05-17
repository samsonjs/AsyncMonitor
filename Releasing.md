# Releasing AsyncMonitor

There's no schedule here. Ship bug fixes whenever, features when they're ready, and breaking changes as rarely as you can stand.

AsyncMonitor is a Swift package and a release is just a git tag. SwiftPM resolves versions directly from tags.

## Before You Cut a Release

Run the tests and make sure they pass.

```shell
swift test
```

Check that you're on `main` with a clean working tree, and that nothing looks weird in the recent history.

```shell
git status
git log -5 --oneline
```

## Update the Changelog

Find the `[Unreleased]` section in [Changelog.md](./Changelog.md), rename it to the new version, stamp it with today's date, and add the diff link at the bottom of the section.

```markdown
## [0.4.0] - 2026-05-17

### Removed
- Description of removals

### Changed
- Description of changes

### Fixed
- Description of fixes

### Added
- Description of additions

[0.4.0]: https://github.com/samsonjs/AsyncMonitor/compare/0.3.1...0.4.0
```

Drop the "Your change here." placeholder if it's still there, and drop any of the Removed/Changed/Fixed/Added sections that don't actually have anything in them.

Commit and push.

```shell
git add Changelog.md
git commit -m "Prepare for release 0.4.0"
git push github main
```

## Tag and Release on GitHub

Tag it, push the tag, and cut the release. GitHub will generate notes from merged PRs and commits since the last tag:

```shell
git tag 0.4.0
git push github 0.4.0
gh release create 0.4.0 --verify-tag --generate-notes
```

If you'd rather use your changelog entry as the release body, this pulls just that section out:

```shell
gh release create 0.4.0 --verify-tag --notes "$(awk '/^## \[0\.4\.0\]/,/^## \[/' Changelog.md | sed '$d')"
```

## Start the Next Version

Drop a fresh `[Unreleased]` section at the top of [Changelog.md](./Changelog.md) so there's somewhere to write down the next round of changes.

```markdown
## [Unreleased]

- Your change here.

[Unreleased]: https://github.com/samsonjs/AsyncMonitor/compare/0.4.0...HEAD
```

Commit and push and you're done.

```shell
git add Changelog.md
git commit -m "Start next changelog entry"
git push github main
```
