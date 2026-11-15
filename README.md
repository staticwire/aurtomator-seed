# AUR packages

This repository is for AUR packages. Each package has its config in `packages/`, and [aurtomator](https://github.com/staticwire/aurtomator) checks it for new upstream versions on a schedule and pushes updates to the AUR.

<!-- BADGES:START -->
**After creating your repository with [Use this template](https://github.com/staticwire/aurtomator-seed/generate)**, set it up:

1. In Settings > General > Features, turn on Issues. Runs report failures and update alerts as issues.
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

   Until the secrets are set, runs with packages to push fail and open an issue. The first run after `./aurtomator.sh setup` in which no job fails closes that issue.

5. Add a package. `<name>` is its AUR pkgbase:

   ```bash
   ./aurtomator.sh draft <name>
   ```

   It reads the AUR `.SRCINFO` of the package, writes `packages/<name>.yml` with a strategy and its `upstream` fields, and runs `validate-pkg` and `check-update` on that file, see [Draft a package](https://aurtomator.dev/add-a-package/#draft-a-package). When no rule matches the url or a source of the package, it writes nothing. Then write the file from the sample, with `name: <name>`, `strategy` and its `upstream` fields, and check it:

   ```bash
   ./aurtomator.sh sample > packages/<name>.yml
   ./aurtomator.sh validate-pkg <name>
   ```

6. Commit and push. The schedule starts a run a few times a day, and Actions > Check AUR Package Updates > Run workflow starts one at once.

`Check AUR Package Updates` replaces this text with the badges after the setup. The full guide is the [Setup](https://aurtomator.dev/setup/#after-creating-the-repository) page of aurtomator. Report problems of aurtomator in [its issues](https://github.com/staticwire/aurtomator/issues) and vulnerabilities [privately](https://github.com/staticwire/aurtomator/security/advisories/new), not in this repository.
<!-- BADGES:END -->

## Packages

<!-- PACKAGES:START -->
`Check AUR Package Updates` replaces this text with the package table after the setup.
<!-- PACKAGES:END -->
