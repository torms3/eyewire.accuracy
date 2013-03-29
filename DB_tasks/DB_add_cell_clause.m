function [query_str] = DB_add_cell_clause( query_str, cell_ID )

if( cell_ID ~= 0 )
	cell_clause = sprintf('and tasks.cell=%d ',cell_ID);
	query_str = [query_str cell_clause];
end

end