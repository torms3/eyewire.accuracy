function [uIDs_info] = NUSM_process_promotion( stat, U, cell_type, cut_line )

%% Argument validation
%
if( ~exist('cell_type','var') )
    cell_type = 'any';
end
if( ~exist('cut_line','var') )
    switch( cell_type )
    case 'sac'
        cut_line.prec   = 0.8;
        cut_line.rec    = 0.8;
    otherwise
        cut_line.prec   = 0.7;
        cut_line.rec    = 0.7;
    end
end


%% Option
upper_right_mode    = false;    % only display the 'good' zone
plot_mode           = true;     % plot prec. vs. rec. curve
user_name_mode      = false;     % gname
accumulate_mode     = false;    % 
reverse_mode        = false;    % bright color -> dark color
promotion_check     = true;
display_cutoff      = true;
novice_expert       = true;
iso_f_curv          = false;
name_background     = false;


%% Preprocessing for plotting the figure
%
% data validation
valid_idx = ~(isnan(stat.vPrec) | isnan(stat.vRec));
valid_idx = valid_idx & (stat.uIDs ~= 1);   % remove superuser
[vPrec] = stat.vPrec(valid_idx)';
[vRec]  = stat.vRec(valid_idx)';


%% Stat
%
uIDs = stat.uIDs(valid_idx);
nUser = numel(uIDs);
good_idx = (vPrec > cut_line.prec) & (vRec > cut_line.rec);
bad_idx  = ~good_idx; 
nGood = nnz(good_idx);
nBad = nUser - nGood;
assert( nBad == nnz(bad_idx) );
goodIDs = uIDs(good_idx);
badIDs = uIDs(bad_idx);

% weight
vals = values( U, num2cell(uIDs) );
[w] = extractfield( cell2mat(vals), 'weight' );
% overwriting cell-type specific weight
if( ~strcmp(cell_type,'any') )
    [SAC_uIDs,SAC_w] = DB_extract_cell_type_specific_weight( cell_type );
    [~,ia,ib] = intersect(uIDs,SAC_uIDs);
    w(ia) = SAC_w(ib);
end

% # cubes 
[nv] = extractfield( cell2mat(vals), 'nv' );
switch( cell_type )
case 'sac'
    nv_filter = nv > 20;
otherwise
    nv_filter = nv > 0;
end
enf = good_idx & (w == 0) & nv_filter;
disenf = bad_idx & (w == 1);
[enfIDs] = uIDs(enf);
if( strcmp(cell_type,'any') && promotion_check )
    [enfIDs] = qualify_enfranchisement_candidates( enfIDs );
end
disenfIDs = uIDs(disenf);

fprintf('%d out of %d users (%.2f %%) are above the cut-line.\n',nGood,nUser,nGood*100.0/nUser);
fprintf('%d out of %d users (%.2f %%) are below the cut-line.\n',nBad,nUser,nBad*100.0/nUser);
fprintf('%d users (%.2f %%) will be enfranchised.\n',numel(enfIDs),numel(enfIDs)*100.0/nUser);
fprintf('%d users (%.2f %%) will be disenfranchised.\n',nnz(disenf),nnz(disenf)*100.0/nUser);

uIDs_info.goodIDs   = goodIDs;
uIDs_info.badIDs    = badIDs;
uIDs_info.enfIDs    = enfIDs;
uIDs_info.disenfIDs = disenfIDs;
% uIDs_info.voter     = union(uIDs(good_idx & (w==1)),enfIDs);


%% Plot
%
if( ~plot_mode )
    return;
end
if( user_name_mode )
    [names] = extractfield( cell2mat(vals), 'username' );
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
case 'sac'
    unit = 50;
otherwise
    unit = 100;
    % unit = 5;
end
stage = 6;
% stage = 9;
from = 0;
to = 6;
% to = 9;


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
            upper_idx = (nv >= (th+1)*unit);
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
        if( display_cutoff )
            % precision cut-line
            line(xlim,[cut_line.prec cut_line.prec],'Color','r','LineWidth',2);
            % recall cut-line
            line([cut_line.rec cut_line.rec],ylim,'Color','r','LineWidth',2);
        end
        if( iso_f_curv )
            F = 0.937531800095224;
            R = (F/(2-F)):0.001:1;
            P = (F*R)./(2*R - F);
            plot(R,P,'-b','LineWidth',2);
        end
    end

    circle_size = 50;

    % exclude users w/ small number of cubes
    % idx = idx & nv_filter;

    idx1 = idx;
    if( novice_expert )
        idx1 = (w == 1) & idx1;
    end
    h1 = scatter( vRec(idx1), vPrec(idx1), circle_size, 'o', ...
                    'MarkerEdgeColor', 'k', ...
                    'MarkerFaceColor', color(th+1,:) );
    % Username
    if( user_name_mode )
        set(gcf,'DefaultTextColor','w');
        gname( names(idx1) );
    end

    if( novice_expert )
        idx0 = (w == 0) & idx;
        h2 = scatter( vRec(idx0), vPrec(idx0), circle_size, 'o', ...
                        'MarkerEdgeColor', color(th+1,:) );
        
        % Username
        if( user_name_mode )    
            set(gcf,'DefaultTextColor','w');
            gname( names(idx0) );
        end
    end

end

% h = colorbar('Location','SouthOutside');
h = colorbar;
% xlabel(h,sprintf('Number of cubes (x %d)',unit));
ylabel(h,sprintf('Number of cubes (x %d)',unit));

hold off;

end