%{
2/9/26
Tyler Kramer, Sean Nichols, Alex Taylor
T2E alarm clock. Will display random code that needs to be entered to turn off alarm
%}
if exist('a', 'var') ~= 1
    a = arduino('COM4', 'Uno');
end
if exist('comTwo', 'var') ~= 1
    comTwo = arduino('COM3', 'Uno');
end
PinTwo = 'D2';   PinThree = 'D3';  PinFour = 'D4';   PinFive = 'D5';
PinSix = 'D6';   PinSeven = 'D7';  PinEight = 'D8';  PinNine = 'D9';
PinTen = 'D10';  PinEleven = 'D11'; PinTwelve = 'D12'; PinThirteen = 'D13';
segmentPins = {PinTwo, PinThree, PinFour, PinFive, PinSix, PinSeven, PinEight, PinNine};
selectPins  = {PinThirteen, PinTwelve, PinEleven, PinTen};
ClearCount = 0;
ClearedDig = 0;
rowPins = {'D9', 'D8', 'D7', 'D6'};
colPins = {'D5', 'D4', 'D3', 'D2'};
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
z = 1; y = 1;
DigOne = 1; DigTwo = 2; DigThree = 3; DigFour = 4;
DigitPins = {DigOne, DigTwo, DigThree, DigFour};
breaking = 0;
Alarm = zeros([1,4]);
TestPassword = zeros([1,4]);
confirmed = false;
while ~confirmed
    % --- Re-enter alarm digits ---
    disp('Enter alarm hour first digit:')
    while true
        [NumInt, keyPressed] = ScanKeypad(comTwo, rowPins, colPins, keys);
        if keyPressed && NumInt >= 0
            AlarmHoursOne = NumInt; disp(NumInt); pause(0.2); break
        end
    end
    disp('Enter alarm hour second digit:')
    while true
        [NumInt, keyPressed] = ScanKeypad(comTwo, rowPins, colPins, keys);
        if keyPressed && NumInt >= 0
            AlarmHoursTwo = NumInt; disp(NumInt); pause(0.2); break
        end
    end
    AlarmHoursStr = AlarmHoursOne * 10 + AlarmHoursTwo;

    disp('Enter alarm minutes first digit:')
    while true
        [NumInt, keyPressed] = ScanKeypad(comTwo, rowPins, colPins, keys);
        if keyPressed && NumInt >= 0
            AlarmMinutesOne = NumInt; disp(NumInt); pause(0.2); break
        end
    end
    disp('Enter alarm minutes second digit:')
    while true
        [NumInt, keyPressed] = ScanKeypad(comTwo, rowPins, colPins, keys);
        if keyPressed && NumInt >= 0
            AlarmMinutesTwo = NumInt; disp(NumInt); pause(0.2); break
        end
    end
    AlarmMinutesStr = AlarmMinutesOne * 10 + AlarmMinutesTwo;

    % --- Display entered time ---
    ClockNumClear(a, selectPins, segmentPins)
    ClockNumDisplay(a, selectPins, segmentPins, AlarmHoursOne,   DigOne);
    ClockNumClear(a, selectPins, segmentPins)
    ClockNumDisplay(a, selectPins, segmentPins, AlarmHoursTwo,   DigTwo);
    ClockNumClear(a, selectPins, segmentPins)
    ClockNumDisplay(a, selectPins, segmentPins, AlarmMinutesOne, DigThree);
    ClockNumClear(a, selectPins, segmentPins)
    ClockNumDisplay(a, selectPins, segmentPins, AlarmMinutesTwo, DigFour);

    % --- Confirm or re-enter ---
    disp('Press * to confirm or # to re-enter:')
    while true
        for r = 1:4
            writeDigitalPin(comTwo, rowPins{r}, 0);
            for c = 1:4
                if readDigitalPin(comTwo, colPins{c}) == 0
                    NumStr = keys(r,c);
                    if NumStr == '*'
                        confirmed = true;  pause(0.2);
                    elseif NumStr == '#'
                        confirmed = false; pause(0.2);
                    end
                end
            end
            writeDigitalPin(comTwo, rowPins{r}, 1);
        end
        if NumStr == '*' || NumStr == '#'; break; end
    end
