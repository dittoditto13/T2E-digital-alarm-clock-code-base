function [AlarmDigOne, AlarmDigTwo, AlarmDigThree, AlarmDigFour] = PasswordAlgorithm(temp)
    repeatPenalty = 0.5;
    bigramIndex = zeros(10,10);
    trigramIndex = zeros(10,10,10);
    % bigrams: digits 0-9 paired with 0-9
    for a = 0:9
        for b = 0:9
            col = a*10 + b + 1;  % maps 00->1, 01->2 ... 99->100
            bigramIndex(a+1, b+1) = col;
        end
    end
    % trigrams: offset by 100 since bigrams occupy cols 1-100
    for a = 0:9
        for b = 0:9
            for c = 0:9
                col = a*100 + b*10 + c + 101;  % maps 000->101 ... 999->1100
                trigramIndex(a+1, b+1, c+1) = col;
            end
        end
    end
    allBigramCodes = []; allBigramTimes = [];
    allTrigramCodes = []; allTrigramTimes = [];
    allQuargramCodes = []; allQuargramTimes = [];
    allData = readmatrix('C:\Users\tyler\OneDrive\Documents\MATLAB\Alarm_Password_Analysis.csv', 'Range', 'A1:D1171');
    loopOverhead = allData(1, 1);
    numParticipants = 13;
    blockSize = 90;
    for p = 1:numParticipants
        blockStart = (p-1) * blockSize + 2;
        block = allData(blockStart : blockStart+89, :);
        baselineRows = block(1:20, :);
        baselineTimes = baselineRows(2:2:end, 1);
        reactionTime = mean(baselineTimes) - loopOverhead;
        bigramRows = block(21:50, :);
        bigramCodes = bigramRows(1:2:end, :);  
        bigramTimes  = bigramRows(2:2:end, 1) / 2;
        trigramRows = block(51:70, :);
        trigramCodes = trigramRows(1:2:end, :); 
        trigramTimes = trigramRows(2:2:end, 1) / 3;
        quargramRows = block(71:90, :);
        quargramCodes = quargramRows(1:2:end, :); 
        quargramTimes = quargramRows(2:2:end, 1) / 4;
        allBigramCodes = [allBigramCodes; bigramCodes];
        allBigramTimes = [allBigramTimes; bigramTimes - reactionTime];
        allTrigramCodes = [allTrigramCodes; trigramCodes]; 
        allTrigramTimes = [allTrigramTimes; trigramTimes - reactionTime];
        allQuargramCodes = [allQuargramCodes; quargramCodes]; 
        allQuargramTimes = [allQuargramTimes; quargramTimes - reactionTime];
    end
    allCodes=[allBigramCodes;allTrigramCodes;allQuargramCodes];
    nRows=size(allCodes, 1);
    nCols= 1100;
    A = zeros(nRows, nCols);  
    for i = 1:size(allCodes,1)
        codeRow = allCodes(i, :);
        digits = codeRow(~isnan(codeRow));
        codeLength = length(digits);
        % bigrams - sliding window of width 2
        for k = 1:(codeLength-1)
            a = digits(k);
            b = digits(k+1);
            col = bigramIndex(a+1, b+1);
            A(i, col) = 1;
        end
        % trigrams - sliding window of width 3
        for k = 1:(codeLength-2)
            a = digits(k);
            b = digits(k+1);
            c = digits(k+2);
            col = trigramIndex(a+1, b+1, c+1);
            A(i, col) = 1;
        end
    end
    B = abs([allBigramTimes; allTrigramTimes; allQuargramTimes]);
    lambda = 0.01;
    W = lsqnonneg([A; sqrt(lambda)*eye(nCols)], [B; zeros(nCols,1)]);
    figure; hold on;
    for i = 1:length(allBigramTimes)
        codeRow = allBigramCodes(i,:);
        digits = codeRow(~isnan(codeRow));
        a = digits(1); b = digits(2);
        w = W(bigramIndex(a+1, b+1));
        label = sprintf('%d%d', a, b);
        scatter(allBigramTimes(i), w, 60, 'b', 'filled');
        col = bigramIndex(a+1, b+1);
        text(allBigramTimes(i), w, sprintf('%s [%d]', label, col), 'FontSize', 7, 'Color', 'b');
    end
    for i = 1:length(allTrigramTimes)
        codeRow = allTrigramCodes(i,:);
        digits = codeRow(~isnan(codeRow));
        a = digits(1); b = digits(2); c = digits(3);
        w = W(trigramIndex(a+1, b+1, c+1));
        label = sprintf('%d%d%d', a, b, c);
        scatter(allTrigramTimes(i), w, 60, 'r', 'filled');
        col = trigramIndex(a+1, b+1, c+1);
        text(allTrigramTimes(i), w, sprintf('%s [%d]', label, col), 'FontSize', 7, 'Color', 'r');
    end
    xlabel('Observed time (s, baseline-corrected)');
    ylabel('Regression weight W');
    title('N-gram weights vs. entry times');
    legend({'Bigrams','Trigrams'}, 'Location','best');
    hold off;
    scores = zeros(10,10,10,10);
    for a = 0:9
        for b = 0:9
            for c = 0:9
                for d = 0:9
                    digits4 = [a b c d];
                    s = 0;
                    % Bigram contributions
                    for k = 1:3
                        s = s + W(bigramIndex(digits4(k)+1, digits4(k+1)+1));
                    end
                    % Trigram contributions
                    for k = 1:2
                        s = s + W(trigramIndex(digits4(k)+1, digits4(k+1)+1, digits4(k+2)+1));
                    end
                    consecutivePenalty = sum(diff(digits4) == 0);
                    bigramList = zeros(1,3);
                    for k = 1:3
                        bigramList(k) = bigramIndex(digits4(k)+1, digits4(k+1)+1);
                    end
                    repeatedBigrams = length(bigramList) - length(unique(bigramList));
                    repeatPenaltyTotal = (consecutivePenalty + repeatedBigrams) * repeatPenalty;
                    scores(a+1,b+1,c+1,d+1) = s - repeatPenaltyTotal;
                end
            end
        end
    end
    flatScores = scores(:);
    [sortedScores, sortedIdx] = sort(flatScores, 'descend');
    topN = max(1, ceil((1 - temp) * numel(flatScores)));
    candidateIdx = sortedIdx(1:topN);
    pick = candidateIdx(randi(topN));
    [a, b, c, d] = ind2sub([10,10,10,10], pick);
    AlarmDigOne = a - 1;
    AlarmDigTwo = b - 1;
    AlarmDigThree = c - 1;
    AlarmDigFour = d - 1;
    figure;
    scatter(1:numel(flatScores), sortedScores, 10, sortedScores, 'filled');
    colormap(parula);
    colorbar;
    xlabel('Password Rank (1 = highest score)');
    ylabel('Score');
    title('4-Digit Password Scores (Sorted)');
    figure;
    histogram(flatScores, 50, 'FaceColor', [0.2 0.5 0.8]);
    xlabel('Score');
    ylabel('Count');
    title('Distribution of 4-Digit Password Scores');
    xline(sortedScores(1), 'r--', 'Max', 'LabelVerticalAlignment', 'bottom');
    xline(median(flatScores), 'k--', 'Median', 'LabelVerticalAlignment', 'bottom');
    figure;
    scatter(1:numel(flatScores), flatScores, 10, 'filled');
    xlabel('Password Index');
    ylabel('Score');
    title('All 4-Digit Password Scores');
    predicted = A * W(1:nCols);
    figure;
    scatter(B, predicted, 30, 'filled');
    hold on;
    plot([0 max(B)], [0 max(B)], 'r--');
    xlabel('Observed Entry Time (s)');
    ylabel('Predicted Entry Time (s)');
    title('Model Fit: Predicted vs Actual Entry Time');
    % Algorithm vs Random Baseline
    tempValues = 0:0.1:1;
    numTrials = 1000;
    algMeans = zeros(size(tempValues));
    algStds = zeros(size(tempValues));
    randomMeans = zeros(size(tempValues));
    randomStds = zeros(size(tempValues));
    % Random baseline (temp-independent)
    randomSamples = flatScores(randi(numel(flatScores), numTrials, 1));
    randomMean = mean(randomSamples);
    randomStd = std(randomSamples);

    for t = 1:length(tempValues)
        temp = tempValues(t);
        sampledScores = zeros(numTrials, 1);
        
        topN = max(1, ceil((1 - temp) * numel(flatScores)));
        candidateIdx = sortedIdx(1:topN);
        
        for trial = 1:numTrials
            pick = candidateIdx(randi(topN));
            sampledScores(trial) = flatScores(pick);
        end
        
        algMeans(t) = mean(sampledScores);
        algStds(t) = std(sampledScores);
    end

    figure;
    hold on;

    % Algorithm scores across temp values
    errorbar(tempValues, algMeans, algStds, '-o', ...
        'Color', [0.2 0.5 0.8], ...
        'MarkerFaceColor', [0.2 0.5 0.8], ...
        'LineWidth', 1.5, ...
        'DisplayName', 'Algorithm');

    % Random baseline as horizontal band
    yline(randomMean, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Random Baseline');
    patch([0 1 1 0], ...
        [randomMean-randomStd, randomMean-randomStd, ...
        randomMean+randomStd, randomMean+randomStd], ...
        'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none', ...
        'DisplayName', 'Random ±1 SD');

    xlabel('Temperature');
    ylabel('Mean Password Score');
    title('Algorithm Score vs Random Baseline Across Temperature Values');
    legend('Location', 'best');
    grid on;
    hold off;
    bigramWeights = zeros(10, 10);
    for a = 0:9
        for b = 0:9
            col = bigramIndex(a+1, b+1);
            bigramWeights(a+1, b+1) = W(col);
        end
    end

    figure;
    imagesc(0:9, 0:9, bigramWeights);
    colormap(parula);
    cb = colorbar;
    cb.Label.String = 'Regression Weight (predicted entry time contribution)';

    % Overlay the actual weight values in each cell
    for a = 0:9
        for b = 0:9
            w = bigramWeights(a+1, b+1);
            % Switch text color based on background intensity for readability
            if w > mean(bigramWeights(:))
                textColor = 'white';
            else
                textColor = 'black';
            end
            text(b, a, sprintf('%.3f', w), ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 7, ...
                'Color', textColor);
        end
    end

    xlabel('Second Digit');
    ylabel('First Digit');
    title('Bigram N-gram Weights (First Digit \rightarrow Second Digit)');
    xticks(0:9); yticks(0:9);
    axis tight;
end
