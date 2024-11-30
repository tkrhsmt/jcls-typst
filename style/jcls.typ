// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% //
//                      jcls                          //
// version 1.0                                        //
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% //

// import equate package
#import "@preview/equate:0.2.1": equate

// setting font
#let gothic = ("Harano Aji Gothic")
#let mincho = ("Harano Aji Mincho")
#let english = ("CMU Serif")
#let mathf = ("Latin Modern Math")
#let rawf = ("Noto Mono for Powerline")

//setting font size
#let textfontsize = 9.25pt

//setting now date
#let nowdate = {
  [#datetime.today().year()年#datetime.today().month()月#datetime.today().day()日]
}

// ================================================== //
//          Japanese class initial setting            //
// ================================================== //
#let jcls_init(body) = {
  // setting japanese language
  set text(lang: "ja")
  // setting page size
  set page(
    paper:"a4",
    margin: (left: 25mm, right: 25mm, top: 30mm, bottom: 30mm),
    numbering: "1",
    number-align: center,
  )
  // setting normal font
  set text(font: (english, mincho), size: textfontsize, cjk-latin-spacing: auto, weight: 250)
  // setting line spacing
  set par(leading: textfontsize)
  // setting equation font
  show math.equation: set text(font: mathf)
  // setting heading
  set heading(numbering: "1.1")
  show heading: it => [
    #set par(first-line-indent: 0em)
    #v(10pt)
    #set text(font: gothic, weight: "regular")
    #if counter(heading).display() != "0" and it.numbering != none {
      counter(heading).display(it.numbering)
    }
    #h(10pt)
    #it.body
    #v(10pt)
  ]
  // setting paragraph indent
  set par(first-line-indent: 1em)
  // setting equation numbering
  show math.equation: set block(spacing: 1em)
  set math.equation(numbering: "(1)")
  show heading.where(level: 1): it => {
    counter(math.equation).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    it
  }
  set math.equation(numbering: num =>
    "(" + (str(counter(heading).get().at(0)) + "." + str(num)) + ")"
  )
  // setting figure numbering
  set figure(numbering: num =>
    str(counter(heading).get().at(0)) + "." + str(num)
  )
  set figure.caption(separator: [ ])
  // setting list (author: tinger)
  set list(indent: 1.5em)
  // setting chapter
  // emulate element function by creating show rule
  show figure.where(kind: "chapter"): it => {
    set par(first-line-indent: 0pt)
    set text(1.5em, font: gothic, weight: "regular")
    align(left)[
      //#counter(heading).update(0)
      第
      #if it.numbering != none {
        it.counter.display(it.numbering)
      }
      部
      #v(0.25em)
      #text(1.25em, font: gothic, weight: "regular", it.body)
    ]

  }
  // no access to element in outline(indent: it => ...), so we must do indentation in here instead of outline
  show outline.entry: it => {
    if it.element.func() == figure {
      // we're configuring chapter printing here, effectively recreating the default show impl with slight tweaks
      let res = link(it.element.location(),
        // we must recreate part of the show rule from above once again
        if it.element.numbering != none {
          text(font: gothic, size: 1em, weight: "regular", "第")
          text(font: gothic, size: 1em, weight: "regular", numbering(it.element.numbering, ..it.element.counter.at(it.element.location())))
          text(font: gothic, size: 1em, weight: "regular", "部")
        } + h(1em) + text(font: gothic, size: 1em, weight: "regular", it.element.body)
      )

      res += h(1fr)

      res += link(it.element.location(), it.page)
      text(font: gothic, size: 1.2em, weight: "regular", res)
    } else {
      // we're doing indenting here
      h(1em * it.level) + it
    }
  }
  // an example of a "show rule" for a chapter
  // can't use chapter because it's not an element after using .with() anymore
  show figure.where(kind: "chapter"): set text(black)
  // setting raw
  show raw.where(block: true): it => {
      set table(stroke: (x, y) => (
        left: if x == 1 { 0.25pt } else { 0pt },
        right: if x == 1 { 0.25pt } else { 0pt },
        top: if y == 0 and x == 1{ 0.25pt } else { 0pt },
        bottom: if x == 1 { 0.25pt } else { 0pt },
      ))
      table(
        columns: (5%, 95%),
        align: (right, left),
        ..for value in it.lines {
          (text(fill: luma(60%),str(value.number)), value)
        }
      )
  }
  show raw.where(block: false): it =>{
    h(0.5em)
    box(fill: luma(240), inset: (x: 0.5em, y: 0pt), outset: (y: 0.5em), radius: 2pt, it)
    h(0.5em)
  }
  set table(
    stroke: (top: 0.5pt + black, bottom: 0.5pt + black, right: 0.5pt + black, left: 0.5pt + black),
    align: (x, y) => (
      //if x > 0 { center }
      //else { left }
      center
    )
  )
  // setting figure caption
  show figure.where(// if figure kind is table ...
    kind: table
  ): set figure.caption(position: top)
  show figure.caption: it => {// if figure caption is image ...
    v(0.5em)
    grid(
      columns: 2,
      align(top)[#it.supplement #it.counter.display() #h(1em)],
      align(left)[#it.body]
    )
  }


  body
}


// --------------------------------------------------
// author: tinger
#let chapter = figure.with(
  kind: "chapter",
  // same as heading
  numbering: none,
  // this cannot use auto to translate this automatically as headings can, auto also means something different for figures
  supplement: [chapter],
  // empty caption required to be included in outline
  caption: "",
)

