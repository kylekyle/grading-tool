# encoding: utf-8
require_relative 'page'
require_relative 'section'
require_relative 'student'
require_relative 'homework'
require_relative 'convert'

TURNIN = File.join(
	"//usmasvddeecs/eecs/Cadet/Turnin/IT/IT105/",
	ENV['USER'].split('.').last
)

PRINTHTML = File.absolute_path("printhtml.exe")
BULLZIP_PATH = "C:/Program Files/Bullzip/PDF Printer"
PDFCONFIG = "C:/Program Files/Bullzip/PDF Printer/API/EXE/config.exe"
DHTML_PATH = "C:/Program Files (x86)/Common Files/microsoft shared/DhtmlEd"
GRADING_PATH = File.read(File.join(Dir.home,'.grading_path')) rescue nil

GradingTool = Shoes.app title: 'IT105 Grading Tool', height: 555 do
	ready = proc do 
		[BULLZIP_PATH, DHTML_PATH, GRADING_PATH].all? do |path| 
			not path.nil? and File.directory? path
		end
	end
	
	sections = Page.new title: 'Sections' do 
		Dir["#{GRADING_PATH}/*"].select{|d| File.directory?(d)}.each do |hour|
			display = File.basename hour
			section_link = 	link "#{display} Hour", underline: 'none' do 
				Section.new(hour, breadcrumbs: [sections]).display
			end
			para section_link, align: 'center', size: 40
		end
	end

	setup = Page.new title: 'Setup' do 
		stack margin_left: 50, margin_right: 50 do 
			para "There is some setup that needs to be done before the Grading Tool can run:"
			
			if GRADING_PATH.nil? or not File.directory? GRADING_PATH
				para link("• Choose a grading folder", underline: 'none', size: 'xx-large') {
					GRADING_PATH = ask_open_folder()
					File.write File.join(Dir.home,'.grading_path'), GRADING_PATH
					(ready.call ? sections : setup).display
				}
			end
			
			unless File.directory? BULLZIP_PATH
				para link("• Install the PDF converter", underline: 'none') {
					`explorer.exe "bin/Setup_BullzipPDFPrinter_10_25_0_2552_PRO_EXP.exe"`
					(ready.call ? sections : setup).display
				}
			end
			
			unless File.directory? DHTML_PATH
				para link("• Install ", underline: 'none') {
					`explorer.exe "bin/DhtmlEd.msi"`
					(ready.call ? sections : setup).display
				}
			end
		end
	end
	
	(ready.call ? sections : setup).display
end