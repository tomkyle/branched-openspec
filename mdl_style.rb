# Markdown linter style rules
all

# MD002: First header should be a top level header - disabled because YAML frontmatter is present
exclude_rule 'MD002'

# MD003: Header style - use ATX style (# headers) consistently
rule 'MD003', :style => :atx

# MD013: Line length - disabled to allow long lines
exclude_rule 'MD013'

# MD033 Inline HTML - disabled to allow <argument> hint in frontmatter
exclude_rule 'MD033'

# MD041 First line in file should be a top level header
exclude_rule 'MD041'
