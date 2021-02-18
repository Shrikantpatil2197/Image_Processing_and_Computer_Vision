function [ output ] = Q5_HSLLLC( image )
%%Fonction qui effectue (Local Color Correction) en utilisant
%l'espce de couleurs HSL
%% Inputs are : image : the name of the colored image

        %Read the image
        Image=double(imread(image))/255;
        I=Image;
        %%From RGB to HSL
        %Find the minimum and maximum values of the image
        MinVal = min(Image,[],3);
        MaxVal = max(Image,[],3);
        
        %Now calculate the Luminace value by adding the max and min values and divide by 2.
        Luminance = 0.5*(MaxVal + MinVal);
        
        %Calculate the Saturation 
        temp = min(Luminance,1-Luminance);
        saturation = 0.5*(MaxVal - MinVal)./(temp + (temp == 0));
        [Matrice,i] = sort(Image,3);
        i = i(:,:,3);
        Delta = Matrice(:,:,3) - Matrice(:,:,1);
        Delta = Delta + (Delta == 0);
        Red = Image(:,:,1);
        Green = Image(:,:,2);
        Blue = Image(:,:,3);
        Hue = zeros(size(Red));
        
        %If Red is max, then Hue = (G-B)/(max-min) 
        k = (i == 1);
        Hue(k) = (Green(k) - Blue(k))./Delta(k);
        
        %If Green is max, then Hue = 2.0 + (B-R)/(max-min)
        k = (i == 2);
        Hue(k) = 2 + (Blue(k) - Red(k))./Delta(k);
        
        %If Blue is max, then Hue = 4.0 + (R-G)/(max-min)
        k = (i == 3);
        Hue(k) = 4 + (Red(k) - Green(k))./Delta(k);
        
        Hue = 60*Hue + 360*(Hue < 0);
        Hue(Delta == 0) = nan;

        %%Concatenating the Hue Saturation and Luminance
        Image(:,:,1) = Hue;
        Image(:,:,2) = saturation;
        Image(:,:,3) = Luminance;
        HSL=Image;
        
        %We take only the Luminance, Hue and saturation won't change
        Lum=HSL(:,:,3);
               
        %Calculate the fft of the Luminance
        DFT2d_Lum=fft2(Lum);
        
        %Calculate the Gaussian
        [M , N]=size(Lum);
        sigma=4;
        Nr = ifftshift((-fix(M/2):ceil(M/2)-1));
        Nc = ifftshift((-fix(N/2):ceil(N/2)-1));
        [Nc,Nr] = meshgrid(Nc,Nr);
        dft_gauss_kernel=exp(-2*sigma^2*pi^2*((Nr/M).^2+(Nc/N).^2)); 
        
        %Convolution of the Gaussian_fft and the Luminance_fft
        DFT2d_Lum_convolved=DFT2d_Lum.*repmat(dft_gauss_kernel,[1,1]);

        %Calculate the inverse, and take the real values
        Lum_convolved=ifft2(DFT2d_Lum_convolved);
        MLum=real(Lum_convolved);

        %Application of the LCC formula
        output=zeros(M,N,3);
        for i=1:M
            for j=1:N
                output(i,j,3)=(Lum(i,j))^(2^(2*MLum(i,j)-1));
            end
        end
        
        %Output will have the same Hue and Saturation, and we change only
        %the Luminance
        output(:,:,2)=HSL(:,:,2);
        output(:,:,1)=HSL(:,:,1);
        
        Luminance=output(:,:,3);
        Delta = Image(:,:,2).*min(Luminance,1-Luminance);

        m0=Luminance-Delta;
        m2=Luminance+Delta;
        tailleN = size(Hue);
        Hue = min(max(Hue(:),0),360)/60;
        m0 = m0(:);
        m2 = m2(:);
        F = Hue - round(Hue/2)*2;
        Matrice = [m0, m0 + (m2-m0).*abs(F), m2];
        Num = length(m0);
        j = [2 1 0;1 2 0;0 2 1;0 1 2;1 0 2;2 0 1;2 1 0]*Num;
        k = floor(Hue) + 1;
        Image = reshape([Matrice(j(k,1)+(1:Num).'),Matrice(j(k,2)+(1:Num).'),Matrice(j(k,3)+(1:Num).')],[tailleN,3]);
            
        
        
        %From HSL to RGB:
        %Luminance=output(:,:,3);
        %if all(saturation==0)
        %    R=Luminance.*255;
        %    G=Luminance.*255;
        %    B=Luminance.*255;
        %else
        %    if (Luminance<0.5)
        %        var_2=Luminance.*(1+saturation);
%             else
%                 var_2=(Luminance+saturation)-(saturation.*Luminance);
%             end 
%             var_1 = 2.*Luminance - var_2;
%             
%             Hue=193./360;
%             R = 255 * Hue_2_RGB( var_1, var_2, Hue + ( 1 / 3 ) ) ;
%             G = 255 * Hue_2_RGB( var_1, var_2, Hue );
%             B = 255 * Hue_2_RGB( var_1, var_2, Hue - ( 1 / 3 ) );
%          end
%             output(:,:,1)=R;
%             output(:,:,2)=G;
%             output(:,:,3)=B;
            
            figure,imshow(I)
            figure,imshow(Image)
        %Affichage
        figure; subplot(2,2,1), imshow(I), title('image Originale');
        subplot(2,2,2), imshow(Image), title('Résultat');
        subplot(2,2,3), imhist(mean(I,3)), title('Histogramme avant');
        subplot(2,2,4), imhist(mean(Image,3)), title('Histogramme après');

        
end

