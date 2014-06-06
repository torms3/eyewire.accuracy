function [MAPs] = UA_extract_individual_accuracy( username, period )
	
	%% Argument validation
	if( ~exist('period','var') )
	    period.since = '';
	    period.until = '';
	end

	%% Prepare MAPs
	[MAPs] = user_accuracy_MAPs(username,period);

	%% Compute tp,fn,fp,tn per each validation
	compute_confusion_info(MAPs);

end