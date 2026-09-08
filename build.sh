#!/usr/bin/env bash
#
# Build the CV and cover letter PDFs locally using Docker (same image/setup as CI).
# No local LaTeX installation required.
#
# Usage:
#   ./build.sh                # build cv/2cv.tex + all cover-letters/*.tex
#   ./build.sh cv/2cv.tex     # build only the given file(s)
#   ./build.sh --clean        # remove build artifacts (aux/log/pdf/...) and exit
#
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

IMAGE_TAG="cv-builder"

AUX_PATTERNS=(
  "*.aux" "*.log" "*.pdf" "*.fls" "*.out" "*.bbl" "*.bcf" "*.bcf-SAVE-ERROR"
  "*.bbl-SAVE-ERROR" "*.blg" "*.run.xml" "*.xdv" "*.fdb_latexmk" "*.synctex.gz"
)

clean() {
  echo "Cleaning build artifacts..."
  for pattern in "${AUX_PATTERNS[@]}"; do
    find . -maxdepth 2 -name "$pattern" -not -path "./.git/*" -delete
  done
}

if [[ "${1:-}" == "--clean" ]]; then
  clean
  exit 0
fi

if [[ $# -gt 0 ]]; then
  TARGETS=("$@")
else
  TARGETS=("cv/2cv.tex")
  for f in cover-letters/*.tex; do
    [[ -e "$f" ]] && TARGETS+=("$f")
  done
fi

echo "Building Docker image ($IMAGE_TAG)..."
docker build -t "$IMAGE_TAG" .

for target in "${TARGETS[@]}"; do
  echo "=== Building $target ==="
  docker run --rm -v "$(pwd)":/work "$IMAGE_TAG" "$target"
  pdf="${target%.tex}.pdf"
  pdf="$(basename "$pdf")"
  if [[ -f "$pdf" ]]; then
    echo "-> $pdf"
  else
    echo "!! $pdf was not produced, check the log above"
    exit 1
  fi
done

echo
echo "Done. Run './build.sh --clean' to remove auxiliary build files."
