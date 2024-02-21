//
// Created by wuyex on 2024/2/20.
//


#include <string>
#include <cstring>
#include <memory>
#include <vector>
#include "sherpa_helper.h"


namespace purlaw {
    sherpa_recognizer::sherpa_recognizer(std::string model_path) { // non realtime
        SherpaNcnnRecognizerConfig config;
        memset(&config, 0, sizeof(config));

        std::string tokens = model_path + "/tokens.txt";

        std::string encoder_bin = model_path + "/encoder_jit_trace-pnnx.ncnn.bin";
        std::string encoder_param = model_path + "/encoder_jit_trace-pnnx.ncnn.param";

        std::string decoder_bin = model_path + "/decoder_jit_trace-pnnx.ncnn.bin";
        std::string decoder_param = model_path + "/decoder_jit_trace-pnnx.ncnn.param";

        std::string joiner_bin = model_path + "/joiner_jit_trace-pnnx.ncnn.bin";
        std::string joiner_param = model_path + "/joiner_jit_trace-pnnx.ncnn.param";

        config.model_config.tokens = tokens.c_str();

        config.model_config.encoder_bin = encoder_bin.c_str();
        config.model_config.encoder_param = encoder_param.c_str();

        config.model_config.decoder_bin = decoder_bin.c_str();
        config.model_config.decoder_param = decoder_param.c_str();

        config.model_config.joiner_bin = joiner_bin.c_str();
        config.model_config.joiner_param = joiner_param.c_str();

        config.model_config.num_threads = 4;
        config.model_config.use_vulkan_compute = false;

        config.decoder_config.decoding_method = "greedy_search";
        config.decoder_config.num_active_paths = 4;
        config.enable_endpoint = 0;
        config.rule1_min_trailing_silence = 2.4;
        config.rule2_min_trailing_silence = 1.2;
        config.rule3_min_utterance_length = 300;

        config.feat_config.sampling_rate = 16000;
        config.feat_config.feature_dim = 80;

        recognizer = CreateRecognizer(&config);
    }
    sherpa_recognizer::~sherpa_recognizer() {
        DestroyRecognizer(recognizer);
    }
    sherpa_stream::sherpa_stream(sherpa_recognizer *r,int max_word_per_line) {
        s = CreateStream(r->recognizer);
        display = CreateDisplay(max_word_per_line);
        recognizer = r->recognizer;
    }
    sherpa_stream::~sherpa_stream() {
        InputFinished(s);
        DestroyDisplay(display);
        DestroyStream(s);
    }
    bool sherpa_stream::feed(const int16_t *data, int length) {
        float *fdata = new float[length];
        for (int i = 0; i < length; i++) {
            fdata[i] = data[i] / 32768.0f;
        }
        AcceptWaveform(s, 16000, fdata, length);
        delete[] fdata;
        return true;
    }
    std::string sherpa_stream::compute() {
        while (IsReady(recognizer, s)) {
            Decode(recognizer, s);
        }
        SherpaNcnnResult *result = GetResult(recognizer, s);
        std::string text = result->text;
        DestroyResult(result);
        return text;
    }
}