# .latexmkrc — build configuration
# Run: latexmk thesis   (or latexmk -pv thesis to also open the PDF)

$pdf_mode = 4;            # 4 = LuaLaTeX (recommended)
                          # Use 5 for XeLaTeX if you prefer
$lualatex = 'lualatex -interaction=nonstopmode -synctex=1 %O %S';
$bibtex_use = 2;          # run biber when needed
$clean_ext = 'synctex.gz synctex(busy) run.xml .aux .bbl .bcf .blg ' .
             '.fdb_latexmk .fls .log .out .toc .lof .lot .mtc* .maf';

$aux_dir = 'build/';
$out_dir = 'build/';

@default_files = ('resume.tex');