% EEGLAB history file generated on the 21-Mar-2018
% ------------------------------------------------

clear
loadDir = '..\MI_2_raw_data\';
saveDir = '..\MI_2_processed_data\';

list_dir=dir(fullfile(loadDir)); 
dirNum=size(list_dir,1); % the first two are "." and ".." 

for i = 3: dirNum % the first two are "." and ".." so begin with index 3
    dateDir = list_dir(i).name;
    filePath = [loadDir, dateDir, '\'];
    savePathSet = [saveDir, dateDir];
    if ~exist(savePathSet)
        mkdir(savePathSet)
    end
%     list_file = dir([filePath, '*_2_*.cnt']);
    list_file = dir(filePath);
    fileNum = size(list_file, 1);
    for j = 3:fileNum % the first two are "." and ".." so begin with index 3
        filename = list_file(j).name;
        filename_pure = filename(1:(find(filename=='.')-1));
        checkPath = [saveDir, dateDir, '\', filename_pure, '.set'];
        disp(checkPath)
        if ~exist(checkPath)
            fileFullPath = [filePath, '\', filename];
            EEG = pop_loadcnt( fileFullPath , 'dataformat', 'auto', 'memmapfile', '');

            % add the location map according to the channel_name
            EEG=pop_chanedit(EEG, 'lookup','.\channel_dict.ced');
            
            % remove HEO, M2, VEO, EMG1, EMG2
            EEG = pop_select(EEG, 'nochannel', {'HEO', 'M2', 'VEO', 'EMG1', 'EMG2'});

            if strfind(filename, '_2_') % only for task session
                % remove the clutter before (<4s) and after (>5s)
                EEG = pop_select(EEG, 'notime', [0, EEG.urevent(1).latency/1000 - 4; EEG.urevent(end).latency/1000 + 5, EEG.xmax]);
%             EEG = pop_select(EEG, 'notime', [EEG.urevent(end).latency/1000 + 5, EEG.xmax]);
            end
            
            % re-reference, CAR,common average reference
            EEG = pop_reref( EEG, []);

            % filter
            EEG = pop_eegfiltnew(EEG,  0.1, []);
            EEG = pop_eegfiltnew(EEG, [], 100);

            % remove base
            EEG = pop_rmbase( EEG, [0  EEG.pnts]);            

            % remove the EOG with AAR_fd
            EEG = pop_autobsseog( EEG, [416.32], [416.32], 'sobi', {'eigratio', [1000000]}, 'eog_fd', {'range',[2  22]});

            % save .set data
            saveNameSet = [filename_pure, '.set'];
            EEG = pop_saveset( EEG, 'filename', saveNameSet ,'filepath',savePathSet);
%             % the necessary information is already included in the EEG structure 
%             % and can be stored directly
%             save(savePathMat , 'EEG');  
        end
    end
end