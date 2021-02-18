function output = Q3_HSILCC(image)
%%Fonction qui effectue (Local Color Correction) en utilisant
%l'espce de couleurs HSI
%% Inputs are : image : the name of the coloured image

        %Read the image
        F=double(imread(image))/255;
        figure, imshow(F)
        title('Originale')
        
        %Extraction of each color chanel
        r=F(:,:,1);
        g=F(:,:,2);
        b=F(:,:,3);
        
        %% From RGB to HSI:
        
        %Calculate the Hue
        th=acos((0.5*((r-g)+(r-b)))./((sqrt((r-g).^2+(r-b).*(g-b)))+eps));
        H=th;
        H(b>g)=2*pi-H(b>g);
        H=H/(2*pi);
        
        %Calculate the Saturation
        S=1-3.*(min(min(r,g),b))./(r+g+b+eps);
        
        %Calculate the Intensity (the mean of colors)
        I=(r+g+b)/3;
        
        %The resulting HSI ( concatenating the Hue Saturation and Intensity ) 
        hsi=cat(3,H,S,I);
        
        figure, imshow(hsi),title('HSI Image');

        %We put Value=Intensity of the image in the following
        Value=hsi(:,:,3);
        
        %Calculate the fft of the Intensity (Value)
        DFT2d_Value=fft2(Value);
        
        %Calculate the Gaussian
        [M , N]=size(Value);
        sigma=4;
        Nr = ifftshift((-fix(M/2):ceil(M/2)-1));
        Nc = ifftshift((-fix(N/2):ceil(N/2)-1));
        [Nc,Nr] = meshgrid(Nc,Nr);
        dft_gauss_kernel=exp(-2*sigma^2*pi^2*((Nr/M).^2+(Nc/N).^2)); 
        
        %Convolution of the Gaussian_fft and the intesity_fft
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
        
        %Output will have the same Hue and Saturation values, and we change
        %the intensity
        output(:,:,2)=hsi(:,:,2);
        output(:,:,1)=hsi(:,:,1);
        
        %From HSI to RGB:
        HV=output(:,:,1)*2*pi;
        SV=output(:,:,2);
        IV=output(:,:,3);
        R=zeros(size(HV));
        G=zeros(size(HV));
        B=zeros(size(HV));
        
        %RedGreen Sector
        id=find((0<=HV)& (HV<2*pi/3));
        B(id)=IV(id).*(1-SV(id));
        R(id)=IV(id).*(1+SV(id).*cos(HV(id))./cos(pi/3-HV(id)));
        G(id)=3*IV(id)-(R(id)+B(id));

        %BlueGreen Sector
        id=find((2*pi/3<=HV)& (HV<4*pi/3));
        R(id)=IV(id).*(1-SV(id));
        G(id)=IV(id).*(1+SV(id).*cos(HV(id)-2*pi/3)./cos(pi-HV(id)));
        B(id)=3*IV(id)-(R(id)+G(id));
        
        %BlueRed Sector
        id=find((4*pi/3<=HV)& (HV<2*pi));
        G(id)=IV(id).*(1-SV(id));
        B(id)=IV(id).*(1+SV(id).*cos(HV(id)-4*pi/3)./cos(5*pi/3-HV(id)));
        R(id)=3*IV(id)-(G(id)+B(id));
        
        %We concatenate the resulting RGB values
        C=cat(3,R,G,B);
        C=max(min(C,1),0);
        
        %Affichage
        figure, imshow(C)
        title('Resultat')

        %Affichage
        figure; subplot(2,2,1), imshow(F), title('image Originale');
        subplot(2,2,2), imshow(C), title('Résultat');
        subplot(2,2,3), imhist(mean(F,3)), title('Histogramme avant');
        subplot(2,2,4), imhist(mean(C,3)), title('Histogramme après');

end

