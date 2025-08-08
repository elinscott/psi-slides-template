// University theme

// Originally contributed by Pol Dellaiera - https://github.com/drupol

#import "touying/lib.typ": *

/// Default slide function for the presentation.
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - repeat (int, auto): is the number of subslides. The default is `auto`, allowing touying to automatically calculate the number of subslides. The `repeat` argument is required when using `#slide(repeat: 3, self => [ .. ])` style code to create a slide, as touying cannot automatically detect callback-style `uncover` and `only`.
///
/// - setting (dictionary): is the setting of the slide, which can be used to apply set/show rules for the slide.
///
/// - composer (array, function): is the layout composer of the slide, allowing you to define the slide layout.
///
///   For example, `#slide(composer: (1fr, 2fr, 1fr))[A][B][C]` to split the slide into three parts. The first and the last parts will take 1/4 of the slide, and the second part will take 1/2 of the slide.
///
///   If you pass a non-function value like `(1fr, 2fr, 1fr)`, it will be assumed to be the first argument of the `components.side-by-side` function.
///
///   The `components.side-by-side` function is a simple wrapper of the `grid` function. It means you can use the `grid.cell(colspan: 2, ..)` to make the cell take 2 columns.
///
///   For example, `#slide(composer: 2)[A][B][#grid.cell(colspan: 2)[Footer]]` will make the `Footer` cell take 2 columns.
///
///   If you want to customize the composer, you can pass a function to the `composer` argument. The function should receive the contents of the slide and return the content of the slide, like `#slide(composer: grid.with(columns: 2))[A][B]`.
///
/// - bodies (arguments): is the contents of the slide. You can call the `slide` function with syntax like `#slide[A][B][C]` to create a slide.
/// 
#let default-footer(self, fill: black) = {
  set text(size: .5em)
  {
    let cell(..args, it) = components.cell(
      ..args,
      text(fill: fill, it),
    )
    show: block.with(width: 100%, height: auto, inset: 2em)
    grid(
      columns: self.store.footer-columns,
      align: (left, center, right),
      cell(utils.call-or-display(self, self.store.footer-a)),
      cell(utils.call-or-display(self, self.store.footer-b)),
      cell(utils.call-or-display(self, self.store.footer-c)),
    )
  }
}

// #let default-header(self, black-logo: true, display-header-text: true) = {
//   set std.align(top)
//   if not black-logo {
//     logo-image = "media/logos/psi_white.png"
//   }
// 
//   if display-header-text {
//     grid(
//       columns: (5fr, 2fr),
//       align: (left + horizon, right + horizon),
//       inset: 1em,
//       text(
//         fill: self.colors.primary,
//         weight: "bold",
//         size: 1.1cm,
//         utils.call-or-display(self, self.store.header),
//       ),
//       image("media/logos/psi_black.png", height: 1.1cm),
//     )
//   }
// }

#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  align: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto {
    self.store.align = align
  }

  let header(self) = {
    set std.align(top)
    grid(
      columns: (5fr, 1fr),
      align: (left + horizon, right + horizon),
      inset: 1em,
      text(
        fill: self.colors.primary,
        weight: "bold",
        size: 1.1cm,
        utils.call-or-display(self, self.store.header),
      ),
      image("media/logos/psi_black.png", height: 1.1cm),
    )
  }

  let self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: default-footer,
    ),
  )
  let new-setting = body => {
    show: std.align.with(self.store.align)
    show: setting
    body
  }
  touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: composer, ..bodies)
})


