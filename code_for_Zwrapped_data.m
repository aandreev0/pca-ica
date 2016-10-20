% sample code for work with 3d wrapped data (Y=Nz*Y slices)

ref_z_stack = permute(reshape(f0,1350,51,1470),[2,1,3]);
%imshow(squeeze(ref_z_stack(1,:,:)))
axis equal
ICuse   = 1:10;
z_range = 1:51;
% function ICAPlotUnwrap3D(ICuse, ica_filters, ref_z_stack, z_range, folder_name,sigsm, save_flag, contour_level_std)

ICAPlotUnwrap3D(ICuse, ica_filters, ref_z_stack, z_range, 'Fish1_WF_LEDonFrame100-199_Laser10Per_Taken1_ICZ_gauss_sigm3_contourLevel4_matchSize',3, true, 4)
