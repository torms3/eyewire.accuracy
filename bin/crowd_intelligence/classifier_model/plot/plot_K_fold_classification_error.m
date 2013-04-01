function plot_K_fold_classification_error( save_path, n_users, setting, K, CE )

% eta
eta(1) = 0.01;
eta(2) = 0.02;
eta(3) = 0.05;
eta(4) = 0.1;
eta(5) = 0.15;
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
save_root_path = cell(n_eta,1);
K_suffix = sprintf('__K_%d/',K);
for i = 1:n_eta

	setting.eta = eta(i);
	save_info{i} = get_classifier_save_info( save_path, n_users, setting );
	save_root_dir = [save_info{i}.prefix,K_suffix];
	save_root_path{i} = [save_path,save_root_dir];

end

train.RMSE 	= [];
train.CE 	= [];
test.RMSE 	= [];
test.CE 	= [];


%% Plot initialize
%
figure();
color = colormap( lines );


%% Iterative plot
%
%% CE
%
hold on;
for i = 1:n_eta

	setting.eta = eta(i);
	params = initialize_classifier_parameters( n_users, setting );
	train.CE = zeros(1,params.samples);
	test.CE = zeros(1,params.samples);
		
	for k = 1:K
	% target_k = 3;
	% for k = target_k:target_k

		% train
		k_suffix = sprintf('k_%d/',k);
		save_path = [save_root_path{i},k_suffix];

		file_suffix = sprintf('_sample_%d.mat',setting.iter);
		
		file_name = [save_info{i}.prefix,file_suffix];

		load([save_path,file_name]);
		train.CE = train.CE + params.CE;

		% test
		load([save_path,'test_result.mat']);
		test.CE = test.CE + test_result.CE;

	end

	% K-fold average	
	% train.CE 	= train.CE;
	% test.CE 	= test.CE;
	train.CE 	= train.CE/K;
	test.CE 	= test.CE/K;

	% plot
	[h(i),eta_str{i}] = draw_CE( eta(i), params.sample_epoch, train.CE, test.CE, color(i,:) );

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


function [handle,eta_str] = draw_CE( eta, epochs, train, test, color)

	handle = plot(epochs,train,'--o','Color',color);
	handle = plot(epochs,test,'-o','Color',color);
	eta_str = sprintf('eta = %.3f',eta);

end