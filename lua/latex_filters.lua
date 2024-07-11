function raw_tex_inline (t)
  return pandoc.RawInline('tex', t)
end

function raw_tex_block (t)
  return pandoc.RawBlock('tex', t)
end

--- Wrap code blocks in tcolorbox environments
function CodeBlock (cb)
  return {raw_tex_block '\\begin{tcolorbox}[enhanced jigsaw,left=17pt,breakable,colback=white!97.2549!black,boxrule=0.2mm]', cb, raw_tex_block '\\end{tcolorbox}'}
end

--- Add left border on blockquotes
function BlockQuote (bq)
    return {
        raw_tex_block '\\begin{tcolorbox}[enhanced jigsaw,breakable,drop shadow,breakable,arc=0pt,outer arc=0pt,grow to left by=-1cm,enlarge top by=0.1cm,enlarge bottom by=0.1cm,boxrule=0.2mm]',
        bq,
        raw_tex_block '\\end{tcolorbox}'
    }
end

function Code(c)
    return {
        raw_tex_inline '\\hl{\\mbox{',
        c,
        raw_tex_inline '}}'
    }
end
