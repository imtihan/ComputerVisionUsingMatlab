%ims = image_cap(50,0);
imdfs = imagediff(ims);
[M] = opticflow(ims,imdfs, 8);

function [ img_seq ] = image_cap( n_frames , time)
% Takes a sequence of images over some time interval and returns a cell of
% images converted to grayscale
%   Detailed explanation goes here
    img_seq = cell(n_frames, 1);
    %img_seq = {};
    for i = 1:n_frames
        [success, im] = mexMTF2('get_frame');
        img_seq{i}=rgb2gray(im);
        imshow(im);
        pause(time);
    end
end

function [img_seq_difs] = imagediff(image_set)
%motion
    n_frames = length(image_set);
    img_seq_difs = cell(n_frames-1, 1);
    %img_seq_difs = {};
    for i = 1:n_frames-1
        im = uint8(abs(double(image_set{i+1}) - double(image_set{i})));
        im(im<80) = 0;
       
        img_seq_difs{i} = im;
        imshow(im);
        drawnow;
    end
    
end

function [M] = opticflow(images, image_diff, blockSize)
%computes flow vectors
    n_frames = length(image_diff);
    [imageHeight, imageWidth] = size(image_diff{1});
    Xa = (1 : blockSize : imageWidth-1);
    Ya = (1 : blockSize : imageHeight-1);
    [X,Y] = meshgrid(Xa,Ya);
    [U, V] = meshgrid(Xa,Ya);
    [limx limy] = size(X)
    for i = 1:n_frames
        %image_diff{i} = imgaussfilt(image_diff{i});
        for j = 1:limx
            for k = 1:limy
                
                lowx = X(j,k);
                highx = X(j,k) + blockSize-1;
                lowy = Y(j,k);
                highy = Y(j,k) + blockSize-1;
                block = images{i}(lowy:highy,lowx:highx);
                [Ix, Iy] = gradient(double(block));
                Ix = reshape(Ix,[],1);
                Iy = reshape(Iy, [],1);
                block = image_diff{i}(lowy:highy,lowx:highx);
                b = reshape(block, [], 1);
                A = horzcat(Ix, Iy);
                d = linsolve(double(A), double(b));
                U(j,k) = d(1);
                V(j,k) = d(2);
            end
        end   
        imshow(uint8(images{i}));
        hold on;
        quiver(X,Y,U,V,3);
        hold off;
        drawnow;
        M(i) = getframe;
   end
   movie(M);
end