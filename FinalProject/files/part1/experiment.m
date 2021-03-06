function experiment(experiment_nr,sampler,descr_type,descr_step_size,vocab_size,d_ims,nr_train_images,nr_test_images, kernel,N)
    % This function runs the whole experiment with the given parameter
    % settings. It checks everytime if an object already exists in the
    % directory, so that we don't have to compute everything everytime. 

    classes = {'airplanes','motorbikes','faces','cars'};  
    folder = '../Caltech4/ImageData/';

    % Define filenames to save and load objects
    D_filename = strcat('objects/D_', sampler, '_', descr_type, '.mat');
    centers_filename = strcat('objects/centers_',num2str(vocab_size),'_',descr_type,'.mat');
    X_train_filename = strcat('objects/X_train_', num2str(vocab_size),'_',sampler,'_',descr_type,'_',num2str(nr_train_images),'.mat');
    M_filename = strcat('_',num2str(vocab_size),'_',sampler,'_',descr_type,'_',num2str(nr_train_images),'_',kernel,'.mat');
    X_test_filename = strcat('objects/X_test_', num2str(vocab_size),'_',sampler,'_',descr_type,'_',num2str(nr_train_images),'.mat');

    % Feature Extraction and Description
    disp('feature extraction..')
    if exist(D_filename, 'file') ~= 2
        disp('no descriptor file yet, so making now..')
        D = feature_extraction(folder, d_ims, sampler, descr_type, descr_step_size);
        save(D_filename, 'D');
    elseif exist('D', 'var') ~= 1
        load(D_filename);
    end

    % K-means: get cluster means
    disp('k-means..')
    if exist(centers_filename, 'file') ~= 2
        disp('no clusters yet, so making now..')
        [~,centers] = kmeans(single(D),vocab_size,'MaxIter',N,'Display','iter');
        save(centers_filename, 'centers');
    elseif exist('centers', 'var') ~= 1 && exist(centers_filename,'file') == 2
        load(centers_filename);
    end

    % Quantization and Classification
    
    % Get the features of the training images
    disp('getting training features..')
    if exist(X_train_filename, 'file') ~= 2
        X_train = get_input_features(folder, d_ims, vocab_size, centers, sampler, descr_type, 'train', nr_train_images, descr_step_size);
        save(X_train_filename, 'X_train');
    elseif exist(X_train_filename, 'var') ~= 1
        load(X_train_filename)
    end

    disp('check for trained models and assign..')

    % Train the models with the features
    for i=1:length(classes)
        if exist(strcat('objects/M_',char(classes(i)),M_filename), 'file') ~= 2
            disp(strcat(char(classes(i)), ' model not created yet, so making now..'))
            model = train_svm(char(classes(i)), X_train, vocab_size, kernel, sampler, descr_type, nr_train_images);
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

    % Get the features of the test images
    disp('getting test features..')
    if exist(X_test_filename, 'file') ~= 2
        X_test = get_input_features(folder, d_ims, vocab_size, centers, sampler, descr_type, 'test', nr_test_images, descr_step_size);
        save(X_test_filename, 'X_test');
    elseif exist(X_test_filename, 'var') ~= 1
        load(X_test_filename)
    end

    % Get the ranked lists: [image_indices, class_ids, scores]
    disp('get ranking lists..')
    
    classesids = zeros(4*nr_test_images, 1);
    classesids(0*nr_test_images+1:1*nr_test_images,:) = 1;
    classesids(1*nr_test_images+1:2*nr_test_images,:) = 2;
    classesids(2*nr_test_images+1:3*nr_test_images,:) = 3;
    classesids(3*nr_test_images+1:4*nr_test_images,:) = 4;
    
    rank_airplanes = test_data(X_test, classesids, model_airplanes, nr_test_images);
    rank_motorbikes = test_data(X_test, classesids, model_motorbikes, nr_test_images);
    rank_faces = test_data(X_test, classesids, model_faces, nr_test_images);
    rank_cars = test_data(X_test, classesids, model_cars, nr_test_images);
    
    % Calculate the average precisions
    disp('calculating average precisions..')
    
    rankedlists = {rank_airplanes rank_motorbikes rank_faces, rank_cars};
    [APs] = evaluate(rankedlists, nr_test_images);

    disp(strcat('MAP: ',num2str(APs(5)))); 

    % Write in file the logs
    fid = fopen(strcat('logs/exper_', num2str(experiment_nr),'_setup.txt'),'w');
    fprintf(fid, [ 'Experiment nr:' ' ' num2str(experiment_nr) '\n']);
    fprintf(fid, [ 'Voc. size:' ' ' num2str(vocab_size) '\n']);
    fprintf(fid, [ 'N:' ' ' num2str(N) '\n']);
    fprintf(fid, [ 'Sampler:' ' ' sampler '\n']);
    fprintf(fid, [ 'Descriptor:' ' ' descr_type '\n']);
    fprintf(fid, [ 'Descriptor step size:' ' ' num2str(descr_step_size) '\n']);
    fprintf(fid, [ 'Nr feature images:' ' ' d_ims '\n']);
    fprintf(fid, [ 'Nr train images:' ' ' num2str(nr_train_images) '\n']);
    fprintf(fid, [ 'Nr test images:' ' ' num2str(nr_test_images) '\n']);
    fprintf(fid, [ 'Kernel:' ' ' kernel '\n']);
    fprintf(fid, [ 'AP airplanes:' ' ' num2str(APs(1)) '\n']);
    fprintf(fid, [ 'AP motorbikes:' ' ' num2str(APs(2)) '\n']);
    fprintf(fid, [ 'AP faces:' ' ' num2str(APs(3)) '\n']);
    fprintf(fid, [ 'AP cars:' ' ' num2str(APs(4)) '\n']);
    fprintf(fid, [ 'mAP:' ' ' num2str(APs(5)) '\n']);
    
    fclose(fid);

    % Also save the ranked list as a csv
    for i = 1:4
        filename = strcat('logs/exper_', num2str(experiment_nr), '_rank_', char(classes(i)), '.csv');
        csvwrite(filename, rankedlists(i))
    end

    disp('done!')

end