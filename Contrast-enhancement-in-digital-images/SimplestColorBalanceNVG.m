function resultat = SimplestColorBalanceNVG(image,s)
%%Fonction qui calcule: Simplest Color Balance pour des images en NVG
%inputs are :   image name
%               s : % of saturation, exp 0.2

    imageData=double(imread(image));
    imageData=mean(imageData,3);
    figure, imshow(imageData/255)
    title('Originale')
    %Get the number of pixels
    pageSize = size(imageData,1) * size(imageData,2);
    
    %Transforme the image into an array
    vecteur_nt=reshape(imageData,[pageSize,1]);
    %Sort the array
    vecteur_t=sort(vecteur_nt);
    
    %Balance the %
    s1=s/2;
    s2=s1;
    
    %Get the position of the quantiles
    pos_v_min=floor(pageSize * s1 / 100);
    pos_v_max=floor((pageSize * (1 - (s2/100))) - 1);
    
    %Get the values of (quantiles)
    v_min=vecteur_t(pos_v_min);
    v_max=vecteur_t(pos_v_max);

    %Replace the values that are greater than v_max with v_max,
    % and those which are smaller than v_min with v_min
    idx_min=vecteur_nt<v_min;
    idx_max=vecteur_nt>v_max;
    vecteur_nt(idx_min)=v_min;
    vecteur_nt(idx_max)=v_max;
    
    %Normalisation
    % f(x) = (x - Vmin) × (max - min) / (Vmax - Vmin) + min.
    for i=1:pageSize
        vecteur_nt(i)=((vecteur_nt(i)-v_min) * (255-0) )/((v_max-v_min) + 0 );
    end
    
    %Reshape the result into a matrix
    resultat=reshape(vecteur_nt,size(imageData));
    figure, imshow(resultat/255)
    title('resultat')
end