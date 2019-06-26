require 'test_helper'

class ResourcesControllerTest < ActiveSupport::TestCase
  it 'compare SSR to to render to string' do
    @resource = content_nodes(:public_annotated_casebook_section_1_1)
    @include_annotations = true

    ssr_html = Vue::SSR.render(@resource.resource.content, @resource.annotations)

    assert_equal HTMLUtils.parse(render_to_string_output).text, HTMLUtils.parse(ssr_html).text
  end

  def render_to_string_output
    "<!DOCTYPE html>\n<html>\n<body>\n<div class='ResourceNumber' data-custom-style='Resource Number'>1.1</div>\n<div class='ResourceTitle' data-custom-style='Resource Title'>District Case 3</div>\n<div class='ResourceHeadnote' data-custom-style='Resource Headnote'><p>This is the first resource in the casebook.</p></div>\n<div class='opinion'>\n<p><span class=\"annotate note head tail\">This is the body of </span><span msword-style=\"FootnoteReference\" data-exclude-from-offset-calcs=\"true\">*</span>case 3.</p>\n<div><span msword-style='FootnoteReference'>*</span>This case rocks. </div>\n</div>\n\n</body>\n</html>\n"
  end
end
