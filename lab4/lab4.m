%ims = image_cap(100,0);
%videotracker(1,2,ims);
%livetracker(8,2)
pyramidTracker(1,1)
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

function livetracker(stepsize, maxiters)

    [~, im] = mexMTF2('get_frame');
    im1 = rgb2gray(im);
    dim1 = double(im1);
    imshow(im);
    rect = getrect();
    rectangle('Position',rect,'LineWidth',2,'LineStyle','--')
    lowx = rect(1);
    lowy = rect(2);
    w = rect(3);
    h = rect(4);
    [imlen, imwidth] = size(im1);
    
    Xi = 1:imwidth;
    Yi = 1:imlen;
    [X, Y] = meshgrid(Xi, Yi);
    
    while 1
        [~, im] = mexMTF2('get_frame');
        im2 = rgb2gray(im);
        dim2 =  double(im2);
        imdiff = dim2 - dim1; % temporal gradient
        %imdiff(abs(imdiff) < 60) = 0;
        [dX, dY] = gradient(dim2); %spatial gradient
        
        for i=1:maxiters
            
            XQ = lowx:stepsize:lowx+w;
            YQ = lowy:stepsize:lowy+h;
            [Xq, Yq] = meshgrid(XQ, YQ);
            %Xi(lowx:stepsize:lowx+w),Yi(lowy:stepsize:lowy+h));
           
            VqX = interp2(X,Y,dX,Xq,Yq);
            VqY = interp2(X,Y,dY,Xq,Yq);
            Vqt = interp2(X,Y,imdiff,Xq,Yq);
            VqX = reshape(VqX, [], 1);
            VqY = reshape(VqY, [], 1);
            Vqt = reshape(Vqt, [], 1);
            
            dI = [VqX VqY];
            
            
            V = (dI'*dI)\( dI'*Vqt);
            
            lowx = lowx - V(1);
            lowy = lowy - V(2);
            
            if norm(V,2) < 0.001
                break
            end
        end
        hold on;
        imshow(im2)
        rectangle('Position',[lowx lowy w h],'LineWidth',2,'LineStyle','--')
        drawnow;
        hold off;
        %im1 = im2;
        dim1 = dim2;
    end

end

function videotracker(stepsize, maxiters, imageCells)
    n_frames = length(imageCells);
    if n_frames == 0
        error('Video cells is of size zero');
    end
    im1 = imageCells{1};
    dim1 = double(im1);
    imshow(im1);
    rect = getrect();
    rectangle('Position',rect,'LineWidth',2,'LineStyle','--')
    lowx = rect(1);
    lowy = rect(2);
    w = rect(3);
    h = rect(4);
    [imlen, imwidth] = size(im1);
    
    Xi = 1:imwidth;
    Yi = 1:imlen;
    [X, Y] = meshgrid(Xi, Yi);
    
    for i=2:n_frames
 
        im2 = imageCells{i};
        dim2 =  double(im2);
        imdiff = dim2 - dim1; % temporal gradient
        %imdiff(abs(imdiff) < 60) = 0;
        [dX, dY] = gradient(dim2); %spatial gradient
        
        for i=1:maxiters
            
            
            XQ = lowx:stepsize:lowx+w;
            YQ = lowy:stepsize:lowy+h;
            [Xq, Yq] = meshgrid(XQ, YQ);
            %Xi(lowx:stepsize:lowx+w),Yi(lowy:stepsize:lowy+h));
           
            VqX = interp2(X,Y,dX,Xq,Yq);
            VqY = interp2(X,Y,dY,Xq,Yq);
            Vqt = interp2(X,Y,imdiff,Xq,Yq);
            VqX = reshape(VqX, [], 1);
            VqY = reshape(VqY, [], 1);
            Vqt = reshape(Vqt, [], 1);
            
            dI = [VqX VqY];
            
            
            V = (dI'*dI)\( dI'*Vqt);
            
            lowx = lowx - V(1);
            lowy = lowy - V(2);
            
            if norm(V,2) < 0.01
                break
            end
        end
        hold on;
        imshow(im2)
        rectangle('Position',[lowx lowy w h],'LineWidth',2,'LineStyle','--')
        drawnow;
        hold off;
        %im1 = im2;
        dim1 = dim2;
    end
    
