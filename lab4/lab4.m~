livetracker(2,3)

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
            A = dI'*dI;
            b = dI'*Vqt;
            
            V = A\b;
            
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