function fullPath = create_subfolder_by_date(storedFolder)
    folderName = ['/',storedFolder,'/',datestr(now, 'yyyy-mm-dd')];
    currentFolder = pwd;
    fullPath = fullfile(currentFolder, folderName);
    if ~exist(fullPath, 'dir')
        % Folder does not exist so create it.
        mkdir(fullPath);
    end
end