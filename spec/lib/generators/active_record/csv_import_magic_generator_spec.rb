require 'rails_helper'
require 'generators/active_record/csv_import_magic_generator'

RSpec.describe ActiveRecord::Generators::CsvImportMagicGenerator, type: :generator do
  destination File.expand_path("../../../../../tmp", __FILE__)
  arguments ['foo', '-c', 'foo', 'bar']

  before do
    prepare_destination

    FileUtils.mkdir_p('tmp/app/models')
    out_file = File.new(File.join(ENGINE_RAILS_ROOT, "tmp/app/models/foo.rb"), "w+")
    out_file.puts("class Foo\nend")
    out_file.close

    run_generator
  end

  after { prepare_destination }

  specify 'check structure of model' do
    model_content = <<-EOF
class Foo
  csv_import_magic :foo, :bar
end
    EOF

    expect(destination_root).to have_structure {
      directory "app" do
        directory "models" do
          file "foo.rb" do
            contains model_content
          end
        end
      end
    }
  end

  specify 'check structure of parser' do
    parser_content = <<-EOF
class FooParser
  include ::CSVImporter

  model Foo

  # will update_or_create via :foo
  identifier :foo

  # Examples of columns declaration
  # column :foo, to: ->(foo) { foo.downcase }, required: true
  # column :foo, as: [ /first.?name/i, /pr(é|e)nom/i ]
  # column :foo,  as: [ /last.?name/i, "nom" ]
  # column :foo,  to: ->(foo, record) { record.foo = foo ?  'a' : 'b' }
  
  column :foo, required: true
  
  column :bar, required: true
  
  # or :abort
  #  when_invalid :skip
end
    EOF

    expect(destination_root).to have_structure {
      directory "app" do
        directory "csv_parsers" do
          file "foo_parser.rb" do
            contains parser_content
          end
        end
      end
    }
  end
end
