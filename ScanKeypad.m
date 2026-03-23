function [NumInt, keyPressed] = ScanKeypad(comTwo, rowPins, colPins, keys)
% Scans the keypad once and returns the result.
% NumInt:
%    >= 0  : valid digit that was pressed
%    -1    : no key detected
%    -2    : hash (#) key pressed (clear/backspace sentinel)
%    -3    : other invalid key pressed (*, A, B, C, D)
% keyPressed: true if any key was physically detected

NumInt = -1;
keyPressed = false;

for x = 1:4
    writeDigitalPin(comTwo, rowPins{x}, 1);
end

for r = 1:4
    writeDigitalPin(comTwo, rowPins{r}, 0);
    for c = 1:4
        if readDigitalPin(comTwo, colPins{c}) == 0
            keyPressed = true;
            NumStr = keys(r, c);
            if NumStr == '*' || NumStr == 'A' || NumStr == 'B' || NumStr == 'C' || NumStr == 'D'
                NumInt = -3;
                disp("Wrong key pressed. Try Again.")
            elseif NumStr == '#'
                NumInt = -2;
            else
                NumInt = str2double(NumStr);
            end
        end
    end
    writeDigitalPin(comTwo, rowPins{r}, 1);
end
end