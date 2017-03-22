function experiment(experiment_nr,descr_type,vocab_size,nr_train_images,nr_test_images, kernel,N) 

% Tushar Nimbhorkar & Diede Rusticus
% Computer Vision '17
% Artificial Intelligence Master
% University of Amsterdam

classes = {'airplanes','motorbikes','faces','cars'};  
folder = '../Caltech4/ImageData/';

D_filename = strcat('objects/D_', descr_type, '.mat');
centers_filename = strcat('objects/centers_',num2str(vocab_size),'.mat');
X_train_filename = strcat('objects/X_train_', num2str(vocab_size),'_',descr_type,'_',num2str(nr_train_images),'.mat');
M_filename = strcat('_',num2str(vocab_size),'_',descr_type,'_',num2str(nr_train_images),'_',kernel,'.mat');
X_test_filename = strcat('objects/X_test_', num2str(vocab_size),'_',descr_type,'_',num2str(nr_train_images),'.mat');



% 2.1 Feature Extraction and Description
disp('feature extraction..')
if exist(D_filename, 'file') ~= 2
    disp('no D file yet, so making now..')
    D = feature_extraction(folder, descr_type);
    save(D_filename, 'D');
elseif exist('D', 'var') ~= 1
    load(D_filename);
end

% 2.2: K-means: get cluster means
disp('k-means..')
if exist(centers_filename, 'file') ~= 2
    disp('no cluster centers yet, so making now..')
    [~,centers] = kmeans(single(D),vocab_size,'MaxIter',N,'Display','final');
    save(centers_filename, 'centers');
elseif exist('centers', 'var') ~= 1 && exist(centers_filename,'file') == 2
    load(centers_filename);
end

% 2.3 & 2.4 & 2.5 Quantization and Classification %%%%%%%
disp('getting training features..')
if exist(X_train_filename, 'file') ~= 2
    X_train = get_features(folder, vocab_size, centers, descr_type, 'train', nr_train_images);
    save(X_train_filename, 'X_train');
elseif exist(X_train_filename, 'var') ~= 1
    load(X_train_filename)
end

disp('check for trained models and assign..')

for i=1:length(classes)
    if exist(strcat('objects/M_',char(classes(i)),M_filename), 'file') ~= 2
        disp(strcat(char(classes(i)), ' model not created yet, so making now..'))
        model = train_svm(char(classes(i)), X_train, vocab_size, kernel, descr_type, nr_train_images);
    end
    if exist(strcat('objects/M_',char(classes(i)),M_filename), 'file') == 2             
        load(strcat('objects/M_',char(classes(i)),M_filename));

        if i == 1
            model_airplanes = model;
        elseif i == 2
            model_motorbikes = model;
        elseif i == 3 
            model_faces = model;
        elseif i == 4
            model_cars = model;
        end
    end
end

classesids = zeros(4*nr_test_images, 1);
classesids(0*nr_test_images+1:1*nr_test_images,:) = 1;
classesids(1*nr_test_images+1:2*nr_test_images,:) = 2;
classesids(2*nr_test_images+1:3*nr_test_images,:) = 3;
classesids(3*nr_test_images+1:4*nr_test_images,:) = 4;

disp('getting test features..')
if exist(X_test_filename, 'file') ~= 2
    X_test = get_features(folder, vocab_size, centers, descr_type, 'test', nr_test_images);
    save(X_test_filename, 'X_test');
elseif exist(X_test_filename, 'var') ~= 1
    load(X_test_filename)
end

disp('get ranking lists..')
% X_test = get_features(folder, vocab_size, centers, descr_type, 'test', nr_test_images);
rank_airplanes = test_data(X_test, classesids, model_airplanes, nr_test_images);
rank_motorbikes = test_data(X_test, classesids, model_motorbikes, nr_test_images);
rank_faces = test_data(X_test, classesids, model_faces, nr_test_images);
rank_cars = test_data(X_test, classesids, model_cars, nr_test_images);

disp('calculating average precisions..')

rankedlists = {rank_airplanes rank_motorbikes rank_faces, rank_cars};

APs = zeros(1,4);
for i = 1:length(classes)
    sum_AP = 0;
    count = 0;
    for j = 1:200
        ranking = cell2mat(rankedlists(i));
        if ranking(j,2) == i
            count = count + 1;
            sum_AP = sum_AP + (count/j);
        else
            sum_AP = sum_AP + (0/j);
        end
    end
    APs(:,i) = (1/50) * sum_AP;
end

MAP = mean(APs);
disp(APs);
disp(strcat('MAP: ',num2str(MAP))); 

fid = fopen(strcat('logs/exper_', num2str(experiment_nr),'.txt'),'w');
fprintf(fid, [ 'Experiment nr:' ' ' num2str(experiment_nr) '\n']);
fprintf(fid, [ 'Voc. size:' ' ' num2str(vocab_size) '\n']);
fprintf(fid, [ 'N:' ' ' num2str(N) '\n']);
fprintf(fid, [ 'Descriptor:' ' ' descr_type '\n']);
fprintf(fid, [ 'Nr train images:' ' ' num2str(nr_train_images) '\n']);
fprintf(fid, [ 'Nr test images:' ' ' num2str(nr_test_images) '\n']);
fprintf(fid, [ 'Kernel:' ' ' kernel '\n']);
fprintf(fid, [ 'APs:' ' ' num2str(APs(1)) ' ' num2str(APs(2)) ' ' num2str(APs(3)) ' ' num2str(APs(4)) '\n']);
fprintf(fid, [ 'mAP:' ' ' num2str(MAP) '\n']);
fclose(fid);

disp('done!')

end