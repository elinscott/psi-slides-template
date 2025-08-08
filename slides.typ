#import "touying/lib.typ": *
#import "@preview/pinit:0.1.4": *
#import "@preview/xarrow:0.3.0": xarrow
#import "@preview/cetz:0.3.3"
#import "psi-slides-0.6.1.typ": *

// color-scheme can be navy-red, blue-green, or pink-yellow
// #let s = psi-slides.register(aspect-ratio: "16-9", color-scheme: "pink-yellow")
#show: psi-theme.with(aspect-ratio: "16-9",
                      color-scheme: "pink-yellow",
                             config-info(
                                title: [Title],
                                subtitle: [Subtitle],
                                author: [Edward Linscott],
                                date: datetime(year: 2025, month: 1, day: 1),
                                location: [Location],
                                references: [references.bib],
                             ))

#set footnote.entry(clearance: 0em)
#show bibliography: set text(0.6em)

#title-slide()

== Outline
Text

= Introduction

== Subsection

#par(justify: true)[#lorem(200)]

#focus-slide()[Here is a focus slide presenting a key idea]

#matrix-slide()[
  This is a matrix slide
][
  You can use it to present information side-by-side
][
  with an arbitrary number of rows and columns
]

More text appears under the same subsection title as earlier

== New Subsection
But a new subsection starts a new page.

Now, let's cite a nice paper.@Linscott2023

== References
#bibliography("references.bib")
