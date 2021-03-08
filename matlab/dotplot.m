% Figure: dot plot
% 
function dotplot(data, pvals, row_label, col_label, axopts, clustopts)

arguments
    % required args
    data                (:,:) double {mustBeNumeric}
    pvals               (:,:) double {mustBeNumeric,mustBeEqualSize(data,pvals)}
    row_label           (:,1) cell   {mustBeEqualDim(data,row_label,1)}
    col_label           (:,1) cell   {mustBeEqualDim(data,col_label,2)}
    % optional args(name-value pairs)
    axopts.Colormap     (:,3) double {mustBeNumeric} =  brewermap(31, '*RdYlBu')
    axopts.FigPosition  (1,4) double {mustBeNumeric} =  [300 200 650 350]
    axopts.RowPosition  (1,4) double {mustBeNumeric} =  [0.81 0.22 0.08 0.67]
    axopts.ColPosition  (1,4) double {mustBeNumeric} =  [0.19 0.89 0.62 0.08]
    axopts.MapPosition  (1,4) double {mustBeNumeric} =  [0.2 0.23 0.6 0.65]
    axopts.BarPosition  (1,4) double {mustBeNumeric} =  [0.85 0.23 0.02 0.15]
    axopts.LgdPosition  (1,4) double {mustBeNumeric} =  [0.85 0.4 0.02 0.1]
    axopts.BarLabel           char                   =  ''
    axopts.LgdValues    (1,4) double {mustBeNumeric} =  [0.1 0.05 0.01 0.001]
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
[dend_row, ~, order_row] = dendrogram(tree_rows, 0, 'Orientation', 'right');
set(dend_row, "Color", "black");
set(gca, "Visible", "off");

% plot column dendrogram
axes("Position", axopts.ColPosition);
[dend_col,~,order_col] = dendrogram(tree_cols, 0);
set(dend_col, "Color", "black");
set(gca, "Visible", "off");

% plot heatmap (reordered based on clustering)
axes("Position", axopts.MapPosition);
colormap(axopts.Colormap);
[xgrid, ygrid] = meshgrid(1:size(data,2), 1:size(data,1));
fig_inflrho = scatter(reshape(xgrid,1,[]), ...
                        reshape(ygrid,1,[]), ...
                        -20*log10(reshape(pvals(order_row,order_col),[],1)), ...
                        reshape(data(order_row,order_col),[],1), ...
                        "filled");
xlim([0.5 size(data,2)+0.5]);     ylim([0.5 size(data,1)+0.5]);
xticks(1:size(data,2));           yticks(1:size(data,1));
xticklabels(row_label(order_col));
yticklabels(col_label(order_row));
xtickangle(90);

% plot colorbar (as separate axis)
axes("Position", [0.85 0.23 0.1 0.2]);
colormap(axopts.Colormap);
cr = colorbar;
set(gca,    "Visible",      "off", ...
            "CLim",         [min(fig_inflrho.CData) max(fig_inflrho.CData)]);
set(cr,     "Position",     axopts.BarPosition, ...
            "AxisLocation", "in");
cr.Label.String = axopts.BarLabel;
cr.Label.Interpreter = "tex";

% plot size legend (as separate axis)
axes("Position", axopts.LgdPosition);
scatter(repelem(1,1,length(axopts.LgdValues)), ...
        1:4, -20*log10(axopts.LgdValues), ...
        'black', 'filled');
set(gca, "YAxisLocation", "right", "XColor", "none");
yticks(1:4);
yticklabels(axopts.LgdValues);
ylabel("p-value");
end



% Custom validation functions
function mustBeEqualSize(a,b)
    % Test for equal size
    if ~isequal(size(a),size(b))
        eid = 'Size:notEqual';
        msg = 'Size of first input must equal size of second input.';
        throwAsCaller(MException(eid,msg))
    end
end

function mustBeEqualDim(a,b,dim)
    % Test for equal length in specified dimension
    if ~isequal(size(a,dim),size(b))
        eid = 'Length:notEqual';
        msg = 'Length of first input dimension must equal length of second input.';
        throwAsCaller(MException(eid,msg))
    end
end