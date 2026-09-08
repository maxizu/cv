# cv

My CV and cover letters, built with LaTeX (XeLaTeX) and automatically compiled to PDF via GitHub Actions.

Check out my website: https://max-z.de

## Structure

```
cv/                     Main CV (2cv.tex, custom "friggeri-cv" class, bibliography)
cover-letters/          Cover letter documents, based on the moderncv class
cover-letters/moderncv/ moderncv class + style files needed by the cover letters
fonts/                  Shared font files (Tex Gyre Heros, Lato)
img/                    Shared images used by both the CV and cover letters
```

## Building locally

You need a XeLaTeX-capable TeX distribution (e.g. [MacTeX](https://tug.org/mactex/), BasicTeX, or TeX Live).
The easiest way to build without installing anything locally is via Docker, using the same image as CI.

### Option A: Docker (recommended, no local install needed)

Build the CV:

```bash
docker run --rm -e TEXINPUTS=".:./cv//:" \
  -v "$(pwd)":/work -w /work texlive/texlive:latest \
  latexmk -pdf -xelatex cv/2cv.tex
```

Build a cover letter (e.g. the Audi one):

```bash
docker run --rm -e TEXINPUTS=".:./cover-letters/moderncv//:" \
  -v "$(pwd)":/work -w /work texlive/texlive:latest \
  latexmk -pdf -xelatex cover-letters/cover_letter_audi.tex
```

The resulting PDF is written next to the source `.tex` file (`cv/2cv.pdf`, `cover-letters/cover_letter_audi.pdf`, ...).

Clean up auxiliary build files afterwards:

```bash
find . -maxdepth 2 \( -name "*.aux" -o -name "*.log" -o -name "*.pdf" -o -name "*.fls" \
  -o -name "*.out" -o -name "*.bbl" -o -name "*.bcf*" -o -name "*.run.xml" -o -name "*.xdv" \
  -o -name "*.blg" -o -name "*.fdb_latexmk" -o -name "*.synctex.gz" \) -delete
```

### Option B: Local TeX Live installation

```bash
brew install --cask basictex
sudo tlmgr update --self
sudo tlmgr install collection-latexextra collection-fontsrecommended latexmk

latexmk -pdf -xelatex cv/2cv.tex
```

## CI

On every push touching `cv/`, `cover-letters/`, `fonts/`, or `img/`, GitHub Actions compiles the CV and
all cover letters and uploads the resulting PDFs as workflow artifacts (`cv-pdf` and `cover-letters-pdf`),
see `.github/workflows/build-cv.yml`.
