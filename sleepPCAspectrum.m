% produce PCA spectral data as function of time and analysis window
% saves data for further use by realT_PCAspectrum

totalTimer = tic;

if exist('iter', 'var')==1
    iter=1+iter;
else
	iter = 1
end

% data_folder require trailing \
%data_folder = 'E:\aa\160923_keepingLightsOn_DOB0919\';
%image_file = '8percFPGA_85mW940nm_900msExp_640pm_100mmLens2xBin_1-scale2x.tif';

%max_realTime = 100;
trial_window = 10:120; % window to analyze data
trial_length = 120; % how long is single trial

% files to save data:
data_container_file = ['CovEvals_',num2str(min(trial_window)),'-',num2str(max(trial_window)),'.mat']
% init container for collecting data
data_container = cell(1,max_realTime);

% params, optimize based on random search
smwidth = 3;
thresh = 2;
nPCs = 100;
dsamp = [1 1]; % temp / spatial downsampling
mu = 0.67;
arealims = [10 18]; % adjusted based on image scale
subtractmean = 0;
termtol = 0.01;
maxrounds = 200;

parfor realTime_i = 1:max_realTime
    disp(['realTime_i=',num2str(realTime_i)])

    flims = [trial_window(1) trial_window(end)] + trial_length*(realTime_i-1);

    fn = [data_folder,'\', image_file];
    outputdir = [int2str(iter),'_',date, '_nPCs',int2str(nPCs),'_file_',image_file];
    mkdir(outputdir);

    badframes = [];
    disp('CellsortPCA')
    disp(['realTime_i=',num2str(realTime_i)])
    [mixedsig, mixedfilters, CovEvals, covtrace, movm, movtm] = CellsortPCA(fn, flims, nPCs, dsamp, outputdir, badframes);

    disp('Done CellsortPCA');
    disp(['realTime_i=',num2str(realTime_i)])
    data_container{realTime_i}.CovEvals = zeros(1,nPCs);
    data_container{realTime_i}.CovEvals(1:length(CovEvals)) = CovEvals;
    data_container{realTime_i}.covtrace = covtrace;
end


% saving PCA spectra into file:
save([data_folder,'\', data_container_file],'data_container');





