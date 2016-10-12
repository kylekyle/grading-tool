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

CONFIG = File.join(Dir.home, '.grading_path')
GRADING_PATH = File.read(CONFIG).tr("\\","/") rescue nil
WKPDFTOHTML = "C:/Program Files/wkhtmltopdf/bin/wkhtmltopdf.exe"

Shoes.setup do 
	gem 'rouge'
end

GradingTool = Shoes.app title: 'IT105 Grading Tool', height: 555 do
	ready = proc do 
		[WKPDFTOHTML, GRADING_PATH].all? do |path| 
			not path.nil? and File.exists? path
		end
	end
	
	sections = Page.new title: 'Sections' do 
		Dir["#{GRADING_PATH}/[A-Z]"].select{|d| File.directory?(d)}.each do |hour|
			display = File.basename hour
			section_link = 	link "#{display} Hour", underline: 'none' do 
				Section.new(hour, breadcrumbs: [sections]).display
			end
			para section_link, align: 'center', size: 40
		end
	end

	setup = Page.new title: 'Setup' do 
		stack margin_left: 50, margin_right: 50 do 
			refresh = link 'refresh', underline: 'none' do 
				(ready.call ? sections : setup).display
			end
		
			para "There is some setup that needs to be done before the Grading Tool can run. Click ", refresh, " when you're done."
			
			if GRADING_PATH.nil? or not File.directory? GRADING_PATH
				para " • ", link("Choose a grading folder", underline: 'none', size: 'xx-large') {
					GRADING_PATH = ask_open_folder()
					File.write File.join(Dir.home,'.grading_path'), GRADING_PATH
					(ready.call ? sections : setup).display
				}
			end
			
			unless File.exists? WKPDFTOHTML
				para " • ", link("Install the PDF converter", underline: 'none', size: 'xx-large') {
					`start "" "\\\\usmasvddeecs\\eecs\\S&F\\Users\\King\\Software\\wkhtmltox-0.12.3.2_msvc2013-win64.exe"`
				}
			end
		end
	end
	
	(ready.call ? sections : setup).display
end