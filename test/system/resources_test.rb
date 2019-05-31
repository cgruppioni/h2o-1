require "application_system_test_case"

class ResourceSystemTest < ApplicationSystemTestCase
  scenario 'secnario', js: true do
    @resource = content_nodes(:resource_with_full_case)
    sign_in users(:user_with_full_case)
    visit annotate_resource_path @resource.casebook, @resource

    # headnote content
    assert_content "1. According to the majority opinion, what did the directors do wrong? In other words, what should the directors have done differently? Why did the business judgment rule not apply?"

    # text is elided
    assert_no_content "Johnson, Joseph B. Lanterman, Graham J. Morgan, Thomas P. O'Boyle, W. Allen Wallis, Sidney H. Bonser, William D. Browder, Trans Union Corporation, a Delaware corporation"

    #replacement annotation
    assert_content "replaced text"

    #highlighted annotation
    sel = '.highlight .selected-text';
    find(sel).assert_text "cash-out merger of Trans Union into the defendant"

    #link annotation
    text = 'Brett A. Ringle, of Shank, Irwin, Conant & Williamson'
    content = "https://opencasebook.org/"
    link = find_link text
    assert_equal content, link[:href]

    delete_first_case_paragraph
    refresh_page
    assert_no_content text

    delete_full_case
    refresh_page
    assert_no_content text

    # --------
    # delete paragraph 

    # annotations still in correct place 

    # change spelling of word

    # annotations still in correct place 

    # remove top of resource
    # annotations still in right place 
  end

  def refresh_page
    visit annotate_resource_path content_nodes(:resource_with_full_case).casebook, content_nodes(:resource_with_full_case)
  end

  def delete_first_case_paragraph
    @resource.resource.update(content: 
      "<h2>[863] HORSEY, Justice (for the majority):</h2>\r\n\r\n<p>This
        appeal from the Court of Chancery involves a class action brought by shareholders
        of the defendant Trans Union Corporation (&quot;Trans Union&quot; or &quot;the
        Company&quot;), originally seeking rescission of a cash-out merger of Trans Union
        into the defendant New T Company (&quot;New T&quot;), a wholly-owned subsidiary
        of the defendant, Marmon Group, Inc. (&quot;Marmon&quot;). Alternate relief in
        the form of damages is sought against the defendant members of the Board of Directors
        of Trans Union, [864] New T, and Jay A. Pritzker and Robert A. Pritzker, owners
        of Marmon.<sup><a href=\"#[1]\" name=\"r[1]\">[1]</a></sup></p>\r\n\r\n<p>----------</p>\r\n\r\n<p><a
        href=\"#r[1]\" name=\"[1]\">[1]</a> The plaintiff, Alden Smith, originally sought
        to enjoin the merger; but, following extensive discovery, the Trial Court denied
        the plaintiff&#39;s motion for preliminary injunction by unreported letter opinion
        dated February 3, 1981. On February 10, 1981, the proposed merger was approved
        by Trans Union&#39;s stockholders at a special meeting and the merger became effective
        on that date. Thereafter, John W. Gosselin was permitted to intervene as an additional
        plaintiff; and Smith and Gosselin were certified as representing a class consisting
        of all persons, other than defendants, who held shares of Trans Union common stock
        on all relevant dates. At the time of the merger, Smith owned 54,000 shares of
        Trans Union stock, Gosselin owned 23,600 shares, and members of Gosselin&#39;s
        family owned 20,000 shares.</p>\r\n")
  end

  def delete_full_case
    @resource.resource.update(content: "hey")
  end
end