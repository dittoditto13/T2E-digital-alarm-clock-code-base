function [AlarmDigOne, AlarmDigTwo, AlarmDigThree, AlarmDigFour] = PasswordAlgorithm(temp)
    repeatPenalty = 0.1;
    A = zeros([420, 1100]);
    bigramIndex = zeros(10,10);
    trigramIndex = zeros(10,10,10);
    quargramIndex = zeros(10,10,10,10);
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
    allData = readmatrix('C:\Users\tyler\OneDrive\Documents\MATLAB\Alarm_Password_Analysis.csv', 'Range', 'A1:D1080');
    loopOverhead = allData(1, 1);
    numParticipants = 5;
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
        allCodes=[bigramCodes;trigramCodes;quargramCodes];
    end
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
    B = [bigramTimes; trigramTimes; quargramTimes] - reactionTime;
    A = A(1:length(B), :);
    A = A(1:length(B), :);
    colCounts = sum(A, 1);
    colCounts(colCounts == 0) = 1;
    A = A ./ colCounts;
    W=A\B;
    figure; hold on;
    for i = 1:length(bigramTimes)
        codeRow = bigramCodes(i,:);
        digits = codeRow(~isnan(codeRow));
        a = digits(1); b = digits(2);
        w = W(bigramIndex(a+1, b+1));
        label = sprintf('%d%d', a, b);
        scatter(bigramTimes(i), w, 60, 'b', 'filled');
        col = bigramIndex(a+1, b+1);
        text(bigramTimes(i), w, sprintf('%s [%d]', label, col), 'FontSize', 7, 'Color', 'b');
    end
    for i = 1:length(trigramTimes)
        codeRow = trigramCodes(i,:);
        digits = codeRow(~isnan(codeRow));
        a = digits(1); b = digits(2); c = digits(3);
        w = W(trigramIndex(a+1, b+1, c+1));
        label = sprintf('%d%d%d', a, b, c);
        scatter(trigramTimes(i), w, 60, 'r', 'filled');
        col = trigramIndex(a+1, b+1, c+1);
        text(trigramTimes(i), w, sprintf('%s [%d]', label, col), 'FontSize', 7, 'Color', 'r');
    end
    xlabel('Observed time (s, baseline-corrected)');
    ylabel('Regression weight W');
    title('N-gram weights vs. entry times');
    legend({'Bigrams','Trigrams'}, 'Location','best');
    hold off;
    ngramCounts = sum(A, 1);
    reliableWeights = W(ngramCounts > 0);
    for a = 0:9
        for b = 0:9
            for c = 0:9
                for d = 0:9
                    col = a*1000 + b*100 + c*10 + d +1001;  % maps 000->101 ... 999->1100
                    quargramIndex(a+1, b+1, c+1, d+1) = col;
                end
            end
        end
    end
    quargramscores = zeros(10,10,10,10);
    for a = 0:9
        for b = 0:9
            for c = 0:9
                for d = 0:9
                    score = W(bigramIndex(a+1,b+1)) + W(bigramIndex(b+1,c+1)) + W(bigramIndex(c+1,d+1)) + ...
                    W(trigramIndex(a+1,b+1,c+1)) + W(trigramIndex(b+1,c+1,d+1));
                    bigrams = [bigramIndex(a+1,b+1), bigramIndex(b+1,c+1), bigramIndex(c+1,d+1)];
                    numUnique = length(unique(bigrams));
                    numRepeats = length(bigrams) - numUnique; % 0, 1, or 2
                    score = score * (1 - repeatPenalty * numRepeats/length(bigrams));
                    quargramscores(a+1,b+1,c+1,d+1) = score;
                end
            end
        end
    end
    [sortedScores, sortedIdx] = sort(quargramscores(:), 'descend');
    [a,b,c,d] = ind2sub([10,10,10,10], sortedIdx(1));
    flatScores = quargramscores(:);
    [sortedScores, sortedIdx] = sort(flatScores, 'descend');
    topN = ceil(temp * numel(flatScores));
    candidateIdx = sortedIdx(1:topN);
    candidateScores = sortedScores(1:topN);
    pick = candidateIdx(randi(topN));
    [a,b,c,d] = ind2sub([10,10,10,10], pick);
    AlarmDigOne = a-1;
    AlarmDigTwo = b-1;
    AlarmDigThree = c-1;
    AlarmDigFour = d-1;
end