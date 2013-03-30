function [query_str] = add_period_clauseDB_add_period_clause( query_str, period )

% check the period
[b_since,b_until] = check_period( period );

% extract data during specific period
if( b_since )
    since_clause = sprintf('and validations.finish > %s ',period.since);
    query_str = [query_str since_clause];
end
if( b_until )
    until_clause = sprintf('and validations.finish < %s ',period.until);
    query_str = [query_str until_clause];
end

end