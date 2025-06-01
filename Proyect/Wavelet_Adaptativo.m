clear all;close all;clc;
load("Guardado_Senales_Necesarias.mat");

f = @(vars,senal) DWT_adap(vars(1), vars(2), vars(3),senal);

%x0 = [0.01,0.01,0.01];

for i = 1:10
    senal_canal_1 = senales_con_ruido{i};
    fun = @(x)f(x,senal_canal_1);
    x0 = [1,1,1];
    [x,fval] = fminsearch(fun,x0)
    [c,l] = wavedec(senal_canal_1',3,'bior3.1');
    [cd1,cd2,cd3] = detcoef(c,l,[1 2 3]);
    cd1 = wthresh(cd1,'s',x0(1));
    cd2 = wthresh(cd2,'s',x0(1));
    cd3 = wthresh(cd3,'s',x0(1));
    c_nuevo = [c(1:l(1)) cd1 cd2 cd3];
    senal_nueva{i} = waverec(c_nuevo,l,'bior3.1');
end

%% Etapa de caracteristicas 
% calculo de prd

snr_metodo_WA = {};
PRD_metodo_WA = {};
mse_metodo_WA = {};

echo on;
display('Comenzamos con el calculo de PDR');

for i = 1:10
    display('Vuelta', num2str(i))
    senal_con_ruido = senal_nueva{i};
    senal_sin_ruido = senales_con_ruido{i};
    Error=senal_con_ruido - senal_sin_ruido;
    se=Error.*Error;
    sumse=sum(se);
    ma=senal_con_ruido.*senal_sin_ruido;
    summa=sum(ma);
    prd=100*sqrt(sumse/summa);
    PRD_metodo_WA{i} = prd;
end

% calculo de snr
display('Comenzamos con el calculo de SNR');

for i = 1:10
    display('Vuelta', num2str(i))
    senal_con_ruido = senal_nueva{i};
    senal_sin_ruido = senales_con_ruido{i};
    ruido = noise{i};
    snr_aux = snr(senal_con_ruido)-snr(senal_sin_ruido);
    snr_metodo_WA{i} = snr_aux;
end

% calculo de mse
display('Comenzamos con el calculo de MSE');
for i = 1:10
    display('Vuelta', num2str(i))
    senal_con_ruido = senal_nueva{i};
    senal_sin_ruido = senales_con_ruido{i};
    mse_aux = immse(senal_sin_ruido,senal_con_ruido');
    mse_metodo_WA{i} = mse_aux;
end

%%

filename = "Metricas_Wavelets_adaptativo.mat";
save(filename,"snr_metodo_WA","mse_metodo_WA","PRD_metodo_WA")


