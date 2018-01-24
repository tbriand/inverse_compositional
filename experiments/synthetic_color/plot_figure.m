cd ~/these/inverse_compositional/experiments/synthetic_color
% h=figure;
% ref = imread('synthetic_1.png');
% imagesc(ref), axis 'image', set(gca,'xtick',[]), set(gca,'ytick',[]);

%%
a = 0.0015;
h=figure;
epe_ic = read_tiff('epe_ic_standard.tiff');
imagesc(epe_ic, [0 a]), axis 'image', colorbar, set(gca,'xtick',[]), set(gca,'ytick',[]);
set(gcf,'color','white')
saveas(h,'epe_ic.eps','epsc');
%
h=figure;
epe_mic = read_tiff('epe_ic_optimized.tiff');
imagesc(epe_mic, [0 a]), axis 'image', colorbar, set(gca,'xtick',[]), set(gca,'ytick',[]);
set(gcf,'color','white')
saveas(h,'epe_mic.eps','epsc');
%

a=0.05;
h=figure;
diff_ic = read_tiff('diff_image_ic_standard.tiff');
[m,n] = size(diff_ic);

for i=1:m
    for j=1:n
        if isnan(diff_ic(i,j))
            diff_ic(i,j) = 0;
        end
    end
end
imagesc(diff_ic, [0 a]), axis 'image', colorbar, set(gca,'xtick',[]), set(gca,'ytick',[]);
set(gcf,'color','white')
saveas(h,'gt_diff_ic.eps','epsc');

%
h=figure;
diff_mic = read_tiff('diff_image_ic_optimized.tiff');
[m,n] = size(diff_mic);
for i=1:m
    for j=1:n
        if isnan(diff_mic(i,j))
            diff_mic(i,j) = 0;
        end
    end
end
imagesc(diff_mic, [0 a]), axis 'image', colorbar, set(gca,'xtick',[]), set(gca,'ytick',[]);
set(gcf,'color','white')
saveas(h,'gt_diff_mic.eps','epsc');