% Figure: clustered heatmap (clustermap)
% 03.05.2020 JR
% Generates a hierarchically-clustered heatmap from a numeric array.
% 
% %%%%% Usage %%%%% 
% CLUSTERMAP(data, row_label, col_label, cmap) performs
% hierarchical clustering via LINKAGE and DENDROGRAM and visualizes data
% via HEATMAP. Rows/columns are labeled by row_label and col_label
% respectively, and colors are specified by cmap.
% 
% HELP CLUSTERMAP displays documentation with links to dependencies
% 
% %%%%% Function Arguments %%%%%
% 
% Required arguments:
%   - data      | n x m double array containing color data
%   - row_label | n x 1 cell array containing row names
%   - col_label | m x 1 cell array containing column names
%   - cmap      | 3-column array defining RGB triplet color values
%           - Can use default matlab colormaps or generate using <a href =
%           "matlab:web('https://www.mathworks.com/matlabcentral/fileexchange/45208-colorbrewer-attractive-and-distinctive-colormaps')"
%           >brewermap</a> function (suggested)
% 
% Optional arguments: specified as Name-Value pairs
%   - 'FigPosition'     | 1 x 4 vector defining position of figure
%   - 'RowPosition'     | 1 x 4 vector defining position of row dendrogram
%   - 'ColPosition'     | 1 x 4 vector defining position of column dendrogram
%   - 'MapPosition'     | 1 x 4 vector defining position of heatmap
%           - specified as [left bottom width height]
%           - 'FigPosition' values in pixels, rest in normalized values
%   - 'ClusterMethod'   | string specifying clustering linkage method
%   - 'ClusterMetric'   | string specifying clustering distance metric
%           - Both must be valid arguments in <a href =
%           "matlab:web(fullfile(docroot, 'stats/linkage.html'))"
%           >linkage</a>

function clustermap(data, row_label, col_label, cmap, axopts, clustopts)

arguments
    % required args
    data                (:,:) double {mustBeNumeric}
    row_label           (:,1) cell
    col_label           (:,1) cell
    cmap                (:,3) double {mustBeNumeric} =  brewermap(31, '*RdBu')
    % optional args(name-value pairs)
    axopts.FigPosition  (1,4) double {mustBeNumeric} =  [300 200 650 350]
    axopts.RowPosition  (1,4) double {mustBeNumeric} =  [0.81 0.22 0.08 0.67]
    axopts.ColPosition  (1,4) double {mustBeNumeric} =  [0.19 0.89 0.62 0.08]
    axopts.MapPosition  (1,4) double {mustBeNumeric} =  [0.2 0.23 0.6 0.65]
    axopts.BarPosition  (1,4) double {mustBeNumeric} =  [0.85 0.23 0.02 0.15]
    axopts.BarLabel         char = ''
    clustopts.ClusterMethod char = 'average'
    clustopts.ClusterMetric char = 'euclidean'
end

% cluster rows/columns
tree_rows = linkage(data,   clustopts.ClusterMethod,  clustopts.ClusterMetric);
tree_cols = linkage(data.', clustopts.ClusterMethod,  clustopts.ClusterMetric);

% generate + plot dendrograms (needed to reorder data)
% plot row dendrogram
figure("Position", axopts.FigPosition);
axes("Position", axopts.RowPosition);
[dend_row, ~, order_row] = dendrogram(tree_rows, 'Orientation', 'right');
set(dend_row, "Color", "black");
set(gca, "Visible", "off");

% plot column dendrogram
axes("Position", axopts.ColPosition);
[dend_col,~,order_col] = dendrogram(tree_cols);
set(dend_col, "Color", "black");
set(gca, "Visible", "off");

% plot heatmap (reordered based on clustering)
axes("Position", axopts.MapPosition);
ax_heatmap = heatmap(data(flip(order_row),  order_col), ...
                        "Colormap",         cmap, ...
                        "XData",            col_label(order_col), ...
                        "YData",            row_label(flip(order_row)), ...
                        "ColorbarVisible",  "off");

% plot colorbar (as separate axis)
axes("Position", [0.85 0.23 0.1 0.2]);
colormap(cmap);         cr = colorbar;
set(gca,    "Visible",      "off", ...
            "CLim",         ax_heatmap.ColorLimits);
set(cr,     "Position",     axopts.BarPosition, ...
            "AxisLocation", "in");
cr.Label.String = axopts.BarLabel;
cr.Label.Interpreter = "tex";
end