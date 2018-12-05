#include <stdint.h>
#include <stdio.h>

#include "../src/animal_detector.h"

int main(void) {
    // ... Rest of code ...

    SdrConfig sdr_config = {
        2000000,
        150000000,
        false,
        0,
        0,
    };

    PulseTarget targets[] = {{
        150130000.0,
        0.0185,
        0.0002,
        0.0005,
        10,
        5
    }};

    DetectorConfig config = { sdr_config, &targets[0], 1 };
    Detector* detector = init_detector(&config);

    printf("detector = %p\n", detector);


    // ... pulse loop
    {
        // ... Get buffer ...
        const float* buffer = 0;
        uint32_t length = 0;

        PulseList pulses = get_pulses(detector, buffer, length);
        printf("num_pulses = %u\n", pulses.length);

        // ... do stuff with pulses ...

        free_pulses(pulses);
    }

    free_detector(detector);
}
