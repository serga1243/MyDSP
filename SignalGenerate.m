%% Подкласс для работы во временной области:
classdef SignalGenerate < Signals
    properties
    end
    
    methods (Access = public)
%%
%
% Основные функции класса SignGen:

        %% 
        % Генерация синусоиды:
        function signal = generateSine(obj, A, F, P)
            t = genTime(obj, 1);
            signal = A*exp(1j*(2*pi*F*t + P));
        end

        
        %% 
        % Генерация радиоимпульса без модуляции:
        function signal = generateRadioPulse(obj, NN2, A, T, ti, f, phi)
            t = genTime(obj, 1);
            tend = obj.Ts*NN2;
            
            ni = floor(tend/T) + 1;
            d = linspace(0, T*(ni-1), ni);

            pulse = rectpuls(t, ti*2);
            
            signal = A*pulstran(t, d, pulse, 1/obj.Ts).*obj.generateSine(1, f, phi);
        end
        
        
        %% 
        % Генерация ЛЧМ сигнала без модуляции:
        function signal = generateLFM(obj, NN2, A, Fmin, Fmax, phi)
            t = genTime(obj, 1);
            tend = obj.Ts*NN2;
            
            f0 = (Fmax + Fmin)/2;
            b = (Fmax - Fmin)/tend;
            
            signal = A*obj.generateSine(1, phi, 2*pi*(f0*t + b/2*t.^2));
        end
        
        %%
        % Добавление норм. распреaaделенного шума:
        function noise = generateNormrnd(obj, sigma)
            noise = normrnd(0, sigma, [1 obj.Ns]) + 1j*normrnd(0, sigma, [1 obj.Ns]);
        end
        
        function noise = generateRandn(obj, sigma)
            noise = randn(1, obj.Ns)*sigma + 1j*randn(1, obj.Ns)*sigma;
        end
        
    end
end