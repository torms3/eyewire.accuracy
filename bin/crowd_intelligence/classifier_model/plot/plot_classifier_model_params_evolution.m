function plot_classifier_model_params_evolution( save_path, usernames )

%% Options
%
% present username
gname_mode = true;
if( ~exist('usernames','var') )
	gname_mode = false;
end

% trace the evolution of parameters over epochs
evolution = true;


%% Load
%
% get the list of params files
file_list = dir([save_path '/' 'params*']);
if( numel(file_list) < 1 )
	return;
end
[EXP] = parse_params_name( file_list(1).name );
[setting] = CM_prepare_setting( EXP.eta, EXP.iter );
[params] = initialize_classifier_parameters( EXP.n_users, setting );
[save_info] = get_classifier_save_info( save_path, EXP.n_users, setting );
load([save_path '/' file_list(1).name]);

sample_epoch = params.periodic_epoch;
n_samples = params.periodic_samples;

figure();
set( gca, 'Color', 'k' );
set( gcf, 'Color', 'k' );
grid on;
grid minor;
set( gca, 'XColor', 'w' );
set( gca, 'YColor', 'w' );
% xlabel( 'theta' );
% ylabel( 'w - theta' );
% title( 'theta vs. (w - theta)', 'BackgroundColor', 'w' );

color = colormap( hot(n_samples) );

hold on;

if( evolution )
	begin_idx = 1;
else
	begin_idx = n_samples;
end
for idx = begin_idx:n_samples
	
	file_suffix = sprintf('_sample_%d.mat',sample_epoch(idx));
	load([save_path '/' save_info.prefix file_suffix]);
	
	draw( params, color(idx,:) );
end

axis equal;

% reference lines
line( xlim, [0 0], 'Color', 'r' );
line( [0 0], ylim, 'Color', 'r' );

line( xlim, [1 1], 'Color', 'y' );
line( [1 1], ylim, 'Color', 'y' );

% axis equal;
% xlim([0.0 1.0]);
% ylim([0.0 1.0]);

h = colorbar;
cbar_title = sprintf('sample count (epoch / %d)', params.period);
ylabel( h, cbar_title );
caxis([0 n_samples]);

set( gcf, 'DefaultTextBackgroundColor', 'w' );
if( gname_mode )
	gname( usernames );
end

hold off;

end


function draw( params, color  )

	scatter( params.theta, (params.w - params.theta), 'MarkerEdgeColor', color );
	% scatter( params.theta, params.w, 'MarkerEdgeColor', color );
	% scatter( params.w.*params.theta, params.w.*(1 - params.theta), 'MarkerEdgeColor', color );
	% scatter( params.theta, params.w, 'MarkerEdgeColor', color );

end


function [EXP] = parse_params_name( name )

C = textscan(name,'params__u_%d_eta_%f_iter_%d*');
EXP.n_users = C{1};
EXP.eta 	= C{2};
EXP.iter 	= C{3};

EXP.K = 1;
idx = strfind(name,'__K_');
if( ~isempty(idx) )
	C = textscan(name(idx:end),'__K_%d');
	EXP.K = C{1};
end

end