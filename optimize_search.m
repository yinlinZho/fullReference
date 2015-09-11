function maximum = optimize_search(origin_path,lossy_path,fx)
    %1.remove the margin of lossy and origin image
    origin_path,lossy_path
    roi_path = 'E:\ROI\ROI2.exe';
    origin_feature = [];
    lossy_feature = [];
    if(exist(origin_path,'file') &&exist(lossy_path,'file'))    
       try
           %1.1.get the feature of the origin image
            [origin_before_roi,origin_after_roi,ocmdout] = roi(origin_path,roi_path,'auto',[]);      
            ocmdout = regexp(ocmdout,'\n','split');
            for i = 4:numel(ocmdout)-1 
                try
                    origin_feature = [origin_feature,[str2double(ocmdout{i})]];
                end
            end
            %1.2.get the feature of the lossy image
            [lossy_before_roi,lossy_after_roi,lcmdout] = roi(lossy_path,roi_path,'auto',[]);
            lcmdout = regexp(lcmdout,'\n','split');
            for i = 4:numel(lcmdout)-1 
                try
                    lossy_feature = [lossy_feature,[str2double(lcmdout{i})]]; 
                end
            end
        catch ME
              disp 'Exception Throw in run calling roi'
        end
    else
          error('image file not found');
    end  
    lossy_feature
    origin_feature
    if(origin_feature(3) >= lossy_feature(3) && origin_feature(4)>=lossy_feature(4))
        disp 'origin larger '
        larger = origin_after_roi;
        smaller = lossy_after_roi;
        maximum = loop_whole(smaller,larger,fx)
        
    else if(origin_feature(3) <= lossy_feature(3) && origin_feature(4)<=lossy_feature(4))
            disp 'lossy larger'
            larger = lossy_after_roi;
            smaller = origin_after_roi;
            maximum = loop_whole(smaller,larger,fx)
        else
            disp 'exception case'
            width = min(origin_feature(3),lossy_feature(3))
            height = min(origin_feature(4),lossy_feature(4))
            maximum = par_find(lossy_before_roi,origin_after_roi,lossy_feature,width,height,fx)
            roi(origin_before_roi,roi_path,'s2',[origin_feature(1),origin_feature(2),width,height]);
        end
    end