/// Title slide for the presentation. You should update the information in the `config-info` function. You can also pass the information directly to the `title-slide` function.
///
/// Example:
///
/// ```typst
/// #show: university-theme.with(
///   config-info(
///     title: [Title],
///     logo: emoji.school,
///   ),
/// )
///
/// #title-slide(subtitle: [Subtitle])
/// ```
/// 
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - extra (string, none): is the extra information for the slide. This can be passed to the `title-slide` function to display additional information on the title slide.
#let title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(
      background: {
        set image(fit: "stretch", width: 100%, height: 100%)
        self.store.background-image
      }
    ),
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
  let body = {
    align(left, image("media/logos/psi_scd_banner_white.png", height: 12.5%))
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
              weight: "bold",
              info.title,
            )
            if info.subtitle != none {
              linebreak()
              text(
                size: 1.2em,
                fill: self.colors.neutral-lightest,
                weight: "bold",
                info.subtitle,
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
  touying-slide(self: self, body)
})

/// New section slide for the presentation. You can update it by updating the `new-section-slide-fn` argument for `config-common` function.
///
/// Example: `config-common(new-section-slide-fn: new-section-slide.with(numbered: false))`
///
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
/// 
/// - level (int, none): is the level of the heading.
///
/// - numbered (boolean): is whether the heading is numbered.
///
/// - body (auto): is the body of the section. This will be passed automatically by Touying.
#let new-section-slide(config: (:), level: 1, numbered: true, body) = touying-slide-wrapper(self => {


  let header(self) = {
    set std.align(top)
    grid(
      columns: (1fr),
      align: (right + horizon),
      inset: 1em,
      image("media/logos/psi_white.png", height: 1.1cm),
    )
  }

  let footer(self) = default-footer(self, fill: self.colors.neutral-lightest)

  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.primary, header: header, footer: footer),
  )

  let slide-body = {
    set std.align(horizon + left)
    stack(
    text(fill: self.colors.neutral-lightest, weight: "bold", size: 2.5em, utils.display-current-heading(level: level, numbered: numbered))
    )
    body
  }
  touying-slide(self: self, config: config, slide-body)
})

/// Focus on some content.
///
/// Example: `#focus-slide[Wake up!]`
/// 
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
///
/// - background-color (color, none): is the background color of the slide. Default is the primary color.
///
/// - background-img (string, none): is the background image of the slide. Default is none.
#let focus-slide(config: (:), background-color: none, background-img: none, body) = touying-slide-wrapper(self => {
  let background-color = if background-img == none and background-color == none {
    rgb(self.colors.primary)
  } else {
    background-color
  }
  let args = (:)
  if background-color != none {
    args.fill = background-color
  }
  if background-img != none {
    args.background = {
      set image(fit: "stretch", width: 100%, height: 100%)
      background-img
    }
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 1em, ..args),
  )
  set text(fill: self.colors.neutral-lightest, weight: "bold", size: 2em)
  touying-slide(self: self, std.align(horizon, body))
})


// Create a slide where the provided content blocks are displayed in a grid and coloured in a checkerboard pattern without further decoration. You can configure the grid using the rows and `columns` keyword arguments (both default to none). It is determined in the following way:
///
/// - If `columns` is an integer, create that many columns of width `1fr`.
/// - If `columns` is `none`, create as many columns of width `1fr` as there are content blocks.
/// - Otherwise assume that `columns` is an array of widths already, use that.
/// - If `rows` is an integer, create that many rows of height `1fr`.
/// - If `rows` is `none`, create that many rows of height `1fr` as are needed given the number of co/ -ntent blocks and columns.
/// - Otherwise assume that `rows` is an array of heights already, use that.
/// - Check that there are enough rows and columns to fit in all the content blocks.
///
/// That means that `#matrix-slide[...][...]` stacks horizontally and `#matrix-slide(columns: 1)[...][...]` stacks vertically.
/// 
/// - config (dictionary): is the configuration of the slide. Use `config-xxx` to set individual configurations for the slide. To apply multiple configurations, use `utils.merge-dicts` to combine them.
#let matrix-slide(config: (:), columns: none, rows: none, alignment: center + horizon, primary: white, secondary: white, ..bodies) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
  )
  touying-slide(self: self, config: config, composer: components.checkerboard.with(columns: columns, rows: rows, alignment: alignment, primary: primary, secondary: secondary), ..bodies)
})


