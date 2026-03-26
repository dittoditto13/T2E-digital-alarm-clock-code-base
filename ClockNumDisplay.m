function ClockNumDisplay(system, selectPins, segmentPins, digit, digitNum)

segMap = [
%  2  3  4  5  6  7  8  9 10
   1  1  1  1  1  1  0  0  0;  % 0 idx 0
   0  1  1  0  0  0  0  0  0;  % 1 idx 1
   1  1  0  1  1  0  1  0  0;  % 2 idx 2
   1  1  1  1  0  0  1  0  0;  % 3 idx 3
   0  1  1  0  0  1  1  0  0;  % 4 idx 4
   1  0  1  1  0  1  1  0  0;  % 5 idx 5
   1  0  1  1  1  1  1  0  0;  % 6 idx 6
   1  1  1  0  0  0  0  0  0;  % 7 idx 7
   1  1  1  1  1  1  1  0  0;  % 8 idx 8
   1  1  1  1  0  1  1  0  0;  % 9 idx 9
   0  0  0  1  0  0  0  0  0;  % _ idx 10
   0  0  0  0  0  0  0  0  1;  % . idx 11
   1  1  1  0  1  1  1  1  0;  % A idx 12
   1  1  1  0  0  1  1  1  0;  % P idx 13
];

for k = 1:4
    writeDigitalPin(system, selectPins{k}, k ~= digitNum);
end

row = digit + 1;
for k = 1:8
    writeDigitalPin(system, segmentPins{k}, segMap(row, k));
end
end
