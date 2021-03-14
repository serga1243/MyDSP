%% Родительский класс MyClass:
classdef Signals
    properties
       Ts       %период дискретизации
       Ns       %число отчетов дискретизации
       signal   %и сам сигнал
       signalQ  %квантованный сигнал
    end
    
    methods (Access = public)
%%
%
% Конструктор класса Signals:
        function obj = Signals(timeSample, numSample)
            obj.Ts = double(timeSample);
            obj.Ns = double(numSample);
            obj.signal = zeros([1 obj.Ns], 'double');
            obj.signalQ = zeros([1 obj.Ns], 'double');
        end
    end
    
    methods (Access = protected)
%%
%
% Вспомогательные инструменты по генерации временного и частотного
% пространства:
        function time = genTime(obj, lent)
            if lent == 1
                time = linspace(0, (obj.Ns-1)*obj.Ts, obj.Ns);
            else
                time = linspace(0, (obj.Ns-1)*obj.Ts, lent);
            end
        end
        
    end
    
    
    methods (Access = public)
        
%%
% SignalGenerate класс - 
% работа во временной области:

        % Возвращение сигнала из объекта:
        function signal = returnSignal(obj)
            signal = obj.signal;
        end
        
        % Квантование сигнала:
        function obj = quantizeSignal(obj, b)
            q = 2^(b-1);
            signalA = obj.signal/max(obj.signal);
            obj.signalQ = floor(signalA*(q-1)); 
        end
        
        % Генерация синусоидального сигнала:
        function obj = genSine(obj, NN, A, F, P)
            sign = SignalGenerate(obj.Ts, (NN(2) - NN(1)));
            
            obj.signal(NN(1)+1:NN(2)) = obj.signal(NN(1)+1:NN(2)) + sign.generateSine(A, F, P);
        end
        
        % Генерация радиоимпульса без внутриимпульсной модуляции:
        function obj = genRadioPulse(obj, NN, A, T, ti, f, phi)
            sign = SignalGenerate(obj.Ts, (NN(2) - NN(1)));
            
            obj.signal(NN(1)+1:NN(2)) = obj.signal(NN(1)+1:NN(2)) + sign.generateRadioPulse(NN(2), A, T, ti, f, phi);
        end
        
        % Генерация ЛЧМ сигнала:
        function obj = genLFM(obj, NN, A, Fmin, Fmax, phi)
            sign = SignalGenerate(obj.Ts, (NN(2) - NN(1)));
            
            obj.signal(NN(1)+1:NN(2)) = obj.signal(NN(1)+1:NN(2)) + sign.generateLFM(NN(2), A, Fmin, Fmax, phi);
        end
        
        % Добавление гауссового шума:
        function obj = addNoise(obj, NN, type, par)
            par = 1/(10^(par/20));
            switch type
                case "normrnd"
                    sign = SignalGenerate(obj.Ts, (NN(2) - NN(1)));
                    obj.signal(NN(1)+1:NN(2)) = obj.signal(NN(1)+1:NN(2)) + sign.generateNormrnd(par);
                case "randn"
                    sign = SignalGenerate(obj.Ts, (NN(2) - NN(1)));
                    obj.signal(NN(1)+1:NN(2)) = obj.signal(NN(1)+1:NN(2)) + sign.generateRandn(par);
            end
        end
        
%%
% SpectrumGenerate класс - 
% работа в частотно-временной области:
        
        function [SAq, SPq] = spectrumQ(obj, NFFT)
            slen = length(obj.signalQ);
            N = ceil(slen/NFFT);
            sign = zeros([NFFT N], 'double');
            sign(1:slen) = obj.signalQ;
            
            S = permute(fft(sign, NFFT, 1),[2 1]);
            SAq = abs(S);
            SPq = angle(S);
        end
        
        function [SA_b, SA_f] = findFreq(~, SA, A)
            
            A = max(SA,[],'all')/A;
            SA_b = SA.*(SA > A);
            
            SA_f = logical(SA);
            SA_f(:) = false;
            for i = 1:size(SA, 1)
                [M, I] = max(SA(i,:));
                if M >= A
                    SA_f(i,I) = true;
                end
            end
        end
           
    end
end
