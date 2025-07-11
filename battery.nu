#!/usr/bin/env nu
const name_color = 'color="#FFFF00"'
const crit = 20
const chrg_color = 'color="#00FF00"'
const crit_color = 'color="#FF0000" weight="bold"'

def color-from-bat []: record -> string {
  {
    perc: ($in.POWER_SUPPLY_CAPACITY | into int)
    chrg: ($in.POWER_SUPPLY_STATUS == 'Charging')
  }
  | if $in.chrg {
    $chrg_color
  } else if ($in.perc <= $crit) {
    $crit_color
  } else {
    null
  }
}
def bat-to-text [--no-name (-0)]: record -> string {
  {
    name: (if $no_name {'BAT'} else {$in.POWER_SUPPLY_NAME})
    color: ($in | color-from-bat)
    perc: ($in.POWER_SUPPLY_CAPACITY ++ '%')
  }
  | [
    $'<span ($name_color)>'
    ($in.name)
    '</span> '
    # hacky shit
    ($in | if ($in.color != null) {
      $'<span ($in.color)>($in.perc)</span>'
    } else {
      $in.perc
    })
  ]
  | str join
}

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
| if (($in | length) == 1) {
  $in | first | bat-to-text -0
} else {
  $in
  | each {|| bat-to-text}
  | str join ' '
}
