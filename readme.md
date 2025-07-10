# swayblocks.nu

A swaybar protocol provider written in nu that leverages functional idiomatic
behavior all but exclusively (*one* mutable variable)

Theoretically works for i3 too.

In no way affiliated with Sway, i3, i3blocks, or Nushell. <sub>duh.</sub>

## Usage

Config is by default located at `~/.config/swayblocks/config.yml`. A different
file can be pointed to with `-c`. Config can be any file by which `open` returns
a type matching `record<modules: list<record<name: string, command:
list<string>, interval: int|float|string, markup?: string, instance?: int>>>`
(no, this is not proper type notation. As long as you understand it, it doesn't
matter.)
