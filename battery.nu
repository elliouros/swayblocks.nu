#!/usr/bin/env nu
const name_color = '#FFFF00'
const crit = 20
const crit_color = '#FF0000'
const chrg_color = '#00FF00'
def span []: string -> string {
  $'<span foreground="($in)">'
}
def color-from-bat []: record -> string {
  let bat = $in
  let perc = $bat.POWER_SUPPLY_CAPACITY | into int
  let chrg = $bat.POWER_SUPPLY_STATUS == 'Charging'
  if $chrg {
    $chrg_color
  } else if ($perc < $crit) {
    $crit_color
  } else {
    '#FFFFFF'
  }
}
def bat-to-text [--no-name (-0)]: record -> string {
  let bat = $in
  [
    $'($name_color | span)'
    $'(if $no_name {'BAT'} else {$bat.POWER_SUPPLY_NAME})'
    '</span> '
    $'($bat | color-from-bat | span)'
    $'($bat.POWER_SUPPLY_CAPACITY | into string)'
    '%</span>'
  ] | str join ''
}
let batteries = (
  glob '/sys/class/power_supply/*'
  | each {||
    $'($in)/uevent'
    | open
    | lines
    | parse '{key}={value}'
    | reduce -f {} {|it|
      upsert $it.key $it.value
    }
  }
  | where POWER_SUPPLY_TYPE == Battery
)

if (($batteries | length) == 1) {
  $batteries | first | bat-to-text -0
} else {
  $batteries
  | each {|| bat-to-text}
  | str join ' '
}
