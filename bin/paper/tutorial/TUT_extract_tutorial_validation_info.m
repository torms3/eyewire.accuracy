function [TUT_V] = TUT_extract_tutorial_validation_info( uIDs )

%% Where clause
%
where_clause = 'WHERE tasks.status=3 AND validations.status=3 ';
uIDs_str = regexprep(num2str(unique(uIDs)),' +',',');
where_clause = [where_clause 'AND validations.user_id IN (' uIDs_str ') '];


%% Create DB MAP
%
[TUT_V] = DB_create_MAP_validation_info( where_clause );

end