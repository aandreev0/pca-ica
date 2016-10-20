%% init & step 1
if exist('iter', 'var')==1
    iter=1+iter;
else
	iter = 1
end

% data_folder require trailing \
%data_folder = 'E:\aa\LightField\Fish1_1p_SVI-100um_LEDonFrame100-199_Laser30Per_Taken2\';
data_folder = 'E:\aa\LightField\Fish1_2p_SVI-100um_Side2_LEDonFrame100-199_Laser35Per_Taken4\dataset_ts78-107_unwrap3D\';
data_folder = 'E:\aa\LightField\Fish1_2p_SVI-100um_Side2_LEDonFrame100-199_Laser35Per_Taken3\dataset_ts91-120_unwrap3D\';
data_folder = 'E:\aa\LightField\Fish1_1p_SVI-100um_LEDonFrame100-199_Laser30Per_Taken2\dataset_ts85-114_unwrap3D\';
image_file = 'Zunwrap.tif';
all_cell_sigs = {};
all_segcentroid = {};
%for realTime_i = 1:196
    %realTime_i
    
flims = [1 30];% + 120*(realTime_i-1);
fn = [data_folder, image_file];
nPCs = 40;
outputdir = [int2str(iter),'_',date, '_nPCs',int2str(nPCs),'_file_',image_file];
mkdir(outputdir);

badframes = [];
dsamp = [1 1]; % temp / spatial downsampling
disp('CellsortPCA')
 [mixedsig, mixedfilters, CovEvals, covtrace, movm, movtm] = CellsortPCA(fn, flims, nPCs, dsamp, outputdir, badframes);
 
 disp('Done CellsortPCA');
 PCuse = 1:20;
 CellsortPlotPCspectrum(fn, CovEvals, PCuse, 1);
 f = figure(1)
 saveas(f,[data_folder,'flims_',int2str(flims(1)),'-',int2str(flims(2)),'_PCuse_',int2str(PCuse(end)),'.fig'])
 
 
%{
 
%% step 2
'step 2'

% 2.a
%[PCuse] = CellsortChoosePCs(fn, mixedfilters);
PCuse = 1:nPCs;
colormap 'jet';

%% 2.b
%
%figure

%PCuse = 1:nPCs;

%CellsortPlotPCspectrum(fn, CovEvals, PCuse, 1);
grid

%% step 3
'step 3'
figure
% 3.a
mu = 0.2;
nIC = nPCs;
termtol = 0.01;
maxrounds = 200;
ica_A_guess = [];
[ica_sig, ica_filters, ica_A, numiter] = CellsortICA(mixedsig, mixedfilters, CovEvals, PCuse, mu, nIC, ica_A_guess, termtol, maxrounds);
title 'mu=0.1';
% 3.b
mode = 'contour';
f0 = imread(fn,1);
tlims = [];
dt = 1;
ratebin = 1;
plottype = 1;
spt = [];
spc = [];
ICuse = [];
disp('CellsortICAplot...');
%CellsortICAplot(mode, ica_filters, ica_sig, f0, tlims, dt, ratebin, plottype, ICuse, spt, spc);

%% step 4
'step 4'
figure
clf
% 4.a
smwidth = 2;
thresh = 3;
arealims = [2 10];
plotting = 0;
[ica_segments, segmentlabel, segcentroid] = CellsortSegmentation(ica_filters, smwidth, thresh, arealims, plotting);

% 4.b
movm = f0;
subtractmean = 1;
cell_sig = CellsortApplyFilter(fn, ica_segments, flims, movm, subtractmean);
pcolor(cell_sig);shading flat

all_cell_sigs{realTime_i} = cell_sig;
save([data_folder, 'all_cell_sigs_t001-120.mat'],'all_cell_sigs');

all_segcentroid{realTime_i} = segcentroid;
save([data_folder, 'all_segcentroid_t001-120.mat'],'all_segcentroid');


xlabel 'Time, s';
ylabel 'Segmented cell';
colormap jet;
close all
end

%{
%% plot spatial filters
figure(5)
clf
seg_image = zeros(size(f0)+20)';
seg_image(10:end-11,10:end-11)= f0';

for kk=1:length(segcentroid)
    c = round(segcentroid(kk,:))+5;
    seg_image((c(1)-5):(c(1)+5),(c(2)-5):(c(2)+5)) = seg_image((c(1)-5):(c(1)+5),(c(2)-5):(c(2)+5))+kk;
end
pcolor(fliplr(seg_image'));shading flat
colormap hsv;

%{
%% step 5: Deconvolve signal and find spikes using a threshold
'step 5'
thresh = 1;
deconvtau = 3;
normalization = 0;

[spmat, spt, spc, zsig] = CellsortFindspikes(ica_sig, thresh, dt, deconvtau, normalization);
%}

%}
 
 %}
