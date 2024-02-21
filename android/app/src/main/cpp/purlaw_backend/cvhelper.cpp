//
// Created by wuyex on 2024/1/20.
//

#include <opencv2/opencv.hpp>
#include <vector>
#include <ncnn/net.h>
#include <ncnn/layer.h>
#include <iostream>
#include <algorithm>
#include <fstream>
#include "clipper.hpp"
#include "cvhelper.h"


namespace purlaw {
    std::vector<std::vector<cv::Point>> cvhelper::findCorners(const cv::Mat &image) {
        cv::Mat gaussImage;
        cv::GaussianBlur(image, gaussImage, cv::Size(5, 5), 0);
        cv::threshold(gaussImage, gaussImage, 0, 255, cv::THRESH_BINARY | cv::THRESH_OTSU);
        cv::Canny(gaussImage, gaussImage, 50, 200);
        cv::morphologyEx(gaussImage, gaussImage, cv::MORPH_CLOSE,
                         cv::Mat::ones(5, 5, CV_32F));
        std::vector<std::vector<cv::Point>> contours;
        std::vector<cv::Vec4i> hierarchy;
        cv::findContours(gaussImage, contours, hierarchy, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);


        std::vector<std::vector<cv::Point>> ret;

        for (auto &contour: contours) {
            double peri = cv::arcLength(contour, true);
            std::vector<cv::Point> approx;
            cv::approxPolyDP(contour, approx, 0.05 * peri, true);
            if (approx.size() == 4 && cv::isContourConvex(approx) && cv::contourArea(approx) > 1000) {
                ret.push_back(approx);
            }
        }

        return ret;
    }

    void cvhelper::GetDocumentRect(cv::Mat &src, std::vector<cv::Point> &ret_points) {
        int shrunkImageHeight = 500;
        cv::Mat shrunkImage;
        cv::resize(src, shrunkImage, cv::Size(shrunkImageHeight * src.cols / src.rows, shrunkImageHeight));

        cv::cvtColor(shrunkImage, shrunkImage, cv::COLOR_BGR2Luv);
        std::vector<cv::Mat> channels;
        cv::split(shrunkImage, channels);

        std::vector<std::vector<cv::Point>> documentCorners;

        for (const auto &channel: channels) {
            std::vector<std::vector<cv::Point>> corners = findCorners(channel);
            if (!corners.empty()) {
                double maxArea = 0.0;
                std::vector<cv::Point> maxAreaContourIt;
                for (const auto &contour: corners) {
                    double area = cv::contourArea(contour);
                    if (area > maxArea) {
                        maxArea = area;
                        maxAreaContourIt = contour;
                    }
                }

                if (maxArea > 0) {
                    std::vector<cv::Point> scaledContour;
                    for (const auto &point: maxAreaContourIt) {
                        cv::Point scaledPoint;
                        scaledPoint.x = static_cast<int>(point.x * static_cast<double>(src.rows) /
                                                         shrunkImageHeight);
                        scaledPoint.y = static_cast<int>(point.y * static_cast<double>(src.rows) /
                                                         shrunkImageHeight);
                        scaledContour.push_back(scaledPoint);
                    }
                    documentCorners.push_back(scaledContour);
                }
            }
        }

        if (documentCorners.size() == 0) {
            return;
        }

        std::vector<cv::Point> maxDocumentCorners;
        double maxDocumentArea = 0.0;
        for (const auto &documentCorner: documentCorners) {
            double area = cv::contourArea(documentCorner);
            if (area > maxDocumentArea) {
                maxDocumentArea = area;
                maxDocumentCorners = documentCorner;
            }
        }

        ret_points = maxDocumentCorners;
    }

