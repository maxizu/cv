%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Project reference sheet class.
% Shares the same design language (colors, fonts, header banner) as the
% "friggeri-cv" class used for the CV, but as a simple single-column
% document (no sidebar) intended to list multiple project entries:
% project name + one-sentence description, tech stack, and a combined
% list of responsibilities/highlights (domain work + soft skills).
%
% All styling lives here; project-reference/projects.tex should only
% contain content, filled in via the commands defined below:
%
%   \header{First}{Last}{Subtitle}
%   \projectentry{Project name}{One-sentence description}
%   \reflabel{Label}
%   \techstack{Item 1, Item 2, Item 3, ...}
%   \projectsep
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\ProvidesClass{project-reference}[2026/01/01 Project reference class]
\NeedsTeXFormat{LaTeX2e}
\LoadClass{article}

%%%%%%%%%%
% Colors %
%%%%%%%%%%

\RequirePackage{xcolor}

\definecolor{white}{RGB}{255,255,255}
\definecolor{gray}{HTML}{4D4D4D}
\definecolor{lightgray}{HTML}{999999}
\definecolor{pblue}{HTML}{3399cc}

\colorlet{fillheader}{gray}
\colorlet{header}{white}
\colorlet{textcolor}{gray}
\colorlet{headercolor}{gray}

%%%%%%%%%
% Fonts %
%%%%%%%%%

\RequirePackage[quiet]{fontspec}
\RequirePackage[math-style=TeX]{unicode-math}

\newfontfamily\bodyfont
[Path=fonts/,
BoldFont=texgyreheros-bold.otf,
ItalicFont=texgyreheros-italic.otf,
BoldItalicFont=texgyreheros-bolditalic.otf]
{texgyreheros-regular.otf}
\newfontfamily\thinfont[Path=fonts/]{Lato-Hairline.ttf}
\newfontfamily\headingfont[Path=fonts/]{texgyreheros-bold.otf}

\defaultfontfeatures{Mapping=tex-text}
\setmainfont
[Path=fonts/,
Mapping=tex-text, Color=textcolor,
BoldFont=texgyreheros-bold.otf,
ItalicFont=texgyreheros-italic.otf,
BoldItalicFont=texgyreheros-bolditalic.otf
]
{texgyreheros-regular.otf}

\setmathfont[Path=fonts/]{texgyreheros-regular.otf}

%%%%%%%%%%
% Header %
%%%%%%%%%%

\RequirePackage{tikz}
\usetikzlibrary{positioning}

