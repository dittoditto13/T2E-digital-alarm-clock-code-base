if exist('comTwo','var') ~= 1
    comTwo = arduino('COM3','Uno');
end
%digital pins correlation to rows
rowPins = {'D9', 'D8', 'D7', 'D6'};
%digital pins correlation to columns
colPins = {'D5', 'D4', 'D3', 'D2'};
%button layout
keys = ['1', '2', '3', 'A';
        '4', '5', '6', 'B';
        '7', '8', '9', 'C';
        '*', '0', '#', 'D'];
for i = 1:4
    configurePin(comTwo, rowPins{i}, 'DigitalOutput');
end
for i = 1:4
    configurePin(comTwo, colPins{i}, 'Pullup');
end

% --- Measure loop overhead ---
for x = 1:4
    writeDigitalPin(comTwo, rowPins{x}, 1);
end
loopStart = tic;
for r = 1:4
    writeDigitalPin(comTwo, rowPins{r}, 0);
    for c = 1:4
        readDigitalPin(comTwo, colPins{c});
    end
    writeDigitalPin(comTwo, rowPins{r}, 1);
end
loopOverhead = toc(loopStart);
%writematrix(loopOverhead, 'C:\Users\tyler\OneDrive\Documents\MATLAB\Alarm_Password_Analysis.csv', 'WriteMode', 'append')
disp("time for a test to get you used to the keypad")

% --- Practice Round ---
% Two single-digit codes
for j = 1:2
    AlarmDigOne = randi([0,9]);
    PasswordMatrix = AlarmDigOne;
    TestPassword = zeros([1,1]);
    if AlarmDigOne == 0
        TestPassword(1) = 1;
    end
    z = 1; y = 1;
    disp(PasswordMatrix)
    while true
        while z == y
            [NumInt, ~] = ScanKeypad(comTwo, rowPins, colPins, keys);
            if NumInt >= 0
                if NumInt == PasswordMatrix(z)
                    TestPassword(z) = NumInt;
                    disp(NumInt)
                    pause(0.2)
                    z = z + 1;
                else
                    disp("Wrong digit. Try Again.")
                end
            end
        end
        y = y + 1;
        if isequal(TestPassword, PasswordMatrix)
            disp("passed")
            break
        end
    end
end

% One two-digit practice code
AlarmDigOne = randi([0,9]); AlarmDigTwo = randi([0,9]);
PasswordMatrix = [AlarmDigOne, AlarmDigTwo];
TestPassword = zeros([1,2]);
if AlarmDigTwo == 0; TestPassword(2) = 1; end
z = 1; y = 1;
disp(PasswordMatrix)
while true
    while z == y
        [NumInt, ~] = ScanKeypad(comTwo, rowPins, colPins, keys);
        if NumInt >= 0
            if NumInt == PasswordMatrix(z)
                TestPassword(z) = NumInt;
                disp(NumInt); pause(0.2); z = z + 1;
            else
                disp("Wrong digit. Try Again.")
            end
        end
    end
    y = y + 1;
    if isequal(TestPassword, PasswordMatrix); disp("passed"); break; end
end

% One three-digit practice code
AlarmDigOne = randi([0,9]); AlarmDigTwo = randi([0,9]); AlarmDigThree = randi([0,9]);
PasswordMatrix = [AlarmDigOne, AlarmDigTwo, AlarmDigThree];
TestPassword = zeros([1,3]);
if AlarmDigThree == 0; TestPassword(3) = 1; end
z = 1; y = 1;
disp(PasswordMatrix)
while true
    while z == y
        [NumInt, ~] = ScanKeypad(comTwo, rowPins, colPins, keys);
        if NumInt >= 0
            if NumInt == PasswordMatrix(z)
                TestPassword(z) = NumInt;
                disp(NumInt); pause(0.2); z = z + 1;
            else
                disp("Wrong digit. Try Again.")
            end
        end
    end
    y = y + 1;
    if isequal(TestPassword, PasswordMatrix); disp("passed"); break; end
end

% One four-digit practice code
AlarmDigOne = randi([0,9]); AlarmDigTwo = randi([0,9]);
AlarmDigThree = randi([0,9]); AlarmDigFour = randi([0,9]);
PasswordMatrix = [AlarmDigOne, AlarmDigTwo, AlarmDigThree, AlarmDigFour];
TestPassword = zeros([1,4]);
if AlarmDigFour == 0; TestPassword(4) = 1; end
z = 1; y = 1;
disp(PasswordMatrix)
while true
    while z == y
        [NumInt, ~] = ScanKeypad(comTwo, rowPins, colPins, keys);
        if NumInt >= 0
            if NumInt == PasswordMatrix(z)
                TestPassword(z) = NumInt;
                disp(NumInt); pause(0.2); z = z + 1;
            else
                disp("Wrong digit. Try Again.")
            end
        end
    end
    y = y + 1;
    if isequal(TestPassword, PasswordMatrix); disp("passed"); break; end
end

input("Press enter when you're ready to continue ");