    cv::Mat cvhelper::CutKeyPosition(cv::Mat &src, std::vector<cv::Point2f> &src_points) {
        // 透视变换
        cv::Point2f dst_points[4];
        dst_points[0] = cv::Point2f(src.cols, 0);
        dst_points[1] = cv::Point2f(0, 0);
        dst_points[2] = cv::Point2f(0, src.rows);
        dst_points[3] = cv::Point2f(src.cols, src.rows);

        cv::Point2f tL = src_points[1];
        cv::Point2f tR = src_points[0];
        cv::Point2f bR = src_points[3];
        cv::Point2f bL = src_points[2];

        int width = (std::min)(cv::norm(tR - tL), cv::norm(bR - bL));
        int height = (std::min)(cv::norm(tR - bR), cv::norm(tL - bL));


        cv::Mat M = cv::getPerspectiveTransform(src_points.data(), dst_points);
        cv::Mat dst;
        cv::warpPerspective(src, dst, M, src.size());
        // 缩放图像
        cv::resize(dst, dst, cv::Size(width, height));
        return dst;
    }

    ppocr::ppocr(std::string model_path) {
        using namespace std;
        dbNet.opt.num_threads = 4;
        crnnNet.opt.num_threads = 1;
        dbNet.load_param((model_path + "/ch_PP-OCRv3_det_fp16.param").c_str());
        dbNet.load_model((model_path + "/ch_PP-OCRv3_det_fp16.bin").c_str());
        crnnNet.load_param((model_path + "/ch_PP-OCRv3_rec_fp16.param").c_str());
        crnnNet.load_model((model_path + "/ch_PP-OCRv3_rec_fp16.bin").c_str());
        ifstream keylist((model_path + "/paddleocr_keys.txt").c_str());
        string line;
        while (getline(keylist, line)) {
            keys.push_back(line);
        }
    }

    std::vector<TextBox> ppocr::detect(cv::Mat &src) // 必须为24位图像
    {
        std::vector<TextBox> objects;
        objects = getTextBoxes(src, 0.3f, 0.5, 1.6);

        std::vector<cv::Mat> partImages = getPartImages(src, objects);

        std::vector<TextLine> textLines = getTextLines(partImages);

        if (textLines.size() > 0) {
            for (int i = 0; i < textLines.size(); i++) {
                objects[i].text = textLines[i].text;
                //复制位置
                for (int j = 0; j < textLines[i].charPositions.size(); j++)
                    objects[i].charPositions.emplace_back(textLines[i].charPositions[j] + objects[i].boxPoint[0].x);
            }
        }
        std::vector<TextBox> objects_copy = objects;

        objects.clear();
        for (auto x: objects_copy)
            if (x.text != "")
                objects.emplace_back(x);

        return objects;
    }

    inline std::vector<cv::Point>
    ppocr::getMinBoxes(const std::vector<cv::Point> &inVec, float &minSideLen, float &allEdgeSize) {
        std::vector<cv::Point> minBoxVec;
        cv::RotatedRect textRect = cv::minAreaRect(inVec);
        cv::Mat boxPoints2f;
        cv::boxPoints(textRect, boxPoints2f);

        float *p1 = (float *) boxPoints2f.data;
        std::vector<cv::Point> tmpVec;
        for (int i = 0; i < 4; ++i, p1 += 2) {
            tmpVec.emplace_back(int(p1[0]), int(p1[1]));
        }

        std::sort(tmpVec.begin(), tmpVec.end(), [](const cv::Point &a, const cv::Point &b) {
            return a.x < b.x;
        });

        minBoxVec.clear();

        int index1, index2, index3, index4;
        if (tmpVec[1].y > tmpVec[0].y) {
            index1 = 0;
            index4 = 1;
        } else {
            index1 = 1;
            index4 = 0;
        }

        if (tmpVec[3].y > tmpVec[2].y) {
            index2 = 2;
            index3 = 3;
        } else {
            index2 = 3;
            index3 = 2;
        }

        minBoxVec.clear();

        minBoxVec.push_back(tmpVec[index1]);
        minBoxVec.push_back(tmpVec[index2]);
        minBoxVec.push_back(tmpVec[index3]);
        minBoxVec.push_back(tmpVec[index4]);

        minSideLen = (std::min)(textRect.size.width, textRect.size.height);
        allEdgeSize = 2.f * (textRect.size.width + textRect.size.height);

        return minBoxVec;
    }

