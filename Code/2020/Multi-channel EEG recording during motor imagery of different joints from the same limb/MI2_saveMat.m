% 这个脚本用于MI_2数据集，有两个目的，
% 第一个是将MI_2数据整理成 （15， 40， 62， 800）、（15， 40， 1）和（300， 62， 800）
% 第二个是 绘制出15个session下的 ERD 和topomap

% %% 这部分用于整理数据，保存为.mat文件，后续分类器构建用
% % 数据加载，滤波，提取，保存（subject_01.mat）（不用拉普拉斯滤波）
% 
saveMainDir = '..\MI_2_trial_data\';
if ~exist(saveMainDir)
    mkdir(saveMainDir)
end
prepath = '..\MI_2_processed_data\';

list_dir = dir(prepath);
for dirIndex = 3:size(list_dir, 1)% 前面两个分别是前一个文件夹路径和当前文件夹路径，不用
    % part 1 加载数据
    % 加载mat数据-获得hand 和 elbow 的数据
    % 每8s（提示前3s以及提示后5s）作为一段，相互之间不能重叠，包括rest
    % 因此，任务态总共是各300个样本叠加，静息态是160个样本叠加。
    dirpath = list_dir(dirIndex).name;
    saveMatName = [dirpath, '.mat']; % e.g. 'subject_01.mat'
    if exist([saveMainDir, saveMatName], 'file')
        continue;
    else
        % 获取task数据
        task_data = zeros(15, 40, 62, 800);
        task_label = zeros(15, 40, 1);        
        
        list_file = dir([prepath, dirpath, '\*_2_*.set']);
%         fileNameCell = regexp(b(3).name, '_', 'split');
%         subName = fileNameCell{1};
        for sess_index = 1:size(list_file,1)
            EEG = pop_loadset('filename',list_file(sess_index).name,'filepath',[prepath, dirpath, '\']);
            EEG = pop_resample( EEG, 200); % 直接降采样到200Hz
            data=double(EEG.data);
            % filter
            EEG = pop_eegfiltnew(EEG,  7, []);
            EEG = pop_eegfiltnew(EEG, [], 40);
            event=EEG.event;
            for j = 1:40
                latency = event(1,j).latency;
                task_data(sess_index, j, :, :) = data(:,latency:latency+799);
                if strcmp(class(event(1,j).type), 'char')
                    task_label(sess_index, j, 1) = str2num(event(1,j).type);
                else
                    task_label(sess_index, j, 1) = event(1,j).type;
                end
            end
        end
        % 获取rest数据
        rest_data = zeros(300, 62, 800);
        rest_label = 3*ones(300, 1);
        list_rest = dir([prepath, dirpath, '\*_rest_*.set']);
        for i = 1:size(list_rest, 1)
            EEG = pop_loadset('filename',list_file(i).name,'filepath',[prepath, dirpath, '\']);
            EEG = pop_resample( EEG, 200); % 直接降采样到200Hz
            data=double(EEG.data);
            % filter
            EEG = pop_eegfiltnew(EEG,  7, []);
            EEG = pop_eegfiltnew(EEG, [], 40);
            
            latency = 1;
            for j = 1:75
                rest_data(j+(i-1)*75, :, :) = data(:,latency:latency+799);
                latency = latency + 849;
            end
        end
        save([saveMainDir, saveMatName], 'task_data', 'task_label', 'rest_data')
    end
end