// new target selector for default outline
#let chapters-and-headings = figure.where(kind: "chapter", outlined: true).or(heading.where(outlined: true))

// can't use set, so we reassign with default args
#let chapter = chapter.with(numbering: "I")

// --------------------------------------------------

#let maketitle(
  title: "",
  abstract: [],
  keywords: (),
  authors: (),
  date: true ,
  tableofcontents: false,
  body,
) = {
  set document(author: authors.map(a => a.name), title: title)
  // set title
  pad(
    bottom: 4pt,
    top: 2cm,
    align(center)[
      #set text(font: (english, mincho))
      #block(text(1.75em, title))
      #v(1em, weak: true)
    ]
  )
  // set author
  pad(
    top: 1em,
    x: 2em,
    bottom: 1.5em,
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(center)[
        #text(1.2em,[#author.name])
        #if str(author.affiliation) != "" {
          if str(author.email) != ""{
            footnote[#author.affiliation (#author.email)]

          }else{
            footnote[#author.affiliation]
          }
        }else{
          if str(author.email) != ""{
          footnote[#author.email]
          }
        }
      ]),
    ),
  )
  // set date
  if date {
    v(-1em)
    align(center)[#text(1.2em,[#nowdate])]
  }
  // set abstract
  if abstract != "" {

    pad(
      top: 1em,
      x: 3em,
      bottom: 0.4em,
      align(center)[
          #text(1.0em, emph(smallcaps[Abstract]), font: english)
          #set par(justify: true)
          #set text(hyphenate: false)

          #abstract
      ],
    )
  }else{
    v(1.2cm, weak: true)
  }
  // 目次の表示
  if tableofcontents {
    v(0.5cm)
    line(length: 100%, stroke: 0.5pt)
    par(leading: 15pt,
      outline(
        indent: auto,
        fill: box(width: 1fr, repeat(h(2pt) + "." + h(2pt))) + h(8pt),
        target: chapters-and-headings,
        title: [#h(-0.7em) 目次]
        )
      )
    pagebreak()
  }
  body
}

#let latex = {
    set text(font: english)
    box(width: 2.55em, {
      [L]
      place(top, dx: 0.3em, text(size: 0.7em)[A])
      place(top, dx: 0.7em)[T]
      place(top, dx: 1.26em, dy: 0.22em)[E]
      place(top, dx: 1.8em)[X]
    })
}

#let nonumber = <equate:revoke>
