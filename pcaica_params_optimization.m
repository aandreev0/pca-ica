%% init & step 1
if exist('iter', 'var')==1
    iter=1+iter;
else
	iter = 1
end

totalTimer = tic;


% data_folder require trailing \
data_folder = 'E:\aa\160918_huc-gcamp-KeepingLightsOn\';
image_file = '120frTrial15minInt_900msExp-100mmLens_2xBin_8perc75mW940nm_813pm_1-scale2x_8bit-trial1.tif';
segcentroid_file = 'all_segcentroid_t001-120.mat';
cell_sigs_file = 'all_cell_sigs_t001-120.mat';

trial_length = 120;
trial_max_num = 50;


flims = [1 60]

fn = [data_folder, image_file];
f0 = imread(fn,1);
params_data = {};


parfor trial_id = 1:trial_max_num
    trial_tic = tic;
    disp(['trial=',num2str(trial_id)])

    % pick random params
    smwidth = 3;1+round(rand*3);
    thresh  = 2;rand*2+1;
    nPCs = 20;100;round(50+rand*60);
    dsamp = [1 1]; % temp / spatial downsampling
    mu = 0.67; rand*0.8 + 0.1;
    arealims = [10 16];round(sort(rand(1,2)*20) + 5);
    %% run PCA/ICA segmentation
    
    file_for_saving = ['pcaica_params_optimization\trial_data_',num2str(trial_id),'.mat'];

    outputdir = ['placeholder_dir'];

    badframes = [];
    [mixedsig, mixedfilters, CovEvals, covtrace, movm, movtm] = CellsortPCA(fn, flims, nPCs, dsamp, outputdir, badframes);
    nPCs = size(mixedsig,1)
    PCuse = 1:nPCs;
    %% step 2
    % 2.a
    '2'
    PCuse = 1:nPCs;
    %% step 3
    '3'
    % 3.a
    nIC = nPCs;
    termtol = 0.01;
    maxrounds = 200;
    ica_A_guess = [];
    [ica_sig, ica_filters, ica_A, numiter] = CellsortICA(mixedsig, mixedfilters, CovEvals, PCuse, mu, nIC, ica_A_guess, termtol, maxrounds);
    '3.b'
    % 3.b
    mode = 'contour';
    tlims = [];
    dt = 1;
    ratebin = 1;
    plottype = 1;
    spt = [];
    spc = [];
    ICuse = [];

    %% step 4
    % 4.a
    '4a'
    plotting = 0;
    [ica_segments, segmentlabel, segcentroid] = CellsortSegmentation(ica_filters, smwidth, thresh, arealims, plotting);
    % 4.b
    '4b'
    movm = f0;
    subtractmean = 0;
    cell_sig = CellsortApplyFilter(fn, ica_segments, flims, movm, subtractmean);
    % save data
   
    params_data{trial_id} = struct;
    params_data{trial_id}.mu = mu;
    params_data{trial_id}.cell_sig = cell_sig;
    params_data{trial_id}.segcentroid = segcentroid;
    params_data{trial_id}.nPCs = nPCs;
    params_data{trial_id}.thresh = thresh;
    params_data{trial_id}.smwidth = smwidth;
    params_data{trial_id}.time = toc(trial_tic);
    params_data{trial_id}.arealims=arealims;
    params_data{trial_id}.ica_segments=ica_segments;

    
end
toc(totalTimer)
save(['pcaica_params_optimization\',num2str(iter),'params_data.mat'],'params_data','-v7.3')
%% save images
max_img = imread([data_folder,'120frTrial15minInt_900msExp-100mmLens_2xBin_8perc75mW940nm_813pm_1-scale2x_8bit-trial1_MAX_colored.tif']);
std_img = imread([data_folder,'STD_120frTrial15minInt_900msExp-100mmLens_2xBin_8perc75mW940nm_813pm_1-scale2x_8bit-trial1.tif']);
mkdir(['pcaica_params_optimization\',num2str(iter),'_segcentroids\']);
show_image_flag = true
%max_img = std_img;
if ~show_image_flag
	max_img = max_img * 0;
end

for trial_id = 1:trial_max_num
    f = figure(1);
    f.InvertHardcopy = 'off';
    clf
    imshow(max_img)
    caxis([0 80])
    colormap hot
    hold on
        
    if length(params_data{trial_id})>0
        xy = params_data{trial_id}.segcentroid;
        if length(xy)>0
            size(xy);
            plot(xy(:,1),xy(:,2),'o','Color',[1 1 1],'Markers',7);
            hold on
        end
        txt = {['nPCs=',     num2str(params_data{trial_id}.nPCs)   ];...
               ['mu=',       num2str(params_data{trial_id}.mu)     ];...
               ['smwidth=',  num2str(params_data{trial_id}.smwidth)];...
               ['thresh=',   num2str(params_data{trial_id}.thresh) ];...
               ['time=',     num2str(params_data{trial_id}.time)   ];...
               ['#seg=',     num2str(size(params_data{trial_id}.segcentroid,1))];...
               ['arealims=', num2str(params_data{trial_id}.arealims(1)),'-',num2str(params_data{trial_id}.arealims(2))]
               };
        text(210, 60,txt);

    end
    %print(f,'-djpg',['pcaica_params_optimization\',num2str(iter),'_segcentroids\',num2str(trial_id),'.jpg']);
    f.Position = [100 100 400 400];
    title(['trial=',num2str(trial_id)]);
    fig_img = getframe(f);

    imwrite(fig_img.cdata, ['pcaica_params_optimization\',num2str(iter),'_segcentroids\',num2str(trial_id),'.jpg']);

end
