function [V] = extract_SAC_validation_info( tIDs )

% period
period.since = '''2013-03-15 12:00:00''';
period.until = '';

% get WHERE clause
[where_clause] = get_where_clause( 0, period, 0, 0 );

% SAC tasks


% create MAP_v_info
[V] = DB_create_MAP_validation_info( where_clause );

end