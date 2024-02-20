#include <jni.h>
#include <string.h>
#include <string>
#include <iostream>
#include "opencv2/opencv.hpp"
#include "purlaw_backend/cvhelper.h"

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
    return env->NewStringUTF(("OpenCV Version " + cv::getVersionString()).c_str());
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

//    std::vector<std::string> res;
//    for (int i = 0; i < _res.size(); ++i) {
//        res.push_back(_res[i].text);
//    }
//
    auto returnObj = env->NewObjectArray(1, env->FindClass("java/lang/String"), 0);
//
//    for (int i = 0; i < res.size(); ++i) {
//        auto v = res[i];
//        jstring str = env->NewStringUTF(v.c_str());
//        env->SetObjectArrayElement(returnObj, i, str);
//        env->DeleteLocalRef(str);
//    }

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