/// Touying university theme.
///
/// Example:
///
/// ```typst
/// #show: university-theme.with(aspect-ratio: "16-9", config-colors(primary: blue))`
/// ```
///
/// The default colors:
///
/// ```typ
/// config-colors(
///   primary: rgb("#04364A"),
///   secondary: rgb("#176B87"),
///   tertiary: rgb("#448C95"),
///   neutral-lightest: rgb("#ffffff"),
///   neutral-darkest: rgb("#000000"),
/// )
/// ```
///
/// - aspect-ratio (string): is the aspect ratio of the slides. Default is `16-9`.
/// 
/// - align (alignment): is the alignment of the slides. Default is `top`.
///
/// - progress-bar (boolean): is whether to show the progress bar. Default is `true`.
///
/// - header (content, function): is the header of the slides. Default is `utils.display-current-heading(level: 2)`.
///
/// - header-right (content, function): is the right part of the header. Default is `self.info.logo`.
///
/// - footer-columns (tuple): is the columns of the footer. Default is `(25%, 1fr, 25%)`.
///
/// - footer-a (content, function): is the left part of the footer. Default is `self.info.author`.
///
/// - footer-b (content, function): is the middle part of the footer. Default is `self.info.short-title` or `self.info.title`.
///
/// - footer-c (content, function): is the right part of the footer. Default is `self => h(1fr) + utils.display-info-date(self) + h(1fr) + context utils.slide-counter.display() + " / " + utils.last-slide-number + h(1fr)`.
#let psi-theme(
  aspect-ratio: "16-9",
  align: top,
  progress-bar: false,
  color-scheme: "pink-yellow",
  header: utils.display-current-heading(level: 2, style: auto),
  header-right: self => box(utils.display-current-heading(level: 1)) + h(.3em) + self.info.logo,
  footer-columns: (5%, 1fr, 15%),
  footer-a: self => {context utils.slide-counter.display()},
  footer-b: self => if self.info.subtitle == none {
    self.info.title
  } else {
    self.info.title + ": " + self.info.subtitle
  },
  footer-c: self => {
    self.info.date.display("[day padding:none] [month repr:long] [year]")
  },
  ..args,
  body,
) = {

  set text(font: "arial", size: 20pt)
  set bibliography(title: none, style: "nature-footnote.csl")
  show footnote.entry: set text(size: 0.6em, fill: rgb("#888888"))
  set footnote.entry(separator: none, indent: 0em)

  let primary = rgb("#dc005a")
  let secondary = rgb("#f0f500")
  let background-image = image("media/backgrounds/pink-yellow.png")
  if color-scheme == "pink-yellow" {
  } else if color-scheme == "blue-green" {
    primary = rgb("#0014e6")
    secondary = rgb("#00f0a0")
    background-image = image("media/backgrounds/blue-green.png")
  } else if color-scheme == "navy-red" {
    primary = rgb("#000073")
    secondary = rgb("#dc005a")
    background-image = image("media/backgrounds/navy-red.png")
  } else {
    panic("color scheme " + color-scheme + " not supported (must be blue-green/pink-yellow/navy-red)")
  }

  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 3em, bottom: 2em, x: 1em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(size: 20pt)
        show heading.where(level: 3): set text(fill: self.colors.primary)
        show heading.where(level: 4): set text(fill: self.colors.primary)

        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      scheme: color-scheme,
      primary: primary,
      secondary: secondary,
      tertiary: rgb("#000000"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    // save the variables for later use
    config-store(
      background-image: background-image,
      align: align,
      progress-bar: progress-bar,
      header: header,
      header-right: header-right,
      footer-columns: footer-columns,
      footer-a: footer-a,
      footer-b: footer-b,
      footer-c: footer-c,
    ),
    ..args,
  )

  body
}
