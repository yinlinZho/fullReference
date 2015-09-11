function [befor_roi,after_roi,cmdout] = roi(image_path,roi_path,option,feature)
    [pathstr,name,ext] = fileparts(image_path);
    if(strcmp(option,'auto'))
        cmd = [roi_path,' -',option,' ',image_path,' ',pathstr,filesep,name,'_new',ext];
        after_roi = [pathstr,filesep,name,'_new',ext];
    else if(strcmp(option, 's2'))
            
            if ~isempty(strfind(image_path,'_new'))
                name = strrep(name,'_new','');
            end
            cmd = [roi_path,' -',option,' ',image_path,' ',pathstr,filesep,name,'_fit',ext,' ',num2str(feature(1)),' ',num2str(feature(2)),' ',num2str(feature(3)),' ',num2str(feature(4))]
            after_roi = [pathstr,filesep,name,'_fit',ext];
        end
    end   
    [status,cmdout] = system(cmd);
    befor_roi = image_path;
    
end