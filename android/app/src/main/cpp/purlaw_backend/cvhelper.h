//
// Created by wuyex on 2024/1/20.
//

#ifndef PURLAW_BACKEND_CVHELPER_H
#define PURLAW_BACKEND_CVHELPER_H

#include <ncnn/net.h>

namespace purlaw {
    template <class ForwardIterator>
    inline static size_t argmax(ForwardIterator first, ForwardIterator last)
    {
        return std::distance(first, std::max_element(first, last));
    }
    struct TextLine
    {
        std::string text;
        std::vector<float> charScores;
        std::vector<float> charPositions;//每个字符的位置
    };
    struct Angle
    {
        int index;
        float score;
    };
    struct TextBox
    {
        std::vector<cv::Point> boxPoint;
        float score;
        std::string text;
        std::vector<int> charPositions;
    };

    class Interval{
    private:
        int start, end;
    public:
        Interval(int start, int end): start(start), end(end) {}
        inline bool overlaps(const Interval &other) {
            return start <= other.end && end >= other.start;
        }
        inline bool in(const int x)
        {
            return x >= start && x <= end;
        }
    };

    class cvhelper {
    public:
        void GetDocumentRect(cv::Mat &src, std::vector<cv::Point> &ret_points);
        cv::Mat CutKeyPosition(cv::Mat &src, std::vector<cv::Point2f> &src_points);
    private:
        std::vector<std::vector<cv::Point>> findCorners(const cv::Mat &image);

    };

    class ppocr {
    public:
        ppocr(std::string model_path);
        std::vector<TextBox> detect(cv::Mat &src);
    private:
        ncnn::Net dbNet;
        ncnn::Net crnnNet;
        std::vector<std::string> keys;

        const int dstHeight = 48;


        inline std::vector<cv::Point> getMinBoxes(const std::vector<cv::Point>& inVec, float& minSideLen, float& allEdgeSize);
        inline float boxScoreFast(const cv::Mat& inMat, const std::vector<cv::Point>& inBox);
        inline std::vector<cv::Point> unClip(const std::vector<cv::Point>& inBox, float perimeter, float unClipRatio);
        inline std::vector<TextBox> findRsBoxes(const cv::Mat& fMapMat, const cv::Mat& norfMapMat,
                                                const float boxScoreThresh, const float unClipRatio);
        inline std::vector<TextBox> getTextBoxes(const cv::Mat& src, float boxScoreThresh, float boxThresh, float unClipRatio);
        inline TextLine scoreToTextLine( const std::vector<float>& outputData, int h, int w);
        inline TextLine getTextLine(const cv::Mat& src);
        inline std::vector<TextLine> getTextLines(std::vector<cv::Mat>& partImg);
        inline cv::Mat getRotateCropImage(const cv::Mat& src, std::vector<cv::Point> box);
        inline std::vector<cv::Mat> getPartImages(const cv::Mat& src, std::vector<TextBox>& textBoxes);
    };

    std::string align_text(std::vector<TextBox> &res);


} // purlaw

#endif //PURLAW_BACKEND_CVHELPER_H
