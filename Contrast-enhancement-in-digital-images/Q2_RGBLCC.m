function output = Q2_RGBLCC(image)
%%Fonction qui effectue (Local Color Correction) pour des images dans
%l'espce de couleurs RBG
%% Inputs are : image : the name of the coloured image

        I=double(imread(image))/255;
        figure, imshow(I)
        title('Original')
        
        %%Extract the three color chanels
        Red=I(:,:,1);
        Green=I(:,:,2);
        Blue=I(:,:,3);
        
        
        %Calculating the fft of the chanels
        DFT2d_RED=fft2(Red);
        DFT2d_Green=fft2(Green);
        DFT2d_Blue=fft2(Blue);
        [M , N, C]=size(I);
        
        %Calculate the gaussian 
        sigma=2;
        Nr = ifftshift((-fix(M/2):ceil(M/2)-1));
        Nc = ifftshift((-fix(N/2):ceil(N/2)-1));

        [Nc,Nr] = meshgrid(Nc,Nr);
        dft_gauss_kernel=exp(-2*sigma^2*pi^2*((Nr/M).^2+(Nc/N).^2)); 
        
        %Convolution of both ffts
        DFT2d_Red_convolved=DFT2d_RED.*repmat(dft_gauss_kernel,[1,1]);
        DFT2d_Green_convolved=DFT2d_Green.*repmat(dft_gauss_kernel,[1,1]);
        DFT2d_Blue_convolved=DFT2d_Blue.*repmat(dft_gauss_kernel,[1,1]);

        %calculate the inverse, choosing only the real values of each
        %chanel
        Red_convolved=ifft2(DFT2d_Red_convolved);
        MRed=real(Red_convolved);

        Green_convolved=ifft2(DFT2d_Green_convolved);
        MGreen=real(Green_convolved);

        Green_convolved=ifft2(DFT2d_Blue_convolved);
        MBlue=real(Green_convolved);

        %Application of LLC
        output=zeros(M,N,3);
        for i=1:M
            for j=1:N
                output(i,j,1)=(Red(i,j))^(2^(2*MRed(i,j)-1));
                output(i,j,2)=(Green(i,j))^(2^(2*MGreen(i,j)-1));
                output(i,j,3)=(Blue(i,j))^(2^(2*MBlue(i,j)-1));
            end
        end

        figure, imshow(output)
        title('Resultat')
        
        %Affichage
        figure; subplot(2,2,1), imshow(I), title('image Originale');
        subplot(2,2,2), imshow(output), title('Résultat');
        subplot(2,2,3), imhist(mean(I,3)), title('Histogramme avant');
        subplot(2,2,4), imhist(mean(output,3)), title('Histogramme après');

end

