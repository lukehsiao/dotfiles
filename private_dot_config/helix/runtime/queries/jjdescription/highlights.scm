; Helix's stock query captures the whole message body as @string, which
; several Omarchy palettes render within 2:1 contrast of @comment, so the
; description I am writing reads as boilerplate. Leaving the body
; uncaptured falls it back to ui.text. The first named child of the
; document is the subject line, which git-commit marks as a heading too.
(document . (text) @markup.heading)

(filepath) @string.special.path

(change type: "A" @diff.plus)
(change type: "D" @diff.minus)
(change type: "M" @diff.delta)
(change type: "C" @diff.plus)
(change type: "R" @diff.delta)

(comment) @comment
