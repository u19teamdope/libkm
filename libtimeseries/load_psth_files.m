function [comb, mid_list, cMissing, cInvPSTH] = load_psth_files(filename, mids, varargin)
% LOAD_PSTH_FILES load and combine psth files based on filename and mids 
% This function assumes that psth files are saved in a recommended folder structure. 
% varargin are filters, which filter-in loaded psths to save memory.
% use LOADP_PATH_FPATHS to directly specify file paths of psths.
%
% see also LOAD_ALL_PSTHS, LOAD_PSTH_FPATHS
%
%  7/9/2015 HRK

verbose = 0;
analysis_root = '';
repo = '';

opt = who();
[leftover_varargin i_left] = process_varargin_ext(varargin);

% make sure that options are on first, and all leftovers are on the right
% side of varargin. This makes sure that I do not mistreat filter or
% accidently miss options.
b_left = false(size(varargin)); 
b_left(i_left) = true;
i_first_left = find(b_left,1,'first');
assert(all(b_left(i_first_left:end)), 'varargin that are not options should appear AFTER options');

% also, make sure that leftover does not include options
for iL = 1:numel(leftover_varargin)
    if isstr(leftover_varargin{iL}) && ismember(leftover_varargin{iL}, opt)
        error('leftover contains options. Options should appear first and should start at even order');
    end
end
    
% get default ANALYSIS_ROOT
global gC; 
% if exists, load declaration script
if isempty(gC) && exist('VirMEn_Def','file');
    gC = scriptvar2struct('VirMEn_Def');
end
    
if ~isempty(gC) && isfield(gC, 'ANALYSIS_ROOT')
    ANALYSIS_ROOT = gC.ANALYSIS_ROOT; 
end

% if repo is given, use it
if ~isempty(repo) && ~isempty(gC) && isfield(gC, 'EXP_ROOT')
    ANALYSIS_ROOT = [gC.EXP_ROOT(repo) 'Analysis' filesep];
end
    
% if given by an agument, use it
if ~isempty(analysis_root)
    ANALYSIS_ROOT = analysis_root;
end

fpaths = {};
% prepare directories for each animal
if is_arg('mids')
    for iM = 1:length(mids)
        fpaths{iM} = [ANALYSIS_ROOT num2str(mids(iM)) '\' filename];
    end
end

comb = struct;
mid_list = [];
cMissing = {};

% load and combine psths files
comb = load_psth_fpaths(fpaths, verbose, leftover_varargin{:} );

% check if one of filters is individual datanams.
cDataname = {};
nDataname = NaN;

for iA = 1:length(leftover_varargin)
    if iscell(leftover_varargin{iA}) && all( cellfun(@isstr, leftover_varargin{iA} ) )
        cDataname = leftover_varargin{iA};
        nDataname = numel( leftover_varargin{iA} );
    end
end

% print out # info
[~,fn] = fileparts(filename);
comb_fn = fieldnames(comb);
if isnan(nDataname)
    fprintf(1, 'combined psths (%s) from %d Subjects, total %d psths\n', fn, numel(mids), numel(comb_fn));
else
    cMissing = setdiff(cDataname, comb_fn);
    fprintf(1, 'combined psths (%s) from %d Subjects, filters (%d), total %d psths\n', fn, numel(mids), nDataname, numel(comb_fn));
    if numel(cMissing) > 0
        fprintf(1, 'missing psths: %s', sprintf('%s ', cMissing{:}) ); fprintf(1, '\n');
    end
end