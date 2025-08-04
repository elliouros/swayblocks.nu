#!/usr/bin/env nu
def find-focused []: record -> record {
  let $inp = $in
  if ($inp.focused? == true) {return $inp}
  $inp.nodes ++ $inp.floating_nodes
  | where id == $inp.focus.0
  # ^should error here in case of layer-shell (empty content of focus); doesnt
  # for some reason, when getting a bogus index in a where, an error is not made
  # somehow helpful? allows us to better avoid an error
  | if ($in | is-empty) {return {type: 'nofocus'} } else {$in}
  | get 0
  # ^would error here instead. what the fuck?
  | find-focused
}

swaymsg -t get_tree
| from json
| find-focused
| match ($in.type) {
  'nofocus' => {'ᓚᘏᗢ'}, # happens when focused window is a layer-shell
  'output' => {$'output ($in.name)'}, # pretty sure this never happens
  'workspace' => {$'workspace ($in.name)'}, # self-explanatory
  'con' | 'floating_con' => {
    if ($in.nodes | is-empty) { # window (empty nodes)
      $in.name? | default '<unnamed>'
    } else { # container (has nodes)
      $'($in.type)tainer ($in.nodes | length)' # hacky ass interpolation
    }
  },
  _ => {$'unknown ($in.type)'}, # also probably doesn't happen
}
