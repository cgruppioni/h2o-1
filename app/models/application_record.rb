class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def klass
    self.class.to_s
  end

  def user_display
    self.user.nil? ? nil : self.user.display
  end

  def dump_fixture
    fixture_file = "#{Rails.root}/test/fixtures/#{self.class.table_name}.yml"
    File.open(fixture_file, "a+") do |f|
      f.puts({ "#{self.class.table_name.singularize}_#{id}" => attributes }.
        to_yaml.sub!(/---\s?/, "\n"))
    end
  end
end
