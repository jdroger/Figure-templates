% Figure: linear regression plots (for significant relationships)
% 03.10.2020 JR
% 
% %%%%% Usage %%%%%
% 
% %%%%% Function Arguments %%%%%
% 
% Required arguments:
% 
% Optional arguments: specified as Name-Value pairs
function regressionplot(data1, data2, labels1, labels2, statsopts, axopts)

arguments
    % required args
    data1       (:,:) double    {mustBeNumeric}
    data2       (:,:) double    {mustBeNumeric}
    labels1     (:,1) cell      {mustBeEqualDim(data1,labels1,2)}
    labels2     (:,1) cell      {mustBeEqualDim(data2,labels2,2)}
    % optional args
    statsopts.PCutoff   double  {mustBeNumeric} = 0.05
    axopts.FigPosition  (1,4) double {mustBeNumeric} = [200 100 400 300]   
end

% calculate correlations between array columns
[rho, pvals] = corr(data1, data2, "rows", "pairwise");

% find significant elements in data (specified by row/col vectors)
[cols1_sig, cols2_sig] = find(pvals<statsopts.PCutoff);

for pair = 1:length(cols1_sig)
    % evaluate regression model for each element
    col1 = cols1_sig(pair);
    col2 = cols2_sig(pair);
    mdl = fitlm(data1(:,col1), data2(:,col2));
    
    % plot regression + statistics
    figure("Position", axopts.Position)
    mdl.plot;
    xlabel(labels1{col1}, "Interpreter", "tex");
    ylabel(labels2{col2}, "Interpreter", "tex");
    annot_str = "/rho = "   + string(round(rho(col1,col2),2)) + newline + ...
                "R^2 = "    + string(round(mdl.Rsquared.Ordinary),2) + newline + ...
                "p = "      + string(round(mdl.Coefficients.pValue,2,'significant'));
    annotation('textbox', [0.65 0.8 0.2 0.1], ...
                'String', annot_str, ...
                'FitBoxToText', 'on', ...
                'EdgeColor', 'none');
    legend('off');
    title(strcat('Linear Model: ', labels1{col1}, "-", labels2{col2}, 'Interpreter', 'tex'));
end
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
    if ~isequal(size(a,dim),size(b,1))
        eid = 'Length:notEqual';
        msg = 'Length of first input dimension must equal length of second input.';
        throwAsCaller(MException(eid,msg))
    end
end