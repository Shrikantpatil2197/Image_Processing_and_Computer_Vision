function result = Poisson( image,s,lambda)
%%Fucntion that calculate Screened Poisson Equation for Image Contrast Enhancement
%   inputs are :    image,
%                   s: the % of saturation exp 0.2
%                   lambda, exp 0.0001

        %Lire l'image
        imageData=double(imread(image));

        %extraction des différents canaux
        red=imageData(:,:,1);
        green=imageData(:,:,2);
        blue=imageData(:,:,3);
        
        %Saturation
        img_sat_red=SimplestColorBalance(red,s);
        img_sat_green=SimplestColorBalance(green,s);
        img_sat_blue=SimplestColorBalance(blue,s);
        
        %Periodisation
        img_prd_red=periodique(img_sat_red);
        img_prd_green=periodique(img_sat_green);
        img_prd_blue=periodique(img_sat_blue);
        
        %Calcule des FFTs
        fft_img_red=(fft2(img_prd_red));
        fft_img_green=(fft2(img_prd_green));
        fft_img_blue=(fft2(img_prd_blue));
        
        
        [J,L]=size(fft_img_red);
        fft_u_red=zeros(J,L);
        fft_u_green=zeros(J,L);
        fft_u_blue=zeros(J,L);
        
        
        %%Application de la formule de poisson sur chaque canal
        for m=1:J
            for n=1:L
                fft_u_red(m,n)=(((pi*m/J)^2+(pi*n/L)^2)/(lambda+(pi*m/J)^2+(pi*n/L)^2))*fft_img_red(m,n);
                fft_u_green(m,n)=(((pi*m/J)^2+(pi*n/L)^2)/(lambda+(pi*m/J)^2+(pi*n/L)^2))*fft_img_green(m,n);
                fft_u_blue(m,n)=(((pi*m/J)^2+(pi*n/L)^2)/(lambda+(pi*m/J)^2+(pi*n/L)^2))*fft_img_blue(m,n);
            end
        end

        [M,N,~]=size(imageData);
        %%calcule de l'inverse, prendre la partie réelle
        u_red=real(ifft2(fft_u_red));
        u_green=real(ifft2(fft_u_green));
        u_blue=real(ifft2(fft_u_blue));
        
        %%saturation
        result(:,:,1)=SimplestColorBalance(u_red(1:M,1:N),s);
        result(:,:,2)=SimplestColorBalance(u_green(1:M,1:N),s);
        result(:,:,3)=SimplestColorBalance(u_blue(1:M,1:N),s);
        
        
        figure; subplot(2,2,1), imshow(imageData/255), title('image Originale');
        subplot(2,2,2), imshow(result/255), title('Résultat');
        subplot(2,2,3), imhist(mean(imageData(:,:,1),3)/255), title('Histogramme avant');
        subplot(2,2,4), imhist(mean(result(:,:,1),3)/255), title('Histogramme après');

end

