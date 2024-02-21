#include <jni.h>
#include <string.h>
#include <string>
#include <iostream>
#include "opencv2/opencv.hpp"
#include "purlaw_backend/cvhelper.h"
#include "purlaw_backend/sherpa_helper.h"


class VoiceRecognizer {
public:
    purlaw::sherpa_recognizer* rec;
    bool initialized;

    void initialize(std::string modelPath) {
        if (initialized) return;
        rec = new purlaw::sherpa_recognizer(modelPath);
        initialized = true;
    }

    ~VoiceRecognizer() {
        delete rec;
    }
};

VoiceRecognizer recognizer;

extern "C"
JNIEXPORT jstring JNICALL
Java_com_tianzhu_purlaw_MainActivity_HelloJNI(JNIEnv *env, jobject thiz, jstring arg) {
    const char* strArg = env->GetStringUTFChars(arg, nullptr);
    std::string res = strArg;
    env->ReleaseStringUTFChars(arg, strArg);
    return env->NewStringUTF(("Hello from purlaw.cpp!" + res).c_str());
}
extern "C"
JNIEXPORT jstring JNICALL
Java_com_tianzhu_purlaw_MainActivity_getCVBuildInfo(JNIEnv *env, jobject thiz) {
    return env->NewStringUTF( ("OpenCV Version " + cv::getVersionString()).c_str());
}

extern "C"
JNIEXPORT jobjectArray JNICALL
Java_com_tianzhu_purlaw_MainActivity_documentRecognition(JNIEnv *env, jobject thiz,
                                                         jstring filename, jstring ocr_model_path) {
    const char* strFilename = env->GetStringUTFChars(filename, nullptr);
    std::string sFilename = strFilename;
    env->ReleaseStringUTFChars(filename, strFilename);

    const char* strOcrModelPath = env->GetStringUTFChars(ocr_model_path, nullptr);
    std::string sOcrModelPath = strOcrModelPath;
    env->ReleaseStringUTFChars(ocr_model_path, strOcrModelPath);

    cv::Mat src = cv::imread(sFilename);
    purlaw::ppocr ocr(sOcrModelPath);
    auto _res = ocr.detect(src);
    auto result = purlaw::align_text(_res);

    auto returnObj = env->NewObjectArray(1, env->FindClass("java/lang/String"), 0);
    jstring str = env->NewStringUTF(result.c_str());
    env->SetObjectArrayElement(returnObj, 0, str);
    env->DeleteLocalRef(str);
    return returnObj;
}
extern "C"
JNIEXPORT void JNICALL
Java_com_tianzhu_purlaw_MainActivity_documentRectify(JNIEnv *env, jobject thiz, jstring filename) {
    const char* strFilename = env->GetStringUTFChars(filename, nullptr);
    std::string sFilename = strFilename;
    env->ReleaseStringUTFChars(filename, strFilename);

    cv::Mat src = cv::imread(sFilename);

    purlaw::cvhelper helper;
    std::vector<cv::Point> points;
    helper.GetDocumentRect(src, points);
    std::vector<cv::Point2f> src_points;
    for (auto &i: points) {
        src_points.emplace_back(i);
    }
    if (points.size() != 4) return;
    cv::Mat dst = helper.CutKeyPosition(src, src_points);
    cv::imwrite(sFilename, dst);
}

extern "C"
JNIEXPORT jstring JNICALL
Java_com_tianzhu_purlaw_MainActivity_speechToText(JNIEnv *env, jobject thiz, jstring filename,
                                                  jstring model_path) {
    const char* strFilename = env->GetStringUTFChars(filename, nullptr);
    std::string sFilename = strFilename;
    env->ReleaseStringUTFChars(filename, strFilename);

    const char* strOcrModelPath = env->GetStringUTFChars(model_path, nullptr);
    std::string sModelPath = strOcrModelPath;
    env->ReleaseStringUTFChars(model_path, strOcrModelPath);

    jclass jclazz = env->FindClass("com/tianzhu/purlaw/MainActivity");
    jmethodID flushFunId = env->GetMethodID(jclazz, "flushUI", "(Ljava/lang/String;)V");
    jobject classObject = env->AllocObject(jclazz);

//    recognizer.initialize(sModelPath);
//    purlaw::sherpa_stream stream(recognizer.rec, 100);

    purlaw::sherpa_recognizer rec(sModelPath);
    purlaw::sherpa_stream stream(&rec, 100);

    std::string log = "";
    log += sFilename + "\n";
    log += sModelPath + "\n";

    FILE *file = fopen(sFilename.c_str(), "rb");
    fseek(file, 0, SEEK_END);
    long size = ftell(file);
    fseek(file, 0, SEEK_SET);
    int16_t *buffer = (int16_t *) malloc(size - 44);
    fseek(file, 44, SEEK_SET); //前44个字节是文件头，后面的全是 16bit pcm 数据
    fread(buffer, 1, size - 44, file);
    fclose(file);

    const int perN = 3200; // 0.2s (16000*0.2)
    int n = size / 2 / perN;
    std::string result = "";

    for (int i = 0; i < n; i++) {
        stream.feed(buffer + i * perN, perN);
        result = stream.compute();
        jstring resultStr = env->NewStringUTF(result.c_str());
        env->CallVoidMethod(classObject, flushFunId, resultStr);
//        env->ReleaseStringUTFChars(resultStr, result.c_str());
    }

    //尾部数据
    if (size % perN != 0) {
        stream.feed(buffer + n * perN, (size - 44) / 2 - n * perN);
        result = stream.compute();
        jstring resultStr = env->NewStringUTF(result.c_str());
        env->CallVoidMethod(classObject, flushFunId, resultStr);
//        env->ReleaseStringUTFChars(resultStr, result.c_str());
    }

    // 最后塞入0.3s的静音，导出全部隐状态
    int16_t *silence = new int16_t[16000 * 0.3 / 2];
    memset(silence, 0, 16000 * 0.3);
    stream.feed(silence, 16000 * 0.3 / 2);
    result = stream.compute();
    jstring resultStr = env->NewStringUTF(result.c_str());
    env->CallVoidMethod(classObject, flushFunId, resultStr);
//    env->ReleaseStringUTFChars(resultStr, result.c_str());
    delete[] silence;
    free(buffer);
    log += result;
    jstring endStr = env->NewStringUTF("<EOF>");
    env->CallVoidMethod(classObject, flushFunId, endStr);

    return env->NewStringUTF(log.c_str());
}
