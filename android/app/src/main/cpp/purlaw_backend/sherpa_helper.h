//
// Created by wuyex on 2024/2/20.
//

#ifndef PURLAW_BACKEND_SHERPA_HELPER_H
#define PURLAW_BACKEND_SHERPA_HELPER_H

#include "sherpa_utils/sherpa-ncnn/c-api/c-api.h"

namespace purlaw {
    class sherpa_recognizer {
    public:
        sherpa_recognizer(std::string model_path);

        ~sherpa_recognizer();

        SherpaNcnnRecognizer *recognizer;
    };

    class sherpa_stream {
    public:
        sherpa_stream(sherpa_recognizer *recognizer,int max_word_per_line = 50);

        bool feed(const int16_t *data, int length);
        std::string compute();

        ~sherpa_stream();

    private:
        SherpaNcnnStream *s;
        SherpaNcnnRecognizer *recognizer;
        SherpaNcnnDisplay *display;
        int _max_word_per_line;
    };
}

#endif //PURLAW_BACKEND_SHERPA_HELPER_H
