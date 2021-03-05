% Figure: clustered heatmap (clustermap)
% 
function clustermap(data, row_label, col_label, cmap)

% cluster rows/columns
tree_rows = linkage(data,   'average',  'euclidean');
tree_cols = linkage(data.', 'average',  'euclidean');

% plot row dendrogram
figure("Position", [300 200 650 350]);
axes("Position", [0.81 0.22 0.08 0.67]);
[dend_row, ~, order_row] = dendrogram(tree_rows, 'Orientation', 'right');
set(dend_row, "Color", "black");
set(gca, "Visible", "off");

% plot column dendrogram
axes("Position", [0.19 0.89 0.62 0.08]);
[dend_col,~,order_col] = dendrogram(tree_cols);
set(dend_col, "Color", "black");
set(gca, "Visible", "off");

% plot heatmap (reordered based on clustering)
axes("Position", [0.2 0.23 0.6 0.65]);
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
set(cr,     "Position",     [0.85 0.23 0.02 0.15], ...
            "AxisLocation", "in");
cr.Label.String = "\DeltaActivity";
cr.Label.Interpreter = "tex";
end