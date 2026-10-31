# AUR packages

This is a repository for AUR packages. Each package has a config in `packages/`, and [aurtomator](https://github.com/staticwire/aurtomator) checks it for new upstream versions on a schedule and pushes the updates to the AUR.

<!-- BADGES:START -->
**After creating your repository from the template [staticwire/aurtomator-seed](https://github.com/staticwire/aurtomator-seed)**, set it up:

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

5. Add a package. `<name>` is the pkgbase on the AUR:

   ```bash
   ./aurtomator.sh sample > packages/<name>.yml
   ```

   Set `name: <name>`, a `strategy` and its `upstream` fields in that file. Then check it:

   ```bash
   ./aurtomator.sh validate-pkg <name>
   ```

6. Commit and push.

A run of `Check AUR Package Updates` after the setup replaces this text with the badges. The full guide is [docs/SETUP.md](https://github.com/staticwire/aurtomator/blob/main/docs/SETUP.md#after-creating-the-repository) of aurtomator. Report a problem of aurtomator in [its issues](https://github.com/staticwire/aurtomator/issues) and a vulnerability [privately](https://github.com/staticwire/aurtomator/security/advisories/new), not in this repository.
<!-- BADGES:END -->

## Packages

<!-- PACKAGES:START -->
A run of `Check AUR Package Updates` after the setup replaces this text with the package table.
<!-- PACKAGES:END -->
