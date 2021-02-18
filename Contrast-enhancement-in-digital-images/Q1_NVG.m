function []=Q1_NVG(choix)
%%Fonction qui effectue (Local Color Correction) pour des images dans
%%l'espce de couleurs NVG
%   Choix = 1, travailler avec des valeurs entre 0 et 1
%   sinon,  travailler avec des valeurs entre 0 et 255
%   Les deux formules utilisées pour le calcule sont différentes

    image='Capture2RGB.PNG';
    if choix==1
        %lire l'image
        I=double(imread(image))/255;
        I=mean(I,3);
        sigma=2;
        %Calcule de la DFT de l'image
        DFT2d_I=fft2(I);
        
        %Calcule de la gaussienne
        [ysize , xsize]=size(I);
        Nr = ifftshift((-fix(ysize/2):ceil(ysize/2)-1));
        Nc = ifftshift((-fix(xsize/2):ceil(xsize/2)-1));
        [Nc,Nr] = meshgrid(Nc,Nr);
        dft_gauss_kernel=exp(-2*sigma^2*pi^2*((Nr/ysize).^2+(Nc/xsize).^2)); 
        
        %Convolution avec la gaussienne (fft(I).*fft(G)) 
        DFT2d_I_convolved=DFT2d_I.*repmat(dft_gauss_kernel,[1,1]);
        I_convolved=ifft2(DFT2d_I_convolved);
        M=real(I_convolved);

        output=zeros(ysize,xsize);
        for i=1:ysize
            for j=1:xsize
                output(i,j)=(I(i,j))^(2^(2*M(i,j)-1));
            end
        end

        
        %Affichage
        figure; subplot(2,2,1), imshow(I), title('image Originale');
        subplot(2,2,2), imshow(output), title('Résultat');
        subplot(2,2,3), imhist(I), title('Histogramme avant');
        subplot(2,2,4), imhist(output), title('Histogramme après');
        
    else
        %lire l'image
        I=double(imread(image));
        I=mean(I,3);
        
        %Calcule de l'image inverse
        Inv=255-I;
        
        %Calcule de la DFT
        DFT2d_I=fft2(Inv);
        
        %Caclule de la gaussienne
        sigma=2;
        [ysize , xsize]=size(I);
        Nr = ifftshift((-fix(ysize/2):ceil(ysize/2)-1));
        Nc = ifftshift((-fix(xsize/2):ceil(xsize/2)-1));
        [Nc,Nr] = meshgrid(Nc,Nr);
        dft_gauss_kernel=exp(-2*sigma^2*pi^2*((Nr/ysize).^2+(Nc/xsize).^2)); 
        
        %Convolution avec la gaussienne (fft(I).*fft(G)) 
        DFT2d_I_convolved=DFT2d_I.*repmat(dft_gauss_kernel,[1,1]);

        I_convolved=ifft2(DFT2d_I_convolved);
        M=real(I_convolved);

        output=zeros(ysize,xsize);
        for i=1:ysize
            for j=1:xsize
                output(i,j)=255.0*((I(i,j)/255.0)^(2^((128.0-M(i,j))/128.0)));
            end
        end
    

        %Affichage
        figure; subplot(2,2,1), imshow(I/255), title('image Originale');
        subplot(2,2,2), imshow(output/255), title('Résultat');
        subplot(2,2,3), imhist(I/255), title('Histogramme avant');
        subplot(2,2,4), imhist(output/255), title('Histogramme après');
        
    end

end
    

