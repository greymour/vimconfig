; Injection queries for JavaScript/TypeScript/TSX/JSX
;
; INSTALLATION FOR NEOVIM:
; 1. Copy to ~/.config/nvim/after/queries/typescript/injections.scm
; 2. Copy to ~/.config/nvim/after/queries/javascript/injections.scm
; 3. Copy to ~/.config/nvim/after/queries/tsx/injections.scm
; 4. Copy to ~/.config/nvim/after/queries/jsx/injections.scm
;
; NOTE: Using 'after/queries' ensures these extend (not replace) existing queries
;
; Supported patterns:
;   groq`...`                    - Tagged template literal
;   /* groq */ `...`             - Block comment before template
;   // groq \n `...`             - Line comment before template

; extends

; =============================================================================
; Tagged template literal: groq`...`
; =============================================================================
; This matches: const query = groq`*[_type == "movie"]`
(call_expression
  function: (identifier) @_tag
  arguments: (template_string) @injection.content
  (#eq? @_tag "groq")
  (#set! injection.language "groq"))

; =============================================================================
; Block comment: /* groq */ `...`
; =============================================================================
; This matches: const query = /* groq */ `*[_type == "movie"]`
(
  (comment) @_comment
  .
  (template_string) @injection.content
  (#lua-match? @_comment "/[*]%s*groq%s*[*]/")
  (#set! injection.language "groq"))

; Alternative block comment pattern (some parsers structure differently)
(lexical_declaration
  (variable_declarator
    (comment) @_comment
    value: (template_string) @injection.content)
  (#lua-match? @_comment "/[*]%s*groq%s*[*]/")
  (#set! injection.language "groq"))

; =============================================================================
; Line comment: // groq
; =============================================================================
; This matches:
; // groq
; const query = `*[_type == "movie"]`
(
  (comment) @_comment
  .
  (lexical_declaration
    (variable_declarator
      value: (template_string) @injection.content))
  (#lua-match? @_comment "^//%s*groq%s*$")
  (#set! injection.language "groq"))

; Line comment directly before template string
(
  (comment) @_comment
  .
  (template_string) @injection.content
  (#lua-match? @_comment "^//%s*groq%s*$")
  (#set! injection.language "groq"))

; =============================================================================
; Expression statement patterns (for standalone template literals)
; =============================================================================
(expression_statement
  (comment) @_comment
  (template_string) @injection.content
  (#lua-match? @_comment "/[*]%s*groq%s*[*]/")
  (#set! injection.language "groq"))
