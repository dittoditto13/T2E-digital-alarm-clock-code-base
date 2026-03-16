%{
2/9/26
Tyler Kramer, Sean Nichols, Alex Taylor
T2E alarm clock. Will display random code that needs to be entered to turn off alarm
%}
a = arduino('COM4','Uno')
comTwo = arduino('COM3','Uno')
% DigOne-DigFour diget numbers for function
% breaking is set varriable to break from second loop in alarm 0 = no break
% Alarm and TestPasssword are set to empty one by four matrix to be filled
%digital pins correlation to rows
PinTwo = 'D2';
PinThree = 'D3';
PinFour = 'D4';
PinFive = 'D5';
PinSix = 'D6';
PinSeven = 'D7';
PinEight = 'D8';
PinNine = 'D9';
PinTen = 'D10';
PinEleven = 'D11';
PinTwelve = 'D12';
PinThirteen = 'D13';
segmentPins = {PinTwo, PinThree, PinFour, PinFive, PinSix, PinSeven, PinEight, PinNine};
selectPins  = {PinThirteen, PinTwelve, PinEleven, PinTen};
ClearCount=0;
ClearedDig=0;
configurePin(comTwo,'D3','Tone')
configurePin(a,'A5','analogInput')
rowPins = {'D9', 'D8', 'D7', 'D6'};
%digital pins correlation to colums
colPins = {'D5', 'D4', 'D10', 'D2'};
%button layout
keys = ['1', '2', '3', 'A';
        '4', '5', '6', 'B';
        '7', '8', '9', 'C';
        '*', '0', '#', 'D'];
%define rows as outputs
for i=1:4
    configurePin(comTwo,rowPins{i},'DigitalOutput');
end
%set coulums to be inputs with pull-ups, also drives them high
for i=1:4
    configurePin(comTwo,colPins{i},'Pullup');
end
z=1;
y=1;
DigOne = 1;
DigTwo = 2;
DigThree = 3;
DigFour = 4;
DigitPins = {DigOne,DigTwo,DigThree,DigFour};
breaking=0;
Alarm = zeros([1,4]);
TestPassword = zeros([1,4]);
AlarmHoursStr = input('What time is the alarm? ');
AlarmMinutesStr = input(': ');
AlarmTimeSetting = input('Am or PM?','s');
Sleven=0;
if strcmpi(AlarmTimeSetting,'PM')==1
    AlarmTimeSetting=2;
else
    AlarmTimeSetting=1;
end
%stores the time for the alarm, separates multidigit number into two integers for the matrix
if AlarmHoursStr > 9
    AlarmHoursMrx = num2str(AlarmHoursStr)-'0';
    Alarm(1)=AlarmHoursMrx(1);
    Alarm(2)=AlarmHoursMrx(2);
else
    Alarm(1)=0;
    Alarm(2)=AlarmHoursStr;
end
if AlarmMinutesStr > 9;
    AlarmMinutesMrx = num2str(AlarmMinutesStr)-'0';
    Alarm(3)=AlarmMinutesMrx(1);
    Alarm(4)=AlarmMinutesMrx(2);
else
    Alarm(3)=0;
    Alarm(4)=AlarmMinutesStr;
