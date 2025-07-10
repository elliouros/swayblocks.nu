#!/usr/bin/env nu
# requires pactl... obv

let perc = pactl get-sink-volume @DEFAULT_SINK@
| str substring 8..(($in | str index-of "\n") - 1)
| split row ',   '
| parse -r '.+: \d+ / +(?<percent>\d+)% / .+ dB'
# the full parsing regex would be:
# (?<channel>.+): (?<value>\d+) / +(?<percent>\d+)% / (?<decibel>-?[\d\.]+) dB
| $in.percent
| if (($in | uniq | length) == 1) {$in.0} else {'??'}

pactl get-sink-mute @DEFAULT_SINK@
| str substring 6..-1
| if ($in == 'no') {'FF'} else {'00'}
| $'<span color="#FF($in)00">VOL</span> ($perc)%'
