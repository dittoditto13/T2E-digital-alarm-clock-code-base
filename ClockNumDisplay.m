function ClockNumDisplay(system, selectPins, segmentPins, digit, digitNum)

segMap = [
%  2  3  4  5  6  7  8  9
   1  1  1  1  1  1  0  0;  % 0
   0  1  1  0  0  0  0  0;  % 1
   1  1  0  1  1  0  1  0;  % 2
   1  1  1  1  0  0  1  0;  % 3
   0  1  1  0  0  1  1  0;  % 4
   1  0  1  1  0  1  1  0;  % 5
   1  0  1  1  1  1  1  0;  % 6
   1  1  1  0  0  0  0  0;  % 7
   1  1  1  1  1  1  1  0;  % 8
   1  1  1  1  0  1  1  0;  % 9
   0  0  0  1  0  0  0  0;  % _
];

for k = 1:4
    writeDigitalPin(system, selectPins{k}, k ~= digitNum);
end

row = digit + 1;
for k = 1:8
    writeDigitalPin(system, segmentPins{k}, segMap(row, k));
end
end