end
preminuteAl=Alarm(4)-1
trigered=0;
while 1==1 
    %pull current date time and store it in hours matrix, then connect those to the four clock digits
    %Ex. 8:25 is stored as [0,8,2,5]  
    c = clock;
    if c(4)>11
        ClockTimeSetting=2;
    else
        ClockTimeSetting=1;
    end
    if c(4)>12
        c(4)=c(4)-12;
    end
    if c(4)>9
        Hours=num2str(c(4))-'0';
        DigitOne = Hours(1);
        DigitTwo = Hours(2);
    else
        DigitOne=0;
        DigitTwo=c(4);
    end
    if c(5)>9
        Minutes=num2str(c(5))-'0';
        DigitThree = Minutes(1);
        DigitFour = Minutes(2);
    else
        DigitThree=0;
        DigitFour=c(5);
    end
    seconds=c(6);
    time = [DigitOne,DigitTwo,DigitThree,DigitFour];
    if Alarm(1)==time(1) && Alarm(2)==time(2) && Alarm(3)==time(3) && preminuteAl==time(4)...
            && AlarmTimeSetting==ClockTimeSetting && seconds>44 && trigered==0
        disp("song tirgered")
        system('start C:\Users\tyler\OneDrive\Desktop\LaunchAlarmTest.bat')
        trigered=1;
    end
    % clocknumClear wipes digits, continues if statments to call the correct function for the correct digit
    ClockNumClear(a,selectPins,segmentPins)
    ClockNumDisplay(a,selectPins,segmentPins,DigitOne,DigOne);
    ClockNumClear(a,selectPins,segmentPins)
    % clocknumClear wipes digits, continues if statments to call the correct function for the correct digit
    ClockNumDisplay(a,selectPins,segmentPins,DigitTwo,DigTwo);
    ClockNumClear(a,selectPins,segmentPins)
    % clocknumClear wipes digits, continues if statments to call the correct function for the correct digit
    ClockNumDisplay(a,selectPins,segmentPins,DigitThree,DigThree);
    ClockNumClear(a,selectPins,segmentPins)
    % clocknumClear wipes digits, continues if statments to call the correct function for the correct digit
    ClockNumDisplay(a,selectPins,segmentPins,DigitFour,DigFour);
    %if all time = alarm start alarm
    if Alarm(1)==time(1) && Alarm(2)==time(2) && Alarm(3)==time(3) && Alarm(4)==time(4) && AlarmTimeSetting==ClockTimeSetting
        disp('Alarm!')
        i=1; % iterations of loop, started at one.
        % set random code for alarm
        AlarmDigOne = randi([0,9]);
        AlarmDigTwo = randi([0,9]);
        AlarmDigThree = randi([0,9]);
        AlarmDigFour = randi([0,9]);
        if AlarmDigFour==0
            TestPassword(4)=1;
        end
        while 1==1
            disp('Alarm!')
            disp(AlarmDigOne)
            disp(AlarmDigTwo)
            disp(AlarmDigThree)
            disp(AlarmDigFour)
            PasswordMatrix = [AlarmDigOne,AlarmDigTwo,AlarmDigThree,AlarmDigFour]; %store passcode in matrix
            while y==z
                if i==5
                    disp("reached")
                    if isequal(PasswordMatrix,TestPassword)
                        disp("Yay!!")
                        system('start C:\Users\tyler\OneDrive\Desktop\KillAlarmSong.bat')
                        breaking=1;
                        break
                    else
                        i=1;
                        z=1;
                        y=1;
                        TestPassword=zeros([1,4]);
                        SongNum = randi([1,1]);
                        disp("Try Again")
                    end
                end
                for q = 1:4
                    if Sleven == 1
                        disp("break")
                        break
                    end
                    ClockNumClear(a,selectPins,segmentPins)
                    ClockNumDisplay(a,selectPins,segmentPins,AlarmDigOne,DigOne);
                    ClockNumClear(a,selectPins,segmentPins)
                    ClockNumDisplay(a,selectPins,segmentPins,AlarmDigTwo,DigTwo);
                    ClockNumClear(a,selectPins,segmentPins)
                    ClockNumDisplay(a,selectPins,segmentPins,AlarmDigThree,DigThree);
                    ClockNumClear(a,selectPins,segmentPins)
                   ClockNumDisplay(a,selectPins,segmentPins,AlarmDigFour,DigFour);
                    disp(" ")
                end
            % If four digits were inputed and not the correct passcode, reset the iterations and the input code. Also new song
                if i==5
                    disp("reached")
                    if isequal(PasswordMatrix,TestPassword)
                        disp("Yay!!")
                        breaking=1;
                        break
                    else
                        i=1;
                        TestPassword=zeros([1,4]);
                        SongNum = randi([1,1]);
                        disp("Try Again")
                    end
                end
                Sleven=1;
                disp(" ")
                if Sleven==1
                    ClockNumDisplay(a, selectPins, segmentPins, 10, DigitPins{1});
                    if i>1
                        PasswordDispCheck(a,i,TestPassword,selectPins,segmentPins,DigitPins)
                    end
                end
                for r=1:4
                    %set rows to high, blocking them from accepting input
                    for x =1:4
                        writeDigitalPin(comTwo,rowPins{x},1);
                    end
                    %set current row to low, making it the only voltage path
                    writeDigitalPin(comTwo,rowPins{r},0);
                    for c =1:4
                        %check if a column has been driven low, making it a path for
                        %voltage
                        if readDigitalPin(comTwo,colPins{c}) == 0
                            %display the associated key from the matrix based on
                            %current row and column
                            disp(keys(r,c));
                            NumStr=keys(r,c);
                            if NumStr == '*'|| NumStr == '#' || NumStr == 'A' || NumStr == 'B' || NumStr == 'C' || NumStr == 'D'
                                fprintf("Wrong Key pressed. %s Try Again.",NumStr)
                                if NumStr == '#'
                                    ClearCount=ClearCount+1;
                                    if ClearCount==1
                                        disp("Press again to clear previous digit.")
                                    end
                                end
                                if ClearCount==2
                                    ClearedDig=z-1;
                                    TestPassword(ClearedDig)=0;
                                    disp("Previous digit Cleared")
                                    z=ClearedDig;
                                    y=ClearedDig;
                                    i=ClearedDig;
                                    Sleven=0;
                                    ClearCount=0;
                                end
                            else
                                NumInt = str2double(NumStr);
                                TestPassword(z)=NumInt;
                                z=z+1;
                                i=i+1;
                                y=y+1;
                                Sleven = 0; 
                            end
                            disp(TestPassword)
                            disp(z)
                            disp(i)
                            pause(0.03)
                            %give the code time to reset and pause
                            
                        end
                    end
                end
            end
            if breaking ==1
                break
            end
        end
    end
end