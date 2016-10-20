function fout = gaussblur(fin, smpix)
%
% Blur an image with a Gaussian kernel of s.d. smpix
%

    if ndims(fin)==2
        [x,y] = meshgrid([-ceil(3*smpix):ceil(3*smpix)]);
        smfilt = exp(-(x.^2+y.^2)/(2*smpix^2));
        smfilt = smfilt/sum(smfilt(:));

        fout = imfilter(fin, smfilt, 'replicate', 'same');
    else
        [x,y] = meshgrid([-ceil(smpix):ceil(smpix)]);
        smfilt = exp(-(x.^2+y.^2)/(2*smpix^2));
        smfilt = smfilt/sum(smfilt(:));

        fout = imfilter(fin, smfilt, 'replicate', 'same');
    end
end