end
function maximum = loop_whole(smaller,larger,fx)
    roi_path = 'E:\ROI\ROI2.exe';
    smaller_image = imread(smaller);
    larger_image = imread(larger);
   [srow,scol] = size(smaller_image) ;
   [lrow,lcol] = size(larger_image);
   width = scol/3;
   height = srow;
   left_top = [];
   maximum = 0;
   log = zeros(lcol/3-width,lrow-height,'double');
   sim = find_image(smaller_image,1,height,1,width);
   move_left = lcol/3-width   ; 
   move_down = lrow-height;
   
   if( move_left ~= 0 && move_down ~= 0)
     [x,y] = meshgrid(1:1:move_left,1:1:move_down);    
     for x = 1: move_left
       for y = 1:move_down
           lim = find_image(larger_image,y,height+y-1,x,width+x-1);
           if(size(lim) ==size(sim))
                similarity = fx(lim,sim);   
                log(x,y) = similarity;   
                if(max(maximum,similarity) ~= maximum)       
                    left_top = [x,y];
                    maximum = max(maximum,similarity);
                end
            else
                disp 'dimension diff oim and lim'
            end           
       end
       
     end
   else if(move_left == 0 && move_down ~= 0)
          [x,y] = meshgrid([1],1:1:move_down); 
           x = 1;
           for y = 1:move_down
               lim = find_image(larger_image,y,height+y-1,x,width+x-1);
               if(size(lim) ==size(sim))
                    similarity = fx(lim,sim);   
                    log(x,y) = similarity;   
                    if(max(maximum,similarity) ~= maximum)       
                        left_top = [x,y];
                        maximum = max(maximum,similarity);
                    end
                else
                    disp 'dimension diff oim and lim'
               end           
            end
       else if(move_left ~= 0 && move_down == 0)
               [x,y] = meshgrid(1:1:move_left,[1]); 
               y = 1;
               for x = 1:move_left
                   lim = find_image(larger_image,y,height+y-1,x,width+x-1);
                   if(size(lim) ==size(sim))
                        similarity = fx(lim,sim);   
                        log(x,y) = similarity;   
                        if(max(maximum,similarity) ~= maximum)       
                            left_top = [x,y];
                            maximum = max(maximum,similarity);
                        end
                    else
                        disp 'dimension diff oim and lim'
                   end           
               end
           else
               left_top = [1,1] ;            
               maximum =   fx(smaller_image,larger_image); 
           end
       end
   end
   if(numel(left_top) ~= 0)  
       [left_top(1)-1,left_top(2)-1,width,height]
       roi(larger,roi_path,'s2',[left_top(1)-1,left_top(2)-1,width,height]);
       
   copyfile(smaller,strrep(smaller,'_new','_fit'))
   end 
   log
   maximum
   left_top
  
   h = figure('visible','off')
   axis on;
   if( move_left ~= 0 && move_down ~= 0)
     [x,y] = meshgrid(1:1:move_left,1:1:move_down);
     plot3(x,y,log)  ;
     
    else if(move_left == 0 && move_down ~= 0)
          [x,y] = meshgrid([1],1:1:move_down); 
          plot3(x,y,log)  ;
        else if(move_left ~= 0 && move_down == 0)
               [x,y] = meshgrid(1:1:move_left,[1]);
                plot3(x,y,log)  ;
            else
                 plot([0,1],[maximum,maximum])
            end
        end
   end
   [pathstr,larger_name,ext] = fileparts(larger);
   [pathstr,smaller_name,ext] = fileparts(smaller);
    xlabel('col'); ylabel('row');
    grid on;
    set(h,'visible','on')
    saveas(h,['3dplot\',larger_name,'_',smaller_name,'.fig'])
    set(h,'visible','off')  
   
end

%loop the left corner ,find the best left top vertex
function maximum = par_find(lossy_image,origin_image,roi_feature,width,height,fx)
    roi_path = 'E:\ROI\ROI2.exe';
    origin_after_roi_image = imread(origin_image);
    lossy_before_roi_image = imread(lossy_image);
    log = zeros(20,20,'double');
    maximum = 0.0;
    left_top = [0,0];
    %use the origin after roi as comparison
    oim = find_image(origin_after_roi_image,1,height,1,width);
    for x1 = roi_feature(1) -10 : roi_feature(1) +10
        for y1 = roi_feature(2) -10 :roi_feature(2)    +10   
            lim = find_image(lossy_before_roi_image,y1,y1+height - 1,x1,x1+width - 1);  

            %which algorithm you need to use
            if(size(lim) ==size(oim))
                similarity = fx(lim,oim);
                log(x1-roi_feature(1)+10 + 1,y1-roi_feature(2)+10 + 1) = similarity;          
                if(max(maximum,similarity) ~= maximum)       
                    left_top = [x1,y1];
                    maximum = max(maximum,similarity);
                end
            else
                disp 'dimension diff oim and lim'
            end           
        end
    end  
  
    disp 'similarity in 20*20 matrix'
    log
    maximum
    left_top
    %[x,y] = meshgrid(1:1:21,1:1:21);     
    %plot3(x,y,log)  
    roi(strrep(lossy_image,'_new',''),roi_path,'s2',[left_top(1)-1,left_top(2)-1,width,height]);
    
end

function im = find_image(pic,y1,y2,x1,x2)
    [lrow,lcol,rd] = size(pic);
   
    if (x1 > 0 && y1 > 0 && x2 <= lcol && y2 <= lrow)
        %get part of the image (y1:y2,x1,x2)
       	im = pic(y1:y2,x1:x2,:);    
    else
        im = pic;
        disp 'not cut'
    end
end
function m = max(a,b)
    if(a > b)
        m = a;
    else
        m =b;
    end
end
function m = min(a,b)
    if(a < b)
        m = a;
    else
        m = b;
    end
end