end
ampmConfirmed = false;
while ~ampmConfirmed
    disp('Press A for AM, B for PM:')
    clear AlarmTimeSetting
    while true
        for r = 1:4
            writeDigitalPin(comTwo, rowPins{r}, 0);
            for c = 1:4
                if readDigitalPin(comTwo, colPins{c}) == 0
                    NumStr = keys(r,c);
                    if NumStr == 'A'
                        AlarmTimeSetting = 1; pause(0.2);
                    elseif NumStr == 'B'
                        AlarmTimeSetting = 2; pause(0.2);
                    end
                end
            end
            writeDigitalPin(comTwo, rowPins{r}, 1);
        end
        if exist('AlarmTimeSetting', 'var'); break; end
    end

    % --- Flash display to show AM (digits 1-2 lit) or PM (digits 3-4 lit) ---
    ClockNumClear(a, selectPins, segmentPins)
    if AlarmTimeSetting == 1
        disp('Selected: AM')
        % Show "A" indicator: flash first two digits with dashes, blank last two
        ClockNumDisplay(a, selectPins, segmentPins, 12, DigOne);   % 11 = dash/blank sentinel
    else
        disp('Selected: PM')
        % Show "P" indicator: blank first two, flash last two
        ClockNumDisplay(a, selectPins, segmentPins, 13, DigOne);
    end
    pause(1.0)
    ClockNumClear(a, selectPins, segmentPins)
    % --- Confirm or re-select ---
    disp('Press * to confirm or # to re-select AM/PM:')
    while true
        for r = 1:4
            writeDigitalPin(comTwo, rowPins{r}, 0);
            for c = 1:4
                if readDigitalPin(comTwo, colPins{c}) == 0
                    NumStr = keys(r,c);
                    if NumStr == '*'
                        ampmConfirmed = true;  pause(0.2);
                    elseif NumStr == '#'
                        ampmConfirmed = false; pause(0.2);
                    end
                end
            end
            writeDigitalPin(comTwo, rowPins{r}, 1);
        end
        if NumStr == '*' || NumStr == '#'; break; end
    end
end
tempConfirmed = false;
while ~tempConfirmed
    disp('Enter difficulty first digit (0-9):')
    while true
        [NumInt, keyPressed] = ScanKeypad(comTwo, rowPins, colPins, keys);
        if keyPressed && NumInt >= 0
            TempDigOne = NumInt; disp(NumInt); pause(0.2); break
        end
    end
    disp('Enter difficulty second digit (0-9):')
    while true
        [NumInt, keyPressed] = ScanKeypad(comTwo, rowPins, colPins, keys);
        if keyPressed && NumInt >= 0
            TempDigTwo = NumInt; disp(NumInt); pause(0.2); break
        end
    end
    temp = (TempDigOne * 10 + TempDigTwo) / 100;
    disp(temp)
    % Display "0.XX_" across all 4 digits
    ClockNumClear(a, selectPins, segmentPins)
    ClockNumDisplay(a, selectPins, segmentPins, 0,  DigOne);    % "0"
    ClockNumClear(a, selectPins, segmentPins)
    ClockNumDisplay(a, selectPins, segmentPins, 11, DigTwo);    % "."
    ClockNumClear(a, selectPins, segmentPins)
    ClockNumDisplay(a, selectPins, segmentPins, TempDigOne, DigThree);
    ClockNumClear(a, selectPins, segmentPins)
    ClockNumDisplay(a, selectPins, segmentPins, TempDigTwo, DigFour);
    disp('Press * to confirm or # to re-enter difficulty:')
    while true
        for r = 1:4
            writeDigitalPin(comTwo, rowPins{r}, 0);
            for c = 1:4
                if readDigitalPin(comTwo, colPins{c}) == 0
                    NumStr = keys(r,c);
                    if NumStr == '*'
                        tempConfirmed = true;  pause(0.2);
                    elseif NumStr == '#'
                        tempConfirmed = false; pause(0.2);
                    end
                end
            end
            writeDigitalPin(comTwo, rowPins{r}, 1);
        end
        if NumStr == '*' || NumStr == '#'; break; end
    end
