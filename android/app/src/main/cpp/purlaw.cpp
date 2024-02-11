#include <jni.h>
#include <string.h>
#include <string>
#include "opencv2/core.hpp"

// Write C++ code here.
//
// Do not forget to dynamically load the C++ library into your application.
//
// For instance,
//
// In MainActivity.java:
//    static {
//       System.loadLibrary("purlaw");
//    }
//

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