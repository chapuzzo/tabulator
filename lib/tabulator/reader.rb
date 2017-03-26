require 'google_drive'
require 'json'
require 'i18n'
I18n.enforce_available_locales = false

module Tabulator
  class Reader
    def initialize file_key, config_file = 'config.json'
      session = GoogleDrive::Session.from_service_account_key(config_file)
      @file = session.spreadsheet_by_key(file_key)
    end

    def [] worksheet
      Worksheet.build @file.worksheets[worksheet].rows
    end

    class Worksheet

      def self.build rows, **options
        header = options[:header] || 0
        skip = options[:skip] || header + 1

        rejected_rows = *options[:reject]

        rejected_rows.each { |row_index|
          rows.delete_at row_index
        }

        header_row = rows[header].map { |raw_header_col|
          I18n.transliterate(raw_header_col.strip.gsub(/\s/, '_')).downcase.to_sym
        }

        new rows.drop(skip).map { |row|
          header_row.zip(row).to_h
        }
      end

      def initialize rows
        @rows = rows
      end

      def only *cols
        self.class.new to_a.map { |row|
          row.select { |title, _|
            cols.include? title
          }
        }
      end

      def apply target
        self.class.new to_a.map { |row|
          row[target] = yield row[target]
          row
        }
      end

      def to_a
        Marshal.load(Marshal.dump(@rows))
      end

      def to_json
        to_a.to_json(json_dump_options)
      end

      def save path
        File.open(path, "w") { |file|
          file.write to_json
        }
      end

      private
        def json_dump_options
          JSON::Ext::Generator::State.new indent: '  ', space: ' ', object_nl: "\n", array_nl: "\n"
        end
    end
  end
end
