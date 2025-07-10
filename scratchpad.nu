#!/usr/bin/env nu
# this works, but hopefully can be improved upon
swaymsg -t get_tree
| from json
# time for the worst index
| $in.nodes.nodes.0.floating_nodes.0
# gets list of windows in scratchpad; assumes scratchpad is always first index,
# will cause issues if that is not the case- I think it is, but keep an eye out
| length
| $'<span color="#FFFF00">/<i>($in)</i>/</span>'

