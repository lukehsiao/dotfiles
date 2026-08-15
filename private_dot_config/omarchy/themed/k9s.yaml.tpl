k9s:
  body:
    fgColor: '{{ foreground }}'
    bgColor: default
    logoColor: '{{ magenta }}'
  prompt:
    fgColor: '{{ foreground }}'
    bgColor: default
    suggestColor: '{{ blue }}'
  help:
    fgColor: '{{ foreground }}'
    bgColor: default
    sectionColor: '{{ green }}'
    keyColor: '{{ blue }}'
    numKeyColor: '{{ red }}'
  frame:
    title:
      fgColor: '{{ cyan }}'
      bgColor: default
      highlightColor: '{{ magenta }}'
      counterColor: '{{ yellow }}'
      filterColor: '{{ green }}'
    border:
      fgColor: '{{ magenta }}'
      focusColor: '{{ blue }}'
    menu:
      fgColor: '{{ foreground }}'
      keyColor: '{{ blue }}'
      numKeyColor: '{{ red }}'
    crumbs:
      fgColor: '{{ background }}'
      bgColor: default
      activeColor: '{{ red }}'
    status:
      newColor: '{{ blue }}'
      modifyColor: '{{ magenta }}'
      addColor: '{{ green }}'
      pendingColor: '{{ yellow }}'
      errorColor: '{{ red }}'
      highlightColor: '{{ cyan }}'
      killColor: '{{ magenta }}'
      completedColor: '{{ muted }}'
  info:
    fgColor: '{{ yellow }}'
    sectionColor: '{{ foreground }}'
  views:
    table:
      fgColor: '{{ foreground }}'
      bgColor: default
      cursorFgColor: '{{ background }}'
      cursorBgColor: '{{ foreground }}'
      markColor: '{{ magenta }}'
      header:
        fgColor: '{{ yellow }}'
        bgColor: default
        sorterColor: '{{ cyan }}'
    xray:
      fgColor: '{{ foreground }}'
      bgColor: default
      cursorColor: '{{ foreground }}'
      cursorTextColor: '{{ background }}'
      graphicColor: '{{ magenta }}'
    charts:
      bgColor: default
      chartBgColor: default
      dialBgColor: default
      defaultDialColors:
        - '{{ green }}'
        - '{{ red }}'
      defaultChartColors:
        - '{{ green }}'
        - '{{ red }}'
      resourceColors:
        cpu:
          - '{{ magenta }}'
          - '{{ blue }}'
        mem:
          - '{{ yellow }}'
          - '{{ yellow }}'
    yaml:
      keyColor: '{{ blue }}'
      valueColor: '{{ foreground }}'
      colonColor: '{{ muted }}'
    logs:
      fgColor: '{{ foreground }}'
      bgColor: default
      indicator:
        fgColor: '{{ blue }}'
        bgColor: default
        toggleOnColor: '{{ green }}'
        toggleOffColor: '{{ muted }}'
  dialog:
    fgColor: '{{ yellow }}'
    bgColor: default
    buttonFgColor: '{{ background }}'
    buttonBgColor: default
    buttonFocusFgColor: '{{ background }}'
    buttonFocusBgColor: '{{ magenta }}'
    labelFgColor: '{{ magenta }}'
    fieldFgColor: '{{ foreground }}'