end
Sleven = 0;
if AlarmHoursStr > 9
    AlarmHoursMrx = num2str(AlarmHoursStr) - '0';
    Alarm(1) = AlarmHoursMrx(1);
    Alarm(2) = AlarmHoursMrx(2);
else
    Alarm(1) = 0;
    Alarm(2) = AlarmHoursStr;
end
if AlarmMinutesStr > 9
    AlarmMinutesMrx = num2str(AlarmMinutesStr) - '0';
    Alarm(3) = AlarmMinutesMrx(1);
    Alarm(4) = AlarmMinutesMrx(2);
else
    Alarm(3) = 0;
    Alarm(4) = AlarmMinutesStr;
end
if Alarm(4) == 0
    preminuteAl = 9;
    preminuteAlTwo = Alarm(3)-1;
else
    preminuteAl = Alarm(4) - 1;
end
trigered = 0;
while 1 == 1
    c = clock;
    if c(4) > 11; ClockTimeSetting = 2; else; ClockTimeSetting = 1; end
    if c(4) > 12; c(4) = c(4) - 12; end
    if c(4) > 9
        Hours = num2str(c(4)) - '0';
        DigitOne = Hours(1); DigitTwo = Hours(2);
    else
        DigitOne = 0; DigitTwo = c(4);
    end
    if c(5) > 9
        Minutes = num2str(c(5)) - '0';
        DigitThree = Minutes(1); DigitFour = Minutes(2);
    else
        DigitThree = 0; DigitFour = c(5);
    end
    seconds = c(6);
    time = [DigitOne, DigitTwo, DigitThree, DigitFour];

    % Pre-alarm song trigger (~15s early)
    if Alarm(1)==time(1) && Alarm(2)==time(2) && (Alarm(3)==time(3) || PreminuteTwo==time(3)) && preminuteAl==time(4) ...
            && AlarmTimeSetting==ClockTimeSetting && seconds>29 && trigered==0
        disp("song triggered")
        system('start C:\Users\tyler\OneDrive\Desktop\LaunchAlarmTest.bat')
        trigered = 1;
    elseif Alarm(1)==time(1) && Alarm(2)==time(2) && Alarm(3)==time(3) && Alarm(4)==time(4) ...
            && AlarmTimeSetting==ClockTimeSetting && trigered==0
        disp("song triggered")
        system('start C:\Users\tyler\OneDrive\Desktop\LaunchAlarmTest.bat')
        trigered = 1;
    end
    % Display current clock time
    ClockNumClear(a, selectPins, segmentPins)
    ClockNumDisplay(a, selectPins, segmentPins, DigitOne, DigOne);
    ClockNumClear(a, selectPins, segmentPins)
    ClockNumDisplay(a, selectPins, segmentPins, DigitTwo, DigTwo);
    ClockNumClear(a, selectPins, segmentPins)
    ClockNumDisplay(a, selectPins, segmentPins, DigitThree, DigThree);
    ClockNumClear(a, selectPins, segmentPins)
    ClockNumDisplay(a, selectPins, segmentPins, DigitFour, DigFour);
    % Alarm trigger
    if trigered == 1
        if Alarm(1)==time(1) && Alarm(2)==time(2) && Alarm(3)==time(3) && Alarm(4)==time(4) && AlarmTimeSetting==ClockTimeSetting
            disp('Alarm!')
            i = 1;
            [AlarmDigOne, AlarmDigTwo, AlarmDigThree, AlarmDigFour] = PasswordAlgorithm(temp);
            TestPassword = zeros([1,4]);
            if AlarmDigFour == 0; TestPassword(4) = 1; end

            while 1 == 1
                disp('Alarm!')
                disp([AlarmDigOne, AlarmDigTwo, AlarmDigThree, AlarmDigFour])
                PasswordMatrix = [AlarmDigOne, AlarmDigTwo, AlarmDigThree, AlarmDigFour];
                StartTime = tic;

                % Show alarm code on display (4 cycles)
                for q = 1:4
                    if Sleven == 1; break; end
                    ClockNumClear(a, selectPins, segmentPins)
                    ClockNumDisplay(a, selectPins, segmentPins, AlarmDigOne, DigOne);
                    ClockNumClear(a, selectPins, segmentPins)
                    ClockNumDisplay(a, selectPins, segmentPins, AlarmDigTwo, DigTwo);
                    ClockNumClear(a, selectPins, segmentPins)
                    ClockNumDisplay(a, selectPins, segmentPins, AlarmDigThree, DigThree);
                    ClockNumClear(a, selectPins, segmentPins)
                    ClockNumDisplay(a, selectPins, segmentPins, AlarmDigFour, DigFour);
                end

                PinEnterStartTime = tic;
                while y == z
                    % Check if all 4 digits entered
                    if i == 5
                        if isequal(PasswordMatrix, TestPassword)
                            disp("Correct!")
                            system('start C:\Users\tyler\OneDrive\Desktop\KillAlarmSong.bat')
                            EndTime = toc(StartTime);
                            disp(EndTime)
                            trigered = 0;
                            breaking = 1;
                            break
                        else
                            i = 1; z = 1; y = 1;
                            TestPassword = zeros([1,4]);
                            disp("Try Again")
                        end
                    end

                    Sleven = 1;
                    if Sleven == 1
                        ClockNumDisplay(a, selectPins, segmentPins, 10, DigitPins{1});
                        if i > 1
                            PasswordDispCheck(a, i, TestPassword, selectPins, segmentPins, DigitPins)
                        end
                    end

                    % --- Keypad scan via ScanKeypad ---
                    [NumInt, keyPressed] = ScanKeypad(comTwo, rowPins, colPins, keys);
                    if keyPressed
                        if NumInt == -2
                            % Hash key: clear previous digit
                            ClearCount = ClearCount + 1;
                            if ClearCount == 1
                                disp("Press again to clear previous digit.")
                            end
                            if ClearCount == 2
                                ClearedDig = z - 1;
                                TestPassword(ClearedDig) = 0;
                                disp("Previous digit cleared")
                                z = ClearedDig; y = ClearedDig;
                                i = ClearedDig; Sleven = 0;
                                ClearCount = 0;
                            end
                        elseif NumInt >= 0
                            PinEnterStartTime = tic;
                            ClearCount = 0;
                            TestPassword(z) = NumInt;
                            z = z + 1; i = i + 1; y = y + 1;
                            Sleven = 0;
                            disp(TestPassword)
                            disp(z); disp(i)
                            pause(0.03)
                        end
                    end

                    % Re-show alarm code if no input for 20s
                    PinEnterEndTime = toc(PinEnterStartTime);
                    if PinEnterEndTime > 20
                        PinEnterStartTime = tic;
                        ClockNumClear(a, selectPins, segmentPins)
                        ClockNumDisplay(a, selectPins, segmentPins, AlarmDigOne, DigOne);
                        ClockNumClear(a, selectPins, segmentPins)
                        ClockNumDisplay(a, selectPins, segmentPins, AlarmDigTwo, DigTwo);
                        ClockNumClear(a, selectPins, segmentPins)
                        ClockNumDisplay(a, selectPins, segmentPins, AlarmDigThree, DigThree);
                        ClockNumClear(a, selectPins, segmentPins)
                        ClockNumDisplay(a, selectPins, segmentPins, AlarmDigFour, DigFour);
                    end
                end

                if breaking == 1; break; end
            end
        end
    end
end
