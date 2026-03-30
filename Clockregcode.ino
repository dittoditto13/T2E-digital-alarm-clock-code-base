// 4-Digit 7-Segment Multiplexing Display
// Common Cathode
// Receives 4 comma-separated indices over Serial e.g. "12,13,0,5\n"
// Indices: 0-9 = digits, 10=_, 11=blank, 12=A, 13=P

// --- Pin Definitions ---
// Select pins (common cathode): LOW = digit ON
const int selectPins[4] = {13, 12, 11, 10};  // digits 1-4

// Segment pins: HIGH = segment ON
// Order: a  b  c  d  e  f  g  dp
const int segmentPins[8] = {2, 3, 4, 5, 6, 7, 8, 9};

// --- Segment Map ---
// Rows = characters, Columns = segments [a b c d e f g dp]
// 1 = segment ON, 0 = segment OFF
const byte segMap[24][8] = {
//   a  b  c  d  e  f  g  dp
    {1, 1, 1, 1, 1, 1, 0, 0},  // 0  (index 0)
    {0, 1, 1, 0, 0, 0, 0, 0},  // 1  (index 1)
    {1, 1, 0, 1, 1, 0, 1, 0},  // 2  (index 2)
    {1, 1, 1, 1, 0, 0, 1, 0},  // 3  (index 3)
    {0, 1, 1, 0, 0, 1, 1, 0},  // 4  (index 4)
    {1, 0, 1, 1, 0, 1, 1, 0},  // 5  (index 5)
    {1, 0, 1, 1, 1, 1, 1, 0},  // 6  (index 6)
    {1, 1, 1, 0, 0, 0, 0, 0},  // 7  (index 7)
    {1, 1, 1, 1, 1, 1, 1, 0},  // 8  (index 8)
    {1, 1, 1, 1, 0, 1, 1, 0},  // 9  (index 9)
    {0, 0, 0, 1, 0, 0, 0, 0},  // _  (index 10)
    {0, 0, 0, 0, 0, 0, 0, 0},  // blank (index 11)
    {1, 1, 1, 0, 1, 1, 1, 0},  // A  (index 12)
    {1, 1, 0, 0, 1, 1, 1, 0},  // P  (index 13)
    {1, 1, 1, 1, 1, 1, 0, 1},  // 0. (index 14)
    {0, 1, 1, 0, 0, 0, 0, 1},  // 1. (index 15)
    {1, 1, 0, 1, 1, 0, 1, 1},  // 2. (index 16)
    {1, 1, 1, 1, 0, 0, 1, 1},  // 3. (index 17)
    {0, 1, 1, 0, 0, 1, 1, 1},  // 4. (index 18)
    {1, 0, 1, 1, 0, 1, 1, 1},  // 5. (index 19)
    {1, 0, 1, 1, 1, 1, 1, 1},  // 6. (index 20)
    {1, 1, 1, 0, 0, 0, 0, 1},  // 7. (index 21)
    {1, 1, 1, 1, 1, 1, 1, 1},  // 8. (index 22)
    {1, 1, 1, 1, 0, 1, 1, 1},  // 9. (index 23)
};

// --- Display State ---
int digits[4] = {11, 11, 11, 11};  // start blank
int currentDigit = 0;

// --- Helper: blank all select pins ---
void allDigitsOff() {
    for (int k = 0; k < 4; k++) {
        digitalWrite(selectPins[k], HIGH);  // common cathode: HIGH = off
    }
}

// --- Helper: write segment pins for a given index ---
void writeSegments(int index) {
    for (int s = 0; s < 8; s++) {
        digitalWrite(segmentPins[s], segMap[index][s]);
    }
}

// --- Helper: parse incoming Serial string into digits[] ---
// Expects format "d1,d2,d3,d4\n" e.g. "12,13,0,5\n"
void parseSerial(String s) {
    int idx = 0;
    int lastComma = -1;

    for (int i = 0; i <= s.length(); i++) {
        if (s[i] == ',' || i == s.length()) {
            if (idx < 4) {
                digits[idx] = s.substring(lastComma + 1, i).toInt();
                // clamp to valid range 0-13
                digits[idx] = constrain(digits[idx], 0, 23);
                idx++;
            }
            lastComma = i;
        }
    }
}

void setup() {
    Serial.begin(9600);

    // Initialise select pins
    for (int k = 0; k < 4; k++) {
        pinMode(selectPins[k], OUTPUT);
        digitalWrite(selectPins[k], HIGH);  // all digits off
    }

    // Initialise segment pins
    for (int s = 0; s < 8; s++) {
        pinMode(segmentPins[s], OUTPUT);
        digitalWrite(segmentPins[s], LOW);  // all segments off
    }
}

void loop() {
    // --- Read Serial if available ---
    if (Serial.available()) {
        String incoming = Serial.readStringUntil('\n');
        incoming.trim();
        parseSerial(incoming);
    }

    // --- Multiplex: show one digit per loop iteration ---
    allDigitsOff();
    writeSegments(digits[currentDigit]);
    digitalWrite(selectPins[currentDigit], LOW);  // enable this digit
    delayMicroseconds(2500);                       // 2.5 ms dwell per digit = ~100 Hz refresh

    currentDigit++;
    if (currentDigit == 4) currentDigit = 0;
}