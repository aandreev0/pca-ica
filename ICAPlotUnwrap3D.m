function ICAPlotUnwrap3D(ICuse, ica_filters, z_range, out_folder,sigsm, save_flag, contour_level_std)
%{
	for z_index = z_range
        h = figure(z_index);
        imshow(squeeze(ref_z_stack(z_index,:,:)));
        h.Position = [123 684 560 420];
        g = gca;
        g.Position = [0.1300 0.1100 0.7750 0.8150];
        xlim([1 1470])
        ylim([1 1350])
        % save 
        if save_flag
            if exist(folder_name,'dir')==0
                mkdir([folder_name,'/raw-ref']);
            end
            fig_fname = [folder_name,'/raw-ref/',sprintf('refImage_%03d.tiff',z_index)];
            saveas(h, fig_fname,'tif');
            close
        end
    end
%}    
    folder_name = [out_folder,'/ica_stack'];
    for ic_index=1:length(ICuse)
        ic_index
        
        for z_index = z_range
            h = figure(z_index);
            clf
            
            y_range = (1:1350) + (z_index-1)*1350;
            ica_filtersuse = gaussblur(squeeze(ica_filters(ICuse(ic_index),y_range,:)), sigsm);
            % in case of 3D Unwrap: size(ica_filtersuse) = [Nz*Ny Nx]
            contour(ica_filtersuse, [1,1]*(mean(ica_filtersuse(:))+contour_level_std*std(ica_filtersuse(:))), ...
                'Color','black','LineWidth',1);
            axis equal
            set(gca,'xtick',[]);
            set(gca,'ytick',[]);
            h.Position = [50 50 735 675];
            g = gca;
            g.Position = [0.1300 0.1100 0.7750 0.8150];

            if save_flag
            % save figure as image
                if exist(folder_name,'dir')==0
                    mkdir(folder_name);
                end
                fig_fname = [folder_name,'/',sprintf('%03d_%03d.tiff',[ic_index z_index])];
                saveas(h, fig_fname,'tif');
                close
            end
        end

    end
end



