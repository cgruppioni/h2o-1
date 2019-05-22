module HTMLHelpers
  class << self
    BLOCK_LEVEL_ELEMENTS = [
      "ADDRESS",
      "ARTICLE",
      "ASIDE",
      "BLOCKQUOTE",
      "DETAILS",
      "DIALOG",
      "DD",
      "DIV",
      "DL",
      "DT",
      "FIELDSET",
      "FIGCAPTION",
      "FIGURE",
      "FOOTER",
      "FORM",
      "H1",
      "H2",
      "H3",
      "H4",
      "H5",
      "H6",
      "HEADER",
      "HGROUP",
      "HR",
      "LI",
      "MAIN",
      "NAV",
      "OL",
      "P",
      "PRE",
      "SECTION",
      "TABLE",
      "UL"
    ]

    def parse_html_string html
      Nokogiri::HTML(html) {|config| config.strict.noblanks}
    end

    def strip_comments! html
      html.xpath('//comment()').remove
      html
    end

    def unnest! html
      html
        .xpath('//article | //section | //aside')
        .each { |el| el.replace el.children }
      html
    end

    def empty_ul_to_p! html
      html
        .xpath('//body/ul[not(*[li])]')
        .each { |list| list.replace "<p>#{list.inner_html}</p>" }
      html
    end

    def wrap_bare_inline_tags! html
      html
        .xpath("//body/*[not(self::center|self::#{BLOCK_LEVEL_ELEMENTS.map(&:downcase).join('|self::')})]")
        .each { |inline_element| inline_element.replace "<p>#{inline_element.to_html}</p>" }
      html
    end

    def get_body_nodes_without_whitespace_text html
      html.xpath "//body/node()[not(self::text()) and not(self::text()[1])]"
    end

    def filter_empty_nodes! nodes
      nodes.each do |node|
        if ! node.nil? && node.children.empty?
          nodes.delete(node)
        end
      end
      nodes
    end

    def process_nodes nodes
      [method(:strip_comments!),
       method(:unnest!),
       method(:empty_ul_to_p!),
       method(:wrap_bare_inline_tags!),
       method(:get_body_nodes_without_whitespace_text),
       method(:filter_empty_nodes!)].reduce(nodes) { |memo, fn| fn.call(memo) }
    end

    def parse_and_process_nodes html_string
      process_nodes(parse_html_string(html_string))
    end

    def prep_for_pandoc html

      # Case Header styling
      html.css(
          # 'section.head-matter p',
          # 'section.head-matter h4',
          'center',
          'p[style="text-align:center"]',
          'p[align="center"]',
          ).each do | p |
        p.wrap("<div data-custom-style='Case Header'></div>")
      end

      # Note and Link annotations
      html.css('span[msword-style="FootnoteReference"]').each do | s |
        s.set_attribute('custom-style', 'Footnote Reference')
        s.delete('msword-style')
      end

      # Elision annotations
      html.css('span.annotate.elided').each do | s |
        if s['class'].include? 'head'
          s.inner_html = '[ … ]'
          s.set_attribute('custom-style', 'Elision')
        else
          s.remove
        end
      end

      # Replacement annotations
      html.css('span.annotate.replaced').each do | s |
        s.remove
      end
      html.css('span[msword-style="ReplacementText"]').each do | s |
        s.set_attribute('custom-style', 'Replacement Text')
        s.delete('msword-style')
      end

      html
    end
  end
end
