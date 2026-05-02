function color_to_code(color) {
    switch (color) {
        case "yellow": return "33"
        case "blue": return "34"
        case "red": return "31"
        case "green": return "32"
        case "magenta": return "35"
        default: return "30"
    }
}

function colored(color, text) {
    return "\033[" color_to_code(color) "m" text "\033[0m"
}

BEGINFILE {
    will_output = 1
    applying_latex = 0
}

/^$/ {
    # Reset everything on an empty line
    if (continue_printing != 0) {
        printf "\n\n"
    }
    continue_printing = 0
}

/^Latexmk: Log file says output/ {
    will_output = 1
}

match($0, /^Latexmk: applying rule '(.*?)'\.\.\./, groups) {
    msg = "◉───── Applying rule " groups[1]
    # print colored("blue", "◉ Compiling...")

    if (groups[1] ~ /(.*?)latex/) {
        if (!will_output) {
            msg = msg " (silenced)"
        }
        
        applying_latex = 1
    }
    msg = msg " ─────"

    print colored("blue", msg)
}

## WARNINGS

will_output && 
  continue_printing == 1 && 
  match($0, "^(\\(" package "\\))?([[:space:]]{4,})?(.+?)$", groups) {
    if (groups[1] != "") {
        printf "\n"
    }
    msg = groups[3]
    if (groups[2] != "") {
        msg = "│ " sprintf("%*s%s", 1 + length(package), "", " ") msg
    } 
    printf "%s",colored("yellow", msg)
}
will_output && 
  match($0, /^(Package|Class|LaTeX) (.+?) Warning: (.*?)$/, groups) {
    printf "%s",colored("yellow", "◈ " groups[2] ": " groups[3])
    package = groups[2]
    continue_printing = 1
}
will_output &&
  continue_printing == 3 {
    split($0, groups, "]")
    if (length(groups) == 1) {
        missing_char = missing_char groups[0]
    } else {
        printf "%s\n\n",colored("yellow", "◈ Font: " missing_char groups[0] "]")
        continue_printing = 0
    }
}
will_output && 
  match($0, /^Missing character: (.+?)$/, groups) {
    if (match(groups[1], /(.*?)(\[.*?\])(.*?)/, groups_)) {
        missing_char = groups_[1] groups_[2]
        printf "%s\n\n",colored("yellow", "◈ Font: " missing_char groups[0])
    } else {
        missing_char = groups[1]
        continue_printing = 3
    }
}

## ERRORS 

will_output && 
  continue_printing == 2 {
    printf "%s\n",colored("red", "│ " $0)

    # if (N != 1 || has_line) {
    #     printf "%s\n",colored("red", "" $0)
    # } else if (!has_line) {
    #     match($0, /^l\.[[:digit:]]+ (.*?)$/, groups)
    #     printf "%s\n",colored("red", "" groups[1])
    # }
    # N--
    # if (N == 0) {
    #     printf "\n"
    # }
}
will_output && 
  match($0, /^! (.*?)$/, groups) {
    printf "%s\n",colored("red", "▣ " groups[1])
    has_line = 0
    continue_printing = 2
}
will_output && 
  match($0, /(.+?):([[:digit:]]+): (.*?)$/, groups) {
    printf "%s\n",colored("red", "▣ " groups[1] ":" groups[2] ": " groups[3])
    has_line = 1
    continue_printing = 2
}

## VARIOUS INFO

# /^This is (.*?)TeX/ {
#     print colored("blue", "◉ Compiling...")
# }

# /^=== Watching for updated files\. Use ctrl\/C to stop \.\.\.$/ {
#     print colored("blue", "◉ Waiting for updates...")
# }

will_output && 
  match($0, /^(Over|Under)full/) {
    print colored("magenta", "◬ " $0 "\n")
    has_line = 0
}

will_output && 
  match($0, /^Output written on ([^\( ]+)/, groups) {
    print colored("green", "⛆ PDF '" groups[1] "' generated.\n")
    will_output = 0
    applying_latex = 0
}