function main(origin_path,lossy_path)
    tic; 
    fx = 'ssim';   
    %origin_path = 'E:\algorithm\fr\test_size\im1\test.png';
    %lossy_path = 'E:\algorithm\fr\test_size\im1\enlarge.png';
    [pathstr1,origin,ext] = fileparts(origin_path);
    [pathstr2,lossy,ext] = fileparts(lossy_path);
    %1.open log
    logfile = ['log\',origin,'_',lossy, '.log']
    diary(logfile);
    diary on;
    %2.get the ssim result and fittest image 
    maximum = optimize_search(origin_path,lossy_path,str2func(fx));
    %3.combine all result [ssim,vsi,FeatureSIM,msssim]
    result = run([pathstr1,'\',origin,'_fit',ext],[pathstr2,'\',lossy,'_fit',ext]);
    outpath = fullfile(['qa\',origin,'_',lossy,'.csv']);
    A = [maximum result]
    csvwrite(outpath,A)
   
    toc;
    diary off;
end
