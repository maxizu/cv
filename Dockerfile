FROM texlive/texlive:latest

WORKDIR /work

ENV TEXINPUTS=".:./cv//:./cover-letters/moderncv//:"

ENTRYPOINT ["latexmk", "-pdf", "-file-line-error", "-halt-on-error", "-interaction=nonstopmode", "-xelatex"]