\newcommand{\header}[3]{%
  \begin{tikzpicture}[remember picture,overlay]
    \node [rectangle, fill=fillheader, anchor=north, minimum width=\paperwidth, minimum height=3.5cm] (box) at (current page.north){};
    \node [anchor=west, xshift=1.5cm] (name) at (box.west) {%
      \fontsize{30pt}{36pt}\selectfont\color{header}%
      {\thinfont #1}{\bodyfont  #2}
    };
    \node [anchor=south west, yshift=-0.8cm] (job) at (name.south west) {%
      \fontsize{14pt}{18pt}\selectfont\color{pblue}%
      \bodyfont #3%
    };
    \node [anchor=east, xshift=-1.5cm] (logo) at (box.east)
    {\includegraphics[scale=0.4]{img/logo.png}};
  \end{tikzpicture}
  \vspace{2cm}
  \vspace{-2\parskip}
}

%%%%%%%%%%%%%
% Structure %
%%%%%%%%%%%%%

\RequirePackage{parskip}

\renewcommand{\section}[1]{%
  \par\vspace{\parskip}%
  {\LARGE\headingfont\color{pblue} #1}%
  \par\vspace{\parskip}%
}

% Project entry heading: project name, employer (to cross-reference the CV),
% and a short one-sentence description.
%
% Everything from \projectentry up to the matching \projectsep is first
% captured into a box (not typeset directly), so its exact height is known
% before it's placed on the page. \projectsep then decides how to place it:
%   - if it doesn't fit the remaining space on the current page at all,
%     it starts a fresh page (no divider, since it's the first thing there)
%   - if it fits together with the small divider rule above it (and this
%     isn't the very first project, and we're not already at the very top
%     of the page), the divider is drawn and the project follows right
%     after it on the same page
%   - otherwise (e.g. it's the first project, or we're at the top of a
%     fresh page already) it's placed without a leading divider
% This avoids ever showing the divider rule stranded alone at the very
% top or bottom of a page.
\newsavebox{\pr@box}
\newif\ifpr@needdivider
\pr@needdividerfalse
\newdimen\pr@boxht
\newdimen\pr@avail
\newdimen\pr@dividerht
\pr@dividerht=1.6\baselineskip

\newcommand{\projectentry}[3]{%
  \begin{lrbox}{\pr@box}%
  \begin{minipage}[t]{\textwidth}%
  {\Large\headingfont\color{headercolor} #1}\\[1pt]%
  {\footnotesize\color{lightgray} @ #2}\\[3pt]%
  {\normalsize\itshape\color{pblue} #3}%
  \par\vspace{0.25\baselineskip}%
}

% Small bold colored label used above a tech stack / bullet list,
% e.g. \reflabel{Tech-Stack}, \reflabel{Highlights}.
\newcommand{\reflabel}[1]{%
  \par\vspace{0.2\baselineskip}%
  {\headingfont\color{pblue} #1}%
  \par\vspace{0.1\baselineskip}%
}

% Closes the box opened by \projectentry and places it on the page,
% drawing a divider above it only if it lands right after another
% project on the same page (see the comment above \projectentry).
\newcommand{\projectsep}{%
  \end{minipage}%
  \end{lrbox}%
  \pr@boxht=\ht\pr@box \advance\pr@boxht by \dp\pr@box
  \pr@avail=\pagegoal \advance\pr@avail by -\pagetotal
  \par
  \ifpr@needdivider
    \ifdim\pagetotal=0pt
      % Fresh page (previous project didn't fit and was pushed here) - no divider.
      \usebox{\pr@box}%
    \else
      \advance\pr@boxht by \pr@dividerht
      \ifdim\pr@boxht<\pr@avail
        \vspace{0.6\baselineskip}{\color{lightgray}\hrule}\vspace{0.6\baselineskip}%
        \usebox{\pr@box}%
      \else
        \advance\pr@boxht by -\pr@dividerht
        \ifdim\pr@boxht<\pr@avail
          \usebox{\pr@box}%
        \else
          \newpage
          \usebox{\pr@box}%
        \fi
      \fi
    \fi
  \else
    \ifdim\pr@boxht<\pr@avail
      \usebox{\pr@box}%
    \else
      \newpage
      \usebox{\pr@box}%
    \fi
  \fi
  \pr@needdividertrue
  \par\vspace{0.6\baselineskip}%
}

\pagestyle{empty}

%%%%%%%%%%%%%%%
% Tech badges %
%%%%%%%%%%%%%%%

% Renders a single technology as a small rounded, colored "chip"/badge.
\newcommand{\techbadge}[1]{%
  \tikz[baseline=(TB.base)]{\node[fill=pblue, text=white, rounded corners=2pt, inner sep=3pt, font=\bodyfont\small] (TB) {#1};}%
}

% Renders a comma-separated list of technologies as a row of badges,
% e.g. \techstack{Java, Spring Boot, Kafka, PostgreSQL, Docker, AWS}
%
% The badges are rigid boxes (tikz pictures), which don't have any
% stretch/shrink of their own. In fully-justified (default) paragraphs,
% LaTeX sometimes still forces one more badge onto a line even if it just
% barely doesn't fit, producing an "Overfull \hbox" that visibly runs past
% the page margin instead of wrapping to the next line. Setting this list
% ragged-right (via \raggedright, scoped locally) gives the line-breaker
% effectively infinite shrink at the end of each line, so it always simply
% wraps to a new line instead of ever overflowing.
\newcommand{\techstack}[1]{%
  \begingroup\raggedright
  \foreach \tech in {#1} {\techbadge{\tech}\hspace{3pt plus 2pt minus 1pt}}%
  \par\endgroup
}

%%%%%%%%%%%%%%%%%%%%
% Page geometry    %
%%%%%%%%%%%%%%%%%%%%

\RequirePackage[left=2cm,top=2cm,right=2cm,bottom=2.5cm,nohead,nofoot]{geometry}
\RequirePackage{hyperref}
