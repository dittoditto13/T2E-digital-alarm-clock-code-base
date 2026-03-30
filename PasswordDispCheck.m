function PasswordDispCheck(system, i, TestPassword)
    % digitPins is a cell array: {DigOne, DigTwo, DigThree}
    DigitDisplay = [11,11,11,11];
    for d = 1:(i-1)
        DigitDisplay(d)=TestPassword(d);
    end
    DigitDisplay(i)=10;
    PasswordDispMSG = sprintf("%d,%d,%d,%d",DigitDisplay(1),DigitDisplay(2),DigitDisplay(3),DigitDisplay(4));
    writeline(system,PasswordDispMSG)
end
