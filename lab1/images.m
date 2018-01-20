%ims = image_cap(200,0);
imdfs = imagediff(ims);
function [ img_seq ] = image_cap( n_frames , time)
% Takes a sequence of images over some time interval and returns a cell of
% images
%   Detailed explanation goes here
    img_seq = cell(n_frames, 1);
    %img_seq = {};
    for i = 1:n_frames
        [success, im] = mexMTF2('get_frame');
        img_seq{i}=im;
        imshow(im);
        pause(time);
    end
end

function [img_seq_difs] = imagediff(image_set)
%motion
    
    n_frames = length(image_set);
    imm = cell(n_frames, 1);
    %imm = {};
    for i = 1:n_frames
        imm{i} = rgb2gray(image_set{i});
    end
    img_seq_difs = cell(n_frames-1, 1);
    %img_seq_difs = {};
    for i = 1:n_frames-1
        im = uint8(abs(double(imm{i+1}) - double(imm{i})));
        im(im<50) = 0;
        im(im>200) =255;
        img_seq_difs{i} = im;
        imshow(im);
    end
    
end