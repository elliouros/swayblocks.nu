#!/usr/bin/env nu
def find-focused []: record -> record {
  let $inp = $in
  if ($inp.focused? == true) {return $inp}
  $inp.nodes ++ $inp.floating_nodes
  | where id == $inp.focus.0
  | get 0
  | find-focused
}

swaymsg -t get_tree
| from json
| find-focused
| match ($in.type) {
  'output' => {$'output ($in.name)'}, # pretty sure this never happens
  'workspace' => {$'workspace ($in.name)'}, # self-explanatory
  'con' | 'floating_con' => {
    if (($in.nodes | length) > 0) { # container (has nodes)
      $'($in.type)tainer ($in.nodes | length)' # hacky ass interpolation :sob:
    } else { # window (empty nodes)
      $in.name? | default '<unnamed>'
    }
  },
  _ => {$'unknown type ($in.type)'}, # also probably doesn't happen
}
