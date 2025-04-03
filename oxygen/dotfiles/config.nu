# aliases
alias ll = ls -l

# config
$env.config.show_banner = false
$env.config.buffer_editor = "code"
$env.config.table.mode = "light"

# prompt
$env.config.edit_mode = "vi"
$env.PROMPT_INDICATOR = $"(ansi reset)> (ansi reset)"
$env.PROMPT_INDICATOR_VI_INSERT = $"(ansi default)> (ansi reset)"
$env.PROMPT_INDICATOR_VI_NORMAL = $"(ansi default)! (ansi reset)"

# theme
$env.config.color_config = {
  binary:black
  block: black
  cell-path: black
  closure: black
  custom: black
  duration: black
  float: black
  glob: black
  int: black
  list: black
  nothing: black
  range: black
  record: black
  string: black

  bool: {|| if $in { 'green' } else { 'red' } }

  date: {|| (date now) - $in |
    if $in < 1hr {
        { fg: '#d73a49' attr: 'b' }
    } else if $in < 6hr {
        '#d73a49'
    } else if $in < 1day {
        '#dbab09'
    } else if $in < 3day {
        '#28a745'
    } else if $in < 1wk {
        { fg: '#28a745' attr: 'b' }
    } else if $in < 6wk {
        '#0598bc'
    } else if $in < 52wk {
        '#0366d6'
    } else { 'dark_gray' }
  }

  filesize: {|e|
    if $e == 0b {
        '#6a737d'
    } else if $e < 1mb {
        '#0598bc'
    } else {{ fg: '#0366d6' }}
  }

  shape_and: default
  shape_binary: default
  shape_block: default
  shape_bool: default
  shape_closure: default
  shape_custom: default
  shape_datetime: default
  shape_directory: default
  shape_external: default_bold
  shape_external_resolved: default
  shape_externalarg: default
  shape_filepath: default
  shape_flag: default
  shape_float: default
  shape_garbage: default
  shape_glob_interpolation: default
  shape_globpattern: default
  shape_int: default
  shape_internalcall: default_bold
  shape_keyword: blue_bold
  shape_list: default
  shape_literal: default
  shape_match_pattern: default
  shape_matching_brackets: default
  shape_nothing: default
  shape_operator: default
  shape_or: default
  shape_pipe: default
  shape_range: default
  shape_raw_string: default
  shape_record: default
  shape_redirection: default
  shape_signature: default
  shape_string: default
  shape_string_interpolation: default
  shape_table: default
  shape_vardecl: default
  shape_variable: default

  foreground: default
  background: bg_default
  cursor: default

  empty: default
  header: default_dimmed
  hints: gray
  leading_trailing_space_bg: gray
  row_index: default_dimmed
  search_result: default
  separator: default
}

# plugins
$env.LS_COLORS = (vivid generate one-light)
mkdir ($nu.data-dir | path join "vendor/autoload")
