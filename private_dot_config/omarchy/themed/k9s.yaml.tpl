k9s:
  body:
    fgColor: '{{ foreground }}'
    bgColor: default
    logoColor: '{{ color5 }}'
  prompt:
    fgColor: '{{ foreground }}'
    bgColor: default
    suggestColor: '{{ color4 }}'
  help:
    fgColor: '{{ foreground }}'
    bgColor: default
    sectionColor: '{{ color2 }}'
    keyColor: '{{ color4 }}'
    numKeyColor: '{{ color1 }}'
  frame:
    title:
      fgColor: '{{ color6 }}'
      bgColor: default
      highlightColor: '{{ color5 }}'
      counterColor: '{{ color3 }}'
      filterColor: '{{ color2 }}'
    border:
      fgColor: '{{ color5 }}'
      focusColor: '{{ color4 }}'
    menu:
      fgColor: '{{ foreground }}'
      keyColor: '{{ color4 }}'
      numKeyColor: '{{ color1 }}'
    crumbs:
      fgColor: '{{ background }}'
      bgColor: default
      activeColor: '{{ color1 }}'
    status:
      newColor: '{{ color4 }}'
      modifyColor: '{{ color5 }}'
      addColor: '{{ color2 }}'
      pendingColor: '{{ color3 }}'
      errorColor: '{{ color1 }}'
      highlightColor: '{{ color6 }}'
      killColor: '{{ color5 }}'
      completedColor: '{{ color8 }}'
  info:
    fgColor: '{{ color3 }}'
    sectionColor: '{{ foreground }}'
  views:
    table:
      fgColor: '{{ foreground }}'
      bgColor: default
      cursorFgColor: '{{ background }}'
      cursorBgColor: '{{ foreground }}'
      markColor: '{{ color5 }}'
      header:
        fgColor: '{{ color3 }}'
        bgColor: default
        sorterColor: '{{ color6 }}'
    xray:
      fgColor: '{{ foreground }}'
      bgColor: default
      cursorColor: '{{ foreground }}'
      cursorTextColor: '{{ background }}'
      graphicColor: '{{ color5 }}'
    charts:
      bgColor: default
      chartBgColor: default
      dialBgColor: default
      defaultDialColors:
        - '{{ color2 }}'
        - '{{ color1 }}'
      defaultChartColors:
        - '{{ color2 }}'
        - '{{ color1 }}'
      resourceColors:
        cpu:
          - '{{ color5 }}'
          - '{{ color4 }}'
        mem:
          - '{{ color3 }}'
          - '{{ color3 }}'
    yaml:
      keyColor: '{{ color4 }}'
      valueColor: '{{ foreground }}'
      colonColor: '{{ color8 }}'
    logs:
      fgColor: '{{ foreground }}'
      bgColor: default
      indicator:
        fgColor: '{{ color4 }}'
        bgColor: default
        toggleOnColor: '{{ color2 }}'
        toggleOffColor: '{{ color8 }}'
  dialog:
    fgColor: '{{ color3 }}'
    bgColor: default
    buttonFgColor: '{{ background }}'
    buttonBgColor: default
    buttonFocusFgColor: '{{ background }}'
    buttonFocusBgColor: '{{ color5 }}'
    labelFgColor: '{{ color5 }}'
    fieldFgColor: '{{ foreground }}'