end

function pyramidTracker(stepsize, maxiters)

[~, im] = mexMTF2('get_frame');
    im1 = rgb2gray(im);
    dim1 = double(im1);
    imshow(im);
    rect = getrect();
    rectangle('Position',rect,'LineWidth',2,'LineStyle','--')
    lowx = rect(1);
    lowy = rect(2);
    w = rect(3);
    h = rect(4);
    [imlen, imwidth] = size(im1);
    
    Xi = 1:imwidth;
    Yi = 1:imlen;
    [X, Y] = meshgrid(Xi, Yi);
    [X2, Y2] = meshgrid(Xi(1:imwidth/2), Yi(1:imlen/2));
    [X3, Y3] = meshgrid(Xi(1:imwidth/4), Yi(1:imlen/4));
    while 1
        [~, im] = mexMTF2('get_frame');
        im2 = rgb2gray(im);
        dim2 =  double(im2);
        imdiff = dim2 - dim1; % temporal gradient
        imdiff2 = impyramid(imdiff, 'reduce');
        imdiff3 = impyramid(imdiff2, 'reduce');
        %imdiff(abs(imdiff) < 60) = 0;
        [dX, dY] = gradient(dim2); %spatial gradient
        rdim2 = impyramid(dim2, 'reduce');
        [dX2, dY2] = gradient(rdim2); %spatial gradient
        rrdim2 = impyramid(rdim2, 'reduce');
        [dX3, dY3] = gradient(rrdim2); %spatial gradient
        for i=1:maxiters
            XQ = lowx:stepsize:lowx+w;
            YQ = lowy:stepsize:lowy+h;
            [Xq, Yq] = meshgrid(XQ, YQ);
            
            XQ2 = lowx/2:stepsize:(lowx+w)/2;
            YQ2 = lowy/2:stepsize:(lowy+h)/2;
            [Xq2, Yq2] = meshgrid(XQ2, YQ2);
            
            XQ3 = lowx/4:stepsize:(lowx+w)/4;
            YQ3 = lowy/4:stepsize:(lowy+h)/4;
            [Xq3, Yq3] = meshgrid(XQ3, YQ3);
            %Xi(lowx:stepsize:lowx+w),Yi(lowy:stepsize:lowy+h));
           
            VqX = interp2(X,Y,dX,Xq,Yq);
            VqY = interp2(X,Y,dY,Xq,Yq);
            Vqt = interp2(X,Y,imdiff,Xq,Yq);
            VqX = reshape(VqX, [], 1);
            VqY = reshape(VqY, [], 1);
            Vqt = reshape(Vqt, [], 1);
            dI = [VqX VqY];
            V = (dI'*dI)\( dI'*Vqt);
            lowx = lowx - V(1);
            lowy = lowy - V(2);
            
            
            VqX = interp2(X2,Y2,dX2,Xq2,Yq2);
            VqY = interp2(X2,Y2,dY2,Xq2,Yq2);
            Vqt = interp2(X2,Y2,imdiff2,Xq2,Yq2);
            VqX = reshape(VqX, [], 1);
            VqY = reshape(VqY, [], 1);
            Vqt = reshape(Vqt, [], 1);
            dI = [VqX VqY];
            V = (dI'*dI)\( dI'*Vqt);
            lowx = lowx - V(1);
            lowy = lowy - V(2);
            
            VqX = interp2(X3,Y3,dX3,Xq3,Yq3);
            VqY = interp2(X3,Y3,dY3,Xq3,Yq3);
            Vqt = interp2(X3,Y3,imdiff3,Xq3,Yq3);
            VqX = reshape(VqX, [], 1);
            VqY = reshape(VqY, [], 1);
            Vqt = reshape(Vqt, [], 1);
            dI = [VqX VqY];
            V = (dI'*dI)\( dI'*Vqt);
            lowx = lowx - V(1);
            lowy = lowy - V(2);
            
            if norm(V,2) < 0.001
                break
            end
        end
        disp("here")
        hold on;
        imshow(im2)
        rectangle('Position',[lowx lowy w h],'LineWidth',2,'LineStyle','--')
        drawnow;
        hold off;
        %im1 = im2;
        dim1 = dim2;
    end

end