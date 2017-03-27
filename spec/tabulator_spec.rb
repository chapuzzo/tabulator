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

      it 'unused header rows can be skipped' do
        garbage_leading_worksheet_data = [
          ['nothing', 'related', 'with', 'table'],
          ['title', 'other title'],
          ['nothing', 'related', 'with', 'table'],
          ['data', 'other data'],
          ['more data', 'other more data']
        ]

        two_lines_worksheet = Tabulator::Reader::Worksheet.build(garbage_leading_worksheet_data, header: 1, skip: 3)
        expect(two_lines_worksheet.to_a.length).to eq(2)
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

      it 'filters out generated rows by condition' do
        garbage_trailing_worksheet_data = [
          ['title', 'other title'],
          ['normal data', 'other normal data'],
          ['more normal data', 'other more normal data'],
          ['not normal data', 'other not normal data']
        ]

        worksheet = Tabulator::Reader::Worksheet.build garbage_trailing_worksheet_data

        expect(worksheet.reject{ |x| x[:title].include? 'not'}.to_a.length).to eq(2)
      end

      it 'can generate new key/values' do
        two_lines_worksheet = Tabulator::Reader::Worksheet.build two_lines_worksheet_data

        added_reversed_first_title = two_lines_worksheet.apply(:reversed_first_title){ |_, row|
          row[:first_title].reverse
        }

        expect(added_reversed_first_title.to_a.first.length).to eq(3)
        expect(added_reversed_first_title.to_a.first[:reversed_first_title]).to eq(
          added_reversed_first_title.to_a.first[:first_title].reverse
        )
      end


      it 'can generate new objects as values & pass them through filters' do
        class SampleClass
          def initialize xx
            @xx = xx
          end

          def rev
            @xx.reverse
          end

          def to_h
            {
              content: @xx,
              reverse: rev
            }
          end

          def to_json *json_dump_options
            to_h.to_json *json_dump_options
          end
        end

        two_lines_worksheet = Tabulator::Reader::Worksheet.build two_lines_worksheet_data

        object_added_worksheet = two_lines_worksheet.apply(:new_row){ |_, row|
          SampleClass.new [row.to_s, rand.to_s].join(' - ')
        }

        filtered_object_added_worksheet = object_added_worksheet.only(:new_row)

        expect(filtered_object_added_worksheet.to_a.length).to eq(2)
        filtered_object_added_worksheet.to_a.all? { |e|
          expect(e.length).to eq(1)
          expect(e[:new_row].to_h.length).to eq(2)
          expect(e[:new_row].to_h.keys).to eq([:content, :reverse])
          expect(e[:new_row].to_h[:content]).to eq(e[:new_row].to_h[:reverse].reverse)
        }
      end

    end
  end
end
