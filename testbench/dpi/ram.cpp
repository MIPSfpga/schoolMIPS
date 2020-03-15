#include <iostream>
#include <map>

using namespace std;

map<int, int> ram;

extern "C" int load_word(int address) {
    int value = 0;
    if (ram.count(address) > 0) {
        value = ram[address];
        cout << "DPI RAM: [OK] Loaded value 0x" << hex << value << " at address 0x" << address << endl;
    } else {
        cout << "DPI RAM: [ERROR] loading value at address 0x" << hex << address << endl;
    }
    return value;
}

extern "C" void store_word(int address, int value) {
    ram[address] = value;
    cout << "DPI RAM: [OK] Stored value 0x" << hex << value << " at address 0x" << address << endl;
}
