class Homework
	attr :student
	attr :filename

	def initialize student, filename
		@student = student
		@filename = filename
	end
	
	def collect	
		unless File.exists? TURNIN
			GradingTool.app do 
				alert "Cannot connect to Turn-In folder!"
			end
		else
			collected = File.join(student.grading_path, filename)
			submitted = File.join(student.submission_path, filename)
			
			dirname = File.dirname collected
			FileUtils.mkdir dirname unless File.exists? dirname
			
			File.write collected, File.read(submitted)
		end
	end
	
	def return_homework
		pdf = filename.sub(/\.py$/,'.pdf')
		graded = File.join(student.grading_path, pdf)
		returned = File.join(student.submission_path, pdf)
		
		overwrite = true
		generate_receipt = true
		
		unless File.exists? graded
			GradingTool.app do 
				alert "#{pdf} does not exist!"
			end
		else
			if File.exists? returned
				GradingTool.app do 
					overwrite = confirm "#{pdf} already exists. Overwrite?"
					generate_receipt = confirm "Generate return receipt?"
				end
			end
			
			if overwrite
				FileUtils.cp graded, returned
			end
			
			if generate_receipt
				receipt = graded.sub(/\.pdf$/,'.receipt')
				File.write receipt, Time.now
			end
			
			student.display
		end
	end
	
	def can_return?
		receipt = filename.sub(/\.py$/,'.receipt')
		collected? and not File.exists? File.join(student.grading_path, receipt)
	end
	
	def collected?
		student.grading.include? filename
	end
	
	def make_pdf
		pdf = filename.sub(/\.py$/,'.pdf')
		graded = File.join(student.grading_path, pdf)

		unless File.exists? graded
			py = File.join(student.grading_path, filename)
			
			if File.exists? py 
				ConvertToPDF.python py, graded
				sleep 1
			else
				GradingTool.app do 
					alert("#{pdf} not found!")
				end
			end
		end
		
		graded
	end
	
	def pdf
		pdf = make_pdf
		`explorer.exe "#{pdf.tr("/","\\")}"`
	end

	def print
		pdf = filename.sub(/\.py$/,'.pdf')
		graded = File.join(student.grading_path, pdf)
		make_pdf unless File.exists? graded
		
		Thread.new do 
			`"C:\\Program Files (x86)\\Foxit Software\\Foxit Reader\\FoxitReader.exe" /t "#{graded.tr("/","\\")}" \\\\usmasvddshugart\\USMAPRDDTH1128C`
		end
	end
	
	def open
		make_pdf
		path = File.join(student.grading_path, filename)
		`explorer.exe "#{path.tr("/","\\")}"`
	end
	
	def display slot 
		homework = self
		
		slot.app do
			slot.append do 
				flow do
					dirname = File.dirname homework.filename
					filename = File.basename(homework.filename,'.py')
					stack do 
						para filename, size: 'xx-large', align: 'center', margin_bottom: 5
						unless dirname == '.'
							para dirname, stroke: green, size: 'xx-small', align: 'center', margin_top: 0, margin_bottom: 5
						end
					end
				end
				
				flow margin_bottom: 30 do
					buttons = [
						{ name: 'Collect', action: :collect, disable: :collected? },
						{ name: 'Return', action: :return_homework, enable: :can_return? },
						{ name: 'Print', action: :print, enable: :collected? },
						{ name: 'Open', action: :open, enable: :collected? },
						{ name: 'Open PDF', action: :pdf, enable: :collected? }
					]
					
					buttons.each do |info|
						state = if info[:disable]
							homework.send(info[:disable]) ? 'disabled' : nil
						elsif info[:enable]
							homework.send(info[:enable]) ? nil : 'disabled'
						end
							
						button info[:name], width: "#{100.0/buttons.size}%", state: state do
							homework.send info[:action]
							homework.student.display
						end
					end
				end
			end
		end
	end
end	