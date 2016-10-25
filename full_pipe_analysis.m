%% wrapper around all analysis
data_folder = 'E:\aa\160718'
image_file = 'fish2fluo_900msExp15minInt_2x2xBin_6perc940BiDir_756_1-scale2x.tif';

min_realTime = 1;
max_realTime = 70;

%% sleep_pcaICA_code
sleep_pcaIca_code


%% generate PCA spectra
sleepPCAspectrum
data_folder

%% render
close all
realT_PCAspectrum
data_folder
%% realT_corr_dist
close all
realT_corr_dist
data_folder


%% realT_Wrapper
close all
realT_wrapper
data_folder