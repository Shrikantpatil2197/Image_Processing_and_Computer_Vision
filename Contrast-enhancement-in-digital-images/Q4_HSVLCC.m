function [ output ] = Q4_HSVLCC( image )
%%Fonction qui effectue (Local Color Correction) en utilisant
%l'espce de couleurs HSV
%% Inputs are : image : the name of the coloured image

        %Read the image
        I=double(imread(image))/255;
        figure, imshow(I)
        title('Originale')
        
        %From RGB to HSV
        HSV=rgb2hsv(I);
        
        %We take only the Value, Hue and saturation won't change
        Value=HSV(:,:,3);
        
        
        %Calculate the fft of the Intensity (Value)
        DFT2d_Value=fft2(Value);
        
        %Calculate the Gaussian
        [M , N]=size(Value);
        sigma=4;        
        Nr = ifftshift((-fix(M/2):ceil(M/2)-1));
        Nc = ifftshift((-fix(N/2):ceil(N/2)-1));
        [Nc,Nr] = meshgrid(Nc,Nr);
        dft_gauss_kernel=exp(-2*sigma^2*pi^2*((Nr/M).^2+(Nc/N).^2)); 

        %Convolution of the Gaussian_fft and the value_fft
        DFT2d_Value_convolved=DFT2d_Value.*repmat(dft_gauss_kernel,[1,1]);

        %Calculate the inverse, and take the real values
        Value_convolved=ifft2(DFT2d_Value_convolved);
        MValue=real(Value_convolved);

        %Application of the LCC formula
        output=zeros(M,N,3);
        for i=1:M
            for j=1:N
                output(i,j,3)=(Value(i,j))^(2^(2*MValue(i,j)-1));
            end
        end
        
        %Output will have the same Hue and Saturation, and we change only
        %the Value
        output(:,:,2)=HSV(:,:,2);
        output(:,:,1)=HSV(:,:,1);
     
        %From HSV to RGB:
        output=hsv2rgb(output);
        
        %Affichage
        figure, imshow(output)
        title('Resultat')

        %Affichage
        figure; subplot(2,2,1), imshow(I), title('image Originale');
        subplot(2,2,2), imshow(output), title('Résultat');
        subplot(2,2,3), imhist(mean(I,3)), title('Histogramme avant');
        subplot(2,2,4), imhist(mean(output,3)), title('Histogramme après');
end

