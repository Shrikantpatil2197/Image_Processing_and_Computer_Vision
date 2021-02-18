function resultat = SimplestColorBalanceRGB(image,s)

    imageData=double(imread(image))/255;
    figure, imshow(imageData)
    title('Originale')
        
    
    pageSize = size(imageData,1) * size(imageData,2);
    vecteur_nt=reshape(imageData,[pageSize,size(imageData,3)]);
    vecteur_t=sort(vecteur_nt);
    min=vecteur_t(1,:);
    max=vecteur_t(pageSize,:);
    
    %Balance the %
    s1=s/2;
    s2=s1;
    
    pos_v_min=floor(pageSize * s1 / 100);
    pos_v_max=floor((pageSize * (1 - (s2/100))) - 1);
    
    v_min=vecteur_t(pos_v_min,:);
    v_max=vecteur_t(pos_v_max,:);

    idx_min_r=vecteur_nt(:,1)<v_min(1);
    idx_min_g=vecteur_nt(:,2)<v_min(2);
    idx_min_b=vecteur_nt(:,3)<v_min(3);
    
    idx_max_r=vecteur_nt(:,1)>v_max(1);
    idx_max_g=vecteur_nt(:,2)>v_max(2);
    idx_max_b=vecteur_nt(:,3)>v_max(3);
    
    vecteur_nt(idx_min_r,1)=v_min(1);
    vecteur_nt(idx_min_g,2)=v_min(2);
    vecteur_nt(idx_min_b,3)=v_min(3);
    
    vecteur_nt(idx_max_r,1)=v_max(1);
    vecteur_nt(idx_max_g,2)=v_max(2);
    vecteur_nt(idx_max_b,3)=v_max(3);
    
    % f(x) = (x - Vmin) × (max - min) / (Vmax - Vmin) + min.
    for c=1:3
        for i=1:pageSize
            vecteur_nt(i,c)=((vecteur_nt(i,c)-v_min(c)) * (max(c) -min(c)) )/( (v_max(c)-v_min(c)) + min(c) );
        end
    end
    
    resultat=reshape(vecteur_nt,size(imageData));
    
    figure, imshow(resultat)
    title('resultat')
end