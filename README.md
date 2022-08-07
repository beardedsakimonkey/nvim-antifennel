# nvim-antifennel

This is a neovim plugin that provides an `:Antifennel` command that runs the current selection (or
the entire file if not in visual mode) through
[antifennel](https://git.sr.ht/~technomancy/antifennel) and replaces the selection with the output.

This plugin vendors in `antifennel` (currently [ebd11ba5](https://git.sr.ht/~technomancy/antifennel/commit/ebd11ba545f6e1a08519004822b2349dbc82a8ad)).

Note that currently, the plugin is only intended for personal use, and lacks some capabilities such
as character-wise selection.

# Copyright

This plugin is released under the MIT/X license, just like `antifennel`.
