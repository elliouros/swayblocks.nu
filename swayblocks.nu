#!/usr/bin/env nu
def remove [y: int]: int -> int {
  let x = $in
  let mod = $x mod $y
  if ($mod == 0) {
    ($x // $y) | remove $y 
  } else {
    $x
  }
}
def gcd [a: int b: int k: int = 0]: nothing -> int {
  if ($a == 0) {
    return ($b * (2 ** $k))
  } else if ($b == 0) {
    return ($a * (2 ** $k))
  }
  let a_even = $a mod 2 == 0
  let b_even = $b mod 2 == 0
  if ($a_even and ($b_even)) {
    gcd ($a // 2) ($b // 2) ($k + 1)
  } else if ($a_even) {
    gcd ($a | remove 2) $b $k
  } else if ($b_even) {
    gcd $a ($b | remove 2) $k
  } else {
    gcd (($a - $b | math abs) // 2) ([$a $b] | math min) $k
  }
}

def gcd-list []: list -> int {
  reduce {|it acc| gcd $it $acc }
}

def main [--config (-c): string = '~/.config/swayblocks/config.yml'] {
  let config = $config | str replace -r '^~' $nu.home-path
  if (($config | path type) != 'file') {
    error make {
      msg: 'Could not find configuration file!'
      help: $'Path was ($config), does this point to a file?'
    }
  }
  let config = $config | open
  let modules = $config | get modules
  let interval = (
    $config.modules.interval
    | where {|v| ($v | describe) == 'int' and $v > 0 }
    | gcd-list
  )
  let interval_dur = $interval | into duration -u ms
  let max = $config.modules.interval | math max

  "{\"version\":1,\"click_events\":false}\n[" | print

  if ($config.debug? != null) {
    sleep ($config.debug.sleep? | default 1000 | into duration -u ms);
    # ^allow notificaiton daemon time to start
    notify-send 'swayblocks.nu info' ([
      $interval
      $max
      ($modules | to nuon)
    ] | str join "\n")
  }

  mut cache = {}

  loop { for clock in 0..$interval..($max - $interval) {
    let before = date now
    let result = $modules
      | reduce -f {cache: $cache results: []} {|mod acc|
        let path = (
          [$mod.name $mod.instance?]
          | where {$in != null}
          | into cell-path
        )
        if ($clock mod $mod.interval == 0) {
          let output = (
            run-external ...$mod.command
            | { name: $mod.name full_text: $in }
            | if ($mod.instance? != null) {insert instance $mod.instance} else {$in}
            | if ($mod.markup? != null) {insert markup $mod.markup} else {$in}
          )
          { # goes into accumulator
            cache: ($acc.cache | upsert $path $output)
            results: ($acc.results | append $output)
          }
        } else {
          # skip computation (module is out of turn), retrieve last version
          let former = $acc.cache | get $path
          {
            cache: $acc.cache
            results: ($acc.results | append $former)
          }
        }
      }

    $cache = $result.cache
    $result.results
    | to json -r
    | $in ++ ','
    | print
    sleep ($before - (date now) + $interval_dur)
    # makes more sense as interval - (date now - before) but this is more
    # conscise because order of operations
  } }
}
