#!/usr/bin/env nu
# Because swayblocks.nu does not spawn processes in parallel and sys cpu -l is
# unperformant, this script is really slow and will make your bar stutter.
# It's also just full of jank and probably bad code. Seriously, don't use this.
# (Nonetheless, it was a fun excercise ¯\_(ツ)_/¯ )
const gradient = [
  { low: 0   high: 255 }
  { low: 255 high: 0   }
  { low: 0   high: 0   }
]
def 'gradient get' [gradient: list<record<low: int high: int>>]: float -> any {
  let factor = $in
  $gradient
  | each {|it|
    $it.low + $factor * ($it.high - $it.low)
    | into int
  }
}
def 'color from list' []: list<int> -> any {
  each {
    [
      ($in // 16)
      ($in mod 16)
    ]
    | each {|it|
      match $it {
        10 => {'A'},
        11 => {'B'},
        12 => {'C'},
        13 => {'D'},
        14 => {'E'},
        15 => {'F'},
        $x if $x < 10 => {$x | into string}
      }
    }
  }
  | flatten
  | str join
}
sys cpu -l
| get cpu_usage
| each {
  $in / 100
  | gradient get $gradient
  | color from list
}
| chunks 2
| each {$"<span color=\"#($in.0)\" bgcolor=\"#($in.1)\">\u{258C}</span>"}
| str join
| '<span color="#FFFF00">CPU</span> ' ++ $in
