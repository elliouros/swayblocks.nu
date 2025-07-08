#!/usr/bin/env nu

# ideally there is only one backlight anyways but fuck it we ball
glob '/sys/class/backlight/*'
| each {
  [
    $'($in)/actual_brightness'
    $'($in)/max_brightness'
  ]
  | each {open | into int}
  | $in.0 * 100 / $in.1
  | math round
  | $'<span color="#FFFF00">LGT</span> ($in)%'
}
| str join ' '
# hell yeah multibacklight support.. whatever thats useful for
