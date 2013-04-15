function [uIDs_info] = UA_plot_user_precision_recall_curve( STAT, cut_line )

%% Argument validation
%
if( ~exist('cut_line','var') )
    cut_line.prec   = 0.5;
    cut_line.rec    = 0.5;
end


%% Option
%
upper_right_mode    = false;    % only display the 'good' zone
plot_mode           = true;     % plot prec. vs. rec. curve
user_name_mode      = true;     % gname
accumulate_mode     = false;    % 
reverse_mode        = false;    % bright color -> dark color

% cell-type
cell_type = 'normal';
% cell_type = 'sac';


%% Read information
%
uIDs    = cell2mat(STAT.keys);
U       = cell2mat(STAT.values);
v_prec  = extractfield(U,'v_prec');
v_rec   = extractfield(U,'v_rec');


%% Preprocessing for plotting the figure
%
% data validation
valid_idx = ~(isnan(v_prec) | isnan(v_rec));
uIDs = uIDs(valid_idx);
U = U(valid_idx);

% sort
tp = extractfield(U,'tp');
fn = extractfield(U,'fn');
fp = extractfield(U,'fp');
n_seg = tp + fn + fp;

[n_seg,idx] = sort(n_seg,'descend');
uIDs = uIDs(idx);
U = U(idx);

% name
names = extractfield(U,'username');


%% stat
%
n_users = numel(uIDs);
v_prec  = extractfield(U,'v_prec');
v_rec   = extractfield(U,'v_rec');
good_idx = (v_prec > cut_line.prec) & (v_rec > cut_line.rec);
bad_idx  = ~good_idx; 
n_good  = nnz(good_idx);
n_bad   = n_users - n_good;
assert(n_bad == nnz(bad_idx));
goodIDs = uIDs(good_idx);
badIDs  = uIDs(bad_idx);

% # cubes 
nv = extractfield(U,'nv');
switch( cell_type )
case 'normal'
    nv_filter = nv > 0;
case 'sac'
    nv_filter = nv > 20;
end

% weight
w = extractfield(U,'weight');
enf = good_idx & (w==0) & nv_filter;
disenf = bad_idx & (w==1);
[enfIDs] = uIDs(enf);
switch( cell_type )
case 'normal'
    % [enfIDs] = qualify_enfranchisement_candidates( enfIDs );
end
disenfIDs = uIDs(disenf);

fprintf('%d out of %d users (%.2f %%) are above the cut-line.\n',n_good,n_users,n_good*100.0/n_users);
fprintf('%d out of %d users (%.2f %%) are below the cut-line.\n',n_bad,n_users,n_bad*100.0/n_users);
fprintf('%d users (%.2f %%) will be enfranchised.\n',numel(enfIDs),numel(enfIDs)*100.0/n_users);
fprintf('%d users (%.2f %%) will be disenfranchised.\n',nnz(disenf),nnz(disenf)*100.0/n_users);

uIDs_info.goodIDs   = goodIDs;
uIDs_info.badIDs    = badIDs;
uIDs_info.enfIDs    = enfIDs;
uIDs_info.disenfIDs = disenfIDs;
uIDs_info.voter     = union(uIDs(good_idx & (w==1)),enfIDs);


%% Plot
%
if( ~plot_mode )
    return;
end


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
switch( cell_type )
case 'normal'
    unit = 100;
    stage = 6;
    from = 0;
    to = 6;
case 'sac'
    unit = 50;
    stage = 6;
    from = 0;
    to = 6;
end

color = colormap( hot(stage+1) );
for i = from:to

    if( reverse_mode )
        th = (stage - i);
    else
        th = i;
    end
    
    if( accumulate_mode )            
        idx = nv > th*unit;
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
    if( user_name_mode )
        set(gcf,'DefaultTextColor','w');
        gname( names(idx1) );
    end

    idx0 = (w == 0) & idx;
    h2 = scatter( v_rec(idx0), v_prec(idx0), circle_size, 'o', ...
                    'MarkerEdgeColor', color(th+1,:) );                    
    
    % Username
    if( user_name_mode )    
        set(gcf,'DefaultTextColor','w');
        gname( names(idx0) );
    end

end

h = colorbar('Location','SouthOutside');
xlabel(h,sprintf('Number of cubes (x %d)',unit));

hold off;

end