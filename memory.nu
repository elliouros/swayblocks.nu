#!/usr/bin/env nu
const gradient = [
  [ 0   255 255 ] # red channel
  [ 255 255 0   ] # green channel
  [ 0   0   0   ] # blue channel
]

def clamp [low high]: number -> number {
  [$in $low]
  | [($in | math max) $high]
  | math min
}

def gradient [vGradient:list<list<number>>]: number -> list<number> {
  let factor = $in | clamp 0 1
  $vGradient | each {|gradient| # list<number>
    let divisions = $gradient | length | $in - 1
    if ($factor >= 1) { return ($gradient | get $divisions) }
    let index = $factor * $divisions | math floor
    let low = $gradient | get $index
    let high = $gradient | get ($index + 1)
    let divfactor = $factor mod (1 / $divisions) * $divisions
    $low + $divfactor * ($high - $low)
  }
}

def color []: list<number> -> string {
  each {
    math round
    | clamp 0 255
    | [
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

sys mem
| $in.used / $in.total
| $'<span color="#FFFF00">MEM</span> <span color="#($in | gradient $gradient | color)">($in * 100 | math round -p 1)%</span>'