    inline float ppocr::boxScoreFast(const cv::Mat &inMat, const std::vector<cv::Point> &inBox) {
        std::vector<cv::Point> box = inBox;
        int width = inMat.cols;
        int height = inMat.rows;
        int maxX = -1, minX = 1000000, maxY = -1, minY = 1000000;
        for (int i = 0; i < box.size(); ++i) {
            if (maxX < box[i].x)
                maxX = box[i].x;
            if (minX > box[i].x)
                minX = box[i].x;
            if (maxY < box[i].y)
                maxY = box[i].y;
            if (minY > box[i].y)
                minY = box[i].y;
        }
        maxX = (std::min)((std::max)(maxX, 0), width - 1);
        minX = (std::max)((std::min)(minX, width - 1), 0);
        maxY = (std::min)((std::max)(maxY, 0), height - 1);
        minY = (std::max)((std::min)(minY, height - 1), 0);

        for (int i = 0; i < box.size(); ++i) {
            box[i].x = box[i].x - minX;
            box[i].y = box[i].y - minY;
        }

        std::vector<std::vector<cv::Point>> maskBox;
        maskBox.push_back(box);
        cv::Mat maskMat(maxY - minY + 1, maxX - minX + 1, CV_8UC1, cv::Scalar(0, 0, 0));
        cv::fillPoly(maskMat, maskBox, cv::Scalar(1, 1, 1), 1);
        return cv::mean(inMat(cv::Rect(cv::Point(minX, minY), cv::Point(maxX + 1, maxY + 1))).clone(),
                        maskMat)
                .val[0];
    }

    inline std::vector<cv::Point>
    ppocr::unClip(const std::vector<cv::Point> &inBox, float perimeter, float unClipRatio) {
        std::vector<cv::Point> outBox;
        ClipperLib::Path poly;

        for (int i = 0; i < inBox.size(); ++i) {
            poly.push_back(ClipperLib::IntPoint(inBox[i].x, inBox[i].y));
        }

        double distance = unClipRatio * ClipperLib::Area(poly) / (double) perimeter;

        ClipperLib::ClipperOffset clipperOffset;
        clipperOffset.AddPath(poly, ClipperLib::JoinType::jtRound, ClipperLib::EndType::etClosedPolygon);
        ClipperLib::Paths polys;
        polys.push_back(poly);
        clipperOffset.Execute(polys, distance);

        outBox.clear();
        std::vector<cv::Point> rsVec;
        for (int i = 0; i < polys.size(); ++i) {
            ClipperLib::Path tmpPoly = polys[i];
            for (int j = 0; j < tmpPoly.size(); ++j) {
                outBox.emplace_back(tmpPoly[j].X, tmpPoly[j].Y);
            }
        }
        return outBox;
    }

    inline std::vector<TextBox> ppocr::findRsBoxes(const cv::Mat &fMapMat, const cv::Mat &norfMapMat,
                                                   const float boxScoreThresh, const float unClipRatio) {
        float minArea = 3;
        std::vector<TextBox> rsBoxes;
        rsBoxes.clear();
        std::vector<std::vector<cv::Point>> contours;
        cv::findContours(norfMapMat, contours, cv::RETR_LIST, cv::CHAIN_APPROX_SIMPLE);
        for (int i = 0; i < contours.size(); ++i) {
            float minSideLen, perimeter;
            std::vector<cv::Point> minBox = getMinBoxes(contours[i], minSideLen, perimeter);
            if (minSideLen < minArea)
                continue;
            float score = boxScoreFast(fMapMat, contours[i]);
            if (score < boxScoreThresh)
                continue;
            //---use clipper start---
            std::vector<cv::Point> clipBox = unClip(minBox, perimeter, unClipRatio);
            std::vector<cv::Point> clipMinBox = getMinBoxes(clipBox, minSideLen, perimeter);
            //---use clipper end---

            if (minSideLen < minArea + 2)
                continue;

            for (int j = 0; j < clipMinBox.size(); ++j) {
                clipMinBox[j].x = (clipMinBox[j].x / 1.0);
                clipMinBox[j].x = (std::min)((std::max)(clipMinBox[j].x, 0), norfMapMat.cols);

                clipMinBox[j].y = (clipMinBox[j].y / 1.0);
                clipMinBox[j].y = (std::min)((std::max)(clipMinBox[j].y, 0), norfMapMat.rows);
            }

            rsBoxes.emplace_back(TextBox{clipMinBox, score});
        }
        reverse(rsBoxes.begin(), rsBoxes.end());

        return rsBoxes;
    }

