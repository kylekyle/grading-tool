class ConvertToPDF
	def self.python input_path, output_path
		require 'rouge'
		require 'rouge/lexers/python'

		theme = Rouge::Themes::Github.new
		lexer = Rouge::Lexers::Python.new
		source = File.read(input_path, :encoding => 'UTF-8')
		
		formatter = Rouge::Formatters::HTMLInline.new(theme)
		html = formatter.format(lexer.lex(source))
		wrapped = "<pre style='word-wrap: break-word; width: 800px;'>#{html}</pre>"
		
		# convert to PDF
		`"#{PDFCONFIG.tr("/","\\")}" /C`
		`"#{PDFCONFIG.tr("/","\\")}" /S "Output" "#{output_path.tr("/","\\")}"`
		`"#{PDFCONFIG.tr("/","\\")}" /S "ShowSettings" "never"`
		`"#{PDFCONFIG.tr("/","\\")}" /S "ConfirmOverwrite" "yes"`
		`"#{PDFCONFIG.tr("/","\\")}" /S "ShowPDF" "no"`
		`"#{PRINTHTML.tr("/","\\")}" html="#{wrapped.gsub('"','""')}"`
	end
end