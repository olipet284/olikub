# Olikub

Olikub is my Omakase (chef's choice) setup, based on DHH's [Omakub](https://github.com/basecamp/omakub), with my own customizations and tweaks. To install it on a fresh Ubuntu 26.04+ system, run:

```sh
wget -qO- https://raw.githubusercontent.com/olipet284/olikub/main/boot.sh | bash
```

Choose another checkout location with `--directory`:

```sh
wget -qO- https://raw.githubusercontent.com/olipet284/olikub/main/boot.sh | bash -s -- --directory "$HOME/repos/olikub/main"
```

Without an option, Olikub uses `~/.local/share/olikub` by default and offers a
directory prompt when run in a terminal. Running `boot.sh` from an existing
Olikub `main` checkout reuses that checkout. Existing paths must be the official
repository on `main`; Olikub does not delete or replace them.

Olikub turns a fresh Ubuntu installation into a fully configured, modern web development system with a single command.

## Development

Use feature branches or worktrees for development; keep the runtime checkout on
the official `main` branch. The bootstrap and self-updater use `main`, so merge
changes there before expecting a normal install or update to include them.

Create a separate worktree for a feature with:

```sh
git worktree add ../olikub-feature -b feat/my-change main
```

## Themes and hotkeys

Open the Olikub app, press Super+Shift+T, or run `olikub theme` in a shell to
choose a theme. Btop uses the
stable `olikub` theme name; changing palettes replaces
`~/.config/btop/themes/olikub.theme` without rewriting the rest of
`~/.config/btop/btop.conf`. On upgrade, Olikub migrates an existing regular
Btop config from an Olikub theme name to `olikub`; config symlinks are left
alone.

GNOME custom shortcuts are loaded from
`${XDG_CONFIG_HOME:-$HOME/.config}/olikub/hotkeys/*.sh`. Olikub creates a sample
file if the directory is missing and leaves existing user directories alone.
The files use `add_custom_keybinding 'Name' 'command' '<Binding>'` and can be
symlinked from a dotfiles repository.

## Upstream project

Olikub builds on Omakub. See [omakub.org](https://omakub.org) for the upstream introduction and documentation, and [Omakub extensions](EXTENSIONS.md) for community add-ons.

## License

Olikub is released under the [MIT License](https://opensource.org/licenses/MIT).
