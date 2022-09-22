#!/bin/bash
cd /Users/victor/repositories/asylamba/game
mix compile
mix lex_table fast fr > lex_flash.txt
mix lex_table slow fr > lex_legacy.txt
mix patent_table fast fr > brevets_flash.txt
mix patent_table slow fr > brevets_legacy.txt
mix building_table fr > buildings.txt

gist -p lex_flash.txt lex_legacy.txt brevets_flash.txt brevets_legacy.txt buildings.txt