% --- Baseline: single digit reaction times ---
digitOrder = randperm(10) - 1;
for j = digitOrder
    writematrix(j, 'C:\Users\tyler\OneDrive\Documents\MATLAB\Alarm_Password_Analysis.csv', 'WriteMode', 'append')
    disp(j)
    TimeStart = tic;
    if j == 0; TestPassword = 1; else; TestPassword = 0; end
    PasswordMatrix = j;
    z = 1; y = 1;
    while true
        while z == y
            [NumInt, ~] = ScanKeypad(comTwo, rowPins, colPins, keys);
            if NumInt >= 0 && NumInt == j
                TestPassword(z) = NumInt;
                disp(NumInt); pause(0.2); z = z + 1;
            end
        end
        y = y + 1;
        if TestPassword == j
            TimeEnd = toc(TimeStart);
            writematrix(TimeEnd, 'C:\Users\tyler\OneDrive\Documents\MATLAB\Alarm_Password_Analysis.csv', 'WriteMode', 'append')
            disp("passed")
            break
        end
    end
end

% --- Bigram data collection (15 two-digit codes) ---
for j = 1:15
    AlarmDigOne = randi([0,9]); AlarmDigTwo = randi([0,9]);
    PasswordMatrix = [AlarmDigOne, AlarmDigTwo];
    TestPassword = zeros([1,2]);
    if AlarmDigTwo == 0; TestPassword(2) = 1; end
    writematrix(PasswordMatrix, 'C:\Users\tyler\OneDrive\Documents\MATLAB\Alarm_Password_Analysis.csv', 'WriteMode', 'append')
    TimeStart = tic;
    z = 1; y = 1;
    disp(PasswordMatrix)
    while true
        while z == y
            [NumInt, ~] = ScanKeypad(comTwo, rowPins, colPins, keys);
            if NumInt >= 0
                if NumInt == PasswordMatrix(z)
                    TestPassword(z) = NumInt;
                    disp(NumInt); pause(0.2); z = z + 1;
                else
                    disp("Wrong digit. Try Again.")
                end
            end
        end
        y = y + 1;
        if isequal(TestPassword, PasswordMatrix)
            TimeEnd = toc(TimeStart);
            writematrix(TimeEnd, 'C:\Users\tyler\OneDrive\Documents\MATLAB\Alarm_Password_Analysis.csv', 'WriteMode', 'append')
            disp("passed")
            break
        end
    end
end

% --- Trigram data collection (10 three-digit codes) ---
for j = 1:10
    AlarmDigOne = randi([0,9]); AlarmDigTwo = randi([0,9]); AlarmDigThree = randi([0,9]);
    PasswordMatrix = [AlarmDigOne, AlarmDigTwo, AlarmDigThree];
    TestPassword = zeros([1,3]);
    if AlarmDigThree == 0; TestPassword(3) = 1; end
    writematrix(PasswordMatrix, 'C:\Users\tyler\OneDrive\Documents\MATLAB\Alarm_Password_Analysis.csv', 'WriteMode', 'append')
    TimeStart = tic;
    z = 1; y = 1;
    disp(PasswordMatrix)
    while true
        while z == y
            [NumInt, ~] = ScanKeypad(comTwo, rowPins, colPins, keys);
            if NumInt >= 0
                if NumInt == PasswordMatrix(z)
                    TestPassword(z) = NumInt;
                    disp(NumInt); pause(0.2); z = z + 1;
                else
                    disp("Wrong digit. Try Again.")
                end
            end
        end
        y = y + 1;
        if isequal(TestPassword, PasswordMatrix)
            TimeEnd = toc(TimeStart);
            writematrix(TimeEnd, 'C:\Users\tyler\OneDrive\Documents\MATLAB\Alarm_Password_Analysis.csv', 'WriteMode', 'append')
            disp("passed")
            break
        end
    end
end

% --- Quargram data collection (10 four-digit codes) ---
for j = 1:10
    AlarmDigOne = randi([0,9]); AlarmDigTwo = randi([0,9]);
    AlarmDigThree = randi([0,9]); AlarmDigFour = randi([0,9]);
    PasswordMatrix = [AlarmDigOne, AlarmDigTwo, AlarmDigThree, AlarmDigFour];
    TestPassword = zeros([1,4]);
    if AlarmDigFour == 0; TestPassword(4) = 1; end
    writematrix(PasswordMatrix, 'C:\Users\tyler\OneDrive\Documents\MATLAB\Alarm_Password_Analysis.csv', 'WriteMode', 'append')
    TimeStart = tic;
    z = 1; y = 1;
    disp(PasswordMatrix)
    while true
        while z == y
            [NumInt, ~] = ScanKeypad(comTwo, rowPins, colPins, keys);
            if NumInt >= 0
                if NumInt == PasswordMatrix(z)
                    TestPassword(z) = NumInt;
                    disp(NumInt); pause(0.2); z = z + 1;
                else
                    disp("Wrong digit. Try Again.")
                end
            end
        end
        y = y + 1;
        if isequal(TestPassword, PasswordMatrix)
            TimeEnd = toc(TimeStart);
            writematrix(TimeEnd, 'C:\Users\tyler\OneDrive\Documents\MATLAB\Alarm_Password_Analysis.csv', 'WriteMode', 'append')
            disp("passed")
            break
        end
    end
end
disp("Thank you for the data!!!")