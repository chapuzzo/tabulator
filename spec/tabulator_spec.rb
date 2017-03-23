require "spec_helper"
require 'ap'

describe Tabulator do
  it "has a version number" do
    expect(Tabulator::VERSION).not_to be nil
  end

  describe 'Reader' do
    describe '::Worksheet' do
      before(:all) {
        FakeWorksheet = Struct.new "FakeWorksheet", :rows
      }

      let(:fake_worksheet){
        header = ['first title', 'second title']
        content = ['first content', 'second content']

        FakeWorksheet.new [
          header,
          content
        ]
      }

      it 'dumps as hashes array' do
        worksheet = Tabulator::Reader::Worksheet.new fake_worksheet

        expect(worksheet.to_a).to eq([
          {
            first_title: 'first content',
            second_title: 'second content'
          }
        ])
      end

      it 'serializes as JSON' do
        worksheet = Tabulator::Reader::Worksheet.new fake_worksheet

        expect(worksheet.to_json).to eq("[\n  {\n    \"first_title\": \"first content\",\n    \"second_title\": \"second content\"\n  }\n]")
      end

      it 'filters based on column' do
        worksheet = Tabulator::Reader::Worksheet.new fake_worksheet

        expect(worksheet.only(:second_title).to_a).to eq([
          second_title: 'second content'
        ])
      end

      it 'postprocesses output hashes by key' do

        worksheet = Tabulator::Reader::Worksheet.new fake_worksheet

        expect(worksheet.apply(:first_title){ |x|
          x.reverse
        }.to_a).to eq([{
          first_title: 'tnetnoc tsrif',
          second_title: 'second content'
        }])
      end

    end
  end
end