    inline std::vector<TextBox>
    ppocr::getTextBoxes(const cv::Mat &src, float boxScoreThresh, float boxThresh, float unClipRatio) {
        int width = src.cols;
        int height = src.rows;
        int target_size = 640;
        // pad to multiple of 32
        int w = width;
        int h = height;
        float scale = 1.f;
        if (w > h) {
            scale = (float) target_size / w;
            w = target_size;
            h = h * scale;
        } else {
            scale = (float) target_size / h;
            h = target_size;
            w = w * scale;
        }

        ncnn::Mat input = ncnn::Mat::from_pixels_resize(src.data, ncnn::Mat::PIXEL_RGB, width, height, w, h);

        // pad to target_size rectangle
        int wpad = (w + 31) / 32 * 32 - w;
        int hpad = (h + 31) / 32 * 32 - h;

        ncnn::Mat in_pad;
        ncnn::copy_make_border(input, in_pad, hpad / 2, hpad - hpad / 2, wpad / 2, wpad - wpad / 2,
                               ncnn::BORDER_CONSTANT, 0.f);

        const float meanValues[3] = {0.485 * 255, 0.456 * 255, 0.406 * 255};
        const float normValues[3] = {1.0 / 0.229 / 255.0, 1.0 / 0.224 / 255.0, 1.0 / 0.225 / 255.0};

        in_pad.substract_mean_normalize(meanValues, normValues);
        ncnn::Extractor extractor = dbNet.create_extractor();
        extractor.input("input0", in_pad);
        ncnn::Mat out;
        extractor.extract("out1", out);
        cv::Mat fMapMat(in_pad.h, in_pad.w, CV_32FC1, (float *) out.data);
        cv::Mat norfMapMat;
        norfMapMat = fMapMat > boxThresh;

        cv::dilate(norfMapMat, norfMapMat, cv::Mat(), cv::Point(-1, -1), 1);

        std::vector<TextBox> result = findRsBoxes(fMapMat, norfMapMat, boxScoreThresh, 2.0f);
        for (int i = 0; i < result.size(); i++) {
            for (int j = 0; j < result[i].boxPoint.size(); j++) {
                float x = (result[i].boxPoint[j].x - (wpad / 2)) / scale;
                float y = (result[i].boxPoint[j].y - (hpad / 2)) / scale;
                x = std::max(std::min(x, (float) (width - 1)), 0.f);
                y = std::max(std::min(y, (float) (height - 1)), 0.f);
                result[i].boxPoint[j].x = x;
                result[i].boxPoint[j].y = y;
            }
        }

        return result;
    }

    inline TextLine ppocr::scoreToTextLine(const std::vector<float> &outputData, int h, int w) {
        int keySize = keys.size();
        std::string strRes;
        std::vector<float> scores;
        std::vector<float> positions;

        int lastIndex = 0;
        int maxIndex;
        float maxValue;

        for (int i = 0; i < h; i++) {
            maxIndex = 0;
            maxValue = -1000.f;

            maxIndex = int(argmax(outputData.begin() + i * w, outputData.begin() + i * w + w));
            maxValue = float(
                    *std::max_element(outputData.begin() + i * w, outputData.begin() + i * w + w)); // / partition;
            if (maxIndex > 0 && maxIndex < keySize &&
                (!(i > 0 && maxIndex == lastIndex)))                   // CTC特性：连续相同即判定为同一个字
            {
                scores.emplace_back(maxValue);
                strRes.append(keys[maxIndex - 1]);
                positions.emplace_back((float) i / (float) h);//这里还只是相对位置
            }
            lastIndex = maxIndex;
        }
        return {strRes, scores, positions};
    }

