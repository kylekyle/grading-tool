class Page 
	attr :title
	attr :block
	attr :breadcrumbs

	def initialize title:, breadcrumbs: [], &block
		@title = title
		@block = block
		@breadcrumbs = breadcrumbs
	end
	
	def display
		page = self
		
		GradingTool.app do 
			clear
			background white
			set_window_icon_path File.join(Dir.getwd,"icon.png")
			
			append do 
				flow height: 30 do 
					links = page.breadcrumbs.map do |breadcrumb|
						link(strong(breadcrumb.title), underline: 'none') { breadcrumb.display }
					end
					unless links.empty?
						para *links.zip(['  •  ']*(links.size - 1)).flatten, size: 'small'
					end
				end
				stack do 
					banner page.title, align: 'center', margin_bottom: 20
					instance_eval &page.block
				end
			end
		end
	end
end