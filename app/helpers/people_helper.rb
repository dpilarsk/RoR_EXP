module PeopleHelper
	def sortable(column, title = nil)
		title ||= column.titleize
		direction = (column == sort_column && sort_direction == "asc" ? "desc" : "asc")
		link_to title, {:direction => direction, :sort => column}
	end
end
