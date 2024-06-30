function raw_tex (t)
  return pandoc.RawBlock('tex', t)
end

--- Wrap code blocks in tcolorbox environments
function CodeBlock (cb)
  return {raw_tex '\\begin{tcolorbox}[enhanced jigsaw,breakable]', cb, raw_tex '\\end{tcolorbox}'}
end

--- Add left border on blockquotes
function BlockQuote (bq)
    return {
        raw_tex '\\begin{tcolorbox}[enhanced jigsaw,breakable,drop shadow,breakable,arc=0pt,outer arc=0pt,grow to left by=-1cm,enlarge top by=0.1cm,enlarge bottom by=0.1cm]',
        bq,
        raw_tex '\\end{tcolorbox}'
    }
end

