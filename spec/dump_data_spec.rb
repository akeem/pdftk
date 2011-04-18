require File.dirname(__FILE__) + '/../lib/pdftk'

describe Pdftk::PDF do
  describe "#dump_data" do
    let(:pdf){ Pdftk::PDF.new(File.expand_path("1040.pdf", File.dirname(__FILE__) +"/pdfs/"))}

    it "should return a Hash" do
      pdf.dump_data.should be_a_kind_of Hash
    end

    it "should return the metadata of the PDF" do
      dumped_data = pdf.dump_data
      %w{Creator Title Producer Author Keywords Subject ModDate CreationDate 
        PdfID0 PdfID1 NumberOfPages}.each{|field|
        dumped_data.should have_key field
      }
    end
  end

  describe "#update_data" do
    before(:all) do
      metadata = {"Subject" => "A New Subject"}
      pdf = Pdftk::PDF.new(File.expand_path("QuickRef.pdf", File.dirname(__FILE__) +"/pdfs/"))
      pdf.update_data(metadata, File.expand_path("new.pdf", File.dirname(__FILE__)+ "/pdfs"))
    end

    it "should create a new pdf" do
      File.exists?(File.expand_path(("new.pdf"), File.dirname(__FILE__) + "/pdfs")).should be true
    end

    it "should update the metadata of the pdf" do
      new_pdf = Pdftk::PDF.new(File.expand_path("new.pdf", File.dirname(__FILE__) +"/pdfs/"))
      new_pdf.dump_data["Subject"].should eql "A New Subject"
    end
  end
end
