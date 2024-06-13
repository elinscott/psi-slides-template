#import "@preview/touying:0.4.2": *
#import "psi.typ"

// color-scheme can be navy-red, blue-green, or pink-yellow
#let s = psi.register(aspect-ratio: "16-9", color-scheme: "pink-yellow")

#let s = (s.methods.info)(
  self: s,
  title: [Title],
  subtitle: [Subtitle],
  author: [Edward Linscott],
  date: datetime(year: 2024, month: 1, day: 1),
  location: [Location]
)

#let (init, slides) = utils.methods(s)
#show: init

#let (slide, empty-slide, title-slide, new-section-slide, focus-slide, matrix-slide) = utils.slides(s)
#show: slides

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
But a new subsection starts a new page