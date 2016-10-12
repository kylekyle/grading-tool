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
		
		Dir.mktmpdir do |dir|
			path = File.join(dir,'code.html')
			File.write path, wrapped
			html path, output_path
		end
	end
	
	def self.html input_path, output_path
		`"#{WKPDFTOHTML.tr("/","\\")}" "#{input_path.tr('/','\\')}" "#{output_path.tr('/','\\')}"`
	end
end