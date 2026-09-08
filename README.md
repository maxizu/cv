# cv

My CV and cover letters, built with LaTeX (XeLaTeX) and automatically compiled to PDF via GitHub Actions.

Check out my website: https://max-z.de

## Structure

```
cv/                     Main CV (2cv.tex, custom "friggeri-cv" class, bibliography)
cover-letters/          Cover letter documents, based on the moderncv class
                        (only the generic template.tex is tracked in git;
                        personal/company-specific letters stay local-only,
                        see .gitignore)
cover-letters/moderncv/ moderncv class + style files needed by the cover letters
fonts/                  Shared font files (Tex Gyre Heros, Lato)
img/                    Shared images used by both the CV and cover letters
Dockerfile              Image used for local & reproducible builds (same as CI)
build.sh                Convenience script to build all PDFs via Docker
```

## Building locally

The easiest way to build without installing anything locally is via Docker (uses the same
TeX Live image as CI), using the provided `Dockerfile` and `build.sh`:

```bash
./build.sh                          # build cv/2cv.tex + all cover-letters/*.tex present locally
./build.sh cv/2cv.tex                # build only the CV
./build.sh cover-letters/template.tex  # build only a specific file
./build.sh --clean                   # remove all build artifacts (*.pdf, *.aux, *.log, ...)
```

The resulting PDFs (`2cv.pdf`, `template.pdf`, ...) are written to the repository root.

### Manual Docker invocation

If you don't want to build the image via `build.sh`, you can also call `texlive/texlive:latest` directly:

```bash
docker run --rm -e TEXINPUTS=".:./cv//:./cover-letters/moderncv//:" \
  -v "$(pwd)":/work -w /work texlive/texlive:latest \
  latexmk -pdf -xelatex cv/2cv.tex
```

### Local TeX Live installation (no Docker)

```bash
brew install --cask basictex
sudo tlmgr update --self
sudo tlmgr install collection-latexextra collection-fontsrecommended latexmk

TEXINPUTS=".:./cv//:./cover-letters/moderncv//:" latexmk -pdf -xelatex cv/2cv.tex
```

## CI

On every push touching `cv/`, `cover-letters/`, `fonts/`, or `img/`, GitHub Actions compiles the CV and
the generic cover letter template and uploads the resulting PDFs as workflow artifacts
(`cv-pdf` and `cover-letter-template-pdf`), see `.github/workflows/build-cv.yml`.
