module PandocHelpers
  class << self
    def insert_metadata html
      binding.pry
      html.css('div')
      html.css('div')[0]
    end

    def prep_for_pandoc html
      # html = self.insert_metadata(html)

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