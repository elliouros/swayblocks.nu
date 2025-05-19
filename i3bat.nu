#!/usr/bin/env nu
def get-stat [] {
  [
    {
      name: battery
      full_text: (nu /home/ellie/Projects/swayblocks.nu/battery.nu)
      markup: pango
    }
    {
      name: time
      full_text: (^date +%T)
    }
  ]
  | to json -r
}

'{"version":1,"click_events":true}'
| $"($in)\n["
| print
loop {
  get-stat
  | $'($in),'
  | print
  sleep 1sec
}

']' | print
