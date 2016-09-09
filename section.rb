class Section < Page	
	attr :hour
	attr :students

	def initialize folder, breadcrumbs: []		
		@hour = File.basename(folder)
		folders = Dir["#{folder}/*"].select {|f| File.directory? f}
		
		@students = students = folders.map do |f|
			Student.new(self, f, breadcrumbs: breadcrumbs + [self])
		end
				
		super title: "#{hour} Hour", breadcrumbs: breadcrumbs do 
			flow do 
				random = link strong('Random'), underline: 'none' do 
					alert students.sample.name
				end
				para random, top: 0, align: 'right'
				
				students.each do |student|
					student_link = link student.name, underline: 'none' do 
						student.display
					end
					flow width: '50%', border: red do 
						para student_link, align: 'center', margin_bottom: 15, size: 'large'
					end
				end
			end
		end
	end
end