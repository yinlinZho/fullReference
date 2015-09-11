function testcase(rootpath)      
    path_list = multi(rootpath);
    for i = 1:numel(path_list)
        if ~isempty(strfind(path_list{i},'testcase'))
            image_list = multi(path_list{i})
            origin_path = ''
            lossy_path = ''
            for j = 1:numel(image_list)
                if ~isempty(strfind(image_list{j},'origin'))
                    origin_path = image_list{j}
                else if ~isempty(strfind(image_list{j},'lossy'))
                        lossy_path = image_list{j}
                    end
                end 
            end
            main(origin_path,lossy_path)
        end
    end
end