function result = run(im1,im2)
        fx = {'VSI','FeatureSIM','msssim'};
        image1 = imread(im1);
        image2 = imread(im2);
        result = zeros(1,numel(fx),'double');
        for i = 1:numel(fx)         
            similarity = str2func(fx{i});
            if(strcmp(fx{i},'msssim'))
                result(i) = similarity(rgb2gray(image1),rgb2gray(image2));
            else
                result(i) = similarity(image1,image2);
            end
        end
end


%VIS
%image1 = imread('E:\capture\testcase51\yy_natural_4.4_lossy511.png');
%image2 = imread('E:\capture\testcase51\yy_natural_4.4_origin510.png');

%sim = VSI(image1, image2)
%ssim
%[mssim, ssim_map] = ssim(img1, img2)
%FSIM
%[FSIM, FSIMc] = FeatureSIM(img1, img2)
%msim
%overall_mssim = msssim(img1, img2)
