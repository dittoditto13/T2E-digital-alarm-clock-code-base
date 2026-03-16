function PasswordDispCheck(system, i, TestPassword, selectPins, segmentPins, digitPins)
    % digitPins is a cell array: {DigOne, DigTwo, DigThree}

    for d = 1:(i-1)
        ClockNumDisplay(system, selectPins, segmentPins, TestPassword(d), digitPins{d});
        ClockNumClear(system, selectPins, segmentPins);
    end
    disp(d)
    % Always end with underscore on digit 1
    ClockNumDisplay(system, selectPins, segmentPins, 10, digitPins{d+1});
    ClockNumClear(system, selectPins, segmentPins);
    disp("__")
end