    inline TextLine ppocr::getTextLine(const cv::Mat &src) {
        float scale = (float) dstHeight / (float) src.rows;
        int dstWidth = int((float) src.cols * scale);

        cv::Mat srcResize;

        cv::resize(src, srcResize, cv::Size(dstWidth, dstHeight));

        ncnn::Mat input;
        input = ncnn::Mat::from_pixels(srcResize.data, ncnn::Mat::PIXEL_RGB, srcResize.cols, srcResize.rows);
        //同理
        const float mean_vals[3] = {127.5, 127.5, 127.5};
        const float norm_vals[3] = {1.0 / 127.5, 1.0 / 127.5, 1.0 / 127.5};
        input.substract_mean_normalize(mean_vals, norm_vals);

        ncnn::Extractor extractor = crnnNet.create_extractor();
        // extractor.set_num_threads(2);
        extractor.input("input", input);

        ncnn::Mat out;
        extractor.extract("out", out);
        float *floatArray = (float *) out.data;
        std::vector<float> outputData(floatArray, floatArray + out.h * out.w);
        //读取数据，执行CTC算法解析数据
        TextLine res = scoreToTextLine(outputData, out.h, out.w);
        return res;
    }

    inline std::vector<TextLine> ppocr::getTextLines(std::vector<cv::Mat> &partImg) {
        int size = partImg.size();
        std::vector<TextLine> textLines(size);

        //带LSTM的模型在外面开多线程加速效果会比在里面开多线程加速好
#pragma omp parallel for num_threads(4)

        for (int i = 0; i < size; ++i) {
            TextLine textLine = getTextLine(partImg[i]);
            textLines[i] = textLine;
            //还原坐标
            for (int j = 0; j < textLines[i].charPositions.size(); j++) {
                textLines[i].charPositions[j] = textLines[i].charPositions[j] * (float) partImg[i].cols;
            }
        }
        return textLines;
    }

    inline cv::Mat ppocr::getRotateCropImage(const cv::Mat &src, std::vector<cv::Point> box) {
        cv::Mat image;
        src.copyTo(image);
        std::vector<cv::Point> points = box;

        int collectX[4] = {box[0].x, box[1].x, box[2].x, box[3].x};
        int collectY[4] = {box[0].y, box[1].y, box[2].y, box[3].y};
        int left = int(*std::min_element(collectX, collectX + 4));
        int right = int(*std::max_element(collectX, collectX + 4));
        int top = int(*std::min_element(collectY, collectY + 4));
        int bottom = int(*std::max_element(collectY, collectY + 4));

        cv::Mat imgCrop;
        image(cv::Rect(left, top, right - left, bottom - top)).copyTo(imgCrop);

        for (int i = 0; i < points.size(); i++) {
            points[i].x -= left;
            points[i].y -= top;
        }

        int imgCropWidth = int(sqrt(pow(points[0].x - points[1].x, 2) +
                                    pow(points[0].y - points[1].y, 2)));
        int imgCropHeight = int(sqrt(pow(points[0].x - points[3].x, 2) +
                                     pow(points[0].y - points[3].y, 2)));

        if (imgCropWidth == 0 || imgCropHeight == 0)
            return src.clone();

        cv::Point2f ptsDst[4];
        ptsDst[0] = cv::Point2f(0., 0.);
        ptsDst[1] = cv::Point2f(imgCropWidth, 0.);
        ptsDst[2] = cv::Point2f(imgCropWidth, imgCropHeight);
        ptsDst[3] = cv::Point2f(0.f, imgCropHeight);

        cv::Point2f ptsSrc[4];
        ptsSrc[0] = cv::Point2f(points[0].x, points[0].y);
        ptsSrc[1] = cv::Point2f(points[1].x, points[1].y);
        ptsSrc[2] = cv::Point2f(points[2].x, points[2].y);
        ptsSrc[3] = cv::Point2f(points[3].x, points[3].y);

        cv::Mat M = cv::getPerspectiveTransform(ptsSrc, ptsDst);

        cv::Mat partImg;
        cv::warpPerspective(imgCrop, partImg, M,
                            cv::Size(imgCropWidth, imgCropHeight),
                            cv::BORDER_REPLICATE);

        if (float(partImg.rows) >= float(partImg.cols) * 1.5) {
            cv::Mat srcCopy = cv::Mat(partImg.rows, partImg.cols, partImg.depth());
            cv::transpose(partImg, srcCopy);
            cv::flip(srcCopy, srcCopy, 0);
            return srcCopy;
        } else {
            return partImg;
        }
    }

