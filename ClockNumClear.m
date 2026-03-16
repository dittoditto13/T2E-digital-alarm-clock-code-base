function ClockNumClear(system,selectPins,segmentPins)
    for k = 1:4
        writeDigitalPin(system,selectPins{k}, 1);
    end
    for k = 1:8
        writeDigitalPin(system,segmentPins{k}, 0);
    end
end