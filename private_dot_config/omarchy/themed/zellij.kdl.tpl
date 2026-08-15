themes {
  omarchy {
    bg "{{ selection }}"
    fg "{{ foreground }}"
    black "{{ background }}"
    red "{{ red }}"
    green "{{ green }}"
    yellow "{{ yellow }}"
    blue "{{ blue }}"
    magenta "{{ magenta }}"
    cyan "{{ cyan }}"
    white "{{ foreground }}"
    // Intentionally yellow: themes without a true orange derive one, and
    // yellow reads better than a derived orange in zellij's UI accents.
    orange "{{ yellow }}"
  }
}
