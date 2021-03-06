function [ imdb, select ] = IMDBAddPlaces2( imdb, path, task_num, varargin )
% IMDBADDPLACES2   Add to imdb the Places2 dataset (401 classes version).
% 
% IMPORTANT NOTE: Here we use Places2 with 401 classes, which was used in
% ILSVRC2015 taster challenge. However, it has become obsolete after our paper
% submission. Places365 now replaces it as a better dataset.
% 
%   Input:
%     PATH struct generated by GETPATH()
%     TASK_NUM the path number (see CNN_CUSTOMTRAIN) that this dataset corresponds to
%   Options:
%     See code comments
% 
% Authors: Zhizhong Li
% 
% See the COPYING file.
% 
% -------------------------------------------------------------------------

opts.partial = 0; % for >0 partial, e.g. 0.3, only include that much portion of # samples.
opts.label = 'class'; % 'class' only.
opts.trainval = [1 2]; % 1 for train, 2 for val. By default include train+val.
opts.randstream = []; % use randstream if provided
opts = vl_argparse(opts, varargin);


if ~isfield(imdb, 'images')
    imdb.images.name = [];
    imdb.images.label = [];
    imdb.images.set = [];
    imdb.images.task = [];
end

sets = {'train', 'val', 'test'}; sets = sets(opts.trainval);

% train or val set
for f = sets
    f = char(f);
    set = 1; if strcmp(f, 'val'), set = 2; elseif strcmp(f, 'test'), set = 3; end

    % image names
    fid = fopen(fullfile(path.path_Placesmeta, [f '.txt']), 'r');
    readname.(f) = textscan(fid, '%s %d');
    fclose(fid);

    % selecting partial
    if opts.partial
        if numel(opts.partial)==1
            partial = opts.partial;
        else
            partial = opts.partial(set);
        end
        if isempty(opts.randstream)
            select.(f) = randperm(numel(readname.(f){1}), ceil(numel(readname.(f){1}) * partial));
        else
            select.(f) = randperm(opts.randstream, numel(readname.(f){1}), ceil(numel(readname.(f){1}) * partial));
        end
    else
        select.(f) = 1:numel(readname.(f){1});
    end

    % names
    names = readname.(f){1}(select.(f));
    n_set = size(names,1);

    % labels...
    switch opts.label
        case 'class'
            % stuff.
            classes = num2cell(double(1 + readname.(f){2}));
        otherwise
            throw(MException('opts.label:notRecognized', 'class'));
    end

    classes = classes(select.(f),:);
    
    names = strcat([f '/'], names);

    imdb.images.name = [ imdb.images.name; names ];
    imdb.images.label = [ imdb.images.label; classes ];

    imdb.images.set = [ imdb.images.set;
        ones(n_set,1) * set ];
    imdb.images.task = [ imdb.images.task;
        task_num * ones(n_set, 1) ];
end
