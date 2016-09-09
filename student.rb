class Student < Page
	attr :name
	attr :grading_path
	attr :submission_path
	attr_accessor :grading
	attr_accessor :submitted
	
	def initialize section, folder, breadcrumbs: []
		student = self
		@name = File.basename(folder).split('_').first
		@grading_path = File.absolute_path File.join(folder,'Homework')
		@submission_path = File.join(TURNIN,section.hour,File.basename(folder),'Homework')
		
		super title: student.name, breadcrumbs: breadcrumbs do
			icon = File.join(Dir.getwd,"arrow.png")
			i = section.students.find_index {|other| other.name == student.name}

			unless i.zero? 
				click = proc { section.students[i-1].display }
				image(icon, top: 230, height: 50, left: 10, click: click).rotate 180
			end
			
			unless i == section.students.size - 1
				click = proc { section.students[i+1].display }
				image(icon, top: 230, height: 50, right: 10, click: click)
			end
			
			flow margin_left: 75, margin_right: 75 do 
				flow margin_bottom: 30 do 
					enable = File.exists? TURNIN 
					button 'Open TurnIn Folder', width: '50%', state: enable ? nil : 'disabled' do 
						`explorer.exe #{student.submission_path.tr("/","\\")}`
					end
				
					button 'Open Grading Folder', width: '50%' do 
						`explorer.exe #{student.grading_path.tr("/","\\")}`
					end
				end
								
				student.submitted = Dir["#{student.submission_path}/*.py"].sort do |a,b|
					File.mtime(b) <=> File.mtime(a)
				end.map {|f| File.basename f}
				
				student.grading = Dir["#{student.grading_path}/*.py"].sort do |a,b|
					File.mtime(b) <=> File.mtime(a)
				end.map {|f| File.basename f}
				
				(student.submitted | student.grading).each do |file| 
					Homework.new(student, File.basename(file)).display self
				end
			end
		end
	end
end