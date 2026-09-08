# cv

My CV and cover letters, built with LaTeX (XeLaTeX) and automatically compiled to PDF via GitHub Actions.

**Landing page with links to both documents:**
https://maxizu.github.io/cv/

**View the latest CV in the browser (stable link, always up to date):**
https://maxizu.github.io/cv/cv_zuleger.pdf

**View the latest project references in the browser (stable link):**
https://maxizu.github.io/cv/projects_zuleger.pdf

**Download the latest CV (stable link, forces a download instead of viewing inline):**
https://github.com/maxizu/cv/releases/latest/download/cv_zuleger.pdf

Check out my website: https://max-z.de

## Structure

```
cv/                     Main CV (cv_zuleger.tex, custom "friggeri-cv" class, bibliography)
cover-letters/          Cover letter documents, based on the moderncv class
                        (only the generic template.tex is tracked in git;
                        personal/company-specific letters stay local-only,
                        see .gitignore)
cover-letters/moderncv/ moderncv class + style files needed by the cover letters
project-reference/      Project reference sheet listing past projects (name + one-liner,
                        tech stack, fachliche/überfachliche topics), same design language
                        as the CV. All styling lives in project-reference.cls; just fill
                        in project-reference/projects.tex with real project entries.
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
./build.sh --project-reference         # build the project reference sheet
./build.sh --all                       # build the CV, cover letter(s), and project reference
./build.sh cv/cv_zuleger.tex                  # build a specific file explicitly
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
  latexmk -pdf -xelatex cv/cv_zuleger.tex
```

### Local TeX Live installation (no Docker)

```bash
brew install --cask basictex
sudo tlmgr update --self
sudo tlmgr install collection-latexextra collection-fontsrecommended latexmk

TEXINPUTS=".:./cv//:./cover-letters/moderncv//:" latexmk -pdf -xelatex cv/cv_zuleger.tex
```

## Project reference sheet

`project-reference/projects.tex` lists all past projects (one per employer/engagement):
project name + one-sentence description, tech stack (rendered as small colored badges),
and a combined list of responsibilities/highlights (domain work + soft skills/methodology,
in one bullet list rather than split into separate categories). All design lives in
`project-reference/project-reference.cls`; the content file only uses these commands:

```latex
\projectentry{Company -- Project name}{One-sentence description of the project.}

\reflabel{Tech-Stack}
\techstack{Java, Spring Boot, Kafka, PostgreSQL, Docker, AWS}

\reflabel{Highlights}
\begin{itemize}
  \item Led a 5-person engineering team, introduced Scrum and CI/CD practices
  \item Designed and implemented the core microservices architecture
\end{itemize}

\projectsep   % separator before the next project entry
```

Just duplicate this block per project and fill in the details. For the highlights, mix
domain-specific work and soft-skill/methodology points in a single list, one bullet per
item, starting with an action verb (e.g. "Led...", "Designed...", "Collaborated with...").

## CI

On every push touching `cv/`, `cover-letters/`, `project-reference/`, `fonts/`, or `img/`,
GitHub Actions compiles the CV, the generic cover letter template, and the project reference
sheet, uploading the resulting PDFs as workflow artifacts (`cv-pdf`, `cover-letter-template-pdf`,
and `project-reference-pdf`), see `.github/workflows/build-cv.yml`.

On every push to `master`, the CV PDF is additionally published as an asset of a `latest` GitHub
Release, which is created or updated automatically. This gives a permanent, stable download link
that never changes, regardless of how often the CV is rebuilt:

```
https://github.com/maxizu/cv/releases/latest/download/cv_zuleger.pdf
```

Both the CV and the project reference sheet are also deployed to GitHub Pages (as
`cv_zuleger.pdf` and `projects_zuleger.pdf`, plus a small `index.html` landing page linking to
both), which serves them with the correct `Content-Type` so browsers display them inline instead
of forcing a download (GitHub Release assets always force a download, which Pages avoids):

```
https://maxizu.github.io/cv/
https://maxizu.github.io/cv/cv_zuleger.pdf
https://maxizu.github.io/cv/projects_zuleger.pdf
```

Note: since the project reference sheet may contain descriptions of employer/project details, and
this repository is public, publishing it to Pages makes it publicly accessible at the URL above -
the same as the CV.
