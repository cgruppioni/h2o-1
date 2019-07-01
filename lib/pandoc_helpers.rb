module PandocHelpers
  class << self
    def insert_metadata nodes, resource
      ordinals = resource.ordinals.delete "]" 
      ordinals = ordinals.delete "["
      new_html =  "<div class='ResourceNumber' data-custom-style='Resource Number'>#{ordinals}</div><div class='ResourceTitle' data-custom-style='Resource Title'>#{resource.title}</div><div class='ResourceHeadnote' data-custom-style='Resource Headnote'><p>#{resource.headnote}</p></div>"
       # nodes.children[0].children[1].children[0].add_previous_sibling new_html
       binding.pry
       nodes.children.css('div')[0].add_previous_sibling new_html
       return nodes
    end

    def prep_for_pandoc nodes, resource
      nodes = self.insert_metadata nodes, resource

      # Case Header styling
      nodes.css(
          # 'section.head-matter p',
          # 'section.head-matter h4',
          'center',
          'p[style="text-align:center"]',
          'p[align="center"]',
          ).each do | p |
        p.wrap("<div data-custom-style='Case Header'></div>")
      end

      # Note and Link annotations
      nodes.css('span[msword-style="FootnoteReference"]').each do | s |
        s.set_attribute('custom-style', 'Footnote Reference')
        s.delete('msword-style')
      end

      # Elision annotations
      nodes.css('span.annotate.elided').each do | s |
        if s['class'].include? 'head'
          s.inner_nodes = '[ … ]'
          s.set_attribute('custom-style', 'Elision')
        else
          s.remove
        end
      end

      # Replacement annotations
      nodes.css('span.annotate.replaced').each do | s |
        s.remove
      end
      nodes.css('span[msword-style="ReplacementText"]').each do | s |
        s.set_attribute('custom-style', 'Replacement Text')
        s.delete('msword-style')
      end

      nodes
    end
  end
end