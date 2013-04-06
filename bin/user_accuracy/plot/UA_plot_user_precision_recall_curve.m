function [uIDs_info] = UA_plot_user_precision_recall_curve( STAT, cut_line )

%% Argument validation
%
if( ~exist('cut_line','var') )
    cut_line.prec   = 0.5;
    cut_line.rec    = 0.5;
end


%% Option
upper_right_mode = 0;   % only display the 'good' zone
plot_mode = 1;          % plot prec. vs. rec. curve
user_name_mode = 1;     % gname
accumulate_mode = 0;    % 
reverse_mode = 0;       % bright color -> dark color


%% Read information
%
[IDs] = cell2mat(STAT.keys);
U = cell2mat(STAT.values);
[tp]     = extractfield(U,'tp');
[fn]     = extractfield(U,'fn');
[fp]     = extractfield(U,'fp');
[nv]     = extractfield(U,'nv');
[s_prec] = extractfield(U,'seg_prec');
[s_rec]  = extractfield(U,'seg_rec');
[v_prec] = extractfield(U,'v_prec');
[v_rec]  = extractfield(U,'v_rec');
[names]  = extractfield(U,'username');
[w]      = extractfield(U,'weight');


%% Calculate precision and recall
%% Preprocessing for plotting the figure
%
n_seg = tp + fn + fp;

% data validation
valid_idx = ~(isnan(v_prec) | isnan(v_rec));
v_prec = v_prec(valid_idx);
v_rec = v_rec(valid_idx);
s_prec = s_prec(valid_idx);
s_rec = s_rec(valid_idx);
nv = nv(valid_idx);
IDs = IDs(valid_idx);
n_seg = n_seg(valid_idx);
names = names(valid_idx);
w = w(valid_idx);


% sort
[n_seg,idx] = sort( n_seg, 'descend' );
v_prec = v_prec(idx);
v_rec = v_rec(idx);
s_prec = s_prec(idx);
s_rec = s_rec(idx);
nv = nv(idx);
IDs = IDs(idx);
names = names(idx);
w = w(idx);


%% stat
%
n_users = numel(IDs);
good_idx = (v_prec > cut_line.prec) & (v_rec > cut_line.rec);
bad_idx  = ~good_idx; 
n_good = nnz(good_idx);
n_bad = n_users - n_good;
assert( n_bad == nnz(bad_idx) );
goodIDs = IDs(good_idx);
badIDs = IDs(bad_idx);

% # cubes 
nv_filter = nv > 20;
% nv_filter = nv > 0;

enf = good_idx & (w==0) & nv_filter;
disenf = bad_idx & (w==1);
[enfIDs] = IDs(enf);
% [enfIDs] = qualify_enfranchisement_candidates( enfIDs );
disenfIDs = IDs(disenf);

fprintf('%d out of %d users (%.2f %%) are above the cut-line.\n',n_good,n_users,n_good*100.0/n_users);
fprintf('%d out of %d users (%.2f %%) are below the cut-line.\n',n_bad,n_users,n_bad*100.0/n_users);
fprintf('%d users (%.2f %%) will be enfranchised.\n',numel(enfIDs),numel(enfIDs)*100.0/n_users);
fprintf('%d users (%.2f %%) will be disenfranchised.\n',nnz(disenf),nnz(disenf)*100.0/n_users);

uIDs_info.goodIDs   = goodIDs;
uIDs_info.badIDs    = badIDs;
uIDs_info.enfIDs    = enfIDs;
uIDs_info.disenfIDs = disenfIDs;
uIDs_info.voter     = union( IDs(good_idx & (w==1)), enfIDs );


%% Plot
%
if( plot_mode == 0 )
    return;
end

%% Number of validations histogram
%
% figure();
% hist(nv,20);


%% Precision vs. Recall curve
%
figure();
hold on;
set( gca, 'Color', 'k' );
set( gcf, 'Color', 'k' );
grid on;
set( gca, 'XColor', 'w' );
set( gca, 'YColor', 'w' );

axis equal;

% thresholding
% % Global
% unit = 100;
% stage = 6;
% from = 0;
% to = 6;

% % SAC
unit = 50;
stage = 6;
from = 0;
to = 6;

color = colormap( hot(stage+1) );
for i = from:to

    if( reverse_mode == 1 )
        th = (stage - i);
    else
        th = i;
    end
    
    if( accumulate_mode == 1 )            
        idx = nv > th*unit;
        disp(nnz(idx));
    else
        lower_idx = (nv >= th*unit);
        if( th == stage )
            upper_idx = zeros(1,numel(nv));
        else
            upper_idx = (nv > (th+1)*unit);
        end
        idx = xor(lower_idx,upper_idx);
    end      
    
    set( gca, 'Color', 'k' );
    if( upper_right_mode )
        xlim( [cut_line.rec 1.0] );
        ylim( [cut_line.prec 1.0] );
    else
        xlim( [0 1.0] );
        ylim( [0 1.0] );
    end
    
    caxis( [0 stage+1] );    

    title( 'Precision vs. Recall' );
    xlabel( 'Recall' );
    ylabel( 'Precision' );
    
    if( i == from )
        % precision cut-line
        line(xlim,[cut_line.prec cut_line.prec],'Color','r','LineWidth',2);
        % recall cut-line
        line([cut_line.rec cut_line.rec],ylim,'Color','r','LineWidth',2);
    end

    circle_size = 50;

    % exclude users w/ small number of cubes
    % idx = idx & nv_filter;

    idx1 = (w == 1) & idx;
    h1 = scatter( v_rec(idx1), v_prec(idx1), circle_size, 'o', ...
                    'MarkerEdgeColor', 'k', ...
                    'MarkerFaceColor', color(th+1,:) );
    % Username
    if( user_name_mode == 1 )
        set(gcf,'DefaultTextColor','w');
        gname( names(idx1) );
    end

    idx0 = (w == 0) & idx;
    h2 = scatter( v_rec(idx0), v_prec(idx0), circle_size, 'o', ...
                    'MarkerEdgeColor', color(th+1,:) );                    
    
    % Username
    if( user_name_mode == 1 )    
        set(gcf,'DefaultTextColor','w');
        gname( names(idx0) );
    end

end

h = colorbar('Location','SouthOutside');
xlabel(h,sprintf('Number of cubes (x %d)',unit));

hold off;

end