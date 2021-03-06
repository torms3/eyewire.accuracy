function AI_plot_precision_recall_curve( STAT, AI_accuracy, ERR_exp )

%% Option
upper_right_mode    = false;    % only display the 'good' zone
cut_line.prec       = 0.7;
cut_line.rec        = 0.7;
accumulate_mode     = false;
nonlinear_color     = true;


%% Preprocessing for plotting the figure
%
% data validation
keys = cell2mat(STAT.keys);
vals = cell2mat(STAT.values);
[v_prec] = extractfield( vals, 'v_prec' );
[v_rec]  = extractfield( vals, 'v_rec' );
valid_idx = ~(isnan(v_prec) | isnan(v_rec));
keys = keys(valid_idx);
vals = vals(valid_idx);
[v_prec] = extractfield( vals, 'v_prec' );
[v_rec]  = extractfield( vals, 'v_rec' );


%% stat
%
[w]  = extractfield( vals, 'weight' );
[nv] = extractfield( vals, 'nv' );

nv_filter = nv > 0;


%% Non-linear coloring
%
if( nonlinear_color )
    nv = log10(nv);
end
% disp(max(nv)); 
% 4.210853365314893

%% Plot
%

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
if( nonlinear_color )
    % unit = 0.25;
    % stage = 17;
    unit = 0.5;
    stage = 8;
else
    unit = 50;
    stage = 11;
end
from = 0;
to = stage;

color = colormap( hot(stage+1) );
for i = from:to

    th = i;
    
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
    
    circle_size = 16;
    % circle_size = 23;

    % exclude users w/ small number of cubes
    idx = idx & nv_filter;

    circle_shape = 'o';

    idx1 = (w == 1) & idx;
    h1 = scatter( v_rec(idx1), v_prec(idx1), circle_size, circle_shape, ...
                    'MarkerEdgeColor', 'k', ...
                    'MarkerFaceColor', color(th+1,:) );
                    % 'MarkerEdgeColor', color(th+1,:) );

    idx0 = (w == 0) & idx;
    h2 = scatter( v_rec(idx0), v_prec(idx0), circle_size, circle_shape, ...
                    'MarkerEdgeColor', 'k', ...
                    'MarkerFaceColor', color(th+1,:) );
                    % 'MarkerEdgeColor', color(th+1,:) );

end

% h = colorbar('Location','SouthOutside');
h = colorbar;
% xlabel(h,sprintf('log_{10}(number of cubes) (x %d)',unit));
% xTick = 0:2:9;
% set(h,'XTick',xTick);
% xTickNum = (xTick/2);
% xTickLabel = strtrim(cellstr(num2str(10.^(xTickNum(:)))))';
% set(h,'XTickLabel',xTickLabel);
% xlabel(h,'Number of cubes');
yTick = 0:2:9;
set(h,'YTick',yTick);
yTickNum = (yTick/2);
yTickLabel = strtrim(cellstr(num2str(10.^(yTickNum(:)))))';
set(h,'YTickLabel',yTickLabel);
ylabel(h,'Number of cubes');


%% AI accuracy
%
AI_prec = extractfield( cell2mat(AI_accuracy), 'prec' );
AI_rec  = extractfield( cell2mat(AI_accuracy), 'rec' );
AI_thresh = extractfield( cell2mat(AI_accuracy), 'threshold' );

idx = ismember(AI_thresh,0.04:0.05:0.99);
idx = idx | ismember(AI_thresh,0.94:0.005:0.99);
idx = idx | ismember(AI_thresh,0.985:0.001:0.99);
h1 = plot( AI_rec(idx), AI_prec(idx), '-b', 'LineWidth', 2 );
% h1 = scatter( AI_rec(idx), AI_prec(idx), 30, 'o', ...
%                     'MarkerEdgeColor', 'w', ...
%                     'MarkerFaceColor', 'b' );


%% EyeWire consensus
%
h2 = scatter( ERR_exp.v_rec, ERR_exp.v_prec, 200, 'p', ...
					'MarkerEdgeColor', 'w', ...
                    'MarkerFaceColor', 'b' );

h = legend([h1 h2],'AI accuracy','EyeWire consensus','Location','SouthWest');
set(h,'TextColor','w');
set(h,'EdgeColor','w');
M = findobj(h,'type','patch');
set(M(1),'MarkerSize',13);

hold off;

end