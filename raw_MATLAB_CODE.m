function test

clc;
close all;
workspace; 
format longg;
format compact;
fontSize = 10;


%----------------------------------------------------------------------------------------------------------------


img1=imread('1.jpg');
subplot(2,6,1)
imshow(img1)
title('1st image', 'FontSize', fontSize);
axis on;
img2=imread('2.jpg');
subplot(2,6,2)
imshow(img2)
title('2nd image', 'FontSize', fontSize);
axis on;
img3=imread('3.jpg');
subplot(2,6,3)
imshow(img3)
title('3rd image', 'FontSize', fontSize);
axis on;
img4=imread('4.jpg');
subplot(2,6,4)
imshow(img4)
title('4th image', 'FontSize', fontSize);
axis on;
img5=imread('5.jpg');
subplot(2,6,5)
imshow(img5)
title('5th image', 'FontSize', fontSize);
axis on;
im = imread('1.jpg');
for i = 2:6
im = imadd(im,imread(sprintf('%d.jpg',i)));
end
im = im/6;
subplot(2,6,6)
imshow(im,[]);
title('Averaged image', 'FontSize', fontSize);
axis on;

%-------------------------------------------------------------------------------------------------------------------


baseFileName = 'final.png';
grayImage = imread(baseFileName);
[rows, columns, numberOfColorBands] = size(grayImage);
if numberOfColorBands > 1
	
	grayImage = grayImage(:,:,2);
end


subplot(2, 6, 7);
imshow(grayImage);
axis on;
title('Cone image', 'FontSize', fontSize);

set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);


[pixelCount, grayLevels] = imhist(grayImage);

pixelCount(1) = 0;
pixelCount(end) = 0;
subplot(2, 6, 8);
bar(grayLevels, pixelCount);
grid on;
title('Histogram of Cone image', 'FontSize', fontSize);
xlim([0 grayLevels(end)]); 



thresholdValue = 75;
binaryImage = grayImage > thresholdValue;
subplot(2, 6, 9);
imshow(binaryImage);
impixelinfo;
axis on;
title('Binary Image', 'FontSize', fontSize);


numberToExtract = 1;
binaryImage = largestarea(binaryImage, numberToExtract);




binaryImage = imfill(binaryImage, 'holes');

se = strel('disk', 3, 0);
binaryImage = imopen(binaryImage, se);


subplot(2, 6, 10);
imshow(binaryImage);
axis on;
title('Largest area covered by the cone', 'FontSize', fontSize);
drawnow;





widths = zeros(1, rows);
leftEdge = zeros(1, rows);
rightEdge = zeros(1, rows);
for row = 1 : rows
	thisRow = binaryImage(row, :);
	leftIndex = find(thisRow, 1, 'first');
	if ~isempty(leftIndex)
		leftEdge(row) = leftIndex;
		rightEdge(row) = find(thisRow, 1, 'last');
		widths(row) = rightEdge(row) - leftEdge(row);
	end
end


subplot(2, 6, 11);
plot(1:rows, widths, 'b-', 'LineWidth', 2);
grid on;
title('Widths of region in cone as a function of line number', 'FontSize', fontSize);
axis on;


x = 90:240;

y = leftEdge(x);
leftCoefficients = polyfit(x, y, 1);
leftAngle = atand(leftCoefficients(1))

subplot(2, 6, 12);
plot(x, y, 'b-', 'LineWidth', 2);
hold on;
y = rightEdge(x);
rightCoefficients = polyfit(x, y, 1);
rightAngle = atand(rightCoefficients(1))
plot(x, y, 'r-', 'LineWidth', 2);
grid on;
coneAngle = abs(leftAngle) + abs(rightAngle);

yLeftFit = polyval(leftCoefficients, x);
plot(x, yLeftFit, 'b-', 'LineWidth', 2);
yRightFit = polyval(rightCoefficients, x);
plot(x, yRightFit, 'r-', 'LineWidth', 2);
legend('left', 'right', 'Location', 'east');

message = sprintf('The angle of cone is: %.1f degrees.', coneAngle);
uiwait(helpdlg(message));

%--------------------------------------------------------------------------------------------------------------------


function binaryImage = largestarea(binaryImage, numberToExtract)
try
	
	[labeledImage, numberOfBlobs] = bwlabel(binaryImage);
	blobMeasurements = regionprops(labeledImage, 'area');
	
	allAreas = [blobMeasurements.Area];
	if numberToExtract > length(allAreas);
		
		numberToExtract = length(allAreas);
	end
	if numberToExtract > 0
		
		[sortedAreas, sortIndexes] = sort(allAreas, 'descend');
	elseif numberToExtract < 0
		[sortedAreas, sortIndexes] = sort(allAreas, 'ascend');
		numberToExtract = -numberToExtract;
	else
		binaryImage = false(size(binaryImage));
		return;
	end
	biggestBlob = ismember(labeledImage, sortIndexes(1:numberToExtract));
	binaryImage = biggestBlob > 0;
catch ME
	errorMessage = sprintf('Error in function ExtractNLargestBlobs().\n\nError Message:\n%s', ME.message);
	fprintf(1, '%s\n', errorMessage);
	uiwait(warndlg(errorMessage));
end

