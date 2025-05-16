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
def gcf [a: int b: int k: int = 0]: nothing -> int {
  if ($a == 0) {
    return ($b * (2 ** $k))
  } else if ($b == 0) {
    return ($a * (2 ** $k))
  }
  let a_even = $a mod 2 == 0
  let b_even = $b mod 2 == 0
  if ($a_even and ($b_even)) {
    gcf ($a // 2) ($b // 2) ($k + 1)
  } else if ($a_even) {
    gcf ($a | remove 2) $b $k
  } else if ($b_even) {
    gcf $a ($b | remove 2) $k
  } else {
    gcf (($a - $b | math abs) // 2) ([$a $b] | math min) $k
  }
}

def gcf-list []: list -> int {
  reduce {|it acc| gcf $it $acc }
}

def main [--config (-c): string = '~/.config/swayblocks/config.yml'] {
  let config = $config | str replace -r '^~' $env.HOME
  if (($config | path type) != 'file') {
    error make {
      msg: 'Could not find configuration file!'
      help: $'Path was ($config), does this point to a file?'
    }
  }
  let config = $config | open
  let interval = (
    $config.modules.interval
    | where {|v| ($v | describe) == 'int' and $v > 0 }
    | gcf-list
  )
  let max = $config.modules.interval | math max
  {
    config: $config
    interval: $interval
    max: $max
  }
}
