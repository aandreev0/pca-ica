%% plot hist of positions on image

scale_factor = 2;

x_bins = 0:30:360;
y_bins = 0:30:517;
dx = x_bins(2) - x_bins(1);
dy = y_bins(2) - y_bins(1);
zoom_factor =3;
[N,C] = hist3(cell_positions*scale_factor,'Edges',{x_bins,y_bins});

%pcolor(x_bins,y_bins,N);shading flat
figure(2)
clf
imshow(std_img);
caxis([10 50])
hold on
cmap = hot(200);

for xi = 1:length(x_bins)
    for yi = 1:length(y_bins)
        N(xi,yi)/sum(sum(N))
       w = floor(N(xi,yi)/max(max(N))*length(cmap));
       if w>0
        plot(C{1}(xi),C{2}(yi),'s','MarkerSize',dx*zoom_factor-2,'LineWidth',1,'Color',cmap(w,:)) 
        
       end
    end
end

plot(cell_positions(:,1)*scale_factor,cell_positions(:,2)*scale_factor,'o','MarkerSize',zoom_factor*4,'LineWidth',zoom_factor)
zoom(zoom_factor)