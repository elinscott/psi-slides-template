// PSI theme

// Adapted from the University theme by Pol Dellaiera - https://github.com/drupol

#import "@preview/touying:0.4.2": *

#let slide(
  self: none,
  title: auto,
  subtitle: auto,
  header: auto,
  footer: auto,
  display-current-section: auto,
  ..args,
) = {

  if title != auto {
    self.uni-title = title
  }
  if subtitle != auto {
    self.uni-subtitle = subtitle
  }
  if header != auto {
    self.uni-header = header
  }
  if footer != auto {
    self.uni-footer = footer
  }
  if display-current-section != auto {
    self.uni-display-current-section = display-current-section
  }
  (self.methods.touying-slide)(
    ..args.named(),
    self: self,
    title: title,
    setting: body => {
      show: args.named().at("setting", default: body => body)
      body
    },
    ..args.pos(),
  )
}

#let title-slide(self: none, ..args) = {
  self = utils.empty-page(self, margin: 2em)
  self.page-args += (
    fill: self.colors.primary,
    background: {
      set image(fit: "stretch", width: 100%, height: 100%)
      self.background-image
    },
  )
  let info = self.info + args.named()
  info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else {
      info.author
    }
    if type(authors) == array {
      authors
    } else {
      (authors,)
    }
  }
  let content = {
    align(left, image("media/logos/psi_scd_banner_white.png", height: 10%))
    align(
      horizon,
      {
        block(
          inset: 0em,
          breakable: false,
          {
            text(
              size: 2em,
              fill: self.colors.neutral-lightest,
              strong(info.title),
            )
            if info.subtitle != none {
              linebreak()
              text(
                size: 1.2em,
                fill: self.colors.neutral-lightest,
                strong(info.subtitle),
              )
            }
          },
        )
        set text(size: .8em)
        text(size: .8em, info.author, fill: self.colors.neutral-lightest)
        linebreak()
        if info.location != none {
          text(
            size: .8em,
            info.location + ", ",
            fill: self.colors.neutral-lightest,
          )
        }
        if info.date != none {
          text(
            size: .8em,
            info.date.display("[day padding:none] [month repr:long] [year]"),
            fill: self.colors.neutral-lightest,
          )
        }
      },
    )
  }
  (self.methods.touying-slide)(self: self, repeat: none, content)
}

#let new-section-slide(self: none, short-title: auto, title) = {
  self = utils.empty-page(self, margin: 2em)
  let content(self) = {
    set align(horizon)
    set text(size: 1.5em, fill: self.colors.neutral-lightest, weight: "bold")
    pad(states.current-section-with-numbering(self))
  }

  let footer(self) = {
    block(
      inset: 2em,
      width: 100%,
      text(
        fill: self.colors.neutral-lightest,
        utils.call-or-display(self, self.uni-footer),
      ),
    )
  }

  let header(self) = {
    block(
      inset: 2em,
      width: 100%,
      align(top + right, image("media/logos/psi_white.png", height: 1.2em)),
    )
  }

  self.page-args += (
    fill: self.colors.primary,
    footer: footer,
    header: header,
  )

  (self.methods.touying-slide)(
    self: self,
    repeat: none,
    section: (title: title, short-title: short-title),
    content,
  )
}

#let focus-slide(
  self: none,
  background-color: none,
  background-img: none,
  body,
) = {
  let background-color = if background-img == none and background-color == none {
    rgb(self.colors.primary)
  } else {
    background-color
  }
  self = utils.empty-page(self, margin: 2em)
  self.page-args += (
    fill: self.colors.primary,
    ..(
      if background-color != none {
        (fill: background-color)
      }
    ),
    ..(
      if background-img != none {
        (
          background: {
            set image(fit: "stretch", width: 100%, height: 100%)
            background-img
          },
        )
      }
    ),
  )
  set text(fill: white, size: 2em)
  (self.methods.touying-slide)(self: self, repeat: none, align(horizon, body))
}

#let matrix-slide(
  self: none,
  columns: none,
  rows: none,
  background-color: none,
  gutter: 5pt,
  stroke: none,
  alignment: none,
  title: none,
  ..bodies,
) = {
  self = utils.empty-page(self)

  let footer(self) = {
    block(
      inset: 2em,
      width: 100%,
      text(
        fill: self.colors.neutral,
        utils.call-or-display(self, self.uni-footer),
      ),
    )
  }

  if title == none {
    title = states.current-section-title
  }

  // header
  self.uni-header = self => {
    grid(
      columns: (6fr, 1fr),
      align(
        top + left,
        text(fill: self.colors.primary, weight: "bold", size: 1.2em, title),
      ),
      align(top + right, image("media/logos/psi_black.png", height: 1.2em)),
    )
  }

  let header(self) = {
    block(inset: 2em, width: 100%, utils.call-or-display(self, self.uni-header))
  }

  self.page-args += (
    margin: (top: 4em, bottom: 3em, x: 2em),
    footer: footer,
    header: header,
  )

  (self.methods.touying-slide)(
    self: self,
    composer: (..bodies) => {
      let bodies = bodies.pos()
      let columns = if type(columns) == int {
        (1fr,) * columns
      } else if columns == none {
        (1fr,) * bodies.len()
      } else {
        columns
      }
      let num-cols = columns.len()
      let rows = if type(rows) == int {
        (1fr,) * rows
      } else if rows == none {
        let quotient = calc.quo(bodies.len(), num-cols)
        let correction = if calc.rem(bodies.len(), num-cols) == 0 {
          0
        } else {
          1
        }
        (1fr,) * (quotient + correction)
      } else {
        rows
      }
      let num-rows = rows.len()
      if num-rows * num-cols < bodies.len() {
        panic("number of rows (" + str(num-rows) + ") * number of columns (" + str(num-cols) + ") must at least be number of content arguments (" + str(
          bodies.len(),
        ) + ")")
      }
      let cart-idx(i) = (calc.quo(i, num-cols), calc.rem(i, num-cols))

      let alignment = if alignment == none {
        left + horizon
      } else {
        alignment
      }

      let color-body(idx-body) = {
        let (idx, body) = idx-body
        let (row, col) = cart-idx(idx)
        let color = if calc.even(row + col) {
          white
        } else {
          background-color
        }
        set align(alignment)
        rect(
          inset: .5em,
          width: 100%,
          height: 100%,
          fill: color,
          stroke: stroke,
          body,
        )
      }
      let content = grid(
        columns: columns, rows: rows,
        gutter: gutter,
        ..bodies.enumerate().map(color-body)
      )
      content
    },
    ..bodies,
  )
}

