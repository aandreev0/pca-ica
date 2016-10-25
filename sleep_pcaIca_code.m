%% init & step 1

totalTimer = tic;

if exist('iter', 'var')==1
    iter=1+iter;
else
	iter = 1
end

% data_folder require trailing \
%data_folder = 'E:\aa\160923_keepingLightsOn_DOB0919\';
%image_file = '8percFPGA_85mW940nm_900msExp_640pm_100mmLens2xBin_1-scale2x.tif';
%all_cell_sigs = {};
%all_segcentroid = {};

segcentroid_file = 'subtractMean0_all_segcentroid_t001-120.mat';
cell_sigs_file = 'subtractMean0_all_cell_sigs_t001-120.mat';

trial_length = 120;

smwidth = 3;
thresh = 2;
nPCs = 100;
dsamp = [1 1]; % temp / spatial downsampling
mu = 0.67;
arealims = [7 12]; % adjusted based on scale
subtractmean = 0;
termtol = 0.01;
maxrounds = 200;

parfor realTime_i = 1:max_realTime
    disp(['realTime_i=',num2str(realTime_i)])

    
flims = [1 trial_length] + trial_length*(realTime_i-1);

fn = [data_folder,'\', image_file];
outputdir = [int2str(iter),'_',date, '_nPCs',int2str(nPCs),'_file_',image_file];
mkdir(outputdir);

badframes = [];
disp('CellsortPCA')
disp(['realTime_i=',num2str(realTime_i)])
 [mixedsig, mixedfilters, CovEvals, covtrace, movm, movtm] = CellsortPCA(fn, flims, nPCs, dsamp, outputdir, badframes);
 
 disp('Done CellsortPCA');
 disp(['realTime_i=',num2str(realTime_i)])

 PCuse = 1:nPCs;
 %CellsortPlotPCspectrum(fn, CovEvals, PCuse, 1);
 %f = figure(1)
 %saveas(f,[data_folder,'flims_',int2str(flims(1)),'-',int2str(flims(2)),'_PCuse_',int2str(PCuse(end)),'.fig'])
 
 

 
%% step 2
disp('step 2')

% 2.a
PCuse = 1:nPCs;
colormap 'jet';

%% 2.b


%% step 3
disp('step 3')
% 3.a
nIC = nPCs;

ica_A_guess = [];
[ica_sig, ica_filters, ica_A, numiter] = CellsortICA(mixedsig, mixedfilters, CovEvals, PCuse, mu, nIC, ica_A_guess, termtol, maxrounds);
title(['mu=',num2str(mu)]);
% 3.b
mode = 'contour';
f0 = imread(fn,flims(1));
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
disp('step 4')
% 4.a
plotting = 0;
[ica_segments, segmentlabel, segcentroid] = CellsortSegmentation(ica_filters, smwidth, thresh, arealims, plotting);
% 4.b
movm = [];
cell_sig = CellsortApplyFilter(fn, ica_segments, flims, movm, subtractmean);

all_cell_sigs{realTime_i} = cell_sig;
all_segcentroid{realTime_i} = segcentroid;

end


save([data_folder,'\', cell_sigs_file],'all_cell_sigs');
save([data_folder,'\', segcentroid_file],'all_segcentroid');

%% render one timepoint centroids
figure
scale_factor = 1;
render_time_point = 14;
max_img = imread([data_folder,'\MAX_colored.tif'], render_time_point);
imshow(max_img)
hold on
plot(all_segcentroid{render_time_point}(:,1)*scale_factor,all_segcentroid{render_time_point}(:,2)*scale_factor,'o','Color',[1 1 1])
title(['smwdth=',num2str(smwidth),', thresh=',num2str(thresh)]);
disp('Total timer:');
toc(totalTimer)
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
 
 
