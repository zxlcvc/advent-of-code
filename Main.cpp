#include <iostream>
#include <fstream>
#include <string>

using namespace std;

int main() {
    // opens input file
    ifstream file("C:\\Users\\boing\\source\\repos\\advent 1\\x64\\Debug\\input.txt");
    if (!file.is_open()) return 1;

    string s;

    // Part 1 vars (just final position stuff)
    int pos1 = 50;
    long long zero1 = 0;

    // Part 2 vars (counting every single click)
    int pos2 = 50;
    long long zero2 = 0;

    // Read each instruction like "L37" or "R412"
    while (file >> s) {
        char d = s[0];              // the L or R
        long long v = stoll(s.substr(1));   // the number after it

    
        //      PART 1
        // only cares about where you END UP after the whole rotation
       
        if (d == 'L')
            pos1 = (pos1 - (v % 100) + 100) % 100;
        else
            pos1 = (pos1 + (v % 100)) % 100;

        if (pos1 == 0)
            zero1++; // only count if we STOP on 0


        
        //      PART 2
        /* counts EVERY time the dial lands on 0
         even while it's spinning */
      
        int step = (d == 'R') ? 1 : -1;

        // simulate each click one-by-one
        for (long long i = 0; i < v; i++) {
            pos2 = (pos2 + step + 100) % 100;

            if (pos2 == 0)
                zero2++; // hits 0 during the spin  count it
        }
    }

    // prints answers 
    cout << zero1 << endl;  
    cout << zero2 << endl;  

    return 0;
}
