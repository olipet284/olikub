# Olikub

<img src="launchers/icons/Olikub.png" alt="Olikub logo" width="128">

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

## Apps

Optional applications live in `apps/<kind>/<topic>/<app>.sh`, where `kind` is
`cli`, `tui`, or `gui`, and `topic` groups apps by use (`coding-harness`,
`browser`, `multiplexer`, ...). Interactive coding harnesses (`claude`, `codex`,
`opencode`, ...) are `tui` or `gui` apps, never `cli`. Each app file defines `APP_NAME`,
`APP_DESCRIPTION`, `APP_DEFAULT`, and the functions `app_installed`,
`app_install`, and `app_uninstall`. `app_installed` decides whether the app
appears under Install or Uninstall; when it is omitted, Olikub checks `APP_BIN`
(or the file name) on `PATH`.

The Install and Uninstall menus are split. Each asks for the app types first
(`CLI`, `TUI`, `GUI`), then the categories within those types, then the apps.
You can select several types and categories at once, and one confirmation
covers the whole batch. Recipes stay available from the types step.

Apps with `APP_DEFAULT=1` are installed by `install.sh`. Everything else is
available from the Olikub menu. To inspect or manage a single app directly:

```sh
olikub apps
olikub apps install lazygit
olikub apps uninstall lazygit
```

Uninstall removes programs but keeps user configuration by default. Apps built
from a Git checkout are cloned to
`${XDG_DATA_HOME:-$HOME/.local/share}/olikub/apps/<app>`; uninstall removes the
command but leaves the checkout and its local data (such as git-user profiles)
in place.

## Themes and hotkeys

Open the Olikub app, press Super+Shift+T, or run `olikub theme` in a shell to
choose a theme. Applying a theme also applies its generated Ubuntu wallpaper.

Each theme can hold several wallpapers in `themes/<theme>/wallpapers/`. They are
cycled in filename order with `Super+Ctrl+Space` (`olikub wallpaper next`), and
the cycle starts over with the Ubuntu wallpaper. Add images by dropping files
into the directory; no registration is needed. Cycling does not persist across
theme changes: switching a theme starts on its Ubuntu wallpaper.

The Ubuntu wallpaper is generated from
`themes/assets/ubuntu-wallpaper.svg.template` using the colors in
`themes/<theme>/theme.conf`. Preview or regenerate one for any theme with:

```sh
olikub wallpaper generate tokyo-night
olikub wallpaper generate all
```

Existing installations keep their current hotkeys file. Re-run
`install/desktop/set-gnome-hotkeys.sh` (or the installer) to pick up the
wallpaper shortcut.

Btop uses the
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
