%% Etapa Filtros Pasa alto y pasa bajo
clear all;close all;clc;
load("Guardado_Senales_Necesarias.mat");
%% Procedemos con el caclulo luego de liberar memoria

num_l = [0.8576 -0.032 0.8629 -0.0811]; 
den_l = [1 -1.2096 0.2696 0.0144]; 
filtro_pasa_bajo = tf(num_l, den_l,1);

num_h = [-0.5034 1.9441 -1.9441 0.5034];
den_h = [1 -1.1737 0.2982 0.0245];
filtro_pasa_alto = tf(num_h, den_h,1);

figure;
bode(filtro_pasa_bajo)
hold on 
bode(filtro_pasa_alto)
etapa_L = {};
etapa_H = {};
etapa_1_2 = {};

for i = 1:10  
    display('Vuelta', num2str(i))
    senal_con_ruido = senales_con_ruido{i};
    %senal_sin_ruido = senales_sin_ruido{i};
    etapa_1 = filter(num_l, den_l,senal_con_ruido);
    etapa_L{i} = etapa_1;
    etapa_H{i} = filter(num_h,den_h,senal_con_ruido);
    etapa_1_2{i} = filter(num_h,den_h,etapa_1);
    
end

%% 

snr_solo_senal_Filtrado_h = {};
snr_solo_senal_Filtrado_l = {};
snr_comparativo_Filtrado = {};
PRD_Filtrado_l = {};
PRD_Filtrado_h = {};
mse_Filtrado_l = {};
mse_Filtrado_h = {};

echo on;
display('Comenzamos con el calculo de PDR');

for i = 1:10
    display('Vuelta', num2str(i))
    senal_con_ruido_h = etapa_H{i};
    senal_con_ruido_l = etapa_L{i};
    senal_sin_ruido = senales_con_ruido{i};
    Error_h = senal_con_ruido_h - senal_sin_ruido;
    Error_l = senal_con_ruido_l - senal_sin_ruido;
    se_l=Error_l.*Error_l;
    se_h=Error_h.*Error_h;
    sumse_l=sum(se_l);
    sumse_h=sum(se_h);
    ma_h = senal_con_ruido_h.*senal_sin_ruido;
    ma_l = senal_con_ruido_l.*senal_sin_ruido;
    summa_h=sum(ma_h);
    summa_l=sum(ma_l);
    prd_h=100*sqrt(sumse_h/summa_h);
    prd_l = 100*sqrt(sumse_l/summa_l);
    PRD_Filtrado_l{i} = prd_l;
    PRD_Filtrado_h{i} = prd_h;
end

% calculo de snr
display('Comenzamos con el calculo de SNR');

for i = 1:10
    display('Vuelta', num2str(i))
    senal_con_ruido_h = etapa_H{i};
    senal_con_ruido_l = etapa_L{i};
    senal_sin_ruido = senales_con_ruido{i};
    %ruido = noise{i};
    snr_aux_h = snr(senal_con_ruido_h)-snr(senal_sin_ruido);
    snr_aux_l = snr(senal_con_ruido_l)-snr(senal_sin_ruido);
    snr_solo_senal_Filtrado{i} = snr(senal_sin_ruido)
    snr_comparativo_Filtrado_h{i} = snr_aux_h;
    snr_comparativo_Filtrado_l{i} = snr_aux_l;
end

% calculo de mse
display('Comenzamos con el calculo de MSE');
for i = 1:10
    display('Vuelta', num2str(i))
    senal_con_ruido_h = etapa_H{i};
    senal_con_ruido_l = etapa_L{i};
    senal_sin_ruido = senales_con_ruido{i};
    mse_aux_h = immse(senal_sin_ruido,senal_con_ruido_h);
    mse_aux_l = immse(senal_sin_ruido,senal_con_ruido_l);
    mse_Filtrado_h{i} = mse_aux_h;
    mse_Filtrado_l{i} = mse_aux_l;
end

%%
filename = "Metricas_Filtrado_HL.mat";
save(filename,"mse_Filtrado_l","mse_Filtrado_h","PRD_Filtrado_h","PRD_Filtrado_l","snr_comparativo_Filtrado_l","snr_comparativo_Filtrado_h")


