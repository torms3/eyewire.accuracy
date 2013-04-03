function plot_classification_error( save_path, n_users, iter, CE, NEM )

% eta
eta(1) = 0.01;
% eta(2) = 0.02;
% eta(3) = 0.05;
% eta(4) = 0.1;
% eta(5) = 0.15;
% eta(6) = 0.2;
% eta(1) = 0.000001;
% eta(2) = 0.000002;
% eta(3) = 0.000005;
% eta(4) = 0.00001;
% eta(5) = 0.00002;
% eta(6) = 0.00005;
n_eta = numel(eta);

% data save path
save_info = cell(n_eta,1);
for i = 1:n_eta

	setting = CM_prepare_setting( eta(i), iter );
	save_info{i} = get_classifier_save_info( save_info, n_users, setting );	

end


%% Plot initialize
%
figure();
color = colormap( lines );

%% Iterative plot
%
%% CE
%
% subplot(1,2,2);
hold on;
for i = 1:n_eta

	setting = CM_prepare_setting( eta(i), iter );
	params = initialize_classifier_parameters( n_users, setting );	

	% load
	file_suffix = sprintf('_sample_%d.mat',iter);
	file_name = [save_info{i}.prefix,file_suffix];	
	load([save_path,file_name]);

	ce = params.CE;

	% plot
	[h(i),eta_str{i}] = draw_CE( eta(i), params.sample_epoch, ce, color(i,:) );

end
hold off;

% EyeWire classification error
% constant threshold
err = CE(1);
h(end+1) = line(xlim,[err err],'LineStyle','-.','Color','r','LineWidth',2);
eta_str{end+1} = 'n/m > 0.2';
% exponential threshold
err = CE(2);
h(end+1) = line(xlim,[err err],'LineStyle','--','Color','r','LineWidth',2);
eta_str{end+1} = 'n/m > exp';

% Novice/expert model classification error
% constant threshold
err = NEM(1);
h(end+1) = line(xlim,[err err],'LineStyle','-.','Color','b','LineWidth',2);
eta_str{end+1} = 'n/m > 0.2';
% exponential threshold
err = NEM(2);
h(end+1) = line(xlim,[err err],'LineStyle','--','Color','b','LineWidth',2);
eta_str{end+1} = 'n/m > exp';

%% Plot finalize
%
% legend
legend(h,eta_str);
% grid
grid on;
grid minor;
% labels
xlabel('epochs');
ylabel('classification error');


end


function [handle,eta_str] = draw_CE( eta, epochs, CE, color)

	handle = plot(epochs,CE,'--o','Color',color);
	eta_str = sprintf('eta = %.6f',eta);

end