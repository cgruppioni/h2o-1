require 'test_helper'

class ResourcesTest < ActiveSupport::TestCase
  before do 
    @resource = content_nodes(:public_casebook_section_1_1)
    @include_annotations = true
  end

  describe "without annotations" do
    it 'compare SSR text to render_to_string' do
      ssr_output = Vue::SSR.render(@resource.resource.content, @resource.annotations)
      assert_equal HTMLUtils.parse(render_to_string_output).text, HTMLUtils.parse(ssr_output).text
    end

    it 'compares ssr html to render_to_string' do
      ssr_output = Vue::SSR.render(@resource.resource.content, @resource.annotations)
      assert_equal render_to_string_output, ssr_output
    end
  end

  # def ssr_output
  #   "<DIV class=\"case-text\" data-server-rendered=\"true\" data-v-5735cec2><P data-v-5735cec2>This is the body of case 1.</P></DIV>"
  # end

  def render_to_string_output
    "<!DOCTYPE html>\n<html>\n<body>\n<div class='ResourceNumber' data-custom-style='Resource Number'>1.1</div>\n<div class='ResourceTitle' data-custom-style='Resource Title'>District Case 1</div>\n<div class='ResourceHeadnote' data-custom-style='Resource Headnote'><p>This is the first resource in the casebook.</p></div>\n<div class='opinion'>\n<p>This is the body of case 1.</p>\n</div>\n\n</body>\n</html>\n"
  end
end
