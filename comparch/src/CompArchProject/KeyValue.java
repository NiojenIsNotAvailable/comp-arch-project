package CompArchProject;

import java.util.*;

class KeyValue {
    String key;
    int[] values;
    int size;

    public KeyValue(String key, int value) {
        this.key = key;
        this.values = new int[10000]; // Assuming maximum 10000 values per key
        this.values[size++] = value;
    }

    public double getAverage() {
        int sum = 0;
        for (int i = 0; i < size; i++) {
            sum += values[i];
        }
        return (double) sum / size;
    }
}

