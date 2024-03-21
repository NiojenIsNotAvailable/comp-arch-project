package CompArchProject;
import java.util.*;
import java.util.*;

import java.util.*;

public class Main {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        Map<String, KeyValue> keyValueMap = new HashMap<>();

        System.out.println("Enter key-value pairs (format: <key> <value>, type 'stop' to end input):");

        while (scanner.hasNextLine()) {
            String line = scanner.nextLine().trim();

            if (line.equals("stop")) {
                break; // Stop input if the user types "stop"
            }

            String[] parts = line.split("\\s+");
            if (parts.length < 2) {
                // Invalid input format, ask the user to enter again
                System.out.println("Invalid input format. Please enter both key and value separated by a space.");
                continue;
            }

            String key = parts[0];
            if (key.isEmpty()) {
                System.out.println("Key cannot be empty. Please enter again.");
                continue;
            }

            int value;
            try {
                value = Integer.parseInt(parts[1]);
            } catch (NumberFormatException e) {
                System.out.println("Invalid value format. Please enter a valid integer.");
                continue;
            }

            if (!keyValueMap.containsKey(key)) {
                keyValueMap.put(key, new KeyValue(key, value));
            } else {
                KeyValue keyValue = keyValueMap.get(key);
                keyValue.values[keyValue.size++] = value;
            }
        }

        KeyValue[] keyValueArray = new KeyValue[keyValueMap.size()];
        int index = 0;
        for (KeyValue keyValue : keyValueMap.values()) {
            keyValueArray[index++] = keyValue;
        }

        // Sort using merge sort
        mergeSort(keyValueArray, 0, keyValueArray.length - 1);

        System.out.println("Keys sorted by average value (descending):");
        for (KeyValue keyValue : keyValueArray) {
            System.out.println(keyValue.key);
        }
    }

    // Merge sort implementation
    private static void mergeSort(KeyValue[] arr, int left, int right) {
        if (left < right) {
            int mid = (left + right) / 2;

            mergeSort(arr, left, mid);
            mergeSort(arr, mid + 1, right);

            merge(arr, left, mid, right);
        }
    }

    private static void merge(KeyValue[] arr, int left, int mid, int right) {
        int n1 = mid - left + 1;
        int n2 = right - mid;

        KeyValue[] leftArr = new KeyValue[n1];
        KeyValue[] rightArr = new KeyValue[n2];

        for (int i = 0; i < n1; ++i) {
            leftArr[i] = arr[left + i];
        }
        for (int j = 0; j < n2; ++j) {
            rightArr[j] = arr[mid + 1 + j];
        }

        int i = 0, j = 0;
        int k = left;
        while (i < n1 && j < n2) {
            if (leftArr[i].getAverage() >= rightArr[j].getAverage()) {
                arr[k++] = leftArr[i++];
            } else {
                arr[k++] = rightArr[j++];
            }
        }

        while (i < n1) {
            arr[k++] = leftArr[i++];
        }

        while (j < n2) {
            arr[k++] = rightArr[j++];
        }
    }
}
