#!/usr/bin/env bash
#
# Build the CV and/or cover letter PDFs locally using Docker (same image/setup as CI).
# No local LaTeX installation required. Resulting PDFs are moved into ./pdf/
# (local only, not tracked in git) and all LaTeX build artifacts are cleaned up
# automatically afterwards.
#
# Usage:
#   ./build.sh                    # build the CV only (default)
#   ./build.sh --cv                 # build the CV only
#   ./build.sh --cover-letters       # build only the cover letter(s)
#   ./build.sh --project-reference    # build the project reference sheet
#   ./build.sh --all                 # build the CV, cover letter(s) and project reference
#   ./build.sh <file.tex> [...]      # build specific file(s) explicitly
#   ./build.sh --clean               # just remove build artifacts / pdf/ and exit
#   ./build.sh --keep-aux ...        # do not clean up LaTeX aux files afterwards
#
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

IMAGE_TAG="cv-builder"
PDF_DIR="pdf"

AUX_PATTERNS=(
  "*.aux" "*.log" "*.fls" "*.out" "*.bbl" "*.bcf" "*.bcf-SAVE-ERROR"
  "*.bbl-SAVE-ERROR" "*.blg" "*.run.xml" "*.xdv" "*.fdb_latexmk" "*.synctex.gz"
)

clean_aux() {
  for pattern in "${AUX_PATTERNS[@]}"; do
    find . -maxdepth 2 -name "$pattern" -not -path "./.git/*" -delete
  done
  # Any stray PDFs left in the repo root from a build (before being moved)
  find . -maxdepth 1 -name "*.pdf" -delete
}

clean_all() {
  echo "Cleaning build artifacts and $PDF_DIR/..."
  clean_aux
  rm -rf "$PDF_DIR"
}

usage() {
  grep '^#' "${BASH_SOURCE[0]}" | sed 's/^#//; s/^ //'
}

MODE="cv"
KEEP_AUX=false
EXPLICIT_TARGETS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cv) MODE="cv"; shift ;;
    --cover-letters) MODE="cover-letters"; shift ;;
    --project-reference) MODE="project-reference"; shift ;;
    --all) MODE="all"; shift ;;
    --clean) clean_all; exit 0 ;;
    --keep-aux) KEEP_AUX=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *.tex) EXPLICIT_TARGETS+=("$1"); shift ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ ${#EXPLICIT_TARGETS[@]} -gt 0 ]]; then
  TARGETS=("${EXPLICIT_TARGETS[@]}")
else
  TARGETS=()
  case "$MODE" in
    cv)
      TARGETS+=("cv/cv_zuleger.tex")
      ;;
    cover-letters)
      for f in cover-letters/*.tex; do
        [[ -e "$f" ]] && TARGETS+=("$f")
      done
      ;;
    project-reference)
      TARGETS+=("project-reference/projects.tex")
      ;;
    all)
      TARGETS+=("cv/cv_zuleger.tex")
      for f in cover-letters/*.tex; do
        [[ -e "$f" ]] && TARGETS+=("$f")
      done
      TARGETS+=("project-reference/projects.tex")
      ;;
  esac
fi

if [[ ${#TARGETS[@]} -eq 0 ]]; then
  echo "No .tex files found to build." >&2
  exit 1
fi

echo "Building Docker image ($IMAGE_TAG)..."
docker build -t "$IMAGE_TAG" .

mkdir -p "$PDF_DIR"

for target in "${TARGETS[@]}"; do
  echo "=== Building $target ==="
  docker run --rm -v "$(pwd)":/work "$IMAGE_TAG" "$target"
  pdf="$(basename "${target%.tex}.pdf")"
  if [[ -f "$pdf" ]]; then
    mv -f "$pdf" "$PDF_DIR/$pdf"
    echo "-> $PDF_DIR/$pdf"
  else
    echo "!! $pdf was not produced, check the log above"
    exit 1
  fi
done

if [[ "$KEEP_AUX" == false ]]; then
  clean_aux
fi

echo
echo "Done. PDFs are in ./$PDF_DIR/"
