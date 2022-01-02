% ����ű�����MI_2���ݼ���������Ŀ�ģ�
% ��һ���ǽ�MI_2��������� ��15�� 40�� 62�� 800������15�� 40�� 1���ͣ�300�� 62�� 800��
% �ڶ����� ���Ƴ�15��session�µ� ERD ��topomap

% %% �ⲿ�������������ݣ�����Ϊ.mat�ļ�������������������
% % ���ݼ��أ��˲�����ȡ�����棨subject_01.mat��������������˹�˲���
% 
saveMainDir = '..\MI_2_trial_data\';
if ~exist(saveMainDir)
    mkdir(saveMainDir)
end
prepath = '..\MI_2_processed_data\';

list_dir = dir(prepath);
for dirIndex = 3:size(list_dir, 1)% ǰ�������ֱ���ǰһ���ļ���·���͵�ǰ�ļ���·��������
    % part 1 ��������
    % ����mat����-���hand �� elbow ������
    % ÿ8s����ʾǰ3s�Լ���ʾ��5s����Ϊһ�Σ��໥֮�䲻���ص�������rest
    % ��ˣ�����̬�ܹ��Ǹ�300���������ӣ���Ϣ̬��160���������ӡ�
    dirpath = list_dir(dirIndex).name;
    saveMatName = [dirpath, '.mat']; % e.g. 'subject_01.mat'
    if exist([saveMainDir, saveMatName], 'file')
        continue;
    else
        % ��ȡtask����
        task_data = zeros(15, 40, 62, 800);
        task_label = zeros(15, 40, 1);        
        
        list_file = dir([prepath, dirpath, '\*_2_*.set']);
%         fileNameCell = regexp(b(3).name, '_', 'split');
%         subName = fileNameCell{1};
        for sess_index = 1:size(list_file,1)
            EEG = pop_loadset('filename',list_file(sess_index).name,'filepath',[prepath, dirpath, '\']);
            EEG = pop_resample( EEG, 200); % ֱ�ӽ�������200Hz
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
        % ��ȡrest����
        rest_data = zeros(300, 62, 800);
        rest_label = 3*ones(300, 1);
        list_rest = dir([prepath, dirpath, '\*_rest_*.set']);
        for i = 1:size(list_rest, 1)
            EEG = pop_loadset('filename',list_file(i).name,'filepath',[prepath, dirpath, '\']);
            EEG = pop_resample( EEG, 200); % ֱ�ӽ�������200Hz
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
