
function [pes_struct pes_mat result] = read_pe_files(feat_dir,pe_list,output_prefix)
% function [pes_struct pes_mat result] = read_pe_files(feat_dir,pe_list,output_prefix)
%
% This script reads in a list of nifti files to be converted to matlab
% variables
%
% feat_dir = absolute path to feat directory
% pe_list = list of pe indices of interest to read in 
% (example: pe_list = [1 2 3 4])
% output_prefix = name of saved nii.gz file


% prepare duplicate stats directory to leave original results untouched
stats_dir = [feat_dir '/stats_matlab'];
if (~exist(stats_dir))
    mkdir(stats_dir);
end

% registration folder
reg_dir = [feat_dir '/reg'];

% toolbox directories
%biac_tools_dir = '~/Dropbox/BIAC_matlab_20070731_ver3.1.4';
%bxh_tools_dir = '/usr/share/bxh_xcede_tools-1.9.2-darwin980.i386/bin';
biac_tools_dir = '/Volumes/ntb/packages/BIAC_matlab';
bxh_tools_dir = '/Volumes/ntb/packages/bxh_xcede_tools/bin';

% add BIAC tools recursively
addpath(genpath(biac_tools_dir));

% read data
for pp=1:length(pe_list)
    
    disp(['dealing with file ' num2str(pp) ' of ' num2str(length(pe_list))]);
    
    % prepare files
    old_file = [feat_dir '/stats/pe' num2str(pe_list(pp)) '.nii.gz'];
    new_file = [stats_dir '/pe' num2str(pe_list(pp)) '.nii.gz'];
    std_file = [stats_dir '/pe' num2str(pe_list(pp)) '_std.nii.gz'];
    bxh_file = [stats_dir '/pe' num2str(pe_list(pp)) '_std.bxh'];
    pe_file = [stats_dir '/pe' num2str(pe_list(pp)) '_std.nii'];
    
    % process if necessary 
    if (~exist(pe_file))
    
        % copy original file
        copyfile(old_file,stats_dir);
        
        % register to standard space
        unix(['flirt -ref ' reg_dir '/standard -in ' new_file ' -out ' std_file ' -applyxfm -init ' reg_dir '/example_func2standard.mat -interp sinc -datatype float']);
    
        % decompress
        unix(['gunzip ' pe_file '.gz']);
        
    end
    
    % remove intermediate files
    unix(['rm -rf ' new_file]);
    unix(['rm -rf ' std_file]);
    
    % wrap with bxh headers
    unix([bxh_tools_dir '/bxhabsorb ' pe_file ' ' bxh_file]);
    
    pause(4)
    
    % read data with BIAC tools
    pes_struct{pp} = readmr(bxh_file,'NOPROGRESSBAR');
    
    % add to matrix, initialize if necessary
    if (pp==1)
        pes_mat = nan([length(pe_list) size(pes_struct{pp}.data)]);
    end
    pes_mat(pp,:,:,:) = pes_struct{pp}.data;
    
end

% do something with PE maps... (demo with sum)
result = squeeze(sum(pes_mat,1));

% write output to file with BIAC tools
output_struct = pes_struct{1}; % doesn't matter which one
output_struct.data = result;
output_bxh = [stats_dir '/' output_prefix '.bxh'];
output_img = [stats_dir '/' output_prefix '.img'];
output_niigz = [stats_dir '/' output_prefix]; % no file type needed, supplied by bxh2analyze
writemr(output_struct,output_bxh,{'BXH','image','',output_img});
unix([bxh_tools_dir '/bxh2analyze --niigz --overwrite ' output_bxh ' ' output_niigz]);
unix(['rm -rf ' output_img]); % remove old image type
