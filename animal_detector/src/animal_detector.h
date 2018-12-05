#ifndef ANIMAL_DETECTOR_H
#define ANIMAL_DETECTOR_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    uint64_t samp_rate;
    uint64_t center_freq;
    bool auto_gain;
    uint32_t vga_gain;
    uint32_t lna_gain;
} SdrConfig;

typedef struct {
    float freq;
    float duration;
    float duration_variance;
    float threshold;
    int64_t edge_length;
    int64_t peak_lookahead;
} PulseTarget;

typedef struct {
    SdrConfig sdr_config;
    PulseTarget* pulse_targets;
    uint32_t num_targets;
} DetectorConfig;

typedef struct {
    float freq;
    float signal_strength;
    uint32_t gain;
    uint64_t seconds;
    uint32_t nanos;
} Pulse;

typedef struct {
    Pulse* data;
    uint32_t length;
} PulseList;

typedef struct Detector Detector;

Detector* init_detector(const DetectorConfig* detector_config);
void free_detector(Detector* detector);

PulseList get_pulses(Detector* detector, const float* samples, uint32_t length);
void free_pulses(PulseList pulse_list);

#ifdef __cplusplus
}
#endif

#endif
