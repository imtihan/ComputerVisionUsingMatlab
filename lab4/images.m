%ims = image_cap(6,1);
%imdfs = imagediff(ims);
%[M] = opticflow(ims,imdfs, 8);
tracker(10, 10);
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
        im(im<60) = 0;
       
        img_seq_difs{i} = im;
       % imshow(im);
       % drawnow;
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
    [limx limy] = size(X);
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
        quiver(X,Y,U,V,4);
        hold off;
        drawnow;
        M(i) = getframe;
   end
   movie(M);
end

function [] = tracker(stepsize, maxiters)
    img_seq = cell(2,1);
    [success, im] = mexMTF2('get_frame');
    img_seq{2} = rgb2gray(im);
    imshow(im);
    rect = getrect();
    rectangle('Position',rect,'LineWidth',2,'LineStyle','--')
     
    [imageHeight, imageWidth] = size(img_seq{2});
    [success, im] = mexMTF2('get_frame');
    Xa = (1 : imageWidth);
    Ya = (1 : imageHeight);
    [X,Y] = meshgrid(Xa,Ya);
      
    while 1
        [success, im] = mexMTF2('get_frame');
        img_seq{1} = img_seq{2};        %set current frame to last frame
        img_seq{2}=rgb2gray(im);        %get new frame
        imdiffarr = imagediff(img_seq);
        imdiff = imdiffarr{1};
        imdiffd=double(imdiff);
        [IdX, IdY] = gradient(double(img_seq{2}));               % X, Y gradient of the whole image
        
         %get the block we are interested in
         lowx = rect(1);
         highx = rect(1) + rect(3);
         lowy = rect(2);
         highy =rect(2) + rect(4);
         
         %iterate to threshold or tolerance here
         for i = 1:maxiters
      
             XQ = lowx:stepsize:highx;
             YQ = lowy:stepsize:highy;
             [Xq, Yq] = meshgrid(XQ,YQ);
             
             VqX=interp2(X,Y,IdX,Xq,Yq);
             VqY=interp2(X,Y,IdY,Xq,Yq);
             Vqt=interp2(X,Y,imdiffd,Xq,Yq);
             
             Ix = reshape(VqX,[],1);   % X gradient of patch
             Iy = reshape(VqY, [],1);  % Y gradient of patch           
             It = reshape(Vqt, [], 1);   %gets temporal difference in patch
             dI = [Ix, Iy];
             
             dP = (((dI')*dI))\(((It')*dI)');
             lowx= lowx + dP(1);
             lowy = lowy + dP(2);
             highx = lowx + rect(3);
             highy = lowy + rect(4);
             
             if( (dP(1)*dP(1) + dP(2)*dP(2) ) < 0.1)
                 break
             end 
             
         end
        
        rect(1) = lowx;
        rect(2) = highx;
           
        imshow(im);
        hold on;
        rectangle('Position',rect,'LineWidth',2,'LineStyle','--')
        drawnow;
        hold off;
    end
end