%%Aplicacion todo dataset
clear all;close all;clc;
load("Datos.mat");

largo_maximo = 16384;%32768;
% senales_sin_ruido = {};
% senales_con_ruido = {};

frecuencia = 60; % en Hz
frecuencia_muestreo = 360; % en Hz 

for i = 1:largo_maximo
    amplitud(i) = rand/5;
end

for i = 1:10
    senal = signal{i};
    senal = senal(1:largo_maximo);
    senales_sin_ruido{i} = senal;
    tm_aux = tm{i};
    tm_aux = tm_aux(1:largo_maximo);

    senal_sinusoidal = sin(2 * pi * frecuencia * tm_aux);
    noise{i} = senal_sinusoidal;
    for j = 1:length(senal)
        senal_total(j,1) = senal(j) + amplitud(j)*senal_sinusoidal(j);
    end

    senales_con_ruido{i} = senal_total;

end
figure;
plot(senal_total)
hold on
plot(senal)
%%
clear i; clear j;
filename = "Guardado_Senales_Necesarias.mat";
save(filename)


%% Etapa de caracteristicas 
% calculo de prd

snr_solo_senal_sin_metodo = {};
snr_comparativo_sin_metodo = {};
PRD_sin_metodo = {};
mse_sin_metodo = {};

echo on;
display('Comenzamos con el calculo de PDR');

for i = 1:10
    display('Vuelta', num2str(i))
    senal_con_ruido = senales_con_ruido{i};
    senal_sin_ruido = senales_sin_ruido{i};
    Error=senal_con_ruido - senal_sin_ruido;
    se=Error.*Error;
    sumse=sum(se);
    ma=senal_con_ruido.*senal_sin_ruido;
    summa=sum(ma);
    prd=100*sqrt(sumse/summa);
    PRD_sin_metodo{i} = prd;
end

% calculo de snr
display('Comenzamos con el calculo de SNR');

for i = 1:10
    display('Vuelta', num2str(i))
    senal_con_ruido = senales_con_ruido{i};
    senal_sin_ruido = senales_sin_ruido{i};
    ruido = noise{i};
    snr_aux = snr(senal_con_ruido)-snr(senal_sin_ruido);
    snr_solo_senal_sin_metodo{i} = snr(senal_sin_ruido)
    snr_comparativo_sin_metodo{i} = snr_aux;
end

% calculo de mse
display('Comenzamos con el calculo de MSE');
for i = 1:10
    display('Vuelta', num2str(i))
    senal_con_ruido = senales_con_ruido{i};
    senal_sin_ruido = senales_sin_ruido{i};
    mse_aux = immse(senal_sin_ruido,senal_con_ruido');
    mse_sin_metodo{i} = mse_aux;
end
%%
figure;
plot(tm{2}(1:largo_maximo),senales_con_ruido{2});
title('Registro ECG MIT-BIH Arrhythmia');
xlabel('Muestras');
ylabel('Amplitud');
hold on
grid on
plot(tm{2}(1:largo_maximo),senales_sin_ruido{2});
legend('Señal con ruido','Señal original');



%% Dado que los calculos son bastante dificiles para el computador, eliminamos varuiable y las guardamos en archivos .mat
clear amplitud; clear Error; clear filename;
clear i; clear j; clear ma; clear mse_aux;
clear pdr; clear se; clear senal_sinusoidal;
clear senal total; clear snr_aux; clear summa; clear summse;
clear tm_aux;
filename = "Guardado_Post_Primer_Bloque.mat";
save(filename)

%% Metricas bases
filename = "Metricas_Sin_metodo.mat";
save(filename,"snr_comparativo_sin_metodo", "PRD_sin_metodo","mse_sin_metodo")






