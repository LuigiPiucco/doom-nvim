-- This is a custom lua reader for pandoc, meant to turn our
-- lua source code into markdown that can be fed into
-- https://github.com/kdheepak/panvimdoc.
-- !! Requires recent pandoc !!

local pandoc = pandoc

local P, S, R, Cf, Cc, Ct, V, Cs, Cg, Cb, B, C, Cmt =
  lpeg.P, lpeg.S, lpeg.R, lpeg.Cf, lpeg.Cc, lpeg.Ct, lpeg.V,
  lpeg.Cs, lpeg.Cg, lpeg.Cb, lpeg.B, lpeg.C, lpeg.Cmt

local function flatten(list)
  local ret = {}
  for _, elem in ipairs(list) do
    if type(elem) == "table" then
      local sub = flatten(elem)
      for _,subelem in ipairs(sub) do
        table.insert(ret, subelem)
      end
    else
      table.insert(ret, elem)
    end
  end
  return ret
end
local function make_tag_block(paragraphs, tag_type, field_name, code_block)
  if tag_type ~= "class" then
    if type(field_name) == "string" then
      table.insert(paragraphs, 1,
        pandoc.Header(4, field_name)
      )
    elseif not code_block then
      code_block = field_name
    end
  end
  if code_block then
    table.insert(paragraphs, code_block)
  end
  return paragraphs
end
local function make_code_block(code)
  return pandoc.CodeBlock(code, { class = "lua" })
end
local function make_read(type)
    return function(text)
      local blocks = pandoc.read(table.concat(text, "\n"), type).blocks
      return table.unpack(blocks)
    end
end

local whitespace_char = S(" \t\r\n")
local word_char = (1 - whitespace_char)
local space_char = P(" ")
local new_line = P"\r"^-1 * P"\n"
-- Use triple dashes with optionaly some spaces,
-- EmmyLua compatible.
local doc_comment_start = P"---" * space_char^0
local empty_doc_comment = doc_comment_start * new_line
local tag = P"@" * C(word_char^1)
local tag_line = doc_comment_start
               * tag
               * space_char
               * C(word_char^1)
               * (space_char * word_char^1)^-1

local G = P{
  "Pandoc",
  -- Top-level document.
  Pandoc = Ct(V"Header"^0) / flatten / pandoc.Pandoc;
  -- A block of markdown (various single line comments).
  -- We reuse pandoc's own parser here, so this is very featureful
  -- markdown.
  Block = (Ct( ( doc_comment_start
               * C((1 - (tag + new_line))^1)
               * new_line
               - empty_doc_comment
               )^1
               * empty_doc_comment^0
             )
          / make_read("markdown")
          );
  -- A relevant piece of code (basically some regular code after a comment).
  -- This is useful to show defaults, if you don't place a blank line after
  -- the triple comment it will show the code until the next blank line.
  CodeBlock = C((1 - (doc_comment_start + new_line^2))^1)
            / make_code_block;
  -- The meat of the parser, this matches a tag line with an optional
  -- prepended description (and corrects the order), turns the field name into
  -- a 4th level heading and optionaly adds code after the comment.
  Header = ( tag_line
           + Ct(V"Block"^1) * tag_line^-1
           )
         * V"CodeBlock"^-1
         * (1 - (tag_line + V"Block"))^0
         / make_tag_block;
}

function Reader(input)
  return lpeg.match(G, tostring(input))
end
