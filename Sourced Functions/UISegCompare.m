function [Stats] = UISegCompare()
%UISEGCOMPARE Compare segmentation masks for precision and accuracy.
%Includes UI to select image files. 
%   Detailed explanation goes here

[controlMask,~,impath] = uigetimages('*.bmp','Select Control Image');
testMask = uigetimages('*.bmp','Select Test Mask',impath);

omissionMask = uigetimages('*.bmp','Select Omission Mask (Optional)',impath);

if omissionMask{1}==0
    Stats = SegCompare(controlMask{1},testMask{1});
else
    Stats = SegCompare(controlMask{1},testMask{1},omissionMask{1});
end

end