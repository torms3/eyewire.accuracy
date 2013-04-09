function plot_K_fold_classifier_error( save_path )

% extract dir list
dir_list = dir([save_path 'param*']);
if( numel(dir_list) < 1 )
	return;
end

%% Plot
% 
figure();

% subplot setting
color = colormap( lines );
n_subplot = 4;
ylabels = {'precision','recall','classification error',''};
for i = 1:n_subplot

	h(i) = subplot(2,2,i);
	hold(h(i),'on');
	grid(h(i),'on');
	% grid(h(i),'minor');
	xlabel('epochs');
	ylabel(ylabels{i});

end

% iterative plot
n_dir = numel(dir_list);
for i = 1:n_dir

	dir_name = dir_list(i).name;
	[EXP] = parse_params_name( dir_name );
	exp_path = [save_path dir_name '/'];
	plot_experiment( exp_path, EXP, color(i,:), h );

end

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


function plot_experiment( save_path, EXP, color, h )

[setting] = CM_prepare_setting( EXP.eta, EXP.iter );
[params] = initialize_classifier_parameters( EXP.n_users, setting );
[save_info] = get_classifier_save_info( save_path, EXP.n_users, setting );

n_samples = params.samples;
sample_epoch = params.sample_epoch;

if( EXP.K > 1 )	% K-fold cross-validation
	
	tpv = zeros(2,n_samples);
	fnv = zeros(2,n_samples);
	fpv = zeros(2,n_samples);

	th_const.tpv = 0;
	th_const.fnv = 0;
	th_const.fpv = 0;

	th_exp.tpv = 0;
	th_exp.fnv = 0;
	th_exp.fpv = 0;

	for k = 1:EXP.K

		% train load
		k_suffix = sprintf('k_%d/',k);
		k_path = [save_path k_suffix];
		
		save_info = get_classifier_save_info( k_path, EXP.n_users, setting );
		file_suffix = sprintf('_sample_%d.mat',EXP.iter);
		file_name = [save_info.prefix file_suffix];
		load([k_path file_name]);

		% error info.
		CM_error = cell2mat(params.error);
		tpv(1,:) = tpv(1,:) + extractfield(CM_error,'tpv');
		fnv(1,:) = fnv(1,:) + extractfield(CM_error,'fnv');
		fpv(1,:) = fpv(1,:) + extractfield(CM_error,'fpv');

		% test load
		file_name = 'test_result.mat';
		load([k_path file_name]);

		% error info.
		CM_error = cell2mat(test_result.error);
		tpv(2,:) = tpv(2,:) + extractfield(CM_error,'tpv');
		fnv(2,:) = fnv(2,:) + extractfield(CM_error,'fnv');
		fpv(2,:) = fpv(2,:) + extractfield(CM_error,'fpv');

		th_const.tpv = th_const.tpv + test_result.ERR_const.tpv;
		th_const.fnv = th_const.fnv + test_result.ERR_const.fnv;
		th_const.fpv = th_const.fpv + test_result.ERR_const.fpv;

		th_exp.tpv = th_exp.tpv + test_result.ERR_exp.tpv;
		th_exp.fnv = th_exp.fnv + test_result.ERR_exp.fnv;
		th_exp.fpv = th_exp.fpv + test_result.ERR_exp.fpv;

	end

	prec = tpv./(tpv + fpv);
	rec  = tpv./(tpv + fnv);
	CE 	 = (fpv + fnv)/58303421;

	th_const.prec 	= th_const.tpv/(th_const.tpv + th_const.fpv);
	th_const.rec 	= th_const.tpv/(th_const.tpv + th_const.fnv);
	th_const.CE 	= (th_const.fpv + th_const.fnv)/58303421;

	th_exp.prec = th_exp.tpv/(th_exp.tpv + th_exp.fpv);
	th_exp.rec 	= th_exp.tpv/(th_exp.tpv + th_exp.fnv);
	th_exp.CE 	= (th_exp.fpv + th_exp.fnv)/58303421;
	
	% train
	plot(h(1),sample_epoch,prec(1,:),'-.o','Color',color);
	plot(h(2),sample_epoch,rec(1,:),'-.o','Color',color);
	plot(h(3),sample_epoch,CE(1,:),'-.o','Color',color);

	% test
	plot(h(1),sample_epoch,prec(2,:),'-o','Color',color);
	plot(h(2),sample_epoch,rec(2,:),'-o','Color',color);
	plot(h(3),sample_epoch,CE(2,:),'-o','Color',color);	
	
	% constant threshold classifier
	axes(h(1));
	line(xlim,[th_const.prec th_const.prec],'LineStyle','-.','Color','r','LineWidth',2);
	line(xlim,[th_exp.prec th_exp.prec],'LineStyle','--','Color','r','LineWidth',2);
	axes(h(2));
	line(xlim,[th_const.rec th_const.rec],'LineStyle','-.','Color','r','LineWidth',2);
	line(xlim,[th_exp.rec th_exp.rec],'LineStyle','--','Color','r','LineWidth',2);
	axes(h(3));
	line(xlim,[th_const.CE th_const.CE],'LineStyle','-.','Color','r','LineWidth',2);
	line(xlim,[th_exp.CE th_exp.CE],'LineStyle','--','Color','r','LineWidth',2);

end

end
