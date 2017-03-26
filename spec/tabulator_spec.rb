require "spec_helper"
require 'ap'

describe Tabulator do
  it "has a version number" do
    expect(Tabulator::VERSION).not_to be nil
  end

  describe 'Reader' do
    describe '::Worksheet' do

      let(:single_line_worksheet_data){
        header = ['first title', 'second title']
        content = ['first content', 'second content']

        [
          header,
          content
        ]
      }

      let(:single_line_worksheet){
        Tabulator::Reader::Worksheet.build single_line_worksheet_data
      }

      let(:two_lines_worksheet_data){
        [
          ['first title', 'second title'],
          ['first content', 'second content'],
          ['first other content', 'second other content']
        ]
      }

      it 'dumps as hashes array' do
        expect(single_line_worksheet.to_a).to eq([
          {
            first_title: 'first content',
            second_title: 'second content'
          }
        ])
      end

      it 'serializes as JSON' do
        expect(single_line_worksheet.to_json).to eq("[\n  {\n    \"first_title\": \"first content\",\n    \"second_title\": \"second content\"\n  }\n]")
      end

      it 'filters based on column' do
        expect(single_line_worksheet.only(:second_title).to_a).to eq([
          second_title: 'second content'
        ])
      end

      it 'postprocesses output hashes by key' do
        expect(single_line_worksheet.apply(:first_title){ |x|
          x.reverse
        }.to_a).to eq([{
          first_title: 'tnetnoc tsrif',
          second_title: 'second content'
        }])
      end

      it 'filters are chainable' do
        expect(single_line_worksheet.only(:first_title).apply(:first_title){ |x|
          x.reverse
        }.to_a).to eq([{
          first_title: 'tnetnoc tsrif'
        }])
      end

      it 'filters do not modify parent' do
        second_column_hash = single_line_worksheet.apply(:second_title){|col| {a:[5], b:9, c:10}}
        modified_second_column_hash = second_column_hash.apply(:second_title){|col| col[:a] << 1; col}

        expect(single_line_worksheet.to_a[0][:second_title]).to eq 'second content'
        expect(second_column_hash.to_a[0][:second_title]).to eq({a:[5], b:9, c:10})
        expect(modified_second_column_hash.to_a[0][:second_title]).to eq({a:[5, 1], b:9, c:10})
      end

      it 'header row is selectable' do
        two_lines_worksheet = Tabulator::Reader::Worksheet.build(two_lines_worksheet_data, header: 1)
        expect(two_lines_worksheet.to_a.length).to eq(1)
      end

      it 'skips rejected row by index' do
        garbage_trailing_worksheet_data = [
          ['title', 'other title'],
          ['data', 'other data'],
          ['nothing', 'related', 'with', 'table']
        ]

        worksheet = Tabulator::Reader::Worksheet.build garbage_trailing_worksheet_data, reject: 2
        expect(worksheet.to_a.length).to eq(1)
      end

      it 'skips multiple rejected rows by index definition' do
        garbage_trailing_worksheet_data = [
          ['title', 'other title'],
          ['data', 'other data'],
          ['nothing', 'related', 'with', 'table'],
          ['more data', 'other more data'],
          ['nothing', 'related', 'with', 'table'],
          ['nothing', 'related', 'with', 'table'],
          ['nothing', 'related', 'with', 'table']
        ]

        worksheet = Tabulator::Reader::Worksheet.build garbage_trailing_worksheet_data, reject: [2, -1, (-2..-1)]
        expect(worksheet.to_a.length).to eq(2)
      end

      it 'skips multiple rejected rows by condition' do
        garbage_trailing_worksheet_data = [
          ['title', 'other title'],
          ['data', 'other data'],
          ['nothing', 'related', 'with', 'table'],
          ['more data', 'other more data'],
          ['nothing', 'related', 'with', 'table'],
          ['nothing', 'related', 'with', 'table'],
          ['nothing', 'related', 'with', 'table']
        ]

        worksheet = Tabulator::Reader::Worksheet.build garbage_trailing_worksheet_data,
          reject: lambda{ |x| x.include? 'nothing'}


        expect(worksheet.to_a.length).to eq(2)
      end

    end
  end
end
