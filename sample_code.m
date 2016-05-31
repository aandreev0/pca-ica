%% init & step 1
if exist('iter', 'var')==1
    iter=1+iter;
else
	iter = 1
end
addpath('../CellSort 1.0/')

data_folder = 'F:\documents\lab\data\spim\brain\evokedResponse\160521_h2bGCaMP_dob0516\';
%image_file = 'MAX_Reslice of LF_Movie_sequence_indexed_8bit-1_035umXY_2umZ.tif';
image_file = 'sleepMovie_15minInt_start4pm_900msExp_2x2xbin_7percFPGA_bidir940nm_1-1_t4.tif';
flims = [];
fn = [data_folder, image_file];
nPCs = 20;
outputdir = [int2str(iter),'_',date, '_nPCs',int2str(nPCs),'_file_',image_file];
mkdir(outputdir);

badframes = [];
dsamp = [1 1];

 [mixedsig, mixedfilters, CovEvals, covtrace, movm, movtm] = CellsortPCA(fn, flims, nPCs, dsamp, outputdir, badframes);

 
%% step 2
'step 2'

% 2.a
[PCuse] = CellsortChoosePCs(fn, mixedfilters);
PCuse = 1:11;
colormap 'jet';

%% 2.b
%
figure(2)

%PCuse = 1:nPCs;

CellsortPlotPCspectrum(fn, CovEvals, PCuse);


%% step 3
'step 3'
figure(3)
% 3.a
mu = 0.2;
nIC = 10;
termtol = 0.01;
maxrounds = 200;
ica_A_guess = [];
[ica_sig, ica_filters, ica_A, numiter] = CellsortICA(mixedsig, mixedfilters, CovEvals, PCuse, mu, nIC, ica_A_guess, termtol, maxrounds);

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
CellsortICAplot(mode, ica_filters, ica_sig, f0, tlims, dt, ratebin, plottype, ICuse, spt, spc);

%% step 4
'step 4'
figure(4)
clf
% 4.a
smwidth = 2;
thresh = 3;
arealims = [5 5];
plotting = 0;
[ica_segments, segmentlabel, segcentroid] = CellsortSegmentation(ica_filters, smwidth, thresh, arealims, plotting);

% 4.b
movm = f0;
subtractmean = 1;
cell_sig = CellsortApplyFilter(fn, ica_segments, flims, movm, subtractmean);
pcolor(cell_sig);shading flat
xlabel 'Time, s';
ylabel 'Segmented cell';
colormap jet;
%% plot spatial filters
figure(5)
clf
seg_image = zeros(size(f0)+20)';
seg_image(10:end-11,10:end-11)= f0';
'qwe'

for kk=1:length(segcentroid)
    c = round(segcentroid(kk,:))+5;
    seg_image((c(1)-5):(c(1)+5),(c(2)-5):(c(2)+5)) = seg_image((c(1)-5):(c(1)+5),(c(2)-5):(c(2)+5))+kk;
end
pcolor(fliplr(seg_image'));shading flat
colormap hsv;


%% step 5: Deconvolve signal and find spikes using a threshold
'step 5'
thresh = 1;
deconvtau = 3;
normalization = 0;

[spmat, spt, spc, zsig] = CellsortFindspikes(ica_sig, thresh, dt, deconvtau, normalization);

