# cv

My CV and cover letters, built with LaTeX (XeLaTeX) and automatically compiled to PDF via GitHub Actions.

**View the latest CV in the browser (stable link, always up to date):**
https://maxizu.github.io/cv/2cv.pdf

**Download the latest CV (stable link, forces a download instead of viewing inline):**
https://github.com/maxizu/cv/releases/latest/download/2cv.pdf

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
./build.sh                             # build the CV only (default)
./build.sh --cv                        # build the CV only
./build.sh --cover-letters             # build only the cover letter(s) present locally
./build.sh --all                       # build the CV and all cover letter(s)
./build.sh cv/2cv.tex                  # build a specific file explicitly
./build.sh --clean                     # remove all build artifacts, incl. pdf/
./build.sh --keep-aux --all            # build but keep LaTeX aux files around
```

The resulting PDFs are moved into `./pdf/` (local only, not tracked in git) and all LaTeX
auxiliary files (`*.aux`, `*.log`, `*.fls`, ...) are cleaned up automatically afterwards.

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

On every push to `master`, the CV PDF is additionally published as an asset of a `latest` GitHub
Release, which is created or updated automatically. This gives a permanent, stable download link
that never changes, regardless of how often the CV is rebuilt:

```
https://github.com/maxizu/cv/releases/latest/download/2cv.pdf
```

It is also deployed to GitHub Pages, which serves the PDF with the correct `Content-Type` so
browsers display it inline instead of forcing a download (GitHub Release assets always force a
download, which Pages avoids):

```
https://maxizu.github.io/cv/2cv.pdf
```
