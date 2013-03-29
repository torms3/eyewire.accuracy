function [b_since,b_until] = check_period( period )

b_since = false;
b_until = false;

if( ~isempty(period.since) )
    b_since = true;
end
if( ~isempty(period.until) )
    b_until = true;
end

end