    inline std::vector<cv::Mat> ppocr::getPartImages(const cv::Mat &src, std::vector<TextBox> &textBoxes) {
        std::sort(textBoxes.begin(), textBoxes.end(), [](const TextBox &a, const TextBox &b) {
            return abs(a.boxPoint[0].x - a.boxPoint[1].x) > abs(b.boxPoint[0].x - b.boxPoint[1].x);
        });
        std::vector<cv::Mat> partImages;
        if (textBoxes.size() > 0) {
            for (int i = 0; i < textBoxes.size(); ++i) {
                cv::Mat partImg = getRotateCropImage(src, textBoxes[i].boxPoint);
                partImages.emplace_back(partImg);
            }
        }

        return partImages;
    }

    std::string align_text(std::vector<TextBox> &res) {
        std::sort(res.begin(), res.end(), [](const TextBox &a, const TextBox &b) {
            return a.boxPoint[0].x < b.boxPoint[0].x;
        });
        std::vector<int> already_IN;
        std::vector<std::pair<int, std::string>> line_list;
        for (int i = 0; i < res.size(); i++) {
            if (find(already_IN.begin(), already_IN.end(), res[i].boxPoint[0].x) != already_IN.end()) {
                continue;
            }
            std::string line_txt = res[i].text;
            already_IN.push_back(res[i].boxPoint[0].x);

            auto y_i_points = {res[i].boxPoint[0].y, res[i].boxPoint[1].y, res[i].boxPoint[2].y, res[i].boxPoint[3].y};

            int min_I_y = *std::min_element(y_i_points.begin(), y_i_points.end());
            int max_I_y = *std::max_element(y_i_points.begin(), y_i_points.end());

            auto curr = Interval(min_I_y, max_I_y);
            int curr_mid = min_I_y + (max_I_y - min_I_y) / 2;

            for (int j = i + 1; j < res.size(); j++) {
                if (find(already_IN.begin(), already_IN.end(), res[i].boxPoint[0].x) != already_IN.end()) {
                    continue;
                }

                auto y_j_points = {res[j].boxPoint[0].y, res[j].boxPoint[1].y, res[j].boxPoint[2].y, res[j].boxPoint[3].y};

                int min_J_y = *std::min_element(y_j_points.begin(), y_j_points.end());
                int max_J_y = *std::max_element(y_j_points.begin(), y_j_points.end());

                auto next_j = Interval(min_J_y, max_J_y);


                if (curr.overlaps(next_j) && next_j.in(curr_mid)) {
                    line_txt += " " + res[j].text;
                    already_IN.push_back(res[j].boxPoint[0].x);

                    curr = Interval(min_J_y + (max_J_y - min_J_y) / 3, max_J_y);
                    curr_mid = min_I_y + (max_I_y - min_I_y) / 2;
                }
            }
            line_list.emplace_back(res[i].boxPoint[0].y, line_txt);
        }
        sort(line_list.begin(), line_list.end(),
             [](const std::pair<int, std::string> &a, const std::pair<int, std::string> &b) {
                 return a.first < b.first;
             });
        auto txt = [line_list]() {
            std::string res;
            for (auto &i: line_list) {
                res += i.second + "\n";
            }
            return res;
        }();
        return txt;
    }
} // purlaw