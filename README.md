# AUR packages

This is a repository for AUR packages. Each package has a config in `packages/`, and [aurtomator](https://github.com/staticwire/aurtomator) checks it for new upstream versions on a schedule and pushes the updates to the AUR.

<!-- BADGES:START -->
**After creating your repository with [Use this template](https://github.com/staticwire/aurtomator-seed/generate)**, set it up:

1. In Settings > General > Features, turn on Issues. A run reports failures and update alerts as issues.
2. In the Actions tab, check that `Check AUR Package Updates` and `Validate packages` are enabled.
3. Clone your repository:

   ```bash
   git clone https://github.com/<you>/<repository>
   cd <repository>
   ```

4. Set up the git identity of your AUR commits, the AUR SSH key and the GitHub secrets:

   ```bash
   ./aurtomator.sh setup
   ```

   Until the secrets are set, a run with a package to push fails and opens an issue. The first run after `./aurtomator.sh setup` in which no job fails closes that issue.

5. Add a package. `<name>` is the pkgbase on the AUR:

   ```bash
   ./aurtomator.sh draft <name>
   ```

   It reads the `.SRCINFO` of the package in the AUR, writes `packages/<name>.yml` with a strategy and its `upstream` fields, and runs `validate-pkg` and `check-update` on that file, see [docs/WORKFLOW.md](https://github.com/staticwire/aurtomator/blob/main/docs/WORKFLOW.md#72-draft-a-package) of aurtomator. When no rule matches the url or a source of the package, it writes nothing. Then write the file from the sample, with `name: <name>`, a `strategy` and its `upstream` fields, and check it:

   ```bash
   ./aurtomator.sh sample > packages/<name>.yml
   ./aurtomator.sh validate-pkg <name>
   ```

6. Commit and push. The schedule starts a run a few times a day, and Actions > Check AUR Package Updates > Run workflow starts one at once.

A run of `Check AUR Package Updates` after the setup replaces this text with the badges. The full guide is [docs/SETUP.md](https://github.com/staticwire/aurtomator/blob/main/docs/SETUP.md#after-creating-the-repository) of aurtomator. Report a problem of aurtomator in [its issues](https://github.com/staticwire/aurtomator/issues) and a vulnerability [privately](https://github.com/staticwire/aurtomator/security/advisories/new), not in this repository.
<!-- BADGES:END -->

## Packages

<!-- PACKAGES:START -->
A run of `Check AUR Package Updates` after the setup replaces this text with the package table.
<!-- PACKAGES:END -->
