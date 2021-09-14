#!/usr/bin/bash

lang_list=("bash" "css" "dockerfile" "fish" "graphql" "html" "javascript" "json" "lua" "ruby" "rust" "scss" "toml" "tsx" "typescript" "yaml")
treesitter_path="$HOME/.local/share/nvim/site/pack/packer/start/nvim-treesitter/parser"

for lang in "${lang_list[@]}"; do
  (! test -f "${treesitter_path}/${lang}.so") && nvim --headless -c "TSInstallSync ${lang}" -c 'q';
done
