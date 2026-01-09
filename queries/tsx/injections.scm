; Injection queries for JavaScript/TypeScript
; Copy this file to ~/.config/nvim/queries/javascript/injections.scm
; and ~/.config/nvim/queries/typescript/injections.scm
; Use "; extends" at the top if you want to add to existing injections

; Block comment /* groq */ followed by template literal
((comment) @_comment
  .
  (template_string) @injection.content
  (#match? @_comment "/\\*\\s*groq\\s*\\*/")
  (#set! injection.language "groq"))

; Line comment // groq followed by template literal on next line
((comment) @_comment
  .
  (template_string) @injection.content
  (#match? @_comment "//\\s*groq")
  (#set! injection.language "groq"))

; Tagged template literal: groq`...`
((call_expression
  function: (identifier) @_tag
  arguments: (template_string) @injection.content)
  (#eq? @_tag "groq")
  (#set! injection.language "groq"))
