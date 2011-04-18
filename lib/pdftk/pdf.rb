module Pdftk

  # Represents a PDF
  class PDF
    attr_accessor :path

    def initialize path
      @path = path
    end

    def fields_with_values
      fields.reject {|field| field.value.nil? or field.value.empty? }
    end

    def clear_values
      fields_with_values.each {|field| field.value = nil }
    end

    def export output_pdf_path
      xfdf_path = Tempfile.new('pdftk-xfdf').path
      File.open(xfdf_path, 'w'){|f| f << xfdf }
      system %{pdftk "#{path}" fill_form "#{xfdf_path}" output "#{output_pdf_path}"}
    end

    def xfdf
      @fields = fields_with_values

      if @fields.any?
        haml_view_path = File.join File.dirname(__FILE__), 'xfdf.haml'
        Haml::Engine.new(File.read(haml_view_path)).render(self)
      end
    end

    def fields
      unless @_all_fields
        field_output = `pdftk "#{path}" dump_data_fields`
        raw_fields   = field_output.split(/^---\n/).reject {|text| text.empty? }
        @_all_fields = raw_fields.map do |field_text|
          attributes = {}
          field_text.scan(/^(\w+): (.*)$/) do |key, value|
            attributes[key] = value
          end
          Field.new(attributes)
        end
      end
      @_all_fields
    end

    def dump_data
      dumped_data = `pdftk "#{path}" dump_data`
      hash_meta_data(dumped_data)
    end

    def update_data(metadata, output_pdf)
      new_metadata = hash_to_meta_data(metadata)
      opertation_output = `echo "#{new_metadata}" | pdftk "#{path}" update_info - output #{output_pdf}`
    end

    private

    def hash_to_meta_data(metadata_hash)
      output = String.new

      metadata_hash.each{|key,value|
        output << "InfoKey: #{key}\n"
        output << "InfoValue: #{value}\n"
      }
      output
    end

    def hash_meta_data(metadata)
      mdh = {}
      key = ''
      metadata.each_line{|line|
        if line =~ /InfoKey/
          key  = line.split(":")[1].strip
        elsif line =~ /InfoValue/
          value = line.split(":")[1].strip
          mdh.merge!({key => value})
        else
          split_line = line.split(":")
          mdh.merge!({split_line[0].strip => split_line[1].strip})
        end
      }
      mdh
    end

  end
end