#let slides(self: none, title-slide: true, slide-level: 1, ..args) = {
  set text(font: "Arial")
  if title-slide {
    (self.methods.title-slide)(self: self)
  }
  (self.methods.touying-slides)(self: self, slide-level: slide-level, ..args)
}

#let register(
  self: themes.default.register(),
  aspect-ratio: "16-9",
  progress-bar: false,
  color-scheme: "blue-green",
  display-current-section: false,
  footer-columns: (5%, 1fr, 15%),
  footer-a: self => states.slide-counter.display(),
  footer-b: self => if self.info.short-title == auto {
    self.info.title
  } else {
    self.info.short-title
  },
  footer-c: self => self.info.date.display("[day padding:none] [month repr:long] [year]"),
  ..args,
) = {

  // save the variables for later use
  self.uni-enable-progress-bar = progress-bar
  self.uni-progress-bar = self => states.touying-progress(ratio => {
    grid(
      columns: (ratio * 100%, 1fr),
      rows: 2pt,
      components.cell(fill: self.colors.primary),
      components.cell(fill: self.colors.secondary),
    )
  })
  self.uni-display-current-section = display-current-section
  self.uni-title = none
  self.uni-subtitle = none

  // footer
  self.uni-footer = self => {
    set text(size: .6em)

    grid(
      columns: footer-columns,
      align: (left + bottom, left + bottom, right + bottom),
      utils.call-or-display(self, footer-a),
      utils.call-or-display(self, footer-b),
      utils.call-or-display(self, footer-c),
    )
  }

  // header
  self.uni-header = self => {
    if self.uni-title != none {
      grid(
        columns: (6fr, 1fr),
        align(
          top + left,
          text(
            fill: self.colors.primary,
            weight: "bold",
            size: 1.2em,
            self.uni-title,
          ),
        ),
        align(top + right, image("media/logos/psi_black.png", height: 1.2em)),
      )
    } else {
      grid(
        columns: (1fr),
        align(top + right, image("media/logos/psi_black.png", height: 1.2em))
      )
    }
  }

  // set page
  let header(self) = {
    block(inset: 2em, width: 100%, utils.call-or-display(self, self.uni-header))
  }

  let footer(self) = {
    block(
      inset: 2em,
      width: 100%,
      text(
        fill: self.colors.neutral,
        utils.call-or-display(self, self.uni-footer),
      ),
    )
  }

  self.page-args += (
    paper: "presentation-" + aspect-ratio,
    header: header,
    footer: footer,
    header-ascent: 0em,
    footer-descent: 0em,
    margin: (top: 4em, bottom: 3em, x: 2em),
  )
  // register methods
  self.methods.slide = slide
  self.methods.title-slide = title-slide
  self.methods.new-section-slide = new-section-slide
  self.methods.touying-new-section-slide = new-section-slide
  self.methods.focus-slide = focus-slide
  self.methods.matrix-slide = matrix-slide
  self.methods.slides = slides
  self.methods.touying-outline = (self: none, enum-args: (:), ..args) => {
    states.touying-outline(
      self: self,
      enum-args: (tight: false) + enum-args,
      ..args,
    )
  }
  self.methods.alert = (self: none, it) => text(fill: self.colors.primary, it)
  self.methods.init = (self: none, body) => {
    set text(size: 20pt)
    set heading(outlined: false)
    show footnote.entry: set text(size: .6em, fill: self.colors.neutral)
    set footnote.entry(separator: none, indent: 0em)
    set bibliography(title: none, style: "nature-footnote.csl")
    body
  }


  // color theme
  self.colors += (
    neutral: rgb("#808080"),
    neutral-light: rgb("#aaaaaa"),
    neutral-lighter: rgb("#d5d5d5"),
    neutral-lightest: rgb("#ffffff"),
    neutral-dark: rgb("#555555"),
    neutral-darker: rgb("#2b2b2b"),
    neutral-darkest: rgb("#000000"),
  )
  if color-scheme == "blue-green" {
    self.colors += (
      primary: rgb("#0014e6"),
      secondary: rgb("#00f0a0"),
      tertiary: rgb("#000000"),
    )
    self.background-image = image("media/backgrounds/blue-green.png")
  } else if color-scheme == "pink-yellow" {
    self.colors += (
      primary: rgb("#dc005a"),
      secondary: rgb("#f0f500"),
      tertiary: rgb("#000000"),
    )
    self.background-image = image("media/backgrounds/pink-yellow.png")
  } else if color-scheme == "navy-red" {
    self.colors += (
      primary: rgb("#000073"),
      secondary: rgb("#dc005a"),
      tertiary: rgb("#000000"),
    )
    self.background-image = image("media/backgrounds/navy-red.png")
  } else {
    panic("color-scheme " + color-scheme + " not supported (must be blue-green/pink-yellow/navy-red)")
  }

  self.freeze-in-empty-page = false

  self
}
