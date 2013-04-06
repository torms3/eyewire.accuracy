function [query_str] = add_cell_clause( query_str, cell_IDs )

if( isempty(cell_IDs) )
	return;
end

if( ~isempty(find(cell_IDs == 0)) )
	return;
end

positive = cell_IDs(cell_IDs > 0);
negative = -cell_IDs(cell_IDs < 0);

cell_clause = ['AND ' get_condition_str( 'tasks.cell', positive, negative )];
query_str = [query_str cell_clause];

end