function [net, info, expdir] = finetune_cnn(varargin)

%% Define options
% run(fullfile(fileparts(mfilename('fullpath')), ...
%   '..', '..', 'MatConvNet', 'matlab', 'vl_setupnn.m')) ;

opts.modelType = 'lenet' ;
[opts, varargin] = vl_argparse(opts, varargin) ;

opts.expDir = fullfile('data', ...
  sprintf('cnn_assignment-%s', opts.modelType)) ;
[opts, varargin] = vl_argparse(opts, varargin) ;

opts.dataDir = './data/' ;
opts.imdbPath = fullfile(opts.expDir, 'imdb-caltech.mat');
opts.whitenData = true ;
opts.contrastNormalization = true ;
opts.networkType = 'simplenn' ;
opts.train = struct() ;
opts = vl_argparse(opts, varargin) ;
if ~isfield(opts.train, 'gpus'), opts.train.gpus = []; end;

opts.train.gpus = [];



%% update model

net = update_model();

%% TODO: Implement getCaltechIMDB function below

if exist(opts.imdbPath, 'file')
    disp('I already exist')
  imdb = load(opts.imdbPath) ;
  imdb.images.data = single(imdb.images.data) ; %why this?
else
  disp('I being recreated')
  imdb = getCaltechIMDB() ;
  mkdir(opts.expDir) ;
  save(opts.imdbPath, '-struct', 'imdb') ;
end

%%
net.meta.classes.name = imdb.meta.classes(:)' ;

% -------------------------------------------------------------------------
%                                                                     Train
% -------------------------------------------------------------------------

trainfn = @cnn_train ;
[net, info] = trainfn(net, imdb, getBatch(opts), ...
  'expDir', opts.expDir, ...
  net.meta.trainOpts, ...
  opts.train, ...
  'val', find(imdb.images.set == 2)) ;

expdir = opts.expDir;
end
% -------------------------------------------------------------------------
function fn = getBatch(opts)
% -------------------------------------------------------------------------
switch lower(opts.networkType)
  case 'simplenn'
    fn = @(x,y) getSimpleNNBatch(x,y) ;
  case 'dagnn'
    bopts = struct('numGpus', numel(opts.train.gpus)) ;
    fn = @(x,y) getDagNNBatch(bopts,x,y) ;
end

end

function [images, labels] = getSimpleNNBatch(imdb, batch)
% -------------------------------------------------------------------------
images = imdb.images.data(:,:,:,batch) ;
labels = imdb.images.labels(1,batch) ;
if rand > 0.5, images=fliplr(images) ; end

end

% -------------------------------------------------------------------------
function imdb = getCaltechIMDB()
% -------------------------------------------------------------------------
% Preapre the imdb structure, returns image data with mean image subtracted
classes = {'airplanes', 'cars', 'faces', 'motorbikes'};
splits = {'train', 'test'};

%% Our implemented loop, to create the data structure described in the assignment

% Count the total number of coloured images (3 channel images)
n = 0;

% Both for train and test set
for s = 1:length(splits)

    % Count images per split
    if strcmp(splits(s),splits(1))
        nr_images = 400;
    else
        nr_images = 50;
    end
    
    % Loop over every image of every class in both splits
    for i = 1:length(classes)
        filename = char(strcat('../Caltech4/ImageData/', classes(i),'_', splits(s), '/'));
        for j = 1:nr_images
            imagename = strcat(filename,'img',num2str(j,'%.3d'),'.jpg');
            I = imread(imagename);
            % Count image when it has more than one channel (coloured image)
            if size(I,3) > 1
                n = n + 1;
            end
        end
    end
end

% Initialise the imdb.images components
% All images are resized to 32x32 and it is made sure they are defined in three channels
data = single(zeros(32,32,3,n));
labels = single(zeros(1,n));
sets = single(zeros(1,n));

% Keeps track of location in vectors/matrix
ind = 1;

% Both for train and test set
for s = 1:length(splits)

    % Count images per split
    if strcmp(splits(s),splits(1))
        nr_images = 400;
    else
        nr_images = 50;
    end
    
    % Loop over every image of every class in both splits
    for i = 1:length(classes)
        filename = char(strcat('../Caltech4/ImageData/', classes(i),'_', splits(s), '/'));
        for j = 1:nr_images
            imagename = strcat(filename,'img',num2str(j,'%.3d'),'.jpg');
            I = imread(imagename);
            
            % Only if the image is not in grayscale, save the image information in the imdb components
            if size(I,3) > 1
                I = single(I);
                
                % Resizing because pre-trained CNN only accepts 32x32x3 images.
                I = imresize(I, [32 32]);
                data(:,:,:,ind) = I;
                
                % Assign the correct set according to the split
                if strcmp(splits(s),splits(1))
                    sets(ind) = 1;
                else
                    sets(ind) = 2;
                end
                
                % Assign the correct label according to the class
                if strcmp(classes(i),classes(1))
                    labels(ind) = 1;
                elseif strcmp(classes(i),classes(2))
                    labels(ind) = 2;
                elseif strcmp(classes(i),classes(3))
                    labels(ind) = 3;
                elseif strcmp(classes(i),classes(4))
                    labels(ind) = 4;
                end
                
                % Alters the focus location for vectors/matrix
                ind = ind + 1;
            end
        end
    end
end
data = single(data);
labels = single(labels);
sets = single(sets);

% subtract mean
dataMean = mean(data(:, :, :, sets == 1), 4);
data = bsxfun(@minus, data, dataMean);

imdb.images.data = data ;

imdb.images.labels = single(labels) ;
imdb.images.set = sets;
imdb.meta.sets = {'train', 'val'} ;
imdb.meta.classes = classes;

perm = randperm(numel(imdb.images.labels));
imdb.images.data = imdb.images.data(:,:,:, perm);
imdb.images.labels = imdb.images.labels(perm);
imdb.images.set = imdb.images.set(perm);
end
