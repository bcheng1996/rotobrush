function Pts=OpenSurf(I, varargin)
%detectSURFFeatures Finds SURF features.
%   POINTS = detectSURFFeatures(I) returns a SURFPoints object, POINTS, 
%   containing information about SURF features detected in a 2-D grayscale 
%   image I. detectSURFFeatures uses Speeded-Up Robust Features 
%   (SURF) algorithm to find blob features.
%
%   POINTS = detectSURFFeatures(I,PARAM1,VAL1,PARAM2,VAL2,...) sets 
%   additional parameters. Each string parameter is followed by a value as
%   indicated below:
%
%   'MetricThreshold'  A non-negative scalar which specifies a threshold
%                      for selecting the strongest features. Decrease it to
%                      return more blobs.
%
%                      Default: 1000.0
%
%   'NumOctaves'       Integer scalar, NumOctaves >= 1. Number of octaves 
%                      to use. Increase this value to detect larger
%                      blobs. Recommended values are between 1 and 4.
%
%                      Default: 3
%
%   'NumScaleLevels'   Integer scalar, NumScaleLevels >= 3. Number of
%                      scale levels to compute per octave. Increase
%                      this number to detect more blobs at finer scale 
%                      increments. Recommended values are between 3 and 6.
%
%                      Default: 4
%
%   Notes
%   -----
%   - Each octave spans a number of scales that are analyzed using varying
%     size filters:
%         octave     filter sizes
%         ------     ------------------------------
%           1        9x9,   15x15, 21x21, 27x27, ...
%           2        15x15, 27x27, 39x39, 51x51, ...
%           3        27x27, 51x51, 75x75, 99x99, ...
%           4        ....
%     Higher octaves use larger filters and sub-sample the image data.
%     Larger number of octaves will result in finding larger size blobs. 
%     'NumOctaves' should be selected appropriately for the image size.
%     For example, 50x50 image should not require NumOctaves > 2. The
%     number of filters used per octave is controlled by the parameter
%     'NumScaleLevels'. To analyze the data in a single octave, at least 3
%     levels are required.
%
%   Class Support
%   -------------
%   The input image I can be logical, uint8, int16, uint16, single, 
%   or double, and it must be real and nonsparse.
%
%   Example
%   -------  
%   % Detect interest points and mark their locations
%   I = imread('cameraman.tif');
%   points = detectSURFFeatures(I);
%   imshow(I); hold on;
%   plot(points.selectStrongest(10));
%
%   See also SURFPoints, extractFeatures, matchFeatures

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2012/01/23 21:10:32 $

%   References:
%      Herbert Bay, Andreas Ess, Tinne Tuytelaars, Luc Van Gool "SURF: 
%      Speeded Up Robust Features", Computer Vision and Image Understanding
%      (CVIU), Vol. 110, No. 3, pp. 346--359, 2008

[Iu8 params] = parseInputs(I,varargin{:});

PtsStruct=ocvFastHessianDetector(Iu8, params);

Pts = SURFPoints(PtsStruct.Location, PtsStruct);

%==========================================================================
% Parse and check inputs
%==========================================================================
function [Iu8 params] = parseInputs(I, varargin)

validateattributes(I,{'logical', 'uint8', 'int16', 'uint16', ...
    'single', 'double'}, {'2d', 'nonempty', 'nonsparse', 'real'},...
                   mfilename, 'I', 1);

if isa(I,'uint8')
    Iu8 = I;
else
    Iu8 = im2uint8(I);
end

% Parse the PV pairs
parser = inputParser;
parser.CaseSensitive = true;
parser.addParamValue('MetricThreshold', 1000, @checkMetricThreshold);
parser.addParamValue('NumOctaves',         3, @checkNumOctaves);
parser.addParamValue('NumScaleLevels',     4, @checkNumScaleLevels);

% Parse input
parser.parse(varargin{:});

% Populate the parameters to pass into OpenCV's icvfastHessianDetector()
params.nOctaveLayers    = parser.Results.NumScaleLevels-2;
params.nOctaves         = parser.Results.NumOctaves;
params.hessianThreshold = parser.Results.MetricThreshold;

%==========================================================================
function tf = checkMetricThreshold(threshold)
validateattributes(threshold, {'numeric'}, {'scalar','finite',...
    'nonsparse', 'real', 'nonnegative'}, mfilename);
tf = true;

%==========================================================================
function tf = checkNumOctaves(numOctaves)
validateattributes(numOctaves, {'numeric'}, {'integer',... 
    'nonsparse', 'real', 'scalar', 'positive'}, mfilename);
tf = true;

%==========================================================================
function tf = checkNumScaleLevels(scales)
validateattributes(scales, {'numeric'}, {'integer',...
    'nonsparse', 'real', 'scalar', '>=', 3}, mfilename);
tf = true;


